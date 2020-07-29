# composer机制
>  *Composer* 是 PHP 中用来管理依赖(dependency)关系的工具，它可以帮我们自动加载类文件（前提是定义好命名空间和目录的映射关系），并且是惰性加载，在使用类时才自动加载，而不是一开始就加载全部类文件

## 1. 魔术方法__autoload
当类不存在时，自动加载类文件（前提是自己需要自己定义好类和类文件的映射规则）
### 1.1 为什么不用__autoload
*__autoload*是全局函数，只能定义一次，所有类和类文件映射规则只能在*\_\_autoload*函数定义，会造成*\_\_autoload*臃肿



## 2. spl_autoload_register
*spl_authoload_register*是__autoload的调用堆栈，可以定义多个*spl_authoload_register*，不同的映射的规则定义到*spl_authoload_register*中



## 3. PSR-4
*PSR-4*规范了如何指定文件路径从而自动加载类定义，同时规范了自动加载文件的位置
### 3.1 PSR-4和PSR-0的区别
*psr-4*和*psr-0*都可以自动加载类，两者的区别如下：
#### 3.1.1 psr-0有更深的目录
例如我们使用use church\testClass，composer.json定义如下
```json
# psr-0
{
    "autoload": {
        "psr-0": {
            "church\\": "./src/"
        }
    }
}
# psr-4
{
    "autoload": {
        "psr-4": {
            "church\\": "./src/"
        }
    }
}
```
- psr-0对应类文件为：./src/church/testClass.php
- psr-4对应类文件为：./src/testClass.php

#### 3.1.2 psr-4命名空间要求“/”结尾
```json
{
    "autoload": {
        "psr-4": {
            "church\\": "./src/"
        }
    }
}
```
church命名空间必须以方斜杠\结尾，否则报错如下：
```bash
  [InvalidArgumentException]                                     
  A non-empty PSR-4 prefix must end with a namespace separator.  
```
#### 3.1.3 psr-4下划线无意义（没搞懂）
psr-4下划线无意义，而psr-0类名有下划线，则会转为斜杠/



## 4. composer机制
### 4.1 疑问
什么时候去解析composer.json文件，如何解析composer.json文件?
> 应该是在composer update，composer install时会根据composer.json定义的autoload属性，自动保存映射关系到对应文件

### 4.2 源码
#### 4.2.1 实例化核心加载类 Composer\Autoload\ClassLoader
#### 4.2.2 设置ClassLoader属性
设置prefixLengthsPsr4， prefixDirsPsr4， prefixesPsr0，如下有两种方式，一种是直接在autoload_static.php读取，另一种是通过autoload_namespaces.php，autoload_psr4.php，autoload_classmap.php读取

```php
$useStaticLoader = PHP_VERSION_ID >= 50600 && !defined('HHVM_VERSION') && (!function_exists('zend_loader_file_encoded') || !zend_loader_file_encoded());
if ($useStaticLoader) {
    require_once __DIR__ . '/autoload_static.php';
  call_user_func(\Composer\Autoload\ComposerStaticInitc9aa9b19e38ff570843aae65d73b4f16::getInitializer($loader));
} else {
    $map = require __DIR__ . '/autoload_namespaces.php';
    foreach ($map as $namespace => $path) {
        $loader->set($namespace, $path);
    }

    $map = require __DIR__ . '/autoload_psr4.php';
    foreach ($map as $namespace => $path) {
        $loader->setPsr4($namespace, $path);
    }

    $classMap = require __DIR__ . '/autoload_classmap.php';
    if ($classMap) {
        $loader->addClassMap($classMap);
    }
}
```

#### 4.2.3 注册到spl_autoload_register调用堆栈
```php
$loader->register(true);
public function register($prepend = false)
{
    spl_autoload_register(array($this, 'loadClass'), true, $prepend);
}
```

