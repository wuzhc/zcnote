我们知道每一个扩展都有一个zend_module_entry结构，在这个结构中，我们可以定义几个钩子函数，分别对应php的生命周期阶段
```c
/* {{{ hello_module_entry
 */
zend_module_entry hello_module_entry =
{
    STANDARD_MODULE_HEADER, // 宏统一设置
    "hello",                // 扩展名称
    hello_functions,       
    PHP_MINIT(hello),       
    PHP_MSHUTDOWN(hello),  
    PHP_RINIT(hello),   /* Replace with NULL if there's nothing to do at request start */
    PHP_RSHUTDOWN(hello), /* Replace with NULL if there's nothing to do at request end */
    PHP_MINFO(hello),
    PHP_HELLO_VERSION,
    STANDARD_MODULE_PROPERTIES // 宏统一设置
};
/* }}} */
```
通过PHP_MINIT,PHP_MSHUTDOWN,PHP_RINIT,PHP_RSHUTDOWN可以获得钩子函数的地址，zend_module_entry的几个钩子函数对应展开如下：
```c
PHP_MINIT(hello),       // 展开后zm_startup_hello
PHP_MSHUTDOWN(hello),   // 展开后zm_shutdown_hello
PHP_RINIT(hello),       // 展开后zm_activate_hello
PHP_RSHUTDOWN(hello),   // 展开后zm_deactivate_hello
```

### 具体钩子函数实现：
#### 模块初始化
可以注册类，常量，并且可以覆盖php编译和执行，从而接管php的编译和执行
```c
// hello.c
PHP_MINIT_FUNCTION(hello)
{
    /* If you have INI entries, uncomment these lines
    REGISTER_INI_ENTRIES();
    */
    return SUCCESS;
}
```
展开后
```c
int zm_startup_hello(int type, int module_number) 
{
    /* If you have INI entries, uncomment these lines
    REGISTER_INI_ENTRIES();
    */
    return SUCCESS;
}
```

模块关闭
```c
// hello.c
PHP_MSHUTDOWN_FUNCTION(hello)
{
    /* uncomment this line if you have INI entries
    UNREGISTER_INI_ENTRIES();
    */
    return SUCCESS;
}
```
展开后
```c
int zm_shutdown_hello(int type, int module_number) 
{
    /* If you have INI entries, uncomment these lines
    UNREGISTER_INI_ENTRIES();
    */
    return SUCCESS;
}
```

#### 请求初始化
在请求之前被调用
```c
PHP_RINIT_FUNCTION(hello)
{
#if defined(COMPILE_DL_HELLO) && defined(ZTS)
    ZEND_TSRMLS_CACHE_UPDATE();
#endif
    return SUCCESS;
}
```
展开后：
```c
int zm_activate_hello(int type, int module_number) 
{
#if defined(COMPILE_DL_HELLO) && defined(ZTS)
    ZEND_TSRMLS_CACHE_UPDATE();
#endif
    return SUCCESS;
}
```

#### 请求结束
在请求结束后被调用
```c
PHP_RSHUTDOWN_FUNCTION(hello)
{
    return SUCCESS;
}
```
展开后：
```c
int zm_deactivate_hello(int type, int module_number) 
{
    return SUCCESS;
}
```
