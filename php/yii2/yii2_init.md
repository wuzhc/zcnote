# yii2创建项目
## 1. 创建项目
### 1.1 下载composer
```bash
 curl -sS https://getcomposer.org/installer | php7
```
### 1.2 安装yii2高级目标到food目录
```bash
php7 composer.phar create-project --prefer-dist yiisoft/yii2-app-advanced food
```
### 1.3 初始化
```bash
/path/to/php-bin/php /path/to/food/init
```
### 1.4 初始化数据库表
```bash
./yii migrate
```
###  参考链接：
- [](https://github.com/yiisoft/yii2-app-advanced/blob/master/docs/guide/start-installation.md)

