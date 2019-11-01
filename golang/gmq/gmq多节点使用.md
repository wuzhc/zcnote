如图:
![多节点使用](https://gitee.com/wuzhc123/zcnote/raw/master/images/gmq/gmq%E5%A4%9A%E8%8A%82%E7%82%B9%E6%B3%A8%E5%86%8C.png)
- node节点为客户端提供消息处理的服务
- 每一个node节点启动的时候,都会向register注册中心注册自己的信息
- 客户端通过获取register注册中心已注册的节点列表,然后选择节点建立连接

说明:  
在这个过程中,`register`仅仅只是提供`node`节点信息存储,不参与其他业务,而`client`是直接连接到`node`,所以即使`register`挂掉,也不会影响`node`的运行,客户端仍然可以继续推送消费消息

## 多节点使用
`register`提供了用于获取节点列表`api`接口,register`启动时http默认端口为`9595`,可以通过调用`http://127.0.0.1:9595/getNodes`获取,返回结构如下:
```json
{
    "code": 0,
    "data": {
        "nodes": [
            {
                "id": 2,
                "http_addr": "127.0.0.1:9508",
                "http_tls": 0,
                "tcp_addr": "127.0.0.1:9505",
                "tcp_tls": 0,
                "join_time": "2019-10-23 15:05:10",
                "weight": 5,
            }
        ]
    },
    "msg": "success"
}
```
- `id` 节点ID,取值范围为1到1024,每个节点的ID必须是唯一
- `http_addr` 节点http服务地址
- `http_tls` 是否启用tls,0否,1是
- `tcp_addr` 节点tcp服务地址
- `tcp_tls` 是否启用tls,0否,1是
- `join_time` 节点注册时间
- `weight` 节点权重,客户端可以根据节点权重分配消息

## 客户端建立和节点的连接
首先需要从注册中心获得所有节点信息,然后根据节点的`tcp_addr`地址来建立连接,一个客户端会维护一个节点连接,客户端结构如下:

```go
type Client struct {
	conn   net.Conn // 维护与节点建立的连接
	addr   string   // 对应节点的tcp_addr
	weight int      // 对应节点的weight
}
```
根据所有节点初始化客户端
```go
// 初始化客户端,建立和注册中心节点连接
func InitClients(registerAddr string) ([]*Client, error) {
	url := fmt.Sprintf("%s/getNodes", registerAddr)
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	data, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	type Node struct {
		Id       int64  `json:"id"`
		HttpAddr string `json:"http_addr"`
		TcpAddr  string `json:"tcp_addr"`
		JoinTime string `json:"join_time"`
		Weight   int    `json:"weight"`
	}
	v := struct {
		Code int `json:"code"`
		Data struct {
			Nodes []*Node `json:"nodes"`
		} `json:"data"`
		Msg string `json:"msg"`
	}{}

	if err := json.Unmarshal(data, &v); err != nil {
		return nil, err
	}

	var clients []*Client
	for i := 0; i < len(v.Data.Nodes); i++ {
		c := NewClient(v.Data.Nodes[i].TcpAddr, v.Data.Nodes[i].Weight)
		clients = append(clients, c)
	}

	return clients, nil
}
```

## 例子
### 平均投递消息模式
每次使用第一个客户端的连接进行消息投递,之后再将该投递过消息的客户端添加到`clients`切片末尾
```go
// 平均模式,每次从取第一个客户端,进行消息投递
func GetClientByAvgMode() *Client {
	if len(clients) == 0 {
		var err error
		clients, err = InitClients("http://127.0.0.1:9595")
		if err != nil {
			log.Fatalln(err)
		}
	}

	c := clients[0]
	if len(clients) > 1 {
		// 已处理过的消息客户端重新放在最后
		clients = append(clients[1:], c)
	}

	return c
}

// 模拟10个消息投递过程
for i := 0; i < 10; i++ {
	c := GetClientByAvgMode()
	fmt.Println(c.GetAddr())
	Example_Produce(c, "golang")
}
```

### 按节点权重投递消息模式 
```go
func GetClientByWeightMode() *Client {
	if len(clients) == 0 {
		var err error
		clients, err = InitClients("http://127.0.0.1:9595")
		if err != nil {
			log.Fatalln(err)
		}
	}

	total := 0
	for _, c := range clients {
		total += c.weight
	}

	w := 0
	rand.Seed(time.Now().UnixNano())
	randValue := rand.Intn(total) + 1
	for _, c := range clients {
		prev := w
		w = w + c.weight
		if randValue > prev && randValue <= w {
			return c
		}
	}

	return nil
}

// 模拟10个消息投递过程
for i := 0; i < 10; i++ {
	c := GetClientByWeightMode()
	fmt.Println(c.GetAddr())
	Example_Produce(c, "golang")
}
```

### 随机投递消息模式
```go
func GetClientByRandomMode() *Client {
	if len(clients) == 0 {
		var err error
		clients, err = InitClients("http://127.0.0.1:9595")
		if err != nil {
			log.Fatalln(err)
		}
	}

	rand.Seed(time.Now().UnixNano()) // 为了方便测试加的
	k := rand.Intn(len(clients))
	return clients[k]
}

// 模拟10个消息投递过程
for i := 0; i < 10; i++ {
	c := GetClientByRandomMode()
    fmt.Println(c.GetAddr())
    Example_Produce(c, "golang")
}
```

## 客户端完整代码
- [gmq客户端完整代码](https://github.com/wuzhc/gmq-client)

