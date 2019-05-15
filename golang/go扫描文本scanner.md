> `text/scanner`可以扫描文本,然后分割一个个组 

## 初始化
`scanner.Scanner.Init()`以`io.Reader`为接口参数

```go
import (
	"text/scanner"
)

var s scanner.Scanner
s.Init(strings.NewReader("hello world"))
```

## 设置模式
- scanner.ScanIdents 字母或汉字会被分割为一组,其他符号为单个一组
- scanner.ScanFloats 不设置这个,浮点数会被拆开
- scanner.ScanInts 不设置这个,整数会被拆开

## scanner.Scanner.Scan()返回值
- scanner.Ident
- scanner.Float
- scanner.Int
- 其他对应ascii码

## 获取分割组
- scanner.Scanner.TokenText()

## 例子
```go
package main

import (
	"fmt"
	"strings"
	"text/scanner"
)

func main() {
	var s scanner.Scanner
	input := "hello world 123456"
	s.Init(strings.NewReader(input))
	s.Mode = scanner.ScanIdents | scanner.ScanFloats | scanner.ScanInts

	for tok := s.Scan(); tok != scanner.EOF; tok = s.Scan() {
		switch tok {
		case scanner.Ident:
			fmt.Println("ident", s.TokenText())
		case scanner.Float:
			fmt.Println("float", s.TokenText())
		case scanner.Int:
			fmt.Println("int", s.TokenText())
		default:
			fmt.Println("unkown", s.TokenText())
		}
	}
}
```
输出如下:
```bash
ident hello
ident world
int 123456
```

























