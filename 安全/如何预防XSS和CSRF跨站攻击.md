## 参考
- https://www.jianshu.com/p/e4c872be2cae

## csrf跨站伪造攻击
![https://img-blog.csdnimg.cn/20190515093459685.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3lpbnFpYW45OTk=,size_16,color_FFFFFF,t_70](https://img-blog.csdnimg.cn/20190515093459685.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3lpbnFpYW45OTk=,size_16,color_FFFFFF,t_70)
伪造用户身份进行请求
- 原理：请求中所有用户验证信息都存在于cookie中，利用用户的cookie来通过安全验证
- 解决办法是：在请求中放入黑客所不能伪造的信息，并且该信息不存在于 cookie 之中

## 解决方法
- 认证`http referer`字段
- 验证码
- 服务端生成随机token,客户端请求时候携带token,服务端接收请求并验证这个token

## xss跨站脚本攻击
原理：xss就是攻击者在web页面插入恶意的Script代码，当用户浏览该页之时，嵌入其中web里面的Script代码会被执行，从而达到恶意攻击用户的特殊目的。
### xss几种类型
- 反射型
- 存储型

