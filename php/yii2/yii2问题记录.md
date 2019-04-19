# yii2问题总结
## 1. 配置文件*.php和*_local.php的区别
*_local.php用于本地开发环境，使用git时不会包括这些文件，正确的使用方法是公用配置写*.php，本地环境配置信息写在*_local.php

## 2. 连接数据库报错误 SQLSTATE[HY000] [2002] No such file or directory
### 2.1 第一种解决方法 
这是因为配置文件使用localhost，然后找不到到相应的.sock文件，所以需要设置php.ini文件中的pdo_mysql.default_socket的值为.sock文件的路径。
```bash
pdo_mysql.default_socket= /tmp/mysqld.sock
```
如何查看sock文件路径？  
用phpinfo()查看mysql扩展信息
### 2.2 第二种解决方法
另一种快速解决方法是将localhost改为127.0.0.1；这是因为当主机填写为localhost时mysql会采用 unix domain socket连接，当主机填写为127.0.0.1时mysql会采用tcp方式连接
```php
'db' => [
	'dsn' => 'mysql:host=127.0.0.1;dbname=yiidb',
],
```

## 3. 如何新增应用
类似于fontend和backend，新增一个api
- 在/environments/dev和/environments/prod目录新建一个api目录
- 添加/environments/index.php中api配置
- 编辑 /common/config/bootstrap.php，添加以下代码：Yii::setAlias('@api', dirname(dirname(__DIR__)) . '/api');
- 从 frontend 里拷贝 web 和 veiws 文件夹到 api
- 执行`php init`
删除应用也是根据这几个步骤，依次删除

## 4. Object报错
报错如下：
```bash
Fatal error: Cannot use 'Object' as class name as it is reserved in /data/wwwroot/php/easyii/vendor/yiisoft/yii2/base/Object.php on line 77
```
这是因为PHP 7.0.2 Beta 3版本的新特性规定不能使用Object作为类名，yii框架本身的问题，新版本的yii已经没有使用Object类名了

## 提示Unable to verify your data submission
只是因为开启了csrf验证，关闭它即可，在controller中设置如下
```php
public $enableCsrfValidation = false;
```