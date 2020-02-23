每一个资源对象都有对应的API操作，每个API对象有3大类属性：元数据metadata，规范spec，状态status
- 元数据metadata 每个对象至少有3个元数据，`namespace`，`name`，`uid`，`labels`
- 规范spec 描述了用户期望K8s集群中的分布式系统达到的理想状态（Desired State），例如用户可以通过复制控制器Replication Controller设置期望的Pod副本数为3
- status描述了系统实际当前达到的状态（Status），例如系统当前实际的Pod副本数为2；那么RC当前的程序逻辑就会自动启动新的Pod，争取达到副本数为3

## 应用配置文件
```bash
kubectl apply -f deployment-goweb.yaml
```

## Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: myweb # name属性为Pod的名字
spec:
    replicas: 2
    selector:
        app: myweb
    template:
        metadata:
            labels:
                app: myweb
        	namespace: development # 指定Pod归于development的命令空间
        spec:
            containers:  # 包含的容器组的定义
             - name: myweb
               image: kubeguide/tomcat-app:v1
               ports:
               - containerPort: 8080 # Pod.IP加上端口表示对外通信的地址
               env:
               - name: MYSQL_SERVICE_HOST
                 value: 'mysql'
               - name: MYSQL_SERVICE_PORTT
                 value: '3306'
```

## RC
```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: frontend
spec:
  replicas: 1
  selector:
    tier: frontend
template:
  metadata:
    labels:
      app: app-demo
      tier: frontend
  spec:
    containers:
     - name: tomcat-demo
       image: tomcat
       ports:
       imagePullPolicy: IfNotPresent
       env:
       - name: GET_HOSTS_FROM
         value: dns
       ports:
       - containerPort: 80
```

## Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: gmq-service
spec:
  selector:
    app: gnode
  ports: # 存在多个enpoint的情况下，要求每个endpoint定义一个名字区分，例如tcp-port,主要用于k8s的服务发现机制
  - port: 9503 
  	name: tcp-port
  	nodePort: 9503 # 为外部程序使用，例如外部通过访问http://nodeIp:nodePort访问web服务
  - port: 9504
  	name: http-port
  	nodePort: 9504
```


## Deployment
```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: frontend
    matchExpressions:
      - {key: tier, operator: In, values: [frontend]}
  template:
    metadata:
      labels:
        app: app-demo
        tier: frontend
    spec:
      containers:
      - name: tomcat-demo
        image: tomcat
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8080
```

## HPA 
```yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: java-apache
  namespace: default
spec:
  minReplicas: 1
  maxReplicas: 10
  scaleTargetRef:
    kind: Deployment
    name: java-apache
  targetCPUUtilizationPercentage: 90 # 当Pod副本的CPUUtilizationPercentage的值超过90%时会触发自动动态扩容行为
```
```bash
kubectl autoscale deployment java-apache --cpu-percent=90 --min=1 --max=10

```

## PV
```yaml
 apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: pv0003
  spec:
    capacity:
      storage: 5Gi
    accessModes: # 指定访问模式
      - ReadWriteOnce # RWO
    persistentVolumeReclaimPolicy: Recycle # 回收策略
    storageClassName: slow # 有指定class的PV只能绑定给请求该class的PVC，没有设置storageClassName属性的PV只能绑定给未请求class的PVC
    nfs:
      path: /tmp
      server: 172.17.0.2
```


## PVC
```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: myclaim
spec:
  accessModes: # 访问模式
    - ReadWriteOnce
  resources: # 请求资源的大小
    requests:
      storage: 8Gi
  storageClassName: slow # 需要和PV的class一直
  selector: # 选择器，用于过滤PV，只有匹配了选择器标签的PV才能绑定给PVC
    matchLabels: # PV必须有一个包含该值得标签
      release: "stable"
    matchExpressions:
      - {key: environment, operator: In, values: [dev]}
```

## Namespace
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: development
```