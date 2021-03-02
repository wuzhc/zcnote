大家好,今天为大家带来的内容是数据类型,在这里,,我先大概说下大纲,主要讲解字符串类型,数组类型,以及布尔类型

三者底层有着相同的内存结构

## 数组
### 数组定义
```go
var a [3]int                    // 定义长度为3的int型数组, 元素全部为0
var b = [...]int{1, 2, 3}       // 定义长度为3的int型数组, 元素为 1, 2, 3
var c = [...]int{2: 3, 1: 2}    // 定义长度为3的int型数组, 元素为 0, 2, 3
var d = [...]int{1, 2, 4: 5, 6} // 定义长度为6的int型数组, 元素为 1, 2, 0, 0, 5, 6
```
### 数组遍历
```go
for i := range a {
	fmt.Printf("a[%d]: %d\n", i, a[i])
}
for i, v := range b {
	fmt.Printf("b[%d]: %d\n", i, v)
}
for i := 0; i < len(c); i++ {
	fmt.Printf("c[%d]: %d\n", i, c[i])
}
```
建议用`for range`迭代数组,因为这种迭代可以保证不会出现数组越界的问题.

### 数组多种类型
```go
// 字符串数组
var s1 = [2]string{"hello", "world"}
var s2 = [...]string{"你好", "世界"}
var s3 = [...]string{1: "世界", 0: "你好", }
// 结构体数组
var line1 [2]image.Point
var line2 = [...]image.Point{image.Point{X: 0, Y: 0}, image.Point{X: 1, Y: 1}}
var line3 = [...]image.Point{{0, 0}, {1, 1}}
// 图像解码器数组
var decoder1 [2]func(io.Reader) (image.Image, error)
var decoder2 = [...]func(io.Reader) (image.Image, error){
    png.Decode,
    jpeg.Decode,
}
// 接口数组
var unknown1 [2]interface{}
var unknown2 = [...]interface{}{123, "你好"}
// 管道数组
var chanList = [2]chan int{}
```

### 空数组
长度为0的数组在内存中并不会占用空间

### 打印数组
```go
fmt.Printf("b: %T\n", b)  // b: [3]int
fmt.Printf("b: %#v\n", b) // b: [3]int{1, 2, 3}
```


## rune
```go
type rune = int32
```
它是int32的别名（-231~231-1），对于byte（-128～127），可表示的字符更多。`rune`能处理一切字符,包括中文字符.
`rune`有什么作用呢?
golang中string底层是通过byte数组实现的。中文字符在unicode下占2个字节，在utf-8编码下占3个字节，而golang默认编码正好是utf-8。
```go
package main

import (
    "fmt"
    "unicode/utf8"
)

func main() {
    var chinese = "我是中国人， I am Chinese"
    fmt.Println("chinese length", len(chinese))
    fmt.Println("chinese word length", len([]rune(chinese)))
    fmt.Println("chinese word length", utf8.RuneCountInString(chinese))
}

//输出，注意在golang中一个汉字占3个byte
//chinese length 31
//chinese word length 19
//chinese word length 19
```

- byte 等同于int8，常用来处理ascii字符
- rune 等同于int32,常用来处理unicode或utf-8字符
https://www.cnblogs.com/chaselogs/p/10715251.html

UTF-8 最大的一个特点，就是它是一种变长的编码方式。它可以使用1~4个字节表示一个符号，根据不同的符号而变化字节长度。

Unicode 只是一个符号集，它只规定了符号的二进制代码，却没有规定这个二进制代码应该如何存储。



## 字符串
```go
var name string = "Go语言编程网"
```
字符串是对我们来说并不陌生,但是我们还是需要记住字符串在Go语言中的一些特性;
- 字符串是一个只读的字节数组
- 字符串一旦赋值,不能修改(即字节数组元素是固定的,不能通过下标修改值)
- 字符串的字节使用`UTF-8`编码标识Unicode文本

先看下`byte`和`rune`
`byte`标识一个字符,`rune`表示几个字符,多个`byte`或`rune`组成的数组便是字符串,这就是上面所说的字节数组.如下所示:
```go
var name string = "hello golang"
//等价于
var name = []byte{'h','e','l','l','o',' ','g','o','l','a','n','g'}
```

### 字符串底层结构
```go
type StringHeader struct {
    Data uintptr
    Len  int
}
```

### 字符串是字节数组
```go
var data = [...]byte{
    'h', 'e', 'l', 'l', 'o', ',', ' ', 'w', 'o', 'r', 'l', 'd',
}
//等同于
var data = "hello world"
```

### 字符串操作
字符串虽然不是切片,但是支持切片方式操作字符串
```go
s := "hello, world"
hello := s[:5]
world := s[7:]
s1 := "hello, world"[:5]
s2 := "hello, world"[7:]
```

## 切片
切片是动态数组

### 切片底层结构
```go
type SliceHeader struct {
    Data uintptr
    Len  int
    Cap  int
}
```

### 切片定义
```go
var (
    a []int               // nil切片, 和 nil 相等, 一般用来表示一个不存在的切片
    b = []int{}           // 空切片, 和 nil 不相等, 一般用来表示一个空的集合
    c = []int{1, 2, 3}    // 有3个元素的切片, len和cap都为3
    d = c[:2]             // 有2个元素的切片, len为2, cap为3
    e = c[0:2:cap(c)]     // 有2个元素的切片, len为2, cap为3
    f = c[:0]             // 有0个元素的切片, len为0, cap为3
    g = make([]int, 3)    // 有3个元素的切片, len和cap都为3
    h = make([]int, 2, 3) // 有2个元素的切片, len为2, cap为3
    i = make([]int, 0, 3) // 有0个元素的切片, len为0, cap为3
)
```

### 切片操作
添加切片
```go
var a []int
a = append(a, 1)               // 追加1个元素
a = append(a, 1, 2, 3)         // 追加多个元素, 手写解包方式
a = append(a, []int{1,2,3}...) // 追加一个切片, 切片需要解包
```

### 切片类型转换





















