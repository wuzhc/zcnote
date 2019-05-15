## 编码
go结构转为json成为`marshal`,通过`json.marshal`来实现,返回结果是字节,不是json字符串

- 只有可导出成员才可以转换为json字段,所以结构体成员都定义为首字母大写
- `json:"title"`是成员标签,格式为`json:"value"`
```go
package main

import (
	"encoding/json"
	"fmt"
)

type Movie struct {
	Title  string   `json:"title"`
	Year   int      `json:"year"`
	Color  bool     `json:"color,omitempty"`
	Actors []string `json:"actors"`
}

func main() {
	data := []Movie{
		{Title: "钢铁侠3", Year: 2015, Color: false, Actors: []string{"托尼"}},
		{Title: "复仇者联盟4", Year: 2019, Color: true, Actors: []string{"黑寡妇", "美国队长"}},
	}

	jsonData, err := json.Marshal(data)
	if err != nil {
		fmt.Println(err)
	} else {
		fmt.Printf("%s\n", jsonData)
	}

	jsonData2, err := json.MarshalIndent(data, "", "    ")
	if err != nil {
		fmt.Println(err)
	} else {
		fmt.Println(string(jsonData2))
	}
}

```

## 解码
json转换为go结构`Unmarshal`,通过`json.Unmarshal`来实现,注意参数是直接,不是json字符串
```go
package main

import (
	"encoding/json"
	"fmt"
)

type Movie struct {
	Title  string   `json:"title"`
	Year   int      `json:"year"`
	Color  bool     `json:"color,omitempty"`
	Actors []string `json:"actors"`
}

func main() {
	// json转为go结构体
	var titles []struct {
		Title string
		// 没有定义其他字段,将被舍弃
	}
	if err := json.Unmarshal(jsonData, &titles); err != nil {
		fmt.Println(err)
	} else {
		fmt.Println(titles)
	}
}
```

## 流式编码
```go
package github

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"strings"
)

const api = "https://api.github.com/search/issues"

type SearchResult struct {
	TotalCount        int  `json:"total_count"`
	IncompleteResults bool `json:"incomplete_results"`
	Items             []*Item
}

type Item struct {
	Url           string
	RepositoryUrl string `json:"repository_url"`
	Title         string
	Id            int
	HtmlUrl       string `json:"html_url"`
	CreateAt      string `json:"create_at"`
	UpdateAt      string `json:update_at`
	Body          string
	score         float64
	User          *User
	Labels        []*Label
}

type User struct {
	Login     string
	Id        int
	Url       string
	AvatarUrl string `json:"avatar_url"`
}

type Label struct {
	Id     int
	NodeId string `json:"node_id"`
	Url    string
	Name   string
	Color  string
}

func SearchIssues(terms []string) (*SearchResult, error) {
	q := url.QueryEscape(strings.Join(terms, " "))
	resp, err := http.Get(api + "?q=" + q)
	if err != nil {
		return nil, err
	} else {
		fmt.Println(api + "?q=" + q)
		defer resp.Body.Close()
	}

	// 请求失败关闭resp.Body
	if resp.StatusCode != http.StatusOK {
		resp.Body.Close()
		return nil, fmt.Errorf("search query failed :%s\n", resp.Status)
	}

	var result SearchResult
	err = json.NewDecoder(resp.Body).Decode(&result)
	if err != nil {
		return nil, err
	}

	return &result, nil
}

```