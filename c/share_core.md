我们定义一个错误处理函数,这个错误处理函数可以让其他程序使用,如下:
```c
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#define BUF_SIZE 50

void err_exit(const char *format, ...)
{
    char errorMsg[BUF_SIZE];
    va_list argList;
    
    va_start(argList, format);
    vsprintf(errorMsg, format, argList);    // 将可变参数以fotmat格式保存到errorMsg字符串
    printf("Error:%s\n", errorMsg);         // 将错误信息输出到标准输出
    va_end(argList);
    exit(0);
}
```

假设a.c和b.c两个程序都需要使用这个函数,最简单做法是每个程序复制一份函数的代码,但是有更多的程序需要用到这个函数时,应该考虑如何把函数抽出来公用,这样也方便维护代码;  
首先将函数提取到一个单独文件error_functions.c
```c
void err_exit(const char *format, ...)
{
    char errorMsg[BUF_SIZE];
    va_list argList;
    
    va_start(argList, format);
    vsprintf(errorMsg, format, argList);    // 将可变参数以fotmat格式保存到errorMsg字符串
    printf("Error:%s\n", errorMsg);         // 将错误信息输出到标准输出
    va_end(argList);
    exit(0);
}
```

再创建一个头文件error_functions.h,并声明函数
```c
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#define BUF_SIZE 50
void err_exit(const char *format, ...);
```

每个程序引入该头文件,以下为a.c文件
```c
#include "error_functions.h"
int main(int argc, char const *argv[])
{
    err_exit("%s, msg:%s", "save failed", "param error");
    return 0;
}
```

最后是编译,将a.c和error_functions.c编译并且链接到同一个文件
```c
gcc a.c error_functions.c -o a
```

当a.c调用err_exit函数时会自动链接到error_functions.c文件中的函数