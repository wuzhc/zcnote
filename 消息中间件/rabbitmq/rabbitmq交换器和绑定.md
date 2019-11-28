## rabbitmq
基于`AMQP`(advanced message queue protocol)高级队列消息协议,由三部分组成,包括交换器,队列,绑定

## 交换器和绑定
- 首先会声明交换器和队列,并通过键绑定两者`$channel->queue_bind('队列', '交换器', '路由键')`
- 开始发布消息,消息是先发布到交换器上,并且发布的时候会指定路由键
- 通过匹配路由键和绑定键,从而将消息路由到指定的队列

### fanout
fanout类型的Exchange路由规则非常简单，它会把所有发送到该Exchange的消息路由到所有与它绑定的Queue中。
![https://img2018.cnblogs.com/blog/774371/201908/774371-20190819104152177-2053988251.png](https://img2018.cnblogs.com/blog/774371/201908/774371-20190819104152177-2053988251.png)

### direct
direct类型的Exchange路由规则也很简单，它会把消息路由到那些binding key与routing key完全匹配的Queue中。
![https://img2018.cnblogs.com/blog/774371/201908/774371-20190819104210818-1771762193.png](https://img2018.cnblogs.com/blog/774371/201908/774371-20190819104210818-1771762193.png)

### topic
和direct相识,但是`routing key`和`binding key`是模糊匹配
- routing key为一个句点号“. ”分隔的字符串（我们将被句点号“. ”分隔开的每一段独立的字符串称为一个单词），如“stock.usd.nyse”、“nyse.vmw”、“quick.orange.rabbit”
- binding key与routing key一样也是句点号“. ”分隔的字符串
- binding key中可以存在两种特殊字符“*”与“#”，用于做模糊匹配，其中“*”用于匹配一个单词，“#”用于匹配多个单词（可以是零个）
![https://img2018.cnblogs.com/blog/774371/201908/774371-20190819104233644-253637000.png](https://img2018.cnblogs.com/blog/774371/201908/774371-20190819104233644-253637000.png)

### headers
headers类型的Exchange不依赖于routing key与binding key的匹配规则来路由消息，而是根据发送的消息内容中的headers属性进行匹配





