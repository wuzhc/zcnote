### 查询firstname="Dale"或者firstname="Dillard"并且age=34的记录
```bash
curl -XGET "http://localhost:9200/bank/_search" -H 'Content-Type: application/json' -d'
{
  "_source": [
    "firstname",
    "age"
  ],
  "query": {
    "constant_score": {
      "filter": {
        "bool": {
          "should": [
            {
              "term": {
                "firstname.keyword": "Dale"
              }
            },
            {
              "bool": {
                "must": [
                  {
                    "term": {
                      "firstname.keyword": "Dillard"
                    }
                  },
                  {
                    "term": {
                      "age": 34
                    }
                  }
                ]
              }
            }
          ]
        }
      }
    }
  }
}'
```

## 过滤播放数在10到20的记录
```bash
curl -XGET "http://elasticsearch:9200/weike/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "constant_score": {
      "filter": {
       "range": {
         "playnum": {
           "gte": 10,
           "lte": 20
         }
       } 
      }
    }
  }
}'
```

## 搜索匹配3三个词，若其中两个有匹配，则符合条件
```bash
curl -XGET "http://elasticsearch:9200/weike/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "should": [
        {"match":{"title":"优秀"}},
        {"match":{"title":"程序员"}},
        {"match":{"title":"搜索"}}
      ],
      "minimum_should_match": 2
    }
  }
}'
```
