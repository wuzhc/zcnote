### 格式：

```mysql
case sex
	when '1' then '男'
	when '2' then '女'
else
	'其他'
end
# 或者
case when sex = '1' then '男'
	when sex = '2' then '女'
else
	'其他'
end
```



### 参考

[[mysql操作查询结果case when then else end用法举例](https://www.cnblogs.com/clphp/p/6256207.html)](https://www.cnblogs.com/clphp/p/6256207.html)



