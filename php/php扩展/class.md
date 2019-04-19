我们知道swoole扩展不是简单提供函数，它还提供了类，例如我们的php可以这么使用：
```php
$serv = new Swoole\Server();
```
那么如何在PHP扩展中实现类呢？
