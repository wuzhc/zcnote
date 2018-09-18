- 单井号就是将后面的 宏参数 进行字符串操作，就是将后面的参数用双引号引起来  
- 双井号就是用于连接

以php底层PHP_FE为例子:
```c
// php.h
#define PHP_FE	ZEND_FE

// zend_API.h
#define ZEND_FE(name, arg_info)  ZEND_FENTRY(name, ZEND_FN(name), arg_info, 0)
#define ZEND_FN(name) zif_##name
#define ZEND_FENTRY(zend_name, name, arg_info, flags)	{ #zend_name, name, arg_info, (uint32_t) (sizeof(arg_info)/sizeof(struct _zend_internal_arg_info)-1), flags },

const zend_function_entry helloworld_functions[] = {
    PHP_FE(hello,NULL) 
    PHP_FE_END    
};
```
此处的PHP_FE(hello,NULL)展开如下:
```c
const zend_function_entry helloworld_functions[] = {
    {
        "hello", zif_hello, NULL, (zend_uint)(sizeof(NULL) / sizeof(struct _zend_arg_info) - 1), 0
    },
    PHP_FE_END    
};

```