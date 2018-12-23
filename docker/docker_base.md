## docker入门知识
### 1. docker版本
Docker 划分为CE 和EE。CE 即社区版（免费，支持周期三个月），EE 即企业版，强调安全，付费使用。

### 2. docker中基本概念
- 镜像(Image)
- 容器(Container)，容器是镜像是实例（即以镜像为基础，创建容器，在容器里面可以部署自己的环境）
- 仓库(Repository)

### 3.docker优势
- 更高效的利用系统资源
- 更快速的启动时间
- 一致的运行环境
- 分层存储
#### 3.1 分层存储的意义
分层存储的特征还使得镜像的复用、定制变的更为容易。甚至可以用之前构建好的镜像作为基础层，然后进一步添加新的层，以定制自己所需的内容，构建新的镜像

### 4. docker安装
docker安装可以参考[这里](https://yeasy.gitbooks.io/docker_practice/content/install/)，以下以deepin为例，deepin15.8基于debian 8.0内核（cat /etc/debian_version查看）  
#### 4.1 安装命令
```bash
# 卸载旧版本
sudo apt-get remove docker.io docker-engine
# 更新下本地软件包索引
sudo apt-get update
# 安装docker-ce与密钥管理与下载相关的工具
sudo apt-get install apt-transport-https ca-certificates curl python-software-properties software-properties-common
# 下载并安装密钥
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
# 验证秘钥是否成功
sudo apt-key fingerprint 0EBFCD88
# 添加docker官方仓库
sudo add-apt-repository  "deb [arch=amd64] https://download.docker.com/linux/debian jessie stable"
# 更新本地软件源仓库
sudo apt-get update
# 安装docker-ce
sudo apt-get install docker-ce
# 查看docker版本
docker version
# 权限设置
sudo usermod -aG docker wuzhc
```
#### 4.2 配置国内镜像加速
在/etc/docker/daemon.json 中写入如下内容（如果文件不存在请新建该文件）
```bash
{
    "registry-mirrors": [
        "https://registry.docker-cn.com"
    ]
}
```
重启服务
```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl start docker
sudo systemctl stop docker
```

### 5. 基本操作
```bash
# 创建并运行容器
docker run hello-world
# 创建并运行交互式容器
# –name 给启动的容器自定义名称，方便后续的容器选择操作
# -d是后台守护进程的意思
docker run -t -i -d --name=自定义名称 IMAGE_NAME /bin/bash
# 查看容器
# -a 列出所有容器
# -l 列出最近容器
docker ps [-a] [-l]
# 查看所有容器ID
# -q 指定查看容器ID
docker ps -a -q
# 查看指定容器
# container-name可以通过docker run时设置--name
docker inspect CONTAINER_NAME | CONTAINER_ID
# 重新启动停止的容器
docker start [-i] CONTAINER_NAME
# 删除停止的容器
docker rm CONTAINER_NAME | CONTAINER_ID
# 日志
# tail行数，显示最新行数的日志
docker logs [-f] [-t] [–tail] IMAGE_NAME
# 查看容器内进程
docker top IMAGE_NAME
# 停止守护式容器
docker stop CONTAINER_NAME
docker kill CONTAINER_NAME
# 查看容器端口映射情况
docker port CONTAINER_NAME
# 删除所有容器
docker rm `docker ps -a -q`
# 删除所有镜像
docker rmi `docker images -q`
# 按条件删除镜像
# 没有打标签
docker rmi `docker images -q | awk '/^<none>/ { print $3 }'`
# 镜像名包含关键字
# doss-api为关键字
docker rmi --force `docker images | grep doss-api | awk '{print $3}'`
# 将镜像保存为一个tar文件
docker save IMAGE_NAME
# 导入tar文件为镜像
docker load -i xxx.tar
# 构建镜像
# -t 指定镜像名称
# . 指上下文目录
docker build -t nginx:v3 .
```
#### 5.1交互式
进入容器，可以执行`docker run -t -i IMAGE_NAME /bin/bash`，我们执行完需要的操作退出容器时，不要使用exit退出，可以利用`按Ctrl+P再按下Ctrl+Q`，以守护式形式推出容器。如果要再次进入容器，则执行`docker attach CONTAINER_NAME`

#### 5.2 端口映射
##### 5.2.1 映射
端口映射在创建时指定，**注意创建容器之后，映射的端口不能通过命令再次修改**，如下
```bash
docker run -p 9500:80 -i -t --name=web ubuntu /bin/bash
```
在宿主机通过访问9500端口可以访问到容器中的端口为80的服务
##### 5.2.2 查看端口映射
如果创建容器没有指定端口映射，如何查看映射呢？可以通过`docker port CONTAINER_NAME`查看，如下，箭头前面是容器暴露的端口，后面是宿主机ip和端口，即容器80端口映射到宿主机的9500端口
```bash
80/tcp -> 0.0.0.0:9500
```

### 6. 使用Dockerfile文件构建镜像
> Dockerfile包含一条条的指令，每一条指令构建一层
```bash
FROM nginx
RUN echo '<h1>Hello, Docker!</h1>' > /usr/share/nginx/html/index.html
```
#### 6.1 From基础镜像
FROM 指定基础镜像，如下：
```bash
FROM nginx
...
```
除了选择现有镜像为基础镜像外，Docker 还存在一个特殊的镜像，名为 scratch。这个镜像是虚拟的概念，并不实际存在，它表示一个空白的镜像。如果你以 scratch 为基础镜像的话，意味着你不以任何镜像为基础，接下来所写的指令将作为镜像第一层开始存在。
#### 6.2 RUN 执行命令
```bash
FROM nginx
RUN echo '<h1>Hello, Docker!</h1>' > /usr/share/nginx/html/index.html
```
每一个RUN会构建一层，即一个RUN会生成一个镜像，所以如下是错误的,太多RUN产生了很多镜像，
```bash
FROM debian:stretch
RUN apt-get update
RUN apt-get install -y gcc libc6-dev make wget
RUN wget -O redis.tar.gz "http://download.redis.io/releases/redis-5.0.3.tar.gz"
RUN mkdir -p /usr/src/redis
RUN tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1
RUN make -C /usr/src/redis
RUN make -C /usr/src/redis install
```
正确的做法应该如下：
```bash
FROM debian:stretch
RUN apt-get update \
	&& apt-get install -y gcc libc6-dev make wget \
	&& wget -O redis.tar.gz "http://download.redis.io/releases/redis-5.0.3.tar.gz" \
	&& mkdir -p /usr/src/redis \
	&& tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
	&& make -C /usr/src/redis \
	&& make -C /usr/src/redis install
```
#### 6.3 COPY 复制文件
```bash
COPY [--chown=<user>:<group>] <源路径>... <目标路径>
```
- --chown可以指定文件权限
- 源路径是相对于上下文目录
- 目标路径是用绝对路径或相对与工作目录路径（由WORKDIR指定）
- 拷贝规则可用用匹配符，例如`COPY hom?.txt /mydir/`
#### 6.4 CMD 容器启动命令


### 7. 镜像构建上下文（Context）
#### 7.1 构建原理
docker是C/S架构，构建是发生在Server端，例如当我们进行镜像构建的时候， COPY 指令、ADD 指令并非在本地构建，而是在服务端。那么服务端怎么获得本地文件呢？这就引入了上下文的概念。当构建的时候，用户会指定构建镜像上下文的路径，docker build 命令得知这个路径后，会将路径下的所有内容打包，然后上传给 Docker 引擎。这样 Docker 引擎收到这个上下文包后，展开就会获得构建镜像所需的一切文件。
#### 7.2 例子说明
```bash
 docker build -t nginx:v3 . 
```
` docker build -t nginx:v3 .`**最后面的点是在指定上下文的目录（默认和Dockerfile同个目录），不是当前目录的意思**，docker build 命令会将该目录下的内容打包交给 Docker 引擎以帮助构建镜像。知道这点有什么有？举个例子，Dockerfile中`COPY ./package.json /app/`指令中，拷贝上下文目录的package.json到app，如果理解为当前目录，然后用`COPY ../package.json /app/`指令来拷贝是上一级目录文件，这是错误的做法，报错如下，因为上下文目录是点，docker引擎只知道该目录，并不知道上一级目录

报错信息：

```bash
Sending build context to Docker daemon  3.072kB
Step 1/2 : FROM ubuntu
 ---> 93fd78260bd1
Step 2/2 : COPY ../test.txt /data/
COPY failed: Forbidden path outside the build context: ../test.txt ()
```
#### 7.3 注意问题
我们知道构建的时候，会把指定目录上传到服务端，所以一般会将 Dockerfile 置于一个空目录下，或者项目根目录下。如果该目录下没有所需文件，那么应该把所需文件复制一份过来。如果目录下有些东西确实不希望构建时传给 Docker 引擎，那么可以用 .gitignore 一样的语法写一个 .dockerignore，该文件是用于剔除不需要作为上下文传递给 Docker 引擎的。

### 疑问

- docker run可以指定端口映射，但是容器一旦生成，就没有一个命令可以直接修改
参考[修改docker容器端口映射的方法](https://blog.csdn.net/m0_37886429/article/details/82757116)，注意需要root权限

### 参考

- [deepin系统下的docker安装](https://www.jianshu.com/p/8200a3a50806)
- [gitbook](https://yeasy.gitbooks.io/docker_practice/content/introduction/)
- [Docker——入门实战](https://blog.csdn.net/bskfnvjtlyzmv867/article/details/81044217)