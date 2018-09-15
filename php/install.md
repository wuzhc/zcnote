#### phpize
phpize用于安装扩展模块,作用在于侦测环境,生成configure文件

#### --with-php-config
假如你的服务器上安装了多个版本php，那么需要告诉phpize要建立基于哪个版本的扩展。通过使用--with-php-config=指定你使用哪个php版本。

#### --enable-fpm
启用sapi的fpm

#### 配置文件
cp /opt/php7/etc/php-fpm.d/www.conf.default /opt/php7/etc/php-fpm.d/www.conf  
cp /opt/php7/etc/php-fpm.conf.default /opt/php7/etc/php-fpm.conf  
cp /data/php7.2.10/php.ini-development /opt/php7/lib/php.ini  

#### 编译安装php
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

#### 编译安装扩展
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

