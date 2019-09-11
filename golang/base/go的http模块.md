构建一个`http server`,包括注册路由，开启监听，处理连接，路由处理函数。
## 注册路由
多路复用器`mutilplexer`用于找到处理器函数`handler`,go有内置的`mutilplexer`,如`DefaultServerMux`
go中最重要是要理解`mutilplexer`和`handler`,`mutiplexer`基于`ServerMux`结构,同时也实现了`handler`接口

## handler
serverHttp  ->  handler函数,即`func(w http.ResponseWriter, r *http.Request)`
		-> handler对象,即实现serverHttp方法的结构对象
		-> handler处理器,即经过HandlerFunc结构包装,具有ServerHttp方法

## serverMux
`serverMux`会使用`handler`并调用其`serverHttp`方法处理请求并返回响应



Golang中一个完整的http服务，包括注册路由，开启监听，处理连接，路由处理函数。
ServeMux
multiplexer 多路复用器管理路由
ServeMux和handler处理器函数的连接桥梁就是Handler接口
ServeMux -> ServeHTTP处理handler -> request,response
ServeHTTP方法就是真正处理请求和构造响应的地方

ServeMux.handler
handler.ServeHTTP

```go
conn,err := net.Dail(net, addr string) (Conn,error)
```
建立连接，发送数据用conn.write,接受数据用conn.read

### 自定义http.Client
自定义请求用(*http.Client).Do(req *Request)
- *http.Client 创建客户端
```go
client := &http.Client{} 
```
- req *Request 创建请求
```go
req := http.NewRequest(method string, url string, body io.Reader)
```
例如自定义请求头部
```go
client := &http.Client{}
req := http.NewRequest("Get", "http://example.com", nil)
req.Header.Add("User-Agent", "Our Custom User-Agent)
resp,err := client.Do()
```

### 获取GET
```go
fmt.Println(r.URL.Query().Get("a"))
```

### 获取POST
- Form：存储了post、put和get参数，在使用之前需要调用ParseForm方法。
- PostForm：存储了post、put参数，在使用之前需要调用ParseForm方法。
- MultipartForm：存储了包含了文件上传的表单的post参数，在使用前需要调ParseMultipartForm方法。
#### r.Form
```go
r.ParseForm()
if len(r.Form["id"]) > 0
{
    fmt.Fprintln(w, r.Form["id"][0])
}
```
r.Form是url.Values类型，r.Form["id"]取到的是一个数组类型。因为http.request在解析参数的时候会将同名的参数都放进同一个数组里，所以这里要用[0]获取到第一个。
#### r.PostFormValue
```go
fmt.Fprintln(w, r.PostFormValue("id"))
```

### 获取COOKIE
```go
cookie, err := r.Cookie("id")
if err == nil {
    fmt.Fprintln(w, "Domain:", cookie.Domain)
    fmt.Fprintln(w, "Expires:", cookie.Expires)
    fmt.Fprintln(w, "Name:", cookie.Name)
    fmt.Fprintln(w, "Value:", cookie.Value)
}
```

