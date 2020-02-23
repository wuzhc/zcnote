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




