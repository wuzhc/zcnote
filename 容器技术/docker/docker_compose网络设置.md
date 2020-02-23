networks通常应用于集群服务，从而使得不同的应用程序得以在相同的网络中运行，从而解决网络隔离问题。

```bash
# 参考网络列表
docker network ls

# 查看某个容器网络配置
docker network inspect <container id>
```