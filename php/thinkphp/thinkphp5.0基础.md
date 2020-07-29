## url访问
```
http://serverName/index.php（或者其它应用入口文件）/模块/控制器/操作/[参数名/参数值...]
例如
http://127.0.0.1:9501/public/index.php/index/index/index
```
默认情况下url不区分大小写，如果类文件名是驼峰法，则需要通过下划线进行访问，例如
```
访问application/index/controller/IndexTest.php
http://127.0.0.1:9501/public/index.php/index/index_test/index
```
如果要区分大小写，设置如下：
```
'url_convert'    =>  false,
```

## 自动生成module
在`application/build.php`文件下定义，然后执行`php think build`
```php
<?php
return [
	// 生成应用公共文件
    '__file__' => ['common.php', 'config.php', 'database.php'],
    // 其他更多的模块定义
    'common' => [
        '__dir__' => ['model','view','controller'],
        'model' => ['index'],
    ],
    'admin' => [
        '__dir__' => ['model','view','controller'],
        'model' => ['test'],
        'view' => ['index/index','order/index'],
    ]
];
```
重复执行不会覆盖原有的module

## trait的优先级
本类 > trait > 父类

## 响应
```php
return json(['code'=>1,'msg'=>'success'])
return xml(['code'=>1,'msg'=>'success'])
$this->success() //ajax返回json,否则返回html，html需要自己定义一个模板 
$this->error() //ajax返回json,否则返回html，html需要自己定义一个模板
$this->result() //需要自己指定返回的类型json或者html
```

## 调试模式

## 自定义异常处理
https://www.kancloud.cn/manual/thinkphp5/126075
*注意：不要在异常捕获success和error*
```php
try{
    Db::name('user')->find();
    //$this->success('执行成功') //不要这样子
}catch(\Exception $e){
    $this->error('执行错误');
}
$this->success('执行成功!');
```
### 定义错误页面
```php
'http_exception_template'    =>  [
    // 定义404错误的重定向页面地址
    404 =>  APP_PATH.'404.html',
    // 还可以定义其它的HTTP status
    401 =>  APP_PATH.'401.html',
]
```
### 手动抛出异常
```php
abort(404,'页面不存在');
```

## 打印sql语句
在`model`执行`getLastsql`方法

## 多语言
- 加载语言文件`application/admin/lang/zh-cn.php`
- `Lang::get('User id', [], 'zh-cn')`
### 多语言传递参数
- 语言文件定义`'file_format'    =>    '文件格式: {:format},文件大小：{:size}',`
- 加载语言文件`Lang::load(APP_PATH . '/admin/lang/zh-cn.php');`
- 根据key获取`lang('file_format',['format' => 'jpeg,png,gif,jpg','size' => '2MB'])`
### 模板显示
`{:lang('file_format',['format' => 'jpeg,png,gif,jpg','size' => '2MB'])}`




