所有 Laravel 路由都定义在位于 `routes` 目录下的路由文件中，这些文件通过框架自动加载，相应逻辑位于 `app/Providers/RouteServiceProvider` 类。

有时候还需要注册一个路由响应多个 HTTP 请求动作 —— 这可以通过 `match` 方法来实现。或者，可以使用 `any` 方法注册一个路由来响应所有 HTTP 请求动作：

```php
Route::match(['get', 'post'], 'foo', function () {
    return 'This is a request from get or post';
});
Route::any('bar', function () {
    return 'This is a request from any HTTP verb';
});
```

## **CSRF 保护**

在 `routes/web.php` 路由文件中所有请求方式为 `PUT`、`POST` 或 `DELETE` 的路由对应的 HTML 表单都必须包含一个 CSRF 令牌字段，否则，请求会被拒绝。

```html
<form method="POST" action="/profile">
    @csrf
    ...
</form>
```

如果我们不在 `VerifyCsrfToken` 中间件中排除对它的检查，那么就需要在表单提交中带上 `csrf_token` 字段



## 重定向路由

```php
Route::redirect('/here', '/there', 301);
```



## 视图路由

```php
Route::view('hello', 'hello', ['name' => '学院君']);
```

然后在 `resources/views` 目录下新建一个视图模板文件 `hello.blade.php`，并初始化视图模板代码如下：

```html
<h1>
    Hello, {{ $name }}!
</h1>
```



## 路由参数

```php
Route::get('posts/{post}/comments/{comment}', function ($postId, $commentId) {
    return $postId . '-' . $commentId;
});
```

根据上面的示例，路由参数需要通过花括号 `{}` 进行包裹并且是拼音字母，这些参数在路由被执行时会被传递到路由的闭包。路由参数名称不能包含 `-` 字符，如果需要的话可以使用 `_` 替代，比如如果某个路由参数定义成 `{post-id}` 则访问路由会报错，应该修改成 `{post_id}` 才行。路由参数被注入到路由回调/控制器取决于它们的顺序，与回调/控制器名称无关。

有必选参数就有可选参数，这可以通过在参数名后加一个 `?` 标记来实现，这种情况下需要给相应的变量指定默认值，当对应的路由参数为空时，使用默认值： 

```php
Route::get('user/{name?}', function ($name = 'John') {
    return $name;
});
```



## 正则约束

```php
Route::get('user/{id}/{name}', function ($id, $name) {
    // 同时指定 id 和 name 的数据格式
})->where(['id' => '[0-9]+', 'name' => '[a-z]+']);
```



## 命名路由

命名路由为生成 URL 或重定向提供了方便，实现起来也很简单，在路由定义之后使用 `name` 方法链的方式来定义该路由的名称： 

```php
Route::get('user/profile', function () {
    // 通过路由名称生成 URL
    return 'my url: ' . route('profile');
})->name('profile');
```

这样我们就可以通过以下方式定义重定向： 

```php
Route::get('redirect', function() {
    // 通过路由名称进行重定向
    return redirect()->route('profile');
});
```

如果命名路由定义了参数，可以将该参数作为第二个参数传递给 `route` 函数。给定的路由参数将会自动插入到 URL 中： 

```php
Route::get('user/{id}/profile', function ($id) {
    $url = route('profile', ['id' => 1]);
    return $url;
})->name('profile');
```

如果通过数组传入额外参数，这些键/值对将会自动添加到生成的 URL 查询字符串： 

```php
Route::get('user/{id}/profile', function ($id) {
    //todo
})->name('profile');
$url = route('profile', ['id' => 1, 'photos' => 'yes']); //photos是额外参数
// /user/1/profile?photos=yes 
```

如果你想要判断当前请求是否被路由到给定命名路由，可以使用 Route 实例上的 `named` 方法，例如，你可以从路由中间件中检查当前路由名称： 

