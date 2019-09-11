### FileInfo接口
FileInfo接口，用于描述文件对象
```go
type FileInfo interface {
    Name() string       // 文件的名字（不含扩展名）
    Size() int64        // 普通文件返回值表示其大小；其他文件的返回值含义各系统不同
    Mode() FileMode     // 文件的模式位
    ModTime() time.Time // 文件的修改时间
    IsDir() bool        // 等价于Mode().IsDir()
    Sys() interface{}   // 底层数据来源（可以返回nil）
}
```
简单使用：
```go
fi, err := os.Stat("/data/wwwroot/go/src/hello/hello.go")
fmt.Println(fi.Name(), fi.Size(), fi.Mode(), fi.ModTime(), fi.IsDir())
```
os.FileInfo继承了FileInfo接口
```go
func main() {
	dir, err := ioutil.ReadDir("/data/wwwroot/go/") // []os.FileInfo, error
	if err != nil {
		fmt.Fprintf(os.Stderr, "fatal error: %s \n", err.Error())
	}
	for _, fi := range dir {
		fmt.Println(fi.Name())
	}
}
```

### 遍历目录文件即子目录文件
```go
filepath.Walk(root string, walkFn WalkFunc) error
type WalkFunc func(path string, info os.FileInfo, err error) error
```
```go
package main

import (
	"fmt"
	"os"
	"path/filepath"
)

func main() {
	files := make([]string, 0, 30)
	err := filepath.Walk("/data/wwwroot/go/", func(path string, fi os.FileInfo, err error) error {
		files = append(files, fi.Name())
		return err
	})
	if err != nil {
		fmt.Println(err)
	} else {
		for _, f := range files {
			fmt.Println(f)
		}
	}
}
```
