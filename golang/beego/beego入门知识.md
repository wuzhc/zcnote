beego是一个`restful`框架

## MVC 架构介绍
![MVC 架构介绍](https://beego.me/docs/images/detail.png)

## beforeRouter和AfterStatic有什么区别
两个都是过滤器

## AppConfig和BConfig的区别

## bee命令工具
```bash
# 安装bee工具
go get github.com/beego/bee

# 创建项目(需要在$GOPATH/src下执行)
bee new <项目名>

# 创建api项目
bee api <项目名>

# 运行项目,可以自动监控文件(需要在$GOPATH/src/appname下执行)
bee run

# 打包zip
bee pack

# 自动生成模板文件,类似于yii的gii
bee generate model [modelname] [-fields="title:string,body:text"]
bee generate view [viewpath]
bee generate controller [controllerfile]
bee generate migration [migrationfile] [-fields="title:string,body:text"]
bee generate test [routerfile]
bee generate docs

# 运行所有未完成的迁移
bee migrate [-driver=mysql] [-conn="root:@tcp(127.0.0.1:3306)/test"]
# 回滚最新的迁移
bee migrate rollback [-driver=mysql] [-conn="root:@tcp(127.0.0.1:3306)/test"]
# 回滚所有的迁移
bee migrate reset [-driver=mysql] [-conn="root:@tcp(127.0.0.1)/test"]
# 回滚所有的迁移并重新执行
bee migrate refresh [-driver=mysql] [-conn="root:@tcp(127.0.0.1:3306)/test"]

# 生成dockerfile文件
bee dockerize -image="library/golang:1.6.4" -expose=9000
```

## 路由设置
在入口文件`main.go`文件里,导入路由包
```go
import _ "yourproject/routers"
```
路由文件位于`yourproject/routers/router.go`,该包只引入`init`函数,所有自己定义的`controller`都需要在这里注册路由
```go
func init() {
    beego.Router("/", &controllers.MainController{})
}
```
### 路由注册规则
```go
// 匹配/api或/api/123
beego.Router("/api/?:id", &controllers.WuzhcController{})
// 匹配/api/123
beego.Router("/api/:id", &controllers.WuzhcController{})
beego.Router("/api/:id([0-9]+)", &controllers.WuzhcController{})
beego.Router("/api/:id:int", &controllers.WuzhcController{})
// 匹配/api/xxx
beego.Router("/api/:username([\\w+]+)", &controllers.WuzhcController{})
beego.Router("/api/xxx:string", &controllers.WuzhcController{})
// 匹配/down/xxx/index.xml,其中:path匹配/xxx/index,:ext匹配xml
beego.Router("/down/*.*", &controllers.WuzhcController{})
```
### 自定义方法名
默认情况下,请求方法名对应请求method,如果需要自定义方法名,如下:
```go
beego.Router("/",&IndexController{},"*:Index")
```
- `*`表示所有请求方法
- index表示方法名
```go
// 是多个 HTTP Method 指向同一个方法的示例
beego.Router("/api",&RestController{},"get,post:ApiFunc")
// 不同的 method 对应不同的方法
beego.Router("/simple",&SimpleController{},"get:GetFunc;post:PostFunc")
```
### 自动匹配
```go
// /object/login调用 ObjectController 中的 Login 方法
beego.AutoRouter(&controllers.ObjectController{})
```
### 命名空间
```go
package routers
import (
	"my-web/controllers"
	"github.com/astaxie/beego/context"
	"github.com/astaxie/beego"
)
func init() {
	ns := beego.NewNamespace("v1",
		// 进入v1的条件,为false时,不会进入
		beego.NSCond(func(ctx *context.Context) bool {
			if ctx.Input.Domain() == "api.beego.me" {
				return false
			} else {
				return true
			}
		}),
		// 进入v1之前做一些东西
		beego.NSBefore(func(ctx *context.Context) {
			fmt.Println("helo world")
		}),
		// 相当于beego.Get
		beego.NSGet("/notallowd", func(ctx *context.Context) {
			ctx.Output.Body([]byte("not allowd"))
		}),
		// 相当于beego.Router
		beego.NSRouter("/hello", &controllers.WuzhcController{}),
		// 嵌套一个namespace
		beego.NSNamespace("/shop",
			beego.NSGet("/:id", func(ctx *context.Context) {
				ctx.Output.Body([]byte("shopinfo"))
			}),
		),
	)
	beego.AddNamespace(ns)
}
```

### 路由设置总结
- 接收参数问题,一般会选择正则匹配方式


## 控制器
### 默认请求
`beego`是一个`restful`框架,默认执行对应`req.Method`的方法,例如`GET METHOD`请求`Get()`方法
### 模板
- 渲染到模板的数据是需要保存在`this.Data`中
- `this.TplName`设置模板名称,默认是渲染模板`<controller>/<方法名>.tpl`
- `this.Ctx.WriteString("hello")`可以直接输出到游览器

## 静态文件
```go
// （在 /main.go 文件中 beego.Run() 之前加入）
// down1映射到download1目录
// download1目录和static目录同一级
beego.SetStaticPath("/down1", "download1") 
```
访问 URL http://localhost:8080/down1/123.txt 则会请求 download1 目录下的 123.txt 文件

## 配置
beego 默认会解析当前应用下的 `conf/app.conf` 文件。`beego.BConfig`为默认配置,`beego.APPConfig`为配置文件解析出来的
```go
beego.AppConfig.String("mysqluser")
```
### 设置开发环境,生成环境配置
配置文件可以设置`runmode ="dev"`,对应`[dev]`,如下:
```bash
appname = beepkg
httpaddr = "127.0.0.1"
httpport = 9090
runmode ="dev"
autorender = false
recoverpanic = false
viewspath = "myview"

[dev]
httpport = 8080
[prod]
httpport = 8088
[test]
httpport = 8888
​````
### 多个配置文件
在第一个配置文件中引入其他的配置文件,如下:
​```bash
include "app2.conf"
```
更多参考: [https://beego.me/docs/mvc/controller/config.md](https://beego.me/docs/mvc/controller/config.md)

## 数据库操作
### 使用问题
- 不要用驼峰法来命名表名,因为不好定义数据库表struct
- go 的链接池无法让两次查询使用同一个链接的

### 注册
```go
RegisterDriver
RegisterDataBase

// 参数4(可选)  设置最大空闲连接
// 参数5(可选)  设置最大数据库连接 (go >= 1.2)
maxIdle := 30
maxConn := 30
orm.RegisterDataBase("default", "mysql", "root:root@/orm_test?charset=utf8", maxIdle, maxConn)
```

### 注册模型
```go
RegisterModel
RegisterModelWithPrefix("tb_",new(User)) // 使用tb_表前缀
```

















