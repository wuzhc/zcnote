## 参考
- https://blog.csdn.net/weixin_43277643/article/details/83382532
- https://www.orchome.com/1786

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

## Service
Service (服务)是分布式集群架构的核心,它是定义了Pod的逻辑集合，Service提供了一个统一的服务访问入口以及服务代理和发现机制，关联多个相同Label的Pod，用户不需要了解后台Pod是如何运行，具有如下特征：
- 拥有一个唯一指定的名字 (比如mysql-server)。
- 拥有一个虚拟IP (ClusterIP、ServiceIP或VIP)和端口号。
- 能够提供某种远程服务能力。
- 被映射到了提供这种服务能力的 一组容器应用上。

## Pod
Pod的目的是为`Service`提供进程隔离，可以将Service对应映射的容器运行在独立`Pod`中

为了建立Service和Pod间的关联关系， Kuberneters 给每个Pod贴上一个`标签(Label)`,而Service也定义`标签选择器（Label Selector）`，通过`Service`的`label selector`找到对应的`label`的`Pod`

一个 pod 包含一组容器，一个 pod 不会跨越多个工作节点
![https://upload-images.jianshu.io/upload_images/6534887-ea180ac7944c2baa.png?imageMogr2/auto-orient/strip|imageView2/2/w/501/format/webp](https://upload-images.jianshu.io/upload_images/6534887-ea180ac7944c2baa.png?imageMogr2/auto-orient/strip|imageView2/2/w/501/format/webp)


## Node
`Pod`运行在node节点上，这个节点可以是物理机又或者是私有云公有云中的一个虚拟机，一个node节点可以运行多个`Pod`

每个 Pod 里运行着一个`Pause容器`，其他容器则为业务容器，这些业务容器共享`Pause容器`的网络栈和Volume挂载卷

Node 上运行着k8s的`kubelet`、 `kube-proxy`服务进程，`kubelet`负责`Pod`的创建、启动、监控、重启、销毁；`kube-proxy`实现软件模式的负载均衡器

## Master
k8s将集群中的机器划分为一个`Master节点`和一群`工作节点(Node)`，在Master节点上运行着集群管理相关的一组进程`apiserver`、`controller-manager`和`scheduler`，这些进程实现了整个集群的资源管理、 `Pod`调度、弹性伸缩、安全控制、系统监控和纠错等管理功能，井且都是全自动完成的
![https://upload-images.jianshu.io/upload_images/6534887-ad58ca339c403a4b.png?imageMogr2/auto-orient/strip|imageView2/2/w/701/format/webp](https://upload-images.jianshu.io/upload_images/6534887-ad58ca339c403a4b.png?imageMogr2/auto-orient/strip|imageView2/2/w/701/format/webp)

## Replication Controller
用于扩容，在一个 RC 定义文件中包括以下3个关键信息：
- 目标Pod的定义。
- 目标 Pod 需要运行的副本数量( Replicas)
- 要监控的目标 Pod 的标签( Label)



