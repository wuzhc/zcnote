## 参考
- https://segmentfault.com/a/1190000019293037?utm_source=tag-newest

全双工通讯协议，又是一种新的应用层协议

## websocket的通信原理和机制是怎么样的？
websocket是游览器和服务器的双向通信协议，在握手阶段需要依靠http协议，在http请求报文带上`upgrate:weboscket`的请求头，另外还有`Sec-WebSocket-Key`，`Sec-WebSocket-Version`，服务器握手成功后会切换到weboscket协议，并响应状态码101，`Connection: Upgrade`，`Upgrade: websocket`，`Sec-WebSocket-Accept: K7DJLdLooIwIG/MOpvWFB3y3FE8=`

### 关于`Sec-WebSocket-Key/Accept`
```
Sec-WebSocket-Key = base64(随机生成16个字节)
Sec-WebSocket-Accept = base64(sha1(Sec-WebSocket-Key + 258EAFA5-E914-47DA-95CA-C5AB0DC85B11))
```
`Sec-WebSocket-Key/Accept`并不是用来保证数据的安全性, 因为其计算/转换公式都是公开的, 而且非常简单, 最主要的作用是预防一些意外的情况



## websocket的通信协议
![https://user-gold-cdn.xitu.io/2019/5/25/16aecb1360a3221e?w=554&h=293&f=png&s=23504](https://user-gold-cdn.xitu.io/2019/5/25/16aecb1360a3221e?w=554&h=293&f=png&s=23504)
- FIN: 占1bit，每条消息可能被分割成多个数据帧，当接收到一个桢时，会根据`FIN`值来判断是否为最后一个数据帧。
	- 0表示不是消息的最后一个分片
	- 1表示是消息的最后一个分片
- RSV1, RSV2, RSV3: 各占1bit, 一般情况下全为0, 与Websocket拓展有关, 如果出现非零的值且没有采用WebSocket拓展, 连接出错
- Opcode: 占4bit
	- %x0: 表示本次数据传输采用了数据分片, 当前数据帧为其中一个数据分片
	- %x1: 表示这是一个文本帧
	- %x2: 表示这是一个二进制帧
	- %x3-7: 保留的操作代码, 用于后续定义的非控制帧
	- %x8: 表示连接断开
	- %x9: 表示这是一个心跳请求(ping)
	- %xA: 表示这是一个心跳响应(pong)
	- %xB-F: 保留的操作代码, 用于后续定义的非控制帧
- Mask: 占1bit
	- 0表示不对数据载荷进行掩码异或操作
	- 1表示对数据载荷进行掩码异或操作
- Payload length: 占7或7+16或7+64bit
	- 0~125: 数据长度等于该值
	- 126: 后续的2个字节代表一个16位的无符号整数, 值为数据的长度
	- 127: 后续的8个字节代表一个64位的无符号整数, 值为数据的长度
- Masking-key: 占0或4bytes
	- 1: 携带了4字节的Masking-key
	- 0: 没有Masking-key 掩码的作用并不是防止数据泄密,而是为了防止早期版本协议中存在的代理缓存污染攻击等问题
- payload data: 载荷数据