```sql
# 查看表信息
show table status from met where name="<table>";

# 优化表
optimize table <table>

# 查看表索引
show keys from <table>

# 建立索引
alter table <table> add index <index> (field(len),field2,field3)

# 删除索引
alter table <table> drop index <index>

# 导出整个数据库
mysqldump -u dbuser -p dbname > dbname.sql

# 导出整个数据库结构
mysqldump -u dbuser -p -d --add-drop-table dbname > dbname.sql

# 导出数据库表
mysqldump -u dbuser -p dbname dbtable > dbtable.sql

# 导入sql文件(进到数据库)
use dbname
source dbname.sql

# on duplicate key update 当插入的数据导致唯一索引或主键出现重复值,则执行update,否则执行insert
insert into table(a,b,c) values(1,2,3) on duplicate key update d = c+1
相当于
update table set d = c + 1 where a = 1 or b =2

# 统计每天数据量
select date_format(create_date,'%Y-%m-%d') as oneday,count(*) as total from user group by oneday;

# 统计今天数据量 (to_days返回一个天数)
select count(*) as total from user where to_days(now()) = to_days(create_date)

# 统计7天数据量
select count(*) as total from user where date_sub(curdate(), interval 7 day) < date(create_date)

# 统计上一个数据量
select count(*) as total from user where period_diff(date_format(now(),'%Y-%m'), date_format(create_date, '%Y-%m')) = 1

# 创建表
create table score(
    `id` int(11) auto_increment,
	`name` varchar(225) collate utf8mb4_unicode_ci default null,
    `course` varchar(225) collate utf8mb4_unicode_ci default null,
    `score` float default null,
	primary key (id)
) engine=innodb default charset=utf8;

insert into score(name,course,score) values("张三","语文",20),("张三","数学",30),("张三","英语",50),("李四","语文",70),("李四","数学",60),("李四","英语",90)


create table fund (
	id int(11) unsigned auto_increment,
	code varchar(50) not null comment '指数代码',
	name varchar(225) not null comment '指数名称',
	cur_rate float default 0 comment '当前估值增长率',
	profit float default 0 comment '累计盈利',
	lose float default 0 comment '累计亏本',
	supplement float default 0 comment '累计补仓',
	total_money float default 0 comment '当前持仓金额',
	create_date datetime default null comment '创建时间',
	buy_date datetime default null comment '购买时间',
	sell_date datetime default null comment '卖出时间',
	status tinyint default 0 comment '0正常,1删除',
	primary key (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 comment '基金表'

create table fund_networth (
	id int(11) unsigned auto_increment,
	fund_id int(11) unsigned not null,
	day date not null comment '净值日期',
	value float default 0 comment '单位净值',
	rate float default 0 comment '日增长率',
	status tinyint(1) default 0 comment '0正常,1删除',
	primary key (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 comment '基金历史净值表'


create table fund_day_profit (
	id int(11) unsigned auto_increment,
	fund_id int(11) unsigned not null,
	day date not null comment '收益日期',
	profit float default 0 comment '收益',
	rate float default 0 comment '日增长率',
	money float default 0 comment '计算收益的金额度',
	status tinyint(1) default 0 comment '0正常,1删除',
	primary key (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 comment '基金每天收益表'

create table fund_operation (
	id int(11) unsigned auto_increment,
	fund_id int(11) unsigned not null,
	day date not null comment '操作时间',
	money float default 0 comment '操作金额',
	type tinyint(1) not null comment '1买入,2卖出',
	cur_rate float default 0 comment '当前估值增长率',
	primary key (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 comment '基金操作表'
```
