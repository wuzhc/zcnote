## 参考
https://www.jianshu.com/p/abacb34fb631

`slice`是一个指向数组的指针,它的结构体如下:
```go
type slice struct {
 array unsafe.Pointer
 len int
 cap int
}
```
- len是slice长度
- cap是slice容积,即底层数组长度
- 当对切片进行扩展`append`时,如果超过`slice.cap`,`slice`会重新分配空间,把原来的数据拷贝过去,`slice.array`指向新地址
-`slice`作为参数,如果函数中对`slice`进行扩展,且超过容积,则不会和原来的slice共享一个底层数组
- `slice`作为参数,是值传递,即使函数中对`slice`进行扩展,并且是共享同个底层数组,但是原来的slice的`len`和`cap`是没有改变的

```go
package main

import "fmt"

func main() {
	a := make([]int, 4, 5)
	fmt.Printf("len: %d cap:%d data:%+v\n", len(a), cap(a), a)
	ap(a)
	fmt.Printf("len: %d cap:%d data:%+v\n", len(a), cap(a), a)
	fmt.Printf("%p", &a)
}

func ap(a []int) {
	a = append(a, 10) // 只追加一个,没有超过cap(a),修改a[0]到a[3]会影响原来的值,因为共享同个底层数组,影响的是slice.array,slice.len和slice.cap不会收到影响,因为是值传递
	a[3] = 11

	//a = append(a, 10, 10) // 超过cap(a),修改a[0]到a[3]不会影响原来的值,因为新分配一个空间
	//a[3] = 12
	fmt.Printf("%p --- %v\n", &a, a)
}
```
- 只追加一个,没有超过cap(a),修改a[0]到a[3]会影响原来的值,因为共享同个底层数组
- 影响的是slice.array,slice.len和slice.cap不会收到影响,因为是值传递

## 解决方案
传递切片地址
```golang
package main

import "fmt"

func main() {
	si := []int{1, 2, 3, 4, 5, 6, 7, 8, 9}
	fmt.Printf("%v  len %d \n", si, len(si))
	test1(&si)
	fmt.Printf("%v  len %d \n", si, len(si))
}

func test1(si *[]int) {
	*si = append((*si)[:3], (*si)[4:]...)
}

```