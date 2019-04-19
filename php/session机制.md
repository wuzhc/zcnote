### session_start()初始化工作
- 读取名为PHPSESSID的cookie值，这个值内容保存这session对应存储的文件名，假设为abc123（由系统生成）
- 若PHPSESSID存在，创建$_SESSION变量，读取session文件（如SESS_abc123），读取到的内容填充到$_SESSION变量中；若PHPSESSID不存在，创建$_SESSION和session文件（SESS_abc123），将abc123作为名喂PHPSESSID的cookie值返回给游览器
- 由此可见，如果需要解决跨域问题，第一需要共享session文件，第二客户端不能丢失sessionID

### session_id($id string)
返回当前会话ID，如果指定参数$id，则需要在session_start()之前调用，返回设置为$id的会话

### 垃圾回收机制
session回收发生在session_start()，但不是每次都会执行回收，由session.gc_probability 和 session.gc_divisor两个选项决定，计算如下：  
系统会根据session.gc_probability/session.gc_divisor 公式计算概率，例如选项 session.gc_probability = 1，选项 session.gc_divisor = 100，这样概率就变成了 1/100，也就是 session_start()函数被调用 100 次才会启动一次 “ 垃圾回收程序 ” 。所以对会话页面访问越频繁，启动的概率就越来越小。一般的建议为 调用1000-5000次才会启动一次： 1/(1000~5000)。

### 登录问题
一般登录时候不会设置cookie过期时间，当游览器退出时，cookie失效，用户需要再次登录；若设置了记住密码，实际上是设置了cookie的过期时间，当游览器退出时，只要cookie没过期，就不需要再次登录（前提是在退出游览器时，用户不能点击退出登录）

### GO实现session
```go
package session

import (
	"encoding/json"
	"io/ioutil"
	"log"
	"math/rand"
	"net/http"
	"os"
	"sync"
	"time"
)

const (
	SESS_PREFIX    string = "sess_"
	COOKIE_NAME    string = "PHPSESSID"
	GC_PROBABILITY int    = 1
	GC_DIVISOR     int    = 100
	SAVE_PATH      string = "sess_files/"
	MAX_LIFE_TIME  int64  = 86400
)

type Session struct {
	Req     http.Request
	Writer  http.ResponseWriter // 请求
	Sfile   string              // session文件名
	Sdata   map[string]string   // session值
	Lock    sync.RWMutex
	IsStart bool
}

func (s *Session) start() {
	defer s.Lock.Unlock()
	s.Lock.Lock()

	if s.IsStart {
		return
	}

	cookie, err := s.Req.Cookie(COOKIE_NAME)
	if err != nil {
		log.Fatal(err)
	}

	// 设置为启动
	s.IsStart = true

	// 首次访问，生成名为PHPSESSID的cookie到客户端
	if !cookie {
		s.Sfile = SESS_PREFIX + GetRandomString(10)
		cookie = http.Cookie{Name: COOKIE_NAME, Value: s.SFile, Path: "/", MaxAge: "86400"}
		http.SetCookie(http.Writer, &cookie)
		return
	} else {
		s.Sfile = SESS_PREFIX + cookie.Value
	}

	// 读取session值,并设置值
	file, err := os.Open(s.Sfile)
	if err != nil {
		log.Fatal(err)
	}
	buf := make([]byte, 0)
	_, err := file.Read(buf)
	if err != nil {
		log.Fatal(err)
	}
	s.Sdata = make(map[string]string)
	json.Unmarshal(buf, s.Sdata)

	// 回收机制
	rand.Seed(time.Now().Unix())
	base := rand.Intn(GC_DIVISOR)
	if GC_PROBABILITY <= base {
		overtimeFiles, err := ioutil.ReadDir(SAVE_PATH)
		if err != nil {
			log.Fatal(err)
		}

		for _, fi := range overtimeFiles {
			modTime := fi.ModTime().Unix()
			if modTime-time.Now().Unix() > MAX_LIFE_TIME {
				os.Remove(SAVE_PATH + string(os.PathSeparator) + fi.Name())
			}
		}
	}
}

func (s *Session) Set(key string, value string) {
	if !s.IsStart {
		log.Fatal("session is not start")
	}

	if s.Sdata == nil {
		s.Sdata = make(map[string]string)
	}
	s.Sdata[key] = value
}

func (s *Session) Get(key string) string {
	if !s.IsStart {
		log.Fatal("session is not start")
	}

	if v, ok := s.Sdata[key]; ok {
		return string(v)
	} else {
		return ""
	}
}

func (s *Session) Save() {
	if !s.IsStart {
		log.Fatal("session is not start")
	}

	str, err := json.Marshal(s.Sdata)
	if err != nil {
		log.Fatal(err)
	}

	file, err := os.Open(s.Sfile)
	if err != nil {
		log.Fatal(err)
	}

	n, err := file.Write([]byte(str))
	if err != nil || n != len(str) {
		log.Fatal("save session failed")
	}
}

// 随机字符串
func GetRandomString(l int) string {
	str := "0123456789abcdefghijklmnopqrstuvwxyz"
	bytes := []byte(str)
	result := []byte{}

	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	for i := 0; i < l; i++ {
		result = append(result, bytes[r.Intn(len(bytes))])
	}

	return string(result)
}

```