> 以我有限的认知,负载均衡软件上有`LVS`,`nginx`可以用来搭建,
> Nginx负载均衡（工作在七层“应用层”）功能主要是通过upstream模块实现，Nginx负载均衡默认对后端服务器有健康检测的能力，仅限于端口检测，在后端服务器比较少的情况下负载均衡能力表现突出。

作者:伊戈尔.西索夫

## http模块指定upstream
```bash
http {
    upstream myweb {
        server 127.0.0.1:9501 weight=1;
        server 127.0.0.1:9502 weight=2;
    }
}
```
- myweb可以自定义,在下面的`proxy_pass`需要用到这个名称
- weight权重越大,被分配的几率越大

## server模块指定location的proxy_pass
```bash
server {
    location / {                                               
        root   /usr/share/nginx/html;                          
        index  index.html index.htm;                           
        proxy_pass http://myweb;      
        proxy_next_upstream http_500 http_502 error timeout invalid_header;
    }    
}
```
- `proxy_next_upstream`故障转移,当500,502,错误,超时等会自动将请求转发到upsteam负载均衡器另一个台服务器

## 负载均衡算法
- 轮询
- 轮询权重weight
- ip_hash 将ip固定分配到某台服务器,可以解决session共享问题
- url_hash
- least_conn 最小链接数

## upstream设置负载均衡调度状态
- down 当前server不参与负载均衡
- backup 当其他server不可用时,backup会启动并接收请求
- max_fails 允许请求失败次数,默认为1,和fail_timeout一起使用
- fail_timeout 当max_fails次数失败后,server将在fail_timeout内不会接收请求
```bash
http {
    upstream xxx {
    	ip_hash; # 使用ip_hash算法
        server 127.0.0.1 weight=1 max_fails=3 fail_timeout=20s;
    }
}
```