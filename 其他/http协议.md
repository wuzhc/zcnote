## 压缩
request头带有`Accept-Encoding`告诉服务器游览器可以接收哪些编码,服务器在响应时会根据游览器接收的编码进行压缩,response头响应`Content-Encoding`
### Accept-Encoding格式如下:
```bash
Accept-Encoding: gzip
Accept-Encoding: identity
Accept-Encoding: gzip, compress, br
Accept-Encoding: br;q=1.0, gzip;q=0.8, *;q=0.1
```
- identity 表明没有对实体进行编码
### 如何压缩
其实就是替换文本一些字符串,使整个文本大小变小