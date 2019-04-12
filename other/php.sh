#!/usr/bin/env bash


echo "开始安装php"
pwd="123"
installDir="/opt"
cd $installDir

echo ${pwd}|sudo -S wget http://101.110.118.21/cn2.php.net/distributions/php-7.2.12.tar.bz2
echo ${pwd}|sudo -S tar -xvf php-7.2.12.tar.bz2
cd php-7.2.12
echo ${pwd}|sudo -S ./configure \
    --prefix=/opt/php7 \
    --with-config-file-path=/opt/php7/etc \
    --with-config-file-scan-dir="/opt/php7/etc/conf.d" \
    --with-mcrypt \
    --with-mhash \
    --enable-ftp \
    --enable-mbstring \
    --enable-mysqlnd \
    --with-curl \
    --with-libedit \
    --with-openssl \
    --with-zlib
echo ${pwd}|sudo -S make
echo ${pwd}|sudo -S make install

echo "正在移动配置文件"
#echo ${pwd}|sudo -S cp /opt/php7/etc/php-fpm.d/www.conf.default /opt/php7/etc/php-fpm.d/www.conf
#echo ${pwd}|sudo -S cp /opt/php7/etc/php-fpm.conf.default /opt/php7/etc/php-fpm.conf
echo ${pwd}|sudo -S cp /opt/php-7.2.12/php.ini-development /opt/php7/etc/php.ini

echo ${pwd}|sudo -S rm -rf php-7.2.12.tar.bz2
echo "已完成php"

