## [TCP 服务器](https://wiki.swoole.com/#/start/start_tcp_server?id=tcp-%e6%9c%8d%e5%8a%a1%e5%99%a8)

```php
//创建Server对象，监听 127.0.0.1:9501 端口
$server = new Swoole\Server('127.0.0.1', 9501);

//监听连接进入事件
$server->on('Connect', function ($server, $fd) {
    echo "Client: Connect.\n";
});

//监听数据接收事件
$server->on('Receive', function ($server, $fd, $reactor_id, $data) {
    $server->send($fd, "Server: {$data}");
});

//监听连接关闭事件
$server->on('Close', function ($server, $fd) {
    echo "Client: Close.\n";
});

//启动服务器
$server->start(); 
```

`Server` 是异步服务器，所以是通过监听事件的方式来编写程序的。当对应的事件发生时底层会主动回调指定的函数。如当有新的 `TCP` 连接进入时会执行 [onConnect](https://wiki.swoole.com/#/server/events?id=onconnect) 事件回调，当某个连接向服务器发送数据时会回调 [onReceive](https://wiki.swoole.com/#/server/events?id=onreceive) 函数



## [TCP 粘包问题](https://wiki.swoole.com/#/learn?id=tcp%e7%b2%98%e5%8c%85%e9%97%ae%e9%a2%98)

`TCP` 协议是流式的，数据包没有边界

因为 `TCP` 通信是流式的，在接收 `1` 个大数据包时，可能会被拆分成多个数据包发送。多次 `Send` 底层也可能会合并成一次进行发送。这里就需要 2 个操作来解决：

- 分包：`Server` 收到了多个数据包，需要拆分数据包
- 合包：`Server` 收到的数据只是包的一部分，需要缓存数据，合并成完整的包

 所以 TCP 网络通信时需要设定通信协议。常见的 TCP 通用网络通信协议有 `HTTP`、`HTTPS`、`FTP`、`SMTP`、`POP3`、`IMAP`、`SSH`、`Redis`、`Memcache`、`MySQL` 。

### 解决粘包方案

- **EOF 结束符协议**

  约定结束符，必须保证数据包中间没有出现结束符

- **固定包头 + 包体协议**

  一个数据包总是由包头 + 包体 `2` 部分组成，包头由一个字段指定了包体或整个包的长度，长度一般是使用 `2` 字节 /`4` 字节整数来表示。服务器收到包头后，可以根据长度值来精确控制需要再接收多少数据就是完整的数据包。

### swoole通过配置解决粘包问题

```php
//EOF 结束符协议
$server->set(array(
    'open_eof_check' => true,
    'package_eof' => "\r\n",
));
$client->set(array(
    'open_eof_check' => true,
    'package_eof' => "\r\n",
));
```

上面配置只能解决`分包`问题，没法解决`合包`问题，也就是说可能 `onReceive` 一下收到客户端发来的好几个请求，需要自行分包

```php
//固定包头+包体协议
$server->set(array(
    'open_length_check' => true,
    'package_max_length' => 81920,
    'package_length_type' => 'n', //see php pack(),
    'package_length_offset' => 0,
    'package_body_offset' => 2,
));

```

`Server` 在 [onReceive](https://wiki.swoole.com/#/server/events?id=onreceive) 回调函数中处理数据包，当设置了协议处理后，只有收到一个完整数据包时才会触发 [onReceive](https://wiki.swoole.com/#/server/events?id=onreceive) 事件。客户端在设置了协议处理后，调用 [$client->recv()](https://wiki.swoole.com/#/client?id=recv) 不再需要传入长度，`recv` 函数在收到完整数据包或发生错误后返回。

各个参数配置解析如下：

- **package_length_type**

  包头中某个字段作为包长度的值，底层支持了 10 种长度类型。请参考 [package_length_type](https://wiki.swoole.com/#/server/setting?id=package_length_type)

- **-package_length_offset**

  `length` 长度值在包头的第几个字节。

- **package_body_offset**

  从第几个字节开始计算长度，一般有 2 种情况：

  - `length` 的值包含了整个包（包头 + 包体），`package_body_offset` 为 `0`

  - 包头长度为 `N` 字节，`length` 的值不包含包头，仅包含包体，`package_body_offset` 设置为 `N`

例子：  

```c
struct
{
    uint32_t type;
    uint32_t uid;
    uint32_t length;
    uint32_t serid;
    char body[0];
}
```

以上通信协议的设计中，包头长度为 `4` 个整型，`16` 字节，`length` 长度值在第 `3` 个整型处。因此 `package_length_offset` 设置为 `8`，`0-3` 字节为 `type`，`4-7` 字节为 `uid`，`8-11` 字节为 `length`，`12-15` 字节为 `serid`。

```php
$server->set(array(
  'open_length_check'     => true,
  'package_max_length'    => 81920,
  'package_length_type'   => 'N',
  'package_length_offset' => 8,
  'package_body_offset'   => 16,
));
```



## [执行异步任务 (Task)](https://wiki.swoole.com/#/start/start_task?id=%e6%89%a7%e8%a1%8c%e5%bc%82%e6%ad%a5%e4%bb%bb%e5%8a%a1task)

异步任务用于处理耗时请求，只需要增加 [onTask](https://wiki.swoole.com/#/server/events?id=ontask) 和 [onFinish](https://wiki.swoole.com/#/server/events?id=onfinish) 2 个事件回调函数即可。另外需要设置 task 进程数量，可以根据任务的耗时和任务量配置适量的 task 进程。

```php
$serv = new Swoole\Server('127.0.0.1', 9501);

//设置异步任务的工作进程数量
$serv->set([
    'task_worker_num' => 4
]);

//此回调函数在worker进程中执行
$serv->on('Receive', function($serv, $fd, $reactor_id, $data) {
    //投递异步任务
    $task_id = $serv->task($data);
    echo "Dispatch AsyncTask: id={$task_id}\n";
});

//处理异步任务(此回调函数在task进程中执行)
$serv->on('Task', function ($serv, $task_id, $reactor_id, $data) {
    echo "New AsyncTask[id={$task_id}]".PHP_EOL;
    //返回任务执行的结果
    $serv->finish("{$data} -> OK");
});

//处理异步任务的结果(此回调函数在worker进程中执行)
$serv->on('Finish', function ($serv, $task_id, $data) {
    echo "AsyncTask[{$task_id}] Finish: {$data}".PHP_EOL;
});

$serv->start();
```

调用 `$serv->task()` 后，程序立即返回，继续向下执行代码。onTask 回调函数 Task 进程池内被异步执行。执行完成后调用 `$serv->finish()` 返回结果。

finish 操作是可选的，也可以不返回任何结果



## 出现大量time_wait问题

```bash
netstat -an | grep TIME_WAIT | wc -l 
```

在 /etc/sysctl.conf中加入`net.ipv4.tcp_tw_recycle = 1`（表示开启TCP连接中TIME-WAIT sockets的快速回收，默认为0，表示关闭）

主动关闭socket的一方最终为time_wait，被动关闭的则为close_wait； 

### 为什么time_wait需要2*MSL等待时间？

MSL表示一个IP数据包能在互联网上生存的最长时间，超过这个时间将在网络中消失，假设客户端要和服务端断开连接，服务端最后会发一个fin给客户端，客户端会响应ack，因为最后的ack有可能丢失，导致服务度重发fin，fin在网络中的时间是msl，所以客户端会等待2个msl时间才会退出，否则重新发的fin有可能把新连接结束掉



## 三次握手的详细描述

1. 第一次握手：建立连接。客户端发送连接请求报文段，将`SYN`位置为1，`Sequence Number`为x；然后，客户端进入`SYN_SEND`状态，等待服务器的确认；
2. 第二次握手：服务器收到`SYN`报文段。服务器收到客户端的`SYN`报文段，需要对这个`SYN`报文段进行确认，设置`Acknowledgment Number`为x+1(`Sequence Number`+1)；同时，自己自己还要发送`SYN`请求信息，将`SYN`位置为1，`Sequence Number`为y；服务器端将上述所有信息放到一个报文段（即`SYN+ACK`报文段）中，一并发送给客户端，此时服务器进入`SYN_RECV`状态；
3. 第三次握手：客户端收到服务器的`SYN+ACK`报文段。然后将`Acknowledgment Number`设置为y+1，向服务器发送`ACK`报文段，这个报文段发送完毕以后，客户端和服务器端都进入`ESTABLISHED`状态，完成TCP三次握手。



## 为什么要三次握手

client发出的第一个连接请求报文段并没有丢失，而是在某个网络结点长时间的滞留了，以致延误到连接释放以后的某个时间才到达server。本来这是一个早已失效的报文段。但server收到此失效的连接请求报文段后，就误认为是client再次发出的一个新的连接请求。于是就向client发出确认报文段，同意建立连接。假设不采用“三次握手”，那么只要server发出确认，新的连接就建立了。由于现在client并没有发出建立连接的请求，因此不会理睬server的确认，也不会向server发送数据。但server却以为新的运输连接已经建立，并一直等待client发来数据。这样，server的很多资源就白白浪费掉了。采用“三次握手”的办法可以防止上述现象发生。例如刚才那种情况，client不会向server的确认发出确认。server由于收不到确认，就知道client并没有要求建立连接。”



## 四次挥手的详细描述

1. 第一次分手：主机1（可以使客户端，也可以是服务器端），设置`Sequence Number`和`Acknowledgment Number`，向主机2发送一个`FIN`报文段；此时，主机1进入`FIN_WAIT_1`状态；这表示主机1没有数据要发送给主机2了；
2. 第二次分手：主机2收到了主机1发送的`FIN`报文段，向主机1回一个`ACK`报文段，`Acknowledgment Number`为`Sequence Number`加1；主机1进入`FIN_WAIT_2`状态；主机2告诉主机1，我也没有数据要发送了，可以进行关闭连接了；
3. 第三次分手：主机2向主机1发送`FIN`报文段，请求关闭连接，同时主机2进入`CLOSE_WAIT`状态；
4. 第四次分手：主机1收到主机2发送的`FIN`报文段，向主机2发送`ACK`报文段，然后主机1进入`TIME_WAIT`状态；主机2收到主机1的`ACK`报文段以后，就关闭连接；此时，主机1等待2MSL后依然没有收到回复，则证明Server端已正常关闭，那好，主机1也可以关闭连接了。



## 为什么要四次分手

第二次握手的时候确认和请求回复可以合并为一步,但是挥手不可以
挥手的时候,接收到客户端的FIN报文后,先进行确认,但是不能请求回复,因为这个时候服务端可能还有数据没有发送完成,只有当服务端发送完数据之后才会发送FIN给客户端,请求客户端回复,所以服务端的确认和请求回复是分开的



参考：网络编程/tcp传输协议.md