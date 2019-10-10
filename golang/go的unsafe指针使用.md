> `unsafe.Pointer`类似于C语言中的`void`类型指针

## 参考
- https://www.linkinstar.wiki/2019/06/06/golang/source-code/point-unsafe/
- https://www.cnblogs.com/echojson/p/10743530.html

## 关系
***任何类型的指针  <=> unsafe.Pointer <=> uintptr***
-（1）任何类型的指针都可以被转化为Pointer
-（2）Pointer可以被转化为任何类型的指针
-（3）uintptr可以被转化为Pointer
-（4）Pointer可以被转化为uintptr

## unsafe.Pointer()参数必须是一个指针类型
```go
a := 1
b := unsafe.Pointer(a) //报错,a必须是指针类型
b := unsafe.Pointer(&a)
```

## unitptr的作用
`uintptr`用于指针数值运算,。不要试图引入一个uintptr类型的临时变量，因为它可能会破坏代码的安全性,如下:
```go
var x struct {
    a bool
    b int16
    c []int
}
 
tmp := uintptr(unsafe.Pointer(&x)) + unsafe.Offsetof(x.b) 
pb := (*int16)(unsafe.Pointer(tmp))
*pb = 42
// 正确的做法
// 和 pb := &x.b 等价
pb := (*int16)(unsafe.Pointer(uintptr(unsafe.Pointer(&x)) + unsafe.Offsetof(x.b)))
*pb = 42
```
`GC`会通过移动变量来降低内存碎片,因为`tmp`只是保存一个普通的数字,当变量发生移动,但是`tmp`没有随着更新数字,所以`tmp`的数字就不再是变量当前的地址了