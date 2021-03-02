## match
使用match匹配的话，如果我们的搜索文本是java spark，那么在返回结果中，只要包含有java或者是spark的文档都会返回

## match_phrase
对于match_phrase短语搜索，如果我们的搜索文本是java spark，那么在返回结果中只包含java和只包含spark的文档不会返回，并且如果文档包含java也包含spark,但是距离范围大于slop限定的范围，那么也不会返回
```bash
curl -XGET "http://elasticsearch:9200/bank/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_phrase": {
      "address": {
        "query": "510 Street",
        "slop": 2
      }
    }
  }
}'
```

## bool组合
```bash
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
  }
}
'
```

bool查询包括`must`,`must_not`,`should`

## term filter
term分词搜索，需要和倒排索引的分词相匹配，这里需要注意的是，text类型的字符串在倒排索引的时候会被分词，所以你用这个字符串时是匹配不到的，例如：
原title为：一个PHP程序员，热爱编程，热爱生活，充满激情14
```bash
#不可以匹配到
curl -XGET "http://elasticsearch:9200/weike/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "constant_score":{
      "filter":{
        "term":{
          "title":"一个PHP程序员，热爱编程，热爱生活，充满激情14"
        }
      }
    }
  }
}'
```
需要用filed.keyword来做全匹配
```bash
#可以匹配到
curl -XGET "http://elasticsearch:9200/weike/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "constant_score":{
      "filter":{
        "term":{
          "title.keyword":"一个PHP程序员，热爱编程，热爱生活，充满激情14"
        }
      }
    }
  }
}'
```
对文本分析：
```bash
curl -XGET "http://elasticsearch:9200/weike/_analyze" -H 'Content-Type: application/json' -d'
{
    "analyzer":"ik_max_word",
    "text":"程序员未付金额离开"
}'
```

### filter执行原理声明解析，bigset和caching机制
filter每个条件会对应一个bigset，先进行稀疏bigset过滤
- match query会计算doc对应搜索条件的相关性relevance score，还会根据score去排序
- filter query只是简单过滤想要的数据，不即时relevance score,不排序

## 普通match转换为term+should
例如：
```bash
{
    "match":{
        "title": "php java"
    }
}
#等同于
{
    "bool":{
        "should": [
            {"term":{"title":"php"}},
            {"term":{"title":"java"}}
        ]
    }
}
```

## 基于boost的细粒度搜索条件权重控制
搜索java的帖子，同时如果标题包含hadoop和elasticsearch就优先搜索出来，如果一个帖子包含java hadoop，一个帖子包含java elasticsearch，包含hadoop的帖子要比elasticsearch优先搜索出来
```bash
{
    "match":{
        "title":{
            "query":"java",
            "boost":5 #值越大，权重越大，经过自己的实验，事实是boost的值要设置成多少才合适的问题
        }
    }
}
```

## best field策略
`best field`策略，就是说搜索到的结果，应该是某一个field中匹配到了尽可能多的关键字则排在前面，而不是尽可能多的field匹配到少量的关键词，使用`dis_max`语法	
![1583679359607](/tmp/1583679359607.png)
```bash
{
    "query":{
        "dis_max": {
            "queries": [
                {"match":{"title":"java solution"}},
                {"match":{"content":"java solution"}}
            ]
        }
    }
}
```

## 基于tie_breaker参数优化dis_max搜索
![1583680653332](/tmp/1583680653332.png)

## mutil_match的使用
![1583680929598](/tmp/1583680929598.png)

## 基于mutil_match+most field策略进行mutil-field搜索
- `best field` 主要将某一个field匹配尽可能多的关键词的doc优先返回
- `most field` 主要是尽可能返回更多field匹配到某个关键词的doc，优先返回

## corse field策略
针对多个field的策略搜索策略
```bash
curl -XGET "http://elasticsearch:9200/bank/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "multi_match": {
      "query": "Aurelia Harding",#搜索名字，在firstname和lastname两个field
      "fields": ["firstname","lastname"],
      "type": "most_fields"
    }
  }
}'
```

## 合并多个field为一个 copy_to
用`copy_to`语法，例如通过`mapping`加个新`field`，如下
```bash
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
          "type": "text",
          "fields": {
            "keyword":{
              "type":"keyword",
              "ignore_above":256
            }
          }
        }
      }
}'
```
**需要注意的是：通过mapping修改后，只有新纪录才会copy_to在fullname**
直接通过新field进行搜索：
```bash
curl -XGET "http://elasticsearch:9200/bank/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "fullname": "wu"
    }
  }
}'
```

