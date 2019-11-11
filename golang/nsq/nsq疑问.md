- 去中心化,处理单点故障
- 消息的可靠性,持久化
- 消息负载处理,合理不超过客户端消费能力情况下把消息分发到不同的客户端

## server端
client有好几个状态
- sampleRate
- SetOutputBuffer
- IdentifyEventChan

- subEventChan

## 发送`rdy`,服务端会怎么处理?
- 设置客户端的`ReadyCount`为`rdy`
- 尝试更新准备状态`tryUpdateReadyState` -> `ReadyStateChan<-1`

## 服务端是有消息就主动推送,还是接收到`rdy`才被动推送?
服务端是通过启用`messagePump`协程来主动推送的,推送的频率根据客户端的`rdy`来限制,`rdy`会和服务端的`inFlight`做比较,当`inFlight`正在处理的消息超过`rdy`,不推送

## 服务端如何保证推送速度不会压垮消费速度慢的客户端
客户端发送`rdy`的频率怎么样?
- 比如服务端没有消息了,这个时候客户端是定期发送`rdy`吗
- 是不是发送的`rdy = rdyCount - inFlight`?
- 接收到一个消息`inFilght+1`,处理完一个消息`inFilght-1`?
- 客户端是拥有多个连接的,`totalRdyCount`是要分配给各个连接吗?
- 客户端`inBackoff`又是表示什么意思?
- 消费者的`maxInFlight`和`totalRdyCount`有什么关系?
## 解答
- 当一个连接发送`rdy`给服务端,会更新消费者的`totalRdyCount`
- 如果消息消费失败,消费者会暂停从服务器消费消息,给其他消费者更多机会





