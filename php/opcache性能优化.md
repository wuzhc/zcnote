## 参考
- https://www.cnblogs.com/HD/p/4554455.html

## 解释性语言与编译型语言的区别？
- 编译器先把源程序编译成机器语言，解析器是在源程序运行的时候再一条条解析成机器语言
- `golang`,`c++`是先编译成机器码后直接执行，而`php`和`python`先产生中间码，这个中间码只有解析器才可以识别执行，比如说`PHP`的解析器是`Zend`，PHP使用Zend引擎，中间码我们也称作为`操作码（opcode）`
- Basic程序，每条语言只有在执行才被翻译。这种解释型语言每执行一次就翻译一次，因而效率低下

## 开启opcache
```bash
# php.ini文件加入
zend_extension=opcache.so
```

## opcache参数
```bash
; 打开快速关闭, 打开这个在PHP Request Shutdown的时候会收内存的速度会提高
; 推荐 1
opcache.fast_shutdown=1

; 是否保存文件/函数的注释，如果apigen、Doctrine、 ZF2、 PHPUnit需要文件注释
; 推荐 0
opcache.save_comments=1

; 开启文件时间戳验证，只有开启了，revalidate_freq才有效，否则代码一直是使用opcache缓存的 
opcache.validate_timestamps=1

; 2s检查一次文件更新，注意:0是一直检查不是关闭，改参数类似于缓存时间
; 推荐 60
opcache.revalidate_freq=2

; 最大缓存的文件数目 200  到 100000 之间
; 推荐 4000
opcache.max_accelerated_files=2000

; Zend Optimizer + 共享内存的大小, 总共能够存储多少预编译的 PHP 代码(单位:MB)
; 推荐 128
opcache.memory_consumption=64
 
; Zend Optimizer + 暂存池中字符串的占内存总量.(单位:MB)
; 推荐 8
opcache.interned_strings_buffer=4
```

