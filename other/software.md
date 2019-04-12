### phpstorm

### git安装
sudo apt-get install git

### git ssh
```bash
git config --global user.name "wuzhc" 
git config --global user.email "1716220125@qq.com"
ssh-keygen -t rsa -C "wuzhc2016@163.com"
ssh-keygen -t rsa -C "1716220125@qq.com"

#### 对应网站添加公钥
# 将id_rsa_zhongzhi.pub和id_rsa_github.pub添加到对应的setting ssh

#### 配置
Host zzgit.cnweike.cn
User git
Hostname zzgit.cnweike.cn
Port 7681
IdentityFile ~/.ssh/id_rsa_zhongzhi

Host github.com
User wuzhc
Hostname github.com
Port 22
IdentityFile ~/.ssh/id_rsa_github

#### 测试    
ssh git@github.com
```

### composer安装
```bash
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

### npm安装
官网： https://nodejs.org/en/
```bash
wget https://nodejs.org/dist/v10.13.0/node-v10.13.0-linux-x64.tar.xz
tar -xvf node-v10.13.0-linux-x64.tar.xz
sudo ln -s /opt/node-v0.12.10-linux-x86/bin/node /usr/local/bin/node # 创建软连接
sudo ln -s /opt/node-v0.12.10-linux-x86/bin/npm /usr/local/bin/npm

#### cnpm淘宝源
vi ~/.bashrc
alias cnpm="npm --registry=https://registry.npm.taobao.org \
--cache=$HOME/.npm/.cache/cnpm \
--disturl=https://npm.taobao.org/dist \
--userconfig=$HOME/.cnpmrc"
source ~/.bashrc
```

### go安装
```bash
cd ~/Downloads/
wget https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz
tar -zxvf go1.9.2.linux-amd64.tar.gz
sudo mv go /usr/local/

#### 工作空间
mkdir -p /data/wwwroot/go/src

#### 环境配置
vim ~/.bashrc
export GOROOT=/usr/local/go                 # go安装所在目录
export GOPATH=/data/wwwroot/go              # go工作空间
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
source ~./bashrc
```
#### liteide
liteide默认会自己安装go-1.10版本
- 设置函数提示 go get -u github.com/nsf/gocode
- 进到src指定项目后，go install编译安装，只能一个main函数
- go build之后可以有代码提示

### svn安装
```bash
sudo apt-get install subversion
```

### 课堂部署
```bash
git clone git@zzgit.cnweike.cn:web/weike.git

#!/bin/bash
cd /data/wwwroot/default/weike
cp protected/components/Distribute.default.php ./protected/components/Distribute.php
cp protected/config/main.default.php ./protected/config/main.php
mkdir protected/runtime
chmod -R 777 protected/runtime/
mkdir assets
chmod -R 777 assets
```

### 学堂部署
```bash
git clone git@zzgit.cnweike.cn:web/xuetang.git

#!/bin/bash
cd /data/wwwroot/default/xuetang
cp protected/components/Distribute.default.php ./protected/components/Distribute.php
cp protected/config/main.default.php ./protected/config/main.php
mkdir protected/runtime
chmod -R 777 protected/runtime/
mkdir assets
chmod -R 777 assets
```

### 大赛
- 复制main.php文件
- 复制Distribute.php文件，修改define(THEMES, '')

### redis安装
```bash
wget http://download.redis.io/releases/redis-4.0.8.tar.gz
tar xzvf redis-4.0.8.tar.gz
cd redis-4.0.8
make
make install PREFIX=/usr/local/redis # 设置目录安装目录到/usr/local/redis

#### 配置
mv redis-4.0.8/redis.conf /usr/local/redis/redis_6379.conf
sudo vi redis_6379.conf
# daemonize no -> yes
# logfile "" -> logfile /usr/local/redis/log/redis_6379.conf

#### 创建用户，否则dump.db没有权限保存
groupadd redis
useradd -r -g redis -s /bin/false redis
chown -R redis:redis ./

#### 启动关闭
sudo -u redis ./bin/redis-server ./redis_6379.conf
./bin/redis-cli shutdown

#### 开机启动
sudo cp ~/Downloads/redis-4.0.8/utils/redis-init-scipt /etc/init.d/redis

修改开机头信息
### BEGIN INIT INFO
# Provides:     redis_6379
# Required-Start:
# Required-Stop:
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description:    Redis data structure server
# Description:          Redis data structure server. See https://redis.io
### END INIT INFO

#### 添加开机启动项
update-rc.d redis defaults

#### 查看redis版本
redis-cli --version
```

### redis扩展
```bash
wget https://pecl.php.net/get/redis-4.1.1.tgz # 只用于php5.6版本，更高php7版本用4.2+
tar -zxvf redis-4.1.1
cd redis-4.1.1
phpize
# echo '123'|sudo -S apt-get install autoconf  phpize会提示错误,则安装autoconf
./configure --with-php-config=/opt/lampp/bin/php-config
make
sudo make install

