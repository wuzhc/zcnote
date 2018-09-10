```php
<?php
/**
 * 多维数组合并排序
 * @param $arr
 * @return array
 */
function mergeMultiSortArray($arr) {
    $data = [];
    $arrPoint = [];

    foreach ($arr as $k => $v) {
        $arrPoint[$k] = 0; // 为每个数组初始化指针,指向第一个位置,0表示
    }

    while (!empty($arr)) {
        $arrIndex = null;
        $min = null;
        foreach ($arr as $k => $v) { // 比较每个数组指针指向的元素
            $vIndex = $arrPoint[$k];
            $vValue = $v[$vIndex];
            if ($min == null || $vValue < $min) {
                $min = $vValue;
                $arrIndex = $k;
            }
        }
        $data[] = $min;
        $arrPoint[$arrIndex]++; // 移动数组元素指针
        if (count($arr[$arrIndex]) <= $arrPoint[$arrIndex]) { // 指针已经指向数组元素最后一位,则删除数组
            unset($arr[$arrIndex]);
        }
    }

    return $data;
}

$t1 = microtime(true);
$arr = array(
    array(3, 10, 100, 101, 103, 105, 109, 123, 145),
    array(2, 30, 70),
    array(4, 6, 9)
);
$data = mergeMultiSortArray($arr);
echo "耗时: " . (microtime(true) - $t1) . PHP_EOL;
print_r($data);

```

```bash
耗时: 8.7976455688477E-5
Array
(
    [0] => 2
    [1] => 3
    [2] => 4
    [3] => 6
    [4] => 9
    [5] => 10
    [6] => 30
    [7] => 70
    [8] => 100
    [9] => 101
    [10] => 103
    [11] => 105
    [12] => 109
    [13] => 123
    [14] => 145
)
```