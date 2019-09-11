# go闭包详解
> 闭包是函数和它相关的引用环境组合而成的实体

## 函数变量
- 调动nil的函数变量会导致panic
- 函数和变量一样使用,函数变量的零值是nil,可以和nil值比较,但是两个函数变量不能比较
```go
func main() {
	f1 := func() string {
		return "hello world"
	}
	f2 := func() string {
		return "hello world"
	}
	if f1 == f2 {
		fmt.Println("yes")
	} else {
		fmt.Println("no")
	}
}
```
上面会报错
```
# command-line-arguments
./test.go:14:8: invalid operation: f1 == f2 (func can only be compared to nil)
```

## 循环闭包引用
**闭包对外层词法域变量是引用的**,在循环中需要注意这点
```go
var dummy [3]int
var f func()
for i := 0; i < len(dummy); i++ {
	f = func() {
		println(i)
	}
}
f() // 3
```
首先循环体中闭包函数i引用外层i的地址,外层i地址不变,值是不断变化,最后一次循环后i的值为2,然后执行`i++`,最终结果为3,所以输出结果为3


