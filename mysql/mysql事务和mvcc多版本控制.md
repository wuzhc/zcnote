## 参考
- https://blog.csdn.net/Waves___/article/details/105295060
- https://zhuanlan.zhihu.com/p/40208895
- https://www.toutiao.com/i6803930119472677388/

## 什么是事务？
> 一个逻辑单元一组操作,要么全部执行,要么全部不执行

## 流程控制
- begin transaction
- commit
- rollback

下面以php为例：
```php
$dsn = 'mysql:dbname=met;host=localhost';
$pdo = new PDO($dsn, 'root', '');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

try {
    $pdo->beginTransaction();
    $sql2 = "insert into swoole(`name`,`age`) values('roob',23)";
    echo $pdo->exec($sql2) ? 'yes' : 'no';
    echo "\n";
    $pdo->commit();
} catch (Exception $e) {
    echo $e->getMessage() . "\n";
    $pdo->rollBack();
}
```

## 事务四个特性
- 原子性(Atomicity): 一个事务中的所有操作要么全部执行,要么全部不执行
- 一致性(Consistency): 事务前后的数据必须保持一致性
- 隔离性(Isolation): 多个事务独立,不相互影响
- 持久性(Durability): 事务提交将保存到数据库

## 事务隔离级别:
mysql默认隔离为可重复读，`rr`，查看命令如下：
```sql
SELECT @@tx_isolation;
```
- 未提交读(read uncommitted),出现脏读， a事务读取到了b事务未提交的数据
- 提交读(read committed),出现不可重复读，同个事务前后两次查询结果不一致
- 可重复读(repeatable read),出现幻读，a事务读取一个范围内的数据包含了b事务的新增或删除的数据
- 串行化(serializable)

安全性: ru < rc < rr < s  
性能: ru > rc > rr > s

### 不可重复度和幻读有什么区别?
不可重复读的重点是修改，幻读的重点在于新增或者删除。

## MVCC多版本控制
大概了解一下：innodb行数据会有两个隐藏字段，分别为事务ID和回滚指针，其中回滚指针指向`undo log`链表，`undo log`保存了行数据的历史版本，每当更新或删除时都会写一条记录到`undo log`，事务从`undo log`最新记录开始搜索，拿`undo log`事务ID和`ReadView`比较，`ReadView`有3个字段，分别为活跃事务ID集合，活跃事务ID集合最小值，下一个即将分配的事务ID，如果小于最小值，说明数据可见，如果大于最大值，说明数据不可见，如果介于两者之间，需要分两种情况，rr级别下都不可见，rc级别下`undolog`事务ID存在活跃事务ID集合，说明`undo log`的数据未提交，不可见，反之说明可见

innodb数据行结构如下：
![https://pic3.zhimg.com/80/v2-e1844f5816a332018183559d1573d80e_720w.jpg](https://pic3.zhimg.com/80/v2-e1844f5816a332018183559d1573d80e_720w.jpg)
两个隐藏列：
- `DATA_TRX_ID` 最近修改改行的事务ID
- `DATA_ROLL_PTR` 回滚指针，指向`undo log`链表，该链表记录着行数据的历史版本

### ReadView
`ReadView`保存当前未提交的事务列表，不包括自己的事务ID，通过列表来判断记录的某个版本是否对当前事务可见，sql开始时就会创建`ReadView`,结构如下：
![https://pic1.zhimg.com/80/v2-7b3dc9ba4be387f086fc63f114031574_720w.jpg](https://pic1.zhimg.com/80/v2-7b3dc9ba4be387f086fc63f114031574_720w.jpg)
- `low_trx_id` 活跃事务集合中最大事务ID（下一个将被分配的事务ID）
- `up_trx_id` 活跃事务集合中最小事务ID 
- `trx_ids`  活跃事务集合， 在rr级别下，活跃事务集合中某个事务提交后，活跃四五集合保存不变，即`ReadView`的值保持不变
- 这里的事务链表指的是活跃事务ID集合

### 如何判断事务链表的数据对事务是否可见？
![https://pic4.zhimg.com/80/v2-77c276015661224f1ddaa0ce9be03d0f_720w.jpg](https://pic4.zhimg.com/80/v2-77c276015661224f1ddaa0ce9be03d0f_720w.jpg)
- 当`trx_id < up_trx_id`时，可见
- 当`up_trx_id <= trx_id <trx_id`时，rc级别下，如果`trx_id`存在事务列表ID集合中，不可见，反之可见，rr级别下都不可见
- 当`trx_id > low_trx_id`时，不可见

### RC和RR下ReadView有什么区别？
已提交读和可重复读的区别就在于它们生成ReadView的策略不同。
- RR隔离级别下，在每个事务开始的时候，会将当前系统中的所有的活跃事务拷贝到一个列表中(read view) 
- RC隔离级别下，在每个语句开始的时候，会将当前系统中的所有的活跃事务拷贝到一个列表中(read view) 

### MVCC有什么好处？
- 数据库读不会加锁，提高数据库的并发能力
- 保证多个事务的隔离性

### RR级别下是如何重现幻读

## 当前读和快照读是什么东西？
https://www.toutiao.com/i6803930119472677388/
在a事务中，select的语句是快照读，读取的历史版本数据，如果是update,insert,delete语句，读取的数据是当前版本，假设当前版本数据是被b事务修改过了并且b事务没有提交，这个时候a事务执行增删改会阻塞（进行当前读会加行锁和区间锁），直到b事务提交，在b事务提交之后读取到的是b事务提交的数据。
```
a事务：begin->b事务先修改了数据->update->等待b事务提交->update success
b事务：begin->   update     ->      ->commit       
```



## 说明
本文图片来源于https://zhuanlan.zhihu.com/p/40208895
