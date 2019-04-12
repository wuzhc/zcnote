## python文件编码声明
```python
#！/usr/bin/env python3
# -*-coding: UTF-8 -*-
```
每个python文件首行有`# -*- coding: utf-8 -*-`,没有这个的话,即时注释有中文也会报错;注意:python3已经默认支持中文了，因此如果你的版本是python3不加这句话也是可以的，但是为了程序的可移植性，所以建议在编写程序的时候加上

## 常用命令
```bash
# 查看pip安装哪些模块
pip3 list
```

## zip()函数
zip将多个可迭代对象转换成一个个元组,然后返回一个对象
```python
a = [1,2,3]
b = [4,5,6]
zipped = zip(a,b)
print(zipped)
# <zip object at 0x103abc288> 
print(list(zipped))
# [(1, 4), (2, 5), (3, 6)]
```

## format()格式化字符串
```python
str = '{0},{1},{2}'.format('1','2','3')
```
format的每个位置对应一个`{}`,其中数字对应位置下标,可省略,[参考](http://www.cnblogs.com/Alexzzzz/p/6832253.html%20)
