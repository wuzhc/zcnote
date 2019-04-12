## nginx.conf
添加一个server{}，每个server里面的配置对应一个虚拟主机vhost
```bash
server {
　　listen 80;    //80端口
　　server_name linux.com;     //设置域名

     #直接输入域名进入的目录和默认解析的文件
　　location / { 
　　　　index index.html; 
　　　　root /usr/htdocs/linux; //直接输入linux.com是进到了这里 ,一般配置和解析php所在目录一直
　　}

      #解析.php的文件
　　location ~ \.php$ {
　　　　fastcgi_pass 127.0.0.1:9000;
　　　　fastcgi_index index.php;
　　　　fastcgi_param SCRIPT_FILENAME /usr/htdocs/linux/$fastcgi_script_name;   //当前虚拟主机对应的目录
　　　　include fastcgi_params;
　　} 
}
```