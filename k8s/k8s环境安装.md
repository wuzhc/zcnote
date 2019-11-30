## 安装kubectl
https://kubernetes.io/docs/tasks/tools/install-kubectl/#before-you-begin
```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version

# 安装bash-completion，有则不需要安装，通过命令type _init_completion可以知道
apt-get install bash-completion
source /usr/share/bash-completion/bash_completion

# 确定kubectl自动完成
echo 'source <(kubectl completion bash)' >>~/.bashrc
kubectl completion bash >/etc/bash_completion.d/kubectl

# 命令简写
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc
```

## minikube
https://yq.aliyun.com/articles/221687
执行`cluster-info`会报如下错误，是因为缺少`k8s`节点
```bash
The connection to the server <server-name:port> was refused - did you specify the right host or port?
````

如果要在本机上体验`kos`，则需要`minikube`作为`k8s`一个节点，执行`kubectl 
安装过程：
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



