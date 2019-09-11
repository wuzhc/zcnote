## 参考
- https://www.jianshu.com/p/228c119a7d0e

> 调用`sync/atomic`中的几个函数可以对几种简单的类型进行原子操作。这些类型包括`int32`,`int64`,`uint32`,`uint64`,`uintptr`,`unsafe.Pointer`,共6个。这些函数的原子操作共有5种：`增或减`，`比较并交换`、`载入`、`存储`和`交换`它们提供了不同的功能，切使用的场景也有区别。

## 什么是原子性
原子性即一组操作不会被被中断,对外表现为一个整体,要么都执行,要么都不执行,**原子操作由底层硬件支持，而锁则由操作系统提供的 API 实现**

## 增或减
```go
# 在原来的基础上加n
atomic.AddUint32(&addr,n)

# 在原来的基础上减n
atomic.AddUint32(&addr, ^uint32(-n-1))
或者
atomic.AddUint32(*addr, uint32(int32(n)))
```

## 比较和交换
简称`cas(compare and swap)`
如果addr指向的值等于old,则用new替换addr指向的值
```go
ok := atomic.CompareAndSwapInt32(&addr, old, new)
```

## 载入
防止写未完成,读发生,用在读场景,读的时候,不会发生写操作
```go
v := atomic.LoadInt32(&addr)
```

## 存储
防止读到一半,写发生,用在写场景,写入的时候,不会发生写操作
```go
atomic.StoreInt32(&addr, v)
```

## 交换
简称`swap`,与CAS不同，交换操作直接赋予新值，不管旧值
```go
oldval := atomic.StoreInt32(&value,newaddr)
```

## 任意类型Value
此类型的值相当于一个容器,可以用来原子地存储或加载任意类型的值







