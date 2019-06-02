### go特性
- 1.自动垃圾回收。
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
设置路径如下：
```bash
vi ~/.bashrc
export GOROOT=/usr/lib/go
export GOPATH=/data/wwwroot/go
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
export PATH=$PATH:/opt/php7/bin
```

### 命令
- go run：go run 编译并直接运行程序，它会产生一个临时文件（但不会生成 .exe 文件），直接在命令行输出程序执行结果，方便用户调试。
- go build：go build 用于测试编译包，主要检查是否会有编译错误，如果是一个可执行文件的源码（即是 main 包），就会直接生成一个可执行文件。
- go install：go install 的作用有两步：第一步是编译导入的包文件，所有导入的包文件编译完才会编译主程序；第二步是将编译后生成的可执行文件放到 bin 目录下（$GOPATH/bin），编译后的包文件放到 pkg 目录下（$GOPATH/pkg）。

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
import "shorturl/model 	加载gopath/src/shorturl/model模块（绝对路径）
import f "fmt"		导入fmt，并给他启别名ｆ
import . "fmt" 		将fmt启用别名"."，这样就可以直接使用其内容，而不用再添加fmt。
	如fmt.Println可以直接写成Println
import  _ "fmt" 	表示不使用该包，而是只是使用该包的init函数，并不显示的使用该包的其他内容。
	注意：这种形式的import，当import时就执行了fmt包中的init函数，而不能够使用该包的其他函数。
```
Note: 包路径为src目录下，不要用相对路径

### 导入项目的包
- 导入都是以src为相对路径,例如`import "src/gopl/thumbnail"`
- 一个`package`一个目录,`package`不能包括`main`函数

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

### string类型
string在go底层中是用byte实现的,具体如下:
```go
s:="hello中国"
len:=len(s) //输出长度11,因为中国换成字节为6个

for k,v:=range s{
    fmt.Println("key:",k,"value:",v) //range时,自动转换为[]byte类型
}
```

### struct类型
类似C语言的结构体，用来定义复杂的数据类型,使用的时候可以想象为类
- 结构体是值类型，如果两个结构体每个字段都是可比较的(int,string)，且变量字段相等，则说明两个结构体相等。如果结构体中包含不可比较字段(map)，则结构体是不可比较的。
- 如果是指针,即时值相等,结构体也不相等
- 和其他可比较类型一样,可比较的结构体类型都可以作为`map`的键
```go
package main

import (
	"fmt"
)

type Stu struct {
	name string
}

func NewStu(name string) Stu {
	return Stu{name}
}

func NewStuPtr(name string) *Stu {
	return &Stu{name}
}

func main() {
	stu1 := NewStu("wuzhc")
	stu2 := NewStu("wuzhc")
	fmt.Println(stu1 == stu2) // true

	stu3 := NewStuPtr("wuzhc")
	stu4 := NewStuPtr("wuzhc")
	fmt.Println(stu3 == stu4) // false
}
```

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

`make`分配内存之后,返回一个非`nil`的值,这在并发的时候需要关注一下,例如:
```go
var m map[string]int
func getN(key string) int {
    if m==nil {
        m=make(map[string]int)
        m["t1"] = 1
        m["t2"] = 2
    }
    return m["t2"]    
}
```
当多个`goroutine`并发执行时会有问题,因为m不为nil时不代表m已经初始化好,可以用`sync.Once`延迟初始化

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

#### make初始化切片
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
- 和`map`一样,使用`make`创建的数据结构引用,当复制或传参时,都是引用,即引用同一份数据结构,和其他应用类型一样,通道的默认值为`nil`
- 同种类型通道可以`==`比较
- 通道可以连接`goroutine`
channel声明和初始化： chan type，这块相当于一个类型
```go
var ch0 chan int // 一个只能存放整数的名字叫ch0的管道channel
var ch1 chan int = make(chan int) // 通过make创建一个channel类型
```

### channel缓冲
通过make第二个参数可以指定channel缓冲大小，这个意义在于：
- 对于发送者来说，直到channel满时会阻塞，直到被接收者接受；
- 对于接收者来说，channel为空时，接收会阻塞，直到channel有数据

### 无缓冲通道
无缓冲通道即同步通道,它可以同步两个`goroutine`,当一个`goroutine`读取时,通道没有数据会阻塞,直到另一个`goroutine`写入数据,相反也一样

### 通道的关闭
- 通道关闭是发送方调用,即写入通道后可以调用`close`关闭,但是,不能在接收方调用`close`关闭通道(这个在单向通道时是有区别的)
- 关闭通道之后,如果通道有数据可以继续接收,到不能往通道写数据
```go
var c = make(chan int)
for {
    v, ok := <-c
    if !ok {
        break // 通道关闭并且已经读完,需要配合close(channel)使用
    }    
}
close(c)

