变量名zval,变量值zend_value,如php脚本声明一个变量时，会创建一个zval；对变量赋值是保存在zend_value上；
另外php7的引用计数是在zend_value,而不是zval

### zval结构：   
```c
//zend_types.h
typedef struct _zval_struct zval; // zval是struct _zval_struct结构体的别名

struct _zval_struct {
    zend_value        value; // 变量实际的值
    union {
        struct {
            ZEND_ENDIAN_LOHI_4(             //这个是为了兼容大小字节序，小字节序就是下面的顺序，大字节序则下面4个顺序翻转
                zend_uchar    type,         //变量类型
                zend_uchar    type_flags,   //类型掩码，不同的类型会有不同的几种属性，内存管理会用到
                zend_uchar    const_flags,
                zend_uchar    reserved)     //call info，zend执行流程会用到
        } v;
        uint32_t type_info; //上面4个值的组合值，可以直接根据type_info取到4个对应位置的值
    } u1; // 通过zval.u1.type可知知道变量类型
    union {
        uint32_t     var_flags;
        uint32_t     next;                 //哈希表中解决哈希冲突时用到
        uint32_t     cache_slot;           /* literal cache slot */
        uint32_t     lineno;               /* line number (for ast nodes) */
        uint32_t     num_args;             /* arguments number for EX(This) */
        uint32_t     fe_pos;               /* foreach position */
        uint32_t     fe_iter_idx;          /* foreach iterator index */
    } u2; //一些辅助值
};
```

### zend_value结构：
```c
typedef union _zend_value {
    zend_long         lval;    //int整形
    double            dval;    //浮点型
    zend_refcounted  *counted;
    zend_string      *str;     //string字符串
    zend_array       *arr;     //array数组
    zend_object      *obj;     //object对象
    zend_resource    *res;     //resource资源类型
    zend_reference   *ref;     //引用类型，通过&$var_name定义的
    zend_ast_ref     *ast;     //下面几个都是内核使用的value
    zval             *zv;
    void             *ptr;
    zend_class_entry *ce;
    zend_function    *func;
    struct {
        uint32_t w1;
        uint32_t w2;
    } ww;
} zend_value;
```
由zend_value可以看到，类型zend_long和double是直接保存值，而其他类型是保存一个指向各自结构的指针，以下是各种类型的结构：
#### 字符串 zend_string
```c
struct _zend_string {
    zend_refcounted_h gc;
    zend_ulong        h;                /* hash value */
    size_t            len;
    char              val;
};
```

#### 数组 zend_array
```c
typedef struct _zend_array HashTable;

struct _zend_array {
    zend_refcounted_h gc; //引用计数信息，与字符串相同
    union {
        struct {
            ZEND_ENDIAN_LOHI_4(
                zend_uchar    flags,
                zend_uchar    nApplyCount,
                zend_uchar    nIteratorsCount,
                zend_uchar    consistency)
        } v;
        uint32_t flags;
    } u;
    uint32_t          nTableMask; //计算bucket索引时的掩码
    Bucket            *arData; //bucket数组
    uint32_t          nNumUsed; //已用bucket数
    uint32_t          nNumOfElements; //已有元素数，nNumOfElements <= nNumUsed，因为删除的并不是直接从arData中移除
    uint32_t          nTableSize; //数组的大小，为2^n
    uint32_t          nInternalPointer; //数值索引
    zend_long         nNextFreeElement;
    dtor_func_t       pDestructor;
};
```
数组使用哈希表(hashTable)来实现，哈希表即通过key-value访问数据，这里的key是直接映射到内存地址，也就是说根据key可以直接获得保存在内存的值（这种方式称寻址技术）；  
数组的元素存在Bucket结构：
```c
//Bucket：散列表中存储的元素
typedef struct _Bucket {
    zval             val; //存储的具体value，这里嵌入了一个zval，而不是一个指针
    zend_ulong       h;   //key根据times 33计算得到的哈希值，或者是数值索引编号
    zend_string      *key; //存储元素的key
} Bucket;
```

#### 对象 zend_object
```c
struct _zend_object {
    zend_refcounted_h gc;
    uint32_t          handle;
    zend_class_entry *ce; //对象对应的class类
    const zend_object_handlers *handlers;
    HashTable        *properties; //对象属性哈希表
    zval              properties_table[1];
};
```

#### 资源 zend_resource
```c
struct _zend_resource {
    zend_refcounted_h gc;
    int               handle;
    int               type;
    void             *ptr;
};
```

#### 引用 zend_reference
```c
struct _zend_reference {
    zend_refcounted_h gc;
    zval              val;
};
```
&首先会创建一个zend_reference结构，其内嵌了一个zval，这个zval的value指向原来zval的value(如果是布尔、整形、浮点则直接复制原来的值)，然后将原zval的类型修改为IS_REFERENCE，原zval的value指向新创建的zend_reference结构。
![](https://box.kancloud.cn/33e9979a33b867db50af8c9db3060235_590x141.png)

### 参考：
- 《PHP7内核剖析》
- 《PHP7底层设计和源码分析》









#define ZVAL_DEREF(z) do {								\
		if (UNEXPECTED(Z_ISREF_P(z))) {					\
			(z) = Z_REFVAL_P(z);						\
		}												\
	} while (0)
	
	
do {
    if (__builtin_expect(!!(z->u1.v.type == IS_REFERENCE), 0)) {
        z = &((*z).value.ref->val)
    }
}