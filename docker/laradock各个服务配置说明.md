## 使用
### 目录结构如下:
```bash
+ laradock
+ project-1
+ project-2
```
### 配置多个域名
nginx/sites访问不同的域时，转到并创建配置文件以指向不同的项目目录

### 添加hosts
```bash
127.0.0.1 food.cm
```

## workspace
可以到该目录下执行php应用执行
```bash
docker-compose exec workspace bash
# 执行php应用 ./yii migrate/up
```


## phpmyadmin
我们自定的配置文件在`/etc/phpmyadmin/config.user.inc.php`,默认情况下不需要设置这个,只需要在Dockerfile指定`environment`环境变量即可
```bash
docker-compose exec phpmyadmin sh
```
### 有两个东西需要更改
- 指定docker-compose.yml的`PMA_HOST`,如下:
```bash
environment:
    - PMA_HOST=mysql
    - PMA_PORT=3306
    - PMA_ARBITRARY=0
```
- 默认安装的是mysql8.0版本,需要更改密码 
```bash
use mysql；
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'root'; 
FLUSH PRIVILEGES;  
```
### 参考
- https://hub.docker.com/r/phpmyadmin/phpmyadmin
- /data/wwwroot/doc/zcnote/mysql/phpmyadmin配置.md


## nginx
- 配置文件`nginx.conf`位于`/etc/nginx`目录下,该文件是复制过来的`COPY nginx.conf /etc/nginx/`
- 域名配置文件位于`/etc/nginx/sites-available`,这些文件被挂载在`nginx/sites`目录下,默认配置文件为`default.conf`
```bash
# nginx.conf配置文件如下
include /etc/nginx/conf.d/*.conf;
include /etc/nginx/sites-available/*.conf;
```

## mysql
默认安装的mysql账号密码为root,root

## mongodb
-  首先在Workspace和PHP-FPM容器中安装mongo： 
	- a）打开.env文件 
	- b）`WORKSPACE_INSTALL_MONGO`在Workspace Container下搜索参数 
	- c）将其设置为true 
	- d）`PHP_FPM_INSTALL_MONGO`在PHP-FPM容器下搜索参数 
	- e）设置它至true
- 重新构建容器 docker-compose build workspace php-fpm
- mongo使用该docker-compose up命令运行MongoDB Container（
```bash
docker-compose up mongo
```

## Yii项目部署过程
```bash
# 进入docker容器
docker-compose exec workspace sh
# 初始化项目,生成index.php, main-local.php, params-local.php等文件,初始化选择生成环境
./init
# composer依赖管理
composer install -vvv
# 修改配置
# yii读取配置顺序是`main-local.php`优先于`main.php`,所以`main-local.php`会覆盖`main.php`配置,即初始化会生成默认配置,这些默认配置需要删掉或者改为自己的配置,因为`main-local.php`不会提交到版本库,所以设置`main-local.php`的配置是不会共享给其他人的
# url美化
# mysql连接
```
