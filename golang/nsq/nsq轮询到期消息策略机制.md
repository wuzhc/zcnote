# nsq扫描到期消息策略机制
nsq维护一个对象池,池中对象为`queueScanWorker`,池根据`channel`个数和配置参数`QueueScanRefreshInterval`定时动态扩展池大小
**对象池为channel的四分之一**

## 参数配置
- QueueScanSelectionCount 表示要抽取`channel`的个数,其值不大于`channel个数`
- QueueScanInterval 表示定时扫描间隔
- QueueScanRefreshInterval 表示刷新对象池间隔
- QueueScanDirtyPercent 表示此次在扫描的channel中,有消息的channel占所有被扫描channel的比例,默认值为0.25

## 策略机制
- 根据`QueueScanSelectionCount`随机获取指定数量的`channel`
- 记录`channel`有消息个数
- 如果此次在扫描的channel中,有消息的channel占所有被扫描channel的大于`QueueScanDirtyPercent`,说明有很多channel是有到期消息的,不需要等到下个定时器,就可以直接再次重复上面的过程
- `channel`是不固定,所以需要一个定时器,不断的调整对象池的大小,对象池中对象固定为`channel`总数量的四分之一,根据这个四分之一,要动态新增worker或减少worker
