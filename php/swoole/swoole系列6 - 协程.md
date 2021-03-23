从 4.0 版本开始 `Swoole` 提供了完整的`协程（Coroutine）`+ `通道（Channel）`特性，带来全新的 `CSP` 编程模型。



 ## [什么是协程](https://wiki.swoole.com/#/coroutine?id=%e4%bb%80%e4%b9%88%e6%98%af%e5%8d%8f%e7%a8%8b)

协程可以简单理解为线程，只不过这个线程是用户态的，不需要操作系统参与，创建销毁和切换的成本非常低，和线程不同的是协程没法利用多核 cpu 的，想利用多核 cpu 需要依赖 `Swoole` 的多进程模型。（go语言是可以利用多核cpu的）

### 创建协程有哪些方法

- `coroutine::create`或`go`方法创建
- 设置`Http Server`的`enable_coroutine`为true时，` onRequest`回调函数中会自动创建协程

### 底层原理

- 调用 Swoole\Http\Server 的 onRequest 事件回调函数时，底层会调用 C 函数 `coro_create` 创建一个协程（#1位置）；
- 调用 mysql->connect 时会发生 IO 操作，底层会调用 C 函数 `coro_save` 保存当前协程的状态，包括 ZendVM 上下文以及协程描述信息，并调用 `coro_yield` 让出程序控制权，当前的请求会挂起（#2位置）；
- 协程让出程序控制权后，会继续进入 HTTP 服务器的事件循环处理其他事件，这时 Swoole 可以继续去处理其他客户端发来的请求；
- 当数据库 IO 事件完成后，MySQL 连接成功或失败，底层调用 C 函数 `coro_resume` 恢复对应的协程，恢复 ZendVM 上下文，继续向下执行 PHP 代码（#3位置）；
- mysql->query 的执行过程与 mysql->connect 一样，也会触发 IO 事件并进行一次协程切换调度；
  所有操作完成后，调用 end 方法返回结果，并销毁此协程。
  总结：Swoole 底层会在 IO 事件发生时，保存当前状态，将程序控制权交出，以便 CPU 处理其它事件，当 IO 事件完成时恢复并继续执行后续逻辑，从而实现异步 IO 的功能，这正是协程的强大之处，它可以让服务器同时可以处理更多请求，而不会阻塞在这里等待 IO 事件处理完成，从而极大提高系统的并发性。

### 引入协程带来的问题

- 每个协程被挂起时，需要保存栈内存并维护对应的状态，如果程序并发很大可能会占用大量内存；
- 协程调度会增加额外的一些 CPU 开销

### 使用协程需要注意哪些问题？

- 协程编程中可直接使用 try/catch 处理异常，但必须在协程内捕获，不得跨协程捕获异常（即不能将 go 函数放到 try 语句块中，这样就是跨协程捕获异常了），协程内使用 exit 终止程序执行退出当前协程的话，会抛出 Swoole\ExitException 异常。
- 所有协程必须在协程容器`Co\run(function(){})`中使用
- go如果挂起，就会接着往下面走程序，当程序不能够往下执行，才会resume
- 协程容器Co\run可当成是同步中的执行的一个函数，只有执行完该函数后才可继续执行；
- 协程容器中不能再创建协程容器



## [什么是协程容器](https://wiki.swoole.com/#/coroutine?id=%e4%bb%80%e4%b9%88%e6%98%af%e5%8d%8f%e7%a8%8b%e5%ae%b9%e5%99%a8)

