## 编译器gcc
```bash
gcc hello.c -o hello 
```

`c语言`的入口函数是`main`,和`golang`是一样的

## 指针括号优先级
`(*t).age` 不等于 `*t.age`
- `(*t).age`指的是`*t`的`age`
- `*t.age`指定是`t.age`的地址

## 函数指针
函数名是指向函数的指针
```c
int (*warp_fn)(int);
warp_fn = go_to_warp_speed;//go_to_warp_speed是一个函数
warp_fn(4);//相当于go_to_warp_speed(4)
```
总结：`返回类型(*指针变量)(参数类型)`

`char**`是一个指针，通常用来指向字符串数组