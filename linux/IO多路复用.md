### 高并发

#### select

```c
int select(int nfds, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, struct timeval *timeout);
```

- 有连接请求抵达了再检查处理。
- 句柄上限+重复初始化+逐个排查所有文件句柄状态效率不高。

#### poll

poll 主要解决 select 的前两个问题：通过一个 pollfd 数组向内核传递需要关注的事件消除文件句柄上限，同时使用不同字段分别标注关注事件和发生事件，来避免重复初始化。4、

- 设计新的数据结构提供使用效率。
- 逐个排查所有文件句柄状态效率不高。

#### epoll

- 只返回状态变化的文件句柄。
- 只有Linux特有

> epoll技术的编程模型就是异步非阻塞回调，也可以叫做Reactor，事件驱动，事件轮循（EventLoop）。Nginx，libevent，node.js这些就是Epoll时代的产物。libevent已支持以下接口/dev/poll, kqueue, event ports, select, poll 和 epoll