`gmq`使用了`pprof`,你可以在通过`go tool pprof`来查看性能,默认端口是`8899`
```
# 堆内存
go tool pprof http://127.0.0.1:8899/debug/pprof/heap
# cpu
go tool pprof http://127.0.0.1:8899/debug/pprof/profle
# goroutine
go tool pprof http://127.0.0.1:8899/debug/pprof/goroutine
```

## 常用命令
```
web
top 10
list <func_name>
```
