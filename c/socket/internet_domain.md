### 网络字节序
不同的主机会以不同的顺序存储一个多字节整数，为了所有主机能够理解端口和IP地址，需要一个标准字节序，在socket地址结构中，port和ip都需要转换成网络字节序  
主机字节序 -> 网络字节序 -> 主机字节序

### internet socket地址结构
internet socket地址结构定义在<netinet/in.h>
#### IPV4地址结构
```c
struct in_addr {
    in_addr_t s_addr;
}
struct sockaddr_in {
    sa_family_t sin_family;  // 地址族，如AF_INET
    in_port_t sin_port;      // 端口（网络字节序，无符号整型，16位）
    struct in_addr sin_addr; // ip地址（网络字节序，无符号整型，32位）
}
```
- ipv4通配地址常量： INADDR_ANY
- ipv4回环地址常量： INADDR_LOOPBACK

#### IPV6地址结构
```c
struct in6_addr {
    unit8_t s6_addr[16];
}
struct sockaddr_in6 {
    sa_family_t sin6_family;    // 地址族，AF_INET6
    in_port_t sin6_port;        // 端口（网络字节序，无符号整型，16位）
    struct in_addr6 sin6_addr;  // ip地址（网络字节序，无符号整型，128位）
}
```
- ipv6通配地址常量： IN6ADDR_ANY_INIT
- ipv6回环地址常量： IN6ADDR_LOOPBACK_INIT  
大概可以这么使用：
```c
const struct in_addr6 in6addr_any = IN6ADDR_ANY_INIT;
struct sockadd_in6 addr;
memset(&addr, 0, sizeof(struct sockadd_in6));
addr.sin6_family = AF_INET6;
addr.sin6_port = htons(9501);
addr.sin_addr = in6addr_any;
```

#### 转换函数
计算机以二进制来表示IP地址和端口号，二进制和可读性形式之间的转换函数如下：

#### inet_pton
```c
// returns 1 on success, or -1 on error
#include <arpa/inet.h>
int inet_pton(int domain, const char *src_str, void *addrptr);
```
将src_str中的字符串转换成网络字节序的二进制IP地址，根据domain的值，将转换结果存放在指向in_addr或in6_addr的结构中

#### inet_ntop
```c
// returns pointer to dst_str on success, or null on error
#include <arpa/inet.h>
const char *inet_ntop(int domain, const void *addrptr, char *dst_str, size_t len);
```
- domain AF_INET或AF_INET6
- addrptr 一个指向in_addr或in6_addr的指针
- dst_str 存放转换结果
- len 指定dst_str长度，使用INET_ADDRSTRLEN或INET6_ADDRSTRLEN表示ipv4或ipv6可读形式的最大长度

#### getaddrinfo
给定主机名和服务名返回网络字节序的二进制IP地址和端口号结构（转换的结构放在in_addr或in6_addr指向的结构中），用于代替gethostbyname()和getservbyname()；
getaddrinfo调用是可能会发送一个DNS查询请求；返回结果不为0时表示错误，具体的错误码可以根据gai_strerror(int errcode)返回错误描述
```c
// returns 0 on success, or nonzero on error
#include <netdb.h>
int getaddrinfo(const char *host, const char *service, const struct addrinfo *hints, struct addrinfo **result);
```
- host 主机名或ip展示地址
- service 服务名或十进制的端口号
- hints 指向一个addrinfo结构，规定了通过result返回socket地址结构的标准
- result指向一个addrinfo结构的链表

#### addrinfo结构
```c
struct addrinfo {
    int ai_flags; 
    int ai_family; 
    int ai_socktype;
    int ai_protocol;
    size_t ai_addrlen;
    char *ai_cannoname;
    struct sockaddr *ai_addr;
    struct sockaddr *ai_next;
}
```
使用addrinfo结构前，调用memset设置addrinfo结构每个字段为0
- ai_flags 
    - AI_PASSIVE 当host设置为NULL时，将绑定到通配地址
    - AI_NUMERICSERV 防止服务名解析
- ai_addr 指向socket地址结构
- ai_next 指向下个addrinfo结构
- ai_family AF_INET，AF_INET6，AF_UNSPEC（表示ipv4和ipv6）

#### freeaddrinfo 释放getaddrinfo分配内存
getaddrinfo会动态为result引用的结构分配内存，所以需要释放内存，调用freeaddrinfo()
```c
#include <netdb.h>
void freeaddrinfo(struct addrinfo *result)
```

#### getnameinfo
给定地址结构返回主机名和服务名，用于代替gethostbyaddr()和getservbyport()
```c
// returns 0 on success, or nonzero on error
#include <netdb.h>
int getnameinfo(const struct sockaddr *addr, socklen_t addrlen, char *host, size_t hostlen, char *serv, size_t servlen, int flags)
```
- addr 待转换的地址结构
- host 转换后主机名保存在host，可以为NULL
- hostlen NI_MAXHOST表示返回主机名字符串最大字节，1025；需要定义_GNU_SOURCE特性宏
- serv 转换户服务名保存在serv，可以为NULL
- servlen NI_MAXSERV表示返回服务名字符串最大字节，32；需要定义_GNU_SOURCE特性宏
- flags 位掩码，控制这getnameinfo行为

