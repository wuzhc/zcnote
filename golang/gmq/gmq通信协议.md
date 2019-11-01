# gmq通信协议
## 请求格式
```
<command_name> <param_1> <param_2> ... <param_n>\n
```
注意:
- 多个参数之间以空格隔开,并且末尾以换行`\n`结束
- 当参数为数字时,必须转为*字符串*(原因是多字节的数字可能包含换行符号或空格符号,这会导致解析协议的时候发生截断)

## 各个命令协议
### 设置topic信息
```bash
# 设置topic为自动确认消息
set <topic_name> <isAutoAck>\n
# 例如
set "topic-1" "1"\n
# 响应:成功返回结果ok,失败则返回错误消息,根据响应类型区分
```
### 发布消息
发布消息由两个命令行组成,第一个命令指定发布目标topic以及其他消息的附加属性,第二个命令为消息内容长度和消息内容,如下:
```bash
# 发布消息
pub <topic_name> <delay_time>\n
[ 4-byte size in bytes ][ N-byte binary data ]
# 例如发布一条延迟时间为20秒,内容为helloworld,topic为topic-1的消息:
pub "topic-1" "20"\n
10helloworld
# 响应:发布成功返回消息ID,失败则返回错误消息,根据响应类型区分
```

### 批量发布消息
批量发布消息由两个命令行组成,第一个命令指定发布目标topic以及消息总数,第二个命令为消息结构
```bash
pub <topic_name> <message_number>\n
<delay_time>[ 4-byte size in bytes ][ N-byte binary data ]
<delay_time>[ 4-byte size in bytes ][ N-byte binary data ]
# 响应:成功返回一个消息ID数组(经过json序列化),失败则返回错误消息,根据响应类型区分
```

### 消费消息
每次只消费一条消息
```bash
# 消费消息
pop <topic_name>\n
# 例如指定消费topic-1的消息
pop "topic-1"
# 响应:成功返回消息结构`{id:"xxx",body:"xxx",retry:"0"}`,失败则返回错误消息,根据响应类型区分
```

### 确认消息
```bash
# 确认已消费
ack <message_id>\n
# 响应:成功返回结果ok,失败则返回错误消息,根据响应类型区分
```

### 消费死信消息
```bash
dead <topic_name> <message_number>\n
# 响应:成功返回消息结构数组`[{id:"xxx",body:"xxx",retry:"0"}]`,失败则返回错误消息,根据响应类型区分
```

## 响应格式
```
# 消息格式,响应类型[2-bytes]+消息长度[4-bytys]+消息内容[n-bytes]
<response_type><message_length><message>
```

### 响应类型
不同的响应类型代表着消息内容的不同的表达方式,响应类型包含三种格式,如下:
- 101 RESP_MESSAGE,消息内容为消息结构,需要json反序列化处理,例如 消息内容为`{id:1,body:"xxxx",retry:1}`
- 102 RESP_ERROR,消息内容为错误信息
- 103 RESP_RESULT,消息内容为响应内容

## 链接
- https://github.com/wuzhc/gmq-client






