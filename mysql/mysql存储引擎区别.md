- 锁粒度不同
    - myisam表锁,innodb行锁和表锁(innodb在走索引的时候才会使用行锁,否则用表锁),并发上innodb优于myisam
- 全文搜索
    - myisam支持全文搜索(其实有很多搜索引擎可以替代,如Sphinx和Elasticsearch),innodb不支持
- 事务支持
    - myisam不支持,innodb支持
- 底层索引
    - myisam索引btree上的节点是一个指向数据物理位置的指针，而innodb索引节点存的数据的主键，所以需要根据主键做二次查找,查询速度上myisam优于innodb

