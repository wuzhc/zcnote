![](/data/wwwroot/doc/zcnote/images/php/hyperf/image.png)

hyperf框架使用hyperf/circuit-breaker提供的超时熔断机制，熔断器注解如下：
```php
@CircuitBreaker(timeout=1, failCounter=10, successCounter=10, fallback="App\Controller\AeController::submitFallback")
```

当close状态时，若请求超过timeout，failCounter加1，当failCounter累计达到10时触发熔断机制，此时切换为open状态
当open状态时，在duration内请求都走熔断器，即会执行fallback，超过duration才会切换到halfopen状态
当halfopen状态时，累计达到failCOunter时，继续触发熔断，若累计达到successCounter，则切换
为close状态

## 参考
https://hyperf.wiki/#/zh-cn/circuit-breaker?id=%E7%86%94%E6%96%AD%E5%99%A8
