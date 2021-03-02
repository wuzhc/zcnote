## 最简单的http服务
对于`golang`来说,创建一个http服务是轻而易举的事情,如下,我们创建了一个非常简单的http服务,监听8899端口,只提供一个接口返回hello world
```go
package main
import (
	"fmt"
	"net/http"
)
func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "hello world")
	})
	http.ListenAndServe(":8899", nil)
}
```
当你在游览器输入`http://127.0.0.1:8899`时,便能看到`hello world`的输出


## http服务
对于`golang`的http服务,我们主要理解两个对象,:
- `Handler`,它是请求的处理对象,`Handler`对象需要实现`ServeHTTP`方法,`ServeHTTP`执行的是我们的业务逻辑,一般我们定义的`func(w http.ResponseWriter, r *http.Request)`的方法需要经过`http.HandlerFunc`包装为`Handler`对象
- `ServeMux`,它相当于一个路由注册器,保存的请求路径`pattern`和`Handler`对象的map表,通过`pattern`找到对应的`Handler`对象,然后执行`Handler`对象的`ServeHTTP`方法
简单的说,http的执行对象是`handler`,而要成为`handler`对象.则必须实现`ServeHTTP`方法,例如`HandlerFunc`实现了`ServeHTTP`方法,所以它也是一个`handler`对象

## handler对象
```go
// Handler接口
type Handler interface {
	ServeHTTP(ResponseWriter, *Request)
}

// HandlerFunc实现了Handler接口
type HandlerFunc func(ResponseWriter, *Request)
func (f HandlerFunc) ServeHTTP(w ResponseWriter, r *Request) {
	f(w, r)
}
```
server从路由中找到`handler`对象,执行`handler`对象中的`ServeHTTP`方法,也就是说,要作为路由的`Handler`对象,需要实现`ServeHTTP`方法,有关handler如下:
![https://upload-images.jianshu.io/upload_images/11043-4ca34e67dff86c7e.jpeg?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp](https://upload-images.jianshu.io/upload_images/11043-4ca34e67dff86c7e.jpeg?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)
- handler函数,具有`func(w http.ResponseWriter, r *http.Requests)`签名的函数,需要经过`HandlerFunc`函数包装,否则不能作为路由的`Handler`对象,
- handler处理函数,经过`HandlerFunc`结构包装的handler函数，`HandlerFunc`实现了`ServeHTTP`接口方法的函数
- handler对象,实现了Handler接口`ServeHTTP`方法的结构

## 注册路由ServeMux
```go
type ServeMux struct {
    mu    sync.RWMutex
    m     map[string]muxEntry
    hosts bool 
}

type muxEntry struct {
    explicit bool
    h        Handler
    pattern  string
}

// ServeMux也拥有ServeHTTP方法,也就说ServeMux实现了Handler接口,即ServeMuX其实也是一个Handler对象,不过ServeMux的ServeHTTP方法不是用来处理request和respone，而是用来找到路由注册的handler
func (mux *ServeMux) ServeHTTP(w ResponseWriter, r *Request) {
	if r.RequestURI == "*" {
		if r.ProtoAtLeast(1, 1) {
			w.Header().Set("Connection", "close")
		}
		w.WriteHeader(StatusBadRequest)
		return
	}
	h, _ := mux.Handler(r)
	h.ServeHTTP(w, r)
}
```
如上,`ServeMux.m`保存了路由规则`pattern`以及对应的`Handler`处理对象,另外`ServeMux`也拥有`ServeHTTP`方法,也就说`ServeMux`实现了`Handler`接口,即`ServeMuX`其实也是一个`Handler`对象,不过ServeMux的ServeHTTP方法不是用来处理request和respone，而是用来找到路由注册的handler

```go
package main

import (
	"fmt"
	"net/http"
)

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "hello world")
	})
	mux.HandleFunc("/test", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "hello world")
	})
	http.ListenAndServe(":8899", mux)
}
```

## Server
```go
http.ListenAndServe(":8899",mux)
// 等价于
serv := &http.Server{
		Addr:    ":8899",
		Handler: mux,
	}
serv.ListenAndServe()
```
http.ListenAndServe源码如下:
```go
func ListenAndServe(addr string, handler Handler) error {
    server := &Server{Addr: addr, Handler: handler}
    return server.ListenAndServe()
}
```

## 来源
- 

## 参考
- https://www.jianshu.com/p/be3d9cdc680b


