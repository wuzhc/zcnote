## docker运行zipkin

```bash
docker pull openzipkin/zipkin
docker run --name zipkin -d -p 9411:9411 openzipkin/zipkin
```

游览器访问`http://127.0.0.1:9411`



## 概念

`trace_id` 整个请求链的唯一id，只要请求的trace_id 相同，不管相隔多长时间，zipkin都会归类到同一个链路中

`span_id` 在同一个请求链路下的单个请求（跟踪）的唯一id，span_id一般是不相同的

`parent_id` 也叫`parent_span_id`本次请求的上一个请求，这个是用于跟踪请求链中的每个请求之间的联系，zipkin可根据这个上下级的id关系生成服务依赖关系图



## zipkin-api的使用

