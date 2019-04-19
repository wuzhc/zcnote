## 1. 配置文件
- server.xml
- rule.xml
- shema.xml 
修改配置文件之后,需要重启`mycat`或者9066端口reload

### 1.1 shema.xml
schema.xml 文件一共有四个配置节点：DataHost、DataNode、Schema、Table。
- dataHost 定义数据库实例
- dataNode 定义数据库名称 (真实存在的数据库)
- schema 定义逻辑库 (数据库中间件可以看做是一个或多个数据库集群构成的逻辑库)
- table 定义逻辑表

#### 1.1.1 定义逻辑库和逻辑表
schema标签用来定义一个逻辑库,table标签用来定义一个逻辑表如下:
```xml
<!-- 定义一个逻辑库 -->
<schema name="food" checkSQLschema="false" sqlMaxLimit="100">
	<!-- 定义一个逻辑表,逻辑表肯定有所属的数据库,所以要指定dataNode -->
	<!-- rule指定了规则名,规则名在rule.xml定义,需要和tableRule标签的name属性值一致 -->
	<table name="article" dataNode="dn1,dn2,dn3" rule="auto-sharding-long" type="global"/>
	<!-- type指定全局表,全局表不需要定义rule,全局表查询时候只从一个节点上执行,插入的时候每个节点都会插入 -->
	<table name="question" dataNode="dn1,dn2,dn3" type="global"/>
</schema>
```
- checkSQLschema 为false自动删除schema
- sqlMaxLimit 自动为`select sql`语句添加`limit 100`

### 2.1 server.xml
server.xml定义了连接mycat的用户和密码,已经用户有操作哪些逻辑库的权限

#### 2.1.1 定义用户,并且指定可以操作哪些逻辑库
```xml
<user name="root">
		<property name="password">123456</property>
		<property name="schemas">TESTDB,food</property> <!-- 多个逻辑库逗号隔开 -->
</user>
```

## 设置环境变量
```bash
vi /etc/profile
# MYCAT_HOST=/opt/mycat
source /etc/profile 
```