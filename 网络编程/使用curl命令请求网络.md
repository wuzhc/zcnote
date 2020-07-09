## 参考
- https://www.cnblogs.com/xingxia/p/linux_curl.html

```bash
#将服务器的cookie存储在文件上
curl -c cookie.txt http://baidu.com

#向服务器发送cookie
curl -b 'foo=bar' http://baidu.com
curl -b cookie.txt http://baidu.com

#post提交表单
curl -XPOST -d 'login=emma＆password=123' http://baidu.com

#head请求
curl -I http://baidy.com

#跳过http认证
curl -k https://baidu.com

#--limit-rate用来限制 HTTP 请求和回应的带宽，模拟慢网速的环境
curl --limit-rate 200k https://google.com

#指定curl请求的时间，到时间后会终止,单位秒
curl -m 60 http://xxxx.com

#请求数据保存到文件
curl -o example.html https://www.example.com
#-O参数将服务器回应保存成文件，并将 URL 的最后部分当作文件名
curl -O https://www.example.com/foo/bar.html

#-s参数将不输出错误和进度信息
curl -s https://www.example.com
#-S参数只输出错误
curl -S https://www.example.com

#调试模式，-v参数输出通信的整个过程
curl -v -o /dev/null https://www.example.com
```







