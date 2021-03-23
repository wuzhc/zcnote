```sql
insert ... on duplicate key update
```

这是mysql特有的语句，`on duplicate key update` 当插入的数据导致唯一索引或主键出现重复值,则执行update,否则执行insert，主要目的是为了解决并发下，两个sql语句分开执行会导致数据不完整性问题。



## 例子一

例如，如果列 a 为 主键 或 拥有UNIQUE索引，并且包含值1，则以下两个语句具有相同的效果：

 ```sql
INSERT INTO TABLE (a,c) VALUES (1,3) ON DUPLICATE KEY UPDATE c=c+1;
UPDATE TABLE SET c=c+1 WHERE a=1;
 ```

如果行作为新记录被插入，则受影响行的值显示1；如果原有的记录被更新，则受影响行的值显示2。 



## 例子二

如果INSERT多行记录(假设 a 为主键或 a 是一个 UNIQUE索引列):

```sql
INSERT INTO TABLE (a,c) VALUES (1,3),(1,7) ON DUPLICATE KEY UPDATE c=c+1;
```

这条sql插入两条记录，首先插入（1,3），数据库没有a=1的记录，所以执行插入操作；接着插入（1,7），因为a=1的记录在前面一条已经插入成功了，所以此时执行的是更新操作，如下：

```sql
//已有记录a=1,c=3
update table set c=c+1 where a=1
```

所以执行结果是c=4



## 例子四

字段a被定义为UNIQUE，并且原数据库表table中已存在记录(2,2,9)和(3,2,1)，如果插入记录的a值与原有记录重复，则更新原有记录，否则插入新行

```sql
INSERT INTO TABLE (a,b,c) VALUES 
(1,2,3),
(2,5,7), //已存在（2,2,9）
(3,3,6), //已存在（3,2,1）
(4,8,2)
ON DUPLICATE KEY UPDATE b=VALUES(b); //values是取当前sql语句的值
```

以上SQL语句的执行，发现(2,5,7)中的a与原有记录(2,2,9)发生唯一值冲突，则执行ON DUPLICATE KEY UPDATE，将原有记录(2,2,9)更新成(2,5,9)，将(3,2,1)更新成(3,3,1)，插入新记录(1,2,3)和(4,8,2)



## 参考

<https://www.jb51.net/article/39255.htm>



