节点 索引 主分片 副分片 段 



## 为什么要使用Elasticsearch?

- 数据量大，做模糊查找会导致全表扫描，用`es`做全文搜索，可以检索资源，快速响应
- 报表统计需要展示聚合统计数据，`es`提供了丰富的聚合函数
- 项目需求要求能够实时检索
- `es`可以很轻松搭建集群，分布式部署，多个节点一起工作



## Elasticsearch是如何实现Master选举的？

包含两个部分，`ping`和`unicast`，多个节点通过rpc来互相通信，`unicast`单播模块包含一个主机列表以控制哪些节点需要ping通

对所有候选节点根据nodeId字典排序 ，每次选举每个节点都把自己所知道节点排一次序，然后选出第一个（第0位）节点，暂且认为它是master节点。

如果对某个节点的投票数达到一定的值（候选节点数n/2+1）并且该节点自己也选举自己，那这个节点就是master。否则重新选举一直到满足上述条件。

**补充：master节点的职责主要包括集群、节点和索引的管理，不负责文档级别的管理；data节点可以关闭http功能。**



 ## Elasticsearch中的节点（比如共20个），其中的10个选了一个master，另外10个选了另一个master，怎么办？

当集群master候选数量不小于3个时，可以通过设置最少投票通过数量（discovery.zen.minimum_master_nodes）超过所有候选节点一半以上来解决脑裂问题；

当候选数量为两个时，只能修改为唯一的一个master候选，其他作为data节点，避免脑裂问题。



## 详细描述一下Elasticsearch索引文档的过程

 ```bash
shard = hash(document_id) % (num_of_primary_shards)
 ```



 ## 详细描述一下Elasticsearch更新和删除文档的过程

删除和更新也都是写操作，但是Elasticsearch中的文档是不可变的，因此不能被删除或者改动以展示其变更； 　　磁盘上的每个段都有一个相应的.del文件。当删除请求发送后，文档并没有真的被删除，而是在.del文件中被标记为删除。该文档依然能匹配查询，但是会在结果中被过滤掉。当段合并时，在.del文件中被标记为删除的文档将不会被写入新段。 　　在新的文档被创建时，Elasticsearch会为该文档指定一个版本号，当执行更新时，旧版本的文档在.del文件中被标记为删除，新版本的文档被索引到一个新段。旧版本的文档依然能匹配查询，但是会在结果中被过滤掉。



## 详细描述一下Elasticsearch搜索的过程

分两个阶段，查询阶段和取回阶段

### 查询阶段

在初始 *查询阶段* 时， 查询会广播到索引中每一个分片。 每个分片在本地执行搜索并构建一个匹配文档的 *优先队列*。

![查询过程分布式搜索](assets/elas_0901.png)

查询阶段包含以下三个步骤:

1. 客户端发送一个 `search` 请求到 `Node 3` ， `Node 3` 会创建一个大小为 `from + size` 的空优先队列。
2. `Node 3` 将查询请求转发到索引的每个主分片或副本分片中。每个分片在本地执行查询并添加结果到大小为 `from + size` 的本地有序优先队列中。
3. 每个分片返回各自优先队列中所有文档的 ID 和排序值给协调节点，也就是 `Node 3` ，它合并这些值到自己的优先队列中来产生一个全局排序后的结果列表（协调节点需要根据 `number_of_shards * (from + size)` 排序文档，如果你 *确实* 需要从你的集群取回大量的文档，你可以通过用 `scroll` 查询禁用排序使这个取回行为更有效率）

 简言之：当一个搜索请求被发送到某个节点时，这个节点就变成了协调节点。 这个节点的任务是广播查询请求到所有相关分片并将它们的响应整合成全局排序后的结果集合，这个结果集合会返回给客户端

### 取回阶段

协调节点首先决定哪些文档 *确实* 需要被取回。例如，如果我们的查询指定了 `{ "from": 90, "size": 10 }` ，最初的90个结果会被丢弃，只有从第91个开始的10个结果需要被取回。这些文档可能来自和最初搜索请求有关的一个、多个甚至全部分片。

