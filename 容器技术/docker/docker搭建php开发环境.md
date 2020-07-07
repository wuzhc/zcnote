```bash
docker network create php-hub-local

#mysql服务
docker run --network php-hub-local --name mysql-local -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -d mysql:v57

##phpmyadmin服务
docker run  --network php-hub-local --name phpmyadmin-local -p 8089:80 --link mysql-local:db -d phpmyadmin/phpmyadmin:latest

#mongo服务
# --privileged container内的root拥有真正的root权限。
docker run --privileged=true -p 27017:27017 -v $PWD/config:/etc/mongod -v $PWD/db:/data/db --name mongodb-local mongo:4.0.0 -f /etc/mongod/config.conf  --bind_ip_all

#php-fpm服务
docker run --network php-hub-local --name php-fpm-local -v /data/wwwroot/default:/app -v /data/wwwroot/docker/php-hub/php/conf/php.ini:/usr/local/etc/php/php.ini -e PHP_INI_PATH=/usr/local/etc/php/php.ini -p 9000:9000 -d crunchgeek/php-fpm:7.3

docker run --network php-hub-local --name php-fpm-local -v /data/wwwroot/default:/app -d bitnami/php-fpm7.3

#nginx服务
docker run --network php-hub-local --name nginx-local -p 80:80 -v /data/wwwroot/default:/usr/share/nginx/html -v /data/wwwroot/docker/php-hub/nginx/conf:/etc/nginx/conf.d -d nginx
```

## docker安装php扩展
以mongo为例：
```bash
docker exec -it php-fpm-local /bin/bash
apt-get update
apt-get install autoconf gcc make
pecl install mongodb
pecl install redis
wget https://github.com/alanxz/rabbitmq-c/archive/v0.10.0.tar.gz
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr/local ..
cmake --build . --target install
pecl install amqp
```

## nginx配置虚拟域名
```bash
server {
    listen       80;
    server_name  weike.cm;

    location / {
        root   /usr/share/nginx/html/weike;
        index  index.html index.htm index.php;
    }

    #error_page   500 502 503 504  /50x.html;
    #location = /50x.html {
    #    root   /usr/share/nginx/html;
    #}

    location ~ \.php$ {
	root /app/weike; #这里必须是php-fpm容器里面的路径
        fastcgi_pass   php-fpm-local:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name; #这里的documet_root的值是root
        include        fastcgi_params;
    }
}
```



