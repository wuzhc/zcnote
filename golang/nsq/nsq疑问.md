- nsqd是如何做存储,为什么性能这么快
- 发布一个消息到nsqd后,是写入存储后返回给client吗,client是接收响应后再进行下一个消息推送吗?
  - publish命令 
  - 包装成ProducerTransaction结构,写入w.transactionChan通道,等待doChan返回 
  - 有个select轮询会在等待着 
  - select响应w.transactionChan通道,把ProducerTransaction结构写入w.transactions切片,然后发送命令发送给server 
  - select响应w.responseChan,从w.transactions切片获得ProducerTransaction结构,完成ProducerTransaction.doChan

- tlsConfig的值怎么用的,要通过configHandlers来操作吗

- 消费者是不是要指定消费某个channel 
> 是的

- 多个channel都是同一份数据,会不会浪费
> 这是为了分发,到底会不会浪费,要看下是如何存储数据的

- 消费者通过`rdy`告诉`nsq`自己可以处理多少条消息,那么nsq是一条条返回还是批量一致性返回给消费者
> 待定

- 如果多个消费者同时订阅同一个topic,这种时候nsq是如何分配给多个消费者,每个消费者的rdy应该不一样的吧
> 待定

- nsqd用到了很多的atomic.Value.Store来保存值,这有什么用呢???