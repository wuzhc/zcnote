## composer
>  *Composer* 是 PHP 中用来管理依赖(dependency)关系的工具，它可以帮我们自动加载类文件（前提是定义好命名空间和目录的映射关系），并且是惰性加载，在使用类时才自动加载，而不是一开始就加载全部类文件

## 自动加载autoload
魔术方法`__autoload`，当类不存在时，自动加载类文件（前提是自己需要自己定义好类和类文件的映射规则），为什么不用`__autoload`，`__autoload`是全局函数，只能定义一次，所有类和类文件映射规则只能在`__autoload`函数定义，会造成`__autoload臃肿，为此一般我们会使用`spl_autoload_register`

`spl_authoload_register`是`__autoload`的调用堆栈，可以定义多个`spl_authoload_register`，不同的映射的规则定义到`spl_authoload_register`中



## composer自动加载的类型

1. classmap
2. psr-0
3. psr-4
4. files

这几种自动加载都会用到，理论上来说，项目代码用 `psr-4` 自动加载， `helper` 用 `files` 自动加载，`development` 相关用 `classmap` 自动加载。 `psr-0` 已经被抛弃了，不过有些历史遗留依然在用，所以偶尔也会看到。

### PSR-0

下划线区分命名空间和类名，更深的目录结构，已经被弃用，参考：<https://gobea.cn/blog/detail/p6aln7oN.html>

### PSR-4

`PSR-4`规范了如何指定文件路径从而自动加载类定义，同时规范了自动加载文件的位置

`psr-4`可以将一个命名空间直接指向一个目录，而不需要像`psr-0`一样，命令空间和目录路径需要对等，所以`psr-0`一般来说会有更深的目录。例如我们使用`use church\testClass`，composer.json定义如下

```json
// psr-0
{
    "autoload": {
        "psr-0": {
            "Acme\\Util\\": "./src/"
        }
    }
}
// psr-4
{
    "autoload": {
        "psr-4": {
            "Acme\\Util\\": "./src/"
        }
    }
}
```
- psr-0对应类文件为：./src/Acme/Util/testClass.php
- psr-4对应类文件为：./src/testClass.php

#### psr-4命名空间要求“/”结尾
```json
{
    "autoload": {
        "psr-4": {
            "Acme\\Util\\": "./src/"
        }
    }
}
```
`Acme\\Util\\`命名空间必须以方斜杠\结尾，否则报错如下：
```bash
  [InvalidArgumentException]                                     
  A non-empty PSR-4 prefix must end with a namespace separator.  
```
#### psr-4下划线无意义
`psr-0`由于旧版本的 php 没有 namespace 所以必须通过 `_` 将类区分开，也就是旧版php的类名是这样的

```php
<?php
//没有命名空间，只有下划线来区分
class Acme_Util_ClassName{}
?>
```

psr-4下划线无意义，而psr-0类名有下划线，则会转为斜杠/

### classmap

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

### files

```json
 {
     "files": [
        "app/Swoft.php",
        "app/Helper/Functions.php"
    ],
 }
```



## 底层源码

[深入解析 composer 的自动加载原理](https://segmentfault.com/a/1190000014948542#articleHeader10)

#### 实例化核心加载类 Composer\Autoload\ClassLoader

#### 设置ClassLoader属性

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

#### 注册到spl_autoload_register调用堆栈

```php
$loader->register(true);
public function register($prepend = false)
{
    spl_autoload_register(array($this, 'loadClass'), true, $prepend);
}
```

### 自动加载类

```php
//vendor/composer/ClassLoader.php
public function loadClass($class)
{
    if ($file = $this->findFile($class)) {
        includeFile($file);

        return true;
    }
}

public function findFile($class)
{
    // class map lookup
    if (isset($this->classMap[$class])) {
        return $this->classMap[$class];
    }
    if ($this->classMapAuthoritative || isset($this->missingClasses[$class])) {
        return false;
    }
    if (null !== $this->apcuPrefix) {
        $file = apcu_fetch($this->apcuPrefix.$class, $hit);
        if ($hit) {
            return $file;
        }
    }

    $file = $this->findFileWithExtension($class, '.php');

    // Search for Hack files if we are running on HHVM
    if (false === $file && defined('HHVM_VERSION')) {
        $file = $this->findFileWithExtension($class, '.hh');
    }

    if (null !== $this->apcuPrefix) {
        apcu_add($this->apcuPrefix.$class, $file);
    }

    if (false === $file) {
        // Remember that this class does not exist.
        $this->missingClasses[$class] = true;
    }

    return $file;
}
```

自动加载类时，会先执行`ClassLoader->loadClass()`方法，然后调用`findFile()`方法，从`findFile()`方法可知，先从`classMap`找，找不到再从`psr-4`和`psr-0`找文件，所以说`composer dump-autoload -o`起到优化效果，因为它可以提前生成加载生成好类名和文件路径的对应关系，需要用到时候直接返回，可以减少io和轮询查询。

#### 类和文件映射规则

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



## 使用

### 初始化composer
```bash
php composer.phar init
```

### 编辑composer.json，添加自己的命名空间和全局函数
```json
// composer.json中的autoload键
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



