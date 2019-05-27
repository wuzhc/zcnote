## 参考
- https://blog.csdn.net/u011304970/article/details/72722044

```go
package main

import (
    "fmt"
)

func main() {
    go func() {
        fmt.Println("Goroutine 1")
    }()

    go func() {
        fmt.Println("Goroutine 2")
    }()
}
```
执行以上代码很可能看不到输出，因为有可能这两个协程还没得到执行主协程已经结束了，而主协程结束时会结束所有其他协程。

## 管道同步方法
```go
package main

import (
    "fmt"
)

func main() {

    ch := make(chan struct{})
    count := 2 // count 表示活动的协程个数

    go func() {
        fmt.Println("Goroutine 1")
        ch <- struct{}{} // 协程结束，发出信号
    }()

    go func() {
        fmt.Println("Goroutine 2")
        ch <- struct{}{} // 协程结束，发出信号
    }()

    for range ch {
        // 每次从ch中接收数据，表明一个活动的协程结束
        count--
        // 当所有活动的协程都结束时，关闭管道
        if count == 0 {
            close(ch)
        }
    }
}
```

## sync.WaitGroup
WaitGroup顾名思义，就是用来等待一组操作完成的。WaitGroup内部实现了一个计数器，用来记录未完成的操作个数，它提供了三个方法，Add()用来添加计数。Done()用来在操作结束时调用，使计数减一。Wait()用来等待所有的操作结束，即计数变为0，该函数会在计数不为0时等待，在计数为0时立即返回。
```go
package main

import (
    "fmt"
    "sync"
)

func main() {
    var wg sync.WaitGroup

    wg.Add(2) // 因为有两个动作，所以增加2个计数
    go func() {
        fmt.Println("Goroutine 1")
        wg.Done() // 操作完成，减少一个计数
    }()

    go func() {
        fmt.Println("Goroutine 2")
        wg.Done() // 操作完成，减少一个计数
    }()

    wg.Wait() // 等待，直到计数为0
}
```

## 简单总结
- 定义`var wg sync.WaitGroup`
- 增加一个`goroutine`就执行一下`wg.Add(1)`,必须在之前
- 执行完一个`goroutine`就执行下`wg.Done()`,计数减一
- 程序最后用`wg.Wait()`等待所有`goroutine`退出


