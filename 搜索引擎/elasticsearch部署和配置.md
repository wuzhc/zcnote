## docker启动
```bash
docker run --name=testes -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" es6.5.4-wuzhc

docker run -e ES_JAVA_OPTS="-Xms256m -Xmx256m" -e "discovery.type=" -p 9200:9200 -p 9300:9300 -v /data/wwwroot/elk/es/es01.yml:/usr/share/elasticsearch/config/elasticsearch.yml -v /data/wwwroot/elk/es/data01:/usr/share/elasticsearch/data --name es01 es6.5.4-wuzhc

docker run -e ES_JAVA_OPTS="-Xms256m -Xmx256m"  -e "discovery.type="  -p 9201:9201 -p 9301:9301 -v /data/wwwroot/elk/es/es02.yml:/usr/share/elasticsearch/config/elasticsearch.yml -v /data/wwwroot/elk/es/data02:/usr/share/elasticsearch/data --name es02 es6.5.4-wuzhc

docker run -e ES_JAVA_OPTS="-Xms256m -Xmx256m"  -e "discovery.type=" -p 9202:9202 -p 9302:9302 -v /data/wwwroot/elk/es/es03.yml:/usr/share/elasticsearch/config/elasticsearch.yml -v /data/wwwroot/elk/es/data03:/usr/share/elasticsearch/data --name es03 es6.5.4-wuzhc


docker run --name=kibana6.5.4 --link testes:elasticsearch -p 5601:5601 docker.elastic.co/kibana/kibana:6.5.4
```

## logstash采集数据
### docker运行
https://blog.csdn.net/qq_33547169/article/details/86629261
```bash
docker run --name=logstash6.5.4 -p 5044:5044 -p 9600:9600 -v /data/wwwroot/elk/logstash/config/:/usr/share/logstash/config/  docker.elastic.co/logstash/logstash:6.5.4
```

### 配置文件
https://www.cnblogs.com/licongyu/p/5383334.html
- pipelines.yml
```bash
- pipeline.id: main
  path.config: "/usr/share/logstash/config/logstash.conf"
  pipeline.workers: 3
```
- logstash.conf
从文件采集数据
```bash
input {
  file {
    path => [ "/usr/share/logstash/config/xxx.log" ]  #文件路径
    exclude => "/var/log/*.gz"  #排除不需要监听的文件
    type => "system"  #自定义事件的类型，可用于后续的条件判断
    add_field => {"key" => "test"}  #自定义新增字段
    start_position => "beginning"  #从日志文件头部读取，相反还有end
  }
}

output {
  stdout {
    codec => rubydebug
  }
}
```
从数据采集数据
```bash
input {
	stdin { }
	jdbc {
		#填写你的mysql链接串8以后驱动必须这样写，不然后出错，这个问题我搞了好几天才解决 {host}:3306/{database}
		jdbc_connection_string => "jdbc:mysql://192.168.1.102:3306/wkwke?characterEncoding=utf8&useSSL=false&serverTimezone=UTC&rewriteBatchedStatements=true"
		#链接数据库用户名称
		jdbc_user => "elasticsearch"
		#链接数据库的密码
		jdbc_password => "123456"
		#指定驱动的位置
		jdbc_driver_library => "/usr/share/logstash/config/mysql-connector-java-8.0.12.jar"
		#最新的mysql驱动写法，写以前的驱动会报错
		jdbc_driver_class => "com.mysql.cj.jdbc.Driver"
		jdbc_paging_enabled => "true"
		jdbc_page_size => "5000"
		jdbc_fetch_size => "5000"
		#同步的表，这里也可以只想一个写了sql的文件,一定不要用select *
		statement => "SELECT id,fdName,fdType,fdCreate,fdCreater from tbAssignment where id > :sql_last_value"
		clean_run => false #退出脚本
		lowercase_column_names => false
		#是否记录上次结果，如果为真,将会把上次执行到的 tracking_column 字段的值记录下来,保存到 last_run_metadata_path 指定的文件中
		record_last_run => true 
		#保存上次结果的field
		tracking_column => "id"
		#是否需要记录某个column 的值,如果 record_last_run 为真,可以自定义我们需要 track 的 column 名称，此时该参数就要为 true. 否则默认 track 的是 timestamp 的值.
        use_column_value => true
        #保存上次结果的文件
        last_run_metadata_path => "/usr/share/logstash/config/kt_assignment_id.log"
        #statement_filepath => "/usr/share/logstash/config/kt_assignment.sql"
		#表示每分钟都同步数据
		#schedule => 分 时 天 月 年  
		#schedule => *  22  *  *  *     //will execute at 22:00 every day
		schedule => "* * * * *"
	}
}
filter {
	date {
		# 有多个项的话能匹配多个不同的格式
		match => [ "fdCreate", "MMM dd yyyy HH:mm:ss","ISO8601" ]
		target => "fieldName1"
		timezone => "Asia/Shanghai"
	}
}

output {
	stdout {
		codec => json_lines
	}

	elasticsearch {
		#数据到es
		hosts => "192.168.1.102:9200"
		#指定索引，名字任意
		index => "kt_assignment"
		#指定类型，任意
		document_type => "messagedata"
		document_id => "%{id}"
		template_overwrite => true
		#模板中的template名需要和output中的索引名一致，template可以使用*配置任意字符。
		#template => "mysqltoes-template.json"
	}
}
```

### logstash出现的问题
```
:exception=>#<Sequel::DatabaseError: Java::JavaSql::SQLException: Zero date value prohibited>
```

## 集群部署
https://www.cnblogs.com/ming-blogs/p/11001282.html
es内部使用 分片机制、集群发现、分片负载均衡请求路由
- 每个索引会有多个分片
- Shards 分片,分片的数量只能在索引创建前指定，并且索引创建后不能更改
- 索引副本,一是提高系统的容错性,二是提高es的查询效率
- 主分片一旦确定后不能修改，而副分片可以
- 一个主分片对应一个副分片
- es在有节点加入或退出时会根据机器的负载对索引分片进行重新分配，挂掉的节点重新启动时也会进行数据恢复

## mapping
https://www.jianshu.com/p/c5016b78a284


