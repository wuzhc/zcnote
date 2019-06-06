## 大概流程如下

![](/data/wwwroot/doc/zcnote/images/go/beego/beego日志模块源码.png)

## BeeLogger
```go
// BeeLogger is default logger in beego application.
// it can contain several providers and log message into all providers.
type BeeLogger struct {
	lock                sync.Mutex
	level               int
	init                bool
	enableFuncCallDepth bool
	loggerFuncCallDepth int
	asynchronous        bool
	prefix              string
	msgChanLen          int64
	msgChan             chan *logMsg
	signalChan          chan string
	wg                  sync.WaitGroup
	outputs             []*nameLogger
}
```
`BeeLogger`是beego默认日志管理器,用于控制日志level,深度,输出前缀,函数调用深度等等,`BeeLogger.outputs`存放适配器的日志处理提供者

## 日志提供者
位于beego/logs目录下,如console.go就是一个`provider`,每个go文件都执行初始化函数`init`,然后自动注册到`logs.adapters`
```go
// 注册日志提供者
func init() {
	Register(AdapterFile, newFileWriter)
}
```
所有日志提供者都实现了`logs.Logger`接口,之后调用`logs.Logger.WriteMsg()`方法写入日志

## 使用
```go
package main

import (
	"github.com/astaxie/beego/logs"
)

func main() {
	log := logs.NewLogger(10000)
	log.SetLogger("console")
	log.Debug("debug")
}
```








