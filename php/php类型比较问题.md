## 类型比较
```php
<?php 
echo -1 == true ? 'yes' : 'no';
echo PHP_EOL;
echo 'null' == true ? 'yes' : 'no';
echo PHP_EOL;
echo 'name' == 1 ? 'yes' : 'no';
echo PHP_EOL;
echo in_array('name',array(true,1)) ? 'yes' : 'no';
```

- 数字和布尔值比较，数字先转换为布尔值（0转为false）
- 字符串和布尔值比较，字符串先转换为布尔值（空字符和0值字符串转为false）
- 字符串和数字比较，字符串先转换为数字（12d转为12,name转为0）
- 字符串和字符串比较，根据acsii码比较

## empty函数
```bash
empty('')
empty(0)
emtpy('0')
empty(null)
```
以上都满足，结果返回`true`

