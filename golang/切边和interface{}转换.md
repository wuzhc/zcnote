## 切片和[]interface{}转换
如果直接将data:=[]string{"one","two"}传递给类型为[]interface{}的参数时，会报错 cannot use  (type []string) as type []interface {} in argument，why???  
这里需要明白的是[]interface{}和interfae{}不是同个概念，interface{}表示任意类型
```go
package main
import (
    "fmt"
)
func PrintAll(vals []interface{}) {
    for _, val := range vals {
        fmt.Println(val)
    }
}
func main() {
    names := []string{"stanley", "david", "oscar"}
    vals := make([]interface{}, len(names))
    for i, v := range names {
        vals[i] = v
    }
    PrintAll(vals)
}
```

