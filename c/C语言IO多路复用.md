- I/O多路服用
- 信号驱动I/O
- Linux特有的epoll编程接口

O_NONBLOCK非阻塞IO

### 什么是文件描述符？
文件描述符是用于指代被打开的文件

### IO多路复用
可以同时检测多个文件描述符，select(), poll();这两个系统调用要么等待文件描述符成为就绪态，要么在调用中设定一个超时时间；

#### select
```c
// returns number of read file descriptors, 0 on timeout, -1 on error
#include <sys/time.h>
#include <sys/select.h>
int select(int nfds, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, struct timeval *timeout)
```
- nfds 需要检测的文件描述符最大符号，通过设置该值，select()变得更加效率，因为不需要检测大于nfds的其他文件描述符号
- readfds 检测输入是否就绪的文件描述符集合（保存结果的地方）
- writefds 检测输出是否就绪的文件描述符集合（保存结果的地方）
- exceptfds 检测异常情况的文件描述符集合（保存结果的地方）
- timeout 为NULL时，select将一直阻塞，timeout结构如下：
```c
struct timeval {
    time_t tv_sec;
    suseconds_t tv_usec; // 微妙
}
```


文件描述符集合由宏来操作
```c
#include <sys/select.h>
void FD_ZERO(fd_set *fdset)
void FD_SET(int fd, fd_set *fdset)
void FD_CLR(int fd, fd_set *fdset)
void FD_ISSET(int fd, fd_set *fdset)
```
- FD_ZERO() 将fdset指向的文件描述符集合初始化为空
- FD_SET() 将fd添加到fdset文件描述符集合
- FD_CLR() 将fd从fdset文件描述符集合移除
- FD_ISSET() fd是否为fdset文件描述符集合成员
文件描述符集合容量限制有FD_SETSIZE决定

#### poll
```c
// returns number of read file descriptors, 0 on timeout,or -1 on error
#include <poll.h>
int poll(struct pollfd fds[], nfds_t nfds, int timeout)
```
struct pollfd结构如下：
```c
struct pollfd {
    int fd;
    short events;
    short revents; 
}
```

### select和poll就绪态
select和poll只会告诉我们IO操作是否阻塞，而不是告诉我们能否成功传输数据
不同类型的描述符

### 信号驱动
进程可以处理其他任务，当有数据写入到文件描述符时，内核向调用数据的进程发送信号；在检测大量文件描述符时，信号驱动比select()和poll()有优势

### epoll
epoll优点如下：
- epoll是Linux特有的，可以同时检测多个文件描述符，并且性能比select()和poll()好；
- 支持两种模式，水平触发（level trigger）,边缘触发（edge trigger）,默认是LT模式

#### epoll api
```c
int epoll_create(int size)
```
创建一个epoll句柄，size表示告诉内核要监控多少个fd；创建之后会占用一个fd，在使用晚时需要close掉

```c
int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event)
```
事件注册函数
- epfd 由epoll_create创建返回的句柄
- op 
    - EPOLL_CTL_ADD 添加一个fd到epfd
    - EPOLL_CTL_MOD 修改已注册的fd的监听事件
    - EPOLL_CTL_DEL 从epfd删除一个fd
- fd 需要监听的fd
- struct epoll_event *event 监听事件，结构如下：
```c
struct epoll_event {
    __unit32_t events; // 例如EPOLLIN,EPOLLOUT
    epoll_data_t data;
}
```
```C
// 返回需要处理的事件数目
int epoll_wait(int epfd, struct epoll_event *event, int maxevents, int timeout)
```
等待事件的发生

### libEvent
libEvent提供了检查文件描述符IO事件的抽象；Libevent底层机制能够以透明的方式应用select(),poll(),epoll(),信号驱动等任意一种技术

### 工作模式（水平触发，边缘触发）
- 水平触发：检测到文件描述符有事件发送并通知应用程序，应用程序可以不立即处理事件
- 边缘触发：检测到文件描述符有事件发送并通知应用程序，应用程序必须立即处理事件

各种IO模式通知模式如下： 

|IO模式|水平触发|边缘触发|
|:---:|:---:|:---:|
|select(),poll()|Y|N|
|信号驱动|N|Y|
|epoll|Y|Y|



