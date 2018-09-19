signal.h库文件包括对信号的定义;信号可以分为标准信号和实时信号,标准信号的编号为1~31(信号最大编号为常量NSIG),用于内核向进程通知事件,两者的区别是同一信号在阻塞状态下产生多次,实时信号会进行排队,而标准信号不会,当阻塞解除时,标准信号只会传递一次

#### 信号集
信号集结构类型为sigset_t,包含一组信号

#### 信号掩码
为什么要阻塞信号?程序为了防止被信号中断,会把信号添加到信号掩码中;当一个信号被触发时,程序不会响应处在掩码集合中的信号,它会把信号存放在等待信号集合中(sigpending),直到从信号掩码中移除,从信号掩码中添加和删除信号用sigprocmask函数

#### 暂停进程进行,等待进程的到达

#### 信号处理器
信号处理器用于响应信号的处理事件,当进程收到信号时,会中断程序的执行,等待信号处理器完成之后,继续从中断处执行
```c
#include <signal.h>

static void signHandle(int sig)
{
    printf("%s\n", "Ouch");
}

int main(int argc, char const *argv[])
{
    int i;

    // 安装信号
    if (signal(SIGINT, signHandle) == SIG_ERR)
    {
        printf("%s\n","signal");
    }

    for (i = 0; ; ++i)
    {
        printf("%d\n", i);
        sleep(3);
    }

    return 0;
}
```
当终端Ctrl+c中止程序时,主程序会收到SIGINT信号,并触发信号处理器,当信号处理器打印signal之后,程序继续往下执行

#### 信号系统函数
##### kill发送信号
kill可以向进程发送信号,也可以用于检查进程是否存在(sig设为0)
```c
// return 0 on success, or -1 on error
kill(pid_t pid, int sig)
```
- pid>0,发送到pid进程
- pid=0,发送到与调用进程同组的所有进程
- pid=-1,发送给所有进程,除了init进程和调用进程
- pid<-1,发送进程组等于pid绝对值的下属进程

##### strsignal信号描述
```c
// return pointer to signal description string
strsignal(int sig)
```

##### sigaction 信号处理器
```c
// return pointer to signal description string
sigaction(int sig, struct sigaction *act, struct sigaction *oldact)
```

##### sigprocmask 向信号掩码添加或删除信号
```c
// return pointer to signal description string
sigprocmask(int how, sigset_t *set, sigset_t *oldset)
```
- how决定了sigprocmask的行为
    - SIG_BLOCK,set信号集的信号会添加到掩码中,oldset会保存上一次掩码
    - SIG_UNLOCK,set信号集的信号会从掩码中移除
    - SIG_SETMASK,将set信号集赋值给信号掩码
- set信号集,如果只是想获得信号掩码,可以设置为NULL
- oldset会保存上一次信号掩码集合,如果不关心这个可以设置为NULL

##### sigpending 等待信号集合
```c
// return 0 on success, or -1 on error
sigpending(sigset_t *set)
```

##### sigemptyset 初始化一个未包含任何成员的信号集
```c
// return 0 on success, or -1 on error
sigemptyset(sigset_t *set)
```

##### sigfillset 初始化一个包含所有成员的信号集
```c
// return 0 on success, or -1 on error
sigfillset(sigset_t *set)
```

##### sigaddset 向信号集添加信号
```c
// return 0 on success, or -1 on error
sigaddset(sigset_t *set, int sig)
```

##### sigdelset 向信号集删除信号
```c
// return 0 on success, or -1 on error
sigdelset(sigset_t *set, int sig)
```

##### sigismember 检查信号是否属于信号集
```c
// return 1 on true, or 0 on false  
sigismember(sigset_t *set, int sig)
```

一个例子:
```c
#include <stdio.h>
#include <signal.h>
#include <string.h>

// 打印信号集所有信号
static void printfSigset(sigset_t *sigset)
{
    for (int sig = 1; sig < NSIG; ++sig) // NSIG为信号最大编号
    {
        if (sigismember(sigset, sig)) // 检查是否属于信号集的信号
        {
            printf("%d %s\n", sig, strsignal(sig));
        }
    }
}

int main(int argc, char const *argv[])
{
    sigset_t *sigset;

    sigfillset(sigset); // 初始化一个包含所有信号的信号集
    printfSig(sigset);
    return 0;
}
```

#### 几个会使进程退出的信号
- SIGKILL 强制杀掉进程,如kill -9 pid,程序处理器无法忽略，捕获，阻塞
- SIGINT  中断信号，Ctrl + c
- SIGTERM 以正常的方式结束程序来终止（预先清除临时文件，释放资源）
- SIGHUP  启动被终止的信号，类似于重启 
- SIGQUIT Ctrl + \ ， 退出信号，并生成可用于调试的核心转储文件，由gdb调试器调用
- SIGSTOP 暂停，程序处理器无法忽略，捕获，阻塞
