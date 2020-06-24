```c
//C 库函数 char *strstr(const char *haystack, const char *needle) 在字符串 haystack 中查找第一次出现字符串 needle 的位置，不包含终止符 '\0'。
char *strstr(const char *haystack, const char *needle)

//比较两个字符串，等于0表示相等
int strcmp(const char* stri1，const char* str2);

//字符串转换为整数
int atoi(const char *nptr);

//将s所指向的某一块内存中的每个字节的内容全部设置为ch指定的ASCII值,块的大小由第三个参数指定,这个函数通常为新申请的内存做初始化工作； memset可以方便的清空一个结构类型的变量或数组。
void *memset(void *buffer, int c, int count)  

//内存复制,从src的开始位置拷贝n个字节的数据到dest。如果dest存在数据，将会被覆盖。memcpy函数的返回值是dest的指针
void *memcpy(void *dest, const void *src, size_t n);

//输出字符串
int puts(const char *s);

//在字符串 s 中查找字符 c，返回字符 c 第一次在字符串 s 中出现的位置,即剩下的字符串
char *strchr(const char *s, int c);

//拷贝n个字符str2 到 str1
 void *memmove(void *str1, const void *str2, size_t n) 
 
 //将字符串转换为整数，失败返回0
 long long strtoll（const char * restrict str，char ** restrict str_end，int base）;
```