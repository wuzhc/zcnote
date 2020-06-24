## 相关连接
- https://github.com/xingwenge/canal-php
- https://github.com/alibaba/canal

## 1.0 mysql配置
```bash
vi my.cnf
[mysqld]
# 开启 binlog
log-bin=mysql-bin 
# 选择 ROW 模式
binlog-format=ROW
# 配置 MySQL replaction 需要定义，不要和 canal 的 slaveId 重复
server_id=1 
# 用于mysql，记录原生sql，便于canal-php客户端回放
binlog-rows-query-log-events=true
# 用于MariaDB，记录原生sql，便于canal-php客户端回放
binlog_annotate_row_events=true 
```
其他命令
```mysql
# 查看是否开启biglog，对应my.cnf的log-bin=mysql-bin
show variable like 'log_bin'
```

### mysql创建canal用户
```mysql
CREATE USER canal IDENTIFIED BY 'canal';  
GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'canal'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'canal'@'%' ;
FLUSH PRIVILEGES;
```

## 2.0 canal配置
软件地址：http://127.0.0.1:8089/#/canalServer/nodeServers
/home/wuzhc/Documents/software/canal

### 修改canal配置文件
主要修改自己数据库的信息，如IP地址等等
```bash
cd canal/logs/example
vi instance.properties
```

### 配置说明如下
canal-2/conf/canal.properties
```bash
canal.register.ip =
canal.port = 11113 #canal-server的端口，客户端可以直接连接这个地址

# canal-admin配置说明
#canal.admin.manager = 127.0.0.1:8089
canal.admin.port = 11115 #用于提供给canal-admin访问的端口
canal.admin.user = admin #canal-admin的用户
canal.admin.passwd = 4ACFE3202A5FF5CF467898FC58AAB1D615029441 #canal-admin的密码，可以在mysql查看

canal.zkServers = 127.0.0.1:2181 #zk集群服务器端口
```

### 启动canal
```bash
# 启动
bin/startup.sh
# 查看 server 日志
cat logs/canal/canal.log
# 查看 instance 的日志
logs/example/example.log
# 关闭
bin/stop.sh
```

## 3.0 canal-admin配置
https://github.com/alibaba/canal/wiki/Canal-Admin-Guide
软件地址：/home/wuzhc/Documents/software/canal.admin-1.1.4
访问地址：http://127.0.0.1:8089/#/canalServer/nodeServers
账号密码：admin admin

### 主要步骤
```bash
# https://github.com/alibaba/canal/wiki/Canal-Admin-QuickStart
vi conf/application.yml
source conf/canal_manager.sql
sh bin/startup.sh
cat logs/admin.log
sh bin/stop.sh
```

### instance说明
只需要配置一个instance即可，集群中多个server会去抢占执行instance实例


## zk启动
软件地址：/home/wuzhc/Documents/software/apache-zookeeper-3.6.0-bin
启动：
```bash
./bin/zkServer.sh start-foreground
```



