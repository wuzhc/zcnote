### phpize
phpize用于安装扩展模块,作用在于侦测环境,生成configure文件

### --with-php-config
用法: --with-php-config=/path/to/php-config (php-config一般放在安装目录bin下)    
php-config用于获取PHP安装信息,如安装路径,版本,依赖,编译参数(执行./configure时带的参数)等等,它提供给configure.in信息,用于生成makefile

### --enable-fpm
启用sapi的fpm

### --with和--enable的区别
- --enable表示是否开启内置的扩展
- --with表示是否添加某个功能，一般需要指定依赖的外部库


### 配置文件
cp /opt/php7/etc/php-fpm.d/www.conf.default /opt/php7/etc/php-fpm.d/www.conf  
cp /opt/php7/etc/php-fpm.conf.default /opt/php7/etc/php-fpm.conf  
cp /data/php7.2.10/php.ini-development /opt/php7/lib/php.ini  

### 编译安装php
```bash
#!/usr/bin/env bash
install_dir = '/home'

echo "开始安装php"
cd ${install_dir}
wget http://am1.php.net/distributions/php-7.2.10.tar.gz
tar zxvf php-7.2.10.tar.gz
cd php-7.2.10
./configure \
    --prefix=/usr/local/php \
    --with-config-file-path=/usr/local/php/etc \
    --with-config-file-scan-dir="/usr/local/php/etc/conf.d" \
    --with-mcrypt \
    --with-mhash \
    --enable-ftp \
    --enable-mbstring \
    --enable-mysqlnd \
    --with-curl \
    --with-libedit \
    --with-openssl \
    --with-zlib 
make && make install
rm -rf php7.2.10.tar.gz
echo "已完成php"
```



### 编译安装扩展
```bash
#!/usr/bin/env bash
install_dir = '/home'

echo "开始安装swoole"
cd ${install_dir}
curl -Ls -o swoole-src-4.0.3.tar.gz https://github.com/swoole/swoole-src/archive/v4.0.3.tar.gz 
tar -zxvf swoole-src-4.0.3.tar.gz 
cd swoole-src-4.0.3 
usr/local/php/bin/phpize 
./configure --with-php-config=/usr/local/php/bin/php-config --enable-openssl
make 
make install 
rm -rf swoole-src-4.0.3.tar.gz
echo "已完成swoole"
```

### 编译工具
![](https://box.kancloud.cn/302fc3e158fcb689336665ddf01b47cb_537x361.png)

### 启动内置web服务
```bash
php -S 127.0.0.1:端口 -t 网站根目录
```
