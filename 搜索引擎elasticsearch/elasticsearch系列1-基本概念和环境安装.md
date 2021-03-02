`elasticsearch`应用场景
- 搜索
- 搜集日志

## 基本概念
**集群**: 

由唯一名称标识,集群可以只有一个节点,也可以拥有任意数量的节点

**索引**:

必须全为小写

**文档**: 

index里面单条的记录称为 Document（文档）。许多条 Document 构成了一个 Index

**分片**:

每个索引可以被分为多个分片,分片本身就是一个功能齐全且独立的"索引",主分片用来解决数据水平扩展的问题。通过主分片可以将数据分布到集群内的所有节点之上。主分片数在索引创建时指定，后续不可以修改（reindex 可以）。

**副本分片**: 

副本分片永远不会与主分片的节点分配在同一节点上

**refresh操作:** 

`new document` -> `indexing buffer` -> `rewrite to one segment` -> `filesystem cache`，从index-buffer中取数据到filesystem cache中的过程叫做refresh

**translog:**

我们可能已经意识到如果数据在filesystem cache之中是很有可能在意外的故障中丢失。这个时候就需要一种机制，可以将对es的操作记录下来，来确保当出现故障的时候，保留在filesystem的数据不会丢失，并在重启的时候可以从这个记录中将数据恢复过来。elasticsearch提供了translog来记录这些操作。

当向elasticsearch发送创建document索引请求的时候，document数据会先进入到index buffer之后，与此同时会将操作记录在translog之中，当发生refresh时（数据从index buffer中进入filesystem cache的过程）translog中的操作记录并不会被清除，而是当数据从filesystem cache中被写入磁盘之后才会将translog中清空。

**flush操作:**

从filesystem cache写入磁盘的过程就是flush

1. es的各个shard会每个30分钟进行一次flush操作。
2. 当translog的数据达到某个上限的时候会进行一次flush操作。



![img](assets/332898-20170906110451069-1815360680.jpg)

参考：<https://blog.csdn.net/dshf_1/article/details/83275523> 



## 分片的设定

- 分片数设置过小
	- 后续无法增加节点实现水平扩展
	- 单个分片的数据量太大导致数据的重新分配耗时
- 分片数设置过大
	- 影响搜索结果的相关性打分，影响统计结果的准确性
	- 单个节点上过多的分片会导致资源浪费，同时会影响性能
	- 7.0开始默认主分片为1，解决了 over-sharding 的问题 

## 安装
环境要求至少java8

### docker运行
```bash
docker run -p 9200:9200 -p 9300:9300 -e ES_JAVA_OPTS="-Xms256m -Xmx256m" -e "discovery.type=single-node" --network es_esnet --name es6.5.4 docker.elastic.co/elasticsearch/elasticsearch:6.5.4

docker run -p 9200:9200 -p 9300:9300 -e ES_JAVA_OPTS="-Xms256m -Xmx256m" -e "discovery.type=single-node" --network es_esnet --name es7.10.1 docker.elastic.co/elasticsearch/elasticsearch:7.10.1
```
访问`http://127.0.0.1:9200`成功则说明成功


## 配置
```bash
docker exec -it es6.5.4 /bin/bash
cd usr/share/elasticsearch/config
```
- `elasticsearch.yml` for configuring Elasticsearch
- `jvm.options` for configuring Elasticsearch JVM settings
- `log4j2.properties` for configuring Elasticsearch logging

### 修改elasticserch.yml配置
```
#集群名字默认为`elasticsearch`,为了防止某人的笔记本电脑加入了集群这种意外,在`elasticsearch.yml`修改集群名称
cluster.name: elasticsearch_production 

#修改节点名称
node.name: elasticsearch_005_data

#修改路径,防止重新安装覆盖数据
path.logs: /path/to/logs
path.data: /path/to/data1,/path/to/data2  #可以通过逗号分隔指定多个目录
path.plugins: /path/to/plugins

#最小主节点数
discovery.zen.minimum_master_nodes: 2
```

### 最小主节点数(master候选节点的法定个数,注意：在es7中已不需要设置改值)
这个配置就是告诉 Elasticsearch 当没有足够 master 候选节点的时候，就不要进行 master 节点选举，等 master 候选节点足够了才进行选举。
此设置应该始终被配置为 master 候选节点的法定个数（大多数个）。法定个数就是 ( master 候选节点个数 / 2) + 1 。 这里有几个例子：

由于 ELasticsearch 是动态的，你可以很容易的添加和删除节点， 但是这会改变这个法定个数。 你不得不修改每一个索引节点的配置并且重启你的整个集群只是为了让配置生效，这将是非常痛苦的一件事情。基于这个原因， `minimum_master_nodes`（还有一些其它配置）允许通过 API 调用的方式动态进行配置。
```
PUT /_cluster/settings
{
    "persistent" : {
        "discovery.zen.minimum_master_nodes" : 2
    }
}
```

## 安装kibana
```bash
docker run --link es6.5.4 --name kibana6.5.4 -p 5601:5601 --network es_esnet kibana:6.5.4
```
`--link`和`--network`将`kibana`和`elasticserch`同个网络,修改配置文件
```bash
docker exec -it kibana6.5.4 /bin/bash
vi config/kibana.yml	
elasticsearch.url: http://es6.5.4:9200 #指定为容器名称
```

## 安装cerebro
```bash
docker run -p 9000:9000 --name cerebro --network es_esnet --link es6.5.4 --link es7.10.1 lmenezes/cerebro
```


## 安装ik中文分词
```bash
cd /usr/share/elasticsearch/bin
elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v6.5.4/elasticsearch-analysis-ik-6.5.4.zip

elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.10.1/elasticsearch-analysis-ik-7.10.1.zip
```
### 创建
```bash
#创建index
curl -XPUT http://localhost:9200/user

#创建mapping
curl -XPOST http://localhost:9200/index/_mapping/_doc -H 'Content-Type:application/json' -d'
{
        "properties": {
            "content": {
                "type": "text",
                "analyzer": "ik_max_word",
                "search_analyzer": "ik_smart"
            }
        }

}'

#插入数据
curl -XPOST http://localhost:9200/index/_doc/1/_create -H 'Content-Type:application/json' -d'
{"content":"美国留给伊拉克的是个烂摊子吗"}
'

curl -XPOST http://localhost:9200/index/_doc/2/_create -H 'Content-Type:application/json' -d'
{"content":"中韩渔警冲突调查：韩警平均每天扣1艘中国渔船"}
'

#搜索
curl -XPOST http://localhost:9200/index/_search  -H 'Content-Type:application/json' -d'
{                                                        
    "query" : { "match" : { "content" : "中国" }},
    "highlight" : {
        "pre_tags" : ["<tag1>", "<tag2>"],
        "post_tags" : ["</tag1>", "</tag2>"],
        "fields" : {
            "content" : {}
        }
    }
}
'
```




