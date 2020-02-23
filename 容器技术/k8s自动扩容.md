
作者：半兽人
链接：https://www.orchome.com/1260
来源：OrcHome
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

Horizontal Pod Autoscaler简称HAP，意思是Pod横向自动扩容，与之前的RC、Deployment一样，也属于一种Kubernetes资源对象。通过追踪分析RC控制的所有目标Pod的负载来自动水平扩容，如果系统负载超过预定值，就开始增加Pod的个数，如果低于某个值，就自动减少Pod的个数。目前，可以有以下两种方式作为Pod负载的度量指标