```php
public function handle($request, Closure $next)
{
    if ($request->route()->named('profile')) {
        //
    }
    return $next($request);
}
```



## 路由分组

### 中间件

要给某个路由分组中定义的所有路由分配中间件，可以在定义分组之前使用 `middleware` 方法。中间件将会按照数组中定义的顺序依次执行： 

```php
Route::middleware(['first', 'second'])->group(function () {
    Route::get('/', function () {
        // Uses first & second Middleware
    });
    
    Route::get('user/profile', function () {
        // Uses first & second Middleware
    });
});
```

### 路由前缀

`prefix` 方法可以用来为分组中每个路由添加一个给定 URI 前缀，例如，你可以为分组中所有路由 URI 添加 `admin` 前缀 ： 

```php
Route::prefix('admin')->group(function () {
    Route::get('users', function () {
        // Matches The "/admin/users" URL
    });
});
```

这样我们就可以通过 `http://blog.test/admin/users` 访问路由了。

 

## 兜底路由

 使用 `Route::fallback` 方法可以定义一个当所有其他路由都未能匹配请求 URL 时所执行的路由。通常，未处理请求会通过 Laravel 的异常处理器自动渲染一个「404」页面，不过，如果你在 `routes/web.php` 文件中定义了 `fallback` 路由的话，所有 `web` 中间件组中的路由都会应用此路由作为兜底，当然，如果需要的话，你还可以添加额外的中间件到此路由： 

```php
Route::fallback(function () {
    //
});
```

注：兜底路由应该总是放到应用注册的所有路由的最后。



## 访问频率限制

频率限制器通过 `RateLimiter` 门面的 `for` 方法定义，该方法接收频率限制器名称和一个返回限制配置（会应用到频率限制器分配到的路由）的闭包作为参数：  

```php
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Support\Facades\RateLimiter;

RateLimiter::for('global', function (Request $request) {
    return Limit::perMinute(1000);
});
```

如果进入的请求量超过了指定的频率限制上限，则会自动返回一个状态码为 429 的 HTTP 响应，如果你想要自己定义这个频率限制返回的响应，可以使用 `response` 方法来定义： 

```php
RateLimiter::for('global', function (Request $request) {
    return Limit::perMinute(1000)->response(function () {
        return response('Custom response...', 429);
    });
});
```

由于频率限制器回调接收的是输入的 HTTP 请求实例，因此你可以基于用户请求或者认证用户动态构建相应的频率限制： 

```php
RateLimiter::for('uploads', function (Request $request) {
    return $request->user()->vipCustomer()
                ? Limit::none()
                : Limit::perMinute(100);
});
```

有时候你可能希望通过特定值进一步对频率限制进行细分。例如，你可能想要限定每分钟每个 IP 地址对应的用户只能访问给定路由不超过 100 次，要实现这个功能，你可以在构建频率限制时使用 `by` 方法： 

```php
RateLimiter::for('uploads', function (Request $request) {
    return $request->user()->vipCustomer()
                ? Limit::none()
                : Limit::perMinute(100)->by($request->ip());
});
```

如果需要的话，你可以为给定频率限制器配置返回频率限制数组，每个频率限制都会基于在数组中的顺序进行执行： 

```php
RateLimiter::for('login', function (Request $request) {
    return [
        Limit::perMinute(500),
        Limit::perMinute(3)->by($request->input('email')),
    ];
});
```

### 应用频率限制器到路由

访问频率限制器可以通过 `throttle` [中间件](https://laravelacademy.org/post/21971)应用到路由或者路由群组。`throttle` 中间件接收频率限制器的名称作为参数，然后再将其通过中间件的形式应用到路由即可： 

```php
Route::middleware(['throttle:uploads'])->group(function () {
    Route::post('/audio', function () {
        //
    });

    Route::post('/video', function () {
        //
    });
});
```



## 参考

<https://laravelacademy.org/post/21970>