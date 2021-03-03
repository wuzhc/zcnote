> 依赖注入是控制反转的一种实现，它实现了调用者和被调用者之间的解耦；应用场景就是当你需要调用别的对象方法而又不想程序的耦合度太高的时候



## 依赖注入和控制反转有什么区别？

```php
 IoC - Inversion of Control  控制反转
 DI  - Dependency Injection  依赖注入
```

依赖注入和控制反转是对同一件事情的不同描述，从某个方面讲，就是它们描述的角度不同。

- 依赖注入是从应用程序的角度在描述，应用程序依赖容器创建并注入它所需要的外部资源；
- 控制反转是从容器的角度在描述，容器控制应用程序，由容器反向的向应用程序注入应用程序所需要的外部资源。

参考：<https://segmentfault.com/a/1190000007209266>



## di和ioc如何实现解耦？

```php
class UserController {
    public function saveLog()
    {
        $log = new LogService();
        $log->save();
    }
}
class LogService {
    public function save()
    {
    }
}
$u = new UserController();
$u->saveLog();
```
一旦LogService类名或参数或实例化方式改变，都需要跟着改变UserController的代码

### 构造函数注入

```php
class UserController {
    public $log;
    public function __construct(LogService $log)
    {
        $this->log = $log;
    }
    public function saveLog()
    {
        $this->log->save();
    }
}
class LogService {
    public function save()
    {
    }
}
$u = new UserController(new LogService());
$u->saveLog();
```
上面logService外部实例化然后作为参数传递给UserController，这样的实现了logService和UserController解耦，无论LogService怎么改变，都不影响UserController；有人可能会有这样的疑问，当LogService改变时，在UserController实例化或是在外部实例化不是一样要改变实例化方式吗？这是错误的想法，首先是解耦的思想，UserController和LogService应该是两个互相独立的对象，其次上面只是一个简单例子，一般我们会用ioc容器来负责生成类的实例，而不是自己手动实例化对象的



## 代码实现原理

声明`Foo`，`Bar`，`Bim`三个类，其中`Foo`依赖`Bar`，`Bar`依赖`Bim`

```php
class Bim
{
    public function doSomething()
    {
        echo __METHOD__, '|';
    }
}

class Bar
{
    private $bim;

    public function __construct(Bim $bim)
    {
        $this->bim = $bim;
    }

    public function doSomething()
    {
        $this->bim->doSomething();
        echo __METHOD__, '|';
    }
}

class Foo
{
    private $bar;

    public function __construct(Bar $bar)
    {
        $this->bar = $bar;
    }

    public function doSomething()
    {
        $this->bar->doSomething();
        echo __METHOD__;
    }
}
```

ioc容器实现，需要一个解析接口，解析接口通过发射来实现对依赖查找

```php
class Container
{
    private $s = array();

    public function __set($k, $c)
    {
        $this->s[$k] = $c;
    }

    public function __get($k)
    {
        return $this->build($this->s[$k]);
    }

    /**
         * 自动绑定（Autowiring）自动解析（Automatic Resolution）
         *
         * @param string $className
         * @return object
         * @throws Exception
         */
    public function build($className)
    {
        // 如果是匿名函数（Anonymous functions），也叫闭包函数（closures）
        if ($className instanceof Closure) {
            // 执行闭包函数，并将结果
            return $className($this);
        }

        /** @var ReflectionClass $reflector */
        $reflector = new ReflectionClass($className);

        // 检查类是否可实例化, 排除抽象类abstract和对象接口interface
        if (!$reflector->isInstantiable()) {
            throw new Exception("Can't instantiate this.");
        }

        /** @var ReflectionMethod $constructor 获取类的构造函数 */
        $constructor = $reflector->getConstructor();

        // 若无构造函数，直接实例化并返回
        if (is_null($constructor)) {
            return new $className;
        }

        // 取构造函数参数,通过 ReflectionParameter 数组返回参数列表
        $parameters = $constructor->getParameters();

        // 递归解析构造函数的参数
        $dependencies = $this->getDependencies($parameters);

        // 创建一个类的新实例，给出的参数将传递到类的构造函数。
        return $reflector->newInstanceArgs($dependencies);
    }

    /**
         * @param array $parameters
         * @return array
         * @throws Exception
         */
    public function getDependencies($parameters)
    {
        $dependencies = [];

        /** @var ReflectionParameter $parameter */
        foreach ($parameters as $parameter) {
            /** @var ReflectionClass $dependency */
            $dependency = $parameter->getClass();

            if (is_null($dependency)) {
                // 是变量,有默认值则设置默认值
                $dependencies[] = $this->resolveNonClass($parameter);
            } else {
                // 是一个类，递归解析
                $dependencies[] = $this->build($dependency->name);
            }
        }

        return $dependencies;
    }

    /**
         * @param ReflectionParameter $parameter
         * @return mixed
         * @throws Exception
         */
    public function resolveNonClass($parameter)
    {
        // 有默认值则返回默认值
        if ($parameter->isDefaultValueAvailable()) {
            return $parameter->getDefaultValue();
        }

        throw new Exception('I have no idea what to do here.');
    }
}
```

`Foo`依赖`Bar`，`Bar`依赖`Bim`

```php
$c = new Container();
$c->bar = 'Bar';
$c->foo = function ($c) {
    return new Foo($c->bar);
};
$foo = $c->foo;
$foo->doSomething(); // Bim::doSomething|Bar::doSomething|Foo::doSomething

$di = new Container();
$di->foo = 'Foo';
$foo = $di->foo;
var_dump($foo);
$foo->doSomething(); // Bim::doSomething|Bar::doSomething|Foo::doSomething
```



## laravel是如何实现依赖注入？

Laravel 通过服务容器来管理类依赖并进行依赖注入。如果使用一个接口`interface`作为函数参数的类型提示，这个时候就需要将指定的实现绑定到接口上面：

```php
interface EventPusher {
    public function send($data);
}
class RedisEventPusher implements EventPusher {
    public function send($data) {
        //
    }
}
$this->app->bind('App\Contracts\EventPusher', 'App\Services\RedisEventPusher');
```

```php
use App\Contracts\EventPusher;
public function __construct(EventPusher $pusher) 
{
    $this->pusher = $pusher; 
}
```

函数参数类型是接口，所以需要将`App\Contracts\EventPusher`绑定在具体实现上`App\Services\RedisEventPusher`，这个就是所谓的**面向接口编程**，接口可以理解为一个规范、一个约束。高层模块不直接依赖于低层模块，它们都应该依赖于抽象（指接口）。