一个`goroutine`内执行是顺序执行,但是我们无法知道一个`goroutine`中的事件x和另一个`goroutine`中的事件y的先后顺序(几个串行程序交错执行),竞态表现在同时对同一个共享变量进行读写

## 方法
- 不要修改变量
- 限制变量只能一个`goroutine`访问 ( go真言:不要用共享内存来通信,而用通信来共享内存 )
- 互斥机制,同一时间只有一个`goroutine`访问

## 互斥锁 sync.Mutex
```go
var mu sync.Mutex
func Balance() int {
	defer mu.Unlock()
	mu.Lock()
	return balance
}
```

##  读写互斥锁 (多读单写锁) sync.RWMutex
允许读并发,不允许写并发
- 在有写的情况下,加了读锁不能读
- 在没写的情况下,加了读锁可以读
- 总而言之,涉及到共享变量和写操作一定得考虑加锁

## 内存同步和语句执行顺序问题
先看下面一个例子:
```go
var x, y int
go func(){
    x = 1                   // A1
    fmt.Print("y:", y, " ") // A2
}()

go func(){
   y = 1                    // B1
   fmt.Print("x:", x, " ")  // B2
}()
```
- 这里打印结果会出现y:0 x:0的情况,如果是多个`goroutine`交错执行,那么不可能会出现都为0的情况,这也说明了多个`goroutine`不是简单的交错执行;  
- 原因是因为各个语句可以调整顺序(赋值和print对应不同的变量,所以编译器认为两个语句的执行顺序不影响结果,然后就交换了两个语句的执行顺序);cpu也有类似情况,各个`goroutine`有自己的缓存,一个`goroutine`的写操作在同步到内存之前对另一个`goroutine`的print语句是不可见的  
- 简而言之,编译器和cpu可以在保证每个`goroutine`满足串行访问的基础上,自由重排访问内存的顺序

## 延迟初始化 sync.Once
```go
package main

import (
	"image"
	"fmt"
)

var icons map[string]image.Image

// 并发不安全
func loadIcons() {
	icons=map[string]image.Image{
		"one.png": loadIcon("one.png"),
		"two.png": loadIcon("two.png"),
		"three.png": loadIcon("three.png")
	}
}

func loadIcon(name string) image.Image{
	return nil
}

func icon(name string) image.Image {
	// icons不为nil,不代表已经全部初始化
	if icons==nil{
		icons=loadIcons()
	}
	return icons[name]
}
```
如上,icons不为nil,不代表已经全部初始化,用`sync.Once`解决方法如下:
```go
var loadIconsOnce sync.Once
var icon map[string]image.Image

func Icon(name string) image.Image {
	loadIconsOnce.Do(loadIconsOnce)
	return icon[name]
}
```
第一次调用`Do()`方法时,用互斥锁,第一次之后设置布尔值为true,后续调用`Do()`会直接跳过

## 竞态检测器
```bash
go test -run=TestConcurrent -race -v gopl/ch9/memo2
```

## 并发架构两种方式
- 共享变量加锁
- 限制共享变量读写操作在单个goroutine

