## 常用命令
- `basic.consume`持续订阅,自动接收下一条消息
- `basic.get`获取单条消息
- `basic.ack`确认收到消息,或者消费者在订阅到队列的时候就将`auto ack`设置为true
- `basic.reject`丢弃消息,如果将`reject`命令的`requeue`参数设置为true的话,`rabbitmq`会将消息投递给下个消费者,否则会立即从队列删除消息并且存放到死信队列
- `queue.declare`创建队列,如果不指定名称则随机分配一个名称,作为匿名队列
	- `exclusive`限制只有由一个消费者够消费
	- `auto-delete`当最后一个消费者取消订阅时候,队列会自动移除
	- 当重复声明一个已存在的队列,若声明参数完全匹配现存队列,rabbit什么都不会做并返回成功
	- 设置`queue.declare`的`passive`为`true`时,如果队列已存在,`queue.declare`返回成功,如果队列不存在,`queue.declare`命令不会创建队列而会返回一个错误  

## 应该由生成者还是消费者创建队列呢?
假设由消费者创建队列,若生成者先投递消息,此时还没有消费者,这个时候消息会怎么样?当有消费者了并且创建队列了会怎么样?
答: 消息会提示发送成功,但是事实上它已经丢失了,即时消费者创建队列了也不能消费之前的发布的消息,最好的做法是消费者和生成者都要尝试创建队列,并且绑定队列和交换器


## 生产消息
- AMQP_NOPARAM 无
- AMQP_DURABLE 持久化exchange
- AMQP_PASSIVE 声明一个已存在的交换器的，如果不存在将抛出异常，这个一般用在consume端。因为一般produce端创建,在consume端建议设置成AMQP_PASSIVE,防止consume创建exchange
- AMQP_AUTODELETE 该交换器将在没有消息队列绑定时自动删除

## 为什么要用信道channel
为了减少tcp连接开销,多个通道可以共享tcp连接???
