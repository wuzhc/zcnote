### 字符串
```c
zend_string *data;
ZEND_PARSE_PARAMETERS_START(1, 2)
Z_PARAM_STR(data)
ZEND_PARSE_PARAMETERS_END();

php_printf("%s \n", ZSTR_VAL(data));
```
- Z_PARAM_STR 解析到zend_string*类型的地址
- ZSTR_VAL 展开后为(zstr)->val,获得字符串的值

### 数组
```c
zval *arr;
HashTable *ht;
int array_count;

ZEND_PARSE_PARAMETERS_START(1, 2)
Z_PARAM_ARRAY(arr)
ZEND_PARSE_PARAMETERS_END();

ht = Z_ARRVAL_P(arr);
array_count = zend_hash_num_elements(ht);
```
- Z_PARAM_ARRAY 解析到zval结构类型的地址
- Z_ARRVAL_P 展开后为(*zval).value.arr，获得一个指向zend_array的指针
- zend_hash_num_elements(ht) 获得数组元素个数；ht为zend_array类型指针