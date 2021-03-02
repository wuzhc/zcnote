[TOC]

为了配合本文的讲解，我们先导入一批数据
```bash
curl -H 'Content-type: application/x-ndjson' -XPOST 'http://127.0.0.1:9200/my_store/_doc/_bulk' -d '{"index":{"_id":1}}
{"price":10,"productID":"XHDK-A-1293-#fJ3"}
{"index":{"_id":2}}
{"price":20,"productID":"KDKE-B-9947-#kL5"}
{"index":{"_id":3}}
{"price":30,"productID":"JODL-X-1937-#pV7"}
{"index":{"_id":4}}
{"price":30,"productID":"QQPX-R-3956-#aD8"}
'
```

## match和term有什么区别
使用`match`搜索文本时，`es`会先将文本进行分词，然后将分词后多个关键字再去搜索，而`term`则不会先去分词，直接将文本原封不动的去搜索，如下：
```json
{
    "query": {
        "match": { //1
            "productID": "JODL-X-1937-#pV7"
        }
    }
}
{
    "query": {
        "term": { //2
            "productID": "JODL-X-1937-#pV7"
        }
    }
}
```
- //1 match查询会将`JODL-X-1937-#pV7`拆分成`jodl`，`x`，`1937`，`#pv7`多个关键词之后再去搜索
- //2 term查询会将`JODL-X-1937-#pV7`作为一个词直接去搜索

## 为什么用term得不到结果
![1610010339759](../../../../../home/wuzhc/Pictures/2can/1138117-20180124095813022-3557581.png)

`term`查询会精确搜索`JODL-X-1937-#pV7`,但是当我们执行查询语句时，并没有得到期望的结果（搜索不到结果），原因是我们在导入的数据时`productID`是先被分词之后再保存在`es`的，我们可以通过es提供的api接口`_analyze`来查看es实际存储`productID`的文本，执行如下命令:

```bash
curl -X GET "127.0.0.1:9200/my_store/_analyze?pretty" -H 'Content-Type: application/json' -d'
{
  "field": "productID",
  "text": "XHDK-A-1293-#fJ3"
}
'
```
![1610008703738](../../../../../home/wuzhc/Pictures/2can/1138117-20180124095813022-3557581.png)
如图所示，`XHDK-A-1293-#fJ3`在导入数据的时候被拆分成了多个关键字，如果用`XHDK-A-1293-#fJ3`来进行匹配，肯定无法匹配到数据。那么我们要怎么才能在导入的时候不让文本分词，方案是我们可以将`productID`设置为`keyword`类型，现在我们需要重新创建映射`mapping`，步骤如下：
```bash
#删除索引，删除索引是必须的，因为我们不能更新已存在的映射
curl -H 'Content-type: application/json' -XDELETE 'http://127.0.0.1:9200/my_store'

#重新创建mapping
curl -H 'Content-type: application/json' -XPUT 'http://127.0.0.1:9200/my_store' -d '{
 "mappings": {
  "_doc": {
   "properties": {
    "productID": {
     "type": "keyword", //设置`productID`为`keyword`类型
     "ignore_above": 64
    }
   }
  }
 }
}'

#再次重新导入数据
curl -H 'Content-type: application/x-ndjson' -XPOST 'http://127.0.0.1:9200/my_store/_doc/_bulk' -d '{"index":{"_id":1}}
{"price":10,"productID":"XHDK-A-1293-#fJ3"}
{"index":{"_id":2}}
{"price":20,"productID":"KDKE-B-9947-#kL5"}
{"index":{"_id":3}}
{"price":30,"productID":"JODL-X-1937-#pV7"}
{"index":{"_id":4}}
{"price":30,"productID":"QQPX-R-3956-#aD8"}
'
```
执行上上面步骤之后，我们再通过API接口`_analyze`查看
![1610008601337](../../../../../home/wuzhc/Pictures/2can/1138117-20180124095813022-3557581.png)
现在`productID`已经不会被分词了，最后，我们再执行下`term`查询,已经可以找到数据了，如下图所示

![1610010423490](../../../../../home/wuzhc/Pictures/2can/1138117-20180124095813022-3557581.png)

## 总结
- `term`是精确搜索
- 在搜索文本情况下，`term`一般配合`keyword`类型进行搜索

## 参考
- https://www.elastic.co/guide/cn/elasticsearch/guide/current/_finding_exact_values.html