#### 4.2.4 类和文件映射规则
```php
private function findFileWithExtension($class, $ext)
    {
        // PSR-4 lookup
        $logicalPathPsr4 = strtr($class, '\\', DIRECTORY_SEPARATOR) . $ext;

        $first = $class[0];
        if (isset($this->prefixLengthsPsr4[$first])) {
            $subPath = $class;
            while (false !== $lastPos = strrpos($subPath, '\\')) {
                $subPath = substr($subPath, 0, $lastPos);
                $search = $subPath . '\\';
                if (isset($this->prefixDirsPsr4[$search])) {
                    $pathEnd = DIRECTORY_SEPARATOR . substr($logicalPathPsr4, $lastPos + 1);
                    foreach ($this->prefixDirsPsr4[$search] as $dir) {
                        if (file_exists($file = $dir . $pathEnd)) {
                            return $file;
                        }
                    }
                }
            }
        }

        // PSR-4 fallback dirs
        foreach ($this->fallbackDirsPsr4 as $dir) {
            if (file_exists($file = $dir . DIRECTORY_SEPARATOR . $logicalPathPsr4)) {
                return $file;
            }
        }

        // PSR-0 lookup
        if (false !== $pos = strrpos($class, '\\')) {
            // namespaced class name
            $logicalPathPsr0 = substr($logicalPathPsr4, 0, $pos + 1)
                . strtr(substr($logicalPathPsr4, $pos + 1), '_', DIRECTORY_SEPARATOR);
        } else {
            // PEAR-like class name
            $logicalPathPsr0 = strtr($class, '_', DIRECTORY_SEPARATOR) . $ext;
        }

        if (isset($this->prefixesPsr0[$first])) {
            foreach ($this->prefixesPsr0[$first] as $prefix => $dirs) {
                if (0 === strpos($class, $prefix)) {
                    foreach ($dirs as $dir) {
                        if (file_exists($file = $dir . DIRECTORY_SEPARATOR . $logicalPathPsr0)) {
                            return $file;
                        }
                    }
                }
            }
        }

        // PSR-0 fallback dirs
        foreach ($this->fallbackDirsPsr0 as $dir) {
            if (file_exists($file = $dir . DIRECTORY_SEPARATOR . $logicalPathPsr0)) {
                return $file;
            }
        }

        // PSR-0 include paths.
        if ($this->useIncludePath && $file = stream_resolve_include_path($logicalPathPsr0)) {
            return $file;
        }

        return false;
    }
```
大概过程如下：prefixLengthsPsr4 -> prefixDirsPsr4 -> fallbackDirsPsr4



### 4.3 使用
### 4.3.1 初始化composer
```bash
php composer.phar init
```

### 4.3.2 编辑composer.json，添加自己的命名空间和全局函数
```json
# composer.json中的autoload键
"autoload": {
    "psr-4": {
        "App\\": "app/" 
    },
    "files": [
        "app/Swoft.php",
        "app/Helper/Functions.php"
    ],
    "classmap": [
        "src/"
    ]
},
```
- psr-4命名空间，保存在autoload_psr4.php文件中
- files全局函数，保存在autoload_files.php文件中
- classmap扫描src所有文件，以`namespace+classname`作为键，文件作为值，保存在autoload_classmap.php文件中  
##### 注意：修改composer.json后，需要composer update

## classmap的用法
```json
{
  "autoload":{
    "classmap":["src/"]
  }
}
```
扫描src目录下的所有文件，以`namespace+classname`作为键，文件作为值，保存在`autoload_classmap.php`文件中，有什么好处呢？
- 同个src目录下，不同的文件可以使用不同的`namespace`
- src有子目录同样可以生成键值对保存在`autoload_classmap.php`中


## 4.3.3 composer常用命令
```bash
# 安装
php7 composer.phar require wuzhc/zcswoole -vvv
# 卸载
php7 composer.phar remove wuzhc/zcswoole -vvv
# 创建项目
composer create-project --prefer-dist yiisoft/yii2-app-advanced yii-application
```
### 参数说明
- `--prefer-dist` 会从github 上下载.zip压缩包，并缓存到本地。下次再安装就会从本地加载，大大加速安装速度。但她没有保留 .git文件夹,没有版本信息。适合基于这个package进行开发。
- `--prefer-source` 会从github 上clone 源代码，不会在本地缓存。但她保留了.git文件夹，从而可以实现版本控制。适合用于修改源代码。




## 5. 参考
[深入解析 composer 的自动加载原理](https://segmentfault.com/a/1190000014948542#articleHeader10)