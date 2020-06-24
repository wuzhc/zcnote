## docker运行rabbitmq
```bash
docker run --name rabbitmq -p 15672:15672 -p 5672:5672 rabbitmq:management
```

## rabbitmqctl命令
```bash
# 查看队列
rabbitmqctl list_queues -p <VHostPath> <QueueInfoItem>
rabbitmqctl list_queues name messages consumers memory durable auto_delete
Listing queues for vhost / ...
name	messages	consumers	memory	durable	auto_delete
 mq_ktuser_request_log_queue	0	0	34720	true	false

# 查看交换器和绑定
rabbitmqctl list_exchanges
```