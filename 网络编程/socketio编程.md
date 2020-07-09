## 参考
https://blog.csdn.net/lijiecong/article/details/50781417

## namespace和room
`namespace`,`room`和`socket`三者之间的关系是`room`包含`socket`,`namespace`包含`room`,`socket`如果没有指定`room`(可以通过`socket.join(room)`加入到某个房间),则默认会有一个`default room`,`room`如果没有指定`namespace`,则默认会属于`namepace /`命名空间之下

客户端连接时指定自己属于哪个namespace,使用` io.connect(  http://localhost/namespace)`。 服务端看到namespace就会把这个socket加入指定的namespace

```bash
# 广播给这个socket所属的namespace里的所有客户端,除了自己外
socket.broadcast.emit('message', "send to the clients which belong to namespace(socket belong to) except sender");

# 广播给这个socket所属的namespace下面的名为chat房间下所有客户端,除了自己外
socket.broadcast.in('chat').emit('message', "send to the clients which belong to namespace(socket belong to) except sender")

# 发送给private命名空间下的所有客户端
socketio.of('/private').send('send to all the clients which belong to namespace(priavte)')

# 发送给private命令空间下chat房间所有客户端
socketio.of('/private').in('chat').send('xxxxx')
```