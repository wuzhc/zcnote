## 参考
- https://blog.csdn.net/i6448038/article/details/82057424#commentBox
- https://juejin.im/entry/5a1e4bcd6fb9a045090942d8

## map的底层数据结构
golang的`map`底层维护两个数据结构,包括`hmap`,`bucket(bmap)`,一个`hmap`上会维护多个`bucket`,每一个`bucket`会维护提个单向链表
```go
//hamp
type hmap struct {
	count     int // # 元素个数
	flags     uint8
	B         uint8  // 说明包含2^B个bucket
	noverflow uint16 // 溢出的bucket的个数
	hash0     uint32 // hash种子
 
	buckets    unsafe.Pointer // buckets的数组指针
	oldbuckets unsafe.Pointer // 结构扩容的时候用于复制的buckets数组
	nevacuate  uintptr        // 搬迁进度（已经搬迁的buckets数量）
 
	extra *mapextra
}
//bmap
type bmap struct {
	tophash [bucketCnt]uint8 //tophash用于记录8个key哈希值的高8位
}
```
最重要的buckets
```
		->	bmap(bucket)
hmap	->	bmap(bucket)
		->	bmap(bucket)
```

## key是如何定位到bucket的？
一个key经过哈希函数计算后,会得到一个值,一般哈希表中,这个值是对应数组下标,然而`golang`的值可以分为高位和低位,低位用于寻找当前key属于hmap中的哪个bucket，而高位用于寻找bucket中的哪个key
有两个过程，一个找哪个桶，一个是找桶里哪个key，key进过哈希函数计算后得到一个值，低5位找属于哪个桶，高8位在桶里找属于哪个key(如`bmap`结构中的`tophash`)


## map是如何扩容的？
当以上的哈希表增长的时候，Go语言会将bucket数组的数量扩充一倍，产生一个新的bucket数组，并将旧数组的数据迁移至新数组。
golang的加载因子公式:`map长度/2^B > 6.5`,其中B为已扩容的次数。

当Go的map长度增长到大于加载因子所需的map长度时，Go语言就会将产生一个新的bucket数组，然后把旧的bucket数组移到一个属性字段oldbucket中。注意：并不是立刻把旧的数组中的元素转义到新的bucket当中，而是，只有当访问到具体的某个bucket的时候，会把bucket中的数据转移到新的bucket中


## 扩容
### 扩容阀值
### 增量扩容
https://juejin.im/post/5dc2cc0b6fb9a04a916d0ba0#heading-1

## 作为函数参数传递时有何影响
map底层使用`makemap`函数创建，`func makemap(t *maptype, hint int64, h *hmap, bucket unsafe.Pointer) *hmap`，makemap返回的是一个指针，所以当作为函数参数传递时，虽然是值拷贝，但是拷贝的是一个地址，所以在函数内部修改的依然是原始值

## map底层结构中，key是如何定位的？
先对key做哈希计算，得到如下：
```
10010111 | 000011110110110010001111001010100010010110010101010 │ 01010
```
低5位即01010决定key落在哪个bmap,高8位10010111决定key落在桶里面哪个位置

## 删除掉map中的元素是否会释放内存？
不会，删除操作仅仅将对应的`tophash[i]`设置为empty，并非释放内存。若要释放内存只能等待指针无引用后被系统gc

## 如何并发地使用map？
map不是goroutine安全的，所以在有多个gorountine对map进行写操作是会panic。多gorountine读写map是应加锁（RWMutex），或使用sync.Map（1.9新增，在下篇文章中会介绍这个东西，总之是不太推荐使用）。

## map的iterator是否安全？
map的delete并非真的delete，所以对迭代器是没有影响的，是安全的。

## map中的 key 为什么是无序的?
因为当map扩容时，原有的bucket上的key可能会被分配到不同的新bucket，也就是key的位置发生了改变

## map是线程安全的吗？
map 不是线程安全的。对map并发读写会导致panic

## map两种get操作
- 带ok `age2, ok := ageMap["stefno"]`
- 不带ok  `age1 := ageMap["stefno"]`


