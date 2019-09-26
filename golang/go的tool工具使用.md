## 参考
- https://www.cnblogs.com/gao88/p/9849819.html

## pprof使用例子
```go
package main

import (
	"net/http"
	_ "net/http/pprof"
)

func main() {
	go func() {
		http.ListenAndServe("0.0.0.0:8899", nil)
	}()
	
	select{}
}
```
- 网址打开
```
http://127.0.0.1:8899/debug/pprof/heap
```
- console打开
```
go tool pprof http://127.0.0.1:8899/debug/pprof/heap
```
- 需要先切换项目的根目录
- 导出cpu需要执行的过程中才能导出

## 其他命令
```
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