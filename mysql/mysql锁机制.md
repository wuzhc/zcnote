## mysql有哪些类型的锁
### 参考
- https://www.iteye.com/blog/chenzhou123520-1863407
- https://www.toutiao.com/a6725582821609439748/?tt_from=weixin&utm_campaign=client_share&wxshare_count=1&timestamp=1568594502&app=news_article&utm_source=weixin&utm_medium=toutiao_android&req_id=201909160841420100230281580C36C579&group_id=6725582821609439748

### 表级锁和行级锁
myisam只支持表锁,而innodb支持表级锁和行级锁   

- 表级锁
    - 锁住整个表,不会发生死锁
    - 锁粒度大
    - 加锁快,开销小
- 行级锁
    - 锁住某一行,会发生死锁
    - 粒度小
    - 加锁慢,开销大
    - 并不是对记录行加锁,而是对行对应的索引进行加锁
    - 如果sql语句没有使用到索引,会通过隐藏的聚簇索引来对记录进行加锁,对聚簇索引加锁，其加锁效果和表锁一样,因为找到一条记录需要扫描全表,要扫描全表就得锁表  

    

### 行级锁的共享锁和排它锁

- 共享锁（其他事务只读不能写）
	- 又叫`S锁`或`读锁`
	- 当前线程对共享资源加锁后,其他线程可以读取,但不能修改
	- 语法:`select id from table in share mode`
- 排它锁 （其他事务不能读不能写）
	- 又叫`X锁`或`写锁`
	- 当前线程对共享资源加锁后,其他线程不可以读取或修改
	- 语法:`select * from t_table for update`
	- 数据库的增删改操作默认都会加排他锁
#### 操作过程：
```sql
set autocommit = 0;
select * from table for update;
commit;
```



### 加锁方式

### 行级锁

- 对于UPDATE、DELETE、INSERT语句，自动给相关数据加上排他锁
- 对于普通的SELECT语句，不加锁，属于快照读

### 表级锁

```mysql
lock tables table_name read/write
unlock tables
```



### 乐观锁和悲观锁

乐观锁与悲观锁是逻辑上的锁。

- 乐观锁
  - 乐观锁认为一般情况下数据不会造成冲突，所以在数据进行提交更新时才会对数据的是否冲突进行检测 
  - 实现方式:版本号机制,在表中增加version字段,第一次读取version,第二次更新的时候检测version是否在数据库发生变化,如果变化了,就不予更新操作
  - mysql使用了以乐观锁的理论基础的mvcc多版本并发控制来避免不可重复读和幻读
- 悲观锁
  - 实现方式:依赖于数据库的锁机制,如行锁,读锁,写锁；悲观锁其实就是我们写锁，一当一个事务持有了写锁，其他事务就不能读和写

  

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

### 查看当前锁住的表

```sql
show OPEN TABLES where In_use > 0;
```


## 死锁问题

指两个或两个以上的进程在执行过程中,因争夺资源而造成的一种互相等待的现象

### 查看死锁情况

```mysql
Show engine innodb status\G
```

### 如何终止死锁

```mysql
select @@tx_isolation;
#当前库的线程情况
show processlist;
#没有看到正在执行的慢SQL记录线程，再去查看innodb的事务表INNODB_TRX
SELECT * FROM information_schema.INNODB_TRX;
#查看下在锁的事务,看下里面是否有正在锁定的事务线程，看看ID是否在show full processlist里面的sleep线程中，如果是，就证明这个sleep的线程事务一直没有commit或者rollback而是卡住了，我们需要手动kill掉。
kill  100
SELECT CONCAT_WS('','kill',' ',t.trx_mysql_thread_id,';')a FROM information_schema.INNODB_TRX t;
```

