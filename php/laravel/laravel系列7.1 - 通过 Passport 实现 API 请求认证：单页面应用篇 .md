从后端剥离出去的前端应用无法通过 API 请求从客户端传递 Cookie 及 CSRF Token 到后端，也就无法通过 Session 实现用户认证。所以，我们需要寻求其它解决方案。

这个解决方案就是 OAuth，OAuth 是一个开发授权标准，允许通过授权的方式让第三方应用访问该用户在某一网站上存储的需要认证的资源，而无需将用户名和密码提供给第三方应用。



## 安装

```bash
composer require laravel/passport
php artisan migrate #创建oauth相关数据库表
php artisan passport:install 
```

最后一个命令会在 `storage` 目录下生成 `oauth-private.key` 和 `oauth-public.key`，分别包含 OAuth 服务的私钥和公钥，用于安全令牌的加密解密，然后在 `oauth_clients` 数据表中初始化两条记录，相当于注册了两个客户端应用，一个用于密码授权令牌认证，一个用于私人访问令牌认证。