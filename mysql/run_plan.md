#### show profiles
```sql
set profiling = 1                 # 开启profile
reset query cache                 # 清除查询缓存
show profiles
show profile for query <query_id> # 查看某个查询sql
```


#### explain
```sql
explain sql
```
查看id,key,rows,type,extra简单说明下:
- id值相同,执行顺序从上往下,id值越大,执行顺序优先级越高
- key表示本次查询用到的索引
- rows表示本次查询扫描过的记录数
- type有all,index,range,ref,eq_ref,const,system,null,由左到右性能越好
    - all全表扫描
    - index只扫描索引树
    - range范围扫描
    - ref非唯一索引扫描
    - eq_ref唯一索引扫描,例如根据主键查询
    - const,system出现在表中只有一行记录时
    - null不需要访问表或索引
- extra
    - using filesort 文件排序
    - using temporary 临时表
    
#### 文件排序(using filesort)
> mysql会根据索引排序,当不能使用索引时,如果数据量小于排序缓存区,直接使用内存快速排序,否则将数据分块,将每个数据块排序结果存放磁盘,最后再合并返回
[mysql排序过程](http://note.youdao.com/noteshare?id=5fff060484622be57c2714e6ed60c7a2)
