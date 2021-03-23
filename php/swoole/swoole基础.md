## Parallel 特性

## WaitGroup 特性

## Defer 特性

## Concurrent 协程运行控制



## [是否可以共用 1 个 Redis 或 MySQL 连接](https://wiki.swoole.com/#/question/use?id=%e6%98%af%e5%90%a6%e5%8f%af%e4%bb%a5%e5%85%b1%e7%94%a81%e4%b8%aaredis%e6%88%96mysql%e8%bf%9e%e6%8e%a5)

绝对不可以。必须每个进程单独创建 `Redis`、`MySQL`、`PDO` 连接，其他的存储客户端同样也是如此。原因是如果共用 1 个连接，那么返回的结果无法保证被哪个进程处理，持有连接的进程理论上都可以对这个连接进行读写，这样数据就发生错乱了。

**所以在多个进程之间，一定不能共用连接**

- 在 [Swoole\Server](https://wiki.swoole.com/#/server/init) 中，应当在 [onWorkerStart](https://wiki.swoole.com/#/server/events?id=onworkerstart) 中创建连接对象

- 在 [Swoole\Process](https://wiki.swoole.com/#/process/process) 中，应当在 [Swoole\Process->start](https://wiki.swoole.com/#/process/process?id=start) 后，子进程的回调函数中创建连接对象

-  