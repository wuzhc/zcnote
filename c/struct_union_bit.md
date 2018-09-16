#### 结构体
```c
struct student
{
  const char *name;
  const char *address;
  int age;
};
```
struct student表示一个类型,类似于int,声明和初始化,以及使用如下:
```c
#include <stdio.h>
#include <string.h>

struct student
{
  const char *name;
  const char *address;
  int age;
};

int main(int argc, char const *argv[])
{

  struct student person = {"wuzhc", "Guangzhou", 18};
  printf("%s\n", person.name);  
  return 0;
}
```

#### typeof别名
可以为结构体设置别名,如下
```c
typedef struct student
{
  const char *name;
  const char *address;
  int age;
} stu;
```
其中结构体名可以省略,如下:
```c
typedef struct 
{
  const char *name;
  const char *address;
  int age;
} stu;
```

#### 结构体复制
当一个结构体变量赋值给另一个结构体变量时,计算机会创建一个全新的副本,如果结构体含有指针,那么复制的仅仅是指针的值,如下:

#### 嵌套结构
```c
#include <stdio.h>
#include <string.h>

typedef struct 
{
  const char *subject;
  int score;
} report;

typedef struct 
{
  const char *name;
  const char *address;
  int age;
  report card; // 这是一个嵌套结构体
} stu;

int main(int argc, char const *argv[])
{
  stu person = {"wuzhc", "Guangzhou", 18, {"english", 59}};
  printf("%s\n", person.card.subject);
  return 0;
}
```

#### 结构体指针
类似于其他类型指针,代码如下:
```c
void modifyAge(stu *s) 
{
  s->age = 23;
  // 等价于(*s).age = 23
}
```

#### 联合union
联合即用一个字段表示各种意义的字段,如总数,重量通常为量;当定义联合时,计算机会为最大的字段分配空间,如下:
```c
typeof union {
    short count;
    float weight;
    float volume
} quantity;
```
初始化:
```c
quantity q = {.weight=1.5}
```

#### 枚举
关键字enum,定义如下:
```c
typeof enum {
    COUNT, POUNDS, PINTS
} unit;
```

#### 位字段
用位字段主要用于减少占用空间,如定义一个结构如下:
```c
typedef struct 
{
  unsigned int fist_visit:1;
  unsigned int come_age:1;
  unsigned int fingers_lost:4;
  unsigned int days_a_week:3;
} survey;
```
位字段应当声明为unsigned int;只有出现在同一个结构中,位字段才能节省空间

#### 位字段和数值计算
最大值 = 2^位数 - 1,即4位只能保存0到15的值

```c
#include <stdio.h>
#include <string.h>

// 枚举
typedef enum 
{
  PREPATE_TYPE, HOMEWORK_TYPE, SCANEXAM_TYPE
} sourceType;

// 联合
typedef union
{
  short count;
  short weight;
} quantity;

// 结构体
typedef struct 
{
  const char *subject;
  int score;
} report;

// 结构体
typedef struct 
{
  const char *name;
  const char *address;
  int age;
  report card; // 这是一个嵌套结构体
  sourceType type;
  quantity q;
} stu;

// 位字段
typedef struct 
{
  unsigned int fist_visit:1;
  unsigned int come_age:1;
  unsigned int fingers_lost:4;
  unsigned int days_a_week:3;
} survey;

// 结构体指针
void modifyAge(stu *s) 
{
  s->age = 23;
  // 等价于(*s).age = 23
}

int main(int argc, char const *argv[])
{
  stu person = {"wuzhc", "Guangzhou", 18, {"english", 59}, HOMEWORK_TYPE, {.weight=118}};

  if (person.type == HOMEWORK_TYPE) {
    printf("%s\n", "homework");
  } else {
    printf("%s\n", "other");
  }

  modifyAge(&person);
  printf("%i\n", person.age);

  printf("%i\n", person.q);
  return 0;
}
```