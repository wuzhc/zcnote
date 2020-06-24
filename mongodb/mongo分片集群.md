## 理论知识
![https://images2017.cnblogs.com/blog/1163391/201710/1163391-20171028100258711-986900075.png](https://images2017.cnblogs.com/blog/1163391/201710/1163391-20171028100258711-986900075.png)
MongoDB基于集合级别的数据分片，将集合数据分布在集群的分片上。

## 课前预习
- 对原有的大集合进行分片会怎么样
- 对已有集群增加分片,数据会怎么样
- 对已有集群减少分片,数据会怎么样
- 分片需要指定集合,没有指定的集合怎么办
- 如何动态扩容或缩容切片
- 如果有shard切片挂掉怎么办
- 数据备份恢复后导入分片集群,原有的索引是否会失效
- 怎么知道哪个shard负责哪块数据,或者说shard是负责管理哪些chunk

## 分片键的问题
分片后您不能更改分片键，也不能取消集合分片。如果查询不包含分片键或复合分片键的前缀 ，则mongos执行广播操作，查询分片集群中的所有分片。这可能需要长时间运行的操作
### 分片策略
- 哈希分片,所谓的数据均匀分布指定是同一个shard中,均匀分布到多个块
- 范围分片,数据的插入都会集中到某个块,也就是会集中到某个shard

## 平衡器
平衡器的作用就是在shard之间迁移chunk，使得每个分片达到相等数量的块
它会影响服务器的性能
```bash
#指定凌晨0点到4点之间均衡,在mongos上执行
use config
db.settings.update({ _id : "balancer" }, { $set : { activeWindow : { start : "00:00", stop : "4:00" } } }, true )
#移除平衡计划窗口
db.settings.update({ _id : "balancer" }, { $unset : { activeWindow : true })

#禁用Balancer
sh.stopBalancer()

#启用Balancer
sh.startBalancer()
```

### 何时发生平衡
只有当分片数量最多的分片和分片数量最少的分片之间的块数差异达到迁移阈值时才开始平衡,阀值如下:
```bash
块数    迁移阀值
<20     2
20~79   4
>80     8
```

## mongos
```bash
docker run --privileged=true -p 10011:27017 -v $PWD/config:/etc/mongod -v $PWD/db:/data/db --entrypoint mongos --name  rs-mongos mongo:4.0.0 -f /etc/mongod/config.conf --configdb rs-config-server/10.16.16.118:10021,10.16.16.118:10022,10.16.16.118:10023 --bind_ip_all
```

## config server
```bash
#docker run --privileged=true -p 27017:27017 -v $PWD/config:/etc/mongod -v $PWD/db:/data/db --name mongodb mongo:4.0.0 -f /etc/mongod/config.conf  --bind_ip_all

#config_server_1
#172.17.0.2
docker run --restart=always --privileged=true -p 10021:27019 -v $PWD/config:/etc/mongod -v $PWD/db:/data/db --name rs-config-server1 mongo:4.0.0 -f /etc/mongod/config.conf --configsvr --replSet "rs-config-server" --bind_ip_all

#config_server_2
#172.17.0.3
docker run --restart=always --privileged=true -p 10022:27019 -v $PWD/config:/etc/mongod -v $PWD/db:/data/db --name rs-config-server2 mongo:4.0.0 -f /etc/mongod/config.conf --configsvr --replSet "rs-config-server" --bind_ip_all

#config_server_3
#172.17.0.4
docker run --restart=always --privileged=true -p 10023:27019 -v $PWD/config:/etc/mongod -v $PWD/db:/data/db --name rs-config-server3 mongo:4.0.0 -f /etc/mongod/config.conf --configsvr --replSet "rs-config-server" --bind_ip_all

#初始化
rs.initiate({
_id: "rs-config-server",
configsvr: true,
members: [
{ _id : 0, host : "10.16.16.118:10021" },
{ _id : 1, host : "10.16.16.118:10022" },
{ _id : 2, host : "10.16.16.118:10023" }
]
});
```
- `--configsvr` 声明这是一个集群的config服务,默认端口27019，默认目录/data/configdb

## shard
```bash
#3个分片
docker run --privileged=true -p 10031:27018 -v $PWD/config:/etc/mongod -v $PWD/backup:/data/backup -v $PWD/db:/data/db  --name rs-shard1 mongo:4.0.0 -f /etc/mongod/config.conf --shardsvr --bind_ip_all

docker run --privileged=true -p 10032:27018 -v $PWD/config:/etc/mongod -v $PWD/backup:/data/backup -v $PWD/db:/data/db  --name rs-shard2 mongo:4.0.0 -f /etc/mongod/config.conf --shardsvr --bind_ip_all

docker run --privileged=true -p 10033:27018 -v $PWD/config:/etc/mongod -v $PWD/backup:/data/backup -v $PWD/db:/data/db  --name rs-shard3 mongo:4.0.0 -f /etc/mongod/config.conf --shardsvr --bind_ip_all

docker run --privileged=true -p 10034:27018 -v $PWD/config:/etc/mongod -v $PWD/backup:/data/backup -v $PWD/db:/data/db  --name rs-shard4 mongo:4.0.0 -f /etc/mongod/config.conf --shardsvr --bind_ip_all
```
- `-–shardsvr`  声明这是一个集群的分片,默认端口27018

```bash
mongo --port 10011
sh.addShard("10.16.16.118:10031")
sh.addShard("10.16.16.118:10032")
sh.addShard("10.16.16.118:10033")
```

```bash
mongo --port 10011 #进入随意一个mongos节点
sh.enableSharding("weike") #指定库
sh.shardCollection("weike.hw", {"_id": "hashed" }) #指定集合和分片键
sh.shardCollection("appdb.book", {bookId:"hashed"}, false, { numInitialChunks: 4} ) #numInitialChunks预定分块数量
use test #切换到test库
for (i = 1; i <= 1000; i=i+1){db.user.insert({'userIndex': 1})} #插入数据

for (i = 1; i <= 1000; i=i+1){db.course.insert({'name': i})}
```


## 数据迁移
```bash
#目标节点从来源节点备份数据
mongodump -h 10.16.16.118:27017 -d mydb -o /backupdata
#还原数据
mongorestore --nsInclude=mydb.task backupdata/
```

## 对已有数据的集合进行分片
```bash
sh.enableSharding("ketang") 
db.exam.ensureIndex({"_id":"hashed"})#集合已有数据才需要建立索引
sh.shardCollection("ketang.exam",{"_id":"hashed"})
```

## 问题
- 在mongos上,已有数据的集合要变成分片集群,只能用`range`分片键
- 在原有的单机架构升级到mongo分片集群,先配置好分片集群,库名和集合名需要一致,然后使用`mongodump`和`mongoresore`备份和导入数据到分片集群