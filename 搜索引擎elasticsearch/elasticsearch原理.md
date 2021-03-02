## field data，doc value
如果是标题或内容不需要keyword，不需要doc value，field data = false，`field data`会加载内存，会消耗内存空间

## 监控field data内存
```bash
curl -XGET "http://elasticsearch:9200/_stats/fielddata?fields=*"
# 查看集群所有节点field data占用情况
curl -XGET "http://elasticsearch:9200/_nodes/stats/indices/fielddata?fields=*"
```
