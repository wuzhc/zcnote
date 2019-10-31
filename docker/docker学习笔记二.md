## 隔离
- Linux的命名空间
- 根文件系统
- 虚拟网络组件

为每个容器创建一个`PID`命名空间是Docker的关键特征
```bash
docker exec 容器名 ps
```
查看容器内进程列表

## 使用环境变量 env
`-e`用于注入环境变量
```
docker run -e MY_ENVIRONMENT_VAR="hello world" 镜像 
```
进入容器,可以通过`env`命令查看容器中有哪些环境变量

