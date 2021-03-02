Laravel 事件提供了简单的观察者模式实现，允许你订阅和监听应用中的事件。事件类通常存放在 `app/Events` 目录，监听器存放在 `app/Listeners`。

当事件发生时，会执行监听器响应的逻辑。



## 注册事件/监听器

Laravel 自带的 `EventServiceProvider` 为事件监听器注册提供了方便之所。其中的 `listen` 属性包含了事件（键）和对应监听器（值）数组。

```php
   protected $listen = [
        Registered::class => [
            SendEmailVerificationNotification::class,
        ],
        'App\Events\OrderShipped' => [
            'App\Listeners\SendShipmentNotification',
        ],
    ];
```





## 生成事件/监听器类

只需简单添加监听器和事件到 `EventServiceProvider` 然后运行 `event:generate` 命令。该命令将会生成罗列在 `EventServiceProvider` 中的所有事件和监听器。当然，已存在的事件和监听器不会被重复创建：

```bash
php artisan event:generate
```



## 手动注册事件

通常，我们需要通过 `EventServiceProvider` 的 `$listen` 数组注册事件，此外，你还可以在 `EventServiceProvider` 的 `boot` 方法中手动注册基于闭包的事件： 

```php
/**
 * 注册应用的其它事件.
 *
 * @return void
 */
public function boot()
{
    parent::boot();

    Event::listen('event.name', function ($foo, $bar) {
        //
    });
}
```



## 定义监听器

有时候，你希望停止事件被传播到其它监听器，你可以通过从监听器的 `handle` 方法中返回 `false` 来实现。

 

## 事件监听器队列

如果监听器将要执行耗时任务，可以将监听器放到队列。在队列化监听器之前，确保已经[配置好队列](https://laravelacademy.org/post/21535)并且在服务器或本地环境启动一个队列监听器。

要指定某个监听器需要放到队列，只需要让监听器类实现 `ShouldQueue` 接口即可，通过 Artisan 命令 `event:generate` 生成的监听器类已经将这个接口导入当前命名空间，可以直接拿来使用： 

```php
<?php

namespace App\Listeners;

use App\Events\OrderShipped;
use Illuminate\Contracts\Queue\ShouldQueue;

class SendShipmentNotification implements ShouldQueue
{
    //
}
```

就是这么简单！当这个监听器被调用的时候，将会使用 Laravel 的[队列系统](https://laravelacademy.org/post/21535)通过事件分发器自动推送到队列。如果通过队列执行监听器的时候没有抛出任何异常，队列任务会在执行完成后被自动删除。

### **自定义队列连接&队列名称**

如果你想要自定义事件监听器使用的队列连接和队列名称，可以在监听器类中定义 `$connection`、`$queue` 和 `$delay` 属性： 

```php
<?php

namespace App\Listeners;

use App\Events\OrderShipped;
use Illuminate\Contracts\Queue\ShouldQueue;

class SendShipmentNotification implements ShouldQueue
{
    /**
     * 任务将被推送到的连接名称.
     *
     * @var string|null
     */
    public $connection = 'sqs';

    /**
     * 任务将被推送到的连接名称.
     *
     * @var string|null
     */
    public $queue = 'listeners';

    /**
     * 任务被处理之前的延迟时间（秒）
     *
     * @var int
     */
    public $delay = 60;
}
```



### **按条件推送监听器到队列**

有时候，你可能需要基于一些运行时数据才能判断某个监听器是否需要推送到队列，这个时候，就需要在监听器中添加一个 `shouldQueue` 方法，该方法用于判断此监听器会被推送到队列还是同步执行： 

```php
<?php

namespace App\Listeners;

use App\Events\OrderPlaced;
use Illuminate\Contracts\Queue\ShouldQueue;

class RewardGiftCard implements ShouldQueue
{
    /**
     * Reward a gift card to the customer.
     *
     * @param  \App\Events\OrderPlaced  $event
     * @return void
     */
    public function handle(OrderPlaced $event)
    {
        //
    }

    /**
     * Determine whether the listener should be queued.
     *
     * @param  \App\Events\OrderPlaced  $event
     * @return bool
     */
    public function shouldQueue(OrderPlaced $event)
    {
        return $event->order->subtotal >= 5000;
    }
}
```



### 手动访问队列

 如果你需要手动访问底层队列任务的 `delete` 和 `release` 方法，在生成的监听器中，默认导入的`Illuminate\Queue\InteractsWithQueue` trait 为这两个方法提供了访问权限： 

```php
<?php

namespace App\Listeners;

use App\Events\OrderShipped;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Contracts\Queue\ShouldQueue;

class SendShipmentNotification implements ShouldQueue
{
    use InteractsWithQueue;

    public function handle(OrderShipped $event)
    {
        if (true) {
            $this->release(30);
        }
    }
}
```



### 处理失败任务

有时候队列中的事件监听器可能会执行失败。如果队列中的监听器任务执行时超出了队列进程定义的最大尝试次数，监听器上的 `failed` 方法会被调用，`failed` 方法接收事件实例和导致失败的异常： 

```php
<?php

namespace App\Listeners;

use App\Events\OrderShipped;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Contracts\Queue\ShouldQueue;

class SendShipmentNotification implements ShouldQueue
{
    use InteractsWithQueue;

    public function handle(OrderShipped $event)
    {
        //
    }

    public function failed(OrderShipped $event, $exception)
    {
        //
    }
}
```





## 分发事件（触发事件）

```php
event(new OrderShipped($order))
```



## 事件订阅者

```php
<?php

namespace App\Listeners;

class UserEventSubscriber
{
    /**
     * 处理用户登录事件.
     * @translator laravelacademy.org
     */
    public function handleUserLogin($event) {}

    /**
     * 处理用户退出事件.
     */
    public function handleUserLogout($event) {}

    /**
     * 为订阅者注册监听器.
     *
     * @param  Illuminate\Events\Dispatcher  $events
     */
    public function subscribe($events)
    {
        $events->listen(
            'Illuminate\Auth\Events\Login',
            'App\Listeners\UserEventSubscriber@handleUserLogin'
        );

        $events->listen(
            'Illuminate\Auth\Events\Logout',
            'App\Listeners\UserEventSubscriber@handleUserLogout'
        );
    }

}
```

### 注册事件订阅者

编写好订阅者之后，就可以通过事件分发器对订阅者进行注册，你可以使用 `EventServiceProvider` 提供的 `$subcribe` 属性来注册订阅者。例如，让我们添加一个 `UserEventSubscriber` ： 

```php
<?php

namespace App\Providers;

use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;

class EventServiceProvider extends ServiceProvider
{
    /**
     * 应用的事件监听器映射.
     *
     * @var array
     */
    protected $listen = [
        //
    ];

    /**
     * 要注册的订阅者类.
     *
     * @var array
     */
    protected $subscribe = [
         'App\Listeners\UserEventSubscriber',
    ];
}
```

