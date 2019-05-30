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

```bash
SQL> select
   sum(case u.sex when 1 then 1 else 0 end)男性,
   sum(case u.sex when 2 then 1 else 0 end)女性,
   sum(case when u.sex <>1 and u.sex<>2 then 1 else 0 end)性别为空
 from users u;
 
        男性         女性       性别为空
---------- ---------- ----------
         2          0

--------------------------------------------------------------------------------
SQL> select
   count(case when u.sex=1 then 1 end)男性,
   count(case when u.sex=2 then 1 end)女,
   count(case when u.sex <>1 and u.sex<>2 then 1 end)性别为空
 from users u;
 
        男性          女       性别为空
---------- ---------- ----------
         2          0
```


### 参考

[[mysql操作查询结果case when then else end用法举例](https://www.cnblogs.com/clphp/p/6256207.html)](https://www.cnblogs.com/clphp/p/6256207.html)