// 或者用range迭代通道
for v:= range <-c {
    // do something
}
close(c)
```

### 错误提示: fatal error: all goroutines are asleep - deadlock!
>出错信息的意思是： 
在main goroutine线，期望从管道中获得一个数据，而这个数据必须是其他goroutine线放入管道的 
但是其他goroutine线都已经执行完了(all goroutines are asleep)，那么就永远不会有数据放入管道。 
所以，main goroutine线在等一个永远不会来的数据，那整个程序就永远等下去了。 
这显然是没有结果的，所以这个程序就说“算了吧，不坚持了，我自己自杀掉，报一个错给代码作者，我被deadlock了”

总的来说就是通道用于多个`goroutine`通信,如果只剩一个协程`main goroutine`,就没有意义了

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

#### 单向通道类型
双向通道是可以转为单向通道
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

### 缓存通道
缓存通道通过`make`函数的容量参数来设置,例如:`ch = make(chan string, 3)`,相反,可以通过`cap(ch)`获取缓冲区的容量,`len(ch)`可以获取通道内元素的个数

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

### 反射reflect
反射机制就是在运行时动态的调用对象的方法和属性,官方自带的reflect包就是反射相关的,reflect可以识别interface{}底层具体类型和具体值
- reflect.Type                     // 具体类型
- reflect.Value                    // 具体值
- reflect.TypeOf(obj)              // 返回具体类型 
- reflect.ValueOf(obj)             // 返回具体值
- reflect.TypeOf(obj).Kind()       // 返回具体类型的类别
- reflect.ValueOf(obj).Numfield()  // 具体值有多少个字段
- reflect.ValueOf(obj).Field(num)  // 第num个字段的值
- Int()                            // 将值转为int
- String()                         // 将值转为string
```go
package main

import (
	"fmt"
	"reflect"
)

type Order struct {
	ID   int
	Name string
	Age  int
}

func (o Order) Create() {
	fmt.Println("生成订单")
}

func main() {
	order := Order{1, "Allen.Wu", 25}
	t := reflect.TypeOf(order)
	v := reflect.ValueOf(order)
	k := t.Kind()
	fmt.Println("reflect.Type=", t)
	fmt.Println("reflect.Value=", v)
	fmt.Println("t.Kind()=", k)

	fmt.Println("reflect.ValueOf().NumField()=", v.NumField())
	fmt.Println("reflect.ValueOf().Field(i)=", v.Field(0))
	fmt.Println("reflect.ValueOf().Field(i).Interface()=", v.Field(0).Interface())
	fmt.Println("reflect.TypeOf().NumField()=", t.NumField())
	fmt.Println("reflect.TypeOf().Field(i)=", t.Field(0))
	fmt.Println("reflect.TypeOf().Field(i).Name=", t.Field(0).Name)
	fmt.Println("reflect.TypeOf().Field(i).Type=", t.Field(0).Type)
	fmt.Println("reflect.TypeOf().NumMethod()=", t.NumMethod())
	fmt.Println("reflect.TypeOf().Method(i)=", t.Method(0))
	fmt.Println("reflect.TypeOf().Method(i).Name=", t.Method(0).Name)
	fmt.Println("reflect.TypeOf().Method(i).Type=", t.Method(0).Type)

	if reflect.TypeOf(order).Kind() == reflect.Struct {
		v := reflect.ValueOf(order)
		fmt.Println("number of fields:", v.NumField())
		for i := 0; i < v.NumField(); i++ {
			fmt.Printf("Field:%d type:%T value:%v v:%v \n", i, v.Field(i), v.Field(i), v.Field(i).Interface())
		}
	}
}


