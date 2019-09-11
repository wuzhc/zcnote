## sync.Once
`sync.Once`控制函数只能被调用一次,不能重复调用,底层原理是利用原子计数记录`func`是否被执行`atomic.StoreUint32(&o.done, 1)`,已执行`sync.Once.done`会设置为1
```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	o := &sync.Once{}
	Do(o)
	Do(o)
}

func Do(o *sync.Once) {
	fmt.Println("start")
	o.Do(func() {
		fmt.Println("run....") // 只能调用一次
	})
	o.Do(func() {
        fmt.Println("re run") // 即时重置函数也不会调用
	})
	fmt.Println("end")
}
```
输出:
```bash
start
run....
end
start
end
```




