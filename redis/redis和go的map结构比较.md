## 参考
- https://www.cnblogs.com/neooelric/p/9621736.html
- https://www.bookstack.cn/read/qcrao-Go-Questions/map-map%20%E7%9A%84%E9%81%8D%E5%8E%86%E8%BF%87%E7%A8%8B%E6%98%AF%E6%80%8E%E6%A0%B7%E7%9A%84.md

## redis
![https://static.bookstack.cn/projects/qcrao-Go-Questions/269a7b4dee91ccf106430ee522d6ef6a.png](https://static.bookstack.cn/projects/qcrao-Go-Questions/269a7b4dee91ccf106430ee522d6ef6a.png)
dict因为要rehash，所以和go一样，有两个hash表，分别为`ht0`,`ht1`,另外还需要记录rehash的进度
```
dict  ->  type  ->  dictType
   ->  ht[0]  -> dictht
   ->  ht[1]  ->  dictht  ->  table  ->  dictEntry  ->  k
   								 -> v
   								 -> next
```

redis扩容过程中，如果遍历，会暂停迁移，直到迭代器结束，这是为了保证在迭代起始时, 字典中持有的所有结点都会被遍历到

## golang
![https://images2018.cnblogs.com/blog/668722/201809/668722-20180910184019522-1324296109.png](https://images2018.cnblogs.com/blog/668722/201809/668722-20180910184019522-1324296109.png)
go的map底层主要是一个`hmap`结构，`hmap`结构有一个指向`bmap`的数组的指针，每一个`bmap`即一个`bucket`,桶里面最多装8个key，key经过hash之后，低5位决定key所在哪个bucket，高8位决定key落在bucket哪个位置


