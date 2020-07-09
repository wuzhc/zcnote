> http协议又称超文本传输协议,应用于应用层

## 参考
- https://www.cnblogs.com/an-wen/p/11180076.html
- https://www.cnblogs.com/cr330326/p/9426018.htm
- https://www.cnblogs.com/taider/p/10716059.htmll
- https://juejin.im/entry/5981c5df518825359a2b9476
- http://www.52im.net/thread-2446-1-1.html

## TCP/IP
`tcp/ip`有七层,从上到下分别为,应用层->表示层->会话层->传输层->网络层->数据链路层->物理层,一般最上层合并为一层,即应用层
![https://upload-images.jianshu.io/upload_images/788498-60330f3a5d61b33f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240](https://upload-images.jianshu.io/upload_images/788498-60330f3a5d61b33f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## http协议
又叫超文本传输协议
- 请求协议报文结构包括请求行,请求头,请求数据
- 响应协议报文结构包括响状态行,首部行,实体

### http的工作原理是怎么样的？
客户端向服务器发送一个请求报文，请求报文包含请求行、请求头部，空行和请求数据。服务器以一个状态行作为响应，响应的内容包括状态行、响应头部，空行和响应数据。

### http请求报文
- 请求行
	- 请求方法
	- URI
	- 协议版本 
- 请求头部
- 空行
- 请求数据
![https://images2018.cnblogs.com/blog/877318/201804/877318-20180418160914403-902015370.png](https://images2018.cnblogs.com/blog/877318/201804/877318-20180418160914403-902015370.png)

### http响应报文
![https://images2018.cnblogs.com/blog/877318/201804/877318-20180418161014087-738990087.png](https://images2018.cnblogs.com/blog/877318/201804/877318-20180418161014087-738990087.png)
- 状态行
	- 协议版本
	- 状态码 200
	- 状态码短语 OK 
- 响应头部
- 空行
- 响应数据

### http请求方法
- `HEAD` 和`GET`一样，都是获取资源，不同的事，`HEAD`不需要返回请求报文中的响应数据
- `PUT` 向指定资源的位置上传其最新内容
- `OPTIONS` 这个方法可使服务器传回该资源所支持的所有HTTP请求方法。用'*'来代替资源名称，向Web服务器发送OPTIONS请求，可以测试服务器功能是否正常运作

## http2.0优势
- 支持并行发送,多个响应
- 支持二进制方式传递文件

## URL和URI有什么区别？
- URI(Universal Resource Identifier：统一资源标识符)
- URL(Universal Resource Locator：统一资源定位符)
- URN(Universal Resource Name：统一资源名称)。


## http常用状态码
https://www.cnblogs.com/taider/p/10716059.html
- 301 （永久移动）  请求的网页已被永久移动到新位置。服务器返回此响应时，会自动将请求者转到新位置。您应使用此代码通知搜索引擎蜘蛛网页或网站已被永久移动到新位置
- 302 （临时移动） 服务器目前正从不同位置的网页响应请求，但请求者应继续使用原有位置来进行以后的请求。会自动将请求者转到不同的位置。但由于搜索引擎会继续抓取原有位置并将其编入索引，因此您不应使用此代码来告诉搜索引擎页面或网站已被移动
- 304 （未修改） 自从上次请求后，请求的网页未被修改过。服务器返回此响应时，不会返回网页内容。
- 400（错误请求） 服务器不理解请求的语法。 
- 401 （身份验证错误） 需要授权验证。
- 405 （方法不被允许） 例如资源是需要GET，你用了POST请求则是不对的
- 414（请求的 URI 过长） 请求的 URI（通常为网址）过长，服务器无法处理。
- 500（服务器内部错误）  服务器遇到错误，无法完成请求。
- 503（服务不可用） 目前无法使用服务器（由于超载或进行停机维护）。通常，这只是一种暂时的状态。
- 504（网关超时）  服务器作为网关或代理，未及时从上游服务器接收请求。

## http是无状态协议
http不保存通信状态，一般使用cookie机制保存会话机制，游览器会根据从服务器的响应报文内的`set-cookie`首部字段信息设置cookie，而客户端每次发送http请求的时候，都会在报文中携带cookie，服务器根据cookie识别客户端的身份。

## http的keep-alive
如果一次请求就建立一个连接就太浪费，http1.1的keepalive通过复用连接来实现，一个tcp连接上可以传送多个http请求和响应，http1.1默认开启Connection: keep-alive，但是是阻塞性，新请求需要需要等待上一个请求响应胡才能发起

## http2.x有什么优势？
- 新的二进制格式，http1.1解析的是文本协议。
- 多路复用
- header压缩 http1.x每个请求都有重复请求头请求信息，http2.x压缩技术则是在游览器和服务器之间维护一个静态表和动态表，通过匹配把头部信息装换成表中的索引
- 服务端可以主动推送

## HTTP2.0的多路复用和HTTP1.X中的长连接复用有什么区别？
- http1.x一个连接可以处理多个http请求，当时多个http请求是串行执行的，只有等到上一个请求响应了，才能执行下一个请求
- http2.x多个请求可以同时在一个连接上并发执行
![https://user-gold-cdn.xitu.io/2017/8/3/718e6c0340dc43ff55af6f7f08965256?imageView2/0/w/1280/h/960/format/webp/ignore-error/1](https://user-gold-cdn.xitu.io/2017/8/3/718e6c0340dc43ff55af6f7f08965256?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

## http和https有什么区别
- http明文传输，https加密传输
- http端口一般是80，http是443
![https://user-gold-cdn.xitu.io/2017/8/3/b6daabee3a064fdc750cf0ff41c69871?imageView2/0/w/1280/h/960/format/webp/ignore-error/1](https://user-gold-cdn.xitu.io/2017/8/3/b6daabee3a064fdc750cf0ff41c69871?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

## https的通信过程是怎么样的？
http://www.52im.net/thread-2446-1-1.html
- client发送自己可以识别的加密算法列表给server
- server从算法中挑选一个，返回给 client, 并且返回证书给client
- client验证证书后，生成随机字符串并使用server的公钥加密后返回给server
- server确认之后，client和server的通信都使用随机字符串进行加解密
![https://img-blog.csdnimg.cn/20200103024126542.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpdXhpbmdyb25nNjY2,size_16,color_FFFFFF,t_70](https://img-blog.csdnimg.cn/20200103024126542.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpdXhpbmdyb25nNjY2,size_16,color_FFFFFF,t_70)

## 什么是数字证书？
数字签名 = ca机构秘钥加密(hash(申请信息))
数字证书 = 公钥+数字签名
