## php://stdin, php://stdout 和 php://stderr
标准输入，标准输出，错误输出，允许直接访问 PHP 进程相应的输入或者输出流。 数据流引用了复制的文件描述符，如果打开 `php://stdin`并在之后关了它， 仅是关闭了复制品，真正被引用的`STDIN`并不受影响，推荐使用常量 `STDIN`、 `STDOUT` 和 `STDERR` 来代替手工打开这些封装器。

## php://input
可以访问请求原始数据的只读流，`POST` 请求的情况下，最好使用 `php://input`来代替 `$HTTP_RAW_POST_DATA`，因为它不依赖于特定的`php.ini`配置
当`enctype="multipart/form-data"` 的时候 `php://input`是无效的。

## php://output
只写的数据流

## php://fd
php://fd 允许直接访问指定的文件描述符。 例如 php://fd/3 引用了文件描述符 3。

## php://memory 和 php://temp
`php://memory` 和 `php://temp` 是一个类似文件 包装器的数据流，允许读写临时数据，两者的唯一区别是 `php://memory` 总是把数据储存在内存中， 而 `php://temp` 会在内存量达到预定义的限制后（默认是 2MB）存入临时文件中。 临时文件位置的决定和 `sys_get_temp_dir()` 的方式一致
`php://temp` 的内存限制可通过添加 `/maxmemory:NN` 来控制，NN 是以字节为单位、保留在内存的最大数据量，超过则使用临时文件
`php://memory` 和 `php://temp` 是一次性的，比如：stream 流关闭后，就无法再次得到以前的内容了。

```php
<?php
// Set the limit to 5 MB.
$fiveMBs = 5 * 1024 * 1024;
$fp = fopen("php://temp/maxmemory:$fiveMBs", 'r+');

fputs($fp, "hello\n");

// Read what we have written.
rewind($fp);
echo stream_get_contents($fp);
?>
```

## 参考
- [https://www.php.net/manual/zh/wrappers.php.php](https://www.php.net/manual/zh/wrappers.php.php)
