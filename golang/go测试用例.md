## `go test`工具
以`_test.go`结尾的文件不是`go build`编译的目标文件,而是`go test`编译目标,包括如下三种特殊函数
- 功能测试函数,以`Test`开头的函数,用来检测程序结果正确性,结果为`PASS`或`FAIL`
- 基准测试函数,以`Benchmark`开头的函数,用来汇报操作的平均执行时间
- 实例函数,以`Example`开头的函数,用来提供demo

## 功能测试函数
```go
func TestCos(t *testing.T) {/* ... */}
```
使用`t.Error()`报错,当某个条目报错时,`t.Error`可以继续往下执行,如果想要终止程序,可以用`t.Fatal()`
```go
package word
import (
	"testing"
)
func TestIsPalindrome(t *testing.T) {
	var tests = []struct {
		input string
		want  bool
	}{
		{"", true},
		{"a", true},
		{"aa", true},
		{"a man nam a", true},
		{"aba", true},
		{"hello", false},
	}
	for _, test := range tests {
		if got := IsPalindrome(test.input); got != test.want {
			t.Errorf("isPalindrome(%q)=%v", test.input, got)
		}
	}
}

```
### 运行测试用例:
```bash
# -v 可以输出包中每个测试用例的名称和执行时间
# -run=测试用例名称 可以指定要运行的测试用例 
go test -v $GOPATH/gopl/ch11/word1
```

## 白盒测试
- 黑盒测试, 包的内部逻辑是不透明的,对包了解仅通过公开的API和文档 ( 通过测试来检测每个功能是否都能正常使用,在完全不考虑程序内部结构和内部特性的情况下，对程序接口进行测试, 查看程序是否能适当地接收输入数据而产生正确的输出信息 )
- 白盒测试, 和黑盒测试不一样,主要对包内部进行测试

