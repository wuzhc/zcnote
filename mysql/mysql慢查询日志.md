```sql
# 查看开启状态
show variables like 'slow_query_log'
# 开启(重启数据库会失效,需配置my.cnf)
set global slow_query_log = 1
# 查看日志文件
show variables like 'slow_query_log_file'
# 查看慢查询时间
show variables like 'long_query_time'
# 设置慢查询时间
set global long_query_time = 10
# 查看日志保存方式
show variables like 'log_output'
# 查看有多少条慢查询记录
show status like 'slow_queries'
```
#### mysqldump日志分析:
- s 按某种方式排序
- r 返回记录数
- c 访问次数
- t 查询时间
- -t n 前面n条记录
- -g 正则匹配
```sql
# 耗时最多的10条记录
mysqldump -s t -t 10 slow_query.log

# 访问次数最多的10记录
mysqldump -s c -t 10 slow_query.log
```
![](../images/slow_query.png)