## 参考
- https://zhuanlan.zhihu.com/p/96471009

## 什么是协程？
协程一种用户态线程，协程调度不需要操作系统来完成，而是由在用户态完成。 它比线程更加轻量，创建和切换的开销更加小。和线程不同的是协程没法利用多核 cpu 的，想利用多核 cpu 需要依赖 Swoole 的多进程模型。
协程带来的好处是代码是同步的，当底层是异步的，性能上会更加优秀。

## 创建协程有哪些方法？
- `coroutine::create`或`go`方法创建
- 设置`Http Server`的`enable_coroutine`为true时，` onRequest`回调函数中会自动创建协程

## 什么是协程容器
被`hook`的函数需要在协程容器中使用

## 协程底层原理是怎么样的？
- 调用 Swoole\Http\Server 的 onRequest 事件回调函数时，底层会调用 C 函数 `coro_create` 创建一个协程（#1位置）；
- 调用 mysql->connect 时会发生 IO 操作，底层会调用 C 函数 `coro_save` 保存当前协程的状态，包括 ZendVM 上下文以及协程描述信息，并调用 `coro_yield` 让出程序控制权，当前的请求会挂起（#2位置）；
- 协程让出程序控制权后，会继续进入 HTTP 服务器的事件循环处理其他事件，这时 Swoole 可以继续去处理其他客户端发来的请求；
- 当数据库 IO 事件完成后，MySQL 连接成功或失败，底层调用 C 函数 `coro_resume` 恢复对应的协程，恢复 ZendVM 上下文，继续向下执行 PHP 代码（#3位置）；
- mysql->query 的执行过程与 mysql->connect 一样，也会触发 IO 事件并进行一次协程切换调度；
所有操作完成后，调用 end 方法返回结果，并销毁此协程。
总结：Swoole 底层会在 IO 事件发生时，保存当前状态，将程序控制权交出，以便 CPU 处理其它事件，当 IO 事件完成时恢复并继续执行后续逻辑，从而实现异步 IO 的功能，这正是协程的强大之处，它可以让服务器同时可以处理更多请求，而不会阻塞在这里等待 IO 事件处理完成，从而极大提高系统的并发性。

## 协程引入哪些问题？
- 每个协程被挂起时，需要保存栈内存并维护对应的状态，如果程序并发很大可能会占用大量内存；
- 协程调度会增加额外的一些 CPU 开销

## 协程模式
单进程单线程单协程，如果要利用CPU 多核，需要依赖于 Swoole 引擎的多进程机制。golang是单进程多线程多线程模式。

## 使用协程需要注意哪些问题？
- 协程编程中可直接使用 try/catch 处理异常，但必须在协程内捕获，不得跨协程捕获异常（即不能将 go 函数放到 try 语句块中，这样就是跨协程捕获异常了），协程内使用 exit 终止程序执行退出当前协程的话，会抛出 Swoole\ExitException 异常。
- 所有协程必须在协程容器`Co\run(function(){})`中使用
- go如果挂起，就会接着往下面走程序，当程序不能够往下执行，才会resume
- 协程容器Co\run可当成是同步中的执行的一个函数，只有执行完该函数后才可继续执行；
- 协程容器中不能再创建协程容器

## 一键协程化
https://wiki.swoole.com/#/runtime?id=swoole_hook_all
```php
Co::set(['hook_flags' => SWOOLE_HOOK_ALL | SWOOLE_HOOK_CURL]);
Co\run(function () {
    go(function() {
        echo '1111'.PHP_EOL;
        sleep(3); //如果不启用一键协程化，这里会被阻塞
    });
    go(function() {
        echo '2222'.PHP_EOL;
    });
});
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
说明：当a协程调用co::yield时让出执行权，即暂定执行，在b协程中调用co::resume恢复a协程执行，需要注意的是co::yield和co::resume必须成对使用，否则会有协程泄露

## 通道
swoole的通道用于多协程之间的通信
### 2. 与go的比较
- swoole创建的通道chan，只能在coroutine中使用（ must be called in the coroutine）


##  问题记录
- co执行顺序并不是想象中那样的协同执行，而是顺序执行，不应该是那个那个没io就自动切换到另一个co吗？为什么我sleep了，还是要等sleep完之后才能执行下一个co
答：因为sleep是阻塞io，swoole不支持将sleep自动异步化，需要手动设置一键协程化


### 4. 注意事项
- 通道在`Server`中使用时必须在`onWorkerStart`之后创建
- 通道已满时，自动yield当前协程，当其他协程消费数据后resume