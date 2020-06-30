## 参考
https://www.cnblogs.com/yanghuahui/p/3697996.html

## lua脚本的好处
- 原子操作，Redis会将整个脚本作为一个整体执行，中间不会被其他命令插入
- 


将访问频率限制为每10秒最多3次
```lua
local times = redis.call('incr',KEYS[1])

if times == 1 then
    redis.call('expire',KEYS[1], ARGV[1])
end

if times > tonumber(ARGV[2]) then
    return 0
end
return 1
```

执行：
```bash
redis-cli --eval ratelimiting.lua rate.limitingl:127.0.0.1 , 10 3
```
- --eval参数是告诉redis-cli读取并运行后面的Lua脚本
- ratelimiting.lua是脚本的位置，后面跟着是传给Lua脚本的参数
- `","`前的rate.limiting:127.0.0.1是要操作的键，可以再脚本中用KEYS[1]获取，`","`后面的10和3是参数
- 注：","两边的空格不能省略，否则会出错