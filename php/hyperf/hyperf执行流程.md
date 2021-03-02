加载容器文件 $container = require BASE_PATH . '/config/container.php';

```php
//config/container.php
$container = new Container((new DefinitionSourceFactory(true))());
```

执行`DefinitionSourceFactory.__invoke`

```php
//vendor/hyperf/di/src/Definition/DefinitionSourceFactory.php
ProviderConfig::load();
```

扫描所有库的`composer.json`，将`extra.hyperf.config`定义的`ConfigProvider`

```php
//vendor/hyperf/config/src/ProviderConfig.php
public static function load(): array
    {
        if (! static::$providerConfigs) {
            $providers = Composer::getMergedExtra('hyperf')['config'] ?? [];
            static::$providerConfigs = static::loadProviders($providers);
        }
        return static::$providerConfigs;
    }
```

实例化所有库的`ConfigProvider`，然后存放在`$configFromProviders`

```php
//vendor/hyperf/config/src/ProviderConfig.php
protected static function loadProviders(array $providers): array
    {
        $providerConfigs = [];
        foreach ($providers as $provider) {
            if (is_string($provider) && class_exists($provider) && method_exists($provider, '__invoke')) {
                $providerConfigs[] = (new $provider())();
            }
        }

        return static::merge(...$providerConfigs);
    }
```

如果有自定义的`dependencies.php`，则会替换库默认的`dependencies`

```php
//vendor/hyperf/di/src/Definition/DefinitionSourceFactory.php
$serverDependencies = $configFromProviders['dependencies'] ?? [];
if (file_exists($configDir . '/autoload/dependencies.php')) {
    $definitions = include $configDir . '/autoload/dependencies.php';
    $serverDependencies = array_replace($serverDependencies, $definitions ?? []);
}
```

如果有`annotations.php`文件，则替换默认库的配置

```php
//vendor/hyperf/di/src/Definition/DefinitionSourceFactory.php
if (file_exists($configDir . '/autoload/annotations.php')) {
    $annotations = include $configDir . '/autoload/annotations.php';
    $scanDirs = array_merge($scanDirs, $annotations['scan']['paths'] ?? []);
    $ignoreAnnotations = array_merge($ignoreAnnotations, $annotations['scan']['ignore_annotations'] ?? []);
    $collectors = array_merge($collectors, $annotations['scan']['collectors'] ?? []);
}
```

初始化`ScanConfig`实例

```php
//vendor/hyperf/di/src/Definition/DefinitionSourceFactory.php
$scanConfig = new ScanConfig($scanDirs, $ignoreAnnotations, $collectors);

```

`DefinitionSourceFactory.php`创建`DefinitionSource`实例

创建扫描器`Scanner`

```php
ast
    ast实例化解析工厂ParserFactory
//vendor/hyperf/di/src/Annotation/Scanner.php
public function __construct(array $ignoreAnnotations = ['mixin'])
    {
        $this->parser = new Ast();

        // TODO: this method is deprecated and will be removed in doctrine/annotations 2.0
        AnnotationRegistry::registerLoader('class_exists');

        foreach ($ignoreAnnotations as $annotation) {
            AnnotationReader::addGlobalIgnoredName($annotation);
        }
    }
```

开始扫描库定义的目录`DefinitionSource.scan`

```php
//vendor/hyperf/di/src/Definition/DefinitionSource.php
public function __construct(array $source, ScanConfig $scanConfig, bool $enableCache = false)
{
    $this->scanner = new Scanner($scanConfig->getIgnoreAnnotations());
    $this->enableCache = $enableCache;

    // Scan the specified paths and collect the ast and annotations.
    $this->scan($scanConfig->getDirs(), $scanConfig->getCollectors());
    $this->source = $this->normalizeSource($source);
}

//$scanConfig->getCollectors() 如下
Array
(
    [0] => Hyperf\Cache\CacheListenerCollector
    [1] => Hyperf\Constants\ConstantsCollector
    [2] => Hyperf\Di\Annotation\AnnotationCollector
    [3] => Hyperf\Di\Annotation\AspectCollector
    [4] => Hyperf\ModelListener\Collector\ListenerCollector
)
```

先扫描`app`路径的文件

```php
//vendor/hyperf/di/src/Definition/DefinitionSource.php
$this->loadMetadata($appPaths, 'app');
```

扫描的路径会序列化保存在cache里面`/data/wwwroot/php/sw-hyperf/runtime/container/annotations.app.cache`

再扫描`vendor`路径的文件，缓存路径为`/data/wwwroot/php/sw-hyperf/runtime/container/annotations.vendor.cache`

解决依赖，每个依赖都变为`ObjectDefinition`

