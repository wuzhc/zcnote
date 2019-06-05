## `go test`工具
以`_test.go`结尾的文件不是`go build`编译的目标文件,而是`go test`编译目标,包括如下三种特殊函数
- 功能测试函数,以`Test`开头的函数,用来检测程序结果正确性,结果为`PASS`或`FAIL`
- 基准测试函数,以`Benchmark`开头的函数,用来汇报操作的平均执行时间
- 实例函数,以`Example`开头的函数,用来提供demo

## 功能测试函数
```go
func TestXXX(t *testing.T) {/* ... */}
```
- 调用`t.Error()`或`t.Errorf()`方法记录日志并标记测试失败
- 调用`t.Fatal()`和`t.Fatalf()`方法，在某条测试用例失败后就跳出该测试函数
- 调用`t.Skip()`和`t.Skipf()`方法，跳过某条测试用例的执行
- 调用`t.Parallel()`标记需要并发执行的测试函数
```go
func TestV(t *testing.T) {
	t.Error("xxxx") // 调用t.Error记录错误日志
	t.Fatal("vvvv") // 调用t.Fatal失败后退出该测试函数
}
```
#### 执行命令
```bash
go test -v -run <func_name> // 指定测试函数名称
```

## 性能测试
```go
func BenchmarkXXX(b *testing.B) {/****/}
```
#### 执行命令
默认情况下,不会执行性能测试函数,需要在命令行加上`-bench=.`
```bash
go test -v -bench=. // . 执行所有性能函数,或者可以指定函数
```

## 示例函数
```go
func ExampleXXX() {/*****/}
// Output:
```
需要指定`Output`,示例函数通过结果和`Output`对比来判断结果
```go
func Example_array() {
	v := []int{1, 2, 3, 4}
	Display("v", v)

	// Output:
	// v[0]=1
	// v[1]=2
	// v[2]=3
	// v[3]=4
}
```

## 白盒测试
- 黑盒测试, 包的内部逻辑是不透明的,对包了解仅通过公开的API和文档 ( 通过测试来检测每个功能是否都能正常使用,在完全不考虑程序内部结构和内部特性的情况下，对程序接口进行测试, 查看程序是否能适当地接收输入数据而产生正确的输出信息 )
- 白盒测试, 和黑盒测试不一样,主要对包内部进行测试

