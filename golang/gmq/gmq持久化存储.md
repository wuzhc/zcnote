# 持久化存储
> 持久化即将内存数据保存到磁盘,其目的是为了保证消息的可靠性,例如gmq发生意外以后中断退出时,消息不会丢失

`gmq`只有两种类型的消息,一种是待消费消息,一种是延迟消息,这两种方式都使用了文件作为存储,并且为了减少io拷贝,`gmq`使用内存映射方式

## 消息存储格式
消息存储格式为`v+msgLen+msg.Id+msg.Retry+msg.Delay+msg.Body`
- v 标识号
- msgLen 整个消息长度(包括消息ID,重试次数,延迟时间,消息主体)
- msg.Id 消息ID
- msg.Retry 重试次数
- msg.Body 消息主体
```go
// 消息结构
type Msg struct {
	Id    uint64 // 8个字节
	Retry uint16 // 2个字节
	Delay uint32 // 4个字节
	Body  []byte // n个字节
}

// 消息编码
func Encode(m *Msg) []byte {
	var data = make([]byte, 8+2+4+len(m.Body))
	binary.BigEndian.PutUint64(data[:8], m.Id)
	binary.BigEndian.PutUint16(data[8:10], m.Retry)
	binary.BigEndian.PutUint32(data[10:14], m.Delay)
	copy(data[14:], m.Body)
	return data
}

// 消息解码
func Decode(data []byte) *Msg {
	msg := &Msg{}
	msg.Id = binary.BigEndian.Uint64(data[:8])
	msg.Retry = binary.BigEndian.Uint16(data[8:10])
	msg.Delay = binary.BigEndian.Uint32(data[10:14])
	msg.Body = data[14:]
	return msg
}
```

## 待消费消息
待消费消息会存储在准备队列,`gmq`分成读和写两部分
### 写部分
- 先映射文件,记录当前文件编号
- 每写入一条消息,记录当前写入偏移量(指当前位置到文件开头的距离),记录当前偏移量和文件编号对应关系map表
- 当写满文件后,解除文件映射,文件编号加1,新建文件进行映射
### 读部分
- 先映射文件,记录当前文件编号
- 判断当前文件编号是否存在于写部分创建的map表中,如果存在,说明该文件已有消息,获得写的偏移量
- 再次判断当前读的偏移量和上一个步骤获得写的偏移量,如果读偏移量小于写偏移量,说明还有消息为读取,则进行读取
- 若读偏移量等于写偏移量,则需要判断是否已经读取文件末尾,如果读到文件末尾,则表示该文件消息已经读取完毕,解除映射并删除该文件

## 延迟消息
延迟消息存储引用了第三方库`BBolt`,`bbolt`底层数据结构采用了`B+Tree`,并且也是用内存映射的方式

### 为什么用采用`bbolt`来存储延迟消息
- 延迟消息是需要根据时间来排序,快到期的消息排在前面,这样每次检索队列中是否到期消息时,只要判断第一个消息是否到期即可
- 因为这个特点,我们需要一个有序的数据结构,在之前设计中,我使用了`跳跃表`,但是`跳跃表`有明显缺陷,第一占空间,第二持久化麻烦(需要导出到文件,然后再重新导入内存,这样增加复杂性)
- `B+Tree`通过内存映射到文件,以一个页为单位,加载到内存,另外`B+Tree`的叶子节点数据是有序,它会根据`key`排序,我们只要把延迟时间作为`key`即可

### `bbolt`带来的问题
- bbolt对页内数据的增删查改都需要使用事务,每一次事务结束时需要`commit`,`commit`会发生`B+Tree`的结点再平衡和分裂操作,导致每一次操作都会很慢,所以如果你的业务对生产延迟消息的性能有要求的话,可以使用批量推送的命令
- `bbolt`不允许`key`重复,所以不能以消息的到期时间作为`key`,因为一个时间都有可能对应有多个到期消息.`gmq`使用*到期时间+唯一字符串*为`key`,唯一字符串使用了消息ID`msg.Id`(消息ID本身也包含了时间戳,所以消息ID也是有序的),这样可以保证`key`不重复,并且是有序的

## 参考
- [内存映射 mmap的理解](https://blog.csdn.net/MakeContral/article/details/85170752)