```php
//vendor/hyperf/di/src/Definition/DefinitionSource.php
$this->source = $this->normalizeSource($source);

 private function normalizeSource(array $source): array
 {
     $definitions = [];
     foreach ($source as $identifier => $definition) {
         $normalizedDefinition = $this->normalizeDefinition($identifier, $definition);
         if (! is_null($normalizedDefinition)) {
             $definitions[$identifier] = $normalizedDefinition;
         }
     }
     return $definitions;
 }
private function normalizeDefinition(string $identifier, $definition): ?DefinitionInterface
{
    if (is_string($definition) && class_exists($definition)) {
        if (method_exists($definition, '__invoke')) {
            return new FactoryDefinition($identifier, $definition, []);
        }
        return $this->autowire($identifier, new ObjectDefinition($identifier, $definition));
    }
    if (is_callable($definition)) {
        return new FactoryDefinition($identifier, $definition, []);
    }
    return null;
}

private function autowire(string $name, ObjectDefinition $definition = null): ?ObjectDefinition
{
    $className = $definition ? $definition->getClassName() : $name;
    if (! class_exists($className) && ! interface_exists($className)) {
        return $definition;
    }

    $definition = $definition ?: new ObjectDefinition($name);

    /**
         * Constructor.
         */
    $class = ReflectionManager::reflectClass($className);
    $constructor = $class->getConstructor();
    if ($constructor && $constructor->isPublic()) {
        $constructorInjection = new MethodInjection('__construct', $this->getParametersDefinition($constructor));
        $definition->completeConstructorInjection($constructorInjection);
    }

    /**
         * Properties.
         */
    $propertiesMetadata = AnnotationCollector::get($className);
    $propertyHandlers = PropertyHandlerManager::all();
    if (isset($propertiesMetadata['_p'])) {
        foreach ($propertiesMetadata['_p'] as $propertyName => $value) {
            // Because `@Inject` is a internal logical of DI component, so leave the code here.
            /** @var Inject $injectAnnotation */
            if ($injectAnnotation = $value[Inject::class] ?? null) {
                $propertyInjection = new PropertyInjection($propertyName, new Reference($injectAnnotation->value));
                $definition->addPropertyInjection($propertyInjection);
            }
            // Handle PropertyHandler mechanism.
            foreach ($value as $annotationClassName => $annotationObject) {
                if (isset($propertyHandlers[$annotationClassName])) {
                    foreach ($propertyHandlers[$annotationClassName] ?? [] as $callback) {
                        call($callback, [$definition, $propertyName, $annotationObject]);
                    }
                }
            }
        }
    }

    $definition->setNeedProxy($this->isNeedProxy($class));

    return $definition;
}
```

一个`ObjectDefinition`内容如下：

```php
Hyperf\Di\Definition\ObjectDefinition Object
(
    [constructorInjection:protected] => Hyperf\Di\Definition\MethodInjection Object
        (
            [methodName:Hyperf\Di\Definition\MethodInjection:private] => __construct
            [parameters:Hyperf\Di\Definition\MethodInjection:private] => Array
                (
                    [0] => Hyperf\Di\Definition\Reference Object
                        (
                            [name:Hyperf\Di\Definition\Reference:private] => 
                            [targetEntryName:Hyperf\Di\Definition\Reference:private] => Psr\Container\ContainerInterface
                            [needProxy:Hyperf\Di\Definition\Reference:private] => 
                        )

                    [1] => Hyperf\Di\Definition\Reference Object
                        (
                            [name:Hyperf\Di\Definition\Reference:private] => 
                            [targetEntryName:Hyperf\Di\Definition\Reference:private] => Hyperf\Amqp\Pool\PoolFactory
                            [needProxy:Hyperf\Di\Definition\Reference:private] => 
                        )

                )

        )

    [propertyInjections:protected] => Array
        (
        )

    [name:Hyperf\Di\Definition\ObjectDefinition:private] => Hyperf\Amqp\Producer
    [className:Hyperf\Di\Definition\ObjectDefinition:private] => Hyperf\Amqp\Producer
    [classExists:Hyperf\Di\Definition\ObjectDefinition:private] => 1
    [instantiable:Hyperf\Di\Definition\ObjectDefinition:private] => 1
    [needProxy:Hyperf\Di\Definition\ObjectDefinition:private] => 
    [proxyClassName:Hyperf\Di\Definition\ObjectDefinition:private] => 
)

```

设置`ObjectDefinition`代理

```php
//vendor/hyperf/di/src/Definition/DefinitionSource.php
$definition->setNeedProxy($this->isNeedProxy($class));
```

创建`ResolverDispatcher`,`ProxyFactory`

```php
//vendor/hyperf/di/src/Container.php
public function __construct(Definition\DefinitionSourceInterface $definitionSource)
{
    $this->definitionSource = $definitionSource;
    $this->definitionResolver = new ResolverDispatcher($this);
    $this->proxyFactory = new ProxyFactory();
    // Auto-register the container.
    $this->resolvedEntries = [
        self::class => $this,
        PsrContainerInterface::class => $this,
        HyperfContainerInterface::class => $this,
        ProxyFactory::class => $this->proxyFactory,
    ];
}
```



vendor/hyperf/di/src/Resolver/ObjectResolver.php

vendor/hyperf/di/src/Resolver/FactoryResolver.php