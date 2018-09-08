# mysql
### mysql工作流程
- client发送sql查询到mysql server
- 查询缓存,如果命中缓存返回
- sql解析(检测关键字),预处理(检测数据库表,列,别名),然后优化器生成执行计划
- 根据执行计划调用存储引擎执行查询
- 返回结果

### 用户和权限管理


### sql执行计划
- show profiles
```sql
set profiling = 1                 # 开启profile
reset query cache                 # 清除查询缓存
show profiles
show profile for query <query_id> # 查看某个查询sql
```
- explain
```sql
explain sql
```
查看id,key,rows,type,extra简单说明下:
- id值相同,执行顺序从上往下,id值越大,执行顺序优先级越高
- key表示本次查询用到的索引
- rows表示本次查询扫描过的记录数
- type有all,index,range,ref,eq_ref,const,system,null,由左到右性能越好
    - all全表扫描
    - index只扫描索引树
    - range范围扫描
    - ref非唯一索引扫描
    - eq_ref唯一索引扫描,例如根据主键查询
    - const,system出现在表中只有一行记录时
    - null不需要访问表或索引
- extra
    - using filesort 文件排序
    - using temporary 临时表
    
#### 文件排序(using filesort)
> mysql会根据索引排序,当不能使用索引时,如果数据量小于排序缓存区,直接使用内存快速排序,否则将数据分块,将每个数据块排序结果存放磁盘,最后再合并返回
[mysql排序过程](http://note.youdao.com/noteshare?id=5fff060484622be57c2714e6ed60c7a2)

### 索引
#### 不能使用索引
- 负向条件不能使用索引,用in
- 前缀模糊匹配不能使用索引,例如'like %name',改为'like name%'
- 选择性小的不宜作为索引
- 索引列不要做运算操作
- 多列索引遵循前缀原则,最左的列必定是频繁查询的列
- 避免使用默认值null,索引树不包含null记录,也就是说null查询会导致全表扫描,例如select * from account where name is null导致全表扫描(全表1722608行记录),select * from account where name = ''只扫描了7行记录

#### 选择索引
- 一般是在where和order by涉及的列建立索引
- 不要每个列都建立索引,太多的索引会影响插入,删除,更新的效率,根据数据的选择性建立
- 字符串建立索引应考虑索引的长度

#### 确定索引长度
```sql
create table city (
  id int(11) not null auto_increment,
  name varchar(50) character set utf8 collate utf8_general_ci not null comment '城市名',
  primary key (id)
) engine = InnoDB charset = utf8 collate utf8_general_ci comment '城市表';

select count(distinct left(city,3))/ count(*) as sel3,
	   count(distinct left(city,4)) /count(*) as sel4,
	   count(distinct left(city,5)) /count(*) as sel5,
	   count(distinct left(city,6)) /count(*) as sel6
from city;
```
比较sel3,sel4,sel5,sel6,值越大也好(也要考虑下索引长度,平衡下选择合适的长度)

#### 优化场景
1. 首先explain查看sql的执行计划,重点看key和rows
2. 如果rows扫描过多查看是否建立索引,或者是否正确使用了索引(效果最显著)
3. 查看查询条件,如果查询条件是否全表扫描,在业务上调整(时间范围问题)
4. 复杂的sql语句拆分多条sql,例如一条sql关联的很多张表会产生临时表,避免临时表(查询大量数据时候)
5. 多条sql遍历插入改为批量插入(交卷的时候)
6. 遍历查询改为批量查询
7. 统计类数据建立计数表
8. 使用mongo保存关联数据,简单的单表查询,配合aggregate可以做复杂的聚合统计
9. 使用redis保存热点数据
10. select * 问题(数据量大的时候内存占用很明显)
11. optimize定期优化表,表含有可变长度的列(如varchar),并且经常性删除或修改记录,使用optimize将对空间碎片进行合并
12. 分拆很长的列：一般情况下，TEXT、BLOB，大于512字节的字符串，基本上都是为了显示信息，而不会用于查询条件， 因此表设计的时候，应该将这些列独立到另外一张表
13. 有时候排序或分组交给php处理,避免临时表 (如获取每个地区数据之后,再用array_multisort)

### 事务

### 慢查询日志
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
mysqldump日志分析:
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

### sql语句
```sql
# 优化表
optimize table <table>

# 查看表索引
show keys from <table>

# 建立索引
alter table <table> add index <index> (field(len),field2,field3)

# 删除索引
alter table <table> drop index <index>

# 导出整个数据库
mysqldump -u dbuser -p dbname > dbname.sql

# 导出整个数据库结构
mysqldump -u dbuser -p -d --add-drop-table dbname > dbname.sql

# 导出数据库表
mysqldump -u dbuser -p dbname dbtable > dbtable.sql

# 导入sql文件(进到数据库)
use dbname
source dbname.sql

# on duplicate key update 当插入的数据导致唯一索引或主键出现重复值,则执行update,否则执行insert
insert into table(a,b,c) values(1,2,3) on duplicate key update d = c+1
相当于
update table set d = c + 1 where a = 1 or b =2

# 统计每天数据量
select date_format(create_date,'%Y-%m-%d') as oneday,count(*) as total from user group by oneday;

# 统计今天数据量 (to_days返回一个天数)
select count(*) as total from user where to_days(now()) = to_days(create_date)

# 统计7天数据量
select count(*) as total from user where date_sub(curdate(), interval 7 day) < date(create_date)

# 统计上一个数据量
select count(*) as total from user where period_diff(date_format(now(),'%Y-%m'), date_format(create_date, '%Y-%m')) = 1
```

# 学习链接
[php中mysql操作的buffer知识](http://www.cnblogs.com/yjf512/p/3431481.html)