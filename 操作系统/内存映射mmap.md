## 1. 文件系统inode
http://www.ruanyifeng.com/blog/2011/12/inode.html
`inode`是理解`linux/uinx`文件系统和硬盘存储的基础

### 1.1 扇区和块
文件存储在硬盘,硬盘最小单位叫扇区`sector`,每个扇区存储512字节,相当于0.5k,多个扇区组成一个块`block`,块是文件存储的最小单位,最常见的块为4k,相当于一个页的大小,即八个连续的扇区组成一个块

### 1.2 inode存储文件元信息
文件数据存储在块中,文件的元数据存(文件大小,作者等等)储在`inode`上,中文译名为索引节点,可以通过`stat filename`查看`inode`结构:
```bash
  文件：db1.sql
  大小：9646      	块：24         IO 块：4096   普通文件
设备：803h/2051d	Inode：10493341    硬链接：1
权限：(0644/-rw-r--r--)  Uid：( 1000/   wuzhc)   Gid：( 1000/   wuzhc)
最近访问：2019-04-25 13:46:18.017133344 +0800
最近更改：2019-04-25 13:45:50.968977076 +0800
最近改动：2019-04-25 13:45:50.968977076 +0800
创建时间：-
```

### 1.3 通过inode读取文件内容
每个`inode`大小一般为128或256字节,每个`inode`有自己的号码,操作系统通过号码来识别不用的文件,可以通过`ls -i filename`查看`inode`号码;`Linux/uinx`系统是通过`inode`号码来读取文件信息的,如下:
- 通过文件名找到`inode`号码
- 通过`inode`号码获取`inode`信息
- 通过`inode`信息找到文件数据所在的`block`

### 1.4 目录文件
目录文件是包含一系列目录项的列表,每个目录项包括`inode`编号和文件名,可以通过`ls -i`查看

### 1.5 硬链接和软连接
`inode`有一个链接数,该数等于指向`inode`文件名总数
- 硬链接,`ln 源文件 目标文件`,多个文件名指向同一个`inode`编号,删除目标文件`inode`链接数减一
- 软连接,`ln -s 源文件 目标文件`,创建的文件只是包含源文件的路径,删除目标文件`inode`链接数不会收到影响


## 2. 内存映射
https://blog.csdn.net/MakeContral/article/details/85170752
https://blog.csdn.net/carson_ho/article/details/87685001

### 2.1 进程虚拟地址空间
![https://img-blog.csdnimg.cn/20181221194626178.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L01ha2VDb250cmFs,size_16,color_FFFFFF,t_70](https://img-blog.csdnimg.cn/20181221194626178.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L01ha2VDb250cmFs,size_16,color_FFFFFF,t_70)

### 2.2 内存映射的作用
- 多个进程共享内存
- 提高读写性能,减少io次数
	- 例如普通的读操作是,程序发起`read`系统调用,切换到内核态,通过`inode`找到数据块加载到页缓存,再从页缓存拷贝到用户态的buffer缓冲区
	- mmap是直接可以操作页缓存的数据,减少一次io

![https://imgconvert.csdnimg.cn/aHR0cHM6Ly9pbWdjb252ZXJ0LmNzZG5pbWcuY24vYUhSMGNEb3ZMM1Z3Ykc5aFpDMXBiV0ZuWlhNdWFtbGhibk5vZFM1cGJ5OTFjR3h2WVdSZmFXMWhaMlZ6THprME5ETTJOUzFqTWpZd05XWTNZbUkzT1dJd09EWTFMbkJ1Wnc](https://imgconvert.csdnimg.cn/aHR0cHM6Ly9pbWdjb252ZXJ0LmNzZG5pbWcuY24vYUhSMGNEb3ZMM1Z3Ykc5aFpDMXBiV0ZuWlhNdWFtbGhibk5vZFM1cGJ5OTFjR3h2WVdSZmFXMWhaMlZ6THprME5ETTJOUzFqTWpZd05XWTNZbUkzT1dJd09EWTFMbkJ1Wnc)

## 2.3 mmap映射过程
- 创建虚拟内存区域
	- 进程在用户空间调用系统函数`mmap`,原型为`void *mmap(void *start, size_t length, int prot, int flags, int fd, off_t offset);`
	- 在当前进程寻找一段空闲的,且满足需求的连续虚拟地址,是在栈和堆之间那部分
	- 为这块虚拟区域分配`vm_area_struct`结构并初始化
	- 将`vm_area_struct`添加到链表中
- 映射文件
	- 内核mmap函数通过虚拟文件系统inode模块定位到文件磁盘物理地址
	- 通过`remap_pfn_range`建立页表,即实现了文件地址和虚拟地址区域的映射关系,此时文件数据没有被加载到虚拟内存区域中
- 进程访问映射空间,引发页中断,实现文件内容到物理内存（主存）的拷贝
![https://imgconvert.csdnimg.cn/aHR0cHM6Ly9pbWdjb252ZXJ0LmNzZG5pbWcuY24vYUhSMGNEb3ZMM1Z3Ykc5aFpDMXBiV0ZuWlhNdWFtbGhibk5vZFM1cGJ5OTFjR3h2WVdSZmFXMWhaMlZ6THprME5ETTJOUzAzWmpCak5tTXlNMkppTTJReFkySTVMbkJ1Wnc](https://imgconvert.csdnimg.cn/aHR0cHM6Ly9pbWdjb252ZXJ0LmNzZG5pbWcuY24vYUhSMGNEb3ZMM1Z3Ykc5aFpDMXBiV0ZuWlhNdWFtbGhibk5vZFM1cGJ5OTFjR3h2WVdSZmFXMWhaMlZ6THprME5ETTJOUzAzWmpCak5tTXlNMkppTTJReFkySTVMbkJ1Wnc)


### 2.4 mmap映射虚拟内存区域需要和物理页大小对齐
- 一个文件的大小是5000字节，mmap函数从一个文件的起始位置开始，映射5000字节到虚拟内存中
![https://img-blog.csdnimg.cn/20181221194650792.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L01ha2VDb250cmFs,size_16,color_FFFFFF,t_70](https://img-blog.csdnimg.cn/20181221194650792.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L01ha2VDb250cmFs,size_16,color_FFFFFF,t_70)

- 一个文件的大小是5000字节，mmap函数从一个文件的起始位置开始，映射15000字节到虚拟内存中，即映射大小超过了原始文件的大小。
![https://img-blog.csdnimg.cn/2018122119470064.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L01ha2VDb250cmFs,size_16,color_FFFFFF,t_70](https://img-blog.csdnimg.cn/2018122119470064.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L01ha2VDb250cmFs,size_16,color_FFFFFF,t_70)


进程的虚拟地址空间
每个进程使用虚拟内存地址来隔离又共享物理内存,代码获取的是虚拟地址空间
读取文件,文件会被读到内存的`page inode`, 然后再从`page cache`拷贝到应用层的读缓存`buffer`中
内核维护`inode`,成员`struct address_space *i_mapping`
将磁盘文件映射到各自的进程虚拟地址空间
mmap映射的虚拟地址长度需要对齐到物理页大小