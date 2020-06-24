## 遇到的问题
- 其他容器无法和etcd通信
- gopusher编译的执行程序无法在容器中运行
- nginx容器中无法启动多个命令
- gopusher上报地址需要是docker域名，不能是127.0.0.1（应该是可以的，我暴露了端口，按道理可以使用主机IP加端口访问）
- gopusher服务器监听127.0.0.1:8080时，只有指定这个127.0.0.1:8080才能连接，如果是0.0.0.0:8080，那么我可以通过127.0.0.1:8080，也可以通过192.168.1.103:8080访问



## 调试方法
- 单独将一个容器作为一个镜像运行
```bash
docker run --name=testgopusher gopusher:v1
```
- 查看日志
```bash
# -f, --follow        Follow log output.
# -t, --timestamps    Show timestamps.
# --tail="all"        Number of lines to show from the end of the logs
docker-compose logs -f --tail=10 -t gopusher
```
- 查看进程
```bash
docker-compose top gopusher
# 或者
docker-compose exec gopusher sh
netstat -anp
```
- 镜像无缓存构建
```bash
docker build --no-cache -t gopusher:v1 .
```
- 删除所有编排容器
```bash
docker-compose rm
```




