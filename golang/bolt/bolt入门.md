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