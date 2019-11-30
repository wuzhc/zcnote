![https://img.orchome.com/group1/M00/00/03/dr5oXFv0Is2AfboAAACHQ83n5vE958.png](https://img.orchome.com/group1/M00/00/03/dr5oXFv0Is2AfboAAACHQ83n5vE958.png)
如图所示：如果我们设置了“role=frontend”的Label Selector，则会选取到Node 1和Node 2上到Pod。而设置“release=beta”的Label Selector，则会选取到Node 2和Node 3上的Pod

总结：使用Label可以給对象创建多组标签，Label和Label Selector共同构成了Kubernetes系统中最核心的应用模型，使得被管理对象能够被精细地分组管理，同时实现了整个集群的高可用性。


## 其他关于selector的使用
- `kube-controller`进程通过资源对象`RC`上定义的`Label Selector`来筛选要监控的`Pod`副本的数量，从而实现`Pod`副本的数量始终符合预期设定的全自动控制流程。

- `kube-proxy`进程通过`Service`的`Label Selector`来选择对应的`Pod`，自动建立起每个`Service`到对应`Pod`的请求转发路由表，从而实现`Service`的智能负载均衡机制。

- 通过对某些`Node`定义特定的`Label`，并且在`Pod`定义文件中使用`NodeSelector`这种标签调度策略，`kube-scheduler`进程可以实现`Pod“定向调度”`的特性。

