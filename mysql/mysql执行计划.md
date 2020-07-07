## 参考
- https://www.cnblogs.com/remember-forget/p/10400496.html

## 连接数过多，cpu过高怎么解决？
- 按链接数最多的客户端排序
```sql
select client_ip,count(client_ip) as client_num from (select substring_index(host,':' ,1) as client_ip from information_schema.processlist ) as connect_info group by client_ip order by client_num desc;
```

- 查看正在执行的线程，并按 Time 倒排序，看看有没有执行时间特别长的线程
```sql
select * from information_schema.processlist where Command != 'Sleep' order by Time desc;
```

- 找出所有执行时间超过 5 分钟的线程，拼凑出 kill 语句，方便后面查杀 （此处 5分钟 可根据自己的需要调整SQL标红处）
```sql
select concat('kill ', id, ';') from information_schema.processlist where Command != 'Sleep' and Time > 300 order by Time desc;
```

## show processlist
显示了有哪些线程在运行，不仅可以查看当前所有的连接数，还可以查看当前的连接状态帮助识别出有问题的查询语句等

## show profiles
```sql
set profiling = 1                 # 开启profile
reset query cache                 # 清除查询缓存
show profiles
show profile for query query_id   # 查看某个查询sql
```

## explain
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
