## goroutine和线程区别
- 每个os线程固定栈大小为2MB,而`goroutine`开始为2kb,之后可以增长,可以达到1GB
- `goroutine`的调度成本比线程低 ( 线程有os内核调度,先将一个线程的状态保存到内存,再恢复另一个线程状态,最后更新调度器的数据结构 )

## GOMAXPROCS
go调度器使用`GOMAXPROCS`参数来确定需要多少个os线程来同时执行go代码,可以通过`GOMAXPROCS`环境变量或`runtime.GOMAXPROCS`来控制参数,默认值为机器上cpu数量