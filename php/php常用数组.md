## array_chunk

最后一个参数为true时，如果有关联和数字同时存在，则数字所以从零开始计算

```php
array_chunk ( array $array , int $size , bool $preserve_keys = false ) : array
```

将一个数组分割成多个数组，其中每个数组的单元数目由 `size` 决定。最后一个数组的单元数目可能会少于 `size`个。

```php
$input_array = array('a', 'b', 'c', 'd', 'e');
print_r(array_chunk($input_array, 2));
print_r(array_chunk($input_array, 2, true));
```

输出

```
Array
(
    [0] => Array
        (
            [0] => a
            [1] => b
        )

    [1] => Array
        (
            [0] => c
            [1] => d
        )

    [2] => Array
        (
            [0] => e
        )

)
Array
(
    [0] => Array
        (
            [0] => a
            [1] => b
        )

    [1] => Array
        (
            [2] => c
            [3] => d
        )

    [2] => Array
        (
            [4] => e
        )

)
```



## array_column

从二维数组获取一列，第三个参数指定的列作为key

```php
array_column ( array $input , mixed $column_key , mixed $index_key = null ) : array
```

```php
$records = array(
    array(
        'id' => 2135,
        'first_name' => 'John',
        'last_name' => 'Doe',
    ),
 );
```



## array_combine

合并两个数组，一个作为key，一个作为value，如果两个数量不一致会报错

```php
array_combine ( array $keys , array $values ) : array
```



## array_count_values

统计数组各个元素出现的次数

```php
array_count_values ( array $array ) : array
```

```php
<?php
$array = array(1, "hello", 1, "world", "hello");
print_r(array_count_values($array));
?>
```

```
Array
(
    [1] => 2
    [hello] => 2
    [world] => 1
)
```



## array_diff

计算数组差集，返回只在第一个数组，但是不在其他数组的元素，注意键名保留不变。 保留数组 `array` 里的键。

```php
array_diff ( array $array , array ...$arrays ) : array
```



## array_intersect

计算数组交集，返回所有数组共有的元素，注意键名保留不变（键名是第一个数组的）。

```php
array_intersect ( array $array1 , array $array2 , array $... = ? ) : array
```



## array_key_exist

**array_key_exists()** 仅仅搜索第一维的键。 多维数组里嵌套的键不会被搜索到。

```php
array_key_exists ( mixed $key , array $array ) : bool
```

array_key_exists() 与 isset() 的对比

[isset()](https://www.php.net/manual/zh/function.isset.php) 对于数组中为 **null** 的值不会返回 **true**，而 **array_key_exists()** 会。 



## array_fill

给定值来填充数组，注意开始位置负数问题

```php
array_fill ( int $start_index , int $count , mixed $value ) : array
```

```php
$a = array_fill(5, 6, 'banana');
$b = array_fill(-2, 4, 'pear');
print_r($a);
print_r($b);
```

输出

```
Array
(
    [5]  => banana
    [6]  => banana
    [7]  => banana
    [8]  => banana
    [9]  => banana
    [10] => banana
)
Array
(
    [-2] => pear 
    [0] => pear
    [1] => pear
    [2] => pear
)
```



## array_flip

交换数组的键和值，如果值有冲突，则后面覆盖前面

```php
array_flip ( array $array ) : array
```

```php
$input = array("a" => 1, "b" => 1, "c" => 2);
$flipped = array_flip($input);
print_r($flipped);
```

输出：

```
Array
(
    [1] => b
    [2] => c
)
```



## array_reverse

反转数组

```php
array_reverse ( array $array , bool $preserve_keys = false ) : array
```



## array_multisort

可以用来一次对多个数组进行排序，或者根据某一维或多维对多维数组进行排序。

```php
array_multisort ( array &$array1 , mixed $array1_sort_order = SORT_ASC , mixed $array1_sort_flags = SORT_REGULAR , mixed $... = ? ) : bool
```

```php
$data[] = array('volume' => 67, 'edition' => 2);
$data[] = array('volume' => 86, 'edition' => 1);
$data[] = array('volume' => 85, 'edition' => 6);
$data[] = array('volume' => 98, 'edition' => 2);
$data[] = array('volume' => 86, 'edition' => 6);
$data[] = array('volume' => 67, 'edition' => 7);
foreach ($data as $key => $row) {
    $volume[$key]  = $row['volume'];
    $edition[$key] = $row['edition'];
}
//将数据根据 volume 降序排列，根据 edition 升序排列
array_multisort($volume, SORT_DESC, $edition, SORT_ASC, $data); 
```