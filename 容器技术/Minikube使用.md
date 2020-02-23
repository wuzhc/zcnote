## minikube
https://segmentfault.com/a/1190000018607114
minikube是单机版的k8s集群，它实际上是基于Kubeadm工具来部署Kubernetes的， 而Kubeadm实际就是把Kubernetes各个组件都容器化了（除了kubelet），而minikube再用虚拟机把它们都跑在一起
```bash
minikube ssh
docker ps | awk '{print $NF}'
```


## 安装过程：
https://yq.aliyun.com/articles/221687
```bash
curl -Lo minikube https://github.com/kubernetes/minikube/releases/download/v1.5.0/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/

# 启动
minikube start --image-mirror-country cn \
    --iso-url=https://kubernetes.oss-cn-hangzhou.aliyuncs.com/minikube/iso/minikube-v1.5.0.iso \
    --registry-mirror=https://xxxxxx.mirror.aliyuncs.com
```
- --image-mirror-country cn 将缺省利用 registry.cn-hangzhou.aliyuncs.com/google_containers 作为安装Kubernetes的容器镜像仓库，
- --iso-url=`*` 利用阿里云的镜像地址下载相应的 .iso 文件
- --cpus=2: 为minikube虚拟机分配CPU核数
- --memory=2000mb: 为minikube虚拟机分配内存数
- --kubernetes-version=`*`: minikube 虚拟机将使用的 kubernetes 版本

## 测试
```bash
# 查看集群配置
kubectl config view
# 查看节点
kubectl get node -o wide
# 创建一个名为goweb的Deployment，使用lingtony/goweb镜像，暴露8000端口，副本pod数为3
kubectl run goweb --image=lingtony/goweb  --port=8000 --replicas=3
# 查看deployment资源
kubectl get deployment 
# 查看pod资源
kubectl get pob
# 创建service资源，通过Nodeport方式暴露服务
kubectl expose deployment goweb --name=gowebsvc --port=80  --target-port=8000  --type=NodePort
# 查看service资源
kubectl get service
```

## dashboard
```bash
minikube dashboard
```

