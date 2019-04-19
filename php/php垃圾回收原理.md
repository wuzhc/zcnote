PHP变量管理（销毁，分配）是基于引用计数和写时复制实现的

### 引用计数
&emsp;&emsp;php垃圾回收使用来引用计数的方法,php变量由zval结构体维护,zval结构体有refcount表示有多少个变量指向这个zval容器,is_ref用于区分引用变量,当unset一个变量时,会端断开变量到内存区域的链接,同时讲该区域的refcount引用计数减1,当refcount为0时,被当做垃圾,释放内存
引用计数的信息位于给具体value结构的gc中：
```c
typedef struct _zend_refcounted_h {
    uint32_t         refcount;          /* reference counter 32-bit */
    union {
        struct {
            ZEND_ENDIAN_LOHI_3(
                zend_uchar    type,
                zend_uchar    flags,    /* used for strings & objects */
                uint16_t      gc_info)  /* keeps GC root number (or 0) and color */
        } v;
        uint32_t type_info;
    } u;
} zend_refcounted_h;
```
note: 并不是所有的数据类型都会用到引用计数，如long、double直接都是硬拷贝,[参考](https://www.kancloud.cn/nickbai/php7/363267)

### 写时复制
&emsp;&emsp;变量复制、函数传参时并不直接硬拷贝一份value数据，而是将refcount++，变量销毁时将refcount--，等到refcount减为0时表示已经没有变量引用这个value，将它销毁;如果其中一个变量试图更改value的内容则会重新拷贝一份value修改，同时断开旧的指向,并且refcount--

### 内存溢出问题
&emsp;&emsp;php5.3版本之前会有内存溢出,主要是环形引用的问题(环形引用举个例子:数组一个元素的值复制为该数组的引用);这种问题主要出现在array,object两种类型  
gc机制:当refcount减1时,如果不为0且类型是IS_ARRAY、IS_OBJECT，则添加到回收池,当回收池满了,会遍历所有变量以及变量下面每一项,模拟recount减1,如果变量整个refcount为0,表示为垃圾,可以回收

### unset函数
&emsp;&emsp;unset只是断开一个变量到一块内存区域的链接,同时将该区域的引用计数-1,内存是否回收主要看refcount是否为0

### 参考
- 《PHP7内核剖析》
- [php7 垃圾回收机制详解](https://segmentfault.com/a/1190000016240169)
