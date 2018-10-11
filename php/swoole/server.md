### 全局变量
#### SwooleG
```c
// swoole.h
swServerG SwooleG; // server全局变量
typedef struct {
    ...                                     // 其他一些配置选项
    swServer *serv;                         // 指向server结构指针，该结构保存了server的配置信息和回调函数，该结构定义在include/Server.h
    swFactory *factory;

    swMemoryPool *memory_pool;              // 内存管理
    swReactor *main_reactor;                // reactor线程
    
    swLock lock;                            // 线程锁,mutex
    swHashMap *functions;                   // swoole哈希表
    swLinkedList *hooks[SW_MAX_HOOK_TYPE];  // swoole链表
} swServerG;
```

#### SwooleWG;
```c
// swoole.h
swWorkerG SwooleWG;
typedef struct
{
    /**
     * Always run
     */
    uint8_t run_always;

    /**
     * Current Proccess Worker's id
     */
    uint32_t id;

    /**
     * pipe_worker
     */
    int pipe_used;
    int max_request;

    swWorker *worker; // 指向worker结构
} swWorkerG;
```

### socket类型
```c
// swoole.h
enum swSocket_type
{
    SW_SOCK_TCP          =  1, // ipv4,数据流
    SW_SOCK_UDP          =  2, // ipv4,数据报
    SW_SOCK_TCP6         =  3, // ipv6,数据流
    SW_SOCK_UDP6         =  4, // ipv6,数据报
    SW_SOCK_UNIX_DGRAM   =  5, // unix sock dgram
    SW_SOCK_UNIX_STREAM  =  6, // unix sock stream
};

```

### server运行模式
```c
// swoole.h
enum swServer_mode
{
    SW_MODE_BASE          =  1, // 基本模式
    SW_MODE_THREAD        =  2, // 多线程模式
    SW_MODE_PROCESS       =  3, // 多进程模式
    SW_MODE_SINGLE        =  4, // 单例模式
};

serv->factory_mode = serv_mode;
```