# yii2事件和行为
行为是基于事件是实现的

## 行为
### 为什么要用行为？
将一个行为类B绑定到一个类A上，类A就拥有了行为类B的方法和属性，总而言之，就是扩展类A的功能；

### 如何实现？
行为的基类为`vendor/yiisoft/yii2/base/Behavior.php`
```php
class Behavior extends Object
{
    // 指向行为本身所绑定的Component对象
    public $owner;

    // Behavior 基类本身没用，主要是子类使用，重载这个函数返回一个数组表
    // 示行为所关联的事件
    public function events()
    {
        return [];
    }

    // 绑定行为到 $owner
    public function attach($owner)
    {
        ... ...
    }

    // 解除绑定
    public function detach()
    {
        ... ...
    }
}
```
### 以过滤器作为例子说明
![](/data/wwwroot/doc/zcnote/images/php/yii2/yii2行为和事件.png)  
#### 控制器声明过滤器
```php
<?php
public function behaviors()
{
    return ArrayHelper::merge([
        [
            'class' => Cors::class,
            'cors'  => [
                'Origin'                        => $this->allowOriginHosts,
                'Access-Control-Request-Method' => $this->allowRequestMethods,
                'actions'                       => [
                    'login' => [
                        'Access-Control-Allow-Credentials' => true,
                    ]
                ]
            ],
        ],
    ], parent::behaviors());
}
```
以上在Controller中定义behaviors方法，以覆盖父类Component的behaviors方法
#### 执行Controller的beforeAction方法
`vendor/yiisoft/yii2/base/Controller.php`调用`runAction`方法，`runAction`执行`beforeAction`，`beforeAction`代码如下：
```php
<?php
public function beforeAction($action)
{
    $event = new ActionEvent($action);
    $this->trigger(self::EVENT_BEFORE_ACTION, $event);
    return $event->isValid;
}
```
#### beforeAction调用trigger触发事件
由上面可知，`beforeAction`执行了`$this->trigger`，`trigger`为父类Component的方法，如下：
```php
<?php
public function trigger($name, Event $event = null)
{
    $this->ensureBehaviors();

    $eventHandlers = [];
    foreach ($this->_eventWildcards as $wildcard => $handlers) {
        if (StringHelper::matchWildcard($wildcard, $name)) {
            $eventHandlers = array_merge($eventHandlers, $handlers);
        }
    }

    if (!empty($this->_events[$name])) {
        $eventHandlers = array_merge($eventHandlers, $this->_events[$name]);
    }

    if (!empty($eventHandlers)) {
        if ($event === null) {
            $event = new Event();
        }
        if ($event->sender === null) {
            $event->sender = $this;
        }
        $event->handled = false;
        $event->name = $name;
        foreach ($eventHandlers as $handler) {
            $event->data = $handler[1];
            call_user_func($handler[0], $event);
            // stop further handling if the event is handled
            if ($event->handled) {
                return;
            }
        }
    }

    // invoke class-level attached handlers
    Event::trigger($this, $name, $event);
}
```
#### ensureBehaviors绑定行为
上面`trigger`会调用`ensureBehaviors`，如下：
```php
<?php
public function ensureBehaviors()
{
    if ($this->_behaviors === null) {
        $this->_behaviors = [];
        foreach ($this->behaviors() as $name => $behavior) {
            $this->attachBehaviorInternal($name, $behavior);
        }
    }
}
```
看到了吗？`$this->behaviors()`即我们在Controller定义的方法，接下来看`attachBehaviorInternal`
```php
<?php
 private function attachBehaviorInternal($name, $behavior)
{
    if (!($behavior instanceof Behavior)) {
        $behavior = Yii::createObject($behavior);
    }
    if (is_int($name)) {
        $behavior->attach($this);
        $this->_behaviors[] = $behavior;
    } else {
        if (isset($this->_behaviors[$name])) {
            $this->_behaviors[$name]->detach();
        }
        $behavior->attach($this);
        $this->_behaviors[$name] = $behavior;
    }

    return $behavior;
}
```
首先因为我们的定义的行为类是这样定义的`'class' => Cors::class`，执行`$behavior = Yii::createObject($behavior);`把行为变成一个behavior对象，然后执行`attach`；去到`vendor/yiisoft/yii2/filters/Cors.php`，可以看到Cors其实是一个Behavior类，再看Cors的父类ActionFilter中的`attach()`,实际上执行的是`ActionFilter->attach()`
```php
<?php
public function attach($owner)
{
    $this->owner = $owner;
    $owner->on(Controller::EVENT_BEFORE_ACTION, [$this, 'beforeFilter']);
}
```
这里的owner是指Controller类，`$owner->on()`即调用`Component->on()`
```php
<?php
public function on($name, $handler, $data = null, $append = true)
{
    $this->ensureBehaviors();

    if (strpos($name, '*') !== false) {
        if ($append || empty($this->_eventWildcards[$name])) {
            $this->_eventWildcards[$name][] = [$handler, $data];
        } else {
            array_unshift($this->_eventWildcards[$name], [$handler, $data]);
        }
        return;
    }

    if ($append || empty($this->_events[$name])) {
        $this->_events[$name][] = [$handler, $data];
    } else {
        array_unshift($this->_events[$name], [$handler, $data]);
    }
}
```
将一个行为类作为一个handler保存在`$this->_events`中，最后回到一开始的`trigger()`方法，执行`call_user_func($handler[0], $event);`，$handler[0]即`[Cors, 'beforeFilter']`，也就是说行为类Cors最后执行的是`beforeFilter`方法，查看类`ActionFilter`可以知道beforFilter调用的是`beforeAction`方法，所以Cors最后执行的其实是beforeAction方法

### 总结
由上面的代码分析总结如下：
- 行为类能将本身的方法作为事件handler绑定到类上，例如`ActionFilter`的`attach()`将`beforeFilter`绑定到了类，过滤器最后执行的是`beforeFilter`方法		
- 行为类通过$ower访问依附类

















