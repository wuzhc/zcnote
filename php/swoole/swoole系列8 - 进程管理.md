## 为什么要使用Swoole的Process，而不是pcntl

[Process](https://wiki.swoole.com/#/process/process) 是 Swoole 提供的进程管理模块，用来替代 PHP 的 `pcntl`。`PHP` 自带的 `pcntl`，存在很多不足，如：

- 没有提供进程间通信的功能
- 不支持重定向标准输入和输出
- 只提供了 `fork` 这样原始的接口，容易使用错误

在协程环境中无法使用 `Process` 模块，可以使用 `runtime hook`+`proc_open` 实现，参考[协程进程管理](https://wiki.swoole.com/#/coroutine/proc_open)


## 基础知识

php使用fork创建子进程的时候有3个返回结果，-1表示失败，0表示子进程，pid有值表示父进程

### 僵尸进程

子进程退出后，父进程没有调用wait()或waitpid()来回收子进程，导致子进程的描述符等资源一直留在系统中（保持在进程表里并会一直等待父进程获取其退出状态）。

危害：

如果进程不调用 wait()/waitpid() 的话， 那么保留的那段信息就不会释放，其进程号就会一直被占用，但是系统所能使用的进程号是有限的，如果大量的产生僵尸进程，将因为没有可用的进程号（或者句柄）而导致系统不能产生新的进程， 此即为僵尸进程的危害，应当避免 。
任何一个子进程（init 除外）在 exit() 之后，都会留下一个称为僵尸进程（Zombie）的数据结构 。

解决方法：

```bash
# 方法一，传递信号给其父进程，命令其回收子进程的资源
kill -CHLD  + 父进程号

# 方法二，直接 KILL 掉其父进程，将此进程变成孤儿进程，交给 init 进程管理，init 进程回收此进程的资源
kill -9 + 父进程号
```

### 孤儿进程

一个父进程退出，而它的一个或多个子进程还在运行，那么那些子进程将成为孤儿进程。孤儿进程将被 init 进程继承，并由 init 进程对它们完成状态收集工作

危害：

孤儿进程退出后的后续工作由init处理，所以不会有什么危害。



## Process

```php
use Swoole\Process;

for ($n = 1; $n <= 3; $n++) {
    $process = new Process(function () use ($n) {
        echo 'Child #' . getmypid() . " start and sleep {$n}s" . PHP_EOL;
        sleep($n);
        echo 'Child #' . getmypid() . ' exit' . PHP_EOL;
    });
    $process->start();
}
for ($n = 3; $n--;) {
    $status = Process::wait(true);
    echo "Recycled #{$status['pid']}, code={$status['code']}, signal={$status['signal']}" . PHP_EOL;
}
echo 'Parent #' . getmypid() . ' exit' . PHP_EOL;
```

- start（）成功返回子进程的 `PID`
- 失败返回 `false`。可使用 [swoole_errno](https://wiki.swoole.com/#/functions?id=swoole_errno) 和 [swoole_strerror](https://wiki.swoole.com/#/functions?id=swoole_strerror) 得到错误码和错误信息。
- 子进程会继承父进程的内存和文件句柄
- 子进程在启动时会清除从父进程继承的 [EventLoop](https://wiki.swoole.com/#/learn?id=%e4%bb%80%e4%b9%88%e6%98%afeventloop)、[Signal](https://wiki.swoole.com/#/process/process?id=signal)、[Timer](https://wiki.swoole.com/#/timer)

执行后子进程会保持父进程的内存和资源，如父进程内创建了一个 redis 连接，那么在子进程会保留此对象，所有操作都是对同一个连接进行的。以下举例说明

```PHP
$redis = new Redis;
$redis->connect('127.0.0.1', 6379);

function callback_function() {
    swoole_timer_after(1000, function () {
        echo "hello world\n";
    });
    global $redis;//同一个连接
};

swoole_timer_tick(1000, function () {
    echo "parent timer\n";
});//不会继承

Swoole\Process::signal(SIGCHLD, function ($sig) {
    while ($ret = Swoole\Process::wait(false)) {
        // create a new child process
        $p = new Swoole\Process('callback_function');
        $p->start();
    }
});

// create a new child process
$p = new Swoole\Process('callback_function');

$p->start();
```

- 子进程启动后会自动清除父进程中 [Swoole\Timer::tick](https://wiki.swoole.com/#/timer?id=tick) 创建的定时器、[Process::signal](https://wiki.swoole.com/#/process/process?id=signal) 监听的信号和 [swoole_event_add](https://wiki.swoole.com/#/event?id=add) 添加的事件监听；
- 子进程会继承父进程创建的 `$redis` 连接对象，父子进程使用的连接是同一个



## [Process\Pool](https://wiki.swoole.com/#/learn?id=processpool)

[Process\Pool](https://wiki.swoole.com/#/process/process_pool) 是将 Server 的进程管理模块封装成了 PHP 类，支持在 PHP 代码中使用 Swoole 的进程管理器。

在实际项目中经常需要写一些长期运行的脚本，如基于 `Redis`、`Kafka`、`RabbitMQ` 实现的多进程队列消费者，多进程爬虫等等，开发者需要使用 `pcntl` 和 `posix` 相关的扩展库实现多进程编程，但也需要开发者具备深厚的 `Linux` 系统编程功底，否则很容易出现问题，使用 Swoole 提供的进程管理器可大大简化多进程脚本编程工作。

- 保证工作进程的稳定性；
- 支持信号处理；
- 支持消息队列和 `TCP-Socket` 消息投递功能；



## 参考

- <https://www.cnblogs.com/zzzwqh/p/13567004.html>



