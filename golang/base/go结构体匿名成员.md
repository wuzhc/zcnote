Go语言的结构体中可以包含匿名的字段，比如：
```go
struct {
    T1       // 字段名自动为 T1
    *T2      // 字段名自动为 T2
    P.T3     // 字段名自动为 T3
    *P.T4    // 字段名自动为 T4
    x, y int  // 非匿名字段 x ， y
}
```
- 如果构体 S，包含一个匿名字段 T，那么这个结构体 S 就有了 T的方法和属性。
- 如果包含的匿名字段为`*T`，那么这个结构体 S 就有了 `*T` 的方法和属性。

```go
package main

import (
    "fmt"
)

type People struct {
    name   string
    age    int
    weight int
}

type Student struct {
    *People
    specialty string
}

func (p *People) GetName() string {
    return p.name
}

func main() {
    liming := Student{&People{"liming", 18, 183}, "None Specialty"}
    fmt.Println(liming.name)

    uname:=liming.GetName() # 相等于 liming.People.GetName()
    fmt.Println(uname) 
}
```