## 一个简单的例子
如果一个类型实现了一个 interface 中所有方法，我们说类型实现了该 interface，所以所有类型都实现了 empty interface，因为任何一种类型至少实现了 0 个方法。go 没有显式的关键字用来实现 interface，只需要实现 interface 包含的方法即可。
```go
type Animal interface {
    Speak() string
}

type Dog struct {
}

// 为Dog类型添加Speak方法
func (d Dog) Speak() string {
    return "Woof!"
}
```
所有实现了Speak方法的类型称它实现了Animal接口

## 有什么用？
interface 的重要用途就体现在函数 的参数中，如果有多种类型实现了某个 interface，这些类型的值都可以直接使用 interface 的变量存储。
```go
func main() {
    animals := []Animal{Dog{}, Cat{}}
    for _, animal := range animals {
        fmt.Println(animal.Speak())
    }
}
```
Dog，Cat都是Animal类型

## 空接口 	interface{}
`interface{}`作为方法参数的例子
```go
func DoSomething(v interface{}) {
   // ...
}
```
在上面例子中，v是interface{}类型，它可以接收任意类型的值，并将值转换为`interface{}`类型

一个接口包含两个值，底层类型和指向数据的指针，`[]T`不等于`[]interface{}`

```go
func (c *Cat) Speak() string {
    return "Meow!"
}

animals := []Animal{Dog{}, Cat{}}
```
这里会报错，因为是`*Cat`实现了Animal接口，而不是Cat

```go
func (c Cat) Speak() string {
    return "Meow!"
}

animals := []Animal{Dog{}, &Cat{}}
```
这里不会报错，因为指针类型`&Cat`可以访问值类型
Go 中的所有东西都是按值传递的
