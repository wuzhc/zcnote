### 1.0 随机数
```go
package main

import (
        "log"
        "math/rand"
        "time"
)

func main() {
        rand.Seed(time.Now().UnixNano())
        i := rand.Intn(3)
        log.Println(i)
}
```
> 每次都需要调用rand.Seed，否则产生的随机数都是一样的

#### 1.1 math/rand
实现了伪随机数生成器
```go
// 随机产生4位长度伪随机数
for i := 0; i < 10; i++ {
	fmt.Printf("%.4d ", rand.Int31()%10000)
}
```
#### 1.2 crypto/rand
实现了用于加解密的更安全的随机数生成器
```go
import (
    "crypto/rand"
    "fmt"
)

func main() {
    b := make([]byte, 20)
    fmt.Println(b)       

    _, err := rand.Read(b)
    if err != nil {
        fmt.Println(err.Error())
    }

    fmt.Println(b)
}
```
该包中常用的是 func Read(b []byte) (n int, err error) 这个方法， 将随机的byte值填充到b 数组中，以供b使用

### 2.0 flag命令行选项
```go
flag.BoolVar(&v, "v", false, "show version and exit")
flag.StringVar(&p, "p", "/usr/local/nginx/", "set `prefix` path")
```
- 第一个参数保存选项值
- 第二个参数选项名称
- 第三个参数选择默认值
- 第四个参数命令行提示
```go
package main

import (
    "flag"
    "fmt"
    "os"
)

// 实际中应该用更好的变量名
var (
    h bool

    v, V bool
    t, T bool
    q    *bool

    s string
    p string
    c string
    g string
)

func init() {
    flag.BoolVar(&h, "h", false, "this help")

    flag.BoolVar(&v, "v", false, "show version and exit")
    flag.BoolVar(&V, "V", false, "show version and configure options then exit")

    flag.BoolVar(&t, "t", false, "test configuration and exit")
    flag.BoolVar(&T, "T", false, "test configuration, dump it and exit")

    // 另一种绑定方式
    q = flag.Bool("q", false, "suppress non-error messages during configuration testing")

    // 注意 `signal`。默认是 -s string，有了 `signal` 之后，变为 -s signal
    flag.StringVar(&s, "s", "", "send `signal` to a master process: stop, quit, reopen, reload")
    flag.StringVar(&p, "p", "/usr/local/nginx/", "set `prefix` path")
    flag.StringVar(&c, "c", "conf/nginx.conf", "set configuration `file`")
    flag.StringVar(&g, "g", "conf/nginx.conf", "set global `directives` out of configuration file")

    // 改变默认的 Usage，flag包中的Usage 其实是一个函数类型。这里是覆盖默认函数实现，具体见后面Usage部分的分析
    flag.Usage = usage
}

func main() {
    flag.Parse()

    if h {
        flag.Usage()
    }
}

func usage() {
    fmt.Fprintf(os.Stderr, `nginx version: nginx/1.10.0
Usage: nginx [-hvVtTq] [-s signal] [-c filename] [-p prefix] [-g directives]

Options:
`)
    flag.PrintDefaults()
}
```
