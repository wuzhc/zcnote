## 自动注入
可以简单的通过在类的构造函数中对依赖进行类型提示来从容器中解析对象，控制器、事件监听器、中间件等都是通过这种方式。此外，你还可以在队列任务的 handle 方法中进行类型提示。



## 容器事件

服务容器在每一次解析对象时都会触发一个事件，可以使用 `resolving` 方法监听该事件： 

```php
$this->app->resolving(function ($object, $app) {
    // Called when container resolves object of any type...
});
    
$this->app->resolving(HelpSpot\API::class, function ($api, $app) {
    // Called when container resolves objects of type "HelpSpot\API"...
});
```

被解析的对象将会传递给回调函数，从而允许你在对象被传递给消费者之前为其设置额外属性。



## Di 依赖注入

一系列依赖，只要不是由内部生产（比如初始化、构造函数 __construct 中通过工厂方法、自行手动 new 的），而是由外部以参数或其他形式注入的，都属于依赖注入（DI）



## IoC 容器， 控制反转

容器提供了整个框架中需要的一系列服务

通过注册、绑定的方式向容器中



## **服务提供者**

 IoC 容器的部分中，提到了，一个类需要绑定、注册至容器中，才能被“制造”，对，一个类要被容器所能够提取，必须要先注册至这个容器。既然 Laravel 称这个容器叫做服务容器，那么我们需要某个服务，就得先注册、绑定这个服务到容器，那么提供服务并绑定服务至容器的东西，就是服务提供者（Service Provider）。

服务提供者主要分为两个部分，`register`（注册） 和 `boot`（引导、初始化）

`register` 负责进行向容器注册“脚本”，但要注意注册部分不要有对未知事物的依赖，如果有，就要移步至 `boot` 部分。



## **门面（Facade）**

门面提供了一个“静态”接口到服务容器中绑定的类

Route 类实际上是 `Illuminate\Support\Facades\Route` 通过 `class_alias()` 函数创造的别名而已，这个类被定义在文件 `vendor/laravel/framework/src/Illuminate/Support/Facades/Route.php`，`getFacadeAccessor` 方法返回了一个 `route`，这是什么意思呢？事实上，这个值被一个 `ServiceProvider` 注册过



## Application.singleton


