```bash
#查看ES各个分片的状态
curl -X GET http://127.0.0.1:9200/_cluster/health?pretty

#删除多余副本
curl -X PUT "http://localhost:9200/_settings" -d'
{
  "number_of_replicas" : 0
}'

#查看集群的状态
curl -X GET "localhost:9200/_cat/health?v&pretty"

#查看对应端口的节点
curl -X GET "localhost:9200/_cat/nodes?v&pretty"

#查看索引分片
curl -XGET "http://localhost:9200/kt_content/_settings?pretty"

#获取所有索引占用空间大小
curl -X GET "localhost:9200/_cat/indices?v&pretty"
#store.size为保存的所有数据大小，包含副本的数据；
#pri.store.size为primary store size，即主分片的数据大小；
#pri为分片个数，rep为副本个数。
#store.size = pri.store.size * （rep + 1）


#创建image索引
curl -X PUT "localhost:9200/image?pretty"

#删除索引
curl -X DELETE "localhost:9200/image?pretty"

#查看索引映射
curl -XGET "http://localhost:9200/weike/_mapping?pretty"

#插入文档
curl -X PUT "localhost:9200/image/_doc/1?pretty" -H 'Content-Type: application/json' -d '{
    "title":"这是一个图片",
    "playnum":123,
    "subjectid":1,
    "userid":21,
    "tagid":[7,78,541],
    "schtypeid":1,
    "versionid":2
}'

#更新文档
curl -X POST "localhost:9200/image/_doc/1/_update?pretty&pretty" -H 'Content-Type: application/json' -d'
{
  "doc": { "name": "Jane Doe" }
}'

curl -X POST "localhost:9200/customer/_doc/1/_update?pretty&pretty" -H 'Content-Type: application/json' -d'
{
  "script" : "ctx._source.age += 5"
}'

#搜索文档
curl -X GET "localhost:9200/bank/_search?q=*&sort=account_number:asc&pretty&pretty"
或者
curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": { "match_all": {} },
  "sort": [
    { "account_number": "asc" }
  ],
  "size": 10,
  "from": 1
}
'

#组合搜索
curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "must": [
        { "match": { "age": "40" } }
      ],
      "must_not": [
        { "match": { "state": "ID" } }
      ]
    }
  },
  "_source": ["firstname"] #返回firstname字段
}
'

#分组排序
curl -X GET "localhost:9200/bank/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "group_by_age": {
      "range": {
        "field": "age",
        "ranges": [
          {
            "from": 20,
            "to": 30
          },
          {
            "from": 30,
            "to": 40
          },
          {
            "from": 40,
            "to": 50
          }
        ]
      },
      "aggs": {
        "group_by_gender": {
          "terms": {
            "field": "gender.keyword"
          },
          "aggs": {
            "average_balance": {
              "avg": {
                "field": "balance"
              }
            }
          }
        }
      }
    }
  }
}
'

# mapping修改
curl -XPUT "http://elasticsearch:9200/bank/_mapping/_doc" -H 'Content-Type: application/json' -d'
{
  "properties": {
        "firstname": {
          "type": "text",
          "copy_to": "fullname"
        },
        "lastname": {
          "type": "text",
          "copy_to": "fullname"
        },
        "fullname": {
          "type": "text"
        }
      }
}'

curl -XPUT "http://127.0.0.1:9200/my_index/_mapping/weike" -H 'Content-Type: application/json' -d'
{
  "properties": {
        "create_date_1": {
          "type": "date"
          }
      }
}'

```



