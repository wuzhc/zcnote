## 发送消息结构
```json
{
    "type": "send",
    "data": {
        "mine": {
            "content": "你好吗",
        },
        "to": {
            "id": "1",
            "type": "1"
        }
    }
}
```
```json
{
    "type": "send",
    "data": {
        "content": "hello swoole chat",
        "targetID": 1,
        "type": "group"
    }
}
```

## 接收消息结构
```json
{
    data: {
      username: "纸飞机" //消息来源用户名
      ,avatar: "http://tp1.sinaimg.cn/1571889140/180/40030060651/1" //消息来源用户头像
      ,id: "100000" //聊天窗口来源ID（如果是私聊，则是用户id，如果是群聊，则是群组id）
      ,type: "friend" //聊天窗口来源类型，从发送消息传递的to里面获取
      ,content: "嗨，你好！本消息系离线消息。" //消息内容
      ,mine: false //是否我发送的消息，如果为true，则会显示在右方
      ,timestamp: 1467475443306 //服务端动态时间戳
    }
}
```

## 上线
```json
{
    "type": "online",
    "data": {
        "uid": 1
    }
}
```

## 加入群组
```json
{
    "type": "joinGroup",
    "data": {
        "gid": 1
    }
}
```