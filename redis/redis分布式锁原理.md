https://www.jianshu.com/p/fba7dd6dcef5

https://github.com/php-lock/lock#mysqlmutex

- 保证原子性,`setnx`和`expire`两个命令无法保证原子性,使用`set`来代替
- 设置过期时间,防止锁一直被应用程序占用
- 为锁设置一个随机值,防止误删其他锁