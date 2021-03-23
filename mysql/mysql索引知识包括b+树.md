## 参考
- https://www.toutiao.com/i6732776474308248072/
- https://www.cnblogs.com/jie-y/p/11153480.html
- https://www.cnblogs.com/kkbill/p/11381783.html

## 为什么要用索引？
索引用于加速查询速度



## 索引的缺点
- 需要维护索引文件,占物理空间
- 影响增删改性能



## 数据存储文件

### 对于MyISAM存储引擎来说
- `.frm`后缀的文件存储的是表结构。
- `.myd`后缀的文件存储的是表数据。
- `.myi`后缀的文件存储的就是索引文件。
### 对于InnoDB 存储引擎来说:
- `.frm`后缀的文件存储的是表结构。
- `.ibd`后缀的文件存放索引文件和数据(需要开启innodb_file_per_table 参数)



## myisam和innodb从索引方面上来说有什么区别？

https://www.cnblogs.com/jie-y/p/11153480.html
- myisam主索引和数据是分开的，innodb数据文件本身就是主索引文件
- myisam的主索引文件和辅助索引文件结构一样，叶子节点保存行数据的物理地址
- innodb的主索引文件是按主键构造的`b+`树（也叫聚簇索引），叶子节点保存行数据；辅助索引的叶子节点保存主键值

## 聚簇索引
`聚簇索引`并不是一种索引类型，也是一种数据存储方式，它按照主键的顺序构建`b+树`，行数据存放在叶子节点上
### 聚簇索引的缺点
- 页分裂会导致表占用更多的磁盘空间；假如磁盘中的某一个已经存满了，但是新增的行要插入到这一页当中，存储引擎就会把该也分裂成两个页面来容纳该行，这就是一次页分裂操作。页分裂会导致表占用更多的磁盘空间

## 什么是二级索引？
对于非主键列其他列建立的索引就是二级索引

## 聚簇索引和二级索引有什么区别？
- 聚簇索引的叶子节点存放行数据，二级索引的叶子节点存放索引列的值和主键
- 二级索引需要回表查询，也就是二次查询，而聚簇索引不需要
![http://p1-tt.byteimg.com/large/pgc-image/818ae93727da4ced81edc2ba548541bb?from=pc](http://p1-tt.byteimg.com/large/pgc-image/818ae93727da4ced81edc2ba548541bb?from=pc)

## 为什么选择B+树作为数据库索引结构？
https://www.cnblogs.com/kkbill/p/11381783.html
首先需要理解的是`b树`和`b+树`的区别；
### b树
b树就是平衡的多路搜索树，b树通常意味着所有的值都是按顺序存储的，并且每一个叶子也到根的距离相同，所谓的m阶B树，即m路平衡搜索树；一颗m阶b树满足以下条件：
- 每个结点至多含有m个分支节点（m>=2）。
- 除根结点之外的每个非叶结点，至少含有m/2个分支。
- 若根结点不是叶子结点，则至少有2个孩子。
- 一个含有k个孩子的非叶结点包含k-1个关键字。 （每个结点内的关键字按升序排列）
所有的叶子结点都出现在同一层。实际上这些结点并不存在，可以看作是外部结点。
- 所有的叶子结点都出现在同一层。
### b+树相对于b树的区别
- 叶子结点包含全部关键字以及行记录数据（或指针）
- 叶子结点连接在一起，组成一个链表，利于范围搜索
- 非叶子结点不存放真正的数据，只存放关键字，利于同样大小的磁盘页可以容纳更多的关键字（节点元素），相对应的树的高度就越小，发生io的次数就越少

## 索引优化(原则)
- 应该选择基数大的字段作为索引
- 数据类型要和索引字段类型一致,如果varchar字段,用数字查询不能使用索引
- 多列索引需要遵循左侧前缀匹配原则,多列索引组成一个索引,比较的时候是从左到右匹配 
- 不在索引列做计算
- 字符串做索引需要避免索引长度过长问题（mysql的索引底层是一个b+树，每个节点对应一个磁盘页，能够容纳的大小是有限，如果索引越小，就能容纳更多key，树的高度就越低，发出io次数就越少，性能就越高）

## 常用索引命令
```sql
# 查看表所有索引
show index from users;
# 创建索引,如果是CHAR，VARCHAR类型，length可以小于字段实际长度；如果是BLOB和TEXT类型，必须指定 length
create index index-name on users(name(10));
# 创建唯一索引
create unique index index-name on users(name(10))
# 创建索引
alter table users add index index-name(name(10));
alter table users add primary key(id);
alter table users add unique index-name(name(10));
# 删除索引
alter table users drop index index-name;
drop index index-name on users;
```

## 其他
https://blog.csdn.net/qq_35495339/article/details/89304012
- `in`,`or`可以命中索引,`in`比`union all`消耗更多cpu,但是一般推荐用`in`
- 负向条件不可以应用索引,包括`!=`、`<>`、`not in`、`not exists`、`not like`,可以优化为`in`查询 
- 最左侧查询需求，并不是指 SQL 语句的 where 顺序要和联合索引一致
- 范围查询可以使用索引,但是范围列后面的列无法用到索引,例如联合索引 (empno、title、fromdate,其中sql语句为`select * fromemployees.titles where emp_no < 10010' and title='Senior Engineer'and from_date between '1986-01-01' and '1986-12-31'`,那么只有 emp_no 可以用到索引，而 title 和 from_date 则使用不到索引
- 

