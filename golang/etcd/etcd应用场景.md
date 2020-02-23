## 参考
- [https://blog.csdn.net/aa1215018028/article/details/81116435](https://blog.csdn.net/aa1215018028/article/details/81116435)

## 应用场景
### 服务发现
在分布式集群环境中发现有可用的服务
- 一个强一致性、高可用的服务存储目录，什么是强一致性？为什么叫服务存储目录？？
![https://res.infoq.com/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0129001.jpg](https://res.infoq.com/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0129001.jpg)

### 订阅和发布
使用了`etcd`中的`Watcher`机制
![https://res.infoq.com/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0129004.jpg](https://res.infoq.com/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0129004.jpg)

### 负载均衡
![https://res.infoq.com/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0129005.jpg](https://res.infoq.com/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0129005.jpg)

### 分布式协同工作
![https://res.infoq.com/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0129006.jpg](https://res.infoq.com/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0129006.jpg)

### 分布式锁
锁服务有两种使用方式，一是保持独占，二是控制时序
![https://res.infoq.com/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0130000.jpg](https://res.infoq.com/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0130000.jpg)

### 分布式队列
![https://res.infoq.com/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0129008.jpg](https://res.infoq.com/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0129008.jpg)

### 集群监控与Leader竞选
![https://res.infoq.com/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0129009.jpg](https://res.infoq.com/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0129009.jpg)


## 集群启动
### 静态配置
[https://blog.csdn.net/kmhysoft/article/details/71106995](https://blog.csdn.net/kmhysoft/article/details/71106995)
```bash
etcd --name cd0 --initial-advertise-peer-urls http://127.0.0.1:2380 \
  --listen-peer-urls http://127.0.0.1:2380 \
  --listen-client-urls http://127.0.0.1:2379 \
  --advertise-client-urls http://127.0.0.1:2379 \
  --initial-cluster-token etcd-cluster-1 \
  --initial-cluster cd0=http://127.0.0.1:2380,cd1=http://127.0.0.1:2480,cd2=http://127.0.0.1:2580 \
  --initial-cluster-state new
```
- `initial-advertise-peer-urls` 用于其他节点通过该地址监听本节点信息
- `listen-peer-urls` 用于本节点通过该地址监听其他节点信息
- `initial-cluster-token` 用于区分多个集群环境，同一个集群环境该值是一样的
- `initial-cluster` 集群中所有节点信息，本节点根据这个信息去联系其他节点
- `initial-cluster-state` 用于指示本次是否为新建集群。有两个取值new和existing

### demo
```bash
# 节点1
etcd --name wuzhc0 --initial-advertise-peer-urls http://127.0.0.1:2380 --listen-peer-urls http://0.0.0.0:2380 --listen-client-urls http://0.0.0.0:2379 --advertise-client-urls http://127.0.0.1:2379 --initial-cluster-token etcd-cluster-1 --initial-cluster wuzhc0=http://127.0.0.1:2380,wuzhc1=http://127.0.0.1:2480,wuzhc2=http://127.0.0.1:2580 --initial-cluster-state new

# 节点2
etcd --name wuzhc1 --initial-advertise-peer-urls http://127.0.0.1:2480 --listen-peer-urls http://0.0.0.0:2480 --listen-client-urls http://0.0.0.0:2479 --advertise-client-urls http://127.0.0.1:2479 --initial-cluster-token etcd-cluster-1 --initial-cluster wuzhc0=http://127.0.0.1:2380,wuzhc1=http://127.0.0.1:2480,wuzhc2=http://127.0.0.1:2580 --initial-cluster-state new

# 节点3
etcd --name wuzhc2 --initial-advertise-peer-urls http://127.0.0.1:2580 --listen-peer-urls http://0.0.0.0:2580 --listen-client-urls http://0.0.0.0:2579 --advertise-client-urls http://127.0.0.1:2579 --initial-cluster-token etcd-cluster-1 --initial-cluster wuzhc0=http://127.0.0.1:2380,wuzhc1=http://127.0.0.1:2480,wuzhc2=http://127.0.0.1:2580 --initial-cluster-state new
```


### 自发现模式
需要先准备一个etcd集群,可以通过`curl http://discovery.etcd.io/new?size=3`获取`discovery`，运行etcd命令时指定`--discovery`选项
```bash
etcd --name etcd0 --initial-advertise-peer-urls http://127.0.0.1:2380 \
--listen-peer-urls http://0.0.0.0:2380 \
--listen-client-urls http://0.0.0.0:2379 \
--advertise-client-urls http://127.0.0.1:2379 \
--discovery https://discovery.etcd.io/a27df692f487b427ab144013f54adb1f \
--initial-cluster-state new

etcd --name etcd1 --initial-advertise-peer-urls http://127.0.0.1:2480 \
--listen-peer-urls http://0.0.0.0:2480 \
--listen-client-urls http://0.0.0.0:2479 \
--advertise-client-urls http://127.0.0.1:2479 \
--discovery https://discovery.etcd.io/a27df692f487b427ab144013f54adb1f \
--initial-cluster-state new

etcd --name etcd2 --initial-advertise-peer-urls http://127.0.0.1:2580 \
--listen-peer-urls http://0.0.0.0:2580 \
--listen-client-urls http://0.0.0.0:2579 \
--advertise-client-urls http://127.0.0.1:2579 \
--discovery https://discovery.etcd.io/a27df692f487b427ab144013f54adb1f \
--initial-cluster-state new

etcd --name etcd3 --initial-advertise-peer-urls http://127.0.0.1:2680 \
--listen-peer-urls http://0.0.0.0:2680 \
--listen-client-urls http://0.0.0.0:2679 \
--advertise-client-urls http://127.0.0.1:2679 \
--discovery https://discovery.etcd.io/a27df692f487b427ab144013f54adb1f \
--initial-cluster-state new
```

## 集群命令
```bash
etcdctl endpoint health --endpoints=http://127.0.0.1:2380,http://127.0.0.1:2680,http://127.0.0.1:2480 --write-out=table

etcdctl member list --write-out=table
```

### static方式下增加新member
cluster的member数之前已经根据initial-cluster描述的成员确定下来了，如果不先add member，直接启动etcd的话生成的clusterID和老clusterID不一致，根本加不进去。

后续要增加member走"运行中改配扩容"流程，即先`add  member`，然后启动新etcd。加入后都是正式member，不存在降为proxy的机制。

### discovery方式下size对新加入节点的限制
size这个key如果不存在或者不设置有效值，集群所有节点都建不起来。

在集群中已经存在size个member的情况下，以--initial-cluster-state new参数新加入的节点自动降为proxy。通过该proxy可进行读写操作。该proxy不在member列表中。原member之一退出后（member异常和remove member情况下相同），proxy无变化，不会自动加入集群。

要加入群，必须走"运行中改配替换"流程。


###  DNS自发现模式
暂不了解

## 配置etcd过程中通常要用到两种url地址容易混淆
- 一种用于etcd集群同步信息并保持连接，通常称为peer-urls；
- 另外一种用于接收用户端发来的HTTP请求，通常称为client-urls。
- peer-urls：通常监听的端口为2380（老版本使用的端口为7001），包括所有已经在集群中正常工作的所有节点的地址。
- client-urls：通常监听的端口为2379（老版本使用的端口为4001），为适应复杂的网络环境，新版etcd监听客户端请求的url从原来的1个变为现在可配置的多个。这样etcd可以配合多块网卡同时监听不同网络下的请求。

## 运行时节点的变更
- 节点迁移和替换
- 节点增加
- 节点移除
- 强制性重启集群

## proxy模式
Proxy模式也是新版etcd的一个重要变更，etcd作为一个反向代理把客户的请求转发给可用的etcd集群

## raft算法
https://blog.csdn.net/aa1215018028/article/details/81116435
- term任期，一个任期即从一次竞选开始到下一次竞选开始
- 从功能上讲，如果Follower接收不到Leader节点的心跳信息，就会结束当前任期，变为Candidate发起竞选，有助于Leader节点故障时集群的恢复
- 发起竞选投票时，任期值小的节点不会竞选成功。
- 如果集群不出现故障，那么一个任期将无限延续下去。
- 而投票出现冲突也有可能直接进入下一任再次竞选。

### Raft状态机是怎样切换的？
Raft刚开始运行时，节点默认进入Follower状态，等待Leader发来心跳信息。
若等待超时，则状态由Follower切换到Candidate进入下一轮term发起竞选，等到收到集群多数节点的投票时，该节点转变为Leader。
Leader节点有可能出现网络等故障，导致别的节点发起投票成为新term的Leader，此时原先的老Leader节点会切换为Follower。
Candidate在等待其它节点投票的过程中如果发现别的节点已经竞选成功成为Leader了，也会切换为Follower节点。

## 超时时间
心跳保持和Leader竞选


## api接口
https://www.cnblogs.com/ilifeilong/p/11608501.html
如果需要使用v2 version api，启动etcd时候需要加入“ETCD_ENABLE_V2=true”参数，否则会报错“404 page not found”

```bash
# 获取版本
curl -L http://127.0.0.1:2379/version
# 获取建康状态
curl -L http://127.0.0.1:2379/health
# 添加key
# -d ttl=30 过期时间
# -d prevExist=true 取消ttl
# -d refresh=true 重置ttl
curl http://127.0.0.1:2379/v2/keys/message -XPUT -d value="Hello world"
# 查看key
curl http://127.0.0.1:2379/v2/keys/message
# 删除key
curl http://127.0.0.1:2379/v2/keys/message -XDELETE
# 添加目录
curl http://127.0.0.1:2379/v2/keys/dir -d ttl=30 -d dir=true
# 向目录添加数据
curl http://127.0.0.1:2379/v2/keys/dir/message -XPUT -d value="Hello world"
# 对queue目录下的数据进行排序
curl http://127.0.0.1:2379/v2/keys/queue -XPOST -d value=Job1
curl http://127.0.0.1:2379/v2/keys/queue -XPOST -d value=Job2
curl 'http://127.0.0.1:2379/v2/keys/queue?recursive=true&sorted=true'
# 监控key
curl http://127.0.0.1:2379/v2/keys/message?wait=true
```

##命令行 api3
https://blog.csdn.net/u010278923/article/details/71727682
```bash
# 删除所有/test前缀的节点
etcdctl del /test --prefix

# 前缀查询
etcdctl get /test/ok --prefix

# 如果监听子节点
etcdctl watch /test/ok --prefix

# 申请租约
etcdctl lease grant 40
# 授权租约，节点的生命伴随着租约到期将会被DELETE
etcdctl put --lease=4e5e5b853f52892b /test/ok xxxx
# 撤销租约
etcdctl lease revoke 4e5e5b853f52892b
# 租约续约，每当到期将会续约
etcdctl lease keep-alive 4e5e5b853f52892b

# 查看集群
etcdctl --endpoints=$ENDPOINTS member list
# 集群状态
etcdctl --write-out=table --endpoints=$ENDPOINTS endpoint status


```
### demo
```go
package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/coreos/etcd/clientv3"
)

var (
	dialTimeout    = 5 * time.Second
	requestTimeout = 10 * time.Second
	endPoints      = []string{"127.0.0.1:2379"}
)

func main() {
	// 新建一个客户端
	cli, err := clientv3.New(clientv3.Config{
		Endpoints:   endPoints,
		DialTimeout: dialTimeout,
	})
	if err != nil {
		log.Fatalf("create client failed, %s \n", err)
	}
	defer cli.Close()

	// 写
	ctx, cancel := context.WithTimeout(context.Background(), requestTimeout)
	_, err = cli.Put(ctx, "/test/hello", "do.......")
	cancel()

	// 读
	ctx, cancel = context.WithTimeout(context.Background(), requestTimeout)
	resp, err := cli.Get(ctx, "/test/hello")
	cancel()
	for _, ev := range resp.Kvs {
		fmt.Printf("%s => %s\n", ev.Key, ev.Value)
	}

	// 事务处理
	_, err = cli.Put(context.TODO(), "key", "xyz")
	ctx, cancel = context.WithTimeout(context.Background(), requestTimeout)
	_, err = cli.Txn(ctx).
		If(clientv3.Compare(clientv3.Value("key"), ">", "abc")).
		Then(clientv3.OpPut("key", "XYZ")).
		Else(clientv3.OpPut("key", "ABC")).
		Commit()
	cancel()
	if err != nil {
		log.Fatalln("txn failed, %s\n", err)
	}

	// 监控
	rch := cli.Watch(context.TODO(), "/test/hello", clientv3.WithPrefix())
	for r := range rch {
		for _, ev := range r.Events {
			fmt.Printf("%s %q:%q\n", ev.Type, ev.Kv.Key, ev.Kv.Value)
		}
	}
}

```


## 命令行 api2
```bash
# 添加key
# --ttl '0'            该键值的超时时间（单位为秒），不配置（默认为 0）则永不超时
# --swap-with-value value 若该键现在的值是 value，则进行设置操作
# --swap-with-index '0'    若该键现在的索引值是指定索引，则进行设置操作
etcdctl set /testdir/testkey "Hello world"

# 获取key
# --sort    对结果进行排序
# --consistent 将请求发给主节点，保证获取内容的一致性
etcdctl get /testdir/testkey

# 更新key
# --ttl '0'    超时时间（单位为秒），不配置（默认为 0）则永不超时
etcdctl update /testdir/testkey "Hello"

# 删除key
# --dir        如果键是个空目录或者键值对则删除
# --recursive        删除目录和所有子键
# --with-value     检查现有的值是否匹配
# --with-index '0'    检查现有的 index 是否匹配
etcdctl rm /testdir/testkey

# 如果给定的键不存在，则创建一个新的键值,当键存在的时候，执行该命令会报错
etcdctl mk /testdir/testkey "Hello world"

# 如果给定的键目录不存在，则创建一个新的键目录，当键目录存在的时候，执行该命令会报错
etcdctl mkdir testdir2

# 删除一个空目录，目录不为空则报错
etcdctl rmdir dir1
```


## 原子CAS操作（Compare And Swap）
- prevExist： 检查key是否存在。如果prevExist为true, 则这是一个更新请求，如果prevExist的值是false, 这是一个创建请求
- prevValue：检查key之前的value
- prevIndex：检查key以前的modifiedIndex
```bash
# 插入一个已存在的key并添加参数prevExist=false，因为已经有存在的key,所以会提示key already exists,如果prevExist=true，则是一个创建请求
{"errorCode":105,"message":"Key already exists","cause":"/foo","index":30}

# 将插入条件换成prevValue，即检查key的value值，条件相等就替换，否则就提示条件不匹配
curl http://127.0.0.1:2379/v2/keys/foo?prevValue=three -XPUT -d value=two
{"errorCode":101,"message":"Compare failed","cause":"[three != one]","index":30}
```





