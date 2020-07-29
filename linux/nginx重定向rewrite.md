```bash
server {　　　　　　　　　　　　　　　　　　　　　　　　
    listen     80;
    server_name  baidu.com;
    rewrite ^/(.*) https://www.baidu.com/$1 permanent; #匹配成功跳转到百度
}
```
- `\` 转义字符
- `( )` 用于匹配括号之间的内容，通过`$1`、`$2`调用

## rewrite最后一项flag参数
- last 如果没有匹配到，会继续向下匹配
- break 如果没有匹配到，则不再向下匹配，直接返回结果404
- redirect 返回302临时重定向
- permanent 返回301永久重定向

## break和last的区别
- break一般用于接口重定向
- last用于请求路径发生改变的常规需求
- break表示重写后停止不再匹配
- last表示重写后会再次匹配