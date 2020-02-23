`gopusher`可用于作为`websocket`连接的接入层，负责连接管理和消息推送两大部分，你可以把它用于即时聊天或者消息推送系统

## 说明
- 使用golang，高性能，单机可以支持百万连接
- 消息推送使用`grpc+protobuf`通信协议，支持`http`和`rpc`两种方式推送，可用于各种编程语言
- 可设置多个消息处理器，多个处理器并发执行可以保证消息能够及时推送到客户端
- 使用消息中间件`nsq`,可支持大量消息的堆积，防止大量推送消息压垮系统
- 消息推送`tps`大概为10000(op/s)，环境8g内存，4核cpu，消息内容长度11个字节（实际会更好，因为压测和被压测是在同一台机子进行的）
- 以`nginx`或`lvs`做负载均衡，以`etcd`+`confd`做高可用的注册发现服务

## 架构
`gopusher`可以分为几大模块
```
queue    队列模块，用于消息存储
service  服务模块，用于处理API
socket   连接管理模块
config   配置模块
web      web模块
```
### 单机架构
![](https://gitee.com/wuzhc123/zcnote/raw/master/images/project/gopusher_2.png)
### 分布式架构
![](https://gitee.com/wuzhc123/zcnote/raw/master/images/project/gopusher.png)

## 如何使用
### 客户端建立连接
```javascript
// 打开一个 web socket
var ws = new WebSocket("ws://127.0.0.1:8080/ws");
ws.onopen = function()
{
	// Web Socket 已连接上，绑定链接标识
    ws.send(JSON.stringify({"event":"join","data":{"app_id":"alibaba","card_id":"mayun"}}));
};

ws.onmessage = function (evt) 
{ 
    var received_msg = evt.data;
    alert("数据已接收...");
};

ws.onclose = function()
{ 
    // 关闭 websocket
    alert("连接已关闭..."); 
};
```
- 当建立链接，需要为连接绑定一个`card_id`（身份证ID），用于标识该连接是谁，`card_id`可以是用户或是群组
- 在`gopusher`中，一个`card_id`会创建一个分组，对于相同的`card_id`可以归类到同一个分组中，例如当`card_id`是用户时，该用户可能在游览器打开多个标签页，此时该用户有多个websocket连接，这些连接会被归到同一个分组中；再例如，该用户在手机端建立连接，同样会被归到同个分组，如果需要区分不同的终端或不同的应用，可以设置`app_id`
### card_id，group，connection的关系如下：
![](https://gitee.com/wuzhc123/zcnote/raw/master/images/project/gopusher_card_id.png)

### 推送消息
gopuser使用`grpc+protobuf`作为消息推送的通信协议，使用`gateway`作为网关代理，因此用户可以使用`http`或`rpc`方式进行推送
- http方式
默认端口为8081，可以在配置文件`config.ini`的`gatewayAddr`选项做修改
```bash
# 将消息推送给wuzhc_1和wuzhc_2两个card_id（可以是用户或分组）
curl -X POST -k http://127.0.0.1:8081/push -d '{"from":"xxx","to":["wuzhc_1","wuzhc_2"], "content":"hellwo world"}'
```

- rpc方式
这里只提供go版本的，可参考测试用例的写法：service/service_test.go
```go
package main

import (
	"context"
	pb "github.com/wuzhc/gopusher/proto"
	"google.golang.org/grpc"
	"log"
)

func main() {
	conn, err := grpc.Dial("127.0.0.1:9002", grpc.WithInsecure())
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close()

	// Contact the server and print out its response.
	c := pb.NewRpcClient(conn)
	r, err := c.Push(context.Background(), &pb.PushRequest{
		From:    "xxx",
		To:      []string{"wuzhc_1", "wuzhc_2"},
		Content: "hello world",
	})
	if err != nil {
		log.Fatalln(err)
	} else {
		log.Printf("recv message:%s\n", r.Message)
	}
}
```

## 分布式部署
参考上图的分布式架构
- 组件
```
https://github.com/nsqio/nsq
https://github.com/etcd-io/etcd
https://github.com/kelseyhightower/confd
```
- 启动
```bash
# 启动nsq
nsqlookupd 
nsq options.go --lookupd-tcp-address=127.0.0.1:4160 -tcp-address=0.0.0.0:4152 -http-address=0.0.0.0:4153

# 启动nginx
nginx -c /usr/local/nginx/conf/nginx.conf

# 启动etcd
etcd

# 启动confd
confd -watch -backend etcdv3 -node http://127.0.0.1:2379
```
- 各个组件的配置
[nginx配置](https://github.com/wuzhc/zcnote/blob/master/%E9%A1%B9%E7%9B%AE/%E6%8E%A8%E9%80%81%E7%B3%BB%E7%BB%9F2.0/nginx%E9%85%8D%E7%BD%AE.md)
[confd配置](https://github.com/wuzhc/zcnote/blob/master/%E9%A1%B9%E7%9B%AE/%E6%8E%A8%E9%80%81%E7%B3%BB%E7%BB%9F2.0/confd%E9%85%8D%E7%BD%AE.md)










