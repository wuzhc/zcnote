发布消息:
curl -d 'hello world 1' 'http://127.0.0.1:4151/pub?topic=wuzhc'
 
## 部署
需要3各节点

etcd需要v2版本
export ETCD_ENABLE_V2=true
etcd

#nsqlookupd
go run nsqlookupd.go --config=/data/wwwroot/go2/youzan_nsq/contrib/nsqlookupd.cfg.example

#nsqd
go run nsqd.go --config=/data/wwwroot/go2/youzan_nsq/contrib/nsqd.cfg.example

#nsqadmin
go run main.go --config=/data/wwwroot/go2/youzan_nsq/contrib/nsqadmin.cfg.example