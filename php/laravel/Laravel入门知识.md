## laravel8 有哪些改变

- Laravel Jetstream
- 模型工厂类
- 迁移文件压缩
- 任务批处理
- 访问频率限制优化
- 队列功能优化
- 动态 Blade 组件
- Tailwind 分页视图
- 时间相关的测试辅助函数
- `artisan serve` 命令优化
- 事件监听器优化
- 其他 bug 修复和可用性优化

Laravel 项目默认将包含 `app/Models` 目录，用于存放 Eloquent 模型类，如果这个目录不存在，模型类还是会生成到 `app` 目录下。

Eloquent [模型工厂](https://laravelacademy.org/post/22029#toc-2)被重构为基于类进行管理，并且被优化为直接支持关联关系



## 哪些优势

- 文档齐全
- 扩展齐全
- 优雅，框架结构组织清晰（抽象了中间件，任务，服务等模块）
- 提供的artisan开发工具开发效率高
- 社区活跃完善
- 门面类提示不优化
- 强大的rest router:用简单的回调函数就可以调用,快速绑定controller和router
- blade模板:渲染速度更快

- **国外最火的框架，很优雅。（然并卵，特别是对于性能有高要求的公司更不会选）**
- **使用了大量设计模式，框架完全符合设计模式的五大基本原则（面向对象设计模式有5大基本原则：单一职责原则、开发封闭原则、依赖倒置原则、接口隔离原则、Liskov(替换)原则。），模块之间耦合度很低，服务容器可以方便的扩展框架功能以及编写测试。（可以算一点，但还是不能说明为什么使用对吧？）**
- **能快速开发出功能，自带各种方便的服务，比如数据验证、队列、缓存、数据迁移、测试、artisan 命令行等等，还有强大的 ORM 。（貌似这点可行，不过同样的功能，别的框架同样能做到）**

 



## 服务容器

服务容器是一个用于管理类依赖和执行依赖注入的强大工具，其实质是通过构造函数或者某些情况下通过「setter」方法将类依赖注入到类中

### 绑定

几乎所有的服务容器绑定都是在[服务提供者](https://laravelacademy.org/post/21457)中完成，注：如果一个类没有基于任何接口那么就没有必要将其绑定到容器。容器并不需要被告知如何构建对象，因为它会使用 PHP 的反射服务自动解析出具体的对象。

### **简单的绑定**

在一个服务提供者中，可以通过 `$this->app` 变量访问容器，然后使用 `bind` 方法注册一个绑定，该方法需要两个参数，第一个参数是我们想要注册的类名或接口名称，第二个参数是返回类的实例的闭包：

```php
$this->app->bind('HelpSpot\API', function ($app) {
    return new HelpSpot\API($app->make('HttpClient'));
});
```

注意到我们将容器本身作为解析器的一个参数，然后我们可以使用该容器来解析我们正在构建的对象的子依赖。

### **绑定一个单例**

```php
$this->app->singleton('HelpSpot\API', function ($app) {
    return new HelpSpot\API($app->make('HttpClient'));
});
```

### **绑定实例**

```php
$api = new HelpSpot\API(new HttpClient);
$this->app->instance('HelpSpot\API', $api);
```

### 扩展绑定

`extend` 方法允许对解析服务进行修改。例如，当服务被解析后，可以运行额外代码装饰或配置该服务。`extend` 方法接收一个闭包来返回修改后的服务：

```php
$this->app->extend(Service::class, function($service) {
    return new DecoratedService($service);
});
```

### 绑定接口到实现

服务容器的一个非常强大的功能是其绑定接口到实现。我们假设有一个 `EventPusher` 接口及其实现类 `RedisEventPusher` ，编写完该接口的 `RedisEventPusher` 实现后，就可以将其注册到服务容器： 

```php
$this->app->bind(
    'App\Contracts\EventPusher', 
    'App\Services\RedisEventPusher'
);
```

这段代码告诉容器当一个类需要 `EventPusher` 的实现时将会注入 `RedisEventPusher`，现在我们可以在构造器或者任何其它通过服务容器注入依赖的地方进行 `EventPusher` 接口的依赖注入： 

```php
use App\Contracts\EventPusher;

/**
 * 创建一个新的类实例
 *
 * @param  EventPusher  $pusher
 * @return void
 */
public function __construct(EventPusher $pusher){
    $this->pusher = $pusher;
}
```

### 上下文绑定

有时侯我们可能有两个类使用同一个接口，但我们希望在每个类中注入不同实现，例如，两个控制器依赖 `Illuminate\Contracts\Filesystem\Filesystem` [契约](https://laravelacademy.org/post/21459)的不同实现。Laravel 为此定义了简单、平滑的接口： 

```php
use Illuminate\Support\Facades\Storage;
use App\Http\Controllers\VideoController;
use App\Http\Controllers\PhotoControllers;
use Illuminate\Contracts\Filesystem\Filesystem;

$this->app->when(PhotoController::class)
    ->needs(Filesystem::class)
    ->give(function () {
        return Storage::disk('local');
    });

$this->app->when(VideoController::class)
    ->needs(Filesystem::class)
    ->give(function () {
        return Storage::disk('s3');
    });
```

### 服务容器解析

有很多方式可以从容器中解析对象，首先，你可以使用 `make` 方法，该方法接收你想要解析的类名或接口名作为参数：

```
$fooBar = $this->app->make('HelpSpot\API');
```

如果你所在的代码位置访问不了 `$app` 变量，可以使用辅助函数`resolve`：

```
$api = resolve('HelpSpot\API');
```

某些类的依赖不能通过容器来解析，你可以通过关联数组方式将其传递传递到 `makeWith` 方法来注入：

```
$api = $this->app->makeWith('HelpSpot\API', ['id' => 1]);
```

### 容器事件

服务容器在每一次解析对象时都会触发一个事件，可以使用 `resolving` 方法监听该事件： 

```php
$this->app->resolving(function ($object, $app) {
    // Called when container resolves object of any type...
});

$this->app->resolving(HelpSpot\API::class, function ($api, $app) {
    // Called when container resolves objects of type "HelpSpot\API"...
});
```





## 服务提供者

内核启动过程中最重要的动作之一就是为应用载入服务提供者，应用的所有[服务提供者](https://laravelacademy.org/post/21966)都被配置在 `config/app.php` 配置文件的 `providers` 数组中。首先，所有提供者的 `register` 方法被调用，然后，所有提供者被注册之后，`boot` 方法被调用。

服务提供者负责启动框架的所有各种各样的组件，比如数据库、队列、验证器，以及路由组件等，正是因为他们启动并配置了框架提供的所有特性，所以服务提供者是整个 Laravel 启动过程中最重要的部分。



## **启动目录**

`bootstrap` 目录包含了少许文件，`app.php` 用于框架的启动和自动载入配置，还有一个 `cache` 文件夹，里面包含了框架为提升性能所生成的文件，如路由和服务缓存文件。



## **路由目录**

`routes` 目录包含了应用定义的所有路由。Laravel 默认提供了四个路由文件用于给不同的入口使用：`web.php`、`api.php`、 `console.php` 和 `channels.php`。

`web.php` 文件包含的路由通过 `RouteServiceProvider` 引入，都被约束在 `web` 中间件组中，因而支持 Session、CSRF 保护以及 Cookie 加密功能，如果应用无需提供无状态的、RESTful 风格的 API，那么路由基本上都要定义在 `web.php` 文件中。

`api.php` 文件包含的路由通过 `RouteServiceProvider` 引入，都被约束在 `api` 中间件组中，因而支持频率限制功能，这些路由是无状态的，所以请求通过这些路由进入应用需要通过 token 进行认证并且不能访问 Session 状态。

`console.php` 文件用于定义所有基于闭包的控制台命令，每个闭包都被绑定到一个控制台命令并且允许与命令行 IO 方法进行交互，尽管这个文件并不定义 HTTP 路由，但是它定义了基于控制台的应用入口（路由）。 

`channels.php` 文件用于注册应用支持的所有事件广播频道。



## 契约

是指框架提供定义服务的接口， 例如，`Illuminate\Contracts\Queue\Queue` 契约定义了队列任务需要实现的方法。所有 Laravel 契约都有其[对应的 GitHub 库](https://github.com/illuminate/contracts)，这为所有有效的契约提供了快速入门指南，同时也可以作为独立、解耦的包被开发者使用。



## 何时使用契约

正如上面所讨论的，大多数情况下使用契约还是门面取决于个人或团队的喜好，契约和门面都可以用于创建强大的、测试友好的 Laravel 应用。只要你保持类的职责单一，你会发现使用契约和门面并没有什么实质性的差别。

但是，对契约你可能还是有些疑问。例如，为什么要全部使用接口？使用接口是不是更复杂？下面让我们从两个方面来扒一扒为什么使用接口：松耦合和简单。

类似于`golang`，接口有两种使用方式，一是作为参数，而是作为返回值；当作为参数时，我们可以对不同的类似做统一调用，例如发送短信和发送邮件，都有一个发送动作；当作为返回值时，我们可以不用关系具体类型，直接使用接口提供的方法即可。



## 门面

Laravel [门面](https://laravelacademy.org/post/21458)为 Laravel 服务的使用提供了便捷方式，所有的门面都定义在 `Illuminate\Support\Facades` 命名空间当中。



## 