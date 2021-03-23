swoole的同步阻塞客户端可以用在`FPM/Apache`环境

相对传统的 [streams](https://www.php.net/streams) 系列函数，有几大优势：

- `stream` 函数存在超时设置的陷阱和 `Bug`，一旦没处理好会导致 `Server` 端长时间阻塞
- `stream` 函数的 `fread` 默认最大 `8192` 长度限制，无法支持 `UDP` 的大包
- `Client` 支持 `waitall`，在有确定包长度时可一次取完，不必循环读取
- `Client` 支持 `UDP Connect`，解决了 `UDP` 串包问题
- `Client` 是纯 `C` 的代码，专门处理 `socket`，`stream` 函数非常复杂。`Client` 性能更好
- `Client` 支持长连接