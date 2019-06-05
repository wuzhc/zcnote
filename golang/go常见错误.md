## 内部匿名函数获取外部循环变量
```go
for i:=0; i<10;i++ {
    go func() {
       fmt.Println(i) // 都是输出10 
    }()
}
```
上面例子是错误的用法,v是被所有匿名函数共享,当循环遍历完毕时,v的值被更新,当goroutine读取v的值时,实际上读取到都是slice的最后一个元素,正确的做法是通过添加显示参数,如下:
```go
for i:=0;i<10;i++ {
    go func(v int) {
       fmt.Println(i)  
    }(v)
}
```

## goroutine泄露
```go
func test() {
	var c = make(chan int)
	var n = 10

	for i := 0; i <= n; i++ {
		go func(i int) {
			fmt.Println("send:", i)
			c <- i
		}(i)
	}

	for i := 0; i <= n; i++ {
		if i == 0 {
			return // 这里会有泄露问题
		}
		fmt.Println("recive:", <-c)
	}
}
```
泄露问题是如果有数据继续往c写数据,讲被阻塞,解决方法是创建缓冲通道

## go方法不支持默认参数值

## 不能用nil初始化无类型变量
```go
var x = nil
_ = x 
// 报错,use of untyped nil
```

## 切片赋值问题,最后逗号问题
```go
x := []int{
    1, 2, 3,
    4, 5, 6,
} // 注意新行时,上面最后一个值要加上逗号,否则会报syntax error: unexpected newline, expecting comma or }错误

y := []int {
    1,2,3,
    4,5,6} // 没有新行,不会报错
```

## 变量自增自减问题
```go
i := 1
i++ // 正确
++i // 不支持
j = i++ // 不支持
```
