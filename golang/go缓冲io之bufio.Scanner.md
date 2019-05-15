## 参考
- https://studygolang.com/articles/11905

> 缓冲IO对写操作来说,可以减少系统调用,因为可以把数据写到缓冲区, 当达到一定量时才写到硬盘;对于读来说,可以读取更多的数据到缓冲区中

## 完整代码
```go
package main

import (
	"bufio"
	"errors"
	"fmt"
	"strings"
)

func main() {
	counts := make(map[string]int)
	input := "wuzhc tangjf pengjc ymg wuzhc"
	scanner := bufio.NewScanner(strings.NewReader(input))

	// scanner.Split(bufio.ScanWords)
	splitFunc := func(data []byte, atEOF bool) (advance int, token []byte, err error) {
		fmt.Printf("%t\t%d\t%s\n", atEOF, len(data), data)
		if atEOF {
			return 0, nil, errors.New("at eof")
		} else {
			return 0, nil, nil
		}
	}
	scanner.Split(splitFunc)

	// 设置缓冲区的大小
	buf := make([]byte, 2)
	scanner.Buffer(buf, bufio.MaxScanTokenSize)

	for scanner.Scan() {
		counts[scanner.Text()]++
	}

	// 报错处理
	if scanner.Err() != nil {
		fmt.Printf("error:%s\n", scanner.Err())
	}

	for k, n := range counts {
		fmt.Println(k, ":", n)
	}
}
```

## 分割函数
`bufio.Scanner`调用`bufio.Scanner.Split(func)`可以分割输入内容;每次调用`func (data []byte,atEOF bool) (advance int,token []byte,err error)`会尽量多读数据,如果设置了缓冲区大小,则一开始会按照缓冲区大小分割,之后缓冲区会慢慢变大`bufio.Scanner.Buffer(buf, bufio.MaxScanTokenSize)`,如果没有设置缓冲区大小,默认一次性读取`64 * 1024`个字节
```go
splitFunc := func(data []byte, atEOF bool) (advance int, token []byte, err error) {
    fmt.Printf("%t\t%d\t%s\n", atEOF, len(data), data)
        if atEOF {
        	return 0, nil, nil
        } else {
        	return 0, nil, nil
    }
}
scanner.Split(splitFunc)
```
