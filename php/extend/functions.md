函数会被注册到EG(function_table)，函数被调用时根据函数名称在这个符号表中查找  
内部函数即由C实现逻辑的函数，可以直接供php调用，用户函数是指PHP脚本中用户自定义函数；  
内部函数结构如下：
```c
typedef struct _zend_internal_function {
    /* Common elements */
    zend_uchar type;
    zend_uchar arg_flags[3]; /* bitset of arg_info.pass_by_reference */
    uint32_t fn_flags;
    zend_string* function_name;
    zend_class_entry *scope;
    zend_function *prototype;
    uint32_t num_args;
    uint32_t required_num_args;
    zend_internal_arg_info *arg_info;
    /* END of common elements */

    void (*handler)(INTERNAL_FUNCTION_PARAMETERS); //函数指针，展开：void (*handler)(zend_execute_data *execute_data, zval *return_value)
    struct _zend_module_entry *module;
    void *reserved[ZEND_MAX_RESERVED_RESOURCES];
} zend_internal_function;
```
主要关注的是handler,handler是一个函数指针，由PHP_FUNCTION定义，例如：
```c
// hello.c
PHP_FUNCTION(helloworld)
{
    zend_string *strg;
    strg = strpprintf(0, "hello world \n");
    RETURN_STR(strg);
}
```
宏定义：
```c
// main/php.h
#define PHP_FUNCTION                 ZEND_FUNCTION
// zend_API.h
#define ZEND_FUNCTION(name)		     ZEND_NAMED_FUNCTION(ZEND_FN(name))
#define ZEND_NAMED_FUNCTION(name)    void name(INTERNAL_FUNCTION_PARAMETERS)
#define ZEND_FN(name)                zif_##name
// zend.h
#define INTERNAL_FUNCTION_PARAMETERS zend_execute_data *execute_data, zval *return_value
```
展开后：
```c
void zif_helloworld(zend_execute_data *execute_data, zval *return_value) 
{
    zend_string *strg;
    strg = strpprintf(0, "hello world \n");
    RETURN_STR(strg);
}
```

以上扩展可以通过PHP_FUNCTION定义函数，接下来需要注册函数，每个函数需要实现zend_function_entry结构，然后把zend_function_entry保存到扩展zend_module_entry.functions函数列表即可；
zend_function_entry通过PHP_FE()定义，例如：
```c
const zend_function_entry hello_functions[] =
{
    PHP_FE(wcl, NULL)
    PHP_FE(helloworld, NULL)
    PHP_FE_END  /* Must be the last line in hello_functions[] */
};
```
zend_function_entry结构：
```c
typedef struct _zend_function_entry {
    const char *fname;                              // 函数名称
    void (*handler)(INTERNAL_FUNCTION_PARAMETERS);  // 函数指针
    const struct _zend_internal_arg_info *arg_info; // 参数信息
    uint32_t num_args;                              // 参数数目
    uint32_t flags;
} zend_function_entry;
```
PHP_FE展开后：
```c
{ 'helloworld', zif_helloworld, arg_info, (uint32_t) (sizeof(arg_info)/sizeof(struct _zend_internal_arg_info)-1), flags },
```
上面整个结构展开后如下：
```c
const zend_function_entry hello_functions[] =
{
    { 'wcl', zif_wcl, arg_info, (uint32_t) (sizeof(arg_info)/sizeof(struct _zend_internal_arg_info)-1), flags },
    { 'helloworld', zif_helloworld, arg_info, (uint32_t) (sizeof(arg_info)/sizeof(struct _zend_internal_arg_info)-1), flags },
    { NULL, NULL, NULL, 0, 0 }
};
```
最后将hello_functions赋值给zend_module_entry.functions即可
