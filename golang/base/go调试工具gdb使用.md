## 编译
```bash
go build -gcflags "-N -l" hello.go
```
`-gcflags "-N -l"`阻止编译器使用内联函数和变量
- `-N`参数代表禁止优化
- `-l`参数代表禁止内联

## 开始调试
```go
gdb hello

# conn_query.go第12行打断点
b /data/wwwroot/go/src/github.com/flike/kingshard/proxy/server/conn_query.go:12

# 开始跑起程序
run

# 打印变量
p value

# 变量是什么类型
whatis value

# 跳到下一个断点
c

# 改变变量值
set variable count=9

# 继续从断点下一行执行
n
```

## 支持goroutines
```bash
source /usr/lib/go/src/runtime/runtime-gdb.py
```
### 使用
```bash
(gdb) info goroutines
  1 waiting  runtime.gopark
  2 waiting  runtime.gopark
  18 waiting  runtime.gopark
  19 waiting  runtime.gopark
* 20 syscall  runtime.notetsleepg
  21 waiting  runtime.gopark
  34 waiting  runtime.gopark
* 23 syscall  runtime.notetsleepg
```
`*`代表正在运行的协程
### 查看协程调用栈
```bash
goroutine n bt
```

## 常用命令行
- b <line_num|function_name> 打上断点(break 7 if n==6表示第七行条件n为6打上断点)
- l <start,end> list显示源代码
- n next下一行代码
- s step下一步代码
- c continue继续运行到下一个断点
- r run运行代码
- info b显示所有断点
- disable <num> 禁用断点
- delete <num> 删除断点
- p <var> print打印变量
- whatis <var> 显示变量类型
- q退出

## 参考
- https://blog.csdn.net/happyanger6/article/details/78724594/
