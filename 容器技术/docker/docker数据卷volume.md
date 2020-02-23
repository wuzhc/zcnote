## docker的数据卷Volume
Docker镜像是由多个文件系统（只读层）叠加而成,只读层+读写层,启动容器会加载只读层并加上一个读写层,容器不能修改只读层,如果要修改则会复制一个副本到读写层,并隐藏对应只读层的东西,所以当容器删掉然后再以镜像重启后,之前的更改会丢失.在Docker中，只读层及在顶部的读写层的组合被称为Union File System（联合文件系统）。*数据卷的作用就是主机和容器之间共享文件*
### 挂载命令
```bash
# 使用-v选项,将宿主机的/home/wuzhc/data挂载到容器的data目录
docker run -v /home/wuzhc/data:/data debian ls /data
# 查看容器数据卷挂载信息
docker inspect -f {{.Volumes}} 容器名
```

## 容器间共享数据
a容器访问b容器的`Volume`,可以使用-volumes-from参数来执行docker run
```bash
docker run -it -h 容器a --volumes-from 容器b debian /bin/bash
```

## 纯数据容器
就是专门用来做数据存储的容器

## 删除Volumes
- 该容器是用docker rm `-v`命令来删除的（-v是必不可少的）。
- docker run中使用了`--rm`参数

