# yii2数据库迁移
## 1. 创建迁移
```bash
yii migrate/create <name>
```

### 1.1 添加字段
```bash
yii migrate/create add_position_to_post --fields="position:integer"
```
以上会生成如下：
```php
class m150811_220037_add_position_to_post extends Migration
{
    public function up()
    {
        $this->addColumn('post', 'position', $this->integer());
    }
    public function down()
    {
        $this->dropColumn('post', 'position');
    }
}
```
更多字段使用如下命令：
```bash
yii migrate/create add_xxx_column_yyy_column_to_zzz_table --fields="xxx:integer,yyy:text"
```
注意column和table是必需的，不能省略

### 1.2 删除字段
```bash
yii migrate/create drop_position_from_post --fields="position:integer"
```
## 2. 提交迁移
提交迁移后，如果成功，数据库会创建新表，migrate表会有一条迁移记录，具体命令如下：
```bash
yii migrate n
```
其中n表示提交前n个迁移

### 1.3 还原迁移
还原迁移是执行down()方法，还原up()生成的记录
```bash
yii migrate/down     # 还原最近一次提交的迁移
yii migrate/down 3   # 还原最近三次提交的迁移
```

### 1.4 重做迁移 
重做迁移是还原迁移的基础上，再重新提交迁移
```bash
yii migrate/redo        # 重做最近一次提交的迁移
yii migrate/redo 3      # 重做最近三次提交的迁移
```

### 1.5 刷新迁移
刷新迁移是清空数据库表，然后重新全部提交迁移
```bash
yii migrate/fresh
```

## 2. 多个数据库迁移方法
```bash
yii migrate --db=db2
```
上面的命令将会把迁移提交到 db2 数据库当中  
### 2.1 迁移多个库
```php
<?php
use yii\db\Migration;
class m150101_185401_create_news_table extends Migration
{
    public function init()
    {
        $this->db = 'db2';
        parent::init();
    }
}
```
只要在迁移类中指定$this->db即可












