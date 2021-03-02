```bash
#创建index
curl -XPUT http://localhost:9200/index

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