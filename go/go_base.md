### go特性
- 1.自动立即回收。
- 2.更丰富的内置类型。
- 3.函数多返回值。
- 4.错误处理。
- 5.匿名函数和闭包。
- 6.类型和接口。
- 7.并发编程。
- 8.反射。
- 9.语言交互性。

### 路径
- GOPATH 项目路径
- GOROOT go安装路径

### 命令
- go build ： 当前目录下生成可执行文件
- go install : 可执行文件生成到bin目录，import的其他包文件生成到pkg目录   

### go数据类型
- channel
- map
- slice
- struct

### 声明变量可见性
在 Go 中，包中成员以名称首字母大小写决定访问权限。首字母大写的名称是被导出的。如下变量的声明为例子：
- 函数内部，仅函数可见
- 函数外部，对当前包可见
- 函数外部且首字母是大写，对所有包可见

### 首行代码 package <name>
表示当前文件属于哪个包，如果是package main表示当前文件是编译后是一个可执行文件，编译后可执行文件存放在bin目录
> 但是同一目录下的文件包名必须一致

### import 导入包
```bash
import "os/exec"  ->  /usr/local/go/pkg/darwin_amd64/os/exec.a
import "fmt"		最常用的一种形式（系统包）
import "./test"		导入同一目录下test包中的内容（相对路径）
import "shorturl/model 	加载gopath/src/shorturl/model模块（绝对路径）
import f "fmt"		导入fmt，并给他启别名ｆ
import . "fmt" 		将fmt启用别名"."，这样就可以直接使用其内容，而不用再添加fmt。
	如fmt.Println可以直接写成Println
import  _ "fmt" 	表示不使用该包，而是只是使用该包的init函数，并不显示的使用该包的其他内容。
	注意：这种形式的import，当import时就执行了fmt包中的init函数，而不能够使用该包的其他函数。
```

### 项目构建和编译
- src: 源码文件
- pkg: 包文件
- bin: 相关执行文件

### 下划线
```go
import _ "fmt" 
// 表示不使用fmt包，只使用fmt的init函数

f, _ := os.Open("xxxxxx")
// 返回句柄和错误，“_”表示忽略error错误
```

### 常量值省略
在常量组中，如不提供类型和初始化值，那么视作与上一个常量相同。一般只要第一个常量初始化值即可
```go
const (
	s = "abc"
	x // x = "abc"
)
```

### iota
在每一个const关键字出现时，被重置为0，然后再下一个const出现之前，每出现一次iota，其所代表的数字会自动增加1
```go
const (
	Sunday = iota
	Monday //通常省略后续行表达式
	Tuesday
	Wednesday
	Thursday
	Friday
	Saturday
)

func main() {
	fmt.Println(Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday)
}

// 输出：0 1 2 3 4 5 6
```

### struct类型
类型C语言的结构体，用来定义复杂的数据类型

### array类型
和C语言不一样，go数组是值类型，这意味着赋值，传参会复制数组，而不是指针
#### 初始化数组
初始化数组是可以使用索引号的

```go
var arr = [长度]类型{值，值，值}
var arr1 = [5]int{1, 2, 3, 4, 5}
var str = [5]string{3: "hello world", 4: "tom"}
var arr2 = [...]int{1, 2, 3, 4, 5, 6}
var users = [...]struct {
		name string
		age  uint8
	}{
		{"user1", 10}, // 可省略元素类型。
		{"user2", 20}, // 别忘了最后一行的逗号。
	}
	
a := [2]int{} // 默认值为0
```
长度可以用...代替，表示通过初始化值确定数组长度
#### 多维数组初始化
```go
a := [2][3]int{{1, 2, 3}, {4, 5, 6}} // 2行3列，每一个为一个花括号
b := [...][2]int{{1, 1}, {2, 2}, {3, 3}} // 第 2 纬度不能用 "..."
```
指针数组 ？？  
数组指针 ？？  

### new和make的区别
- make和new用于分配内存
- make 用来创建map、slice、channel，返回对象非指针
- new 用来创建值类型，返回指向类型值的指针

### slice用于变长数组
slice切片，引用数组,引用数组,引用数组(切片修改的值，原数组也会改变)，初始化如下：
```go
arr := arr[start:end]

arr := [10]int{0,1,2,3,4,5,6,7,8,9}
arr2 := arr[1:3] // 1,2
```
- start为0时是可以省略，表示从头开始切切
- end省略表示切切到结尾结束
- start表示从下标start开始，end表示从下标end-1结束

#### make创建slice
```go
arr := make([]int, len, cap)
```
- len 可以使用的长度
- cap 容量，append扩展长度时，如果新的长度小于容量，不会更换底层数组，否则，go 会新申请一个底层数组，拷贝这边的值过去，把原来的数组丢掉

