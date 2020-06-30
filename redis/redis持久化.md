## 参考
- https://www.jianshu.com/p/bab8f4b26445
- https://www.cnblogs.com/lizhimin123/p/10192217.html


> 相对于memcache,redis的是数据可以做持久化处理,主要有两种方式,快照rdb和追加文件aof,redis是持久化处理是比较耗时,一般在主从模式中,master不做持久化处理,由slave处理

## 持久化的意义
防止数据丢失

## 快照rdb 
- redis使用操作系统的多进程COW机制(Copy On Write)复制写机制来实现快照的持久化
- 由子进程进行持久操作，子进程刚刚产生时，和父进程共享内存里面的代码段和数据段
- 子进程会

### 配置
持久化有两个命令，`save`和`bgsave`，`save`会阻塞服务进程，直到持久化完成，`bgsave`会fork子进程，由子进程去完成持久化，`bgsave`对应配置如下：
```bash
// 满足以上三个条件中的任意一个，则自动触发 BGSAVE 操作 
save 900 1       // 服务器在900秒之内，对数据库执行了至少1次修改 
save 300 10      // 服务器在300秒之内，对数据库执行了至少10修改 
save 60  1000    // 服务器在60秒之内，对数据库执行了至少1000修改
```
### rdb文件结构
https://www.cnblogs.com/lizhimin123/p/10192217.html
![https://img2018.cnblogs.com/blog/1522047/201812/1522047-20181229102040895-1225006452.png](https://img2018.cnblogs.com/blog/1522047/201812/1522047-20181229102040895-1225006452.png)
- REDIS：5字节，保存着 "REDIS" 五个字符
- db_version：4字节，RDB文件的版本号
- database 0：数据库中的键值对
	- SELECTDB：1字节常量
	- db_number：数据库号码
	- key_value_pairs：键值对
		- type: 记录类对象的编码类型，程序会根据 TYPE 属性来决定如何读入和解释value数据
		- key
		- value
- EOF：RDB文件的结束标志
- check_sum：校验和（CRC64），用来检查RDB文件是否出错

### rdb问题
- 持久化过程中数据发生改变？
rdb文件被成为快照文件，子进程所看到的数据在它被创建的一瞬间就固定下来了，父进程修改的某个数据只是该数据的复制品。（父子进程共享内存，数据发生写时会另外复制一份数据进行修改）
![https://upload-images.jianshu.io/upload_images/7789414-016d9f4ff4c14e33.png?imageMogr2/auto-orient/strip|imageView2/2/w/1196/format/webp](https://upload-images.jianshu.io/upload_images/7789414-016d9f4ff4c14e33.png?imageMogr2/auto-orient/strip|imageView2/2/w/1196/format/webp)

### 优缺点
优点:  
- 性能好  
缺点:  
- 实时性差  

## 追加日志aof
redis将指令追加到日志，通过回放指令来恢复数据，随着时间的增大会有日志文件变大的问题，这就需要重写日志

## aof重写日志
![https://upload-images.jianshu.io/upload_images/7789414-42813796f197b274.png?imageMogr2/auto-orient/strip|imageView2/2/w/957/format/webp](https://upload-images.jianshu.io/upload_images/7789414-42813796f197b274.png?imageMogr2/auto-orient/strip|imageView2/2/w/957/format/webp)

优点:  
- 实时性小
缺点:  
- 需要重写日志文件  
