## 创建confdir
```bash
sudo mkdir -p /etc/confd/{conf.d,templates}
```

配置文件以`toml`后缀
```bash
[template]
prefix = "/myapp" 
src = "nginx.tmpl" # 模板文件，需要定义在/etc/confd/templates目录之下
dest = "/tmp/myapp.conf" # 生成的配置文件
owner = "nginx"
mode = "0644"
keys = [
  "/services/web" // 需要监控的key
]
check_cmd = "docker exec chat-nginx nginx -t -c "/etc/nginx/nginx.conf""
reload_cmd = "/usr/sbin/service nginx -s reload"
```

模板常用的命令
`base，get，gets，lsdir，json，getv，getvs`
```bash
{{range $dir := lsdir "/services/web"}}
upstream {{base $dir}} {
    {{$custdir := printf "/services/web/%s/*" $dir}}{{range gets $custdir}}
    server {{$data := json .Value}}{{$data.IP}}:80;
    {{end}}
}
 
server {
    server_name {{base $dir}}.example.com;
    location / {
        proxy_pass {{base $dir}};
    }
}

upstream {{getv "/subdomain"}} {
{{range getvs "/upstream/*"}}
    server {{.}};
{{end}}
}
```

## 实例
定义配置文件
```conf
[template]
prefix = "/chat-nginx"
src = "chat-nginx.tmpl"
dest = "/data/wwwroot/go/src/socketServer/nginx/nginx.conf"
owner = "docker"
mode = "0644"
keys = [
    "/socketserver",
]
check_cmd = "docker exec chat-nginx nginx -t -c /etc/nginx/nginx.conf"
reload_cmd = "docker exec chat-nginx nginx -s reload"
```

定义template
```conf
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
    }

    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    upstream websocket {
        {{range getvs "/socketserver/*"}}
        server {{.}};
        {{end}}
    }

    include /etc/nginx/conf.d/*.conf;
}
```

添加新socket-server
```bash
etcdctl put /chat-nginx/socketserver/8889 "192.168.1.104:8889 weight=2"
```

同步配置文件
```bash
confd -onetime -backend etcdv3 -node http://127.0.0.1:2379
confd -watch -backend etcdv3 -node http://127.0.0.1:2379 &
```

## nginx docker
```bash
docker run --name chat-nginx -v `pwd`/nginx/nginx.conf:/etc/nginx/nginx.conf -v `pwd`/nginx/conf.d:/etc/nginx/conf.d -v `pwd`/assets:/assets -p 8081:80 nginx 
```

重启下nginx
```bash
docker exec chat-nginx nginx -s reload
```

测试配置文件格式是否正确
```bash
docker exec chat-nginx nginx -t -c /etc/nginx/nginx.conf
```

## 参考
- [https://blog.csdn.net/bbwangj/article/details/82953786](https://blog.csdn.net/bbwangj/article/details/82953786)





