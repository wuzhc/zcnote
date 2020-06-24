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

## hash
键值对`key-value`
查询的时间复杂度为`O(1)`

## 列表
有两个特点，`有序`，可重复性
在版本3.2之前使用的是两种数据结构，`linkedlist(双端链表)`和`ziplist(压缩列表)`；因为双向链表占用的内存比压缩列表要多， 所以当创建新的列表键时， 列表会优先考虑使用压缩列表， 并且在有需要的时候， 才从压缩列表实现转换到双向链表实现。

```bash
#redis.conf
list-max-ziplist-value 64 
list-max-ziplist-entries 512 
```
当压缩链表entry数据超过512、或单个value 长度超过64，底层就会转化成linkedlist编码；

在版本3.2之后，由于`listedlist`和`ziplist`有缺点，采用了`quicklist`，它是一个双向链表`linkedlist(双端链表)`，每一个节点是 `ziplist(压缩列表)`  

## 哈希

## 集合
有两个特点，`无序`，`不可重复`，应用场景是求集合的并集

## 有序集合
有序的

## stream
其实是一个队列，每一个key对应一个队列