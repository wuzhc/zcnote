### swoole_process::signal文档
swoole_process::signal用于设置异步信号监听。
```bash
bool swoole_process::signal(int $signo, callable $callback);
```
- 此方法基于signalfd和eventloop是异步IO，不能用于同步程序中
- 同步阻塞的程序可以使用pcntl扩展提供的pcntl_signal
- $callback如果为null，表示移除信号监听
- 如果已设置了此信号的回调函数，重新设置时会覆盖历史设置

使用举例：
```php
swoole_process::signal(SIGTERM, function($signo) {
     echo "shutdown.";
});
```

### 源码
```c
// swoole_process.c
static PHP_METHOD(swoole_process, signal)
{
    zval *callback = NULL; // 回调函数会保存到zval结构中
    long signo = 0; // 信号

    // 解析signo和callback参数
    if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "lz", &signo, &callback) == FAILURE)
    {
        return;
    }

    // 全局变量cli，标识当前运行模式是否为cli模式，swoole_process::signal只能用于cli模式
    if (!SWOOLE_G(cli))
    {
        swoole_php_fatal_error(E_ERROR, "cannot use swoole_process::signal here.");
        RETURN_FALSE;
    }

    // SwooleG定义在Server.c，以下是关于各类进程不能注册的信号
    if (SwooleG.serv && SwooleG.serv->gs->start)
    {
        // worker和taskWorker不能安装SIGTERM信号处理器
        if ((swIsWorker() || swIsTaskWorker()) && signo == SIGTERM)
        {
            swoole_php_fatal_error(E_WARNING, "unable to register SIGTERM in worker/task process.");
            RETURN_FALSE;
        }
        else if (swIsManager() && (signo == SIGTERM || signo == SIGUSR1 || signo == SIGUSR2 || signo == SIGALRM))
        {
            swoole_php_fatal_error(E_WARNING, "unable to register SIGTERM/SIGUSR1/SIGUSR2/SIGALRM in manager process.");
            RETURN_FALSE;
        }
        else if (swIsMaster() && (signo == SIGTERM || signo == SIGUSR1 || signo == SIGUSR2 || signo == SIGALRM || signo == SIGCHLD))
        {
            swoole_php_fatal_error(E_WARNING, "unable to register SIGTERM/SIGUSR1/SIGUSR2/SIGALRM/SIGCHLD in manager process.");
            RETURN_FALSE;
        }
    }

    // 貌似用于检测或初始化reactor线程
    php_swoole_check_reactor();
    swSignalHander handler;

    // $callback如果为null，表示移除信号监听
    if (callback == NULL || ZVAL_IS_NULL(callback))
    {
        callback = signal_callback[signo];
        if (callback)
        {
            swSignal_add(signo, NULL);
            SwooleG.main_reactor->defer(SwooleG.main_reactor, free_signal_callback, callback);
            signal_callback[signo] = NULL;
            RETURN_TRUE;
        }
        else
        {
            swoole_php_error(E_WARNING, "no callback.");
            RETURN_FALSE;
        }
    }
    // 如果callback为整数型，则忽略信号
    else if (Z_TYPE_P(callback) == IS_LONG && Z_LVAL_P(callback) == (long) SIG_IGN)
    {
        handler = NULL;
    }
    else
    {
        char *func_name;
        if (!sw_zend_is_callable(callback, 0, &func_name TSRMLS_CC))
        {
            swoole_php_error(E_WARNING, "function '%s' is not callable", func_name);
            efree(func_name);
            RETURN_FALSE;
        }
        efree(func_name);

        callback = sw_zval_dup(callback);
        sw_zval_add_ref(&callback);

        handler = php_swoole_onSignal;
    }

    /**
     * for swSignalfd_setup
     */
    SwooleG.main_reactor->check_signalfd = 1;

    //free the old callback
    if (signal_callback[signo])
    {
        SwooleG.main_reactor->defer(SwooleG.main_reactor, free_signal_callback, signal_callback[signo]);
    }
    signal_callback[signo] = callback;

#if PHP_MAJOR_VERSION >= 7 || (PHP_MAJOR_VERSION >= 5 && PHP_MINOR_VERSION >= 4)
    /**
     * use user settings
     */
    SwooleG.use_signalfd = SwooleG.enable_signalfd;
#else
    SwooleG.use_signalfd = 0;
#endif

    swSignal_add(signo, handler);

    RETURN_TRUE;
}
```

### 信号处理
```c
// signal.c
static void swSignalfd_set(int signo, swSignalHander callback)
{
    // callback为null，移除信号
    if (callback == NULL && signals[signo].active)
    {
        sigdelset(&signalfd_mask, signo);
        bzero(&signals[signo], sizeof(swSignal));
    }
    else
    {
        sigaddset(&signalfd_mask, signo);
        signals[signo].callback = callback;
        signals[signo].signo = signo;
        signals[signo].active = 1;
    }
    if (signal_fd > 0)
    {
        sigprocmask(SIG_BLOCK, &signalfd_mask, NULL); // signanlfd_mask加入到信号掩码中
        signalfd(signal_fd, &signalfd_mask, SFD_NONBLOCK | SFD_CLOEXEC); // 非阻塞和异步
    }
}
```

### 信号结构体
```c
// signal.c
typedef struct
{
    swSignalHander callback;
    uint16_t signo;
    uint16_t active;
} swSignal;
```

### swServerG结构体
```c
// swoole.h
typedef struct
{
    swTimer timer;

    uint8_t running :1;
    uint8_t enable_coroutine :1;
    uint8_t use_timerfd :1;
    uint8_t use_signalfd :1;
    uint8_t enable_signalfd :1;
    uint8_t reuse_port :1;
    uint8_t socket_dontwait :1;
    uint8_t dns_lookup_random :1;
    uint8_t use_async_resolver :1;

    /**
     * Timer used pipe
     */
    uint8_t use_timer_pipe :1;

    int error;
    int process_type;
    pid_t pid;

    int signal_alarm;  //for timer with message queue
    int signal_fd;
    int log_fd;
    int null_fd;
    int debug_fd;

    /**
     * worker(worker and task_worker) process chroot / user / group
     */
    char *chroot;
    char *user;
    char *group;

    uint8_t log_level;
    char *log_file;
    int trace_flags;

    uint16_t cpu_num;

    uint32_t pagesize;
    uint32_t max_sockets;
    struct utsname uname;

    /**
     * tcp socket default buffer size
     */
    uint32_t socket_buffer_size;

    swServer *serv;
    swFactory *factory;

    swMemoryPool *memory_pool;
    swReactor *main_reactor;

    char *task_tmpdir;
    uint16_t task_tmpdir_len;

    char *dns_server_v4;
    char *dns_server_v6;
    double dns_cache_refresh_time;

    swLock lock;
    swHashMap *functions;
    swLinkedList *hooks[SW_MAX_HOOK_TYPE];

} swServerG;
```