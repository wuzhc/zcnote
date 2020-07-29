## 对channel读写会出现的问题
- 从一个nil channel读数据，造成永远阻塞
- 给一个nil channel写数据，造成永远阻塞
- 从一个已关闭的channel读数据，返回零值
- 给一个已关闭的channel写数据，会引发panic
- 多次关闭channel会引发panic
- 判断channel是否关闭，可以使用ok判断法
- channel是线程安全，多个goroutine操作同个channel，不会发生资源竞争问题

## golang的csp并发模型
https://www.jianshu.com/p/36e246c6153d
CSP 全称是 “Communicating Sequential Processes”，用于描述两个独立的并发实体通过共享的通讯 channel(管道)进行通信的并发模型
golang仅仅是借用了 process和channel这两个概念。process是在go语言上的表现就是 goroutine 是实际并发执行的实体，每个实体之间是通过channel通讯来实现数据共享
*不要通过共享内存来通信，而要通过通信来实现内存共享。*

## channel底层结构
```golang
type hchan struct {
    // chan 里元素数量
    qcount   uint
    // chan 底层循环数组的长度
    dataqsiz uint
    // 指向底层循环数组的指针
    // 只针对有缓冲的 channel
    buf      unsafe.Pointer
    // chan 中元素大小
    elemsize uint16
    // chan 是否被关闭的标志
    closed   uint32
    // chan 中元素类型
    elemtype *_type // element type
    // 已发送元素在循环数组中的索引
    sendx    uint   // send index
    // 已接收元素在循环数组中的索引
    recvx    uint   // receive index
    // 等待接收的 goroutine 队列
    recvq    waitq  // list of recv waiters
    // 等待发送的 goroutine 队列
    sendq    waitq  // list of send waiters
    // 保护 hchan 中所有字段
    lock mutex
}
```
这么多字段，只要记下下面字段即可：
- buf 指向底层循环数组，只有缓冲型的 channel 才有。
- sendx，recvx 均指向底层循环数组，表示当前可以发送和接收的元素位置索引值（相对于底层数组）。
- sendq，recvq 分别表示被阻塞的 goroutine，这些 goroutine 由于尝试读取 channel 或向 channel 发送数据而被阻塞。
可以这么记住：
- channel肯定有读有写，那么一定会维护两个队列，一个是等待接收g队列，一个是等待写g队列即`sendq`，`recvq`。
- channel是有缓冲区的，那么就需要有一个存放的地方，这个地方就是buf，它指向底层循环数组。既然是循环数组，那么肯定有当前可以接收或发送元素的位置索引即`sendx`，`recvx`


## channel 发送和接收元素的本质是什么
channel 的发送和接收操作本质上都是 “值的拷贝”，无论是从 sender goroutine 的栈到 chan buf，还是从 chan buf 到 receiver goroutine，或者是直接从 sender goroutine 到 receiver goroutine

## channel接收数据是怎么样的？
- 一种带 “ok”，反应 channel 是否关闭
- 一种是不带"ok"

## channel 在什么情况下会引起资源泄漏
`goroutine`一直处于处于发送或接收阻塞状态，而channel的状态一直没有改变；例如一channel，有两个goroutine，一个读，一个写，结果一个读意外退出了，导致写一直处于阻塞状态；
另外，程序运行过程中，对于一个 channel，如果没有任何 goroutine 引用了，gc 会对其进行回收操作，不会引起内存泄漏。

## 如何优雅的关闭channel?
- (1)一个 sender，一个 receiver
- (2)一个 sender， M 个 receiver
- (3)N 个 sender，一个 reciver
- (4)N 个 sender， M 个 receiver
对于一个sender而言，在sender关闭
对于多个sender,一个receiver，则增加多一个channel，接收者通过channel发出关闭指令，发送者监控到channel的关闭指令则停止发送
对于多个sender,多个receiver而言，需要一个中间人，接收者和发送者都监控中间人关闭状态，另外中间人需要被设计为带缓存的channel,这是因为如果中间人所在的goroutine未准备好，那么第一个发送信号可能会丢失。
