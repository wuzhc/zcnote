#### 函数参数解析
参数保存到zend_execute_data,然后通过zend_parse_parameters()解析保存在zend_execute_data的参数;
```c
zend_string    *str;
if(zend_parse_parameters(ZEND_NUM_ARGS(), "S", &str) == FAILURE){
    ...
}
```
- num_args: 通过ZEND_NUM_ARGS()获得参数个数
- type_spec: 是一个字符串,用来标识解析参数类型
    - l 或 L 表示传入的参数解析为zend_long(l!或L!则会检测参数是否为null,若为null,则设置为0,同时zend_bool设置为1)
    - b表示传入的参数解析为zend_bool
    - d表示传入的参数解析为double
    - s, S, P, p表示传入的参数解析为zend_string
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
    
