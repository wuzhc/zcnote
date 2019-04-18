> PHP的FPM需要独立运行, 有自己的独立的配置文件. 等等.
> 默认情况下, FPM监听某个(127.0.0.1:9000)端口, 等待nginx(或者其他的web服务器)将请求转过来.由于PHP独立运行了, 再修改PHP的配置, 就不需要重启web服务器(nginx)了, 重启PHP-FPM即可.

```bash
server {
    location ~ \.php$ {
        root           html;
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        include        fastcgi_params;
    }
}
```
一个server对应一个虚拟主机,在server模块提供对请求脚本的解析工作:`location指令`, 匹配请求的URL脚本. 以`.php`结尾的请求, 交给PHP-FPM处理