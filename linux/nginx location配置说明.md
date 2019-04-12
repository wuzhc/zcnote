## location几种匹配模式：
-（1）严格匹配，= 作为前缀 location = /uri (以`=`作为标识)
-（2）字符串匹配，多个字符串匹配时，与字符串长短有关系（长的先匹配,以`/`作为标识）
-（3）正则匹配，多个正则匹配时，与顺序有关系（前的先匹配,以`~`作为标识）

## location匹配原则：
（1）如果有严格匹配，则匹配成功后中止匹配
（2）先匹配字符串，在匹配正则表达式
（3）先匹配字符串，如果使用^~,则中止其他匹配

## location格式：
location = /uri 　　　=开头表示精确匹配，只有完全匹配上才能生效。
location ^~ /uri 　　^~ 开头对URL路径进行前缀匹配，并且在正则之前。
location ~ pattern 　~开头表示区分大小写的正则匹配。
location ~* pattern 　~*开头表示不区分大小写的正则匹配。
location /uri 　　　　不带任何修饰符，也表示前缀匹配，但是在正则匹配之后。
location / 　　　　　通用匹配，任何未匹配到其它location的请求都会匹配到，相当于switch中的default。 

## 例子说明：
测试"^~"和"~"，nginx配置如下。浏览器输入http://localhost/helloworld/test，返回601。如将#1注释，#2打开，浏览器输入http://localhost/helloworld/test，返回603。注：#1和#2不能同时打开，如同时打开，启动nginx会报nginx: [emerg] duplicate location "/helloworld"...，因为这两个都是普通字符串。
```conf
location ^~ /helloworld {      #1
    return 601;
}
        
#location /helloworld {        #2
#    return 602;
#}

location ~ /helloworld {
    return 603;
}    
```

测试普通字符串的长短（普通字符串的匹配与顺序无关，与长短有关）。浏览器输入http://localhost/helloworld/test/a.html，返回601。浏览器输入http://localhost/helloworld/a.html，返回602。
```conf
location /helloworld/test/ {        #1
    return 601;
}
        
location /helloworld/ {                #2
    return 602;
}
```

测试正则表达式的顺序（正则匹配与顺序相关）。浏览器输入http://localhost/helloworld/test/a.html，返回602；将#2和#3调换顺序，浏览器输入http://localhost/helloworld/test/a.html，返回603
```conf
location /helloworld/test/ {        #1
    return 601;
}

location ~ /helloworld {            #2
    return 602;
}
        
location ~ /helloworld/test {        #3
    return 603;
}
```

## 参考
- http://www.cnblogs.com/coder-yoyo/p/6346595.html







