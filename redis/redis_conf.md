# redis配置
## redis.conf
创建一个新的redis实例，需要更改如下3个配置
- pidfile
- logfile
- port
- daemonize 为yes表示守护进程 

## 启动
```bash
# 服务端启动
redis-server /etc/redis/6379.conf
# 客户端启动
redis-cli -p 6379
```
