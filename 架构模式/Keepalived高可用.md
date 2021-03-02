## keepalived安装
```bash
cp /opt/keepalived-2.1.5/keepalived/etc/init.d/keepalived /etc/init.d/keepalived
systemctl start keepalived.service
```

## keepalived功能
- 失败接管，主节点失败由备节点接管
- `keepalived.conf`里配置就可以实现`lvs`功能
- 可以对`lvs`下面的集群节点做健康检查

## VRRP协议
虚拟路由器冗余协议，用于主要用于解决静态路由单点故障的，通过竞选机制来确定主备，通过IP多播的方式实现通信。

## keepalived原理
`keepalived`高可用之间是通过`VRRP`协议通信的，`VRRP`协议是通过竞选机制来确定主备的，主的优先级高于备，因此，工作时会主会获得所有资源，备处于等待状态，当主挂掉后，备节点接管主节点资源，然后代替主节点对外继续提供服务。

