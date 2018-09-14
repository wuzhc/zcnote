- 说明:一般redis作为缓存工具使用,例如统计类数据,热点数据放在redis,因为redis是内存数据库,读取速度很可观,能够有效减轻mysql压力;
- 注意:需要注意的是缓存穿透和雪崩问题
    - 缓存穿透即绕过redis直接读取mysql,例如热点数据为空,不保存redis,导致每次请求读取不到redis时都去查询MySQL,建议是空数据时也要写一个空值到redis中,并且设置一个小的过期时间(如几分钟等等);
    - 缓存雪崩是redis突然失效,导致所有请求都去到了mysql,这种情况简单方法是用互斥锁,网上还有各种方法自行搜索
<br/>
##### 缓存穿透
```php
if (!($cacheData = $redis->get('key'))) {
    $data = $mysql->getData();
    if (empty($data)) {
        $redis->set('key', json_encode($data), 60);   // 当数据为空时,设置一个小的过期时间,这样的好处是可以减低数据更新延时率
    } else {
        $redis->set('key', json_encode($data), 7200); // 正常的过期时间为两个小时
    }
}
```
##### 缓存雪崩 (参考:http://huoding.com/2015/09/14/463)
```php
$key = 'cache_create_lock';                                   // 锁的名称
$value = sha1(uniqid(getmypid().'_'.mt_rand().'_', true));    // 唯一值,加入唯一值判断是为了避免删除到其他操作的锁(这种情况是发生在生成cache过程很久导致锁到了过期时间,此时锁被另一个用户拿到,而当代码继续执行时,会把另一个用户拿到的锁误删掉)
$ttl = 10;                                                    // ttl表示超时时间time to live,单位是秒.
if ($redis->set($key, $value, array('nx', 'ex' => $ttl))) {   // 锁: nx表示not exists. ex表示expire.
    $cache->create();                                         // 加锁后执行业务逻辑,这里是生成缓存,注意锁的过期时间必须比create长,否则会出现死锁
    if ($redis->get($key) === $value) {                       // 认证锁,防止误删
        $redis->del($key);
    }
} else {
    // 拿不到锁,是sleep几秒后重新查询缓存,还是直接返回系统繁忙状态?
    // 缓存失效,又拿不到锁生成缓存,怎么办?直接返回请求失败?
}
 
```