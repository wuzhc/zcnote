参数保存到zend_execute_data,然后通过zend_parse_parameters()解析保存在zend_execute_data的参数;
```c
zend_parse_parameters(int num_args, const char *type_spec, ...)
```
- num_args: 通过ZEND_NUM_ARGS()获得参数个数
- type_spec: 是一个字符串,用来标识解析参数类型
    - l 或 L 表示传入的参数解析为zend_long(l!或L!则会检测参数是否为null,若为null,则设置为0,同时zend_bool设置为1)
    - b表示传入的参数解析为zend_bool
    - d表示传入的参数解析为zend_double
    - s, S, P, p表示传入的参数解析为字符串
