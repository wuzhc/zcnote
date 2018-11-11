- runtime.Goexit() // 终止当前 goroutine
- runtime.Gosched()用于让出CPU时间片

- 如果某个goroutine panic了，而且这个goroutine里面没有捕获(recover)，那么整个进程就会挂掉。所以，好的习惯是每当go产生一个goroutine，就需要写下recover。