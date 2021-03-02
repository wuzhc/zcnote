<https://laravelacademy.org/post/817>

门面提供了一个“静态”接口到服务容器中绑定的类



我们首先创建一个需要绑定到服务容器的 `Test` 类：

```PHP
class Test
{
    public function doSomething()
    {
        echo 'This is TestClass\'s method doSomething';
    }
}
```

然后创建一个静态指向 `Test` 类的门面类 `TestClass`： 

```PHP
class TestClass extends Facade
{
    protected static function getFacadeAccessor()
    {
        return 'test';
    }
}
```

接下来我们要在服务提供者中绑定 `Test` 类到服务容器，修改 `TestServiceProvider` 类如下： 

```php
<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use App\Services\TestService;
use App\Facades\Test;

class TestServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap the application services.
     *
     * @return void
     */
    public function boot()
    {

    }

    /**
     * Register the application services.
     *
     * @return void
     */
    public function register()
    {
        $this->app->singleton('test',function(){
            //return new TestService();
            return new Test;
        });

        $this->app->bind('App\Contracts\TestContract',function(){
            return new TestService();
        });
    }
}
```