#### append追加切片
append追加切片，并返回新slice对象；可以用两种用法；
```go
slice = append(slice, elem1, elem2)
slice = append(slice, anotherSlice...) // 拼接两个切片
```
具体如下： 
```go
var a = []int{1, 2, 3, 8:10} // 声明并初始化一个切片,可以使用索引号
fmt.Printf("slice a : %v\n", a)
var b = []int{4, 5, 6}
fmt.Printf("slice b : %v\n", b)
c := append(a, b...)
fmt.Printf("slice c : %v\n", c)
d := append(c, 7)
fmt.Printf("slice d : %v\n", d)
e := append(d, 8, 9, 10)
fmt.Printf("slice e : %v\n", e)

// 输出结果：
slice a : [1 2 3]
slice b : [4 5 6]
slice c : [1 2 3 4 5 6]
slice d : [1 2 3 4 5 6 7]
slice e : [1 2 3 4 5 6 7 8 9 10]
```

#### 切片结构 [x:y:z]
a[x:y:z] 切片内容 [x:y] 切片长度: y-x 切片容量:z-x  
x是可以忽略的，即a[:y:z]的长度为y,切片容量为z

### 容器map
声明和初始化： map[keyType]valueType，这块相当于一个类型
```go
var m1 map[string]float32 = map[string]float32{"c":5, "go":5.5}
// 或者
m2 := map[string]float32{"c":5, "go":5.5}
```

#### 通过make创建map
```go
// 创建了一个键类型为string,值类型为int的map
m1 := make(map[string]int)
```

#### map增删查改
```go
m1 := map[string]string{"key2": "value2", "key3": "value3"}
m1["key4"] = "value4" // 新增
fmt.Printf("增加key4:%v\n", m1)

m1["key2"] = "new_value2"
fmt.Printf("修改key2:%v\n", m1)

if val, ok := m1["key3"]; ok {
    fmt.Println("key3 has found", val)
}

delete(m1, "key3")
fmt.Println("删除key3", m1)

len := len(m1)
fmt.Printf("m1 len is %v\n", len)
```

#### map遍历
map遍历不能保证迭代返回次序，通常是随机结果
```go

m := make(map[int]int)
for i := 0; i < 10; i++ {
    m[i] = i
}
for j := 0; j < 2; j++ {
    fmt.Println("---------------------")
    for k, v := range m {
        fmt.Printf("key -> value : %v -> %v\n", k, v)
    }
}
```

### map和slice使用
```go
len := 10
items := make([]map[int]int, len)
for i := 0; i < len; i++ {
    items[i] = make(map[int]int)
    items[i][0] = i
    items[i][1] = i + 1
}

fmt.Println(items)
```

### channel管道
- 类似于unix管道（pipe）
- 线程安全，多个goroutine同时访问，不需要加锁
channel声明和初始化： chan type，这块相当于一个类型
```go
var ch0 chan int // 一个只能存放整数的名字叫ch0的管道channel
var ch1 chan int = make(chan int) // 通过make创建一个channel类型
```

### channel缓冲
通过make第二个参数可以指定channel缓冲大小，这个意义在于：
- 对于发送者来说，直到channel满时会阻塞，直到被接收者接受；
- 对于接收者来说，channel为空时，接收会阻塞，直到channel有数据


### channel发送和接受，关闭
```go
var ch chan int = make(chan int)
ch <- 1 // 发送数据到channel
x := <- ch // 从接受channel数据
close(ch) // 向关闭的channel发送数据会引起panic，接收数据会得到零值
```
- 执行关闭的channel，此时如果channel还有数据，则会在channel接收完毕后返回零值
```go
var ch0 chan int
ch0 = make(chan int, 11)
ch0 <- 99
for i := 0; i < 10; i++ {
    ch0 <- i
}
frist_ch, ok := <-ch0
if ok {
    fmt.Printf("fist ch is %v\n", frist_ch)
}

ch0 <- 10
close(ch0) // 关闭channel，若channel有值，则可以继续接收channel，但是不能在向channel发送新数据
for {
    var num int
    num, ok := <-ch0
    if ok == false {
        fmt.Println("has close")
        break
    }
    fmt.Println(num)
}

fmt.Println("all done")
```

或者
```go
close(ch0)
for num := range ch0 {
    fmt.Println(num)
}
```

#### 单向channel
```go
c := make(chan int, 3)

var send chan<- int = c // send-only
var recv <-chan int = c // receive-only

send <- 1
// <-send               // Error: receive from send-only type chan<- int

val, ok := <-recv
if ok {
    fmt.Println(val)
}
// recv <- 2           // Error: send to receive-only type <-chan int
```
- chan<- 只发送数到channel
- <-chan 只从channel接收数据

