可以建立分词器，然后应用他
field还可以建立子field

日期需要用`date`类型

## mapping
https://www.jianshu.com/p/c5016b78a284
```bash
curl -XPUT http://localhost:9200/content -H 'Content-Type:application/json' -d'
{
    "mappings": {
      "content": {
        "properties": {
          "data": {
            "type": "text",
            "analyzer": "ik_max_word",
            "search_analyzer": "ik_max_word"
          },
          "id": {
            "type": "text"
          }
        }
      }
    }
}
```