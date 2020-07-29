注解一共有 3 种应用对象，分别是 类、类方法 和 类属性。

`@Value` `@Inject`

- 扫描文件吧，收集注解（`Hyperf\Di\Annotation\AnnotationCollector`）
- 要匹配注解名称吧
- 匹配到了要怎么办呢，好像是有3种类型的

## aop面向切面编程
在不改变原有代码的情况下，通过切面介入到任意类任意方法的执行流程中，从而改变和加强原方法的功能
### 概念
- 切面
对流程织入的定义类，内容包括介入的目标，以及实现对原方法的修改的代码逻辑
- 代理类
每个被介入的目标类最终都会生成一个代理类，来执行切面里面的方法

a类
找个东西定义修改的逻辑
a类生成一个代理类，来执行切面方法和a类逻辑

## 代理类
```php
<?php

declare (strict_types=1);
/**
 * This file is part of Hyperf.
 *
 * @link     https://www.hyperf.io
 * @document https://doc.hyperf.io
 * @contact  group@hyperf.io
 * @license  https://github.com/hyperf/hyperf/blob/master/LICENSE
 */
namespace App\Controller;

use App\Annotation\SomeAnnotation;
class IndexController extends AbstractController
{
    use \Hyperf\Di\Aop\ProxyTrait;
    use \Hyperf\Di\Aop\PropertyHandlerTrait;
    function __construct()
    {
        if (method_exists(parent::class, '__construct')) {
            parent::__construct(...func_get_args());
        }
        self::__handlePropertyHandler(__CLASS__);
    }
    /**
     * index
     * @SomeAnnotation()
     *
     * @return array
     * @author wuzhc 2020723 16:33:54
     */
    public function index()
    {
        return self::__proxyCall(__CLASS__, __FUNCTION__, self::__getParamsMap(__CLASS__, __FUNCTION__, func_get_args()), function () {
            $user = $this->request->input('user', 'Hyperf');
            $method = $this->request->getMethod();
            return ['method' => $method, 'message' => "Hello {$user}."];
        });
    }
}
```




