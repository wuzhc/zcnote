> 什么是反射，反射就是程序在运行的时候能够“观察”并且修改自己的行为。

## 参考
https://www.bookstack.cn/read/qcrao-Go-Questions/%E5%8F%8D%E5%B0%84-Go%20%E8%AF%AD%E8%A8%80%E5%A6%82%E4%BD%95%E5%AE%9E%E7%8E%B0%E5%8F%8D%E5%B0%84.md 

![https://static.bookstack.cn/projects/qcrao-Go-Questions/3398dceef374166abb8218b4abda36a5.png](https://static.bookstack.cn/projects/qcrao-Go-Questions/3398dceef374166abb8218b4abda36a5.png)

总结一下：TypeOf() 函数返回一个接口，这个接口定义了一系列方法，利用这些方法可以获取关于类型的所有信息； ValueOf() 函数返回一个结构体变量，包含类型信息以及实际值。

## 三大定律
- 第一条是最基本的：反射是一种检测存储在 `interface` 中的类型和值机制，这可以通过 `TypeOf` 函数和 `ValueOf` 函数得到
- 第二条实际上和第一条是相反的机制，它将 `ValueOf` 的返回值通过 `Interface()` 函数反向转变成 `interface` 变量。
- 如果想要操作原变量，反射变量 Value 必须要 hold 住原变量的地址才行。

## reflect.Value常用方法
```go
//数组或切片
v.Len()
v.Index(i int)

//map
v.MapKeys() //获取所有的keys
v.MapIndex(key reflect.Value) //根据key获取对应的值

//struct
v.NumField() //结构体成员数量
v.Type().Field(i int).Name //获取字段名称
v.Field(i int) //获取第几个字段

//ptr
v.IsNil()
v.Elem() //获取指针指向的值
v.FieldByName(name string) //根据名称获取结构体的内部字段值

//其他
v.Call(in []value) // 通过参数列表 in 调用 v 值所代表的函数（或方法)
reflect.Indirect(value) // value是一个指针,这里获取了该指针指向的值,相当于value.Elem()
```

```go
// reflect反射
package display

import (
	"fmt"
	"reflect"
	"strconv"
)

func Display(name string, v interface{}) {
	display(name, reflect.ValueOf(v))
}

func formatAtom(v reflect.Value) string {
	switch v.Kind() {
	case reflect.Int, reflect.Int8, reflect.Int32, reflect.Int64:
		return strconv.FormatInt(v.Int(), 10)
	case reflect.String:
		return v.String()
	case reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64, reflect.Uintptr:
		return strconv.FormatUint(v.Uint(), 10)
	case reflect.Bool:
		if v.Bool() {
			return "true"
		} else {
			return "false"
		}
	case reflect.Chan, reflect.Slice, reflect.Map, reflect.Func, reflect.Ptr:
		return v.Type().String() + "0x" + strconv.FormatUint(uint64(v.Pointer()), 16)
	default: // reflect.Array, reflect.Srtuct, reflect.Interface
		return v.Type().String() + " v"
	}
}

func display(path string, v reflect.Value) {
	switch v.Kind() {
	case reflect.Invalid:
		fmt.Printf("%s=invalid\n", path)
	case reflect.Slice, reflect.Array:
		// 对数组和切片的处理
		for i := 0; i < v.Len(); i++ {
			display(fmt.Sprintf("%s[%v]", path, i), v.Index(i))
		}
	case reflect.Map:
		//对map的处理
		for _, k := range v.MapKeys() {
			display(fmt.Sprintf("%s[%s]", path, k.String()), v.MapIndex(k))
		}
	case reflect.Struct:
		//对struct的处理
		for i := 0; i < v.NumField(); i++ {
			display(fmt.Sprintf("%s.%s", path, v.Type().Field(i).Name), v.Field(i))
		}
	case reflect.Ptr:
		// 处理指针
		if v.IsNil() {
			fmt.Printf("%s=nil\n", path)
		} else {
			display(fmt.Sprintf("*%s", path), v.Elem())
		}
	case reflect.Interface:
		// 处理接口
		if v.IsNil() {
			fmt.Printf("%s=nil\n", path)
		} else {
			fmt.Printf("%s.type=%s\n", path, v.Elem().Type())
			display(path+".value", v.Elem())
		}
	default:
		fmt.Printf("%s=%s\n", path, formatAtom(v))
	}
}

```