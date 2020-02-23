作者：半兽人
链接：https://www.orchome.com/1322
来源：OrcHome
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

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
- etcd保存了整个集群的状态；
- apiserver提供了资源操作的唯一入口，并提供认证、授权、访问控制、API注册和发现等机制；
- controller manager负责维护集群的状态，比如故障检测、自动扩展、滚动更新等；
- scheduler负责资源的调度，按照预定的调度策略将Pod调度到相应的机器上；
- kubelet负责维持容器的生命周期，同时也负责Volume（CVI）和网络（CNI）的管理；
- Container runtime负责镜像管理以及Pod和容器的真正运行（CRI）；
- kube-proxy负责为Service提供cluster内部的服务发现和负载均衡；
- RC、RS和Deployment只是保证了支撑服务的微服务Pod的数量



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
### 命令
```bash
kubectl create -f gmq-service.yaml
kubectl get endpoints
kubectl get svc gmq-service -o yaml
```
### 外部如何访问Service
Service相当于我们的微服务，连接服务需要有通信地址，而ClusterIP属于`k8s`内部地址，不能为外部访问，可以通过`node ip`加`node port`,`node ip`是真实的物理地址，`node port`通过配置文件指定
```yaml
apiVersion: v1
kind: Service
metadata:
  name: tomcat-service
spec:
  type: NodePort
  ports:
   - port: 8080
     nodePort: 31002 # 指定node port
  selector:
    tier: frontend
```



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
复制控制器，简称`RC`，用于扩容或缩容，确保集群中的`Pod`的数量在某一时刻都符合预期值，保证了集群的高可用性，在一个 RC 定义文件中包括以下3个关键信息：
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
副本集，简称`RS`，它与RC当前存在的唯一区别是：Replica Sets支持基于集合的Label selector（Set-based selector），而RC只支持基于等式的Label Selector（equality-based selector）
主要作为`Deployment`的理想状态参数使用



## Deployment
部署，目的是为了更好地解决Pod的编排问题，它可以是创建一个新的服务，更新一个新的服务，也可以是滚动升级一个服务（新建RS，逐渐替换旧的RS）
- 创建一个`Deployment`对象来生成对应的`Replica Set`并完成Pod副本的创建过程。
- 检查`Deployment`的状态来看部署动作是否完成（Pod副本的数量是否达到预期的值）。
- 更新`Deployment`以创建新的`Pod`（比如镜像升级）。
- 如果当前`Deployment`不稳定，则回滚到一个早先的`Deployment`版本。
- 暂停`Deployment`以便于一次性修改多个`PodTemplateSpec`的配置项，之后再恢复`Deployment`，进行新的发布。
- 扩展`Deployment`以应对高负载。
- 查看`Deployment`的状态，以此作为发布是否成功的指标。
- 清理不再需要的旧版本`ReplicaSets`。

### 命令
```bash
kubectl create -f tomcat-deployment.yaml
```



### StatefulSet
StatefulSet的目的是为了为Pod提供状态，Pod的管理对象RC、Deployment、DaemonSet和Job都是面向无状态的服务，因为Pod的名字是随机产生的，Pod的IP地址也是在运行期才确定且可能有变动的，我们事先无法为每个Pod确定唯一不变的ID

- StatefulSet里的每个Pod都有稳定、唯一的网络标识，可以用来发现集群内的其他成员。假设StatefulSet的名字叫kafka，那么第一个Pod叫kafak-0，第二个Pod叫kafak-1，以此类推
- StatefulSet控制的Pod副本的启停顺序是受控的，操作第n个Pod时，前n-1个Pod已经时运行且准备好的状态。
- StatefulSet里的Pod采用稳定的持久化存储卷，通过PV/PVC来实现，删除Pod时默认不会删除与StatefulSet相关的存储卷（为了保证数据的安全）。
- 当`Pod`出现故障，会从其他节点启动一个相同名字的`Pod`，并且挂载到原来`Pod`的数据卷上
- 适合`StatefulSet`的业务包括数据库服务，例如`MySQL`



## Volume
Volume是Pod中能够被多个容器访问的共享目录
```yaml
template:
  metadata:
    labels:
      app: app-demo
      tier: frontend
  spec:
    volumes:
    - name: datavol
      emptyDir: {} # 在Pod分配到Node时创建的，无须指定宿主机上对应的目录文件，k8s会自动分配的一个目录，当Pod从Node上移除时，emptyDir中的数据也会被永久删除
    containers:
    - name: tomcat-demo
      image: tomcat
      volumeMounts:
       - mountPath: /mydata-data
         name: datavol
      imagePullPolicy: IfNotPersent
```
声明了一个名为`datavol`的数据卷，然后挂载到了容器上的`/mydata-data`

### Volume类型
- emptyDir 在Pod分配到Node时创建的，无须指定宿主机上对应的目录文件，k8s会自动分配的一个目录，当Pod从Node上移除时，emptyDir中的数据也会被永久删除
- hostPath 为在Pod上挂载宿主机上的文件或目录
- gcePersistentDisk 使用这种类型的Volume表示使用谷歌公有云提供的永久磁盘（Persistent Disk，PD）存放Volume的数据，它与emotyDir不同，PD上的内容会被永久保存，当Pod被删除时，PD只是被卸载（Unmount）,但不会被删除，节点需要是GCE虚拟机
- awsElasticBlockStore 该类型的Volume使用亚马逊公有云提供的EBS Volume存储数据，需要先创建一个EBS Volume才能使用awsElasticBlockStore。节点需要是AWS EC2实例
- NFS

### PV和PVC
PersistentVolume（简称PV）和PersistentVolumeClaim（简称PVC）是k8s提供的两种API资源，两种的主要区别如下：
- 管理员关注于如何通过pv提供存储功能而无需关注用户如何使用，同样的用户只需要挂载pvc到容器中而不需要关注存储卷采用何种技术实现。
- pvc和pv的关系与pod和node关系类似，前者消耗后者的资源。pvc可以向pv申请指定大小的存储资源并设置访问模式,这就可以通过Provision -> Claim 的方式，来对存储资源进行控制
- 总的来说就是：PV是集群中的资源，PVC是对这些资源的请求，同时也是这些资源的“提取证”
- Pod通过使用PVC（使用方式和volume一样）来访问存储。PVC必须和使用它的pod在同一个命名空间，集群发现pod命名空间的PVC，根据PVC得到其后端的PV，然后PV被映射到host中，再提供给pod

### Volume几个阶段
- Available：空闲的资源，未绑定给PVC
- Bound：绑定给了某个PVC
- Released：PVC已经删除了，但是PV还没有被集群回收
- Failed：PV在自动回收中失败了，CLI可以显示PV绑定的PVC名称。



## Namespace命名空间
用于实现多租户的资源隔离，k8s默认有个`default`的命令空间，如果不指定命令空间，默认下创建的资源都归到`default`空间下，通过`kubectl get namespaces`查看所有命令空间

指定命令空间的资源，在命令行查看时需要指定是哪个`namespaces`，例如：
```bash
# kubectl get默认是拿default命令空间的资源
kubectl get pods --namespace=development
```



## 参考

- https://blog.csdn.net/weixin_43277643/article/details/83382532
- https://www.orchome.com/1786



