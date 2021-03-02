## 使用composer安装
```bash
#设置composer全局中国镜像
wget https://mirrors.aliyun.com/composer/composer.phar
#项目为example-app
php73 composer.phar create-project laravel/laravel laravel-demo -vvv
cd laravel-demo
php73 artisan serve
```



## 使用docker安装

```bash
curl -s https://laravel.build/example-app | bash
cd example-app
./vendor/bin/sail up
```

