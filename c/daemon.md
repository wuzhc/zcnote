守护进程即后台运行的服务进程，它独立于控制终端，原因是为了避免被任何终端产生的信息打断，在执行过程中信息也不会在终端显示，关于控制终端可以参考其他资料

### 查看守护进程
```bash
ps axj
```

### 实现过程
- fork创建子进程，父进程退出
- 子进程继续调用setsid创建新会话，此时子进程会成为新会话的首进程，并脱离从父进程继承过来的会话，控制终端
- 再次fork，退出父进程，目的是确保daemon进程不是会话首进程，因为当会话首进程open一个终端设备时会建立控制终端，守护进程不需要控制终端
- unmask(0)，确保daemon有足够创建文件和目录的权限
- 修改当前工作目录
- 关闭文件描述符
- 重定向标准输出，标准输入，错误输出到/dev/null

### demo
```c
int daemon()
{
    pid_t pid;
    int fd, maxfd;

    // fork
    switch(fork())
    {
    case -1:
        return -1
           case 0:
        break;
    default:
        _exit(0);
    }

    // setsid, create new session
    if (setsid() == -1)
    {
        return -1;
    }

    // fork
    switch(fork())
    {
    case -1:
        return -1;
    case 0:
        break;
    default:
        _exit(0);
    }

    // umask
    umask(0);

    // chdir
    chdir("/");

    // close all file descriptor
    maxfd = sysconf(_SC_OPEN_MAX);
    if (maxfd)
    {
        for (int i = 0; i < maxfd; ++i)
        {
            close(i);
        }
    }

    // dup to /dev/null
    fd = open("/dev/null", O_RDWR);
    if (fd < 0)
    {
        return -1;
    }
    if (dup2(fd, STDIN_FILENO) < 0 || dup2(fd, STDOUT_FILENO) < 0 || dup2(fd, STDERR_FILENO) < 0)
    {
        close(fd);
        return -1;
    }
    close(fd);

    return 0;
}
```
