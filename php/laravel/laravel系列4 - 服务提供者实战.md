## 服务提供者实战

### 1. 定义服务

```php
class TestService implements TestContract
{
    public function callMe($controller)
    {
        dd('Call Me From TestServiceProvider In '.$controller);
    }
}
```

### 2. 创建服务提供者

创建服务提供者将我们上面定义的服务注册到容器中

```bash
php artisan make:provider TestServiceProvider
```

该命令会在`app/Providers`目录下生成一个`TestServiceProvider.php`文件，我们编辑该文件内容如下： 

```php
class TestServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap the application services.
     *
     * @return void
     */
    public function boot()
    {
        //
    }

    /**
     * Register the application services.
     *
     * @return void
     * @author LaravelAcademy.org
     */
    public function register()
    {
        //使用singleton绑定单例
        $this->app->singleton('test',function(){
            return new TestService();
        });

        //使用bind绑定实例到接口以便依赖注入
        $this->app->bind('App\Contracts\TestContract',function(){
            return new TestService();
        });
    }
}
```

### 3. 注册服务提供者

定义完服务提供者类后，接下来我们需要将该服务提供者注册到应用中，很简单，只需将该类追加到配置文件`config/app.php`的`providers`数组中即可：

```
'providers' => [

    //其他服务提供者

    App\Providers\TestServiceProvider::class,
],
```

### 4、测试服务提供者

```bash
php artisan make:controller TestController
```