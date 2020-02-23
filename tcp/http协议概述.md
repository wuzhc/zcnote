## 参考
- [https://juejin.im/entry/5981c5df518825359a2b9476](https://juejin.im/entry/5981c5df518825359a2b9476)
- [https://juejin.im/post/5cd0438c6fb9a031ec6d3ab2#heading-8](https://juejin.im/post/5cd0438c6fb9a031ec6d3ab2#heading-8)

![http时间图](https://user-gold-cdn.xitu.io/2017/8/3/016c54576b5ac1238fe4df64259e6cb4?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)  

## 无状态
http协议是无状态的，协议本身对于请求或响应之间的通信状态不进行保存，因此连接双方不能知晓对方当前的身份和状态，我们使用`cookie`来保持会话机制，浏览器会根据从服务器端的响应报文内`Set-Cookie首部字段信息`自动保持`Cookie`。而每次客户端发送 HTTP 请求，都会在请求报文中携带 Cookie，作为服务端识别客户端身份状态的标识。

## http延迟的原因
- 游览器阻塞,游览器对于用一个域名有连接限制,超过限制则后续请求会被阻塞
- DNS查询,通过DNS查询得到域名的IP
- 建立连接,每个连接都需要经过三次握手


## 串行连接
每次连接只能处理一个请求，收到响应后立即断开连接。HTTP/1.0 版本中每次HTTP通信后都要断开TCP连接，所以每个新的HTTP请求都需要建立一个新的连接。但在现在网站动则几十条HTTP请求的情况下，很容易达到浏览器请求上限，并且每次请求都建立新的tcp连接（每次都有三次握手四次挥别）极大的增加了通信开销。
总结：一个请求一个连接，容易达到游览器上限，建立连接需要三次握手，开销大

## 持久连接
持久连接（也叫长连接、长轮询）。一定时间内，同一域名下的HTTP请求，只要两端都没有提出断开连接，则持久保持TCP连接状态，其他请求可以复用这个连接通道。HTTP/1.1 实现并默认了所有连接都是持久连接，这样客户端发起多个HTTP请求时就减少了TCP握手造成的网络资源和通信时间的浪费。但是持久连接采用阻塞模式，下次请求必须等到上次响应返回后才能发起，如果上次的请求还没返回响应内容，下次请求就只能等着（就是常说的线头阻塞）
总结：一个`tcp`连接上可以传送多个http请求和响应，`http1.1`默认开启`Connection: keep-alive`，但是是阻塞性，新请求需要需要等待上一个请求响应胡才能发起

## 管道化持久连接
管道化则可以不用等待响应返回而发送下个请求并按顺序返回响应，现代浏览器并未默认开启管道化

## HTTP/2.0多路复用
 每个HTTP请求都有一个序列标识符，这样浏览器可以并发多个请求，服务器接收到数据后，再根据序列标识符重新排序成不同的请求报文，而不会导致数据错乱（ 细节参照此文）。同样，服务端也可以并发返回多个响应给浏览器，浏览器收到后根据序列标识重新排序并归入各自的请求的响应报文。并且同一个域名下的所有请求都复用同一个TCP连接，极大增加了服务器处理并发的上限

## WebSocket
WebSocket是HTML5提出的一种客户端和服务端通讯的全双工协议，由客户端发起请求，建立连接之后不仅客户端可以主动向服务端发送请求，服务端可以主动向客户端推送信息

## http和https区别
- https需要ca证书,https在应用层和传输层增加多了一层`SSL/TLS`层,传输的内容是明文
- http用80端口,https用443端口
![](https://user-gold-cdn.xitu.io/2017/8/3/b6daabee3a064fdc750cf0ff41c69871?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

![https://user-gold-cdn.xitu.io/2019/5/14/16ab4ec30a0062a3?imageView2/0/w/1280/h/960/format/webp/ignore-error/1](https://user-gold-cdn.xitu.io/2019/5/14/16ab4ec30a0062a3?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

## URI
- URI(Universal Resource Identifier：统一资源标识符)
- URL(Universal Resource Locator：统一资源定位符)
- URN(Universal Resource Name：统一资源名称)。

## HTTP/1.1
HTTP/1.1 引入了更多的缓存控制策略，如Entity tag，If-Unmodified-Since, If-Match, If-None-Match等
HTTP/1.1 允许范围请求，即在请求头中加入Range头部
HTTP/1.1 的请求消息和响应消息都必须包含Host头部，以区分同一个物理主机中的不同虚拟主机的域名
HTTP/1.1 默认开启持久连接，在一个TCP连接上可以传送多个HTTP请求和响应，减少了建立和关闭连接的消耗和延迟。

## HTTP/2.0


## http2.0
https://juejin.im/entry/5981c5df518825359a2b9476
- 二进制协议格式解析
- 服务端主动推送,例如客户端请求index.html,服务端会把index.html中的js,css一起推送给客户端
- 多路复用,多个请求同时在一个连接上并行执行
- 现在的主流游览器只支持基于TLS部署的http2.0协议

