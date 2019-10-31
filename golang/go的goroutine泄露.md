# goroutine泄露
主要有两种方式:
- channel错误使用

## 危害
- goroutine泄露,导致它引用的内存不能被回收,进而导致内存泄露

## 参考
- https://studygolang.com/articles/12495?fr=sidebar

## channel错误使用
### 发送到一个没有接收者的 channel
**往channel写入数据,但是channel其实随着函数退出而消失了**
```go
func queryAll() int {  
    ch := make(chan int)  
    go func() { ch <- query() }() 
    go func() { ch <- query() }()  
    go func() { ch <- query() }()  
    return <-ch  
}
```
- 上面代码中,channel只接收到一个query(),就退出了,其他两个query()就相当于发送给没有接受者的channel,将永远阻塞在那里
- 一个好的习惯是当使用完channel之后,调用close关闭channel,这样其他两个query()继续发送给ch时,会报`panic: send on closed channel`错误

### 从没有发送者的 channel 中接收数据
**写入到 nil channel 会永远阻塞,这种情况出现在忘记创建channel**
```go
var ch chan int  
if false {  
	ch = make(chan int, 1)  
	ch <- 1  
}  
// 这个gorotine将永远堵在这里
go func(ch chan int) {  
	<-ch  
}(ch)
```

## 解决方法
- 使用`context`
当产生多个goroutine时,使用context来通知goroutine退出
```go
func main() {
    ctx, cancel := context.WithCancel(context.Background())
 
    ch := func(ctx context.Context) <-chan int {
        ch := make(chan int)
        go func() {
            for i := 0; ; i++ {
                select {
                case <- ctx.Done():
                    return
                case ch <- i:
                }
            }
        } ()
        return ch
    }(ctx)
 
    for v := range ch {
        fmt.Println(v)
        if v == 5 {
            cancel()
            break
        }
    }
}
```