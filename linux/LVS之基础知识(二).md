LVS,Linux虚拟服务器
### 关键词
ip负载均衡技术(ipvs模块),自动屏蔽故障机器,多台服务器组成一台虚拟的服务器,不能直接配置ipvs模块,需要借助ipvsadmin,可以直接通过keepalived直接管理ipvs
### 功能
LVS主要用于服务器集群的负载均衡。它工作在网络层，可以实现高性能，高可用的服务器集群技术  - 3种IP负载均衡技术
- 10种连接调度算法
- 3种防卫策略(大规模拒绝服务)
### 专业术语
- vip,虚拟IP地址,为客户机提供服务的IP地址,LVS是面向客户端,所以需要一个公网IP才能服务在互联网上,我们称配置在LVS服务器上的公网IP为VIP
- rip,真实IP地址,真正处理请求服务器的内网IP
- dip,director的IP地址,director用于连接内外网络的IP地址,物理网卡上的IP地址,是负载均衡器上的IP;配置在LVS服务器上的内网ip称为DIP
- cip,客户端的IP地址  
![](http://www.zsythink.net/wp-content/uploads/2017/07/070617_0124_2.png)  
### ip报文转换
cip -> lvs -> 将请求报文中的目标IP修改为后端某个realServer的rip
realServer响应 -> lvs的dip -> 修改为vip 