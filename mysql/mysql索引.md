## 索引
- 索引是数据库表记录引用的指针
- 唯一索引是指索引字段的值只能唯一的
- 复合索引也就是多列索引,由多个列组成的索引

## 聚集索引和非聚集索引
- 聚集索引,一般是指以主键作为节点的key值,建立的b+树,并且叶子节点保存了所有字段的数据,,通过聚集索引可以直接获取数据,不需要回表进行二次查询,一个表只能一个聚集索引,索引的排序和记录的排序是一致的
- 非聚集索引只包含索引字段+主键字段，所以如果在使用非聚集索引后还需要使用其他字段的（包括在where条件中或者select子句中），则需要通过主键索引回表到聚集索引获取其他字段,如果是非聚集索引可以满足SQL语句的所有字段的，则被称为全覆盖索引，没有回表开销
- 回表是一个通过主键字段重新查询聚集索引的过程

## 索引优化(原则)
- 应该选择基数大的字段作为索引
- 数据类型要和索引字段类型一致,如果varchar字段,用数字查询不能使用索引
- 多列索引需要遵循左侧前缀匹配原则,多列索引组成一个索引,比较的时候是从左到右匹配 
- 不在索引列做计算
- 在频繁查询的字段建立索引

## 索引的缺点
- 需要维护索引文件,占物理空间
- 影响增删改性能

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
drop index index-name on users;
```


## 其他
https://blog.csdn.net/qq_35495339/article/details/89304012
- `in`,`or`可以命中索引,`in`比`union all`消耗更多cpu,但是一般推荐用`in`
- 负向条件不可以应用索引,包括`!=`、`<>`、`not in`、`not exists`、`not like`,可以优化为`in`查询
- 最左侧查询需求，并不是指 SQL 语句的 where 顺序要和联合索引一致
- 范围查询可以使用索引,但是范围列后面的列无法用到索引,例如联合索引 (empno、title、fromdate,其中sql语句为`select * fromemployees.titles where emp_no < 10010' and title='Senior Engineer'and from_date between '1986-01-01' and '1986-12-31'`,那么只有 emp_no 可以用到索引，而 title 和 from_date 则使用不到索引
- 

