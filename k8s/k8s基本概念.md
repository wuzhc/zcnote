k8s是一个容器集群管理平台，具有如下特点：
- 具有完备的集群管理能力，包括
	- 多层次的安全防护和准入机制
	- 多租户应用支撑能力
	- 透明的服务注册和服务发现机制
	- 内建智能负载均衡器
	- 强大的故障发现和自我修复能力
	- 服务滚动升级和在线扩容能力、可扩展的资源自动调度机制
	- 多粒度的资源配额管理能力
- 提供了完善的管理工具，这些工具涵盖了包括开发、部署测试、运维监控在内的各个环节



## 整体架构
![https://images2015.cnblogs.com/blog/1087716/201704/1087716-20170411111532391-899038129.png](https://images2015.cnblogs.com/blog/1087716/201704/1087716-20170411111532391-899038129.png)



## Label
Label是一个键值对，Label可以附加到各种资源对象上，例如Node、Pod、Service、RC等，一个资源对象可以定义任意数量的Label，同一个Label也可以被添加到任意数量的资源对象上去，，Label通常在资源对象定义时确定，也可以在对象创建后动态添加或者删除。

### Label筛选
通过标签选择器（Label Selector）筛选满足`Label`的资源对象，筛选规则如下：
- name=redis-slave：匹配所有具有标签name=redis-slave的资源对象。
- env != production：匹配所有不具有标签env=production的资源对象，比如env=test就满足此条件的标签之一。
- name in (redis-master)：匹配所有具有标签name=redis-master或者name=redis-slave的资源对象。
- name not in (php-frontend)：匹配所有不具有标签name=php-frontend的资源对象。

复合条件
- name=redis-slave,env!=production
- name notin (php-fronted),env!=production



## Service
Service (服务)是分布式集群架构的核心,它是定义了Pod的逻辑集合，Service提供了一个统一的服务访问入口以及服务代理和发现机制，关联多个相同Label的Pod，用户不需要了解后台Pod是如何运行，具有如下特征：
- 拥有一个唯一指定的名字 (比如mysql-server)。
- 拥有一个虚拟IP (ClusterIP、ServiceIP或VIP)和端口号。
- 能够提供某种远程服务能力。
- 被映射到了提供这种服务能力的 一组容器应用上。



## Pod
Pod的目的是为`Service`提供进程隔离，可以将Service对应映射的容器运行在独立`Pod`中,每个 Pod 里运行着一个`Pause容器`，其他容器则为业务容器，这些业务容器共享`Pause容器`的网络栈和Volume挂载卷，除此之外，`Pause容器`状态代表这整个`Pod`状态

集群内任意两个Pod可以直接通信，一个Pod里的容器与另外主机上的Pod容器能够直接通信

为了建立Service和Pod间的关联关系， Kuberneters 给每个Pod贴上一个`标签(Label)`,而Service也定义`标签选择器（Label Selector）`，通过`Service`的`label selector`找到对应的`label`的`Pod`


![https://upload-images.jianshu.io/upload_images/6534887-ea180ac7944c2baa.png?imageMogr2/auto-orient/strip|imageView2/2/w/501/format/webp](https://upload-images.jianshu.io/upload_images/6534887-ea180ac7944c2baa.png?imageMogr2/auto-orient/strip|imageView2/2/w/501/format/webp)
一个 pod 包含一组容器，一个 pod 不会跨越多个工作节点


![https://img.orchome.com/group1/M00/00/03/dr5oXFv0IS-AbqyhAACfzxoTgIY518.png](https://img.orchome.com/group1/M00/00/03/dr5oXFv0IS-AbqyhAACfzxoTgIY518.png)
在默认情况下，当Pod里的某个容器停止时，Kubernetes会自动检测到这个问题并且重新启动这个Pod（重启Pod里的所有容器），如果Pod所在的Node宕机，则会将这个Node上的所有Pod重新调度到其他节点上。Pod、容器与Node的关系图如图所示。

```bash
kubectl describe pod xxxx # 来查看Pod的描述信息
```

### 资源配额
当前可以设置资源限额的计算机资源有两种，`memory`（单位字节数）和`cpu`（单位核数，500m表示占用0.5个cpu），对计算机资源进行配额需要指定以下两个参数：
- Request：该资源的最小申请量，系统必须满足要求。
- Limits：该资源最大允许使用量，不能被突破，当容器试图使用超过这个量的资源时，可能会被Kubernetes Kill并重启。
```yaml
spec:
   containers:
   - name: db
     image: mysql
     resources:
       request:
        memory: "64Mi"
        cpu: "250m"
       limits:
        memory: "128Mi"
        cpu: "500m"
```



## Node
`Pod`运行在node节点上，这个节点可以是物理机又或者是私有云公有云中的一个虚拟机，一个node节点可以运行多个`Pod`

Node 上运行着k8s的`kubelet`、 `kube-proxy`服务进程
- `kubelet`，负责`Pod`的创建、启动、监控、重启、销毁，另外kubelet会向master注册自己，定期向master汇报自己的情况，这要master就可以获得node资源使用情况，从而实现高效均衡等资源调度策略
- `kube-proxy`实现软件模式的负载均衡器

### 命令
```bash
# 查看集群所有node节点
kubectl get nodes
# 查看node节点描述
kubectl describe node <name>
```
使用`kubectl get nodes`命令可以查看集群中有多少个node节点



## Master
k8s将集群中的机器划分为一个`Master节点`和一群`工作节点(Node)`，在Master节点上运行着集群管理相关的一组进程`api server`、`controller-manager`和`scheduler`，这些进程实现了整个集群的资源管理、 `Pod`调度、弹性伸缩、安全控制、系统监控和纠错等管理功能，井且都是全自动完成的
![https://upload-images.jianshu.io/upload_images/6534887-ad58ca339c403a4b.png?imageMogr2/auto-orient/strip|imageView2/2/w/701/format/webp](https://upload-images.jianshu.io/upload_images/6534887-ad58ca339c403a4b.png?imageMogr2/auto-orient/strip|imageView2/2/w/701/format/webp)
- api server，提供了 HTTP Rest 接口的关键服务进程，是Kubernetes里所有资源的增、删、改、查等操作的唯一入口，也是集群控制的入口进程。
- controller manager，Kubernetes里所有资源对象的自动化控制中心，可以理解为资源对象的“大总管”
- scheduler，负责资源调度（Pod调度）的进程，相当于公交公司的“调度室”
- etcd，Kubernetes里的所有资源对象的数据全部是保存在etcd



## Replication Controller
用于扩容或缩容，确保集群中的`Pod`的数量在某一时刻都符合预期值，保证了集群的高可用性，在一个 RC 定义文件中包括以下3个关键信息：
- 目标Pod的定义。
- 目标 Pod 需要运行的副本数量( Replicas)
- 要监控的目标 Pod 的标签( Label)

### 命令
```bash
# 修改rc副本数量
kubectl scale rc redis-slave --replicas=3
```

### 注意
删除`RC`不会影响已创建好的`Pod`,如果要删除所有`Pod`，可以设置`replicas=0`,然后更新`RC`，另外，kubectl提供了stop和delete命令来一次性删除RC和RC控制的全部Pod。

### 总结
在大多数情况下，我们通过定义一个RC实现Pod的创建过程及副本数量的自动控制。
- RC里包括完整的Pod定义模版。
- RC通过Label Selector机制实现对Pod副本的自动控制。
- 通过改变RC里的Pod副本数量，可以实现Pod的扩容或缩容功能。
- 通过改变RC里的Pod模版中的镜像版本，可以实现Pod的滚动升级功能。



## Replication Set
它与RC当前存在的唯一区别是：Replica Sets支持基于集合的Label selector（Set-based selector），而RC只支持基于等式的Label Selector（equality-based selector）


## 参考
- https://blog.csdn.net/weixin_43277643/article/details/83382532
- https://www.orchome.com/1786



