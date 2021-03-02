### 用户信息
`/etc/passwd`保存着linux用户账号信息,内容包括账号,密码,用户ID,用户组ID,用户主目录,shell登录,举个例子：`john:x:1005:1005::/home/wuzhc:/bin/bash`,各个参数说明如下:
- john ： 用户名， 
- x ： 密码，对应/etc/shadow
- 1005 ： UID， 用户ID， 0表示系统管理员，例如root, 1-999系统账号， 1000 - 60000 可登录账号
- 1005 ： GID， 用户组ID，对应/etc/group
- /home/wuzhc ： 使用者主文件夹
- /bin/bash ： shell环境，如果是/sbin/nologin表示账号无法取得shell环境登录动作

### 用户相关命令
- grep wuzhc /etc/passwd /etc/shadow /etc/group ： 查看wuzhc用户对应信息内容
- ll -d /home/john ： 查看john主文件夹信息
- id <username> ： 查看用户相关uid，gid信息

### 目录管理
#### 更改目录所有者
```bash
chown -R <user> <directory>
# ch表示修改,own是所有者,目录放最后
```

#### 更改用户组
```bash
chgrp -R <group> <directory>
# ch修改,grp是用户组,目录放最后
```

### 用户组管理
#### 增加用户组
```bash
groupadd <group>
```

#### 删除用户组
```bash
groupdel <group>
```

#### 修改用户组名称
```bash
groupmod -n <newname> <group>
```

### 用户管理
#### 新增用户
```bash
useradd -g <group> <user>
# -g表示初始化群组,新用户需要设置密码(passwd <user>)才能登录
```

#### 删除用户
```bash
userdel -r <user>
```

#### 新增用户，并且指定多个附加群组
```bash
useradd -G <group1>,<group2>,<group3> <user>
```

#### 用户加入新群组
```bash
usermod -a -G <group> <user>
# -a表示追加
# -G表示附加群组
```

### 查看当前用户群组
```bash
groups
# 列出当前用户所在的用户组,第一个群组为用户的有效群组
```

### 切换当前用户的有效群组
```bash
newsgrp <group> 
# 有效群组是用户创建文件或文件夹时显示那个用户组,切换群组时,只能在用户已有的群组中切换
```

### 修改用户的有效群组
```bash
usermod -g <group> <user>
# 其他附加组会被清空掉
```

### 从群组中删除某个用户
```bash
gpasswd -d <user> <group>
```










