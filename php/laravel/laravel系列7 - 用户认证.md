## 底层实现

在底层代码中，Laravel 的认证组件由「guards」和「providers」组成，Guard 定义了用户在每个请求中如何实现认证，例如，Laravel 通过 `session` guard 来维护 Session 存储的状态和 Cookie。

Provider 定义了如何从持久化存储中获取用户信息，Laravel 底层支持通过 [Eloquent](https://laravelacademy.org/post/22017) 和数据库查询构建器两种方式来获取用户，如果需要的话，你还可以定义额外的 Provider。

配置文件位于 `config/auth.php`

一个是从数据库存取用户数据，一个是把用户登录状态保存起来，在 Laravel 的底层实现中，通过 Provider 存取数据，通过 Guard 存储用户认证信息，前者主要和数据库打交道，后者主要和 Session 打交道



## **Laravel API 认证服务**

**Passport**

Passport 是一个 OAuth2 认证服务商，提供了多个 OAuth2「授权类型」以便颁发不同类型的访问令牌。总体来说，它是一个健全且复杂的 API 认证扩展包。不过，大多数应用并不需要 OAuth2 规范提供的复杂特性，这会让开发者和用户都感到困惑。此外，开发者也一直对如何使用 Passport 认证 SPA 应用和移动应用感到困扰。

**Sanctum**

Laravel Sanctum 是一个混合了 Web/API 认证的扩展包，可用于管理应用的整个认证流程。其背后的工作原理是对于一个基于 Sanctum 提供认证服务的应用，当服务端接收到请求时，Sanctum 会先判断请求是否包含引用了认证 Session 的会话 Cookie，如果没有通过会话 Cookie 认证，Sanctum 会继续检查请求是否包含 API 令牌，如果 API 令牌存在，则 Sanctum 会使用 API 令牌认证请求。想要了解更多关于这个处理流程的底层细节，请参考 [Sanctum 官方文档](https://laravelacademy.org/post/22036#toc-1)。 

**总结 & 如何选择**

如果应用提供了 API 接口，可以在 [Passport](https://laravelacademy.org/post/22035) 和 [Sanctum](https://laravelacademy.org/post/22036) 扩展包中任选其一提供 API 令牌认证。一般来说，优先使用 Sanctum，因为它位 API 认证、SPA 认证以及移动端认证提供了简单但完整的解决方案，包括对「作用域」和「权限」的支持。

Passport 可用于构建基于 OAuth2 规范的认证功能，比如我们要做开放平台，需要提供针对第三方应用的授权认证（比如微信、支付宝、QQ、微博之类的开发平台），则只能选择 Passport。

 

**指定一个 Guard**

 添加 `auth` 中间件到路由后，还可以指定使用哪个 guard 来实现认证， 指定的 guard 对应配置文件 `config/auth.php` 中 `guards` 数组的某个键 ：

```php
public function __construct()
{
    $this->middleware('auth:api');
}
```

如果没有指定的话，默认 guard 是 `web`，这也是配置文件中配置的： 

```php
'defaults' => [
    'guard' => 'web',
    'passwords' => 'users',
],
```





