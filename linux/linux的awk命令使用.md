-F参数：指定分隔符，可指定一个或多个

指定`空格`和`：`两个分隔符

```bash
awk -F '[ :]' '{print NF}' access.log
```



NR参数：文件行数

NF参数：字段数量

获取test.txt文件第20到30行的记录

```bash
awk '{if(NR>=20 && NR<=30) print $1}' test.txt  
```