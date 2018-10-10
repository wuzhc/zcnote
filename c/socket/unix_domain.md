unix domain允许在同一主机上的不同应用程序之间的通信，它通过文件系统中的一个路径名来标识；

### 地址结构 sockaddr_un
unix domain地址结构定义在<sys/un.h>
```c
struct sockaddr_un {
    sa_family_t sun_family; // AF_UNIX
    char sun_path[108]; // 向这个字段写入数据时用snprintf和strcpy避免缓冲区溢出
}
```

### 代码说明
```c
#include <sys/socket.h>
#include <sys/un.h> // 里面定义了sockaddr_un的结构
int sfd;
struct sockaddr_un sv_addr;
const char *SOCKNAME = "/tmp/mysock";

sfd = socket(AF_UNIX, SOCK_STREAM, 0); 
remove(SOCKNAME); // 如果/tmp/mysock已经存在，会bind失败，需要手动删除（因为服务器终止后，socket路径名会继续存在）
memset(&sv_addr, 0, sizeof(struct sockaddr_un)); // memset确保sv_addr结构中的所有字段为0 
sv_addr.sun_family = AF_UNIX;
strncpy(sv_addr.sun_path, SOCKNAME, sizeof(sv_addr.sun_path) - 1); // strncry指定写入到sun_path的长度，避免缓冲区溢出
bind(sfd, (struct sockaddr_un *)&sv_addr, sizeof(struct sockaddr_un)); // sv_addr指定指针类型，长度是指结构的长度
```

### demo
以下为我实现PHP扩展的两个方法
```c
// header
#ifndef DOMORE_SOCKET
#define DOMORE_SOCKET

#include <sys/socket.h>
#include <sys/un.h>

#define DOMORE_ERROR_DOCREF(msg) php_error_docref(0, E_ERROR, msg)
#define UNIX_SOCK_PATH "/tmp/mysock"
#define BUF_SIZE 10

#endif

// server
PHP_METHOD(domore_socket, unix_server)
{
    int sfd, cfd, backlog = 10;
    struct sockaddr_un sv_addr;
    ssize_t numRead;
    char buf[BUF_SIZE];

    sfd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (sfd == -1)
    {
        return ;
    }

    if (remove(UNIX_SOCK_PATH) == -1 && errno != ENOENT)
    {
        DOMORE_ERROR_DOCREF("remove failed");
    }

    memset(&sv_addr, 0, sizeof(struct sockaddr_un));
    sv_addr.sun_family = AF_UNIX;
    strncpy(sv_addr.sun_path, UNIX_SOCK_PATH, sizeof(sv_addr.sun_path) - 1);

    if (bind(sfd, (struct sockaddr_un *)&sv_addr, sizeof(struct sockaddr_un)) == -1)
    {
        DOMORE_ERROR_DOCREF("bind failed");
    }
    if (listen(sfd, backlog) == -1)
    {
        DOMORE_ERROR_DOCREF("listen failed");
    }

    for (;;)
    {
        cfd = accept(sfd, NULL, NULL); // 一次只处理一个请求，阻塞
        if (!cfd)
        {
            DOMORE_ERROR_DOCREF("accept failed");
        }
        while ((numRead = read(cfd, buf, BUF_SIZE)) > 0)
        {
            if (write(STDOUT_FILENO, buf, numRead) != numRead)
            {
                DOMORE_ERROR_DOCREF("write failed");
            }
        }
        if (numRead == -1)
        {
            DOMORE_ERROR_DOCREF("read failed");
        }
        if (close(cfd) == -1)
        {
            DOMORE_ERROR_DOCREF("close failed");
        }
    }
}

// client
PHP_METHOD(domore_socket, unix_client)
{
    int sfd;
    ssize_t numRead;
    char buf[BUF_SIZE];
    struct sockaddr_un addr;

    sfd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (sfd == -1)
    {
        DOMORE_ERROR_DOCREF("create sfd failed");
    }

    memset(&addr, 0, sizeof(struct sockaddr_un));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, UNIX_SOCK_PATH, sizeof(addr.sun_path) - 1);

    if (connect(sfd, (struct sockaddr_un *)&addr, sizeof(struct sockaddr_un)) == -1)
    {
        DOMORE_ERROR_DOCREF("connect failed");
    }

    while ((numRead = read(STDOUT_FILENO, buf, BUF_SIZE)) > 0)
    {
        if(write(sfd, buf, numRead) != numRead)
        {
            DOMORE_ERROR_DOCREF("wirte failed");
        }
    }
    if (numRead == -1)
    {
        DOMORE_ERROR_DOCREF("read failed");
    }
    if(close(sfd) == -1)
    {
        DOMORE_ERROR_DOCREF("close failed");
    }
}
```

### unix domain中的数据报
&emsp;&emsp;前面说过数据报是不可靠的，对于unix domain来说，因为数据报的传输发生在内核，所以是可靠的

### 抽象socket名空间
&emsp;&emsp;允许将UNIX domain socket绑定到一个不存在的文件系统中的名字上，具体好处如下：
- 不必担心文件名冲突
- socket关闭后会自动删除抽象名，不需要手动调用remove删除文件路径

#### demo
要创建一个抽象绑定就需要将sun_path的第一个字节设置null,具体如下：
```c
// snprintf(claddr.sun_path, sizeof(claddr.sun_path), "/tmp/ud_ucase_cl.%ld", (long)getpid());
strncpy(&claddr.sun_path[1], "xyz", sizeof(claddr.sun_path) - 2); // 抽象socket名空间
```