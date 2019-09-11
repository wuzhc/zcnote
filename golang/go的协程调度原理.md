# golang协程调度原理
golang协程调度原理主要是MPG三者的关系

## 参考
- https://www.cnblogs.com/linguanh/p/9510746.html
- http://lessisbetter.site/2019/04/04/golang-scheduler-3-principle-with-graph/

## 调度器的三个基本对象
- M 工作线程
- P 处理器,是M的上下文
- G goroutine,协程,系统调度最基本单位,代码中使用`go关键字`时候会创建的对象

## G，M，P 三者的关系与特点
- 每一个运行的M必须绑定P,线程M会去检查和执行G对象
- P的个数就是GOMAXPROCS,每一个P维护一个G队列
- M的个数不一定等于P的个数
- 除了P维护的G队列,还有全局的G队列
- 空闲的P会新建一个M来绑定它,这个时候P是空闲的,它会从全局队列中获取一些G到自己的本地队列,公式为`n = min(len(GQ)/GOMAXPROCS + 1, len(GQ/2))`

## G负载均衡
- 从当前M绑定的P维护的G队列查找
- 去别的P维护的G队列查找
- 从全局G队列查找

## 协程G切换
协程的切换时间片是10ms，也就是说 goroutine 最多执行10ms就会被 M 切换到下一个 G。这个过程，又被称为 中断，挂起
- P有一个标记G执行次数的计数,每执行一个G计数就会递增,如果一直没有没有递增,并且超过10ms就会在G任务的栈信息加一个tag标记,如果遇到非内联函数,就去检查这个tag标记,然后中断,重新加入到队列的尾部,执行下一个G
- 如果没有遇到非内联函数,就会一直执行直到结束,如果P=1,M=1,则拥有都不会切换到其他G,一直死循环

## G中断后恢复
- 中断的时候将寄存器里的栈信息，保存到自己的 G 对象里面
- 再次轮到自己执行时，将自己保存的栈信息复制到寄存器里面，这样就接着上次之后运

## 局部G队列和全局G队列

## GOMAXPROCS的作用
`GOMAXPROCS`即P的数量,即它决定了P的个数,P的个数决定了M的个数(因为一个空闲的P将由新建的M来绑定P),而M的个数决定了各个G队列能同时被多少个M线程来进行调取执行

## 重点
- 内联函数`(inline call)`会触发`goroutine`的调用,通过`go run -gcflags -m main.go`可以查看是否为内联函数 

![http://img.lessisbetter.site/2019-04-arch.png](http://img.lessisbetter.site/2019-04-arch.png)
*Go调度本质是把大量的goroutine分配到少量线程上去执行，并利用多核并行，实现更强大的并发。*