### php_hello.h
```c
// php_hello.h
extern zend_class_entry *person_ce_ptr;

PHP_METHOD(hello,__construct);
PHP_METHOD(hello,saying);
PHP_METHOD(hello,__destruct);
```

### hello.c
```c
// hello.c
zend_class_entry person_ce;
zend_class_entry *person_ce_ptr;

ZEND_BEGIN_ARG_INFO_EX(arginfo_person_saying, 0, 0, 1)
ZEND_ARG_INFO(0, msg) // zend_internal_arg_info宏定义
ZEND_END_ARG_INFO()

const zend_function_entry person_functions[] =
{
    PHP_ME(hello, __construct, NULL, ZEND_ACC_PUBLIC | ZEND_ACC_CTOR) // ZEND_ACC_PUBLIC表示访问级别为public，ZEND_ACC_CTOR表示是构造函数
    PHP_ME(hello, saying, arginfo_person_saying, ZEND_ACC_PUBLIC) 
    PHP_ME(hello, __destruct, NULL, ZEND_ACC_PUBLIC | ZEND_ACC_DTOR) // ZEND_ACC_DTOR表示析构函数
    PHP_FE_END
};

PHP_METHOD(hello, saying)
{
    char *content;
    size_t content_len;

    if (zend_parse_parameters(ZEND_NUM_ARGS(), "s", &content, &content_len) == FAILURE)
    {
        return;
    }

    // saying方法参数值赋值给name属性,用zend_update_property_string快捷函数代替
    // zval tmp;
    // ZVAL_STRING(&tmp, content);
    // Z_SET_REFCOUNT(tmp, 0);
    // zend_update_property(scope, object, name, name_length, &tmp);
    
    // saying方法参数值赋值给name属性
    zend_update_property_string(person_ce_ptr, getThis(), ZEND_STRL("name"), content);
    
    zval *self = getThis(); // getThis返回一个zval指针
    zval *name;
    zval rv;
    
    // 读取name属性并打印name的值
    name = zend_read_property(Z_OBJCE_P(self), self, ZEND_STRL("name"), 0 TSRMLS_CC, &rv); // Z_OBJECT_P展开后是(zval).value.obj->ce
    php_printf("%s", Z_STRVAL(name)); // zend_read_property返回一个zval结构, Z_STRVAL(name)展开后name->value.str.val
}


PHP_MINIT_FUNCTION(hello)
{
    INIT_CLASS_ENTRY(person_ce, "person", person_functions); // 类名和类方法
    person_ce_ptr = zend_register_internal_class(&person_ce TSRMLS_CC); // 注册
    zend_declare_property_null(person_ce_ptr, ZEND_STRL("name"), ZEND_ACC_PUBLIC TSRMLS_CC); // 定义name属性，默认值为null
    return SUCCESS;
}
```

### 使用
```php
$person = new Person();
$person->saying("hello wolrd");
echo $person->name . "\n";
```

上面是一个类实现方法，代码都有详细的注释，以下是一些知识点补充：
```c
// 读取普通属性
ZEND_API zval *zend_read_property(zend_class_entry *scope, zval *object, char *name, int name_length, zend_bool silent TSRMLS_DC);
// 读取静态属性
ZEND_API zval *zend_read_static_property(zend_class_entry *scope, char *name, int name_length, zend_bool silent TSRMLS_DC);
// 更新普通属性
ZEND_API void zend_update_property(zend_class_entry *scope, zval *object, char *name, int name_length, zval *value TSRMLS_DC); 
// 更新静态属性
ZEND_API int zend_update_static_property(zend_class_entry *scope, char *name, int name_length, zval *value TSRMLS_DC);
```
快捷函数
```c
ZEND_API void zend_update_property_null(zend_class_entry *scope, zval *object, char *name, int name_length TSRMLS_DC); 
ZEND_API void zend_update_property_bool(zend_class_entry *scope, zval *object, char *name, int name_length, long value TSRMLS_DC); 
ZEND_API void zend_update_property_long(zend_class_entry *scope, zval *object, char *name, int name_length, long value TSRMLS_DC); 
ZEND_API void zend_update_property_double(zend_class_entry *scope, zval *object, char *name, int name_length, double value TSRMLS_DC); 
ZEND_API void zend_update_property_string(zend_class_entry *scope, zval *object, char *name, int name_length, const char *value TSRMLS_DC); 
ZEND_API void zend_update_property_stringl(zend_class_entry *scope, zval *object, char *name, int name_length, const char *value, int value_length TSRMLS_DC);
ZEND_API int zend_update_static_property_null(zend_class_entry *scope, char *name, int name_length TSRMLS_DC); 
ZEND_API int zend_update_static_property_bool(zend_class_entry *scope, char *name, int name_length, long value TSRMLS_DC); 
ZEND_API int zend_update_static_property_long(zend_class_entry *scope, char *name, int name_length, long value TSRMLS_DC); 
ZEND_API int zend_update_static_property_double(zend_class_entry *scope, char *name, int name_length, double value TSRMLS_DC); 
ZEND_API int zend_update_static_property_string(zend_class_entry *scope, char *name, int name_length, const char *value TSRMLS_DC); 
ZEND_API int zend_update_static_property_stringl(zend_class_entry *scope, char *name, int name_length, const char *value, int value_length TSRMLS_DC);
```
