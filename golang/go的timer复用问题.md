# 重用timer
> 重用的timer的目的在于减少减少创建timer实例

## 参考
- https://studygolang.com/articles/9289

## 重置条件
- 第一步是要确定timer是否已过期,用`timer.Stop`确定,`true`表示timer未过期,`false`表示timer已过期
- timer已过期,选择性抽干channel,然后调用`time.Reset`
- timer未过期,`timer.Stop`返回`true`,此时不必关系channel会被删除,可以直接调用`time.Reset`

## 代码
```go
	go func() {
        timer := time.NewTimer(time.Second * 5)
        for {
            // 不管有没有过期,我们都尝试stop timer,成功表示timer未过期,失败表示timer已过期
            if !timer.Stop() {
                select {
                case <-timer.C: // 尝试抽干channel,因为不知道channel过期之前是否已经被抽干了,但是这不是完美的,会有竞争条件
                default:
                }
            }
            timer.Reset(time.Second * 5)
            select {
            case b := <-c:
                if b == false {
                    fmt.Println(time.Now(), ":recv false. continue")
                    continue
                }
                //we want true, not false
                fmt.Println(time.Now(), ":recv true. return")
                return
            case <-timer.C:
                fmt.Println(time.Now(), ":timer expired")
                continue
            }
        }
    }()
```
说明:
- `timer`过期,之后从最小堆移除,此时调用`timer.Stop`会失败,失败之后需要显示抽干channel
- `timer`未过期,调用`timer.Stop`成功(此时channel抽干),可以直接调用`timer.Reset`
- `timer`未过期,若调用`timer.Stop`失败,此时channel有可能之前被抽干,也有可能未被抽干,这个时候需要用`select{}`选择性抽干

## time.timer和time.ticker的区别
- `time.timer` 一次性,到期后会从最小堆移除,可以用`time.Reset`实现持续运行效果
- `time.ticker` 持续性,到期后执行下个周期