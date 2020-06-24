## 参考
- https://blog.csdn.net/i6448038/article/details/82057424#commentBox
- https://juejin.im/entry/5a1e4bcd6fb9a045090942d8

map一般实现有两种数据结构，`哈希查找表`和`搜索树`
哈希查找表存在`碰撞`问题，一般使用`链表法`和`开放地址法`，链表法将一个 bucket 实现成一个链表，落在同一个 bucket 中的 key 都会插入这个链表。开放地址法则是碰撞发生后，通过一定的规律，在数组的后面挑选“空位”，用来放置新的 key。
go使用的是`哈希查找表`和`链表法`解决碰撞问题

golang的`map`底层维护两个数据结构,包括`hmap`,`bucket(bmap)`,一个`hmap`上会维护多个`bucket`,每一个`bucket`会维护提个单向链表
![https://img-blog.csdn.net/20180826000521794?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2k2NDQ4MDM4/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70](https://img-blog.csdn.net/20180826000521794?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2k2NDQ4MDM4/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

## bucket(bmap)
`bucket`是实际存储键值对的数据结构
![https://img-blog.csdn.net/20180826002611384?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2k2NDQ4MDM4/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70](https://img-blog.csdn.net/20180826002611384?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2k2NDQ4MDM4/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

## 哈希函数
一个key经过哈希函数计算后,会得到一个值,一般哈希表中,这个值是对应数组下标,然而`golang`的值可以分为高位和低位,低位用于寻找当前key属于hmap中的哪个bucket，而高位用于寻找bucket中的哪个key
有两个过程，一个找哪个桶，一个是找桶里哪个key，key进过哈希函数计算后得到一个值，低5位找属于哪个桶，高8位在桶里找属于哪个key


## map扩容
当以上的哈希表增长的时候，Go语言会将bucket数组的数量扩充一倍，产生一个新的bucket数组，并将旧数组的数据迁移至新数组。
golang的加载因子公式:`map长度/2^B > 6.5`,其中B为已扩容的次数。

当Go的map长度增长到大于加载因子所需的map长度时，Go语言就会将产生一个新的bucket数组，然后把旧的bucket数组移到一个属性字段oldbucket中。注意：并不是立刻把旧的数组中的元素转义到新的bucket当中，而是，只有当访问到具体的某个bucket的时候，会把bucket中的数据转移到新的bucket中


## 扩容
### 扩容阀值
### 增量扩容
https://juejin.im/post/5dc2cc0b6fb9a04a916d0ba0#heading-1

## 作为函数参数传递时有何影响
map底层使用`makemap`函数创建，`func makemap(t *maptype, hint int64, h *hmap, bucket unsafe.Pointer) *hmap`，makemap返回的是一个指针，所以当作为函数参数传递时，虽然是值拷贝，但是拷贝的是一个地址，所以在函数内部修改的依然是原始值



