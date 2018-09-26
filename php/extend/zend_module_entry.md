以下主要记录php扩展：zend_module_entry定义了扩展的全部信息：扩展名、扩展版本、扩展提供的函数列表以及PHP四个执行阶段的hook函数等,内核通过该结构获得扩展功能
动态库就是在php_ini_register_extensions()这个函数中完成的注册(位于main/main.c文件)，动态库注册到extension_lists.functions

主要通过dlopen，dlsystem加载动态库

### zend_module_entry结构
```c
/* {{{ hello_module_entry
 */
zend_module_entry hello_module_entry =
{
    STANDARD_MODULE_HEADER, // 宏统一设置
    "hello",                // 扩展名称
    hello_functions,        // 扩展函数列表，参考下面
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
```c
//zend_modules.h
struct _zend_module_entry {
    unsigned short size; //sizeof(zend_module_entry)
    unsigned int zend_api; //ZEND_MODULE_API_NO
    unsigned char zend_debug; //是否开启debug
    unsigned char zts; //是否开启线程安全
    const struct _zend_ini_entry *ini_entry;
    const struct _zend_module_dep *deps;
    const char *name; //扩展名称，不能重复
    const struct _zend_function_entry *functions; //扩展提供的内部函数列表
    int (*module_startup_func)(INIT_FUNC_ARGS); //扩展初始化回调函数，PHP_MINIT_FUNCTION或ZEND_MINIT_FUNCTION定义的函数
    int (*module_shutdown_func)(SHUTDOWN_FUNC_ARGS); //扩展关闭时回调函数
    int (*request_startup_func)(INIT_FUNC_ARGS); //请求开始前回调函数
    int (*request_shutdown_func)(SHUTDOWN_FUNC_ARGS); //请求结束时回调函数
    void (*info_func)(ZEND_MODULE_INFO_FUNC_ARGS); //php_info展示的扩展信息处理函数
    const char *version; //版本
    ...
    unsigned char type;
    void *handle;
    int module_number; //扩展的唯一编号
    const char *build_id;
};
```
有了zend_module_entry结构，还需要ZEND_GET_MODULE函数来获取这个结构
```c
// hello.c
ZEND_GET_MODULE(hello)

// zend_API.h
#define ZEND_GET_MODULE(name) \
    BEGIN_EXTERN_C()\
	ZEND_DLEXPORT zend_module_entry *get_module(void) { return &name##_module_entry; }\
    END_EXTERN_C()
// 展开后代码如下：
extern "C" { __declspec(dllexport) zend_module_entry *get_module(void) { return &hello_module_entry; } }

```
