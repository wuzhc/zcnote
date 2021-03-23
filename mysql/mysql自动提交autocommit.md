查看当前数据库的隔离级别，默认mysql的隔离级别是可重复读（rr），命令如下：

```bash
show variables like 'autocommit';
```



## 如果mysql关闭autocommit会带来什么问题

关闭自动提交

```bash
set autocommit ='OFF'
```

如果在innodb引擎下，关闭autocommit后，a事务插入一条数据到mysql后，b事务看不到这条数据，需要在a事务执行

```bash
commit
```



## 如果mysql同时开启autocommit，同时业务代码又有begin，那么会怎么样？

如果业务代码有`begin --- commit ----rockback`代码，则业务代码优先级最高，在业务代码没有commit之前，其他事务不会读到他的数据 



