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

**默认情况下,不会执行性能测试函数,需要在命令行加上`-bench=.`**
```bash
go test -v -bench=. // . 执行所有性能函数,或者可以指定函数
```
- `-benchtime` 可以控制benchmark的运行时间
- `b.ReportAllocs()` ，在report中包含内存分配信息，例如结果是:
```
BenchmarkStringJoin1-4 300000 4351 ns/op 32 B/op 2 allocs/op
-4表示4个CPU线程执行；300000表示总共执行了30万次；4531ns/op，表示每次执行耗时4531纳秒；32B/op表示每次执行分配了32字节内存；2 allocs/op表示每次执行分配了2次对象。
```
-  StopTimer() 和 StartTimer() 暂停和开始计时  
```go
func Benchmark_TimeConsumingFunction(b *testing.B) {
	b.StopTimer() //调用该函数停止压力测试的时间计数

	//做一些初始化的工作,例如读取文件数据,数据库连接之类的,
	//这样这些时间不影响我们测试函数本身的性能

	b.StartTimer() //重新开始时间
	for i := 0; i < b.N; i++ {
		Division(4, 5)
	}
}
```

### 导出pprof文件
```bash
# 导出
go test -bench=. -cpuprofile profile_cpu.out
go test -bench=. -memprofile profile_mem.out
# 进入pprof
go tool pprof skiplist.test profile_cpu.out
# 导出svg
go tool pprof -svg profile_cpu.out > profile_cpu.svg
# 导出火焰图
go-torch -b profile_cpu.out -f profile_cpu.torch.svg
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

