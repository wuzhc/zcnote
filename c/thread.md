### 关于线程的一些描述
- 共享数据方便
- 一个进程中多个线程可以同时运行
- POSIX线程库，pthread，编译的时候需要加上-lphread
- 所有线程共享相同的全局和堆变量，但每个线程都有自己存放局部变量的私有栈
- 线程不安全，多线程之间相互影响共享变量，需要互斥锁
- 一个线程出问题，会危及到其他线程，即不稳定
- 线程避免使用信号

### pthread_create
创建线程并运行
```c
// returns 0 on success, or a positice error number on error
#include <pthread.h>
pthread_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start)(void *), void *arg)
```
- 线程函数返回的类型为void *

### pthread_exit
终止进程
```c
#include <pthread.h>
pthread_exit(void *retval)
```
- 任意线程调用exit()或主线程执行了return语句都会导致进程中所有线程立即终止
- 其返回值可以由另一线程通过pthread_join()来获取
- 参数retval指定了线程的返回值，指向的内容不应分配于线程栈中

### pthread_self
获取当前线程ID
```c
include <pthread.h>
pthread_t pthread_self(void);
```

### pthread_join
等待线程结束
```c
// returns 0 on success, or a positive error number on error
#include <pthread.h>
pthread_join(pthread_t thread, void **retval);
```
- retval 保存线程终止时返回值的拷贝，即线程调用return或pthread_exit时所指定的值
- 没有调用pthread_join将产生僵尸线程，除非是分离状态的线程（pthread_detach）

### pthread_detach
将线程标识为分离状态，这样线程终止能够自动清理和移除，不需要调用pthread_join来获取其返回状态
```c
// returns 0 on success, or a positive error number on error
#include <pthread.h>
pthread_detach(pthread_t thread);
```

### 互斥量mutex（mutual exclusion）
- 互斥锁必须对所有线程可见，即互斥锁是一个全局变量，互斥锁用在需要修改共享变量位置
- 类型为pthread_mutex_t
- 静态分配的互斥量，PTHREAD_MUTEX_INITIALIZER
- 动态分配的互斥量，pthread_mutext_init
```c
pthread_mutex_t a_lock = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_lock(&a_lock);   // 加锁
pthread_mutex_unlock(&a_lock); // 解锁
```

### 动态初始化互斥量
```c
// returns 0 on success, or a positive error number on error
#include <pthread.h>
pthread_mutex_init(pthread_mutex_t *mutext, const pthread_mutexattr_t *attr)
```
动态分配的互斥量需要通过pthread_mutex_destroy
```c
// returns 0 on success, or a positive error number on error
#include <pthread.h>
pthread_mutex_destory(pthread_mutex_t *mutex)
```

### 互斥量类型
```c
pthread_mutexattr_settype(pthread_mutexattr *attr, type)
```
type类型如下：
- PTHREAD_MUTEX_NORMAL 互斥量不具有死锁检测功能
- PTHREAD_MUTEX_ERRORCHECK 对此类互斥量的所有操作都会执行错误检查，运行慢
- PTHREAD_MUTEX_RECURSIVE 递归互斥量维护一个锁计数器


### 互斥量的死锁
一般出现在线程有多个互斥量
- 确定互斥量的层级关系

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <pthread.h>
#define NUM_SIZE 20

int num = 2000000;
pthread_mutex_t a_lock = PTHREAD_MUTEX_INITIALIZER;


void *modify_num()
{
    pthread_mutex_lock(&a_lock);
    for (int i = 0; i < 100000; ++i)
    {
        num = num - 1;
    }
    pthread_mutex_unlock(&a_lock);
    printf("nun=%d\n", num);
    return NULL;
}

int main(int argc, char const *argv[])
{
    pthread_t threads[NUM_SIZE];
    for (int i = 0; i < NUM_SIZE; ++i)
    {
        if (pthread_create(&threads[i], NULL, modify_num, NULL) == -1)
        {
            printf("%s\n", "pthread create failed");
            exit(1);
        }
    }

    void *result;
    for (int i = 0; i < NUM_SIZE; ++i)
    {
        if (pthread_join(threads[i], &result) == -1)
        {
            printf("%s\n", "pthread join failed");
        }
    }

    printf("剩余%d\n", num);

    return 0;
}
```

### 参考
- 嗨翻C语言