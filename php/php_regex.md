# 正则表达式
## 双反斜杠 \\\
如果需要正则需要匹配反斜杠，需要三个反斜杠，例如：
```php
$classname = 'make\done';
$class = preg_replace("/\w+\\\/", '', $classname);
echo $class; // done
```

## 函数
### preg_replace 正则替换
```php
preg_replace($pattern, $replacement, $subject, $limit, $count)
```
- 如果要在replacement 中使用反斜线，必须使用4个("\\\\"，译注：因为这首先是php的字符串，经过转义后，是两个，再经过 正则表达式引擎后才被认为是一个原文反斜线)。
- 如果subject是一个数组， preg_replace()返回一个数组
- 后向引用$n，表示第n个被捕获的子组
#### 例子
```php
$patterns = array ('/(19|20)(\d{2})-(\d{1,2})-(\d{1,2})/',
                   '/^\s*{(\w+)}\s*=/');
$replace = array ('\3/\4/\1\2', '$\1 =');
echo preg_replace($patterns, $replace, '{startDate} = 1999-5-27');
// $startDate = 5/27/1999
```
```php
$string = 'April 15, 2003';
$pattern = '/(\w+) (\d+), (\d+)/i';
$replacement = '${1}1,$3';
echo preg_replace($pattern, $replacement, $string);
// April1,2003
```
```php
$string = 'The quick brown fox jumps over the lazy dog.';
$patterns = array();
$patterns[0] = '/quick/';
$patterns[1] = '/brown/';
$patterns[2] = '/fox/';
$replacements = array();
$replacements[2] = 'bear';
$replacements[1] = 'black';
$replacements[0] = 'slow';
echo preg_replace($patterns, $replacements, $string);
// The bear black slow jumps over the lazy dog.
// NOTE: 数组是根据位置对应的，例如0到2,1到1,2到0，如果需要得到正确的排序的，可以调换下replacements的位置，和索引值没有关系
```
### preg_split 正则分割
```php
preg_split($pattern, $subject, $limit, $flags)
```
flags包括：
- PREG_SPLIT_NO_EMPTY 返回不为空的
- PREG_SPLIT_DELIM_CAPTURE 分割模式括号部分会被匹配
- PREG_SPLIT_OFFSET_CAPTURE 分割后每个字符串偏移量
### 例子
```php
//使用逗号或空格(包含" ", \r, \t, \n, \f)分隔短语
$keywords = preg_split("/[\s,]+/", "hypertext language, programming");
print_r($keywords); // 匹配模式包括不可见字符，逗号，以这个两个作为分割标识
Array
(
    [0] => hypertext
    [1] => language
    [2] => programming
)
```
