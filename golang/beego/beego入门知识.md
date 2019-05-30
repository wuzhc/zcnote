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

# 迁移(还不知道怎么用,估计和gii一样)
bee migrate [-driver=mysql] [-conn="root:@tcp(127.0.0.1:3306)/test"]

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
beego.SetStaticPath("/down1", "download1")
```
访问 URL http://localhost:8080/down1/123.txt 则会请求 download1 目录下的 123.txt 文件

