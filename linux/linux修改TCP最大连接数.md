## 参考
- https://blog.csdn.net/zxljsbk/article/details/89153690
- https://github.com/link1st/go-stress-testing#4go-stress-testing-go%E8%AF%AD%E8%A8%80%E5%AE%9E%E7%8E%B0%E7%9A%84%E5%8E%8B%E6%B5%8B%E5%B7%A5%E5%85%B7
-https://www.cnblogs.com/cwp-bg/p/8377742.html


## tcp连接数影响因素
- 系统允许打开的最大文件数
- 用户允许打开的最大文件数（必须小于系统最大文件数`limits < file-max`）
- 可用的端口范围
- 取上述的最小值


## 系统允许打开的最大文件数
- 查看：
```bash
sysctl -a | grep file-max
```
- 修改：
```bash
vi /etc/sysctl.conf
# 在末尾添加
fs.file_max = 10240
# 立即生效
sysctl -p
```


## 用户允许打开的最大文件数
```bash
# 查看系统默认的值
ulimit -n #默认为1024，即只能一个进程只能打开1024个文件描述符，也就是只能维持1024个tcp连接
# 临时设置最大打开文件数
ulimit -n 1040000
# ulimit -Sn 软限制
# ulimit -Hn 硬限制
```
如果设置无效，需要修改配置文件，改方式是永久设置
```bash
vim /etc/security/limits.conf

root soft nofile 1040000 
root hard nofile 1040000

root soft nofile 1040000 #nofile是每个进程可以打开的文件数的限制
root hard nproc 1040000 #nproc是操作系统级别对每个用户创建的进程数的限制

root soft core unlimited
root hard core unlimited

* soft nofile 1040000
* hard nofile 1040000

* soft nofile 1040000
* hard nproc 1040000

* soft core unlimited
* hard core unlimited
```
- 如果重启无效，参考[https://www.cnblogs.com/cwp-bg/p/8377742.html](https://www.cnblogs.com/cwp-bg/p/8377742.html)
- 软限制可以在程序的进程中自行改变(突破限制)，而硬限制则不行(除非程序进程有root权限)
- soft nproc ：单个用户可用的最大进程数量(超过会警告);
- hard nproc：单个用户可用的最大进程数量(超过会报错);
- soft nofile  ：可打开的文件描述符的最大数(超过会警告);
- hard nofile ：可打开的文件描述符的最大数(超过会报错);


## 可用的端口范围
- 查看可用端口
```bash
sysctl -a | grep ipv4.ip_local_port_range
```
- 修改
```bash
vim /etc/sysctl.conf # 在文件末尾添加
net.ipv4.ip_local_port_range = 1024 65000
sysctl -p # 重启 
```




