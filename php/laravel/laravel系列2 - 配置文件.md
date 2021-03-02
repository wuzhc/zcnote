## 判断当前应用环境

判断当前应用环境 `App::environment();`你也可以向 `environment()` 方法传递参数来判断当前环境是否匹配给定值

```php
if (App::environment('local')) {
    // The environment is local
}
    
if (App::environment('local', 'staging')) {
    // The environment is either local OR staging...
}
```



## 通过config访问配置

```php
// app 是配置文件名，timezone 是配置项，配置项有多个层级（数组）的话，使用 . 进行分隔
$value = config('app.timezone'); 

// 如果 app.timezone 配置值为空，则返回默认值 Asia/Shanghai
$value = config('app.timezone', 'Asia/Shanghai');
```



## 配置缓存

```bash
php artisan config:cache
```

注：如果在部署过程中执行 `config:cache` 命令，需要确保只在配置文件中调用了 `env` 方法。一旦配置文件被缓存后，`.env` 文件将不能被加载，所有对 `env` 函数的调用都会返回 `null`。



## 调试模式

`.env`将 `APP_DEBUG` 环境变量设置为 `true`

