### 第一步：定义全局变量结构体
扩展的全局变量统一定义在一个结构体中，如下
```c
// php_hello.h
ZEND_BEGIN_MODULE_GLOBALS(hello)
  zend_long filter_blank;
ZEND_END_MODULE_GLOBALS(hello)
```
展开后：
```c
typedef struct _zend_hello_globals 
{
    zend_long filter_blank; // fiter_blank是一个全局变量
} zend_hello_globals;
```

### 第二步：声明全局变量
以上在定义好了结构体，接下来就是要去使用它，声明如下：
```c
// hello.c
ZEND_DECLARE_MODULE_GLOBALS(hello)
```
展开后：
```c
// 开启ZTS(线程安全管理)
ts_rsrc_id module_name##_globals_id;
```
```c
// 没有开启ZTS
zend_hello_globals hello_globals;
```

### 第三步：读写全局变量
php_hello.h定义了HELLO_G(v)宏，可以通过HELLO_G(v)读写全局变量，宏定义如下：
```c
#define HELLO_G(v) ZEND_MODULE_GLOBALS_ACCESSOR(hello, v)
```
展开后：
```c
// ZTS
#define HELLO_G(v) ((zend_hello_globals *)(*((void ***) NULL))((hello_globals_id)-1))->v
```
```c
// 非ZTS
#define HELLO_G(v) hello_globals.v
```
使用如下：
```c
/* {{{ proto int wcl(string filename)
    */
PHP_FUNCTION(wcl)
{
    char *filename = NULL;
    int argc = ZEND_NUM_ARGS();
    size_t filename_len;
    char ch, pre = '\n';
    FILE *fp;
    zend_long lcount = 0;

    if (zend_parse_parameters(argc, "s", &filename, &filename_len) == FAILURE)
        return;

    if ((fp = fopen(filename, "r")) == NULL)
    {
        RETURN_FALSE;
    }

    while ((ch = fgetc(fp)) != EOF)
    {
        if (ch == '\n')
        {
            if (HELLO_G(filter_blank) && pre == ch) // 读取全局变量filter_blank
            {
                continue;
            }
            lcount++;
        }
        pre = ch;
    }
    fclose(fp);

    RETURN_LONG(lcount);
    // php_error(E_WARNING, "wcl: not yet implemented");
}
/* }}} */
```

### php.ini配置
如果我们的程序想通过php.ini程序读取配置，除了需要将配置项定义在全局变量外，还需要将扩展的配置项映射到对应的全局变量，例如php.ini中的hello.filter_blank映射到HELLO_G中的filter_blank全局变量；
比如将php.ini中的hello.filter_blank值映射到HELLO_G()结构中的filter_blank，类型为zend_long，默认值0，则可以这么定义规则：
```c
// hello.c
PHP_INI_BEGIN()
STD_PHP_INI_ENTRY("hello.filter_blank", "0", PHP_INI_ALL, OnUpdateLong, filter_blank, zend_hello_globals, hello_globals)
// 其他配置项
PHP_INI_END()
```
以上定义好规则之后，接下来就要进行解析了：
```c
/* {{{ PHP_MSHUTDOWN_FUNCTION
 */
PHP_MSHUTDOWN_FUNCTION(hello)
{
    /* uncomment this line if you have INI entries
    UNREGISTER_INI_ENTRIES(); // 需要把这行注释去掉
    */
    UNREGISTER_INI_ENTRIES();
    return SUCCESS;
}
/* }}} */
```