# go的interface接口深入理解
> 接口是golang数据结构的核心,golang不是面向对象语言,语法上不支持继承和类
> 函数是作用在某个数据类型上的,类似于类的方法
> 某个数据类型实现了接口定义的方法,则成这个数据类型实现了接口

## 参考
- https://juejin.im/post/5a6873fd518825734501b3c5

## 接口的作用
- 泛型编程,假设有一个函数A,参数为接口类型;不管什么数据类型,只要实现了接口定义的方法,那么就可以调用函数A了
- 隐藏具体实现,假设有一个函数,返回值是接口类型,那么你只能使用接口提供的方法,但是里面的具体实现是不知道的,因为你也不知道他是什么类型

下方高能警惕!!!
## interface底层结构
根据是否有method方法,底层由两种`struct`表示
- eface `empty interface`,没有method
```go
    type eface struct {
        _type *_type
        data  unsafe.Pointer
    }
    
    type _type struct {
        size       uintptr // type size
        ptrdata    uintptr // size of memory prefix holding all pointers
        hash       uint32  // hash of type; avoids computation in hash tables
        tflag      tflag   // extra type information flags
        align      uint8   // alignment of variable with this type
        fieldalign uint8   // alignment of struct field with this type
        kind       uint8   // enumeration for C
        alg        *typeAlg  // algorithm table
        gcdata    *byte    // garbage collection data
        str       nameOff  // string form
        ptrToThis typeOff  // type for pointer to this type, may be zero
    }
```
- iface
```go
type iface struct {
        tab  *itab
        data unsafe.Pointer
    }
    
    // layout of Itab known to compilers
    // allocated in non-garbage-collected memory
    // Needs to be in sync with
    // ../cmd/compile/internal/gc/reflect.go:/^func.dumptypestructs.
    type itab struct {
        inter  *interfacetype
        _type  *_type
        link   *itab
        bad    int32
        inhash int32      // has this itab been added to hash?
        fun    [1]uintptr // variable sized
    }
```

interface包含两个指针,一个指向值的类型,一个指向实际值,对于一个interface类型的nil变量来说,它的两个指针都是0

