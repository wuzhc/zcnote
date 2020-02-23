模板文件 gopusher.tmpl
```yaml
user  root;
worker_processes  1;

error_log  /usr/local/nginx/logs/error.log warn;
pid        /usr/local/nginx/logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
    }

    include       /usr/local/nginx/conf/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /usr/local/nginx/logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    upstream websocket {
        {{range getvs "/socketserver/*"}}
        server {{.}};
        {{end}}
    }

    #include /etc/nginx/conf.d/*.conf;
    #include /usr/local/nginx/conf/conf.d/*.conf;
}
```

命令文件 gopuser.toml
```yaml
[template]
prefix = "/gopuser"
src = "gopuser.tmpl"
dest = "/usr/local/nginx/conf/nginx.conf"
owner = "wuzhc"
mode = "0644"
keys = [
  "/socketserver",
]
check_cmd = "nginx -t -c {{.dest}}"
reload_cmd = "nginx -s reload"
```

## 运行
```bash
confd -watch -backend etcdv3 -node http://127.0.0.1:2379
```
意思是confd监控的是etcd版本3，etcd节点为http://127.0.0.1:2379