协调节点给持有相关文档的每个分片创建一个 [multi-get request](https://www.elastic.co/guide/cn/elasticsearch/guide/current/distrib-multi-doc.html) ，并发送请求给同样处理查询阶段的分片副本。

分片加载文档体-- `_source` 字段—如果有需要，用元数据和 [search snippet highlighting](https://www.elastic.co/guide/cn/elasticsearch/guide/current/highlighting-intro.html) 丰富结果文档。 一旦协调节点接收到所有的结果文档，它就组装这些结果为单个响应返回给客户端。



## Elasticsearch对于大数据量（上亿量级）的聚合如何实现？



## 在并发情况下，Elasticsearch如果保证读写一致？

可以通过版本号使用乐观并发控制，以确保新版本不会被旧版本覆盖，由应用层来处理具体的冲突； 　

另外对于写操作，一致性级别支持quorum/one/all，默认为quorum，即只有当大多数分片可用时才允许写操作。但即使大多数可用，也可能存在因为网络等原因导致写入副本失败，这样该副本被认为故障，分片将会在一个不同的节点上重建。 

对于读操作，可以设置replication为sync(默认)，这使得操作在主分片和副本分片都完成后才会返回；如果设置replication为async时，也可以通过设置搜索请求参数_preference为primary来查询主分片，确保文档是最新版本



## ElasticSearch中的分片是什么?

- 索引 - 在Elasticsearch中，索引是文档的集合。 　　
- 分片 -因为Elasticsearch是一个分布式搜索引擎，所以索引通常被分割成分布在多个节点上的被称为分片的元素。



## 为什么说Elasticsearch搜索是近实时的？

主要是由`FileSystem Cache`的文件系统缓存来实现的

`new document` -> `indexing buffer` -> `rewrite to one segment` -> `filesystem cache`

在Elasticsearch和磁盘之间还有一层称为FileSystem Cache的系统缓存，正是由于这层cache的存在才使得es能够拥有更快搜索响应能力

一个index是由若干个segment组成，随着每个segment的不断增长，我们索引一条数据后可能要经过分钟级别的延迟才能被搜索，为什么有种这么大的延迟，这里面的瓶颈点主要在磁盘。 

持久化一个segment需要fsync操作用来确保segment能够物理的被写入磁盘以真正的避免数据丢失，但是fsync操作比较耗时，所以它不能在每索引一条数据后就执行一次，如果那样索引和搜索的延迟都会非常之大。

所以这里需要一个更轻量级的处理方式，从而保证搜索的延迟更小。这就需要用到上面提到的FileSystem Cache，**所以在es中新增的document会被收集到indexing buffer区后被重写成一个segment然后直接写入filesystem cache中**，这个操作是非常轻量级的，避免了比较损耗性能io操作，之后经过一定的间隔或外部触发后才会被flush到磁盘上，这个操作非常耗时。但只要sengment文件被写入cache后，这个sengment就可以打开和查询，从而确保在短时间内就可以搜到，而不用执行一个full commit也就是fsync操作，这是一个非常轻量级的处理方式而且是可以高频次的被执行，而不会破坏es的性能。

在elasticsearch里面，这个轻量级的写入和打开一个cache中的segment的操作叫做refresh，默认情况下，es集群中的每个shard会每隔1秒自动refresh一次，这就是我们为什么说es是近实时的搜索引擎而不是实时的，也就是说给索引插入一条数据后，我们需要等待1秒才能被搜到这条数据，这是es对写入和查询一个平衡的设置方式，这样设置既提升了es的索引写入效率同时也使得es能够近实时检索数据。

refresh的用法如下：

```
PUT /my_logs
{
  "settings": {
    "refresh_interval": "30s" 
  }
}
```

上面的参数是可以随时动态的设置到一个存在的索引里面，如果我们正在插入超大索引时，我们完全可以先关闭掉这个refresh机制，等写入完毕之后再重新打开，这样以来就能大大提升写入速度。

命令如下：

```bash
PUT /my_logs/_settings
{ "refresh_interval": -1 }  //禁用刷新机制
 
PUT /my_logs/_settings
{ "refresh_interval": "1s" }  //设置每秒刷新一次
```

注意refresh_interval的参数是可以带时间周期的，如果你只写了个1，那就代表每隔1毫秒刷新一次索引，所以设置这个参数时务必要谨慎。



## Elasticsearch是如何保证不丢失数据的

文档被写入`FileSystem Cache`之后，虽然可以直接提供查询，但此时数据并没有持久化到磁盘，会有丢失数据的风险。所以ES引入了transLog，事务日志，当写入数据时，同时写入transLog，代码（ InternalEngine.index()）

translog默认情况下是 是每 5 秒被 fsync 刷新到硬盘， 或者在每次写请求完成之后执行(e.g. index, delete, update, bulk)， 也就是说默认情况下，在没有写入translog前，你的客户端不会得到一个 200 OK 响应。通过tranLog保障数据不会丢失。代码可见（ AsyncAfterWriteAction.run()）

在不断的写入，translog主键变大时，es会执行 一个全量提交，即Lucene的写入磁盘，这个执行一个提交并且截断 translog 的行为在 Elasticsearch 被称作一次 flush 。 分片每30分钟被自动刷新（flush），或者在 translog 太大的时候也会刷新。

```bash
POST /blogs/_flush
```



## ES主分片数目为什么索引创建的时候就要确定？主分片数目如何确定

文档到路由的确定方式，根据 `shard = hash(document_id) % primary_shard_num` 。因此主分片的数目必须在索引创建之前确定好。

由于新加入节点，ES会自动对节点进行负载均衡，因此，主分片的数目主理想的数目是每个节点上一个主分片，数目与节点个数一样。