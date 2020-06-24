## 参考
https://www.jianshu.com/p/f0905f36e9c3
https://zhuanlan.zhihu.com/p/104254647
https://www.cnblogs.com/yihuihui/p/11386679.html
https://www.jianshu.com/p/a1344ca86e9b

## 杂的知识点
- `influx`的cli连接的端口是8086
- influxdb的存储模型，`measurement+tag set+field key`作为key，`field value`作为value，如果没有field则没有了对应的value了，所以`field`是必填的，`tag`是可选的

## 基本概念
- measurement 相当于table
- point 相当于row
- point = `time` + `tags` + `fields`
- field 必填的，`field value`通常都是与时间关联的，fields相当于SQL的没有索引的列
- tag `tag`是有索引的，`tags`相当于SQL中的有索引的列。tag value只能是string类型
- series `Retention policy` + `Measurement` + `Tag set`组成
### 对point的理解
point相当于一行数据，每个point是根据 timestamp + series 来保证唯一性。`point = time + tags + fields`，其中的tag用来检索，field用来记录一些信息，measurement用来将相同类型的数据归集

## 函数
- 聚合函数：fill(), integral()，spread()， stddev()，mean(), median()等。
- 选择函数: sample(), percentile(), first(), last(), top(), bottom()等。
- 转换函数: derivative(), difference()等。
- 预测函数：holt_winters()。
- `spread(field_key)` 计算数值字段的最大值和最小值的差值。
- `percentile(field_key, N)` 选取某个字段中大于N%的这个字段值。
- `sample(field_key, N)` 随机返回field key的N个值。如果语句中有GROUP BY time()，则每组数据随机返回N个值
- `cumulative_sum(field_key)` 计算字段的递增和
- ` derivative(field_key,unit)` 计算字段值的变化比，uint默认为1s，计算公式为`(2.116-2.064)/(3*60) = 0.00014`

## 常用命令
```bash
#进入influxdb
#-precision
influx -precision rfc3339

#创建用户和密码
create user <user> with password '123456'
grant all privileges on <database> to <user>

#每个数据库可以有多个过期策略
show retention policies on "db_name"
#创建保留策略
create retention policy "tow_hour" on testdb duration 2h replication 1
create retention policy "tow_day" on testdb duration 2d replication 1

#查询cq
show continuous queries  
#创建cq
create continuous query "cq_avg_time" on testdb
begin 
    select mean("cost_time") as "avg_cost_time" into "tow_day"."log2" from log 
    group by cost_time(1m) 
end

CREATE CONTINUOUS QUERY cq_avg_time ON testdb BEGIN SELECT mean(cost_time) AS cost_time INTO tow_day.log2 FROM log GROUP BY cost_time(1m) END
#删除cq
drop continuous query "cq_avg_time" on testdb

#创建数据库，过期时间为30天
create database testdb2 with duration 30d

#查看所有表
show measurements

#获取表中的tag keys
show tag keys on <database> from userlog
#获取表中的tag values
show tag values from userlog with key="app"
 
#查看field keys
show field keys on <database> from <measurement>

#查看series
show series on <database> from <measurement>

#聚合分组
#limt 1表示每个measurement+tags只显示第条time记录
#slimit 1表示只显示一个measurement+tags
select sum(rate) from userlog group by time(20m),uid fill(2000) limit 1
```

## 存储引擎 （Timestamp-Structure Merge Tree）
存储引擎包含四部分`cache`、`wal`、`tsm file`、`compactor`
- cache：插入数据时，先往 cache 中写入再写入wal中，可以认为 cache 是 wal 文件中的数据在内存中的缓存，cache 中的数据并不是无限增长的，有一个 maxSize 参数用于控制当 cache 中的数据占用多少内存后就会将数据写入 tsm 文件。如果不配置的话，默认上限为 25MB
- wal：预写日志，对比MySQL的 binlog，其内容与内存中的 cache 相同，作用就是为了持久化数据，当系统崩溃后可以通过 wal 文件恢复还没有写入到 tsm 文件中的数据，当 InfluxDB 启动时，会遍历所有的 wal 文件，重新构造 cache。
- tsm file：每个 tsm 文件的大小上限是 2GB。当达到 cache-snapshot-memory-size,cache-max-memory-size 的限制时会触发将 cache 写入 tsm 文件。
- compactor：主要进行两种操作，一种是 cache 数据达到阀值后，进行快照，生成一个新的 tsm 文件。另外一种就是合并当前的 tsm 文件，将多个小的 tsm 文件合并成一个，减少文件的数量，并且进行一些数据删除操作。 这些操作都在后台自动完成，一般每隔 1 秒会检查一次是否有需要压缩合并的数据。

### 存储目录
influxdb的数据存储有三个目录，分别是meta、wal、data：
- meta 用于存储数据库的一些元数据，meta 目录下有一个 meta.db 文件；
- wal 目录存放预写日志文件，以 .wal 结尾；
- data 目录存放实际存储的数据文件，以 .tsm 结尾。

## 主题问题
- where子句如果是字符串需要引号，例如`select * from t where "name" ='wuzhc'`,name需要双引号，wuzhc需要单引号


