## mysql连接配置
- 数据库驱动源码在`thinkphp/library/think/db/connector`目录下，根据`database.type`指定哪个驱动
- 每个模块可以指定不同的数据库
- mysql的断线重连（V5.0.6+之后版本支持）
```php
'break_reconnect' => true,
```
- mysql配置可以单独写在`database.php`，也可以写在`config.php`下的`db_config1`自定义字段下
```php
//application/config.php
//数据库配置1
'db_config1' => [
    // 数据库类型
    'type'        => 'mysql',
    // 服务器地址
    'hostname'    => '127.0.0.1',
    // 数据库名
    'database'    => 'thinkphp',
    // 数据库用户名
    'username'    => 'root',
    // 数据库密码
    'password'    => '',
    // 数据库编码默认采用utf8
    'charset'     => 'utf8',
    // 数据库表前缀
    'prefix'      => 'think_',
],
//数据库配置2
'db_config2' => 'mysql://root:1234@localhost:3306/thinkphp#utf8';
```
- 不同的数据库连接可以使用`Db::connect('db_config1');`指定
- 模型中定义数据库连接，直接定义`connection`字段即可
```php
//在模型里单独设置数据库连接信息
namespace app\index\model;
use think\Model;
class User extends Model
{
    // 直接使用配置参数名
    protected $connection = 'db_config1';
}
```

## 原生sql查询和插入
```
Db::query('select * from think_user where id=?',[8]);
Db::execute('insert into think_user (id, name) values (?, ?)',[8,'thinkphp']);
```

## 数据库查询
```php
//普通查询
Db::name('user')->where('id',1)->find(); //查询一条记录
Db::name('user')->where('status',1)->select();　//查询多条记录
Db::connect('dbname')->table('user') //指定数据库

//读写分离
Db::name('user')->master()->where('id',1)->find();　//指定master(),强制从主库查询
Db::table('think_user')->readMaster()->insert($data);　//指定readMaster(),之后查询都走主库

//助手函数ｄｂ
db('user')->where('id',1)->find();　//使用db助手函数默认每次都会重新连接数据库，而使用Db::name或者Db::table方法的话都是单例的。db函数如果需要采用相同的链接，可以传入第三个参数，例如db('user',[],false)->where('id',1)->find();
```
### where查询
```php
where('字段名','表达式','查询条件');
->where('name','like','%thinkphp') //like查询
->where('name&title','like','%thinkphp') //and合并,等同于name like %thinkphp and title like %thinkphp
->where('name|title','like','%thinkphp') //or合并，等同于name like %thinkphp or title like %thinkphp

->where('id','=',100);
->where('id','<>',100);
->where('id','between',[1,8]);
->where('id','not in',[1,5,8]);
->where('title','=', 'null');
->where('name','=', 'not null');
->whereTime('birthday', '<', '2000-10-1')
->whereTime('birthday', 'between', ['1970-10-1', '2000-10-1']) //时间查询
->whereTime('create_time', 'last month') //上个月记录

->where([
    'name'  =>  ['like','thinkphp%'],
    'title' =>  ['like','%thinkphp'],
    'id'    =>  ['>',0],
    'status'=>  1
]) //联合查询

->where('id > :id AND name LIKE :name ',['id'=>0, 'name'=>'thinkphp%']) //绑定查询
```

## 构造查询
```php
->value('field_name') //代替find(),用于返回某个字段的值
->column('field_value', 'field_key') //返回某一列的值，结果是一个数组，key可以指定为field_key

Db::connect('met')->table('chat_group')->where('id',1)->chunk(100, function($res) {
            foreach ($res as $r) {
                Debug::dump($r);
            	return false; //可以提前终止处理
            }
},'id','desc'); //批量查询，每次处理100条数据，默认是根据主键查询
```

## 插入
```php
Db::name('user')->insertGetId($data); //获取最后一次插入ID
Db::name('user')->insertAll([
    ['foo' => 'bar', 'bar' => 'foo'],
    ['foo' => 'bar1', 'bar' => 'foo1'],
    ['foo' => 'bar2', 'bar' => 'foo2']
]); //批量插入数据
```

## 更新
```php
Db::table('think_user')->where('id', 1)->update(['name' => 'thinkphp']); // 更新操作，先指定查询条件，再指定更新字段值，update 方法返回影响数据的条数，没修改任何数据返回 0

Db::connect('met')->table('chat_group')->where('id', 1)->inc('status',2)->update(); //自增字段
```

## 链式调用
```php
->order(['order'=>'desc','id'=>'desc'])
->orderRaw('rand()')
->field(['id','nickname'=>'name']) //指定查询字段，等同于select id, nickname as name,如果设置第二个参数为`true`,则表示排除
->page(1)->limit(10) //分页，第1页，每页10条记录
```

