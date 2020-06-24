## bucket和metric两大概念
- bucket 一个数据分组
- metric 对一个数据分组执行统计

## 基本结构
```json
"aggregations" : {
    "<aggregation_name>" : {
        "<aggregation_type>" : { # 需要为每个aggs命名
            <aggregation_body>
        }
        [,"meta" : {  [<meta_data_body>] } ]?
        [,"aggregations" : { [<sub_aggregation>]+ } ]?
    }
    [,"<aggregation_name_2>" : { ... } ]*
}
```

## 按term分组
对类型分组
```bash
curl -XGET "http://elasticsearch:9200/my_index/weike/_search" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "type_group": {
      "terms": {
        "field": "type.keyword"
      }
    }
  }
}'
```

## histogram 区间统计
类型terms,也是进行bucket分组操作，接收一个field，按照这个field的值各个范围区间，进行bucket分组，比如下面会划分范围：`0-2000`，`2000-4000`,`4000-6000`等等,这些区间会作为key
```json
"histogrm": {
    "field": "price",
    "interval": 2000
}
```
完整例子：
```bash
curl -XGET "http://elasticsearch:9200/my_index/weike/_search" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "type_group": {
      "histogram": {
        "field": "playnum",
        "interval": 2
      },
      "aggs": {
        "playnum_sum": {
          "avg": {
            "field": "playnum"
          }
        }
      }
    }
  }
}'
```

## histogram 月统计
- size:0 表示不返回搜索的结果
- date_histogram下的field必须是一个date类型
- min_doc_count 表示为0时，也要包括
- extended_bounds 指定范围，否则开始时间是从有数据开始

修改mapping类型
```bash
curl -XPUT "http://127.0.0.1:9200/my_index/_mapping/weike" -H 'Content-Type: application/json' -d'
{
  "properties": {
        "create_date_1": {
          "type": "date"
          }
      }
}'
```
统计：
```bash
curl -XGET "http://elasticsearch:9200/my_index/weike/_search" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "type_group": {
      "date_histogram": {
        "field": "create_date_2",
        "interval": "day",
        "format": "yyyy-MM-dd",
        "min_doc_count": 0,
        "extended_bounds": {
          "min": "2020-01-09",
          "max": "2020-01-10"
        }
      },
      "aggs": {
        "playnum": {
          "sum": {
            "field": "playnum"
          }
        }
      }
    }
  }
}'
```

## 单个商品和总商品的比较 global bucket
```bash
curl -XGET "http://elasticsearch:9200/my_index/weike/_search" -H 'Content-Type: application/json' -d'
{
  "size": 0, 
  "query": {
    "term": {
      "type": {
        "value": "course" # 匹配course类型
      }
  }
  },
  "aggs": {
    "sigal_avg_play_num": {
      "avg": {
        "field": "playnum" # 求course类型平均播放量
      }
    },
    "all":{
      "global": {},
      "aggs": {
        "total_avg_play_num": {
          "avg": {
            "field": "playnum" @ 所有类型播放量
          }
        }
      }
    }
  }
}'
```

## 过滤加聚合
```bash
curl -XGET "http://elasticsearch:9200/my_index/weike/_search" -H 'Content-Type: application/json' -d'
{
  "size": 0, 
  "query": {
    "constant_score": {
      "filter": {
        "match": {
          "title": {
            "query":"world"
          }
        }
      }
    }
  },
  "aggs": {
    "group_by_type": {
      "sum": {
        "field": "playnum"
      }
    }
  }
}'
```

## 聚合排序
- 默认排序是根据`doc_count`倒序排序
- 主要是使用`order`字段，order需要用自定义的aggs字段名，例如avg_playnum
```bash
curl -XGET "http://elasticsearch:9200/my_index/weike/_search" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "query": {
    "constant_score": {
      "filter": {
        "match": {
          "title": {
            "query": "hello"
          }
        }
      }
    }
  },
  "aggs": {
    "group_by_type": {
      "terms": {
        "field": "type.keyword",
        "order": {
          "avg_playnum": "asc" # 对每个类型下播放数平均值进行排序
        }
      },
      "aggs": {
        "avg_playnum": {
          "avg": {
            "field": "playnum"
          }
        }
      }
    }
  }
}'
```

