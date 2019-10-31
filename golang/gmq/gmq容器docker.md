## docker运行
除上面之后,还可以直接运行gmq的容器
```bash
# 启动注册中心
docker run --name=gmq-register -p 9595:9595 --network=gmq-network  wuzhc/gmq-image:v1 gregister -http_addr=":9595"

# 启动节点
docker run --name=gmq-node -p 9503:9503 -p 9504:9504 --network=gmq-network  wuzhc/gmq-image:v1 gnode -node_id=1 -tcp_addr=gnode:9503 -http_addr=gnode:9504 -register_addr=http://gmq-register:9595

# 启动web管理
docker run --name=gmq-web -p 8080:8080 --network=gmq-network wuzhc/gmq-image:v1 gweb -web_addr=":8080" -register_addr="http://gmq-register:9595"

# 启动客户端
docker run --name=gmq-client --network=gmq-network wuzhc/gmq-image:v1 
docker exec gmq-client gclient -node_addr="gmq-node:9503" -cmd="push" -topic="gmq-topic-1" -push_num=1000
docker exec gmq-client gclient -node_addr="gmq-node:9503" -cmd="pop_loop" -topic="gmq-topic-1" 
```