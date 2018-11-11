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

