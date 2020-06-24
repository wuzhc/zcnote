lvs对网络的依赖比较大
内核模块`ip_vs`
管理工具：`ipvsadm`,`keepalive`
查看是否安装`ipvsadm`，使用命令`sudo ipvsadm -L`
网卡可以设置多个`IP`


## LVS的工作模式
- NAT模式
- TUN模式
- DR模式

## 宿主机
```bash
sudo apt-get update # 更新源 
sudo apt-get install ipvsadm # 安装 ipvsadm 工具
sudo ipvsadm -L # 查看ipvsadm规则
sudo ipvsadm -C # 清除ipvsadm规则
cat /proc/sys/net/ipv4/ip_forward #1 1 说明此机器已开启内核路由转发
```

## docker
```bash
# --privileged表示容器内root用户真正拥有宿主机root的权限
docker run --privileged --name=RealServer1 -ti ubuntu
docker run --privileged --name=RealServer2 -ti ubuntu

apt-get update
apt-get install vim -y 
apt-get install nginx -y
service nginx start
```

## NAT模式
```bash
#添加虚拟服务器
sudo ipvsadm -A -t 192.168.1.103:80 -s rr
#为虚拟服务器增加真实服务器,参数参考下面
sudo ipvsadm -a -t 192.168.1.103:80 -r 172.17.0.2 -m
sudo ipvsadm -a -t 192.168.1.103:80 -r 172.17.0.3 -m
#查看ipvs定义的规则
sudo ipvsadm -l
```

## DR模式
```bash
docker run --privileged --name=LoadBalancer -ti ubuntu
```
- a)通过在调度器LB上修改数据包的目的MAC地址实现转发。注意，源IP地址仍然是CIP，目的IP地址仍然是VIP。
b)请求的报文经过调度器，而RS响应处理后的报文无需经过调度器LB，因此，并发访问量大时使用效率很高，比Nginx代理模式强于此处。
c)因DR模式是通过MAC地址的改写机制实现转发的，因此，所有RS节点和调度器LB只能在同一个局域网中。需要注意RS节点的VIP的绑定(lo:vip/32)和ARP抑制问题。
d)强调下：RS节点的默认网关不需要是调度器LB的DIP，而应该直接是IDC机房分配的上级路由器的IP(这是RS带有外网IP地址的情况)，理论上讲，只要RS可以出网即可，不需要必须配置外网IP，但走自己的网关，那网关就成为瓶颈了。
e)由于DR模式的调度器仅进行了目的MAC地址的改写，因此，调度器LB无法改变请求报文的目的端口。LVS DR模式的办公室在二层数据链路层（MAC），NAT模式则工作在三层网络层（IP）和四层传输层（端口）。
f)当前，调度器LB支持几乎所有UNIX、Linux系统，但不支持windows系统。真实服务器RS节点可以是windows系统。
g)总之，DR模式效率很高，但是配置也较麻烦。因此，访问量不是特别大的公司可以用haproxy/Nginx取代之。这符合运维的原则：简单、易用、高效。日1000-2000W PV或并发请求1万以下都可以考虑用haproxy/Nginx(LVS的NAT模式)
h)直接对外的访问业务，例如web服务做RS节点，RS最好用公网IP地址。如果不直接对外的业务，例如：MySQL，存储系统RS节点，最好只用内部IP地址。

### ipvsadm参数说明
```bash
# 添加集群服务
-A：添加一个新的集群服务
-t: 使用 TCP 协议
-s: 指定负载均衡调度算法
rr：轮询算法(LVS 实现了 8 种调度算法)

# 添加 Real Server 规则
-a：添加一个新的 RealServer 规则
-t：tcp 协议
-r：指定 RealServer IP 地址
-m：定义为 NAT 
```