# 依赖注入 (Dependency Injection)
> 依赖注入是控制反转的一种实现，它实现了调用者和被调用者之间的解耦；例如userController（调用者）需要调用logService(被调用者)来实现日志功能，通常做法是在userController中new logService()，而依赖注入的做法是将new logService()的工作交给外部（一般是ioc容器）处理；然后在注入到userController

## 例子
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

## 构造函数注入
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
上面logService实例化外部实例化然后作为参数传递给UserController，这样的实现了logService和UserController解耦，无论LogService怎么改变，都不影响UserController；有人可能会有这样的疑问，当LogService改变时，在UserController实例化或是在外部实例化不是一样要改变实例化方式吗？这是错误的想法，首先是解耦的思想，UserController和LogService应该是两个互相独立的对象，其次上面只是一个简单例子，一般我们会用ioc容器来负责生成类的实例，而不是自己手动实例化对象的

## 