```
结果如下：
```
reflect.Type= main.Order
reflect.Value= {1 Allen.Wu 25}
t.Kind()= struct
reflect.ValueOf().NumField()= 3
reflect.ValueOf().Field(i)= 1
reflect.ValueOf().Field(i).Interface()= 1
reflect.TypeOf().NumField()= 3
reflect.TypeOf().Field(i)= {ID  int  0 [0] false}
reflect.TypeOf().Field(i).Name= ID
reflect.TypeOf().Field(i).Type= int
reflect.TypeOf().NumMethod()= 1
reflect.TypeOf().Method(i)= {Create  func(main.Order) <func(main.Order) Value> 0}
reflect.TypeOf().Method(i).Name= Create
reflect.TypeOf().Method(i).Type= func(main.Order)
number of fields: 3
Field:0 type:reflect.Value value:1 v:1 
Field:1 type:reflect.Value value:Allen.Wu v:Allen.Wu 
Field:2 type:reflect.Value value:25 v:25
```
- Order的字段首字母需要大写，否则v.Field(0).Interface()报错
- Field是struct结构才有的，像float64，int是没有这个的
- 类型转换，struct结构可以通过v.Field(0).Interface()获得结果，而float64则需要通过v.Interface().(float64)获得结果
- reflect.TypeOf(n)等效于reflect.ValueOf(n).Type()

#### reflect类型
- reflect.Int
- reflect.String
- reflect.Struct
- reflect.Func 可以调用.Call()  

#### reflect具体类型转换
通过reflect.ValueOf(t interface{})可以获得类型为reflect.Value的值，如果需要进一步使用该值，需要进行转换，如下：
强制类型转换用Interface().(type)；格式为：reflect.ValueOf(t).Interface().(type)
```go
package main

import (
	"fmt"
	"reflect"
)

func main() {
	var n float64 = 1.23456
	value := reflect.ValueOf(n)
	fmt.Printf("类型是%T，值是%v \n", value, value)

	var v float64
	v = value.Interface().(float64)
	fmt.Printf("类型是%T，值是%f \n", v, v)
}
```
输出结果：
```
类型是reflect.Value，值是1.23456 
类型是float64，值是1.234560 
```
需要注意的是，转换的时候需要区分指针和值，如value.Interface().(float64)和value.Interface().(*float64)是不一样的

#### 通过反射调用方法
reflect.ValueOf(n).MethodByName("funcName").Call([]reflect.Value)流程如下：
- 获得reflect.Value反射类型对象
- 通过reflect.Value调用MethodByName()获得reflect.Value方法名
- 参数格式[]reflect.Value
- 调用Call
```go
package main

import (
	"fmt"
	"reflect"
)

type Order struct {
	Id   int
	Name string
}

func (o Order) Handle(code string) {
	fmt.Println("处理订单号：", code)
}

func (o Order) Create() {
	fmt.Println("创建订单成功")
}

func main() {
	var order = Order{1, "淘宝"}
	getValue := reflect.ValueOf(order)

	// 没有参数
	createMethod := getValue.MethodByName("Create")
	args := make([]reflect.Value, 0)
	createMethod.Call(args)

	// 有参数
	handleMethod := getValue.MethodByName("Handle")
	args2 := []reflect.Value{reflect.ValueOf("xxxxdeewew33242342343333")}
	handleMethod.Call(args2)
}
```
