## 查看数据库binlog已经写到哪个位置
```mysql
show binary logs ;
show binlog events in 'mysql-bin.000003' \G;
show binlog events in 'mysql-bin.000003' from 13788906 limit 1,10;
```

## 修改canal.conf.example.meta.dat
如下修改journalName，position
```json
{"clientDatas":[{"clientIdentity":{"clientId":1001,"destination":"example","filter":"wkwke.tbAnswer"},"cursor":{"identity":{"slaveId":-1,"sourceAddress":{"address":"localhost","port":3306}},"postion":{"gtid":"","included":false,"journalName":"mysql-bin.000003","position":13788906,"serverId":1,"timestamp":1584689464000}}}],"destination":"example"}
```

