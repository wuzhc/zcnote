> mysql的用户信息保存在mysql库的user表

## 命令
```sql
# 查找用户
select User,Host,Password from mysql.user where User = "wuzhc";

# 创建wuzhc用户,密码为123456,host为%
create user wuzhc indetified by "123456";
# 或者
insert into mysql.user(Host,User,Password) Values('%','wuzhc',password('123456'));
flush privileges;

# 修改密码
update mysql.user set Password = password('123456') where User = 'wuzhc' and Host = '%';
flush privileges;

# 删除用户
drop user wuzhc@'%';

# 授权(授权哪个库哪个表的哪些权限给哪个用户),具体权限类型如下所示
grant all privileges on dbnane.* to wuzhc@'%' indentified by 'wuzhc';
flush privileges;

# 查看用户有哪些权限
show grants for wuzhc;
```

## 授权类型
- `all privileges` 所有权限
- `select` 读权限
- `update`
- `delete`
- `create` 创建表权限
- `drop` 删除数据库,数据表权限



## 问题
### 新建的用户的Host为%,可以不用密码登录问题
```sql
# 主要是有空用户存在,删除空用户
delete from mysql.user where user = "";
flush privileges;
```