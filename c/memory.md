### malloc分配内存
- malloc用来分配空间，然后返回一个指针，指向堆上新分配的空间
- 使用malloc时需要引入头文件stdlib.h
- malloc需要知道数据类型所占的字节，通常配合sizeof使用，例如： swServer *p = malloc(sizeof(struct swServer));
```c
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>

typedef struct island {
    char *name;
    struct island *next;
} island;


void display(island *island)
{
    for (; island != NULL; island = island->next) {
        printf("name: %s\n", island->name);
    }
}

island* create(char *name)
{
    island *i = malloc(sizeof(island));
    i->name = strdup(name); /* 记得要释放strdup在堆上创建的空间 */
    i->next = NULL;
    return i;
}

void release(island *start)
{
    island *i = start;
    island *next = NULL;

    while (i != NULL) {
        next = i->next;
        free(i->name); /* 释放strdup创建的name字段 */
        free(i);
        i = next;
    }
}

int main()
{
    island *start = NULL;
    island *i = NULL;
    island *next = NULL;
    char name[80];

    for (; fgets(name, 80, stdin) != NULL; i = next) {
        next = create(name);
        if (start == NULL) {
            start = next;
        }
        if (i != NULL) {
            i->next = next;
        }
    }

    display(start);
    release(start);
}

```

