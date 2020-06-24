## 限制外网访问：
启动命令指定`--bind_ip`为127.0.0.1
```bash
 ./mongod --bind_ip 127.0.0.1 --dbpath /data/db --auth
```

或者修改配置文件
```bash
vi /etc/mongodb.conf
bind_ip = 127.0.0.1
```

## 设置账号密码
启动命令指定`--auth`
```bash
./mongod --dbpath /data/db --auth
```

或者修改配置文件
```bash
vi /etc/mongodb.conf
auth = true
```

创建账号
```bash
db.createUser({user:"root",pwd:"123456",roles:["userAdminAnyDatabase"]})
db.auth('root','123456') #认证
```

mongodb的uri语法
```bash
mongodb://{username}:{password}@localhost:27017/{db}
```








