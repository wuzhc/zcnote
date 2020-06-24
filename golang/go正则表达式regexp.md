golang的正则表达式使用的`regexp`库
## 参考
https://segmentfault.com/a/1190000018244892
https://www.jianshu.com/p/7bd8324b0870

## 创建Regexp对象
可以用过`Complite`、`CompilePOSIX`、`MustCompile`、`MustCompilePOSIX`
`Compile` 用来解析正则表达式 expr 是否合法，如果合法，则返回一个 Regexp 对象

## 是否匹配
使用`MatchString`和`Match`,返回`bool`值
```golang
package main

import (
	"fmt"
	"log"
	"regexp"
)

func main() {
	//匹配字符串
	isMatch, err := regexp.MatchString("(?i)H(.*) world", "hello world")
	if err != nil {
		log.Fatalln(err)
	}
	fmt.Println(isMatch)

	//匹配字节
	isMatch, err = regexp.Match("(?i)H(.*) world", []byte("hello world"))
	if err != nil {
		log.Fatalln(err)
	}
	fmt.Println(isMatch)
	
	//使用compile
	r, _ := regexp.Compile("(?i)H(.*) world")
	fmt.Println(r.MatchString("hello world"))
}
```

## 根据匹配规则返回匹配的字符串
```go
r, _ := regexp.Compile("your(.*?)make(.*?)world")
result := r.FindString("make your hello make the world")
fmt.Println(result) //匹配正则,就返回能匹配上的正则那一段字符串
```

## 根据匹配规则返回匹配的字符串起始和结束位置
```go
r2,_:=regexp.Compile("lilei")
loc := r2.FindStringIndex("my name is lilei")
fmt.Println(loc) //返回[11,16],从0开始,11是l开始位置,16是i的位置加1
```

## 返回正则分组子串
```go
r3,_:=regexp.Compile("广东(.*?)茶(.*?)粒")
res2 := r3.FindStringSubmatch("广东凉茶颗粒")
fmt.Println(res2)//[广东凉茶颗粒 凉 颗]
```

## 替换所有匹配到所有正则
```go
//替换匹配所有正则
r4, _ := regexp.Compile("H([a-z]+)d!")
res3 := r4.ReplaceAllString("Hello World! Hwefd! Held! world Hmawefd!", "html")
fmt.Println(res3)
```

## 用方法来替换所有正则
```go
r5, _ := regexp.Compile("H([a-z]+)d!")
res5 := r5.ReplaceAllFunc([]byte("Hello World! Hwefd! Held! world Hmawefd!"), func(bytes []byte) []byte {
	return []byte("make")
})
fmt.Println(string(res5))
```