## 联表查询
```php
Db::table('think_artist')
->alias('a')
->join('think_work w','a.id = w.artist_id')
->join('think_card c','a.card_id = c.id')
->select();
```

## 聚合查询
```php
->count()
->max('field')
->avg('field')
->sum('field')
```

## 事务操作
```php
//自动事务
Db::transaction(function(){
    Db::table('think_user')->find(1);
    Db::table('think_user')->delete(1);
});

//手动事务
Db::startTrans();
try{
    Db::table('think_user')->find(1);
    Db::table('think_user')->delete(1);
    // 提交事务
    Db::commit();    
} catch (\Exception $e) {
    // 回滚事务
    Db::rollback();
}
```

## 模型
- 模型名称为去除下划线，去除表前缀，驼峰法
- 如果不符合第一条，则需要在model模型里面指定`table`
```php
<?php
namespace app\demo\model;
use think\Model;
class ChatGroup extends Model
{
    protected $table = 'chat_group'; //直接指定表名
    protected $connection = 'met'; //直接指定数据库名
}
```

### 插入数据
```php
//普通插入
$user = new User(); //注意不要在同一个实例里面多次新增数据，一个`new`一个插入
$user->name     = 'onethink';
$user->save();
echo $user->id; //返回插入的ID

//静态方法create插入
$user = User::create([
    'name'=>'xxxx',
]);
echo $user->id; //create返回的是当前模型对象实例

//指定字段插入
$user = new User($_POST);
// post数组中只有name和email字段会写入
$user->allowField(['name','email'])->save();

//批量插入
$user = new User();
$user->saveAll([ 
    ['name'=>'php','id'=>1],//如果带有主键，则是一个更新操作
    ['name'=>'golang']
]);
```

### 更新数据
```php
$user = new User;
// save方法第二个参数为更新条件
$user->save([
    'name'  => 'thinkphp',
    'email' => 'thinkphp@qq.com'
],['id' => 1]);

$user = new User();
// post数组中只有name和email字段会写入
$user->allowField(['name','email'])->save($_POST, ['id' => 1]);

User::update(['name' => 'thinkphp'],['id'=>1]); //更新多条的
```

### 删除记录
```php
User::destroy(1); //根据主键删除 或者 User::destroy([1,2,3]);
User::destroy(['name'=>'xxx']) //根据名称删除
```

### 查询数据
```php
User::get(1); //根据主键获取
User::get(['name'=>'xxx']) //根据名称获取
User::all(); //查询多条记录

$user = new User();
$user->where('name', 'thinkphp')
    ->limit(10)
    ->order('id', 'desc')
    ->select();
    
//后续该模型的操作从主库读取数据
$user           = new User;
$user->name     = 'thinkphp';
$user->email    = 'thinkphp@qq.com';
$user->readMaster()->save(); //当设置readMaster(true)时，所有模型查询从主库查找，或者配置文件`'read_master'	=> true`
```

## 获取器
获取器的作用是在获取数据的字段值后自动进行处理
```php
class User extends Model 
{
	//包装status数据，获取$user->status会输出处理后的值
    public function getStatusAttr($value)
    {
        $status = [-1=>'删除',0=>'禁用',1=>'正常',2=>'待审核'];
        return $status[$value];
    }
    
     //定义一个不存在的字段，第二个参数是一行记录数据
     public function getStatusTextAttr($value,$data)
    {
        $status = [-1=>'删除',0=>'禁用',1=>'正常',2=>'待审核'];
        return $status[$data['status']];
    }
}

$user = new User();
echo $user->status;
echo $user->status_text; //获取不存在的字段
echo $user->getData('status'); //获取原始数据
$user->toArray(); //获取的字段都是经过获取器的
```

## 修改器
修改器的作用是可以在数据赋值的时候自动进行转换处理
```php
class User extends Model 
{
    public function setNameAttr($value, $data) //第二个参数是当前所有数据
    {
        return strtolower($value);
    }
}

$user = new User();
$user->name = 'xxxx';
$user->save();

//或者用data()的第二个参数为true来触发
$user->data(['name'=>'xxxx'], true);
$user->save();
```

## 自动创建时间和更新时间
```php
class User extends Model 
{
    protected $autoWriteTimestamp = 'datetime'; //开始自动创建时间和更新时间，如果是datetime类型，需要指定
    protected $createTime = 'create_at'; //指定创建时间字段名称
    protected $updateTime = false; //如果没有更新时间，则设置更新时间为false
}
```

## 保护字段
```php
class User extends Model
{
	protected $readonly = ['name','email'];
}
```