## 参考
- https://www.toutiao.com/i6826959307888656899/
- https://www.cnblogs.com/Zhangcsc/p/11739754.html

## 核心概念
### 交换机exchange
接收消息，并根据路由键转发消息到所绑定的队列
### 交换机的4种类型
- topic 对路由键进行模式匹配，将消息转发到匹配上的队列上，其中`*` 表示匹配任意一个单词，`#` 表示匹配任意一个或多个单词，使用`.`分割单词，例如路由键`quick.orange.rabbit`，可以匹配上绑定键`quick.#`,`*.orange.rabbit`
- direct 要求路由键必须与绑定key完全匹配，这样才会被转发对应的队列
- fanout 不处理路由键。你只需要简单的将队列绑定到交换机上，一个发送到交换机的消息都会被转发到与该交换机绑定的所有队列上
- headers 不处理路由键，而是根据消息内容中的headers属性进行匹配

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

## 什么是消息幂等性？
无论一条消息被消费多少次，消费的结果都是一样的。

## 什么是confirm消息确认机制？
生成者生成消息，Broker收到消息就会给生产者一个应答，生产者接受应答来确认broker是否收到消息。
### 如何实现confirm确认消息？
- 在Channel上开启确认模式：`channel.confirmSelect()`
- 在channel上添加监听：`addConfirmListener`，监听成功和失败的结果，具体结果对消息进行重新发送或者记录日志。

## 如何生成的消息匹配不到队列会怎么样？
如果`Mandatory`设置为true，如果找不到队列，则broker会调用`basic.return`方法将消息返还给生产者;当`mandatory`设置为false时，出现上述情况broker会直接将消息丢弃;通俗的讲，mandatory标志告诉broker代理服务器至少将消息route到一个队列中，否则就将消息return给发送者;
**Mandatory设置为true只有在confirm模式有效**
### 如何获得被return回来的消息？
通过为channel信道设置`ReturnListener`监听器来实现
```php
<?php
require_once __DIR__ . '/vendor/autoload.php';

use PhpAmqpLib\Connection\AMQPStreamConnection;
use PhpAmqpLib\Message\AMQPMessage;

$connection = new AMQPStreamConnection('localhost', 5672, 'guest', 'guest', '/');
$channel = $connection->channel();
$channel->set_return_listener(function ($i,$msg,$exchange,$routeKey,AMQPMessage $message) {
   print_r($message->body);
});
$channel->confirm_select();
$channel->set_ack_handler(function (AMQPMessage $message) {
    print_r($message->body);
});
$channel->exchange_declare('hyperf', 'topic', true, true, false);
$channel->queue_declare('kt-test', false, true, false, false);
$channel->queue_bind('kt-test', 'kt-test', 'kt-test');

for ($i = 0; $i < 2; $i++) {
    $msg = new AMQPMessage('Hello World!');
    //设置一个匹配不到队列的路由键，mandatory设置为true
    $channel->basic_publish($msg, 'hyperf', 'kjfwelf',true); 
    echo " [x] Sent 'Hello World!'\n";
}

$channel->wait_for_pending_acks_returns(10); //等待
$channel->close();
$connection->close();
```

## 什么是消费端的限流？
rabbitMQ提供了一种`qos`的功能，即非自动确认消息的前提下，如果有一定数目的消息（通过consumer或者Channel设置qos）未被确认，不进行新的消费。
```php
$channel->basic_qos($prefetch_size, $prefetch_count, $a_global);
```
- prefetchSize:0 单条消息的大小限制。0就是不限制，一般都是不限制。
- prefetchCount: 设置一个固定的值，一旦有N个消息还没有ack，则consumer将block掉，直到有消息ack
- global：是否将上面的设置用于channel，也是就是说上面设置的限制是用于channel级别的还是consumer的级别的。

## 什么是TTL队列/消息？
- 支持消息的过期时间，在消息发送时可以指定。
- 支持队列过期时间，在消息入队列开始计算时间，只要超过了队列的超时时间配置，那么消息就会自动的清除。

## 什么是死信队列？
死信队列：DLX，Dead-Letter-Exchange
### 消息变为死信的几种情况：
- 消息被拒绝（basic.reject/basic.nack）同时requeue=false（不重回队列）
- TTL过期
- 队列达到最大长度
https://www.cnblogs.com/Zhangcsc/p/11739754.html
```php
<?php
require_once __DIR__ . '/vendor/autoload.php';

use PhpAmqpLib\Connection\AMQPStreamConnection;
use PhpAmqpLib\Message\AMQPMessage;
use PhpAmqpLib\Wire\AMQPTable;

$connection = new AMQPStreamConnection('localhost', 5672, 'guest', 'guest', '/');
$channel = $connection->channel();

$args = new AMQPTable();
// 消息过期方式：设置 queue.normal 队列中的消息10s之后过期
$args->set('x-message-ttl', 3000);
// 设置队列最大长度方式： x-max-length
//$args->set('x-max-length', 1);
$args->set('x-dead-letter-exchange', 'exchange.dlx');
$args->set('x-dead-letter-routing-key', 'routingkey');
$channel->exchange_declare('exchange.dlx', 'direct', false, true);
$channel->queue_declare('queue.dlx', false, true, false, false);
$channel->queue_bind('queue.dlx', 'exchange.dlx', 'routingkey');

$channel->exchange_declare('hyperf', 'topic', true, true, false);
$channel->queue_declare('test-ttl', false, true, false, false,false,$args);
$channel->queue_bind('test-ttl', 'hyperf', 'kt-test');

for ($i = 0; $i < 2; $i++) {
    $msg = new AMQPMessage('Hello World!');
    //设置一个匹配不到队列的路由键，mandatory设置为true
    $channel->basic_publish($msg, 'hyperf', 'kt-test',false);
    echo " [x] Sent 'Hello World!'\n";
}

$channel->close();
$connection->close();
```