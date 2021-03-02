```bash
phpize7
./configure --with-php-config=/opt/php73/bin/php-config 
 /opt/lampp/bin/php-config
make
sudo make install
# 打开php.ini位置,追加如下
extension=gd.so
```

- 如果不知道php-config的位置可以执行`whereis php-config`
- 如果不知道php.ini的位置可以执行`php --ini`

## 问题
### 1 gd扩展不能用
进入到php7源码目录`/opt/php-7.2.12/ext/gd`,执行安装gd扩展命令如下:
```bash
phpize7
./configure --with-php-config=/opt/php73/bin/php-config --with-png-dir --with-freetype-dir --with-jpeg-dir --with-zlib-dir --with-gd
make
sudo make install
```
#### 1.1 configure: error: freetype.h not found.
解决办法：
```bash
 sudo apt-get install libfreetype6-dev
```

#### 1.2 configure: error: jpeglib.h not found.
解决方法:
```bash
sudo apt-get install libjpeg-dev
```