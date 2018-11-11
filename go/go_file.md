```go
package main

import (
	"fmt"
	"os"
)

func main() {
	if dir, err := os.Getwd(); err != nil {
		fmt.Println("get dir failed : ", err)
	} else {
		fmt.Println("current dir is : ", dir)
	}

	// mkdir
	if err := os.Mkdir("./mydir", 0777); err != nil {
		fmt.Println("mkdir failed : ", err)
		if os.IsExist(err) {
			fmt.Println("file or dir is exist")
		}
		if os.IsNotExist(err) {
			fmt.Println("file or dir is not exist")
		}
	}

	// mkdirall
	if err := os.MkdirAll("./golang/go/go", 0777); err != nil {
		fmt.Println("mkdirall failed", err)
	}
	if err := os.Rename("./mydir", "./mydirr"); err != nil {
		fmt.Println("rename failed", err)
	}
}

```