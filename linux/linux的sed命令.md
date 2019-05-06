## 参考
- https://www.cnblogs.com/ginvip/p/6376049.html

> sed 编辑器没有破坏性，它不会修改文件, sed 把当前正在处理的行保存在一个临时缓存区中，这个缓存区称为模式空间或临时缓冲
sed 修改的是临时缓存区的副本,不会修改源文件,如果需要修改源文件,加上选项`-i`

## 格式
```bash
sed [-nefri] 命令 输入文本
```

## 选项
- -i 表示直接修改内容,而不是输出到屏幕
- -n 表示只显示sed操作的行,否则会重复打印行,-n取消默认打印

## 命令
- a 在当前行追加新一行
- i 在当前行前插入新一行
- c 取代n1,n2之间的行
- d 删除
- s 正则替换
- p 打印

## 模式
### first~step
从first行起,每隔step行输出
```bash
sed -n 2~5p filename
```

### & 保存结果
```bash
sed s/love/**&**/
```
love 变成**love**

### s 正则替换
```bash
# g表示全局替换
sed s/正则表达式/被替换内容/g filename
```

### 对匹配结果的引用
```bash
sed s/\(wuzhc\)/\1hello filename
```
一个括号一个引用,例如wuzhc对应`\1`

## 案例
```bash
# 删除最后一行
# -i 表示直接修改内容,而不是输出到屏幕,不加-i则只是删除缓存区的内容,原内容没有被修改
sed -i '$d' filename
# 删除2到最后一行
sed -i '2,$d' filename
# 删除包含north的行
sed -i '/north/d' filename

# 打印2到最后一行
# -n 表示只显示sed操作的行,否则会重复打印行,-n取消默认打印
sed -n '2,$p' filename
# 打印包含vivo的行
sed -n '/vivo/p' filename

# 从1到5行替换vivo为huawei,并输出被替换的行
# -n和p配合可以输出sed操作的行
# s正则匹配替换
sed -n '1,5s/vivo/huawei/gp' filename

# 所有数字结尾的数字加上0.5
# &保存匹配结果
sed 's/[0-9][0-9]$/&.5/' ceshi.txt

# 替换wu为wuzhc
sed -n 's/\(wu\)/\1zhc/p' filename

# 在north开头各行后追加hellow world
sed '/^north/a Hello world!' ceshi.txt 
```
