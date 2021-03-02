## 常用命令

设置分片数量

```json
PUT index_name
{
    "settings": {
    	"number_of_shards": 1,
    	"number_of_replicas": 0 
	}
}
```

可以用过 GET _cat/shards查看详情

```bash
curl -H 'Content-Type:application/json' http://localhost:9200/_cat/shards/my_index
```

通过下面命令查看索引分配失败的问题

```bash
 curl -X GET "localhost:9200/_cat/shards?h=index,shard,prirep,state,unassigned.reason"
```

参考：https://www.elastic.co/guide/en/elasticsearch/reference/6.5/cat-shards.html

未分配的解释：
**分片数目过多，而节点数不足，主节点不会将主分片和副本分片分配至同一个节点，同样，也不会将两个副本节点分配到同一个节点，所以当没有足够的节点分配分片时，会出现未分配的状态；**
为了避免该种情况发生，节点数和副本数的关系应该为N>=R+1 （其中N为节点数，R为副本数量）

查看磁盘利用率：
```bash
curl -s 'localhost:9200/_cat/allocation?v'
```

更多关于分片未分配的问题参考：https://blog.csdn.net/kezhen/article/details/79379512



## 设置多少分片合适

**一旦在Elasticsearch中将索引的分片设置好后，主分片数量在集群中是不能进行修改的，即便是你发现主分片数量不合理也无法调整。**

- 分配分片时主要要考虑的问题
  - 数据集的增长趋势
  - 很多用户认为提前放大分配好分片的量就能确保以后不会出现新的问题，比如分2000个分片
- 要知道分配的每个分片都是由额外的成本的
  - 每个分片其实都是要存数据的，并且都是一个lucene的索引，会消耗文件句柄以及CPU和内存资源
  - 当你进行数据访问时，我们的index就会去到所有的分片上去取数据
  - 如果要取100条，如果你有2000个分片，就会从2000个分片上各取出100个数据然后进行排序给出最终的排序结果，取了2000*100条数据
- 主分片数据到底多少为宜呢？
  - 根据节点数来进行分片，3个Node，N*(1.5-3)
  - 如果有3个节点，主分片数据：5-9个分片

**总结**

- 分片是有相应消耗的，并且持续投入
- 当index拥有多个分片时，ES会查询所有分片然后进行数据合并排序
- 分片数量建议：node*(1.5-3)
- 分片大小为50GB通常被界定为适用于各种用例的限制
- 考虑整个index的shard数量，如果shard数量（不包括副本）超过50个，就很可能引发拒绝率上升的问题，此时可考虑把该index拆分为多个独立的index，分摊数据量，同时配合routing使用，降低每个查询需要访问的shard数量。
- 做日志的，按照天去分割

**参考**

- <https://blog.csdn.net/weixin_39777242/article/details/111916720>
- <https://my.oschina.net/u/4080405/blog/4289185>
- <https://elasticsearch.cn/question/10285>



## 问题

