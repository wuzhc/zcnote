## 发生条件
https://www.cnblogs.com/my_life/articles/10219594.html
两个或多个事务在同一资源上相互占用并请求锁定对方占用的资源，从而导致恶性循环的现象，例如：
- 客户端A: 拿着锁S，等待着客户端B释放锁X。
- 客户端B: 拿着锁X，等待着客户端A释放锁S。
```sql
create table t (i int) engine=innodb;
insert into t(i) values(1)
# 客户端A 
start transaction;
select * from t where i = 1 lock in share mode;
# 客户端B
start transaction;
delete from t where i = 1;
```

## 发生死锁怎么办
- 超时等待
- wait-for-graph（等待图）,死锁碰撞检测，是一种较为主动的死锁检测机制,需要维护事务等待链表和锁的信息链表
![https://img-blog.csdn.net/20180908151930581?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L25vYW1hbl93Z3M=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70](https://img-blog.csdn.net/20180908151930581?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L25vYW1hbl93Z3M=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
![https://img-blog.csdn.net/20180908152816317?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L25vYW1hbl93Z3M=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70](https://img-blog.csdn.net/20180908152816317?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L25vYW1hbl93Z3M=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
有4个事务，所以对应4个节点T1、T2、T3、T4； 
- 由（1）得出：节点T1指向节点T2； 
- 由（2）得出：节点T2分别指向节点T1、T4； 
- 由（3）得出：节点T3指向节点T1、T2、T4；

`innodb`存储引擎会将持有最小写锁的事务进行回滚，在应用程序中进行`try-catch`进行异常回滚处理即可，例如上面的例子，最终客户端B会报如下错误，然后B进行回滚，A继续正常执行
```
ERROR 1213 (40001): Deadlock found when trying to get lock;
try restarting transaction
```

## 查看是否有死锁
通过查看日志（`SHOW ENGINE INNODB STATUS`）是否存储`deadlock`，或者通过命令查看
```sql
# 查看是否有锁表
show open tables where in_use>0;
# 查询进程(super可以查看所有线程，如果有线程堵住，可以使用kill id关闭线程)
show processlist;

# 查看当前的事务
SELECT * FROM INFORMATION_SCHEMA.INNODB_TRX;
# 查看当前锁定的事务
SELECT * FROM INFORMATION_SCHEMA.INNODB_LOCKS;
# 查看当前等锁的事务
SELECT * FROM INFORMATION_SCHEMA.INNODB_LOCK_WAITS;
```



