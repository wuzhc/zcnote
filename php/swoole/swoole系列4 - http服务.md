```php
$http = new Swoole\Http\Server('0.0.0.0', 9501);

$http->on('Request', function ($request, $response) {
    $response->header('Content-Type', 'text/html; charset=utf-8');
    $response->end('<h1>Hello Swoole. #' . rand(1000, 9999) . '</h1>');
});

$http->start();
```

`HTTP` 服务器只需要关注请求响应即可，所以只需要监听一个 [onRequest](https://wiki.swoole.com/#/http_server?id=on) 事件。当有新的 `HTTP` 请求进入就会触发此事件。事件回调函数有 `2` 个参数，一个是 `$request` 对象，包含了请求的相关信息，如 `GET/POST` 请求的数据。

另外一个是 `response` 对象，对 `request` 的响应可以通过操作 `response` 对象来完成。`$response->end()` 方法表示输出一段 `HTML` 内容，并结束此请求。



## [Chrome 请求两次问题](https://wiki.swoole.com/#/start/start_http_server?id=chrome-%e8%af%b7%e6%b1%82%e4%b8%a4%e6%ac%a1%e9%97%ae%e9%a2%98)

使用 `Chrome` 浏览器访问服务器，会产生额外的一次请求，`/favicon.ico`，可以在代码中响应 `404` 错误。

```php
$http->on('Request', function ($request, $response) {
    if ($request->server['path_info'] == '/favicon.ico' || $request->server['request_uri'] == '/favicon.ico') {
        $response->end();
        return;
    }
    var_dump($request->get, $request->post);
    $response->header('Content-Type', 'text/html; charset=utf-8');
    $response->end('<h1>Hello Swoole. #' . rand(1000, 9999) . '</h1>');
});

```

