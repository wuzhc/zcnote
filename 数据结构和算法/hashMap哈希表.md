## 简单描述
![http://p1.pstatp.com/large/pgc-image/91ae8a4e7dc948a8ba9f03350c103812](http://p1.pstatp.com/large/pgc-image/91ae8a4e7dc948a8ba9f03350c103812)
`hashMap`底层结构如上,主要涉及到3个概念,hasn函数+数组+链表,大概流程如下:
- 对于`key-value`,首先对`key`进行hash计算,得到数组下标位置
- 如果数组下标已经存在元素值,即发生哈希碰撞,则键值对就会存储在该数组对应链表的下一个节点上(注意是键值对)
## 考虑问题
- 数组应该有初始化长度,所以会有数组扩容的
- hash函数应该是尽可能的把数据均匀分布到数组上