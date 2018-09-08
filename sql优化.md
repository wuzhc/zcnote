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
