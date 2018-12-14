- runtime.Goexit() // 终止当前 goroutine
- runtime.Gosched()用于让出CPU时间片
- 如果某个goroutine panic了，而且这个goroutine里面没有捕获(recover)，那么整个进程就会挂掉。所以，好的习惯是每当go产生一个goroutine，就需要写下recover。

### 1. 协程执行顺序

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	go func() {
		for i := 0; i < 10; i++ {
			fmt.Println("a")
		}
	}()

	go func() {
		for i := 0; i < 10; i++ {
			fmt.Println("b")
		}
	}()

	go func() {
		for i := 0; i < 10; i++ {
			fmt.Println("c")
		}
	}()

	time.Sleep(30 * time.Second)
}
```

输出结果如下：

```bash
a
a
a
a
c
c
c
c
c
c
c
c
c
c
b
b
b
b
b
b
b
b
b
b
a
a
a
a
a
a
```

这说明了一旦创建一个协程，代码不一定会协程中的代码，各个协程执行顺序由系统调用，没有先后的说法



### 2. 通道

#### 2.1 注意

- 如果是先向通道写输入，如c <- 1，需要确保创建通道时候设置队列，例如make(chan int, 10)，否则会报fatal error: all goroutines are asleep - deadlock!
- 如果是先读取通道数据，如<- c，如果通道没有数据，将一直阻塞