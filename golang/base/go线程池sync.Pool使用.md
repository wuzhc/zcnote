## 参考
- https://segmentfault.com/a/1190000015464889#articleHeader14

## 大规模Goroutine的瓶颈
- 会对垃圾回收(gc)造成负担,需要频繁的释放内存
- 虽然goroutine只分配2KB,但是大量gorotine会消耗完内存,并且gc也是goroutine调用的

## 原理和作用
原理类似是IO多路复用,就是尽可能复用,池化的核心优势就在于对goroutine的复用。此举首先极大减轻了runtime调度goroutine的压力，其次，便是降低了对内存的消耗  
![https://segmentfault.com/img/remote/1460000015464895?w=1752&h=1170](https://segmentfault.com/img/remote/1460000015464895?w=1752&h=1170)

