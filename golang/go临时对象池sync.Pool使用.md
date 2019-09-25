## 参考
- https://segmentfault.com/a/1190000015464889#articleHeader14
- https://www.cnblogs.com/sunsky303/p/9706210.html
- https://www.cnblogs.com/DaBing0806/p/6934318.html

## sync.Pool作用
对象重用机制,为了减少GC,`sync.Pool`是可伸缩的，并发安全的

## 两个结构体
```go
type Pool struct {
    local     unsafe.Pointer // local fixed-size per-P pool, actual type is [P]poolLocal
    localSize uintptr        // size of the local array
  
    // New optionally specifies a function to generate
    // a value when Get would otherwise return nil.
    // It may not be changed concurrently with calls to Get.
    New func() interface{}
}
  
// Local per-P Pool appendix.
type poolLocal struct {
    private interface{}   // Can be used only by the respective P.
    shared  []interface{} // Can be used by any P.
    Mutex                 // Protects shared.
    pad     [128]byte     // Prevents false sharing.
}
```
`Pool`是提供外部使用的对象,`Pool`有两个重要的成员,`local`是一个`poolLocal`数组,`localSize`是工作线程的数量( runtime.GOMAXPROCS(0)),`Pool`为每个线程分配一个`poolLocal`对象

## 写入和读取
- `Pool.Get`
	- 先获取当前线程私有值(poolLocal.private)获取
	- 否则则从共享列表(poolLocal.shared)获取
	- 否则则从其他线程的共享列表获取
	- 否则直接通过New()分配一个返回值
- `Pool.Put`
	- 当前线程私有制为空,赋值给私有值
	- 否则追加到共享列表 
	
## sync.Pool注意点
- 临时性,当发生GC时,Pool的对象会被清除,并且不会有通知
- 无状态,当前线程中的PoolLocal.shared的对象可能会被其他线程偷走

## 大规模Goroutine的瓶颈
- 会对垃圾回收(gc)造成负担,需要频繁的释放内存
- 虽然goroutine只分配2KB,但是大量gorotine会消耗完内存,并且gc也是goroutine调用的

## 原理和作用
原理类似是IO多路复用,就是尽可能复用,池化的核心优势就在于对goroutine的复用。此举首先极大减轻了runtime调度goroutine的压力，其次，便是降低了对内存的消耗  
![https://segmentfault.com/img/remote/1460000015464895?w=1752&h=1170](https://segmentfault.com/img/remote/1460000015464895?w=1752&h=1170)