## 包版本

版本格式：主版本号.次版本号.修订版本号

版本约束可以用几个不同的方法来指定。

| 名称         | 实例                                        | 描述                                                         |
| ------------ | ------------------------------------------- | ------------------------------------------------------------ |
| 确切的版本号 | 1.0.2                                       |                                                              |
| 范围         | `>=1.0`，` >=1.0，<2.0` `>=1.0，<1.1|>=1.2` | 通过使用比较操作符可以指定有效的版本范围。  有效的运算符：`>`、`>=`、`<`、`<=`、`!=`。  你可以定义多个范围，用逗号隔开，这将被视为一个**逻辑AND**处理。一个管道符号`|`将作为**逻辑OR**处理。  AND 的优先级高于 OR。 |
| 通配符       | 1.0.*                                       | 你可以使用通配符`*`来指定一种模式。`1.0.*`与`>=1.0,<1.1`是等效的。 |
| 赋值运算符   | ~1.2                                        | `~1.2` 相当于 `>=1.2,<2.0`，而 `~1.2.3` 相当于 `>=1.2.3,<1.3`，也就是说～约束的是点最后一位，将最后一位去掉，点之前的数字加1 |
| 赋值运算符   | ^1.2.3                                      | 代表1.2.3 <= 版本号 < 2.0.0                                  |



## composer.lock的作用

compose在处理完依赖关系后创建它，它列举了所有依赖关系的详细路径，如果该文件存在，composer install的时候会先读取它，主要作用是：

- ###### 1).保持环境一致性。

- ###### 2).项目的依赖可以被快速安装



## –prefer-source和–prefer-dist参数

```bash
# 安装
php7 composer.phar require wuzhc/zcswoole -vvv
# 卸载
php7 composer.phar remove wuzhc/zcswoole -vvv
# 创建项目
composer create-project --prefer-dist yiisoft/yii2-app-advanced yii-application
```

- `--prefer-dist` 会从github 上下载.zip压缩包，并缓存到本地。下次再安装就会从本地加载，大大加速安装速度。但她没有保留 .git文件夹,没有版本信息。适合基于这个package进行开发。
- `--prefer-source` 会从github 上clone 源代码，不会在本地缓存。但她保留了.git文件夹，从而可以实现版本控制。适合用于修改源代码。



## composer 生产环境加载优化

```bash
composer dump-autoload -o
#或者
composer dump-autoload -a
```

可以生成 map映射关系加快vendor引用速度，如果无法获取map映射关系会从psr4   psr0中查找加载关系

-o和-a共同点都是生成了classmap，加快了查找速度，不同点在于，如果classmap找不到目标类的话，-o的时候会继续在文件系统中查找，而-a则不会继续查找。（使用Laravel开发期间千万不要用-a，否则你新建的任何路由都不会生效）



## 如何发布自己的包

注册[github](https://github.com/)账号，注册 [Packagist](https://packagist.org/) 账号

`composer init`初始化`composer.json`

发布到packagist，登录 Packagist，检出 <https://github.com/xxxxx/xxx.git> 仓库的代码，系统会根据仓库中 composer.json 文件自动设置包的相关信息。

设置 Packagist 中的包自动更新如果不设置自动同步，每次 Github 中的代码更新，需要在对应包中手动更新，所以建议设置自动更新。官方文档如下[how-to-update-packages](https://packagist.org/about#how-to-update-packages)

虽然我们已经将comspoer包上传到packagist上了，但是我们在本地安装我们的composer包时还是会报错的，这是因为我们没有在github上指定版本的原因，如果我们不想在github上指定版本，这时候我们可以执行

 ```bash
composer require huaweichenai/baidu-discern "dev-master"
 ```

推荐参考：<https://segmentfault.com/a/1190000017857437>