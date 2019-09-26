> gmq基于golang和redis开发的轻量级消息队列

## 功能和特性
- 支持分布式部署
- 支持延迟消息
- 消息确认删除机制
- 长连接方式
- 支持安全传输tls
- json,gob两种序列化方式
- 提供http api接口

## 注意
- 分布式情况下不保证有序性,需要单机情况下且限制一个goroutine来消费消息,消息才能保证有序性

## 部署
## 源码运行
```bash
git clone https://github.com/wuzhc/gmq.git
cd $GOPATH/src/gmq
go get -u -v github.com/kardianos/govendor # 如果有就不需要安装了
govendor sync

cd $GOPATH/src/gmq/cmd/register
go run main.go # 需要先启动注册中心

cd $GOPATH/src/gmq/cmd/gnode
go run main.go # 启动节点,启动成功后,节点会向注册中心注册自己
```

## 工作原理
![https://github.com/wuzhc/zcnote/raw/master/images/gmq/gmq%E6%B5%81%E7%A8%8B%E5%9B%BE.png](https://github.com/wuzhc/zcnote/raw/master/images/gmq/gmq%E6%B5%81%E7%A8%8B%E5%9B%BE.png)  

## 传输协议
### 请求数据包
主要分为两种类型,命令和内容
```
# 命令(命令和多个参数以空格隔开组成一个字符串,并以换行符号为结尾)
# 即一行为一组命令,注意参数不能出现空格或换行符号,如果是数字类型先转为字符串类型
cmd param_1 param_2 ...\r\n

# 消息内容(包长度+包体)
 xxxx   |  xxxx
4-bytes | n-bytes
```
### 响应数据包
```
  xx    |   xx    |   ...  |
响应类型    数据长度    数据
 2-bytes   2-bytes   n-bytes
```
更多详情参考[gmq传输协议](https://github.com/wuzhc/zcnote/blob/master/golang/gmq/gmq%E9%80%9A%E4%BF%A1%E5%8D%8F%E8%AE%AE.md)

## 客户端
- [golang客户端](https://github.com/wuzhc/gmq-client-go)
- [php客户端](https://github.com/wuzhc/gmq-client-php)
- [php-swoole客户端](https://github.com/wuzhc/gmq-client-swoole)

## 相关文章
- [gmq使用教程]()
- [gmq持久化消息](https://github.com/wuzhc/zcnote/blob/master/golang/gmq/gmq%E6%8C%81%E4%B9%85%E5%8C%96%E6%B6%88%E6%81%AF.md)
- [gmq消息确认机制](https://github.com/wuzhc/zcnote/blob/master/golang/gmq/gmq%E6%B6%88%E6%81%AF%E7%A1%AE%E8%AE%A4%E6%9C%BA%E5%88%B6.md)
- [gmq通信协议](https://github.com/wuzhc/zcnote/blob/master/golang/gmq/gmq%E9%80%9A%E4%BF%A1%E5%8D%8F%E8%AE%AE.md)
