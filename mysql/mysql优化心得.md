## 优化总结
- 配置参数调优，例如mysql最大连接数默认为100，在并发数比较高的时候，连接会不够用
- 复杂sql关联优化，减少多张表的关联，一般是限制到两三张表关联，第一为了以后能够减少分库分表复杂性，第二个是多张表关联查询时，有时候不同版本执行计划不一样，不会执行我们设置的索引执行，拆分细的sql语句可以避免这种情况
- 最重要的是索引优化，索引优化主要从选择和使用两个方面，在选择哪些列作为索引时，一般选择基数大的列和被作为查询条件到的列建立索引，另外如果是多表关联查询，一般会选择关联条件的列作为索引；在使用方面需要注意的是，索引的列不能参与计算，数据类型和索引列的类型必须要一致，复合索引需要遵循左侧匹配原则，如果是字符串建立索引，需要控制索引长度，索引的底层是b+树，操作系统每一个内存页为4096个字节，存放的key是有限的，所以索引长度不能太大，避免`select *`写法，如innodb如果满足覆盖索引条件，则可以不需要二次回表查询

## 如何选择索引
- 一般是在where和order by涉及的列建立索引，关联表的关联列一般可以作为索引
- 选择基数大的，例如性别就不适合做索引
- 字符串建立索引应考虑索引的长度

## 如何查看索引是否有效或者优化要如何入手
- 通过`explain`查看sql的执行计划，重点查看影响的行数


## 如何确定索引长度
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