#### php.ini添加扩展
extension=redis.so
```

### hiredis安装

```bash
wget https://github.com/redis/hiredis/archive/v0.14.0.tar.gz
tar -xzvf v0.14.0.tar.gz
cd hiredis-0.14.0
make clean > /dev/null
make -j
make install
ldconfig
```

### mongo安装

```bash
sudo apt-get install mongodb
```

### mongo扩展
https://pecl.php.net/package/mongo

```bash
wget https://pecl.php.net/get/mongo-1.6.16.tgz
tar -zxvf mongo-1.6.16.tgz
cd mongo-1.6.16
phpize
# sudo apt-get install libssl-dev 报错configure: error: Cannot find OpenSSL's <evp.h> 
./configure --with-php-config=/opt/lampp/bin/php-config
make
sudo make install

#### php.ini添加配置
extension=mongo.so
```

### mongodb扩展
https://pecl.php.net/package/mongodb

```bash
wget https://pecl.php.net/get/mongodb-1.3.4.tgz # 1.5.3版本会报错
tar -zxvf mongodb-1.3.4.tgz
cd mongodb-1.3.4
phpize
# sudo apt-get install libssl-dev 报错configure: error: Cannot find OpenSSL's <evp.h> 
./configure --with-php-config=/opt/lampp/bin/php-config
make
sudo make install

#### php.ini添加配置
extension=mongo.so
```

### swoole扩展

### php7
cURL version 7.10.5 or later is required to compile php with cURL support
sudo apt-get install libcurl4-openssl-dev
sudo apt-get install libedit-dev

```bash
apt-get update && apt-get install -y \
        autoconf \
        file \
        g++ \
        gcc \
        make \
        pkg-config \
        re2c \
        libcurl4-openssl-dev \
        libedit-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        zlib1g-dev \
        ca-certificates \
        curl \
        git \
        curl \
        vim \
        nano \
        zip \
        wget 
        
wget http://am1.php.net/distributions/php-7.2.8.tar.gz \
    && tar -zxf php-7.2.8.tar.gz \
    && cd php-7.2.8 \
    && ./configure \
        --prefix=/usr/local/php \
        --with-config-file-path=/usr/local/php/etc \
        --with-config-file-scan-dir=/usr/local/php/conf.d \
        --with-mhash \
        --enable-ftp \
        --enable-mbstring \
        --enable-mysqlnd \
        --with-curl \
        --with-libedit \
        --with-openssl \
        --with-zlib \
    && make clean > /dev/null \
    && make \
    && make install \
    && cp php.ini-development /usr/local/php/etc/php.ini
```

### 游览器扩展
http://chromecj.com/list/

### xdebug安装
https://pecl.php.net/package/xdebug
```bash
wget https://pecl.php.net/get/xdebug-2.5.5.tgz
tar -zxvf xdebug-2.5.5.tgz
cd xdebug-2.5.5
phpize
./configure --with-php-config=/opt/lampp/bin/php-config
make
sudo make install

#### php.ini添加配置
[xdebug]
;启用性能检测分析  
xdebug.profiler_enable=0
;通过XDEBUG_PROFILE触发生成效能分析文件，profiler_enable需要设置为off
xdebug.profiler_enable_trigger=1 
;启用代码自动跟踪  
;xdebug.auto_trace=on  
;允许收集传递给函数的参数变量  
xdebug.collect_params=on  
;允许收集函数调用的返回值  
xdebug.collect_return=on  
;指定堆栈跟踪文件的存放目录  
xdebug.trace_output_dir="/data/wwwroot/xdebug_profiler/"
;指定性能分析文件的存放目录  
xdebug.profiler_output_dir="/data/wwwroot/xdebug_profiler"  
xdebug.profiler_output_name = cachegrind.out.%R
;xdebug.idekey=PHPSTORM
;断点调试需要开启这个
xdebug.remote_enable = 1

zend_extension=xdebug.so
```

### 环境变量
- /etc/profile 全局修改
- ~/.bashrc 用户修改
- export $PATH:/usr/local/redis/bin

### swoole-ide-helper
```bash
cd /data/wwwroot/default
git clone https://github.com/wudi/swoole-ide-helper.git
```

### php.ini配置
```bash
error_reporting = E_ALL & ~E_NOTICE 
```

### 虚拟机安装
- 进入pe工具
- 快速分4个区
- 安装
共享文件夹
- 共享文件夹->添加->选择其他->勾选自动挂载，勾选固定分配
- 设备->安装增强功能

### deepin触摸板水平滑动配置
```bash
gsettings set com.deepin.dde.touchpad horiz-scroll-enabled true ## 开启双指水平滚动
```

### wireshark权限配置
```bash
 sudo setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/bin/dumpcap
```

### charles破解
路径：菜单栏->help  
- Registered Name: https://zhile.io
- License Key: 48891cf209c6d32bf4

### phpstorm破解
激活时选择License server 填入http://idea.imsxm.com 点击Active即可

### 规则
- 软件安装统一到/opt下，执行文件创建软连接到/usr/bin目录
