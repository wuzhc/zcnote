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
