## 参考
- https://www.jianshu.com/p/228c119a7d0e

> 调用`sync/atomic`中的几个函数可以对几种简单的类型进行原子操作。这些类型包括`int32`,`int64`,`uint32`,`uint64`,`uintptr`,`unsafe.Pointer`,共6个。这些函数的原子操作共有5种：`增或减`，`比较并交换`、`载入`、`存储`和`交换`它们提供了不同的功能，切使用的场景也有区别。

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
简称`cas`
```go
ok := atomic.CompareAndSwapInt32(&addr, old, new)
```

## 载入
预防写未完成,读发生
```go
v := atomic.LoadInt32(&addr)
```

## 存储
区分读到一般,写发生
```go
atomic.StoreInt32(&addr, v)
```

## 交换
简称`swap`,与CAS不同，交换操作直接赋予新值，不管旧值
```go
oldval := atomic.StoreInt32(&value,newaddr)
```








