## swoole协程

### 1. 基础知识

#### 1.1 多协程之间调度 

```php
<?php
$cid = go(function () {
    echo "co 1 start\n";
    co::yield();
    echo "co 1 end\n";
});

go(function () use ($cid) {
    echo "co 2 start\n";
    co::sleep(1);
    co::resume($cid);
    echo "co 2 end\n";
});

// 输出结果：
co 1 start
co 2 start
co 1 end
co 2 end
```

说明：当a协程调用co::yield时让出执行权，即暂定执行，在b协程中调用co::resume恢复a协程执行，需要注意的是co::yield和co::resume必须成对使用，否则会有协程泄露

#### 1.2 通道

swoole的通道用于多协程之间的通信



### 2. 与go的比较

- swoole创建的通道chan，只能在coroutine中使用（ must be called in the coroutine）



#### 3. 问题记录

- co执行顺序并不是想象中那样的协同执行，而是顺序执行，不应该是那个那个没io就自动切换到另一个co吗？为什么我sleep了，还是要等sleep完之后才能执行下一个co



### 4. 注意事项

- 通道在`Server`中使用时必须在`onWorkerStart`之后创建
- 通道已满时，自动yield当前协程，当其他协程消费数据后resume