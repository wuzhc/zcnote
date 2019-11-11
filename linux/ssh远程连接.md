## 参考
- https://www.jianshu.com/p/540407aeb55b
- https://www.jianshu.com/p/33461b619d53

## ssh远程连接
> SSH是一种协议标准，其目的是实现安全远程登录以及其它安全网络服务。
> ssh协议全称Secure Shell Protocol, 它通过对数据进行加密,然后再传输到网络中,到另一端时进行数据解密还原原始数据,所以说是信息传输是安全的

## 提供两个服务
- ssh远程登录
- sftp文件上传下载服务

## 连接过程
- 服务端启动sshd,自动生成公钥到`/etc/ssh/ssh_host_*`
- 客户端连接请求
- 服务端传送自己的公钥发给到客户端
- 客户端将服务端的公钥记录到`~/.ssh/known_hosts`,并利用服务端的公钥加密数据,将数据传输给服务端
- 服务端利用自己的私钥进行数据解密

## 安装ssh服务端
```bash
# ubuntu
sudo apt-get install openssh-server
# sudo /etc/init.d/ssh start 这个命令不一定可以
# centos
sudo yum openssh-server
# /etc/init.d/sshd start 这个命令不一定可以

# 生成hostKey,鸟哥私房菜是说会自动生成的,但是并没有,需要我自己手动生成
ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key
```

## 配置
配置文件位于`/etc/ssh/sshd_config`

## 客户端连接命令
```bash
# -f表示本机不等待远程机,立即返回
# -p指定端口,默认是22,如果不是需要指定端口
ssh [-f] [-p port] wuzhc@127.0.0.1 [指令]

# 第一次连接会提示服务端公钥是否写入到`~/.ssh/known_hosts`
ECDSA key fingerprint is SHA256:NjoVh/HoRIemr/o4JjyGpXayKL7Xi5hEBi5K7f7+HYA.
Are you sure you want to continue connecting (yes/no)? yes
```

## 更新服务端
删除`/etc/ssh/ssh_host*`,然后重启`sshd`
```bash
rm /etc/ssh/ssh_host*
sudo /etc/init.d/sshd start
```

## 更新客户端
删除`~/.ssh/known_hosts`对应的行,然后再重连会提示,选择yes即可

## sftp命令
```bash
sftp -P 10022 root@10.10.10.198
# -P 指定端口,默认是22,不是的话需要指定

# 上传
put [本机目录或文件] [远程]
# 下载
get [远程目录或文件] [本机]
# 切换到本机时,用`l`开头,例如`lls`列出本机目录

```
一般用filezilla工具来操作`sftp`

## scp命令
```bash
# 上传
scp [-pr] [-l 速率] file [账号@]主机:目录
# 下载
scp [-pr] [-l 速率] [账号@]主机:目录 file
# -p 保留权限
# -r 复制整个目录(包括子目录)
# -l 限制网速,单位字节,1k等于8字节
# -P 指定端口,默认端口是22,如果不是的话需要指定
```

## 免密码连接
免密码连接主要利用秘钥,客户端先生成公钥和秘钥,公钥保存在服务端的`~/.ssh/authorized_keys`,秘钥保存在客户端的`~/.ssh/`中,具体过程如下:
```bash
# 客户端
ssh-keygen
scp ~/.ssh/id_rsa_test.pub wuzhc@10.10.10.198:~

# 服务端
cat id_rsa_test.pub >> .ssh/authorized_keys
chmod 644 .ssh/authorized_keys
```
### 注意
- `~/.ssh/`目录必须是700的权限才行
- `id_rsa_test`权限必须是600,否则会被认为危险的
- `authorized_keys`权限必须是644

## 总结
- id_rsa：保存私钥
- id_rsa.pub：保存公钥
- authorized_keys：保存已授权的客户端公钥
- known_hosts：保存已认证的远程主机ID（关于known_hosts详情，见文末更新内容）

## 安全性
```bash
# 允许连接的ip
vi /etc/host.allow
	sshd: 127.0.0.1 10.10.10.142
# 不允许连接的ip
vi /etc/host.deny
	sshd: ALL
```

## docker安装ssh服务
```bash
# 运行centos系统
docker run -it centos

# 安装ssh
yum install openssh-server -y 

# 生成HostKey,鸟哥私房菜说会自动创建,如果没有自动创建需要自己创建
ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key

# 修改root密码,这里连接到时候需要密码,或者不用root,自己新建一个用户
passwd root

# 编写启动脚本
vi /run.sh
# #!bin/bash
# /usr/sbin/sshd -D
chmod +x /run.sh

# 退容器
exit

# 打包修改后的容器为一个新镜像
docker commit -a "wuzhc" -m "add ssh" <container id> <image name>

# 用新的镜像运行容器
docker run --name <container name> -p 10022:22 <image name> /run.sh 

# 测试连接,root用户为容器的用户
ssh root@<宿主主机ip> -p 10022
```

## Dockerfile
```conf
FROM centos:centos7
MAINTAINER 简书：Rethink "https://www.jianshu.com/u/425d52eec5fa" "shijianzhihu@foxmail.com"

RUN yum install openssh-server -y 

#修改root用户密码
#用以下命令修改密码时，密码中最好不要包含特殊字符，如"!"，否则可能会失败；
RUN /bin/echo "rethink123" | passwd --stdin root

#生成密钥
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key \
    && ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key \
    && ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key

#修改配置信息
RUN /bin/sed -i 's/.*session.*required.*pam_loginuid.so.*/session optional pam_loginuid.so/g' /etc/pam.d/sshd \
    && /bin/sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config \
    && /bin/sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config


EXPOSE 22

CMD ["/usr/sbin/sshd","-D"]
```


