```sql
#查看线程数
status
#查看线程详细信息
show processlist;
#查看mysql最大连接数
SHOW VARIABLES LIKE 'max_connections';
#查看线程相关变量
SHOW STATUS LIKE 'Threads%';
```