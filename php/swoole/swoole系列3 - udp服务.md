```php
$server = new Swoole\Server('127.0.0.1', 9502, SWOOLE_PROCESS, SWOOLE_SOCK_UDP);

//监听数据接收事件
$server->on('Packet', function ($server, $data, $clientInfo) {
    var_dump($clientInfo);
    $server->sendto($clientInfo['address'], $clientInfo['port'], "Server：{$data}");
});

//启动服务器
$server->start();
```

UDP 服务器与 TCP 服务器不同，UDP 没有连接的概念。启动 Server 后，客户端无需 Connect，直接可以向 Server 监听的 9502 端口发送数据包。对应的事件为 onPacket。

UDP 服务器可以使用 `netcat -u` 来连接测试

```bash
netcat -u 127.0.0.1 9502
hello
Server: hello
```