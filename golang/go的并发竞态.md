一个`goroutine`内执行是顺序执行,但是我们无法知道一个`goroutine`中的事件x和另一个`goroutine`中的事件y的先后顺序(几个串行程序交错执行),竞态表现在同时对同一个共享变量进行读写

## 方法
- 不要修改变量
- 限制变量只能一个`goroutine`访问 ( go真言:不要用共享内存来通信,而用通信来共享内存 )
- 互斥机制,同一时间只有一个`goroutine`访问

## 互斥锁 sync.Mutex
```go
var mu sync.Mutex
func Balance() int {
	defer mu.Unlock()
	mu.Lock()
	return balance
}
```

##  读写互斥锁 (多读单写锁) sync.RWMutex
允许读并发,不允许写并发
- 在有写的情况下,加了读锁不能读
- 在没写的情况下,加了读锁可以读
