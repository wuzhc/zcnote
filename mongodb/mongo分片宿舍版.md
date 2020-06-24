## 测试
- 对原有的大集合进行分片会怎么样
- 对已有集群增加分片,数据会怎么样
- 对已有集群减少分片,数据会怎么样
- 分片需要指定集合,没有指定的集合怎么办

## mongos
```bash
docker run --privileged=true -p 10011:27017 -v $PWD/config:/etc/mongod -v $PWD/db:/data/db --entrypoint mongos --name  mongo-server-mongos mongo:4.0.0 -f /etc/mongod/config.conf --configdb mongo-rs-server-config-server/192.168.1.103:10021,192.168.1.103:10022,192.168.1.103:10023 --bind_ip_all
```

## config server
```bash
docker run --privileged=true -p 27017:27017 -v $PWD/config:/etc/mongod -v $PWD/db:/data/db --name mongod mongo:4.0.0 -f /etc/mongod/config.conf  --bind_ip_all

#config_server_1
#172.17.0.2
docker run --restart=always --privileged=true -p 10021:27019 -v $PWD/config:/etc/mongod -v $PWD/db:/data/db --name mongo-server-config1 mongo:4.0.0 -f /etc/mongod/config.conf --configsvr --replSet "mongo-rs-server-config-server" --bind_ip_all

#config_server_2
#172.17.0.3
docker run --restart=always --privileged=true -p 10022:27019 -v $PWD/config:/etc/mongod -v $PWD/db:/data/db --name mongo-server-config2 mongo:4.0.0 -f /etc/mongod/config.conf --configsvr --replSet "mongo-rs-server-config-server" --bind_ip_all

#config_server_3
#172.17.0.4
docker run --restart=always --privileged=true -p 10023:27019 -v $PWD/config:/etc/mongod -v $PWD/db:/data/db --name mongo-server-config3 mongo:4.0.0 -f /etc/mongod/config.conf --configsvr --replSet "mongo-rs-server-config-server" --bind_ip_all

#初始化
rs.initiate({
_id: "mongo-rs-server-config-server",
configsvr: true,
members: [
{ _id : 0, host : "192.168.1.103:10021" },
{ _id : 1, host : "192.168.1.103:10022" },
{ _id : 2, host : "192.168.1.103:10023" }
]
});
```
- `--configsvr` 声明这是一个集群的config服务,默认端口27019，默认目录/data/configdb

## shard
```bash
#3个分片
docker run --privileged=true -p 10031:27018 -v $PWD/config:/etc/mongod -v $PWD/backup:/data/backup -v $PWD/db:/data/db  --name mongo-server-shard1 mongo:4.0.0 -f /etc/mongod/config.conf --shardsvr --bind_ip_all

docker run --privileged=true -p 10032:27018 -v $PWD/config:/etc/mongod -v $PWD/backup:/data/backup -v $PWD/db:/data/db  --name mongo-server-shard2 mongo:4.0.0 -f /etc/mongod/config.conf --shardsvr --bind_ip_all

docker run --privileged=true -p 10033:27018 -v $PWD/config:/etc/mongod -v $PWD/backup:/data/backup -v $PWD/db:/data/db  --name mongo-server-shard3 mongo:4.0.0 -f /etc/mongod/config.conf --shardsvr --bind_ip_all
```
- `-–shardsvr`  声明这是一个集群的分片,默认端口27018

```bash
mongo --port 10011
sh.addShard("192.168.1.103:10031")
sh.addShard("192.168.1.103:10032")
sh.addShard("192.168.1.103:10033")
```

```bash
mongo --port 10011 #进入随意一个mongos节点
sh.enableSharding("mydb") #指定库
sh.shardCollection("mydb.task", {"_id": "hashed" }) #指定集合和分片键
use test #切换到test库
for (i = 1; i <= 1000; i=i+1){db.user.insert({'userIndex': 1})} #插入数据
```



