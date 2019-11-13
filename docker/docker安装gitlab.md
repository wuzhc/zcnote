## 参考
- [https://www.jianshu.com/p/080a962c35b6](https://www.jianshu.com/p/080a962c35b6)

```bash
# 获取gitlab镜像
docker pull gitlab/gitlab-ce
# 创建映射文件假
mkdir -p /home/wuzhc/gitlab/etc
mkdir -p /home/wuzhc/gitlab/log
mkdir -p /home/wuzhc/gitlab/data
# 运行容器
docker run \
    --detach \
    -p 8443:443 \
    -p 80:80 \
    -p 222:22 \
    --name gitlab \
    --restart unless-stopped \
    -v /home/wuzhc/gitlab/etc:/etc/gitlab \
    -v /home/wuzhc/gitlab/log:/var/log/gitlab \
    -v /home/wuzhc/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce
# 修改配置文件
vi /home/wuzhc/gitlab/etc/gitlab.rb
external_url 'http://10.8.8.165'
gitlab_rails['gitlab_ssh_host'] = '10.8.8.165'
gitlab_rails['gitlab_shell_ssh_port'] = 222 # 此端口是run时22端口映射的222端口
```
- 只有80端口成功了

## web访问
http://10.8.8.165:8090

##　注册runner
```bash
mkdir -p ~/gitlab-runner/runnertest/builder

# 启动runner
sudo docker run -d --name runnertest-builder --restart always \
	-v /home/wuzhc/gitlab-runner/runnertest/builder:/etc/gitlab-runner \
	-v /var/run/docker.sock:/var/run/docker.sock \
	gitlab/gitlab-runner:latest

# 注册
sudo docker exec -it runnertest-builder gitlab-runner register
```

待补充...