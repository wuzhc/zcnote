# gmq通信协议
## 请求格式
```
<cmd_name> <param_1> <param_2> ... <param_n>\r\n
```
说明:命令和多个参数以空格隔开作为字符串传输
**注意:当param为数字时会转为字符串,原因是数字的字节中可能包含和换行符号或空格符号相同的字节,这在服务端解析协议的时候会导致截断**

## 支持命令
```
# 订阅topic
sub <topic_name> <isPesist>\r\n

# 发布消息
pub <topic_name> <delay_time> <ttr_time>\r\n
[ 4-byte size in bytes ][ N-byte binary data ]

# 消费消息
pop <topic_name>\r\n
返回: RSP_SUCCESS 

# 确认已消费
ack <job_id>\r\n
```

## 响应格式
```
<response_type><message_length><message>\r\n
```
### 响应类型 response_type
- 0 (RESP_JOB) 响应消息类型,message为job内容
- 1 (RESP_ERR) 响应错误类型,message为错误信息
- 2 (RESP_MSG) 响应字符串类型,message为提示信息

## 链接
- https://github.com/wuzhc/gmq