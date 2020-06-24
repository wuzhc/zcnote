## 批量局部更新
`doc`是关键，表示不会全量替换，只是局部更新
```bash
curl -XPUT "http://elasticsearch:9200/my_index/weike/_bulk" -H 'Content-Type: application/json' -d'
{"update":{"_id":1}}
{"doc":{"content":"es是分布式的，可能有数百个节点，你不能每次都一个一个节点上面去修改","type":"image"}}
{"update":{"_id":2}}
{"doc":{"content":"每次都是在es的扩展词典中，手动添加新词语，很坑","type":"video"}}
{"update":{"_id":3}}
{"doc":{"content":"每次添加完，都要重启es才能生效，非常麻烦","type":"course"}}
{"update":{"_id":4}}
{"doc":{"content":"直接我们在外部某个地方添加新的词语，es中立即热加载到这些新词语","type":"course"}}
{"update":{"_id":5}}
{"doc":{"content":"基于ik分词器原生支持的热更新方案，部署一个web服务器，提供一个http接口，通过modified和tag两个http响应头，来提供词语的热更新","type":"course"}}
'
```