```c
// header
#ifndef DOMORE_SOCKET
#define DOMORE_SOCKET

#include <sys/socket.h>
#include <sys/un.h>
#include <netdb.h>
#include <arpa/inet.h>

#define UNIX_SOCK_PATH "/tmp/mysock3"
#define PORT_NUM "9501"
#define BUF_SIZE 100
#define BACKLOG 10
#endif

#ifndef _GNU_SOURCE
#define _GNU_SOURCE 
#endif 

// server
PHP_METHOD(domore_socket, inet_server)
{
    int errcode, sfd, cfd, optval;
    zend_string *host, *port;
    socklen_t addrlen;
    struct addrinfo hints;
    struct addrinfo *result, *rp;
    struct sockaddr_storage claddr; // 通用地址结构

    char cl_host[NI_MAXHOST]; // NI_MAXHOST需要定义特性宏_GNU_SOURCE
    char cl_port[NI_MAXSERV];
    char recv_data[BUF_SIZE];

    if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "SS", &host, &port) == FAILURE)
    {
        DOMORE_ERROR_DOCREF("parse parameters failed");
    }

    // 忽略SIGPIPE,防止对一个关闭的socket对端写入数据会收到SIGPIPE信号，从而是write失败并返回EPIPE错误
    if (signal(SIGPIPE, SIG_IGN) == SIG_ERR)
    {
        DOMORE_ERROR_DOCREF("signal failed");
    }

    // getaddrinfo获取网络字节序的二进制ip地址和端口号结构体
    // hints.ai_flags = AI_PASSIVE | AI_NUMRICSERV; // 通配地址,数字端口
    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_flags = AI_NUMERICSERV;
    hints.ai_family = AF_UNSPEC; // 允许ipv4和ipv6
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_canonname = NULL;
    hints.ai_next = NULL; // 指向下一个addrinfo结构
    hints.ai_addr = NULL; // 指向socket地址结构
    errcode = getaddrinfo(ZSTR_VAL(host), ZSTR_VAL(port), &hints, &result);
    if (errcode != 0)
    {
        DOMORE_ERROR_DOCREF(gai_strerror(errcode));
    }

    for (rp = result; rp != NULL; rp = rp->ai_next)
    {
        sfd = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
        if (sfd == -1)
        {
            continue;
        }
        // 重复使用端口，停止的socket的端口再一段时间内不能重复使用
        if (setsockopt(sfd, SOL_SOCKET, SO_REUSEADDR, &optval, sizeof(optval)) == -1)
        {
            DOMORE_ERROR_DOCREF("setsockopt failed");
        }
        // 绑定成功，终止
        if (bind(sfd, rp->ai_addr, rp->ai_addrlen) == 0)
        {
            break;
        }
        close(sfd);
    }

    if (rp == NULL)
    {
        DOMORE_ERROR_DOCREF("can not bind socket to any address");
    }

    if (listen(sfd, BACKLOG) == -1)
    {
        DOMORE_ERROR_DOCREF("listen failed");
    }

    freeaddrinfo(result); // 释放addrinfo内存

    for (;;)
    {
        addrlen = sizeof(struct sockaddr_storage);
        cfd = accept(sfd, (struct sockaddr *)&claddr, &addrlen);
        if (cfd == -1)
        {
            continue;
        }
        // 打印客户单IP和端口号
        if(getnameinfo((struct sockaddr *)&claddr, addrlen, cl_host, NI_MAXHOST, cl_port, NI_MAXSERV, 0) == 0)
        {
            php_printf("client ip and port is : %s %s \n", cl_host, cl_port);
        }
        else
        {
            php_printf("get client name info failed \n");
        }

        memset(recv_data, 0, strlen(recv_data));
        if (read(cfd, recv_data, BUF_SIZE) == -1)
        {
            DOMORE_ERROR_DOCREF("read failed");
        }
        else
        {
            php_printf("client receive data is : %s \n", recv_data);
        }

        if (close(cfd) == -1)
        {
            DOMORE_ERROR_DOCREF("close failed");
        }
    }
}

// client
PHP_METHOD(domore_socket, inet_client)
{
    int cfd, errcode;
    zend_string *host, *port, *msg;
    struct addrinfo hints;
    struct addrinfo *result, *rp;

    if (zend_parse_parameters(ZEND_NUM_ARGS(), "SSS", &host, &port, &msg) == FAILURE)
    {
        DOMORE_ERROR_DOCREF("parse parameters failed");
    }

    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_addr = NULL;
    hints.ai_next = NULL;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_family = AF_UNSPEC;
    errcode = getaddrinfo(ZSTR_VAL(host), ZSTR_VAL(port), &hints, &result);
    if (errcode != 0)
    {
        DOMORE_ERROR_DOCREF(gai_strerror(errcode));
    }

    for (rp = result; rp != NULL; rp = rp->ai_next)
    {
        cfd = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
        if (cfd == -1)
        {
            continue;
        }
        if (connect(cfd, (struct sockaddr *)rp->ai_addr, rp->ai_addrlen) == 0)
        {
            break;
        }
        if (close(cfd) == -1)
        {
            DOMORE_ERROR_DOCREF("close failed");
        }
    }
    if (rp == NULL)
    {
        DOMORE_ERROR_DOCREF("can not connect any socket");
    }

    freeaddrinfo(result); 

    if (write(cfd, ZSTR_VAL(msg), ZSTR_LEN(msg)) != ZSTR_LEN(msg))
    {
        DOMORE_ERROR_DOCREF("write failed");
    }
}
```