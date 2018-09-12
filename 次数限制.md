> 主要使用了redis的setnx特性,以下是一个小时内,6次登录失败限制10分钟后再登录
```php
if ($hasErrors) { // 登录错误时,记录错误次数
    $res = $redis->set($key, 1, array('nx', 'ex' => 3600));
    if (false === $res && $redis->incr($key) > 5) {
        $redis->expire($key, 600);
        $this->addError('password', '登录失败次数有点频繁,请稍后再登录!');
    }
}
```
第一登录失败设置key,返回true,第二次失败返回false则错误次数加1;当错误次数达到5次,提示稍后登录
