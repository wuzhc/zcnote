Linux提供inotify机制来监控文件事件，简单流程如下：
- inotify_init创建inotify实例，成功会返回一个文件描述符
- inotify_add_watch添加要监控文件或目录，添加成功返回监控描述符
- read读取inotify实例文件描述符，获得文件事件
需要注意的是inotify监控机制非递归的，即子目录也需要通过inotify_add_watch添加监控列表

### inotify_init 创建inotify_init实例
```c
// return file descriptor on success, or -1 on error
int inotify_ini(void)
```

### inotify_add_watch 添加监控项
```c
// return watch descriptor on success, or -1 on error
int inotify_add_watch(int fd, const char *pathname, unit32_t mask)
```
- fd指inotify_init返回的文件描述符
- filename指被监控的文件或目录
- mask掩码，用于指定监控事件

### inotify_rm_watch 删除监控项
```c
// return 0 on success, or -1 on error
int inotify_rm_watch(int fd, unit32_t wd)
```
- wd为监控项描述符
删除监控项会生成IN_IGNORED事件

### 读取inotify事件
read通过inotify文件描述符读取事件，当事件发生时，返回一个或多个inotify_event结构
```c
struct inotify_event {
    int wd,             // 监控项描述符
    unit32_t mask,      // 描述该事件的位掩码
    unit32_t cookie,    // 用于联系两个事件，例如重命名子目录或子文件则会发送IN_MOVE_FROM和IN_MOVE_TO两个事件，两者inotify.cookie是一样的
    unit32_t len,
    char name[]
}
```

### 掩码
- IN_ACCESS 文件被访问
- IN_ATTRIB 文件元数据被修改（例如文件权限）
- IN_CREATE 在监控目录中创建子目录或文件
- IN_MODIFY 文件被修改
- IN_OPEN 文件被打开
- IN_CLOSE_WRITE 关闭可写文件
- IN_CLOSE_NOWRITE 关闭以只读方式打开的文件

- IN_DELETE 删除监控目录下的子目录或文件
- IN_DELETE_SELF 删除监控目录

- IN_MOVE_FROM 从监控目录移除子目录或文件
- IN_MOVE_TO 文件移动到监控目录
- IN_MOVE_SELF 移动监控目录或监控文件（或重命名监控目录，文件,如果是重命名子目录或子文件则会发送IN_MOVE_FROM和IN_MOVE_TO两个事件，两者inotify.cookie是一样的）

下面只能添加监控项使用
- IN_MASK_ADD 将事件追加到pathname当前掩码,当指定这个并且对同个pathname执行两次添加监控项，掩码不会覆盖而是合并
- IN_ONLYDIR pathname只能是目录，否则inotify_add_watch调用失败，报错ENOTDIR
- IN_ONESHOT 只监控pathname一个事件，事件发生后，自动从监控列表消失
- IN_ALL_EVENTS 所有输出事件的总称

下面只能读取事件时使用
- IN_IGNORED 移除监控项
- IN_ISDIR name返回的文件名为路径
- IN_Q_OVERFLOW 事件队列移除

### demo
```c
#include <sys/inotify.h>
#include <limits.h>
#include "tlpi_hdr.h"
#define BUF_LEN 10 * (sizeof(struct inotify_event) + NAME_MAX + 1)

void displayInotifyEvent(struct inotify_event *i)
{
    printf("    wd =%2d; ", i->wd);
    if (i->cookie > 0)
        printf("cookie =%4d; ", i->cookie);

    printf("mask = ");
    if (i->mask & IN_ACCESS)        printf("IN_ACCESS ");
    if (i->mask & IN_ATTRIB)        printf("IN_ATTRIB ");
    if (i->mask & IN_CLOSE_NOWRITE) printf("IN_CLOSE_NOWRITE ");
    if (i->mask & IN_CLOSE_WRITE)   printf("IN_CLOSE_WRITE ");
    if (i->mask & IN_CREATE)        printf("IN_CREATE ");
    if (i->mask & IN_DELETE)        printf("IN_DELETE ");
    if (i->mask & IN_DELETE_SELF)   printf("IN_DELETE_SELF ");
    if (i->mask & IN_IGNORED)       printf("IN_IGNORED ");
    if (i->mask & IN_ISDIR)         printf("IN_ISDIR ");
    if (i->mask & IN_MODIFY)        printf("IN_MODIFY ");
    if (i->mask & IN_MOVE_SELF)     printf("IN_MOVE_SELF ");
    if (i->mask & IN_MOVED_FROM)    printf("IN_MOVED_FROM ");
    if (i->mask & IN_MOVED_TO)      printf("IN_MOVED_TO ");
    if (i->mask & IN_OPEN)          printf("IN_OPEN ");
    if (i->mask & IN_Q_OVERFLOW)    printf("IN_Q_OVERFLOW ");
    if (i->mask & IN_UNMOUNT)       printf("IN_UNMOUNT ");
    printf("\n");

    if (i->len > 0)
        printf("        name = %s\n", i->name);
}

int main(int argc, char const *argv[])
{
    int i, fd, wd;
    char *p;
    ssize_t numRead;
    char buf[BUF_LEN];
    struct inotify_event *event;

    if (argc < 2 || strcmp(argv[1], "--help") == 0)
    {
        usageErr("%s pathname", argv[0]);
    }

    fd = inotify_init();
    if (fd == -1)
    {
        errExit("inotify_init failed \n");
    }

    for (i = 0; i < argc - 1; ++i)
    {
        wd = inotify_add_watch(fd, argv[i + 1], IN_ALL_EVENTS);
        if ( wd == -1)
        {
            errExit("inotify_add_watch failed \n");
        }
        else
        {
            printf("watching %s using wd %d \n", argv[i + 1], wd);
        }
    }

    for (;;)
    {
        numRead = read(fd, buf, BUF_LEN);
        if (numRead == 0)
        {
            fatal("read from inotify fd returned 0 \n");
        }
        if (numRead == -1)
        {
            errExit("read failed\n");
        }

        printf("read %ld bytes from inotify fd\n", (long)numRead);
        for (p = buf; p < buf + numRead;)
        {
            event = (struct inotify_event *)p;
            displayInotifyEvent(event);
            p += sizeof(struct inotify_event) + event->len;
        }
    }

    return 0;
}
```
### 相关链接
- [我用inotify实现的一个php扩展](https://github.com/wuzhc/php-inotify)

### 参考
- Linux系统编程手册(上册)