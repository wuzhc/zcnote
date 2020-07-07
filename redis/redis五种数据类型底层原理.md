> Redis使用前面说的五大数据类型来表示键和值，每次在Redis数据库中创建一个键值对时，至少会创建两个对象，一个是键对象，一个是值对象，而Redis中的每个对象都是由 `redisObject` 结构来表示
```c
typedef struct redisObject{
     //类型
     unsigned type:4;
     //编码
     unsigned encoding:4;
     //指向底层数据结构的指针
     void *ptr;
     //引用计数
     int refcount;
     //记录最后一次被程序访问的时间
     unsigned lru:22;
}robj
```
对象指向数据结构由`encoding`属性决定；如下：
![https://images2018.cnblogs.com/blog/1120165/201805/1120165-20180529083236432-1997988837.png](https://images2018.cnblogs.com/blog/1120165/201805/1120165-20180529083236432-1997988837.png)
![https://imgconvert.csdnimg.cn/aHR0cHM6Ly9tbWJpei5xcGljLmNuL21tYml6X3BuZy80bzIyT0ZjbXpIa2liQ0hiaWJjanVRMlJSNUlUUnN4aWJpYWJjdFYza1RiY093bmZ1aWJ1SDFRYmlhbDQwU0tUNnBweERqSUtpYmNDeVdIUDlpYVpwRDQzN3V6Y0JRLzY0MA?x-oss-process=image/format,png](https://imgconvert.csdnimg.cn/aHR0cHM6Ly9tbWJpei5xcGljLmNuL21tYml6X3BuZy80bzIyT0ZjbXpIa2liQ0hiaWJjanVRMlJSNUlUUnN4aWJpYWJjdFYza1RiY093bmZ1aWJ1SDFRYmlhbDQwU0tUNnBweERqSUtpYmNDeVdIUDlpYVpwRDQzN3V6Y0JRLzY0MA?x-oss-process=image/format,png)
每种类型的对象使用了多种编码
![https://images2018.cnblogs.com/blog/1120165/201805/1120165-20180529083343934-438384530.png](https://images2018.cnblogs.com/blog/1120165/201805/1120165-20180529083343934-438384530.png)

```bash
#查看对象类型 
type key
#查看对象编码
object encoding key
```

## string
> 一个redis中字符串value最多可以是`512M`
字符串对象的编码可以是`int`，`raw(大于44字节的长字符串)`或者`embstr(小于44字节的小字符串)`。
### raw和embstr的区别
`embstr`只分配一次内存，只读，`raw`需要分配两次内存（分别为redisObject和sds分配空间）
![https://imgconvert.csdnimg.cn/aHR0cHM6Ly9tbWJpei5xcGljLmNuL21tYml6X3BuZy80bzIyT0ZjbXpIa2liQ0hiaWJjanVRMlJSNUlUUnN4aWJpYWJVM1AxakI2MjBhY3pUQnVqRTQ3ZmhtRHhWanNLWUxJemFTbjZIRGJsNHhGYlJ1N0d2d3NnYkEvNjQw?x-oss-process=image/format,png](https://imgconvert.csdnimg.cn/aHR0cHM6Ly9tbWJpei5xcGljLmNuL21tYml6X3BuZy80bzIyT0ZjbXpIa2liQ0hiaWJjanVRMlJSNUlUUnN4aWJpYWJVM1AxakI2MjBhY3pUQnVqRTQ3ZmhtRHhWanNLWUxJemFTbjZIRGJsNHhGYlJ1N0d2d3NnYkEvNjQw?x-oss-process=image/format,png)
`embstr`编码的字符串对象的所有数据都在一块连续的内存

## 哈希hash
键值对`key-value`
查询的时间复杂度为`O(1)`
hash编码有两种`压缩列表`和`字典`
### 压缩列表
- 当哈希类型元素个数小于hash-max-ziplist-entries配置（默认512个）；
- 所有值都小于hash-max-ziplist-value配置（默认64个字节）；



## 列表list
有两个特点，`有序`，可重复性
在版本3.2之前使用的是两种数据结构，`linkedlist(双端链表)`和`ziplist(压缩列表)`；因为双向链表占用的内存比压缩列表要多， 所以当创建新的列表键时， 列表会优先考虑使用压缩列表， 并且在有需要的时候， 才从压缩列表实现转换到双向链表实现。

```bash
#redis.conf
list-max-ziplist-value 64 
list-max-ziplist-entries 512 
```
当压缩链表entry数据超过512、或单个value 长度超过64，底层就会转化成linkedlist编码；

在版本3.2之后，由于`listedlist`和`ziplist`有缺点，采用了`quicklist`，它是一个双向链表`linkedlist(双端链表)`，每一个节点是 `ziplist(压缩列表)`  

## 集合
有两个特点，`无序`，`不可重复`，应用场景是求集合的并集，集合是通过哈希表实现的，所以查找，添加，删除的复杂度都是O(1)
集合的编码类型是`REDIS_ENCODING_HT字典`和`REDIS_ENCODING_INTSET整数集合`
当满足下面条件时使用`整数集合编码`
- Set集合中必须是64位有符号的十进制整型；
- 元素个数不能超过set-max-intset-entries配置，默认512；

## 有序集合
https://www.jianshu.com/p/35bce2ea5743
有序的，元素不重复，每个元素会关联一个score用于排序，score是可以重复的
有序集合两种编码，分别为压缩列表和跳跃表（`REDIS_ENCODING_ZIPLIST`和`REDIS_ENCODING_SKIPLIST`）
### 压缩列表
![https://upload-images.jianshu.io/upload_images/6990035-4d859c25df76393e.png?imageMogr2/auto-orient/strip|imageView2/2/w/771/format/webp](https://upload-images.jianshu.io/upload_images/6990035-4d859c25df76393e.png?imageMogr2/auto-orient/strip|imageView2/2/w/771/format/webp)
当有序集合对象同时满足以下两个条件时，对象使用 ziplist 编码：
- 1、保存的元素数量小于128；
- 2、保存的所有元素长度都小于64字节。
### 跳跃表
![http://p1-tt.byteimg.com/large/pgc-image/e0a4825bb5774b96b85b0313d93def65?from=pc](http://p1-tt.byteimg.com/large/pgc-image/e0a4825bb5774b96b85b0313d93def65?from=pc)

## stream
其实是一个队列，每一个key对应一个队列

## 问题
### set和hash的关系是什么？
两者都是`REDIS_ENCODING_HT`字典类型时，`set`的value为null的特殊字典`dict`

### 如何借助Sorted set实现多维排序?
可以把涉及排序的多个维度的列按照一定方式组成score，例如按照时间time和下载量download排序，score=time+download


