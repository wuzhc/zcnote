>  用户可以很方便使用Dockerfile模板来定义一个应用容器,实际应用程序中,需要多个容器一起使用,这个时候就是docker-compose的用途了

## 安装
```bash
sudo curl -L https://github.com/docker/compose/releases/download/1.17.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
# 查看版本
docker-compose --version
# 卸载
sudo rm /usr/local/bin/docker-compose
```

## 概念
配置文件`docker-compose.yml`如下:
```bash
version: "3"

services:
  webapp:
    image: examples/web
    ports:
      - "80:80"
    volumes:
      - "/data"
```
### 服务(service)
如上配置文件中的`services`,下面的`webapp`就是其中一个服务(容器)
### 项目(project)
整个docker-compose就是由多个服务组成的环境

## 命令
### 重新构建服务
如果改变了某个服务的Dockerfile配置,需要重新build
```bash
docker-compose build [options] 服务名称 
--force-rm 删除构建过程中的临时容器。
--no-cache 构建镜像过程中不使用 cache（这将加长构建过程）。
--pull 始终尝试通过 pull 来获取更新版本的镜像。
```

### 运行服务容器
默认情况下，如果存在关联，则所有关联的服务将会自动被启动，除非这些服务已经在运行中。
```bash
docker-compose run 服务名
```

### 启动已经存在的服务
和`docker-compose run`的区别在于run是没有创建过的,需要构建镜像,start是已经存在的服务,只是处于停止状态而已
```bash
docker-compose start 服务名
```

### 停止所有服务
该命令会停止up命令所启动的容器
```bash
docker-compose down
```

### 进入服务终端
```bash
docker-compose exec 服务名 bash
```

### 杀死服务
```bash
docker-compose kill 服务名
```

### 查看服务日志
在调试问题的时候很有用
```bash
docker-comose logs 服务名
```

### 查看服务容器端口所映射的公共端口
```bash
docker-compose port 服务名
```

### 查看项目中所有服务
```bash
docker-compose ps
# -q 和docker -a -q一样,只打印容器ID的信息	
```

### 重启项目中的所有服务
```bash
docker-compose restart 
```

### 删除服务容器
```bash
docker-compose rm [options]
# -f, --force 强制直接删除，包括非停止状态的容器。一般尽量不要使用该选项。
# -v 删除容器所挂载的数据卷。
```

### 查看服务容器进程
```bash
docker-compose top 
```
