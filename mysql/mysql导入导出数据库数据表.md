## 参考
- https://www.cnblogs.com/yuzhoushenqi/p/7066317.html

## 常用命令
```bash
# 导出一个数据库结构,不包括数据,-d结构
mysqldump -d dbname -uroot -p > dbname.sql
# 导出多个数据库结构
mysqldump -d -B db1 db2 -uroot -p > dbname.sql
# 导出数据库数据，-t数据
mysqldump -t db -uroot -p > dbname.sql
# 导出数据库表结构和数据
mysqldump db -uroot -p > dbname.sql
# 导出一个数据库多个表结构
mysqldump -d -B db --tables table1 table2 -uroot -p > dbname.sql
# 导出一个数据库一张表结构和数据
mysqldup db table -uroot -p > dbname.sql
# 导入数据库
create database dbname # dbname不存在时,需要创建
use dbname
source dbname.sql
```

- -d 结构(--no-data:不导出任何数据，只导出数据库表结构)
- -t 数据(--no-create-info:只导出数据，而不添加CREATE TABLE 语句)
- -R (--routines:导出存储过程以及自定义函数)
- -E (--events:导出事件)
- --triggers (默认导出触发器，使用--skip-triggers屏蔽导出)
- -B (--databases:导出数据库列表，单个库时可省略）
- --tables 表列表（单个表时可省略）