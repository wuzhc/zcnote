# 服务定位器（Service Locator）
> 服务定位器模式和依赖注入模式都是控制反转（IoC）模式的实现。我们在服务定位器中注册给定接口的服务实例，然后通过接口获取服务并在应用代码中使用而不需要关心其具体实现。我们可以在启动时配置并注入服务提供者。

## 意义
- 在组件中可能存在多个地方需要引用服务的实例，在这种情况下，直接创建服务实例的代码会散布到整个程序中，造成一段程序存在多个副本，大大增加维护和排错成本
- 某些服务的初始化过程需要耗费大量资源，因此多次重复地初始化服务会大大增加系统的资源占用和性能损耗
- 当组件需要调用多个服务时，不同服务初始化各自实例的方式又可能存在差异。开发人员不得不了解所有服务初始化的API，以便在程序中能够正确地使用这些服务

## 代码
```php
<?php

namespace zcswoole;


use zcswoole\utils\FactoryUtil;

/**
 * 服务定位器
 * Class ServiceLocator
 *
 * @package zcswoole
 */
class ServiceLocator implements ServiceLocatorInterface
{
	// 存放实例化的服务
    private $_services = [];
    // 存放类定义，如class
    private $_definitions = [];
    // 存放是否为单例模式标识
    private $_singletons = [];

    /**
     * 注册服务
     *
     * @param string       $id 组件ID
     * @param array|object $definition
     * @param bool         $isSingleton 是否为单例模式,非单例模式下每次获取组件时都会实例化一次对象
     * @throws \Exception
     */
    public function set($id, $definition, $isSingleton = true): void
    {
        if (!$definition || !is_array($definition)) {
            return;
        }

        if (!isset($definition['class']) && !$definition['class']) {
            throw new \Exception("$id class is empty");
        }

        if (isset($this->_services[$id])) {
            unset($this->_services[$id]);
        }

        $this->_singletons[$id] = $isSingleton;
        
        // 延迟加载,用到的时候在创建类
        $this->_definitions[$id] = $definition;
    }

    /**
     * 获取服务实例
     *
     * @param string $id
     * @return mixed|null|object
     * @throws \Exception
     */
    public function get($id)
    {
        $isSingleton = $this->_singletons[$id] ?? false;

        if (isset($this->_services[$id]) && true === $isSingleton) {
            return $this->_services[$id];
        }

        if (!isset($this->_definitions[$id])) {
            throw new \Exception("Unknown component id $id");
        }

        $definition = $this->_definitions[$id];
        if (is_object($definition)) {
            $obj = $definition;
        } else {
            $className = $definition['class'];
            unset($definition['class']);
            $obj = FactoryUtil::createObject($className, [], $definition);
        }

        if ($isSingleton) {
            $this->_services[$id] = $definition;
        }

        return $obj;
    }

    /**
     * @param $id
     * @return bool
     */
    public function has($id)
    {
        return isset($this->_definitions[$id]) || isset($this->_services[$id]);
    }

    /**
     * 魔术方法
     * e.g. ZCSwoole::$app->get('logger') or ZCSwoole::$app->logger
     *
     * @param $id
     * @return mixed
     */
    public function __get($id)
    {
        if ($this->has($id)) {
            return $this->get($id);
        }

        $method = 'get' . ucfirst($id);
        if (method_exists($this, $method)) {
            return $this->$method();
        }

        return null;
    }
}
```
## 参考
- [PHP 设计模式系列 —— 服务定位器模式（Service Locator）](https://laravelacademy.org/post/2820.html)

