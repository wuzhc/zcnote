# golang的select功能
select用来监io事件,一般用于监控channel的读和写

## 特性
- 没有io事件时,select会阻塞
- 同时多个io事件发生时,随机执行某一个
- 一次只执行一个io事件
- 如果有default,则在没有io事件时执行

`break`不能跳出`for-select`循环,需要用`return`,或用`goto`