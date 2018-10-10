- 共享数据方便
- 线程不安全，多线程之间相互影响共享变量，需要互斥锁
- 一个进程中多个线程可以同时运行
- POSIX线程库，pthread
- 线程函数返回的类型为void *

### pthread_create
创建线程并运行
```c

```

### pthread_join
等待线程结束
```c

```

### 线程互斥锁
互斥锁必须对所有线程可见，即互斥锁是一个全局变量，互斥锁用在需要修改共享变量位置
```c
pthread_mutex_t a_lock = PTHTEAD_MUTEX_INITIALIZE;
pthread_mutex_lock(&a_lock);   // 加锁
pthread_mutex_unlock(&a_lock); // 解锁
```

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