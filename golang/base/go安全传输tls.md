## 疑问
- `x509`是什么
- 不是应该把自己的公钥发送给对方吗

`tls`传输层安全协议,它可以确保客户端和服务端之间的通信不会被攻击者窃取
## 服务端证书
确保服务器不是假的
```bash
# 私钥
openssl genrsa -out server.key 2048
# 公钥
openssl req -new -x509 -key server.key -out server.pem -days 3650
```

## 客户端证书
```bash
# 私钥
openssl genrsa -out client.key 2048
# 公钥
openssl req -new -x509 -key client.key -out client.pem -days 3650
```