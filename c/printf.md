C语言printf家族函数的成员：
```c
#include <stdio.h>
int printf(const char *format, ...);                            // 输出到标准输出
int fprintf(FILE *stream, const char *format, ...);             // 输出到文件
int sprintf(char *str, const char *format, ...);                // 输出到字符串str中
int snprintf(char *str, size_t size, const char *format, ...);  // 按size大小输出到字符串str中
```

以下函数功能与上面的一一对应相同，只是在函数调用时，把上面的...对应的一个个变量用va_list调用所替代。在函数调用前ap要通过va_start()宏来动态获取。
```c
#include <stdarg.h>
int vprintf(const char *format, va_list ap);
int vfprintf(FILE *stream, const char *format, va_list ap);
int vsprintf(char *str, const char *format, va_list ap);
int vsnprintf(char *str, size_t size, const char *format, va_list ap);
```
```c
static void outputError(Boolean useErr, int err, Boolean flushStdout, const char *format, va_list ap)
{
#define BUF_SIZE 500
    char buf[BUF_SIZE], userMsg[BUF_SIZE], errText[BUF_SIZE];

    vsnprintf(userMsg, BUF_SIZE, format, ap); // 输出可变参数到userMsg

    if (useErr)
        snprintf(errText, BUF_SIZE, " [%s %s]",
                 (err > 0 && err <= MAX_ENAME) ?
                 ename[err] : "?UNKNOWN?", strerror(err));
    else
        snprintf(errText, BUF_SIZE, ":");  // 输出BUF_SIZE长度到errText

    snprintf(buf, BUF_SIZE, "ERROR%s %s\n", errText, userMsg);

    if (flushStdout)
        fflush(stdout);       /* Flush any pending stdout */
    fputs(buf, stderr);
    fflush(stderr);           /* In case stderr is not line-buffered */
}
```

#### 可变参数
va_end , va_arg, va_list叫宏，不是函数，宏用来编译前重写代码，实际上他们是指令
- va_list 用于保存函数的其他参数
- va_start 可变参数从那个开始
- va_arg 获取一个可变参数
- va_end 销毁va_list
```c
#include <stdio.h>
#include <stdarg.h>

static void show_va_list(char *msg, ...)
{
    int number;
    va_list argList;

    va_start(argList, msg);
    number = va_arg(argList, int);
    va_end(argList);
    printf("第一个数字%i\n", number);
}

int main(int argc, char const *argv[])
{
    show_va_list("test", 1, 2);
    return 0;
}
```
