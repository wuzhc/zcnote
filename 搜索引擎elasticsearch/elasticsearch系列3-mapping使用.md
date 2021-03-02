`mapping`是用来定义文档及其字段的存储方式、索引方式的手段,例如:
- 哪些字段需要被定义为全文检索类型
- 哪些字段包含number、date类型等
- 格式化时间格式
- 自定义规则，用于控制动态添加字段的映射

## mapping-type
每个索引都拥有唯一的`mapping type`，用来决定文档将如何被索引,组成如下:
- Meta-fields
元字段用于自定义如何处理文档的相关元数据。 元字段的示例包括文档的`_index`，`_type`，`_id`和`_source`字段
- Fields or properties
映射类型包含与文档相关的字段或属性的列表。

## 字段类型
包括text、keyword、double、boolean、long、date、ip等等

### text类型
text类型的字段用来做全文检索，例如邮件的主题、淘宝京东中商品的描述等。这种字段在被索引存储前先进行分词，存储的是分词后的结果，而不是完整的字段。text字段不适合做排序和聚合。如果是一些结构化字段，分词后无意义的字段建议使用keyword类型，例如邮箱地址、主机名、商品标签等。

### keyword类型
keyword用于索引结构化内容（例如电子邮件地址，主机名，状态代码，邮政编码或标签）的字段，这些字段被拆分后不具有意义，所以在es中应索引完整的字段，而不是分词后的结果。
keyword只能按照字段精确搜索,通常用于过滤（例如在博客中根据发布状态来查询所有已发布文章），排序和聚合
```bash
PUT my_index
{
  "mappings": {
    "properties": {
      "title": {
        "type":  "text",
        "analyzer": "ik_max_word", 
        "search_analyzer": "ik_smart", 
         "fields": {
          	"keyword" : {"ignore_above" : 256, "type" : "keyword"}
        }
      }
    }
  }
}
```
- index：是否可以被搜索到。默认是true
- fields: 允许同一个字符串值同时被不同的方式索引
- null_value: 默认值
- ignore_above es不会索引大小超过它设置的值

### date类型
支持排序，且可以通过format字段对时间格式进行格式化
json中没有时间类型，所以在es在规定可以是以下的形式:
- "2015-01-01"或者"2015/01/01 12:10:30"
- 距某个时间的毫秒数，例如1420070400001
- 距某个时间的秒数

### object类型
默认`field`为`object`类型

## range类型
支持以下范围类型
- integer_range	-2的31次 到 2的31次-1.
	 float_range	32位单精度浮点数
	 long_range	-2的63次 到 2的63次-1.
	 double_range	64位双精度浮点数
	 date_range	unsigned 64-bit integer milliseconds
	 ip_range	ipv4和ipv6或者两者的混合
使用如下:
```bash
PUT range_index
{
  "settings": {
    "number_of_shards": 2
  },
  "mappings": {
    "properties": {
      "age_range": {
        "type": "integer_range"
      },
      "time_frame": {
        "type": "date_range", 
        "format": "yyyy-MM-dd HH:mm:ss||yyyy-MM-dd||epoch_millis"
      }
    }
  }
}

PUT range_index/_doc/1?refresh
{
  "age_range" : { 
    "gte" : 10,
    "lte" : 20
  },
  "time_frame" : { 
    "gte" : "2015-10-31 12:00:00", 
    "lte" : "2015-11-01"
  }
}
```