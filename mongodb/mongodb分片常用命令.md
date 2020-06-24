```bash
#为数据库启用分片
sh.enableSharding("db")

#使用hash分片某个集合（test数据库中的users集合，username是文档中的key）
sh.shardCollection("test.users",{username:"hashed"})

#插入1w数据
for (var i = 1; i <= 1000; i++) { db.users.insert({username: "name" + i}) }

#唯一索引
db.users.ensureIndex({"username":1},{"unique":true})

#查看分片状态
sh.status()

#增加分片
sh.addShard("IP:Port")

#删除分片
db.runCommand({"removeshard":"mab"})   #删除mab分片
	
#查看各分片状态
mongostat --discover


```