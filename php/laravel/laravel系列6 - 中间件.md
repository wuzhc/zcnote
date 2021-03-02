## 定义中间件

所有的中间件都位于 `app/Http/Middleware` 目录下。

```php
php artisan make:middleware CheckAge
```



## 请求之前/之后的中间件

```php
class BeforeMiddleware
{
    public function handle($request, Closure $next)
    {
        //请求之前执行
        return $next($request);
    }
}

class AfterMiddleware
{
    public function handle($request, Closure $next)
    {
        $response = $next($request);
        //请求之后执行
        return $response;
    }
}
```



## 注册中间件

### 全局中间件

如果你想要定义的中间件在每一个 HTTP 请求时都被执行，只需要将相应的中间件类添加到 `app/Http/Kernel.php` 的数组属性 `$middleware` 中即可 



### 分配中间件到指定路由

首先应该在 `app/Http/Kernel.php` 文件中分配给该中间件一个 `key`，只需要将其追加到后面并为其分配一个 `key`

```php
// 在 App\Http\Kernel 类中...
/**
 * 应用的路由中间件列表
 * 这些中间件可以分配给路由组或者单个路由
 * @var array
 */
protected $routeMiddleware = [
    ...
    'age' => \App\Http\Middleware\CheckAge::class,
];

// 在web.php设置
Route::get('/hello', function () {
})->middleware('age');
```



需要阻止中间件被应用到群组中的单个路由，这可以通过使用 `withoutMiddleware` 方法来实现

```php
use App\Http\Middleware\CheckAge;

Route::middleware([CheckAge::class])->group(function () {
    Route::get('/', function () {
        //
    });

    // 该路由不会应用 CheckAge 中间件
    Route::get('admin/profile', function () {
        //
    })->withoutMiddleware([CheckAge::class]);
});
```



### 中间件组

将相关中间件分到同一个组里可以通过使用 HTTP Kernel 提供的 `$middlewareGroups` 属性实现

```php
//app/Http/Kernel.php
protected $middlewareGroups = [
    'test' => [
        Test::class,
        Test2::class
    ]
];

//routes/web.php
Route::get('/user', function () {
    return '中间件';
})->middleware('test');
```



### 中间件排序

可以在 `app/Http/Kernel.php` 文件中通过 `$middlewarePriority` 属性来指定中间件的优先级

```php
protected $middlewarePriority = [
    \Illuminate\Session\Middleware\StartSession::class,
    \Illuminate\View\Middleware\ShareErrorsFromSession::class,
    \Illuminate\Contracts\Auth\Middleware\AuthenticatesRequests::class,
    \Illuminate\Routing\Middleware\ThrottleRequests::class,
    \Illuminate\Session\Middleware\AuthenticateSession::class,
    \Illuminate\Routing\Middleware\SubstituteBindings::class,
    \Illuminate\Auth\Middleware\Authorize::class,
];
```



### 终端中间件

终端中间件，可以理解为一个善后的后台处理中间件。有时候中间件可能需要在 HTTP 响应发送到浏览器之后做一些工作，比如，Laravel 内置的 `session` 中间件会在响应发送到浏览器之后将 Session 数据写到存储器中，为了实现这个功能，需要定义一个终止中间件并添加 `terminate` 方法到这个中间件：

```php
<?php
    
namespace Illuminate\Session\Middleware;
    
use Closure;
    
class StartSession
{
    public function handle($request, Closure $next)
    {
        return $next($request);
    }
    
    public function terminate($request, $response)
    {
        // 存储session数据...
    }
}
```

定义了一个终端中间件之后，还需要将其加入到 `app/Http/Kernel.php` 文件的全局中间件列表中。

当调用中间件上的 `terminate` 方法时，Laravel 将会从[服务容器](https://laravelacademy.org/post/21965)中取出一个该中间件的新实例，如果你想要在调用 `handle` 和 `terminate` 方法时使用同一个中间件实例，则需要使用容器提供的 `singleton`方法以单例的方式将该中间件注册到容器中。通常这需要在 `AppServiceProvider.php` 的 `register`方法中完成：

```php
use App\Http\Middleware\TerminableMiddleware;
    
/**
 * Register any application services.
 *
 * @return void
 */
public function register()
{
    $this->app->singleton(TerminableMiddleware::class);
}
```

