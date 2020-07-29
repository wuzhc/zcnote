## static
`pm.max_children`：静态方式下开启的php-fpm进程数量


## dynamic
`pm.start_servers`：动态方式下的起始php-fpm进程数量
`pm.min_spare_servers`：动态方式下的最小php-fpm进程数
`pm.max_spare_servers`：动态方式下的最大php-fpm进程数量


## php-fpm需要设置多少个进程数
php-fpm进程只占用3M左右内存，运行一段时间后就会上升到20-30M，所以一般根据`服务器的内存/30M`就可以知道要设置多少个进程了。比如8G，可以设置`8*1024/30`个进程