#### channel demo
```go
package main

import "fmt"

type Request struct {
	data []int
	ret  chan int
}

func NewRequest(data ...int) *Request {
	return &Request{data, make(chan int, 1)}
}

func Process(req *Request) {
	x := 0
	for _, i := range req.data {
		x += i
	}

	req.ret <- x
}

func main() {
	req := NewRequest(10, 20, 30)
	Process(req)
	fmt.Println(<-req.ret)
}
```

### 函数
声明方式： func 函数名称(参数 参数类型) (返回类型) {}
```go
func test(x, y int, s string) (int, string) {}
func test(x int) int {}
```
- 合并同类型参数，用逗号隔开，类型放后面
- 没有返回类型可以省略

#### 匿名函数
- 没有函数名
- 可以赋值给变量
- 可以作为一种类型，例如func() string
```go
package main

import (
	"fmt"
	"math"
)

func main() {
	// 普通使用
	getSprt := func(a float64) float64 {
		return math.Sqrt(a)
	}
	fmt.Println(getSprt(4))

	// 作为管道
	fc := make(chan func() string, 2)
	fc <- func() string { return "hello world" }
	fmt.Println((<-fc)())

	// 作为结构体的一个字段
	d := struct {
		fn   func() string
		name string
	}{
		fn:   func() string { return "struct function" },
		name: "good name",
	}
	fmt.Println(d.fn(), d.name)
}
```

#### 函数闭包
一个函数嵌套另一个函数，闭包中变量始终存在，以下面为例：
```go
package main

import "fmt"

func test() func() int {
	i := 0
	fn := func() int {
		i++
		fmt.Println(i)
		return i
	}
	return fn
}

func main() {
	a := test()
	a() // 1
	a() // 2
	a() // 3

	b := test()
	b() // 1
	b() // 2
	b() // 3
}
```
- a实际上指向了test()函数中的fn函数，每一次a()调用是直接指向fn函数，所以说，test函数中的i:=0只会在a:=test()执行一次
- a和b属于两个不同的环境

### defer延迟调用
- 最后执行
- 多个defer按照先进后出的方式执行
- 闭包中会先执行值，最后再调用结果
```go
package main

import (
	"fmt"
	// "time"
)

func main() {
	v := 1

	fn1 := func() {
		fmt.Println("fn1", v)
	}
	fn2 := func() {
		fmt.Println("fn2", v)
	}
	fn3 := func() func() {
		fmt.Println("闭包")
		return func() {
			fmt.Println("fn3")
		}
	}

	defer fn1()
	defer fn2()
	defer fn3()() // 当代码到这一步时，不会调用，但是会执行闭包内的值

	v = 2 // 改变了v的值，输出结果也跟着改变
	fmt.Println("runing")
}
```
输出结果：
```go
闭包
runing
fn3
fn2 2
fn1 2
```

### 异常处理
- panic抛出错误
- recover捕获错误
go通过panic抛出一个异常，然后在defer中通过recover捕获这个异常
```go
package main

import (
	"errors"
	"fmt"
)

var ErrDivByZero = errors.New("division by zero")

func div(x, y int) (int, error) {
	if y == 0 {
		return 0, ErrDivByZero
	}
	return x / y, nil
}

func main() {
	defer func() {
		fmt.Println(recover())
	}()

	switch z, err := div(10, 0); err {
	case nil:
		println(z)
	case ErrDivByZero:
		panic(err)
	}
}
```
### 错误处理
error是一个类型，类似int,float64

### 接口
一个类型实现了所有接口中定义的方法
实现的接口的类型，其i.(type)是接口名字

### 类型断言
- 参数是任意类型,如i interface{}
- i.(type) ,其中i是接口值，type是类型
type两种情况，具体类型和接口类型
- 具体类型：断言成功，可以获得i的具体值，失败则panic
- 接口类型：...

### 类型转换
显示 静态类型 底层类型 底层类型相同，也需要强制转换
- 普通类型向接口类型的转换是隐式的。
- 接口类型向普通类型转换需要类型断言。
  

### nil
nil可以和channel,func,interface,map,slice作比较


### 方法
类型， 该类型拥有的方法 叫方法的接受者是类型
类型只能是T或*T
值类型调用方法， 指针类型调用方法
无视类型调用方法，根据接受者类型操作内部
匿名字段

### 终端读取
从os.Stdin读取
fmt.Scanln(&a, &b) 终端多个值空格隔开，直到换行
fmt.SScan(string, format, &a, &b, &c)从字符串string按照format格式分别读取a,b,c三个值

### 缓冲IO
缓冲的IO的作用避免大数据块读写带来的开销

### windown和linux，mac交叉编译
```go
CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build gofile.go   // mac
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build gofile.go  // window
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build gofile.go    // window
```
- GOOS：目标可执行程序运行操作系统，支持 darwin，freebsd，linux，windows
- GOARCH：目标可执行程序操作系统构架，包括 386，amd64，arm

