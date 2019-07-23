phpmyadmin的配置文件是`config.inc.php`,主要参数如下:
```php
// phpmyadmin登录账号和密码,如果设置就不需要每次登录,但是从安全性角度上不建议把密码写到配置文件(auth_type为config时有效),注意这里的账号密码是mysql库中user表存在的用户和密码,不是自己随意更改的
$cfg['Servers'][$i]['user'] = 'root';
$cfg['Servers'][$i]['password'] = '';

// 是否允许无密码登录,应该是在password为空的时候才有需要设置吧
$cfg['Servers'][$i]['AllowNoPassword'] = true;

$cfg['Servers'][$i]['host'] = 'localhost'
$cfg['Servers'][$i]['port'] = 3306

// mysql套接字,通过mysql的status命令可以知道套接字,只能配合host为localhost有效(MySQL服务器必须和网站服务器在同一台服务器上)
$cfg['Servers'][$i]['socket'] = 'mysql.sock'

// 认证类型,有四种类型,`config`表示账号密码定义到配置文件,不需要账号密码就可以直接进入phpmyadmin,`http`和`cookie`是通过账号密码登录认证,`signon`不懂
$cfg['Servers'][$i]['auth_type'] = 'config'

// 允许登录界面输入mysql地址
$cfg['AllowArbitraryServer'] = true;    
```

## phpmyadmin账号密码登录问题
第一次安装phpmyadmin后,查看`config.inc.php`,如果`auth_type`为`config`,则直接使用配置文件的user和password即可;如果要使用账号密码登录,则`auth_type`设置为`cookie`或`http`,默认情况下mysql会有root用户,密码为空,你可以直接进入到mysql控制台,然后修改root的密码,命令如下:
```mysql
mysql -uroot -proot
use mysql
set password for root@localhost = password('123456');
```

## 使用docker
https://github.com/phpmyadmin/docker

```bash
docker run --name myadmin -d -e PMA_ARBITRARY=1 -p 8080:80 phpmyadmin/phpmyadmin
```
-e为环境变量,更多环境变量如下:
- PMA_ARBITRARY - 对应`$cfg['AllowArbitraryServer']`,为1时可以输入mysql地址
- PMA_HOST - 定义MySQL服务器的地址/主机名,对应`$cfg['Servers'][$i]['host']`
- PMA_VERBOSE - 定义MySQL服务器的详细名称
- PMA_PORT - 定义MySQL服务器的端口,对应`$cfg['Servers'][$i]['port']`
- PMA_HOSTS - 定义逗号分隔的MySQL服务器的地址/主机名列表
- PMA_VERBOSES - 定义以逗号分隔的MySQL服务器详细名称列表
- PMA_PORTS - 定义以逗号分隔的MySQL服务器端口列表
- PMA_USER和PMA_PASSWORD- 定义用于配置身份验证方法的用户名,对应`$cfg['Servers'][$i]['user']`和`$cfg['Servers'][$i]['password']`
PMA_ABSOLUTE_URI - 定义面向用户的URI

### 自定义配置文件
```bash
docker run --name myadmin -d -p 8080:80 -v /some/local/directory/config.user.inc.php:/etc/phpmyadmin/config.user.inc.php phpmyadmin/phpmyadmin
```
docker允许的phpmyadmin,配置文件一般保存在`/etc/phpmyadmin`目录