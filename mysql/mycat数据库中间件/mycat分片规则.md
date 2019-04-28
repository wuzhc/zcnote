## 链接
- [Mycat水平拆分之十种分片规则](https://www.cnblogs.com/756623607-zhang/p/6656022.html)
- [MYCAT操作MYSQL示例之E-R表](https://www.cnblogs.com/z-qinfeng/p/9726707.html)

## ER join
表分组（Table Group）是解决跨分片数据 join 的一种很好的思路，也是数据切分规划的重要一条规则。
```xml
<table name="customer" primaryKey="ID" dataNode="dn1,dn2,dn3" rule="sharding-by-intfile">
		   <childTable name="orders" primaryKey="ID" joinKey="customer_id" parentKey="id">
		     <childTable name="order_items" joinKey="order_id" parentKey="id" /> </childTable>
		   <childTable name="customer_addr" primaryKey="ID" joinKey="customer_id" parentKey="id" />
		 </table>
```

这样子插入记录包括子记录会被分配到同一个节点dataNode

## Share join
跨分片join,目前支持两个表join,原理解析sql,拆分单表的sql语句执行,然后把各个节点的数据汇集

## 枚举分片
```java
默认节点的作用：枚举分片时，如果碰到不识别的枚举值，就让它路由到默认节点
	 *                如果不配置默认节点（defaultNode值小于0表示不配置默认节点），碰到
	 *                不识别的枚举值就会报错，
```


