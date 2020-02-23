## 参考
- http://blog.codeg.cn/2015/10/22/nsq/

## 存在问题
- NSQ不能保证数据的消费顺序与生产顺序完全一致。

## 关键词
- 分布式
- 高吞吐量
- golang
- nsqd
- nsqlookupd
- nsqadmin

## 概念
- nsqd 接收,排队,转发请求给客户端
- nsqlookupd 管理拓扑信息并提供最终一致性的发现服务
- nsqadmin 集群监控统计

## nsq, topic, channel之间的关系
- nsq	
	- topic_1
		- channel_1 (消费者订阅的时候生成)
		- channel_2
	- topic_2
		- channel_1
		- channel_2
![http://static.oschina.net/uploads/img/201401/03081429_evAT.gif](http://static.oschina.net/uploads/img/201401/03081429_evAT.gif)
		
## 源码启动
```bash
# 启动nsqlookupd
cd $GOPATH/src/github.com/nsqio/nsq/apps/nsqlookupd
go run main.go

# 启动nsqd
cd $GOPATH/src/github.com/nsqio/nsq/apps/nsqd
go run main.go options.go --lookupd-tcp-address=127.0.0.1:4160 -tcp-address=0.0.0.0:4152 -http-address=0.0.0.0:4153

# 启动nsqadmin(web地址:http://127.0.0.1:4171/)
cd $GOPATH/src/github.com/nsqio/nsq/apps/nsqadmin
go run main.go --lookupd-http-address=127.0.0.1:4161

# 启动nsq_to_file
cd $GOPATH/src/github.com/nsqio/nsq/apps/nsq_to_file
go run *.go --topic=test --output-dir=/tmp --lookupd-http-address=127.0.0.1:4161

# 发布数据
curl -d 'hello world 2' 'http://127.0.0.1:4151/pub?topic=test'
```

## 默认IP
```
TCPAddress:       "0.0.0.0:4150",
HTTPAddress:      "0.0.0.0:4151",
HTTPSAddress:     "0.0.0.0:4152",
```

## nsqd源码
有一个叫svc,这个东西是用来操作服务,例如启动,初始化,停止
### server启动流程
- 合并配置选项(默认,命令行,配置文件)
- 加载元数据 (nsqd.dat)
- 持久化元数据
- nsqd.main()
	- 启动tcpServer
	- 启动httpServer

### client流程
- 建立tcp连接,发送4个字节`[space][space][V][2]`
- 发送`identify`
	- 从服务端获得`maxRdyCount`,`TLSv1`,`AuthRequired`
	- 会根据`TLSv1`升级client
	- 设置读写缓冲区
- 发送`sub`订阅`topic`和`channel`
- 设置`rdy`状态,为0时表示client不会收到任何消息,100时表示100条消息推送到client

V2 版本的协议让客户端拥有心跳功能。每隔 30 秒（默认设置），nsqd 将会发送一个 _heartbeat_ 响应，并期待返回。如果客户端空闲，发送 NOP命令。如果 2 个 _heartbeat_ 响应没有被应答， nsqd 将会超时，并且强制关闭客户端连接。IDENTIFY 命令可以用来改变/禁用这个行为。

### client源码
- 初始化consumer,`NewConsumer()` 
	- 开启一个`goroutine`执行`rdyLoop()`,这是一个定时器,会重新分配rdy
		- 执行`redistributeRDY()`,主要是再分配什么来着

![https://img-blog.csdn.net/20160826111400116?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center](https://img-blog.csdn.net/20160826111400116?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

