## 参考
https://www.cnblogs.com/duanxz/p/10730121.html
https://blog.csdn.net/quanmaoluo5461/article/details/85164588

将大集合数据分散到多个节点
- mongos 提供对外应用访问，所有操作均通过mongos执行。一般有多个mongos节点。数据迁移和数据自动平衡。
- config server 存储集群所有节点、分片数据路由信息。默认需要配置3个Config Server节点。
- shard 真正的数据存储位置，以chunk为单位存数据。
- 客户端连接`mongos`路由，`mongos`从`config server`获取`shard`节点信息，将请求路由到对应的`shard`上
- 副本集和分片技术可以搭建一个高可用，故障转移的系统
**Mongos本身并不持久化数据，Sharded cluster所有的元数据都会存储到Config Server，而用户的数据会分散存储到各个shard。Mongos启动后，会从配置服务器加载元数据，开始提供服务，将用户的请求正确路由到对应的碎片。**

## 块chunk分裂和迁移
- 集合拆分为块
- 每个分片负责一部分块
- 块的信息存放在`config server`
- 块默认大小为64M,存储需求超过64M，chunk会进行分裂(插入和更新时发生),chunk会被自动均衡迁移

![chunk分裂](https://img2018.cnblogs.com/blog/285763/201904/285763-20190418161324100-576146571.png)
![balancer迁移chunk到其他shard](https://img2018.cnblogs.com/blog/285763/201904/285763-20190418161413324-957658228.png)

## 分片键shard key设计
- 分片以集合为基本单位
- 集合中的数据通过片键被分成多个部分
- 片键是集合中某个字段,必须是个索引
- 自增的片键会导致一直在一个分片写入 ???

## writeConcern和readConcern
- 指定 writeConcern:majority 可以保证写入数据不丢失，不会因选举新主节点而被回滚掉。
- readConcern:majority + writeConcern:majority 可以保证强一致性的读
- readConcern:local + writeConcern:majority 可以保证最终一致性的读
- mongodb 对configServer全部指定writeConcern:majority 的写入方式，因此元数据可以保证不丢失。

## 环境
- shard11, shard21  config_server1, mongos1
- shard12, shard22  config_server2, mongos2
- shard13, shard23  config_server3, mongos3
![https://img-blog.csdnimg.cn/20181221164712719.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3F1YW5tYW9sdW81NDYx,size_16,color_FFFFFF,t_70](https://img-blog.csdnimg.cn/20181221164712719.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3F1YW5tYW9sdW81NDYx,size_16,color_FFFFFF,t_70)

说明:
- 有两个分片`shard11`和`shard21`,其中`shard12`和`shard13`是`shard11`的副本集

## 命令
```bash
docker run --restart=always --privileged=true -p 10021:27019 -v $PWD/config:/etc/mongod -v $PWD/db:/data/db -d --name pro-file-server-config1 mongo:4.0.0 -f /etc/mongod/config.conf --configsvr --replSet "rs-file-server-config-server" --bind_ip_all
```
- `--privileged`，container内的root拥有真正的root权限
-  `--resstart=always`，Docker 重启时，容器自动启动。
-  `--bind_ip_all` mongodb允许所有IP访问


## 部署
### config server
```bash
#config_server_1
#172.17.0.2
docker run --restart=always --privileged=true -p 10021:27019 -v $PWD/config:/etc/mongod -v $PWD/db:/data/db --name pro-file-server-config1 mongo:4.0.0 -f /etc/mongod/config.conf --configsvr --replSet "rs-file-server-config-server" --bind_ip_all

#config_server_2
#172.17.0.3
docker run --restart=always --privileged=true -p 10022:27019 -v $PWD/config:/etc/mongod -v $PWD/db:/data/db --name pro-file-server-config2 mongo:4.0.0 -f /etc/mongod/config.conf --configsvr --replSet "rs-file-server-config-server" --bind_ip_all

#config_server_3
#172.17.0.4
docker run --restart=always --privileged=true -p 10023:27019 -v $PWD/config:/etc/mongod -v $PWD/db:/data/db --name pro-file-server-config3 mongo:4.0.0 -f /etc/mongod/config.conf --configsvr --replSet "rs-file-server-config-server" --bind_ip_all

#初始化
rs.initiate({
    _id: "rs-file-server-config-server",
    configsvr: true,
    members: [
        { _id : 0, host : "10.16.16.109:10021" },
        { _id : 1, host : "10.16.16.109:10022" },
        { _id : 2, host : "10.16.16.109:10023" }
    ]
});
```

## shard
```bash
#shard11
docker run --restart=always --privileged=true -p 10031:27018 -v $PWD/config:/etc/mongod -v $PWD/backup:/data/backup -v $PWD/db:/data/db  --name pro-file-server-shard11 mongo:4.0.0 -f /etc/mongod/config.conf --shardsvr --replSet "rs-file-server-shard1-server" --bind_ip_all

#shard12
docker run --restart=always --privileged=true -p 10032:27018 -v $PWD/config:/etc/mongod -v $PWD/backup:/data/backup -v $PWD/db:/data/db  --name pro-file-server-shard12 mongo:4.0.0 -f /etc/mongod/config.conf --shardsvr --replSet "rs-file-server-shard1-server" --bind_ip_all

#shard13
docker run --restart=always --privileged=true -p 10033:27018 -v $PWD/config:/etc/mongod -v $PWD/backup:/data/backup -v $PWD/db:/data/db  --name pro-file-server-shard13 mongo:4.0.0 -f /etc/mongod/config.conf --shardsvr --replSet "rs-file-server-shard1-server" --bind_ip_all

##初始化
rs.initiate({
    _id: "rs-file-server-shard1-server",
    members: [
        { _id : 0, host : "10.16.16.109:10031" },
        { _id : 1, host : "10.16.16.109:10032" },
        { _id : 2, host : "10.16.16.109:10033" }
    ]
});

##shard21
docker run --restart=always --privileged=true -p 10041:27018 -v $PWD/config:/etc/mongod -v $PWD/backup:/data/backup -v $PWD/db:/data/db  --name pro-file-server-shard21 mongo:4.0.0 -f /etc/mongod/config.conf --shardsvr --replSet "rs-file-server-shard2-server" --bind_ip_all

##shard22
docker run --restart=always --privileged=true -p 10042:27018 -v $PWD/config:/etc/mongod -v $PWD/backup:/data/backup -v $PWD/db:/data/db  --name pro-file-server-shard22 mongo:4.0.0 -f /etc/mongod/config.conf --shardsvr --replSet "rs-file-server-shard2-server" --bind_ip_all

##shard23
docker run --restart=always --privileged=true -p 10043:27018 -v $PWD/config:/etc/mongod -v $PWD/backup:/data/backup -v $PWD/db:/data/db  --name pro-file-server-shard23 mongo:4.0.0 -f /etc/mongod/config.conf --shardsvr --replSet "rs-file-server-shard2-server" --bind_ip_all

##初始化
rs.initiate({
    _id: "rs-file-server-shard2-server",
    members: [
        { _id : 0, host : "10.16.16.109:10041" },
        { _id : 1, host : "10.16.16.109:10042" },
        { _id : 2, host : "10.16.16.109:10043" }
    ]
});
```

## mongos
```bash
#mongos1
docker run --restart=always --privileged=true -p 10011:27017 -v $PWD/config:/etc/mongod -v $PWD/db:/data/db --entrypoint mongos --name pro-file-server-mongos1 mongo:4.0.0 -f /etc/mongod/config.conf --configdb rs-file-server-config-server/10.16.16.109:10021,10.16.16.109:10022,10.16.16.109:10023 --bind_ip_all

#mongos2
docker run --restart=always --privileged=true -p 10012:27017 -v $PWD/config:/etc/mongod -v $PWD/db:/data/db --entrypoint mongos --name pro-file-server-mongos2 mongo:4.0.0 -f /etc/mongod/config.conf --configdb rs-file-server-config-server/10.16.16.109:10021,10.16.16.109:10022,10.16.16.109:10023 --bind_ip_all

#mongos3
docker run --restart=always --privileged=true -p 10013:27017 -v $PWD/config:/etc/mongod -v $PWD/db:/data/db --entrypoint mongos --name pro-file-server-mongos3 mongo:4.0.0 -f /etc/mongod/config.conf --configdb rs-file-server-config-server/10.16.16.109:10021,10.16.16.109:10022,10.16.16.109:10023 --bind_ip_all

#添加分片服务器
sh.addShard("rs-file-server-shard1-server/10.16.16.109:10031,10.16.16.109:10032,10.16.16.109:10033")
sh.addShard("rs-file-server-shard2-server/10.16.16.109:10041,10.16.16.109:10042,10.16.16.109:10043")
```

在mongos路由中指定要分片的数据库,指定要分片的集合以及分片键策略
```bash
mongo --port 10011 #进入随意一个mongos节点
sh.enableSharding("test") #指定库
sh.shardCollection("test.user", {"_id": "hashed" }) #指定集合和分片键
use test #切换到test库
for (i = 1; i <= 1000; i=i+1){db.user.insert({'userIndex': 1})} #插入数据
```

在分片节点上可以查看每个分片的数据
```bash
mongo --port 10031 #进入shard11节点
db.user.find({}).count()
```

## 问题
在本机上不能使用本地地址`127.0.0.1`



## 聚合统计
```bash
db.user.aggregate([ {$group: {"_id": "$category", count: {$sum: 1}}}, {$project: {"_id": 0, "category": "$category", "count": 1}}, {$sort: {"count": -1}} ]) 
```






