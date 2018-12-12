SSO单点登录
### 一般的登录原理是怎么样的
 首先http是无状态协议，为了限制资源的获取，需要有会话标识，处理方式为：服务端session_start,生成session_id保存客户端游览器中，保存用户登录信息到session中，之后客户端每次访问服务端时，都会带上PHPSESSID的cookie值，根据PHPSESSID读取到用户的session，检测session是否有登录信息，有则为合法访问，否则为非法访问
 ![sso](/data/wwwroot/doc/zcnote/images/sso.png)

### 如何实现多系统单点登录
我们知道会话标识依赖于session，而session依赖于cookie，但是cookie是有域名限制的，而我们的多系统一般是用不同的域名，即用户访问不同的域名，生成的PHPSESSID的值是不一样的，而我们要做的就是让不同域名能够共享同个会话，这里就需要借助第三方来保存游览器和第三方的会话，然后让不同的子系统重定向到第三方时，其实就相当于游览器直接和第三方交互，所以，只要在第三方保存游览器登录成功的会话，其他子系统重定向到第三方时，就能够共享同个会话，这样就可以实现单点登录了

### sso开源项目
- 一个系统一个broker
- 一个用户访问系统时，生成唯一标识token（只生成一次）
- 重定向到oss-server
- broker+tokern作为键，游览器PHPSESSIID作为值，保存到oss-server全局变量，其实就是建立游览器和系统的关联关系
- 只要是同个游览器访问oss-server，PHPSESSID都是一样的
- 若系统登录，则在oss-server设置用户信息session，$_SESSION['sso_user'] = $username

![](https://cloud.githubusercontent.com/assets/100821/9979965/c6b22e18-5f86-11e5-952d-e42fcae27327.png)

