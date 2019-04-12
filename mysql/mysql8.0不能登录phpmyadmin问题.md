MYSQL8.0的密码验证方式从mysql_native_password改为了caching_sha2_password。而目前为止，php的pdo和mysqli应该还是不支持的。

### 解决如下:
```sql
use mysql；
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '123456';  
FLUSH PRIVILEGES;  
```
然后就可以用root,12356登录phpmyadmin

