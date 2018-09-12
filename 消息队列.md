关于队列可以参考我博客一篇的文章, [Redis 实现队列](https://segmentfault.com/a/1190000011084493)

这里主要说下多个消费者管理问题.  
- 采用swoole多进程管理多个worker消费者,worker消费者可以分为两类,一种是静态worker,静态worker退出后会重启,一个队列会保持固定数量的静态worker;另一种是动态worker,只有当队列积压过多任务数,会动态新增worker缓解压力,当动态worker处理完任务后退出不重启;  
- 每个worker可以设置worker最大执行时间,最大执行任务数,这样的好处是防止worker内存溢出;  
- 当然不要开太多进程,进程切换开销很大的;
- 可以参考我的框架[zcswoole消息队列](https://www.kancloud.cn/wuzhc/zcswoole/742975)
