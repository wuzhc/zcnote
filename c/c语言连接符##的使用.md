## 概念
    连接符的概念是结合define预编译指令的使用技巧，用户可以向define中传入字符串来调用不同功能的函数。

## 例子
```c
#include <stdio.h>

int algorithm_add_op(int num1, int num2) {
    return num1+num2;
}

int algorithm_sub_op(int num1, int num2) {
    return num1 - num2;
}
#define ALGORITHM(name, num1, num2) \
        algorithm_##name##_op(num1, num2)
    
int main() {
    printf("%d\n", ALGORITHM(add, 1, 2));
    printf("%d\n", ALGORITHM(sub, 1, 2));
    return 0;
}
```