# go垃圾回收gc机制
> 对不再使用的内存资源进行自动回收的功能就被称为垃圾回收,golang的gc回收主要基于标记-清扫的算法,在此基础进行了改进

## 参考
- https://studygolang.com/articles/27243?fr=sidebar
- https://www.jb51.net/article/157744.htm
- https://studygolang.com/articles/21840?fr=sidebar



## 标记清除
- 标记可达到对象
- 清除没有标记的对象
### 缺点:
- STW，stop the world；让程序暂停，程序出现卡顿。
- 标记需要扫描整个heap
- 清除数据会产生heap碎片
针对`STW`问题,golang使用三色标记法



## 三色标记法
- 首先所有的对象都标记为白色
- 扫描可到达对象,标记为灰色
- 从灰色对象中找到它引用对象标记为灰色,同时将灰色对象标记为黑色
- 循环步骤3，直到没有灰色对象
- 步骤4结束后，白色集合中的对象就是不可达对象，也就是垃圾，进行回收
- 最后重新将黑色对象标记为白色,进行下一轮操作
![https://segmentfault.com/img/remote/1460000018161591](https://segmentfault.com/img/remote/1460000018161591)

三色标记法主要解决了`STW`问题, 可以让用户程序和标记并发的进行,但是这就意味着用户可以随时修改对象,解决的方式是`写屏障`



## 写屏障
- 如果不碰触黑色对象,只清除白色对象,不会影响程序,但是如果涉及到黑色对象操作(改变它的引用),这就需要写屏障,写屏障是当gc一旦开始，无论是创建对象还是对象的引用改变，都会先变为灰色。防止对象丢失
- 清除阶段,不需要开启写屏障



## gc带来的问题
开启写屏障,回收器就会开始进入都标记阶段。回收器第一件做的事情就是拿走25%的可用CPU给自己使用,也就是它会从应用程序抢过来对应数量的P和M



## gc触发时机
- 手动触发`runtime.GC()`，会阻塞程序指定gc完成
- 内存大小阈值， 内存达到上次gc后的2倍
- 达到定时时间 ，2m interval
但是，如果Go运行时一段时间（通常约5分钟）不使用，它将把内存返回给OS。
如果在此期间内存使用量增加（并且有选择地再次缩小），则很有可能不会将内存返回给操作系统。
debug.FreeOSMemory
在经过几次ForceGC和scavenge后，才会释放内存给操作系统。 尝试过多次，基本在15分钟左右。
https://www.jianshu.com/p/f807373ad681
`GODEBUG=madvdontneed=1 go run main.go`


##  如何减少垃圾
[https://www.cnblogs.com/shanyou/p/4296181.html](https://www.cnblogs.com/shanyou/p/4296181.html)
- 避免把[]byte 转化为字符串类型
- 重复使用缓存或者对象（有时也许是sync.Pool又称为issue4720）
- 预分配切片（特别是make的能力）并总是知晓链中各个条目的数量和大小
- 





