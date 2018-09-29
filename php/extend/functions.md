### 定义函数
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

### 函数参数解析
通过zend_parse_parameters()解析保存在zend_execute_data的参数;
```c
zend_string   *str;
if(zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "S", &str) == FAILURE){
    ...
}
```
- num_args: 通过ZEND_NUM_ARGS()获得参数个数，TSRMLS_CC用来确保线程安全 
- type_spec: 是一个字符串,用来标识解析参数类型
    - l 或 L 表示传入的参数解析为zend_long(l!或L!则会检测参数是否为null,若为null,则设置为0,同时zend_bool设置为1)
    - b表示传入的参数解析为zend_bool
    - d表示传入的参数解析为double
    - s, S, P, p表示传入的参数解析为string,s解析到char*,且需要一个size_t类型用于获取字符串长度，S解析到zend_string
    - a, A, h, H表示传入的参数解析为array,aA解析到zval,hH解析到hashTable
    - o, O 对象, 解析到zval
    - r 资源, 解析到zval
    - C 类, 解析到zend_class_entry
    - f 回调函数, 解析到zend_fcall_info
    - z 任意类型  
   
    
type_spec标识符:
- | 表示之后的参数为可选,例如al|b可以表示3个参数或2个参数,b为可选
- \* 可变参数,可以不传递
- \+ 可变参数,至少一个
    
### 引用传参
如果用到参数引用，需要定义参数数组，参数数组定义在ZEND_BEGIN_ARG_INFO_EX和ZEND_END_ARG_INFO两个宏之间
```c
#define ZEND_BEGIN_ARG_INFO_EX(name, _unused, return_reference, required_num_args)
```
- name参数数组名，对应PHP_FE的第二个参数
- required_num_args 函数有多少个引用参数，就需要在参数数组中定义多少个zend_internal_arg_info

zend_internal_arg_info宏定义如下：
```c
//pass_by_ref表示是否引用传参，name为参数名称
#define ZEND_ARG_INFO(pass_by_ref, name)                             { #name, NULL, 0, pass_by_ref, 0, 0 },

//只声明此参数为引用传参
#define ZEND_ARG_PASS_INFO(pass_by_ref)                              { NULL,  NULL, 0, pass_by_ref, 0, 0 },

//显式声明此参数的类型为指定类的对象，等价于PHP中这样声明：MyClass $obj
#define ZEND_ARG_OBJ_INFO(pass_by_ref, name, classname, allow_null)  { #name, #classname, IS_OBJECT, pass_by_ref, allow_null, 0 },

//显式声明此参数类型为数组，等价于：array $arr
#define ZEND_ARG_ARRAY_INFO(pass_by_ref, name, allow_null)           { #name, NULL, IS_ARRAY, pass_by_ref, allow_null, 0 },

//显式声明为callable，将检查函数、成员方法是否可调
#define ZEND_ARG_CALLABLE_INFO(pass_by_ref, name, allow_null)        { #name, NULL, IS_CALLABLE, pass_by_ref, allow_null, 0 },

//通用宏，自定义各个字段
#define ZEND_ARG_TYPE_INFO(pass_by_ref, name, type_hint, allow_null) { #name, NULL, type_hint, pass_by_ref, allow_null, 0 },

//声明为可变参数
#define ZEND_ARG_VARIADIC_INFO(pass_by_ref, name)                    { #name, NULL, 0, pass_by_ref, 0, 1 },
```
引用参数通过zend_parse_parameters()解析时只能使用"z"解析，不能再直接解析为zend_value了，否则引用将失效，下面是一个引用参数的例子
```c
// 引用参数数组定义
ZEND_BEGIN_ARG_INFO_EX(arginfo_changeName, 0, 0, 1)
ZEND_ARG_INFO(1, name) // zend_internal_arg_info宏定义
ZEND_END_ARG_INFO()

PHP_FUNCTION(changeName)
{
    zval *lval;
    if (zend_parse_parameters(ZEND_NUM_ARGS(), "z", &lval) == FAILURE) // z表示任意类型，将参数解析到zval地址
    {
        return;
    }
    zval *real_val = Z_REFVAL_P(lval); // Z_REFVAL_P展开后&(lval.value->ref.val)
    Z_LVAL_P(real_val) = 100; // Z_LVAL_P展开后lval.value->ref.val.value.lval = 100
}

const zend_function_entry hello_functions[] =
{
    PHP_FE(changeName, arginfo_changeName) // 第二个参数为参数数组名
    PHP_FE_END 
};
```

### 函数返回值
#### 返回数组
```c
PHP_FUNCTION(getArray)
{
    array_init(return_value);
    add_assoc_string(return_value, "name", "wuzhc");
    add_assoc_string(return_value, "address", "GD");
    add_next_index_string(return_value, "Guangzhou");
    add_next_index_string(return_value, "School");
}
```
- add_assoc_* 添加关联索引数组元素，如key=>value
- add_next_index_* 添加数字索引数组元素
```php
print_r(getArray());
```
php脚本输出如下：
```bash
Array
(
    [name] => wuzhc
    [address] => GD
    [0] => Guangzhou
    [1] => School
)
```


### 调用其他函数
通过call_user_function，内部函数可以调用PHP脚本自定义函数或其他扩展的内部函数
```c
ZEND_API int call_user_function(HashTable *function_table, zval *object, zval *function_name, zval *retval_ptr, uint32_t param_count, zval params[]);
```
- function_table符号表，普通函数边到EG(function_table)，类成员方法保存在zend_class_entry.function
- object（成员方法才需要用到，普通函数设置为NULL）
- function_name 调用函数名
- retval_ptr 返回值地址
- param_count 参数个数
- params 参数数组

以一个例子为说明：
```php
// 调用扩展内部函数my_array_merge,内部函数my_array_merge将调用array_merge函数
$arr1 = array(1,2);
$arr2 = array(3,4);
$arr3 = my_array_merge($arr1, $arr2);
print_r($arr3);
```
my_array_merge实现如下：
```c
PHP_FUNCTION(my_array_merge)
{
    zend_array *arr1, *arr2;
    zval call_func_name, call_func_ret, call_func_params[2];
    zend_string *call_func_str;
    char *func_name = "array_merge";

    if (zend_parse_parameters(ZEND_NUM_ARGS(), "hh", &arr1, &arr2) == FAILURE)
    {
        return ;
    }

    call_func_str = zend_string_init(func_name, strlen(func_name), 0); // 分配zend_string
    ZVAL_STR(&call_func_name, call_func_str); // call_func_name.value.str = call_func_str(string字符串指针)
    ZVAL_ARR(&call_func_params[0], arr1); // call_func_params[0].value.arr = arr1 (array数组指针)
    ZVAL_ARR(&call_func_params[1], arr2); // call_func_params[1].value.arr = arr2 (array数组指针)

    if (SUCCESS != call_user_function(EG(function_table), NULL, &call_func_name, &call_func_ret, 2, call_func_params))
    {
        zend_string_release(call_func_str);
        RETURN_FALSE;
    }
    else
    {
        zend_string_release(call_func_str);
        RETURN_ARR(Z_ARRVAL(call_func_ret)); // 调用array_merge结果地址会存放在call_func_ret，RETURN_ARR参数是一个数组指针
    }
}
```

### 回调函数
