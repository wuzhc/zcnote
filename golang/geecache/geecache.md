- 内存不够用问题(`FIFO`,`LRU`,`LFU`)
- 并发写入冲突问题(加锁)
- 单机性能问题(分布式)

## 缓存淘汰算法
### FIFO
先入先淘汰,用队列实现
### LFU (Least Frequently Used)
淘汰访问频率低的,需要维护一个按照访问次数排序的队列,每次访问，访问次数加1，队列重新排序，淘汰时选择访问次数最少的即可
问题: 
- 需要维护计数,占内存空间
- 历史数据的影响较大
## LRU (Least Recently Used)
淘汰最近最少访问的,维护一个队列，如果某条记录被访问了，则移动到队尾，那么队首则是最近最少访问的数据，淘汰该条记录即可。
![https://geektutu.com/post/geecache-day1/lru.jpg](https://geektutu.com/post/geecache-day1/lru.jpg)

