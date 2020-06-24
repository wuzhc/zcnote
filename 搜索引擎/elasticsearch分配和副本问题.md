## 问题
### 默认情况下，Elasticsearch中的每个索引分配有5个主碎片和1个副本，那么我只有一个节点的情况下，它还会分配5个分片吗？如果增多了节点，我要在哪里看分片的情况呢？

解答：
可以用过 GET _cat/shards查看详情，在单个节点情况下，会有5个分片，但是副本会显示未分配涨停，命令如下：
```bash
curl -H 'Content-Type:application/json' http://localhost:9200/_cat/shards/my_index*
```

通过下面命令查看索引分配失败的问题
```bash
 curl -X GET "localhost:9200/_cat/shards?h=index,shard,prirep,state,unassigned.reason"
```

参考：https://www.elastic.co/guide/en/elasticsearch/reference/6.5/cat-shards.html


未分配的解释：
分片数目过多，而节点数不足，主节点不会将主分片和副本分片分配至同一个节点，同样，也不会将两个副本节点分配到同一个节点，所以当没有足够的节点分配分片时，会出现未分配的状态；
为了避免该种情况发生，节点数和副本数的关系应该为N>=R+1 （其中N为节点数，R为副本数量）

查看磁盘利用率：
```bash
curl -s 'localhost:9200/_cat/allocation?v'
```

更多关于分片未分配的问题参考：https://blog.csdn.net/kezhen/article/details/79379512

### 貌似在多个分片下，会出现搜索relevance score不准确问题


