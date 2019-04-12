### 1. iptables防火墙

iptables默认有3个规则链，分别是INPUT（输入），OUTPUT（输出），FORWARD（转发）

- -A：追加规则
- -I：新增规则
- -D：删除规则
- -R：修改规则
- -L：查看规则
- -N：定义新的规则链
- -p：指定协议类型 
- -d：指定目标地址 
- -s：指定来源地址
- -i：指定入口网卡
- -o：指定出口网卡
- –dport：指定目标端口，input指定 (注意:--dport需要和-p结合使用,否则会报--dport不可用)
- –sport：指定源端口，output指定
- -j：指定动作类型，ACCEPT（接收）或DROP（拒绝）

#### 1.1 追加规则
```bash
iptables -A INPUT -p tcp -s 192.168.1.2 -j DROP
```
以上表示追加一条规则到INPUT链之后，来禁止192.168.1.2访问  

#### 1.2 新增规则
```bash
iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
```
以上在编号为1的位置上新增一条规则，原本该位置(这里是位置1)上的规则将会往后移动一个顺位

#### 1.3 删除规则
```bash
iptables -D INPUT 1
```
1是规则编号，通过iptables -L -n --line-number可以显示，以上标识删除编号为1的规则

#### 1.4 编辑规则
```bash
iptables -R INPUT 1 -s 192.168.0.1 -j DROP
```
1是规则编号，通过iptables -L -n --line-number可以显示，以上表示编辑编号为1的规则

#### 1.5 删除规则链
```bash
iptables -F INPUT
```

#### 1.11 保存
修改iptables后，最后需要service iptables save执行保存

### 2. 例子
#### 2.1 端口限制
```bash
# 允许外部访问22端口
iptables -A INPUT -p tcp --dport 22 -j ACCEPT 
# 允许提供22端口服务
iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT 	
```

#### 2.2 端口范围限制
```bash
iptables -A INPUT -p tcp --dport 30001:31000 -j ACCEPT
```

#### 2.3 来源IP限制
```bash
iptables -A INPUT -p tcp -s 192.168.1.2 -j DROP
```
-p tcp通过tcp访问，-s表示来源ip，即我们要限制的ip，-j DROP表示禁止访问，以上表示追加一条规则到INPUT链之后，来禁止192.168.1.2访问 

### 3. 其他问题
#### 3.1 DNS端口53设置
如果ping不通域名或host域名时超时有可能是iptables限制了53端口，设置如下：
```bash
# 请求dns解析是从53端口发出请求，所以要允许发出请求到53端口
iptables -A OUTPUT -p udp -dport 53 -j ACCEPT
# dns解析结构会响应给我们，所以要允许接收53端口发来的数据
iptables -A INPUT -p udp -sport 53 -j ACCEPT
# 除此之外还需要设置
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p udp --sport 53 -j ACCEPT
```

#### 3.2 回环地址
```bash
iptables -A INPUT -i lo -j ACCEPT
```
-i 参数是指定接口，这里的接口是lo ，lo就是Loopback（本地环回接口），意思就允许本地环回接口在INPUT表的所有数据通信。

#### 3.3 攻击
##### 3.3.1 控制单个IP的最大并发连接数
```bash
iptables -I INPUT -p tcp --dport 80 -m connlimit --connlimit-above 50 -j REJECT 
```
以上表示单个IP最大连接数为50（默认iptables模块不包含connlimit,需要自己单独编译加载）

##### 3.2 Ping洪水攻击 
```bash
iptables -A FORWARD -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT 
```

##### 3.3 防止各种端口扫描 
```bash
iptables -A FORWARD -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j ACCEPT 
```

##### 3.4 每秒中最多允许5个新连接 
```bash
iptables -A FORWARD -p tcp --syn -m limit --limit 1/s --limit-burst 5 -j ACCEPT 
```

##### 3.5 禁止外部ping
```bash
iptables -A INPUT -p icmp -j DROP 
```

### 4. 参考链接
- [https://www.cnblogs.com/itxiongwei/p/5871075.html](https://www.cnblogs.com/itxiongwei/p/5871075.html)
- [https://fp-moon.iteye.com/blog/2075707](https://fp-moon.iteye.com/blog/2075707)