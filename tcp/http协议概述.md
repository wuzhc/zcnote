## 参考
- [https://juejin.im/entry/5981c5df518825359a2b9476](https://juejin.im/entry/5981c5df518825359a2b9476)

![http时间图](https://user-gold-cdn.xitu.io/2017/8/3/016c54576b5ac1238fe4df64259e6cb4?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)  

## http延迟的原因
- 游览器阻塞,游览器对于用一个域名有连接限制,超过限制则后续请求会被阻塞
- DNS查询,通过DNS查询得到域名的IP
- 建立连接,每个连接都需要经过三次握手

## 长连接
在一个｀tcp｀连接上可以传送多个http请求和响应，｀http1.1｀默认开启｀Connection: keep-alive｀

## http和https区别
- https需要ca证书,https在应用层和传输层增加多了一层`SSL/TLS`层,传输的内容是明文
- http用80端口,https用443端口
![](https://user-gold-cdn.xitu.io/2017/8/3/b6daabee3a064fdc750cf0ff41c69871?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

## http2.0
https://juejin.im/entry/5981c5df518825359a2b9476
- 二进制协议格式解析
- 服务端主动推送,例如客户端请求index.html,服务端会把index.html中的js,css一起推送给客户端
- 多路复用,多个请求同时在一个连接上并行执行
- 现在的主流游览器只支持基于TLS部署的http2.0协议