## 易并行算法，进似聚合
数据统计有两种方式
- 大数据+实时 用es，会有错误率
- 大数据+精准 hadoop，非实时，可能会跑几个小时
![1583976262891](/tmp/1583976262891.png)


## cartinality metric 去重统计
对每个bucket指定的field进行去重，取去重后的count，类似于count(distcint)，不是完全准确的，会有错误率
```bash
curl -XGET "http://elasticsearch:9200/my_index/weike/_search" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "months": {
      "date_histogram": {
        "field": "create_date_2",
        "interval": "day",
        "format": "yyyy-MM-dd"
      },
      "aggs": {
        "distinct_type": {
          "cardinality": {
            "field": "type.keyword" # 统计每一天下，每个类型的个数
          }
        }
      }
    }
  }
}'
```

## cardinality算法优化内存开销
- cardinality结果并不精确，如果要精确会占用大量的内存，可以用过`precision_threshold`来控制，占用内存等于`precision_threshold × 8`字节，在`precision_threshold`内，结果都是几乎准确的
```bash
curl -XGET "http://elasticsearch:9200/my_index/weike/_search" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "months": {
      "date_histogram": {
        "field": "create_date_2",
        "interval": "day",
        "format": "yyyy-MM-dd"
      },
      "aggs": {
        "distinct_type": {
          "cardinality": {
            "field": "type.keyword",
            "precision_threshold": 100
          }
        }
      }
    }
  }
}'
```

## 各个百分比统计
- 如同压测一样，50%请求在多少秒内，80%请求在多少秒内，所有请求在多少秒内
- 主要用到了`percentiles`，如果想自己指定值，可以用`percentile_ranks`
```bash
curl -XGET "http://elasticsearch:9200/my_index/weike/_search" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "group_by_type": {
      "terms": {
        "field": "type.keyword"
      },
      "aggs": {
        "play_time": {
          "percentiles": {
            "field": "playnum",
            "percents": [ # 百分比
              1,
              5,
              25,
              50,
              75,
              95,
              99
            ]
          }
        },
        "play_time_avg": {
          "avg":{
              "field": "playnum" # 所有播放平均数
            }
          }
      }
    }
  }
  
}'
```
优化
![1583996785288](/tmp/1583996785288.png)

## 广度优先搜索
主要设置`terms.collect_mode = breadth_first`，目的是为了减少搜索量？？？如果不排序确实可以减少，要排序还是的查找所有然后再下一步
```bash
curl -XGET "http://elasticsearch:9200/my_index/weike/_search" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "group_by_type": {
      "terms": {
        "field": "type.keyword",
        "size": 2,
        "collect_mode": "breadth_first",
        "order": {
          "play_num_sum": "asc"
        }
      },
      "aggs": {
        "play_num_sum": {
          "sum": {
            "field": "playnum"
          }
        }
      }
    }
  }
}'
```

## 统计最近7天，30天，3个月的数据
```bash
curl -XGET "http://elasticsearch:9200/kt_content/_search" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "query": {
    "constant_score": {
      "filter": {
        "bool": {
          "must": [
            {
              "term": {
                "fdDisabled": {
                  "value": 0
                }
              }
            },
            {
              "term": {
                "fdUserID": {
                  "value": 9131
                }
              }
            }
          ]
        }
      }
    }
  },
  "aggs": {
    "recent_90d": {
      "filter": {
        "range": {
          "fdCreate": {
            "gte": "now-90d"
          }
        }
      }
    },
    "recent_30d": {
      "filter": {
        "range": {
          "fdCreate": {
            "gte": "now-30d"
          }
        }
      }
    },
    "recent_7d": {
      "filter": {
        "range": {
          "fdCreate": {
            "gte": "now-7d"
          }
        }
      }
    }
  }
}'
```