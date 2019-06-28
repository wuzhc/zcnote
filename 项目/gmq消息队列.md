## gmq流程如下:

![一个不规范的流程图](../images/project/gmq流程图.png)


## 使用
目前只实现python,go,php语言的客户端的demo
### php
```php
// consumer.php 消费者
$client = new JsonRPC("127.0.0.1", 9503);
while (true) {
    $r = $client->Call("Service.Pop", array_slice($topic,rand(0,7)));
    if (!$r) {
        // 是否断开连接了
        print_r($client->getErrors());exit;
    }
    print_r($r);
    // sleep(2);
    // print_r($r);
    echo 'POP ' . $r['result']['id'] . PHP_EOL;
    if (!empty($r['error'])) {
        if ($r['error'] == 'empty') {
            echo '[' . date('Y-m-d H:i:s') . '] no jobs and will sleep 3 seconds' . PHP_EOL;
            echo '已处理' . $n . PHP_EOL;
            // $client->close();
            sleep(3);
            continue;
        }
    }
    $result = $r['result'];
    if ($result['TTR'] > 0) {
        echo 'ACK' . $result['id'] . PHP_EOL;
        $r = $client->Call('Service.Ack', $result['id']);
        // print_r($r);
    }
    $n++;
    echo '已处理' . $n . PHP_EOL;
}
$client->close();
```

```php
// consumer.php 生产者
$client = new JsonRPC("127.0.0.1", 9503);
for ($i = 0; $i < 100000; $i++) {
    $data = [
        'id'    => 'xxxx_id' . microtime(true) . rand(1,999999999),
        'topic' => $topic[rand(0, 7)],
        'body'  => 'this is a rpc test',
        'delay' => (string)rand(0, 1000),
        'TTR'   => '3'
    ];
    $r = $client->Call("Service.Push", $data);
    if ($client->getErrors()) {
        echo $client->getErrors() . PHP_EOL;
        sleep(3);
    } else {
        print_r($r);
        echo $i . ' ' . $r['result'] . '---' . PHP_EOL;
    }
}
$client->close();
```

## 遇到问题
以下是开发遇到的问题,以及一些粗糙的解决方案

### 平滑退出
当程序修复好bug,需要替换线上服务,此时就需要关闭`gmq`,如果粗暴关闭`gmq`可能会导致某些业务执行到一般就中止,进而出现一些奇怪的未知问题,为了避免这种情况,`gmq`在收到终止信号时,并不会马上退出程序,也是当每个`goroutine`都处理完业务,再退出整个服务
**注意:**不要使用`kill -9 pid`来强制杀死进程,系统无法捕获SIGKILL信号,导致gmq可能执行到一半就被强制中止,应该使用`kill -15 pid`,`kill -1 pid`或`kill -2 pid`,各个数字对应信号如下:
- 9 对应SIGKILL
- 15 对应SIGTERM
- 1 对应SIGHUP
- 2 对应SIGINT
- [https://www.jianshu.com/p/5729fc095b2a](https://www.jianshu.com/p/5729fc095b2a)  
![](https://upload-images.jianshu.io/upload_images/10118224-625e74bf4a2d4204.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/516/format/webp)


### 热更新
程序需要升级,但是又不能直接关闭服务,需要接收客户端的请求;而go不像php一样动态解析代码,go是编译成一个可执行文件,如果需要升级服务需要替换整个执行文件,一般操作如下:
- 多部署几个服务,当服务需要升级时,一个个替换,把替换的服务请求打到其他服务,替换后在接收请求,类似的方式替换掉所有的服务
- fork子进程,当子进程重启服务,父进程退出,子进程缺少父进程会成为孤儿进程,托管到init进程

### 确认机制
任务被消费者获取之后,只是删除了队列job信息,`job pool`不会去删除job元数据,只有当消费者手动发起`ack`确认删除;另外,如果当`TTR=0`时,即job不会有超时时间,可以无限的执行,此时`gmq`会在消费获取job之后就直接删掉`job pool`任务

### 智能定时器
每一个`bucket`会维护一个定时器,定时器并非周期性的时钟,通俗来讲,即不是每隔多久执行一次;首先先获取`bucket`下一个要执行`job`的时间,然后用这个时间作为定时器的周期,这样当没有job时不会有其他开销;当然,事物都有两面性,这样的设计带来的弊端就是当生成者产生一个新数据时会可能需要重置定时器的时间,频繁产生意味着频繁重置定时器

### 原子性问题
成功添加到bucket时,会去设置job.status,但是,因为添加bucket和设置job.status是两个方法,两个方法分别去获取redis连接池句柄,此时会出现添加bucket成功后,但是设置job.status获取连接句柄失败(因为访问量大,连接池耗尽了),设置job.status就会阻塞在那里;如果这个时候定时器扫描到bucket,就会得到status是错误的
redis对请求是排队处理,假设我们添加一个job到bucket,经历的过程大概是add bucket -> set job status; 此时如果在`add bucket`和`set job status`两个命令之间插入其他命令,就会使得这个事物原子性问题
gmq会很多这样的场景,为此我用redis的`lua脚本`替换了所有涉及事务的代码,考虑到用`lua脚本`而不是`MULTI/EXEC`是为了减少gmq和`redis server`通信次数,并且`lua脚本`有利于之后的redis分片

### redis连接池
刚好第三方库`redis`自带了连接池,我也可以不需要自行实现连接池,连接池是很有必要的,它带来的好处是限制redis连接数,通过复用redis连接来减少开销,另外可以防止tcp被消耗完,这在生产者大量生成数据时会很有用

### 设置job执行超时时间TTR(TIME TO RUN)
当job被消费者读取后,如果`job.TTR>0`,即job设置了执行超时时间,那么job会在读取后添加到bucket,并且设置`job.delay = job.TTR`,在TTR时间内没有得到消费者ack确认删除job,job将在TTR时间之后添加到`ready queue`,然后再次被消费(如果消费者在TTR时间之后才请求ack,会得到失败的响应)

## 使用中可能出现的问题
### 客户端出现大量的TIME_WAIT状态,并且新的连接被拒绝
```bash
netstat -anp | grep 9503 | wc -l
tcp        0      0 10.8.8.188:41482        10.8.8.185:9503         TIME_WAIT   -                   
```
这个在大并发的场景下是正常现象,socket连接为了保证每个连接正常关闭,会处于`TIME_WAIT`状态,并且等待2ML时间后消失; 如果要避免大量`TIME_WAIT`的连接导致tcp被耗尽;一般方法如下:
- 使用长连接,而不是每个请求一个连接
- 配置文件,网上很多教程,就是让系统尽快的回收`TIME_WAIT`状态的连接
- 使用连接池,当连接池耗尽时,阻塞等待,直到连接回收


- bucket有job,但是pool没有job
- bucket.JobNum计数有问题
- bucket存在status=ready的job (原本是在bucket中,job.status=delay,强制重启后job.status=ready,但未被加入到readQueue
- jobPool出现只有{status:1}的job (10万个快速请求造成的) 可能的原因: addBucket -> 被中断执行了 delete job -> bucket又设置了状态
- [E] [default] [2019-06-23 22:38:24] strconv.Atoi: parsing "": invalid syntax (可能和上一个bug有关)
