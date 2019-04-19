# yii2路由器
## 1. 路由管理器
路由管理器为urlManager，主要负责路由解析`parseRequest()`和创建url`createUrl()`

## 2. 创建路由
```php
$url = Url::to(['post/view', 'id' => 100]);
```

## 3. 解析路由
### 3.1 设置默认路由：
```php
return [
	// main.php设置
   'defaultRoute' => 'module/controller/action',
]
```
### 3.2 拦截所有路由
```php
return [
	// main.php设置
    'catchAll' => ['site/offline'],
];

```
### 3.3 url简写
```php
use yii\helpers\Url;

// 主页URL：/index.php?r=site%2Findex
echo Url::home();

// 根URL，如果程序部署到一个Web目录下的子目录时非常有用
echo Url::base();

// 当前请求的权威规范URL
// 参考 https://en.wikipedia.org/wiki/Canonical_link_element
echo Url::canonical();

// 记住当前请求的URL并在以后获取
Url::remember();
echo Url::previous();
```

### 3.4 url美化
```php
[
    'components' => [
        'urlManager' => [
            'enablePrettyUrl' => true, // 是否开启美化，必选
            'showScriptName' => false, // 是否显示index.php
            'enableStrictParsing' => false, // 是否开启严格解析,true时规则列表中必选匹配到一条，false时没匹配到则原url解析
            'rules' => [
                // ...
            ],
        ],
    ],
]
```
#### 3.4.1 rules规则
当找到第一条匹配的规则时停止。  同样的，创建URL的时候，URL管理器 查找 第一条匹配的的规则
并用来生成URL
#### 3.4.2 rules写法
yii\web\UrlManager::$rules 为一个数组，键为匹配规则，值为路由，例如：
```php
[
    'posts' => 'post/index', 
    'post/<id:\d+>' => 'post/view',
]
// 或者
[
    [
        'pattern' => 'posts',
        'route' => 'post/index',
        'suffix' => '.json',
    ],
]
```
举个例子：
```php
[
    'posts/<year:\d{4}>/<category>' => 'post/index',
    'posts' => 'post/index',
    'post/<id:\d+>' => 'post/view',
]
```
#### 当规则用来解析 URL 时：
- 根据第二条规则，/index.php/posts 被解析成路由 post/index；
- 根据第一条规则，/index.php/posts/2014/php 被解析成路由 post/index， 参数 year 的值是 2014，参数 category 的值是 php；
- 根据第三条规则，/index.php/post/100 被解析成路由 post/view， 参数 id 的值是 100；
- 当yii\web\UrlManager::$enableStrictParsing 设置为 true 时，/index.php/posts/php 将导致一个yii\web\NotFoundHttpException 异常， 因为无法匹配任何规则。如果 yii\web\UrlManager::$enableStrictParsing 设为 false（默认值）， 路径部分 posts/php 将被作为路由。  

#### 当规则用来生成 URL 时：
- 根据第二条规则 Url::to(['post/index']) 生成 /index.php/posts；
- 根据第一条规则 Url::to(['post/index', 'year' => 2014, 'category' => 'php']) 生成 /index.php/posts/2014/php；
- 根据第三条规则 Url::to(['post/view', 'id' => 100]) 生成 /index.php/post/100；
- 根据第三条规则 Url::to(['post/view', 'id' => 100, 'source' => 'ad']) 生成 /index.php/post/100?source=ad。 因为参数 source 在规则中没有指定，将被作为普通请求参数附加到生成的 URL 后面。
- Url::to(['post/index', 'category' => 'php']) 生成 /index.php/post/index?category=php。 注意因为没有任何规则适用，将把路由信息当做路径信息来生成URL， 并且所有参数作为请求查询参数附加到 URL 后面。

## 4. 问题
### 4.1 url不支持驼峰写法
例如动作名称为actionGetName，调用的时候要用get-name

### 4.2 隐藏index.php
在URL中隐藏入口脚本名称，除了要设置 showScriptName 为 false， 同时应该配置 Web 服务，处理当请求 URL 没有特殊指定入口脚本时确定要执行哪个PHP文件，[参考这个](https://www.yiichina.com/doc/guide/2.0/start-installation#recommended-apache-configuration)

## 参考
- [https://www.yiichina.com/doc/guide/2.0/runtime-routing](https://www.yiichina.com/doc/guide/2.0/runtime-routing)




