一致性是指多副本中的数据一致性问题,可以分为强一致性,顺序一致性,弱一致性
## 强一致性
在任意时刻，所有节点中的数据是一样的,例如，例如主从数据库,主库更新一个数据后,可以从从库读取到

可以指定复制所有库,指定库,或者指定表
## 主从复制的优点
- 主库负责写,从库负责读,可以分配负载以提高性能
- 数据备份,从库可以作为备份数据库



## 主从复制原理
![https://upload-images.jianshu.io/upload_images/11414906-1e1d8aaa7a86af96.png?imageMogr2/auto-orient/strip|imageView2/2/w/799/format/webp](https://upload-images.jianshu.io/upload_images/11414906-1e1d8aaa7a86af96.png?imageMogr2/auto-orient/strip|imageView2/2/w/799/format/webp)
- 主库开启二进制日志
- 主库将sql语句通过`io线程`保存在二进制日志`binary log`
- 从库启动`io线程`,读取主库的`binary log`到自己的中继日志`realy log`
- 从库开启`sql线程`,定时检查`realy log`,然后执行`realy log`语句
- 从库会记录主库二级制日志的坐标,所以从库可以暂停恢复继续处理

## docker启动mysql容器
https://www.cnblogs.com/sablier/p/11605606.html
```bash
# 镜像为mysql:5.7
docker run -p 13306:3306 --name mysql_1 --network mysql-network -e MYSQL_ROOT_PASSWORD=123456 -d mysql:v57
# 进入容器 
docker exec -it mysql_1 /bin/bash
# 允许root远程登录mysql
grant all privileges on *.* to root@'%' identified by "password";
flush privileges;
```

## 主库配置
创建用户 
```bash
# 创建用于复制数据的用户,并只赋予replication权限
create user 'repl'@'%';
grant replication slave on *.* to repl@'%' identified by "123456";
# 导出主库已经存在的数据
mysqldump  -u用户名  -p密码  --all-databases  --master-data=1 > dbdump.db
```
配置`my.cnf`
```bash
# docker默认路径`/etc/mysql/my.cnf`
vi /etc/mysql/my.cnf

[mysqld]
log-bin=mysql-bin
server-id=1

# 重启
/etc/init.d/mysqld restart
```
- server-id 为0时,表示主库拒绝任何来自从库的连接
- 主从库server-id不能冲突，主要Master要依靠server_id来决定是否执行event。从库会把主库的event发送回主库???
-  多个从库的server-id不能冲突，server-id用来表示从库连接

## 从库配置
配置`my.cnf`
```bash
[mysqld]
server-id=2

# 重启
/etc/init.d/mysqld restart

change master to master_host='mysql_1',master_user='repl',master_password='123456';

# 启动
start slave;
# 查看是否成功
show slave status\G
```

## 测试sql
```sql
# 创建users表
create table users( id int(11) auto_increment, name varchar(100) not null, age int(1) default 0, primary key(id) )engine=InnoDB default charset=utf8;
# 插入一条数据
insert into users(name,age) values('wuzhc',20),('mayun',65);
```

## 复制过程
当master上写操作繁忙时，当前POS点例如是10，而slave上IO_THREAD线程接收过来的是3，此时master宕机，会造成相差7个点未传送到slave上而数据丢失
- 异步复制
- 半同步复制


## 常见的错误
- master上删除一条记录，而slave上找不到 
	- `set global sql_slave_skip_counter=1;`
- 主键重复。在slave已经有该记录，又在master上插入了同一条记录
	- 删除从库重复的记录
-  在master上更新一条记录，而slave上找不到，丢失了数据
	- 从库补充数据,跳过`set global sql_slave_skip_counter=1;`

## 恢复relay-log日志
从库有两个线程,一个是`Slave_IO_Running`,一个是`Slave_SQL_Running`
### Slave_IO_Running ：接收master的binlog信息
- Master_Log_File
- Read_Master_Log_Pos
### Slave_SQL_Running：执行写操作
- Relay_Master_Log_File
- Exec_Master_Log_Pos
```bash
stop slave;
# MASTER_LOG_FILE对应Relay_Master_Log_File,MASTER_LOG_POS对应Exec_Master_Log_Pos
CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000001',MASTER_LOG_POS=1609;
start slave;
show slave status\G;
```

## mysql自定义dock镜像
```bash
FROM mysql:5.7
RUN sed -i "s@http://deb.debian.org@http://mirrors.aliyun.com@g" /etc/apt/sources.list \
	&& sed -i "s@http://security.debian.org@http://mirrors.aliyun.com@g" /etc/apt/sources.list \
	&& rm -Rf /var/lib/apt/lists/* \
	&& apt-get update \
	&& apt-get install vim -y \
	&& apt-get install iputils-ping -y \
	&& apt-get install net-tools -y \
	&& apt-get install ssh -y 
```