所有的[协程](https://wiki.swoole.com/#/coroutine)必须在`协程容器`里面[创建](https://wiki.swoole.com/#/coroutine/coroutine?id=create)，`Swoole` 程序启动的时候大部分情况会自动创建`协程容器`，用 `Swoole` 启动程序的方式一共有三种：

- 调用[异步风格](https://wiki.swoole.com/#/server/init)服务端程序的 [start](https://wiki.swoole.com/#/server/methods?id=start) 方法，此种启动方式会在事件回调中创建`协程容器`，参考 [enable_coroutine](https://wiki.swoole.com/#/server/setting?id=enable_coroutine)。
- 调用 `Swoole` 提供的 2 个进程管理模块 [Process](https://wiki.swoole.com/#/process/process) 和 [Process\Pool](https://wiki.swoole.com/#/process/process_pool) 的 [start](https://wiki.swoole.com/#/process/process_pool?id=start) 方法，此种启动方式会在进程启动的时候创建`协程容器`，参考这两个模块构造函数的 `enable_coroutine` 参数。
- 其他直接裸写协程的方式启动程序，需要先创建一个协程容器 (`Coroutine\run()` 函数，可以理解为 java、c 的 `main` 函数)，例如：

不可以嵌套 `Coroutine\run()`。 `Coroutine\run()` 里面的逻辑如果有未处理的事件在 `Coroutine\run()` 之后就进行 [EventLoop](https://wiki.swoole.com/#/learn?id=%e4%bb%80%e4%b9%88%e6%98%afeventloop)，后面的代码将得不到执行，反之，如果没有事件了将继续向下执行，可以再次 `Coroutine\run()`。



## 一键协程化

https://wiki.swoole.com/#/runtime?id=swoole_hook_all

从 v4.5.4 版本起，`SWOOLE_HOOK_ALL` 包括 `SWOOLE_HOOK_CURL`

```php
$sch = new Co\Scheduler;
$sch->set(['max_coroutine' => 100,'hook_flags' => SWOOLE_HOOK_ALL | SWOOLE_HOOK_CURL]);
$sch->add(function(){
    echo '1111'.PHP_EOL;
});
$sch->add(function(){
    sleep(10); //不协程化，sleep会阻塞，但是在Co\run不会
    echo '2222'.PHP_EOL;
});
$sch->parallel(10,function(){
    echo '3333'.PHP_EOL;
});
$sch->start();
```



## 协程调度器

### Co\Scheduler

```php
$sch = new Co\Scheduler;
$sch->set(['max_coroutine' => 100]);
$sch->add(function(){
    echo '1111'.PHP_EOL;
});
$sch->add(function(){
    echo '2222'.PHP_EOL; 
});
$sch->parallel(10,function(){
    echo '3333'.PHP_EOL;
});
$sch->start(); //只有start了，add的方法才会被执行
```

- add方法提交一个协程到调度器
- parallel方法提交n个协程到调度器

### Co\run

```php
Co\run(function () {
    go(function() {
        echo '1111'.PHP_EOL;
    });
    go(function() {
        echo '2222'.PHP_EOL;
    });
});
```

`Co\run()` 函数其实是对 `Swoole\Coroutine\Scheduler` 类 (协程调度器类) 的封装



## 通过`yield`手动让出控制权，`resume`恢复继续执行

```php
<?php
$cid = go(function () {
    echo "co 1 start\n";
    co::yield();//把执行权限让给其他协程
    echo "co 1 end\n";
});

go(function () use ($cid) {
    echo "co 2 start\n";
    co::sleep(1);
    co::resume($cid);//恢复co1协程
    echo "co 2 end\n";
});

// 输出结果：
co 1 start
co 2 start
co 1 end
co 2 end
```



## 协程调度

这里将尽量通俗的讲述什么是协程调度，首先每个协程可以简单的理解为一个线程，大家知道多线程是为了提高程序的并发，同样的多协程也是为了提高并发。

用户的每个请求都会创建一个协程，请求结束后协程结束，如果同时有成千上万的并发请求，某一时刻某个进程内部会存在成千上万的协程，那么 CPU 资源是有限的，到底执行哪个协程的代码？

决定到底让 CPU 执行哪个协程的代码决断过程就是`协程调度`，`Swoole` 的调度策略又是怎么样的呢？

- 首先，在执行某个协程代码的过程中发现这行代码遇到了 `Co::sleep()` 或者产生了网络 `IO`，例如 `MySQL->query()`，这肯定是一个耗时的过程，`Swoole` 就会把这个 Mysql 连接的 Fd 放到 [EventLoop](https://wiki.swoole.com/#/learn?id=%e4%bb%80%e4%b9%88%e6%98%afeventloop) 中。
  - 然后让出这个协程的 CPU 给其他协程使用：**即 yield(挂起)**
  - 等待 MySQL 数据返回后就继续执行这个协程：**即 resume(恢复)**
- 其次，如果协程的代码有 CPU 密集型代码，我们可以开启 [enable_preemptive_scheduler](https://wiki.swoole.com/#/other/config)，Swoole 会强行让这个协程让出 CPU。



## [父子协程优先级](https://wiki.swoole.com/#/coroutine?id=%e7%88%b6%e5%ad%90%e5%8d%8f%e7%a8%8b%e4%bc%98%e5%85%88%e7%ba%a7)

优先执行子协程 (即 `go()` 里面的逻辑)，直到发生协程 `yield`(co::sleep 处)，然后[协程调度](https://wiki.swoole.com/#/coroutine?id=%e5%8d%8f%e7%a8%8b%e8%b0%83%e5%ba%a6)到外层协程

```php
use Swoole\Coroutine;
use function Swoole\Coroutine\run;

echo "main start\n";
run(function () {
    echo "coro " . Coroutine::getcid() . " start\n";
    Coroutine::create(function () {
        echo "coro " . Coroutine::getcid() . " start\n";
        Coroutine::sleep(.2);
        echo "coro " . Coroutine::getcid() . " end\n";
    });
    echo "coro " . Coroutine::getcid() . " do not wait children coroutine\n";
    Coroutine::sleep(.1);
    echo "coro " . Coroutine::getcid() . " end\n";
});
echo "end\n";

/*
main start
coro 1 start
coro 2 start
coro 1 do not wait children coroutine
coro 1 end
coro 2 end
end
*/
```



## 协程全局变量问题

可以使用 [context](https://wiki.swoole.com/#/coroutine/coroutine?id=getcontext) 用协程 id 做隔离，实现全局变量的隔离。

获取当前协程的上下文对象。

```php
Swoole\Coroutine::getContext([int $cid = 0]): Swoole\Coroutine\Context
```



## [多协程共享 TCP 连接](https://wiki.swoole.com/#/coroutine?id=%e5%a4%9a%e5%8d%8f%e7%a8%8b%e5%85%b1%e4%ba%abtcp%e8%bf%9e%e6%8e%a5)

 对于一个 `TCP` 连接来说 Swoole 底层允许同时只能有一个协程进行读操作、一个协程进行写操作。也就是说不能有多个协程对一个 TCP 进行读 / 写操作，底层会抛出绑定错误:

```
use Swoole\Coroutine;
use Swoole\Coroutine\Http\Client;
use function Swoole\Coroutine\run;

run(function() {
    $cli = new Client('www.xinhuanet.com', 80);
    Coroutine::create(function () use ($cli) { //1
        $cli->get('/');
    });
    Coroutine::create(function () use ($cli) { //2
        $cli->get('/');
    });
});
```

如上，1和2同时对cli同一个tcp连接进行读操作，会报错



## [什么是 channel](https://wiki.swoole.com/#/coroutine?id=%e4%bb%80%e4%b9%88%e6%98%afchannel)

`channel` 用于协程间进行通信，类似于消息队列，多个协程通过 `push` 和 `pop` 操作生产消息和消费消息。需要注意的是 `channel` 是没法跨进程的，只能一个 `Swoole` 进程里的协程间通讯。

- channel在`Server`中使用时必须在`onWorkerStart`之后创建
- channel已满时，自动yield当前协程，当其他协程消费数据后resume



