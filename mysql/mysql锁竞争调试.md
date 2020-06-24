## 查看表级锁竞争情况
```sql
SHOW STATUS LIKE '%Table_locks%'
#输出如下:
Table_locks_immediate
3538146549
Table_locks_waited
6021147
```
Table_locks_immediate 指的是能够立即获得表级锁的次数，而Table_locks_waited指的是不能立即获取表级锁而需要等待的次数

## 查看当前锁住的表
```sql
show OPEN TABLES where In_use > 0;
```