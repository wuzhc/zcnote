## 删除topic
- topic.Delete() 
	- topic.exit(true) 标记exitFlag为1,通知lookupd,关闭exitChan,等待topic其他goroutine退出,删除channelMap和关闭channel,清空topic(清空BackendQueue),删除BackendQueue
		- topic.Empty()  清空BackendQueue 
		- topic.backend.Delete() 删除BackendQueue
		- channel.Delete()  
			- channel.exit(true)  标记exitFlag为1,通知loopup,加锁强制关闭client,清空channel,删除BackendQueue
				- client.Close() 加锁强制关闭客户端
            	- channel.Empty() 初始化了inFlightPQ和deferredPQ队列,清空client,清空BackendQueue
            	- channel.backend.Delete() 删除BackendQueue

> 退出的时候都会检测memoryMsgChan是否已读完

### 突然想到一个问题,如何在退出之前保证channel读取完毕???
先禁止往channel写入,读取的时候用`for-select`循环读取channel数据,当channel没有数据时,执行select默认事件,在默认事件执行退出

## 新建topic
### topic几个重要的属性
- memoryMsgChan 取决于options.MemQueueSize
- backend 好像是后台队列
	- newDummyBackendQueue() 创建的dummyBackendQueue数据类型 
	- diskqueue.New() 返回值是一个接口类型,具体类型是diskQueue磁盘队列

### 流程
- 新建Topic对象
- 创建topic.backend(后台队列),其值是`dummyBackendQueue`或`diskQueue`,虚拟topic创建dummyBackendQueue,其他创建diskQueue
- 新建goroutine运行`topic.messagePump`,这个方法是将磁盘或内存的消息推送给客户端
- 调用`t.ctx.nsqd.Notify(t)`,这是要通知nsqd更新持久化元数据

## messagePump的作用
`messagePump`大概是从内存或磁盘获取消息,然后遍历topic下的channel,推送给每一个channel,这种时候如果是延迟消息会进行处理
### 延迟消息推送
- 有一个pqueue的队列,延迟消息作为一个元素`(&pqueue.Item{Value: msg, Priority: absTs})`加入到队列,然后存放在`channel.deferredMessages`
- `channel.deferredMessages`存放延迟消息包装的`pqueue.Item`和`message.id`的map表,主要用来检测消息是否已经加入过了
- 将pqueue.Item推到channel.deferredPQ的堆上