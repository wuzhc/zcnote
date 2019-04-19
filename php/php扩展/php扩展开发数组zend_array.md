### 结构体
#### zend_array
```c
// HashTable为zend_array的别名
typedef struct _zend_array HashTable;

// zend_array结构体
struct _zend_array {
    zend_refcounted_h gc; // 引用计数
    union {
        struct {
            ZEND_ENDIAN_LOHI_4(
                zend_uchar    flags,        // 例如，HASH_FLAG_PACKED是否为packed array，HASH_FLAG_INITIALIZED是否初始化数组
                zend_uchar    nApplyCount,
                zend_uchar    nIteratorsCount,
                zend_uchar    consistency)
        } v;
        uint32_t flags; 
    } u;
    uint32_t          nTableMask;       // 用于计算索引，例如 nIndex = h | ht->nTableMask （nTableMask是一个负值，packed array默认为-2，hash array为-8）
    Bucket            *arData;          // bucket数组
    uint32_t          nNumUsed;         // 已用bucket数
    uint32_t          nNumOfElements;   // 已有元素数，nNumOfElements <= nNumUsed，因为删除的并不是直接从arData中移除
    uint32_t          nTableSize;       // 数组的大小，为2^n
    uint32_t          nInternalPointer; // 数值索引
    zend_long         nNextFreeElement; 
    dtor_func_t       pDestructor;
};
```
数组使用哈希表(hashTable)来实现，哈希表即通过key-value访问数据，这里的key是直接映射到内存地址，也就是说根据key可以直接获得保存在内存的值（这种方式称寻址技术）；  
数组的元素存在Bucket结构：
```c
//Bucket：散列表中存储的元素
typedef struct _Bucket {
    zval             val;  // 存储的具体value，这里嵌入了一个zval，而不是一个指针
    zend_ulong       h;    // key根据times 33计算得到的哈希值，或者是数值索引编号
    zend_string      *key; // 存储元素的key
} Bucket;
```

### packed array和hash array
&emsp;&emsp;packed array不需要索引表，空间和效率上优于hash array
- packed array可以简单理解为数字索引数组（事实上数字索引是有序的，并且不能间隔太大，否则为转为hash array）
- hash array可以理解为关联数组

### 哈希冲突
&emsp;&emsp;即不同的bucket.key经过哈希函数得到相同的值(key通过zend_string_hash_val(key)可以计算h的值)，但这些值需要同时插入nIndex数组，
但出现冲突时将原有的arData[nIndex]的位置信息存储到新插入的value的zval.u2.next中,再将新value的存储地址更新到索引数组

### 数组操作API
- zend_hash_init 数组初始化，设定zend_array初始值
- zend_hash_index_insert 
- zend_hash_find 
- zend_hash_add_new 插入uninitialized_zval到zend_array
- zend_hash_packed_to_hash packed array转为hash array
- zend_hash_rehash 生成新的HashTable（删除标识为IS_UNDF的数据，有效数据重新聚合并更新插入索引表）
- zend_hash_del 删除，不会真正删除，只是标识，如zval.u1.v.type为IS_UNDF，只有在扩容或重建时才触发删除，

- zend_hash_xxx 插入或更新字符串key，key指向zend_string的指针
- zend_hash_str_xxx 插入或更新字符串key,key执行char的指针，需要len表示字符串长度
- zend_has_index_xxx 插入或更新数字key
