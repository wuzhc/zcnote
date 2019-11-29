# Mysql
## mysql有哪些类型的锁
### 参考
- https://www.iteye.com/blog/chenzhou123520-1863407
- https://www.toutiao.com/a6725582821609439748/?tt_from=weixin&utm_campaign=client_share&wxshare_count=1&timestamp=1568594502&app=news_article&utm_source=weixin&utm_medium=toutiao_android&req_id=201909160841420100230281580C36C579&group_id=6725582821609439748

### 表级锁和行级锁
> myisam只支持表锁,而innodb支持表级锁和行级锁   
- 表级锁
    - 锁住整个表,不会发生死锁
    - 锁粒度大
    - 加锁快,开销小
- 行级锁
    - 锁住某一行,会发生死锁
    - 粒度小
    - 加锁慢,开销大
    - 并不是对记录行加锁,而是对行对应的索引进行加锁
    - 如果sql语句没有使用到索引,会通过隐藏的聚簇索引来对记录进行加锁,对聚簇索引加锁其加锁效果和表锁一样,因为找到一条记录需要扫描全表,要扫描全表就得锁表  

### 共享锁和排它锁
- 共享锁
	- 又叫`S锁`或`读锁`
	- 当前线程对共享资源加锁后,其他线程可以读取,但不能修改
	- 语法:`select id from table in share mode`
- 排它锁
	- 又叫`X锁`或`写锁`
	- 当前线程对共享资源加锁后,其他线程不可以读取或修改
	- 语法:`select * from t_table for update`
	- 数据库的增删改操作默认都会加排他锁
#### 操作过程
```sql
set autocommit = 0;
select * from table for update;
commit;
```

### 乐观锁和悲观锁
> 乐观锁与悲观锁是逻辑上的锁。
- 乐观锁
	- 实现方式:版本号机制,在表中增加version字段,第一次读取version,第二次更新的时候检测version是否在数据库发生变化,如果变化了,就不予更新操作
- 悲观锁
	- 实现方式:依赖于数据库的锁机制,如行锁,读锁,写锁 