## 召回率和精准度
一般要求精准度，然后再要求召回率
```bash
curl -XGET "http://elasticsearch:9200/bank/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "must": {
        "match":{
          "address":{
            "query":"510 Sedgwick Street"
          }
        }
      },
      "should": [
        {
          "match_phrase": {
            "address": {
              "query": "510 Street",
              "slop": 3
            }
          }
        }
      ]
    }
  }
}'
```

## 重打分机制 rescoring
先match匹配到docs，然后设置`window_size`，表示对`window_size`条的doc进行重评分
```bash
curl -XGET "http://elasticsearch:9200/bank/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "address": "232 Place"
    }
  },
  "rescore": {
    "query": {
      "rescore_query": {
        "match_phrase": {
          "address": {
            "query": "232 Place",
            "slop": 50
          }
        }
      }
    },
    "window_size": 10
  }
}'
```

## 前缀搜索，正则搜索，通配符搜索
**这几种性能都很差，需要搜索整个倒排索引，不建议使用**
- 前缀搜索
前缀搜索不计算`relevance score`
```bash
curl -XGET "http://elasticsearch:9200/bank/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_phrase_prefix": {
      "address": {
        "query": "331 street",
        "slop":10,
        "max_expansions": 10 #因为会扫描整个倒排索引，所以指定max_expansions，当有10条记录时则停止扫描
      }
    }
  }
}'
```
- 通配符匹配
试了一下，需要小写才行才能匹配到
```bash
curl -XGET "http://elasticsearch:9200/bank/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "wildcard": {
      "firstname": {
        "value": "vir*"
      }
    }
  }
}'
```

## 通过ngram分词机制实现index-time搜索推荐
一般用于搜索前缀提示

- 设置索引mapping
```bash
curl -XPUT "http://elasticsearch:9200/my_index" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "analysis": {
      "filter": {
        "autocomplete_filter": {
          "type": "edge_ngram",
          "min_gram": 1,
          "max_gram": 20
        }
      },
      "analyzer": {
        "autocomplete": {
          "type": "custom",
          "tokenizer": "standard",
          "filter": [
            "lowercase",
            "autocomplete_filter"
          ]
        }
      }
    }
  }
}'
```

- 设置对title进行分析器
```bash
curl -XPUT "http://elasticsearch:9200/my_index/_mapping/weike" -H 'Content-Type: application/json' -d'
{
  "properties": {
    "title": {
      "type": "text",
      "analyzer": "autocomplete",
      "search_analyzer": "standard"
    }
  }
}'
```

- 查看分析结构
```bash
curl -XGET "http://elasticsearch:9200/my_index/_analyze" -H 'Content-Type: application/json' -d'
{
  "text": "hello world",
  "analyzer": "autocomplete"
}'
```

## 通过negative降低权重
在`negative`指定的field分数会去乘以`negative_boost`，例如乘以0.2，则会降低分数
```bash
curl -XGET "http://elasticsearch:9200/my_index/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "boosting": {
      "positive": {
        "match": {
          "title": "hello"
        }
      },
      "negative": {
        "match": {
          "title": "world"
        }
      },
      "negative_boost": 0.2
    }
  }
}'
```

## 三种常见相关度分数优化方法
- 设置boost，增高权重
- negative boost ，减低权重
- constant_score 不要分数


## function_score自定义相关度分数算法
就是将doc得到的分数乘以指定字段，比如我们的指定的字段是播放数，只要播放越多，doc最总得分就越高，使用`field_value_factor`
![1583851082664](/tmp/1583851082664.png)
```bash
curl -XGET "http://elasticsearch:9200/my_index/weike/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "function_score": {
      "query": {
        "match": {
          "title": "hello world"
        }
      },
      "field_value_factor": {
        "field": "playnum",
        "modifier": "square",
        "factor": 1.2
      }
    }
  }
}'
```

## 搜索开启模糊匹配
主要设置`fuzziness`为1
```bash
curl -XGET "http://elasticsearch:9200/my_index/weike/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "title": {
        "query": "hellw",
        "fuzziness": 1,
        "operator": "and"
      }
    }
  }
}'
```




