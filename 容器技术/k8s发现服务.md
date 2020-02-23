每个Kubernetes中的Service都有一个唯一的Cluster IP及唯一的名字，部署时也没有改变，所以完全可以固定在配置中

## 如何通过Service名字找到对应的Cluster IP
早期是每个Service生成一些对应的Linux环境变量（ENV），并在每个Pod的容器在启动时，自动注入这些环境变量，后来引入的DNS系统，把服务名作为dns域名


## 外部系统访问Service的问题
- Node IP：Node节点的IP地址，真实存在的地址
- Pod IP：Pod的IP地址，它是Docker Engine根据docker0网桥的IP地址段进行分配的，通常是一个虚拟的二层网络，一个Pod里的容器访问另外一个Pod里的容器，就是通过`Pod IP`所在的虚拟二层网络进行通信的，而真实的TCP/IP流量则是通过Node IP所在的物理网卡流出的
- Cluster IP：Service的IP地址，它是k8s集群内的地址，是一个虚拟IP，无法被ping
