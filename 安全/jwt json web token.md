# jwt（Json web token ）
> cookie+session认证机制为用户身份创建认证的凭证，这种模式在前后端分离中并不适用；因为需要解决跨域（域名或端口不同即为跨域）与session保持问题

## 跨域问题
当a异步ajax请求b接口，b接口设置session，此时session是属于哪个域名的？  
首先这里涉及到跨域问题，a域名不能直接调用b域名接口，解决方法一般客户端用jsonp或服务端用cors（跨域共享）；以cors为例，如下：
 ### 客户端
```js
$(function () {
        $.ajax({
            url: 'http://10.10.10.151:9502/test.php',
            xhrFields: {withCredentials: true}, // 注意这里
            method: 'get',
            success: function (res) {
                console.log(res)
            }
        });
    });
```
为什么要设置`xhrFields: {withCredentials: true}`？
如果没设置`xhrFields: {withCredentials: true}`的话，第一个请求后端接口可以成功返回，并且响应结果也有set-cookie；但是第二次请求的时候请求头没有带上这个cookie，跨域请求要带上cookie就必须设置`xhrFields: {withCredentials: true}`；[参考](http://www.cnblogs.com/zhangcybb/p/6594991.html)
### 服务端
```php
header('Access-Control-Allow-Origin:http://127.0.0.1:9501');
header("Access-Control-Request-Method:GET,POST");
header("Access-Control-Allow-Credentials: true" ); // 是否允许客户端携带cookie
```
上面的意思大概是允许127.0.0.1:9501域名请求，接受get,post请求，允许客户端携带cookie；重点说下`Access-Control-Allow-Credentials`；这个的意思是允许客户端请求时带上cookie，对应客户端的`xhrFields: {withCredentials: true}`；
*需要注意的是如果设置请求带有cookie，则`Access-Control-Allow-Origin`就不能设为星号*

## jwt
jwt同样用来认证用户身份，与session机制不同的是，session放在服务端，而jwt则放在客户端，每次请求时，客户端带上jwt生成的token，由服务端校验token，从而实现身份认证

### 有什么用？
跨域可以解决两个域名之间的交互，但是如果有多个域名呢？难道每个域名都需要执行一遍登录，每个域名都要设置一遍session，实际上UC等等同步登录都是这样的；

## 问题
- 客户端是指php服务端，而不是游览器，token过期怎么办
- jwt续签问题？难道客户端请求两次

jwt由三个部分组成，头部，有效载荷，签名

## 有效载荷（playload）
- iss：发行人
- exp：到期时间
- sub：主题
- aud：用户
- nbf：在此之前不可用
- iat：发布时间
- jti：JWT ID用于标识该JWT

## 参考
- [深入理解JWT的使用场景和优劣](https://mp.weixin.qq.com/s?__biz=MzI0NzEyODIyOA==&mid=2247483918&idx=1&sn=12683bae55f2ab1a8281ab398472362f&chksm=e9b58bc5dec202d385d1c1d861f7e0ff495296ed9387b32a8d01ae195eae03688e5aeebe6396&mpshare=1&scene=23&srcid=0505snLrWQ4JjwVW94oSMJaK#rd)