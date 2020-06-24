## docker安装redis
```bash
docker run --name redis -p 6379:6379 redis
```

## 配置文件修改
```bash
port 6481
cluster-enabled yes
#集群内部配置文件
cluster-config-file nodes-6481.conf
#节点超时时间，单位毫秒
cluster-node-timeout 15000
logfile "/data/wwwroot/redis/redis_cluster/6481/log/redis-6481.log"
pidfile /data/wwwroot/redis/redis_cluster/redis-6481.pid
```

## 开始
```bash
#启动节点
redis-server /data/wwwroot/redis/redis_cluster/6481/redis-6481.conf
redis-server /data/wwwroot/redis/redis_cluster/6482/redis-6482.conf
redis-server /data/wwwroot/redis/redis_cluster/6483/redis-6483.conf
redis-server /data/wwwroot/redis/redis_cluster/6484/redis-6484.conf
redis-server /data/wwwroot/redis/redis_cluster/6485/redis-6485.conf
redis-server /data/wwwroot/redis/redis_cluster/6486/redis-6486.conf

redis-server /data/wwwroot/redis/redis_cluster/6487/redis-6487.conf
redis-server /data/wwwroot/redis/redis_cluster/6488/redis-6488.conf

#创建集群
#--replicas 1表示每个主节点配备几个从节点
redis-trib.rb create --replicas 1 127.0.0.1:6481 127.0.0.1:6482 127.0.0.1:6483 127.0.0.1:6484 127.0.0.1:6485 127.0.0.1:6486

#检测集群完整性
#只要16384个槽中有一个没有分配给节点则表示集群不完整
#可以对集群中任意一个节点发起检测
redis-trib.rb check 127.0.0.1:6481

#查看集群所有节点
cluster nodes

#集群扩容
#6487是新节点，6481是已存在节点
#如果新节点已存在数据，则会添加失败
#redis-trib.rb add-node {new_ip:new_port} {existing_ip:existing_port}
redis-trib.rb add-node 127.0.0.1:6487 127.0.0.1:6481
#迁移槽和数据，127.0.0.1:6481为集群中任意一个节点
redis-trib.rb reshard 127.0.0.1:6481

#集群缩容
#迁移槽
redis-trib.rb reshard 127.0.0.1:6481
#忘记节点
redis-trib.rb del-node 127.0.0.1:6487 d4aafc5465d0f85a55ccd648e045cedcb46478cd

#请求路由
#查看key对应的槽
cluster keyslot {key}
#cli模式下加上-c可以重定向到正确节点
redis-cli -p 6481 -c
```

## 新节点迁移槽和数据


## 日志输出
```bash
M: b079123bb42e1de36e9bc21d0473f8ceda6f7265 127.0.0.1:6481
   slots:0-5460 (5461 slots) master
   1 additional replica(s)
M: bcbb401d25543cfc6384546ad24b46eb264b426e 127.0.0.1:6483
   slots:10923-16383 (5461 slots) master
   1 additional replica(s)
S: 8f2f21cb11d1986da9137f099e938bdb4e0f230e 127.0.0.1:6484
   slots: (0 slots) slave
   replicates fa0015a21a575b170f5e39f463cc62fdb3a6e667
S: af886e91bf0f42e36627d16d35bc270c0b6fb35e 127.0.0.1:6486
   slots: (0 slots) slave
   replicates b079123bb42e1de36e9bc21d0473f8ceda6f7265
M: fa0015a21a575b170f5e39f463cc62fdb3a6e667 127.0.0.1:6482
   slots:5461-10922 (5462 slots) master
   1 additional replica(s)
S: 41e8cc7350b94185fca11ce243183f414307b037 127.0.0.1:6485
   slots: (0 slots) slave
   replicates bcbb401d25543cfc6384546ad24b46eb264b426e
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```