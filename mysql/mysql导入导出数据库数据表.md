## 参考
- https://www.cnblogs.com/yuzhoushenqi/p/7066317.html

## 常用命令
```bash
# 导出一个数据库结构,不包括数据
mysqldump -d dbname -uroot -p > dbname.sql
# 导入数据库
create database dbname # dbname不存在时,需要创建
use dbname
source dbname.sql
```