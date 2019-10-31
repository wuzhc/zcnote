## 参考
- https://www.jianshu.com/p/b86a69892990
- https://www.jianshu.com/p/65980834ce88

## 创建db
- 不同平台下,`mmap`、`fdatasync`、`flock`相关的系统调用貌似不一样,通过`fdatasync()`调用将内核中磁盘页缓冲立即写入磁盘。
- 通过mmap对文件进行只读映射，写时通过write和fdatasync系统调用修改文件(读用`mmap`,写用`fseek`和`fwrite`)
- database的有多少个页保存在`db.meta.pgid`
- 如果要调整文件大小,用`ftruncate`
- `page.meta.txid`实际上可以看作是数据库的修改版本号，每次写时会增加1(为什么要用前两页来维护`meta`)
![](https://upload-images.jianshu.io/upload_images/9246898-ab33fb1d94be0cd0.png?imageMogr2/auto-orient/strip|imageView2/2/w/529/format/webp)

## 分支页(branchPageElements),叶子页(leafPageElements)
- `node`是一个`page`加载到内存中后的结构化表示，即它是page反序列化(或者实例化)的结果,`page`中存的`K/V`对反序列化后会存在`node.inodes`中，`page`中的`elements`个数与`node.inodes`中的个数相同，而且一一对应
- 一个Bucket对应一颗B+Tree
- `leafPageElement.flags` 标明当前element是否代表一个Bucket，如果是Bucket则其值为1，如果不是则其值为0
- `page` = `header` + `leafPageElement_1` + `leafPageElement_2` + .... + `key-value_1` + `key_value_2` + ...
![](https://upload-images.jianshu.io/upload_images/9246898-0a761d47189dae73.png?imageMogr2/auto-orient/strip|imageView2/2/w/604/format/webp)

## 事务transaction
- 读写transaction的整个生命周期，实现了一个进程内同时只有一个读写transaction
- 结合文件锁与db.rwlock，BoltDB可以保证同一时段只有一个进程的一个线程可以对数据库修改(可以认为只有一个goroutine会修改数据库)
- 如果存在着耗时的只读transaction，同时写transaction需要remmap时，写操作会被读操作阻塞

## bucket
- rootNode: Bucket的根节点，也是对应B+Tree的根节点;
- FillPercent: 当节点中Key的个数或者size超过整个node容量的某个百分比后，节点必须分裂为两个节点，这是为了防止B+Tree中插入K/V时引发频繁的再平衡操作
- 一个节点中的Key的数量如果大于节点Key数量的最大值 x 填充率的话，节点会分裂(split)成两个节点，并向父节点添加一个Key和Pointer
- 内置bucket即它的`b+tree`只有一个根节点(根节点上面有很多inodes,因为没有分裂所以只有一个根节点吧)
	- 内置bucket的`page`字段指向`value`中内置`page`的起始位置(一个bucket的value是bucket头和内置page的序列化结果)
	- 内置bucket的`root`为0

## 节点再平衡和分裂
再平衡和分裂发生在`db.Commit`过程
- 写入不直接读写页的内容,而且将其实例化为node后，修改node中的记录，随后在Transaction Commit时，node经过旋转和分裂后再被写入磁盘页
- 修改的node会重新分配新的页,而旧页会通过freelist.free()被标记为Pending页,即将被释放(怎么知道映射内存中哪些页是空闲的呢?页号是根据什么生成的?)
- 每一次`freelist`都会重新分配页
- 每一次`meta.pgid`都会向后移,每次写入页时都会检测`meta.pgid`前面是否有空闲页
- 页面的分配和回收可能会伴随着文件大小的调整及remmap过程
	- 1) 需要增加文件大小，不需要remmap
	- 2) 需要增加文件大小，需要remmap; 
	- 3) 不需要增加文件大小，需要remmap；
	- 4) 不需要增加文件大小，不需要remmap 


## MVCC机制
> MVVC (Multi-Version Concurrency Control) (注：与MVCC相对的，是基于锁的并发控制，Lock-Based Concurrency Control)是一种基于多版本的并发控制协议,，只有在InnoDB引擎下存在。MVCC是为了实现事务的隔离性，通过版本号，避免同一数据在不同事务间的竞争，你可以把它当成基于多版本号的一种乐观锁 

MVCC的基本思路是: 写时增加版本号，读时可能读到不同的版本，读写可以并行
### mvcc解决了什么问题
- MVCC使得数据库读不会对数据加锁，select不会加锁，提高了数据库的并发处理能力；
- 借助MVCC，数据库可以实现RC，RR等隔离级别，用户可以查看当前数据的前一个或者前几个历史版本，保证了ACID中的I-隔离性。


