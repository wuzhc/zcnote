# 过滤器
```php
## 1. 创建过滤器
创建的过滤器需要继承 yii\base\ActionFilte，并且覆盖beforeAction和afterAction，如果返回false表示不往下执行动作
​```php
<?php
class LoginFilter extends ActionFilter
{
   public function beforeAction($action)
    {
        return false; // 表示不在往下执行
    }
    
    public function afterAction($action, $result)
    {
    	return parent::afterAction($action);
    }
}
```

## 2. 使用
在控制器中使用
```php
public function behaviors()
{
    return [
        [
            'class' => 'yii\filters\HttpCache',
            'only' => ['index', 'view'],
            'lastModified' => function ($action, $params) {
                $q = new \yii\db\Query();
                return $q->from('user')->max('updated_at');
            },
        ],
    ];
}
```
only表示要应用过滤器的动作，except表示不要应用过滤器的动作

## 3. 多个过滤器执行顺序
### 3.1 预过滤
- 按顺序执行应用主体中 behaviors() 列出的过滤器。
- 按顺序执行模块中 behaviors() 列出的过滤器。
- 按顺序执行控制器中 behaviors() 列出的过滤器。
- 如果任意过滤器终止动作执行， 后面的过滤器（包括预过滤和后过滤）不再执行。
- 成功通过预过滤后执行动作。
### 3.2 后过滤
- 倒序执行控制器中 behaviors() 列出的过滤器。
- 倒序执行模块中 behaviors() 列出的过滤器。
倒序执行应用主体中 behaviors() 列出的过滤器。

## 4. 认证过滤器
```php
use yii\filters\AccessControl;

public function behaviors()
{
    return [
        'access' => [
            'class' => AccessControl::className(),
            'only' => ['create', 'update'],
            'rules' => [
                // 允许认证用户
                [
                    'allow' => true,
                    'roles' => ['@'],
                ],
                // 默认禁止其他用户
            ],
        ],
    ];
}
```

## 过滤器原理






```

```