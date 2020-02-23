## goreman
是一个多进程管理工具，用于开发环境，我们使用它来启动多个etcd实例
```bash
# 启动etcd-cluster-profile配置文件的进程
goreman -f etcd-cluster-profile start

# 查看进程状态
goreman run status

# 停止某个etcd节点
goreman run stop etcd1
```

## 多节点静态配置
静态配置需要事先知道节点的个数，我们需要在命令行选项`--initial-cluster`中列举需要启动节点的地址

定义`etcd-cluster-profile`，配置etcd节点启动命令，然后`goreman -f etcd-cluster-profile start`

通过使用任意节点获取集群member信息，`etcdctl --endpoints=localhost:2379 member list`

```bash
etcd1: etcd --name wuzhc0 --initial-advertise-peer-urls http://127.0.0.1:2380 --listen-peer-urls http://0.0.0.0:2380 --listen-client-urls http://0.0.0.0:2379 --advertise-client-urls http://127.0.0.1:2379 --initial-cluster-token etcd-cluster-1 --initial-cluster wuzhc0=http://127.0.0.1:2380,wuzhc1=http://127.0.0.1:2480,wuzhc2=http://127.0.0.1:2580 --initial-cluster-state new

etcd2: etcd --name wuzhc1 --initial-advertise-peer-urls http://127.0.0.1:2480 --listen-peer-urls http://0.0.0.0:2480 --listen-client-urls http://0.0.0.0:2479 --advertise-client-urls http://127.0.0.1:2479 --initial-cluster-token etcd-cluster-1 --initial-cluster wuzhc0=http://127.0.0.1:2380,wuzhc1=http://127.0.0.1:2480,wuzhc2=http://127.0.0.1:2580 --initial-cluster-state new

etcd3: etcd --name wuzhc2 --initial-advertise-peer-urls http://127.0.0.1:2580 --listen-peer-urls http://0.0.0.0:2580 --listen-client-urls http://0.0.0.0:2579 --advertise-client-urls http://127.0.0.1:2579 --initial-cluster-token etcd-cluster-1 --initial-cluster wuzhc0=http://127.0.0.1:2380,wuzhc1=http://127.0.0.1:2480,wuzhc2=http://127.0.0.1:2580 --initial-cluster-state new
```

## 多节点自发现模式
- 服务自发现简单来说就是用一个集群去启动另一个新的etcd集群
- 服务发现URL地址作为`--discovery`参数来启动etcd
- 获取服务URL地址，`curl https://discovery.etcd.io/new?size=3`，其中`size=3`表示要初始化集群大小设置为3，如果加入的节点数量大于3，那么多余的节点会自动转化为`Proxy`模式的`etcd`
- 当加入的节点满足`size=3`后，URL就会失去作用

```bash
etcd --name wuzhc0 --initial-advertise-peer-urls http://127.0.0.1:2560 --listen-peer-urls http://0.0.0.0:2560 --listen-client-urls http://0.0.0.0:2559 --advertise-client-urls http://127.0.0.1:2559 --initial-cluster-token etcd-cluster-1 --discovery https://discovery.etcd.io/8525df31f8ce8803b5ab1cbbadeaba70

etcd --name wuzhc1 --initial-advertise-peer-urls http://127.0.0.1:2570 --listen-peer-urls http://0.0.0.0:2570 --listen-client-urls http://0.0.0.0:2569 --advertise-client-urls http://127.0.0.1:2569 --initial-cluster-token etcd-cluster-1 --discovery https://discovery.etcd.io/8525df31f8ce8803b5ab1cbbadeaba70

etcd --name wuzhc2 --initial-advertise-peer-urls http://127.0.0.1:2580 --listen-peer-urls http://0.0.0.0:2580 --listen-client-urls http://0.0.0.0:2579 --advertise-client-urls http://127.0.0.1:2579 --initial-cluster-token etcd-cluster-1 --discovery https://discovery.etcd.io/8525df31f8ce8803b5ab1cbbadeaba70

etcd --name wuzhc3 --initial-advertise-peer-urls http://127.0.0.1:2590 --listen-peer-urls http://0.0.0.0:2590 --listen-client-urls http://0.0.0.0:2589 --advertise-client-urls http://127.0.0.1:2589 --initial-cluster-token etcd-cluster-1 --discovery https://discovery.etcd.io/8525df31f8ce8803b5ab1cbbadeaba70
```

## value版本
为了让客户端可以访问任意版本的value，etcd会一直保存key的所有历史版本的value，`etcdctl`可以通过指定版本号`--rev`查询指定版本的value，版本号是从2开始
```bash
etcdctl --endpoints=localhost:2559 get foo --rev=3
```

为了减少磁盘空间，etcd可以释放旧版本占用的空间，如下
```bash
# 释放3版本之前的旧数据
etcdctl --endpoints=localhost:2559 compact 3
```

## 租约
key可以绑定一个租约，当租约到期后，key会被自动删除，或者当租约被撤销后，key也会被自动删除
```bash
# 申请一个10秒过期的租约
etcdctl lease grant 10
# 为key绑定租约
etcdctl put <key> <value> --lease=<leaseID> 
# 撤销租约
etcdctl lease revoke <leaseID>
# 续约
etcdctl lease keep-alive <leaseID>
```
