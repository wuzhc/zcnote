## 参考
- https://gobyexample.com/command-line-flags

go自带flag库
可以支持三种方式,字符串,整数,布尔值,使用过程主要两个步骤,先声明,声明完后调用`flag.Parse()`如下:
```go
package main
import (
	"fmt"
	"runtime"
)

func main() {
    wordPtr := flag.String("word", "food", "is string")
    numPtr := flag.Int("num", 42, "is int")
    boolPtr := flag.Bool("fork", false, "is bool")
    
    var svar string
    flag.StringVar(&svar, "svar", "bar", "a string var")
    
    flag.Parse()
    
    fmt.Println("word:", *wordPtr)
    fmt.Println("numb:", *numbPtr)
    fmt.Println("fork:", *boolPtr)
    fmt.Println("svar:", svar)
    fmt.Println("tail:", flag.Args())
}
```

## 声明格式
```go
flag.String("word", "food", "is string")
```
声明一个参数word,默认值为food,提示语是is string

## 使用已声明的变量
```go
var svar String
flag.StringVar(&svar, "svar", "bar", "is string var")
```
svar是已声明的变量,默认值是bar,提示语是is string var 

## 返回值
flag返回值是一个指针,所以需要用`*ptr`来获取实际的值

## 剩余参数值
`flag.Args()`存放了所有没有声明的命令行参数




