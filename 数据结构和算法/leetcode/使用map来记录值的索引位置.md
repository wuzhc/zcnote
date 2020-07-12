> 使用map来记录值的索引位置，主要用于找下标的算法

示例:
给定 nums = [2, 7, 11, 15], target = 9

因为 nums[0] + nums[1] = 2 + 7 = 9
所以返回 [0, 1]

来源：力扣（LeetCode）
链接：https://leetcode-cn.com/problems/two-sum
著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。

```golang
package main

import "fmt"

func main() {
	var nums = []int{2, 13, 7, 11, 15}
	var target = 9

	m := make(map[int]int, len(nums))
	for i, num := range nums {
		v := target - num
		if j, ok := m[v]; ok {
			fmt.Println(i, j)
			break
		} else {
			m[num] = i
		}
	}
}
```