> iptables可以理解为客户端代理,真正防火墙是`netfilter`,`iptables`可以由用户定义一系列规则,然后通过对数据包(报文)比较,进行处理

## 参考
- http://www.zsythink.net/archives/1199

## 规则
源地址`-s`,目标地址`-d`,传输协议(tcp,udp,icmp)`-p`,服务类型(http,http,smtp)
## 处理行为
接收accept,拒绝reject,丢弃drop`-j`
## 命令
```bash
# 追加一条禁止192.168.1.2访问的规则到INPUT链上
iptables -A INPUT -p tcp -s 192.168.1.2 -j DROP
# 新增禁止访问80端口的规则到INPUT链上
# 在编号为1的位置上新增一条规则，原本该位置(这里是位置1)上的规则将会往后移动一个顺位
iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
# 删除INPUT链上规则,位置为1,可以通过`iptables -L -n --line-number`
iptables -D INPUT 1
# 编辑INPUT链上规则
iptables -R INPUT 1 -s 192.168.1.2 -j DROP
# iptables生效
service iptables save
```
更多命令参考: [iptables防火墙设置](https://gitee.com/wuzhc123/zcnote/blob/master/linux/iptables%E9%98%B2%E7%81%AB%E5%A2%99%E8%AE%BE%E7%BD%AE.md)

## 传递数据包流程
例如client访问server,首先发送报文到网卡,然后网卡通过内核的tcp传输协议传输到用户空间的web服务上,iptables是在内核空间设置的关卡,例如`input`,`output`
![http://www.zsythink.net/wp-content/uploads/2017/02/021217_0051_2.png](http://www.zsythink.net/wp-content/uploads/2017/02/021217_0051_2.png)
由上图可知,报文流向场景如下:
- 到本机的某进程的报文 prerouting -> input
- 由本机转发的报文 prerouting -> forward -> postrouting
- 由本机的某进程发出的报文 output -> postrouting

## iptables五链和四表
### 五链
- input
- output
- prerouting 路由前
- forward 转发
- postrouting 路由后  
![http://www.zsythink.net/wp-content/uploads/2017/02/021217_0051_3.png](http://www.zsythink.net/wp-content/uploads/2017/02/021217_0051_3.png)  
每一条链上都有很多规则
### 四表
什么是表,表即是对链上规则的分类,即同一个类的规则在同一个表
- filter表,负责过来功能
- nat表,网络地址转换
- mangle表,拆解报文,作出修改,并重新封装
- raw表,关闭nat表上启用的连接追踪机制
## 链表关系
如果一条链上有多个表,则表的执行优先级为`raw --> mangle --> nat --> filter`,每条链也有特定的可以使用哪些表,如下:
- input上的规则可以存在于`mangle`,`filter`
- output上的规则可以存在于`raw`,`mangle`,`nat`,`filter`
- prerouting上的规则可以存在于`raw`,`mangele`,`nat`
- forward上的规则可以存在于`mangle`,`filter`
- postrouting上的规则可以存在于`mangle`,`nat`
![http://www.zsythink.net/wp-content/uploads/2017/02/021217_0051_6.png](http://www.zsythink.net/wp-content/uploads/2017/02/021217_0051_6.png)









