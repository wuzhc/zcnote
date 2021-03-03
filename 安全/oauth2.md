> OAuth（开放授权）是一个关于授权的开放标准，允许让第三方应用使用我们的用户来访问第三方应用（举个例子，用户通过QQ授权，可以使用QQ账号来登录A站，此过程中A站是第三方应用）

## 应用场景
- 授权登录，免去注册账号等繁琐操作
- 保护授权资源，是不是可以设置授权过期时间？

## 流程
发出凭证->验证凭证->发出请求访问令牌->验证令牌->返回受保护资源

## 模式
- 授权码模式（authorization code）
- 简化模式（implicit）
- 密码模式（resource owner password credentials）
- 客户端模式（client credentials）

## 例子
以github为例
- 首先我的网站需要关联github，并获取的github的一些权限，此时github会给我的网站一个client ID 和client secret两个东西
- 用户点击授权跳转到github授权页面，因为clientID，github知道是我的网站，所以列出我的网站获取的github权限，并且询问用户是否允许这些权限
```bash
// 用户登录 github，协商
GET //github.com/login/oauth/authorize
// 协商凭证
params = {
  client_id: "xxxx",
  redirect_uri: "http://my-website.com"
}
```
- 如果用户同意，跳转到redirect_uri，并带上code
```bash
// 协商成功后带着盖了章的 code
Location: http://my-website.com?code=xxx
```
- 前面的code只表示用户允许我的网站从github上获取用户的数据，所以接下来github需要验证我的网站的秘钥，来看这次请求是否合法，合法之后返回授权令牌
```bash
// 网站和 github 之间的协商
POST //github.com/login/oauth/access_token
// 协商凭证包括 github 给用户盖的章和 github 发给我的门票
params = {
  code: "xxx",
  client_id: "xxx",
  client_secret: "xxx",
  redirect_uri: "http://my-website.com"
}
```
- 成功授权之后，返回
```bash
// 拿到最后的绿卡
response = {
  access_token: "e72e16c7e42f292c6912e7710c838347ae178b4a"
  scope: "user,gist"
  token_type: "bearer",
  refresh_token: "xxxx"
}
```



## 授权码模式

- a站请求b站，b站验证返回授权码
- a站带授权码，client_id，client_secret请求b站，获取access_token
- a站带access_token请求b站的资源

第一步，A 网站提供一个链接，用户点击后就会跳转到 B 网站，授权用户数据给 A 网站使用。下面就是 A 网站跳转 B 网站的一个示意链接。

```bash
https://b.com/oauth/authorize?
  response_type=code&
  client_id=CLIENT_ID&
  redirect_uri=CALLBACK_URL&
  scope=read
```

上面 URL 中，`response_type`参数表示要求返回授权码（`code`），`client_id`参数让 B 知道是谁在请求，`redirect_uri`参数是 B 接受或拒绝请求后的跳转网址，`scope`参数表示要求的授权范围（这里是只读）。

第二步，请求到B站，B 网站会要求用户登录，然后询问是否同意给予 A 网站授权。用户表示同意，这时 B 网站就会跳回`redirect_uri`参数指定的网址。跳转时，会传回一个授权码，就像下面这样。

```bash
https://a.com/callback?code=AUTHORIZATION_CODE
```

上面 URL 中，`code`参数就是授权码。

 第三步，A 网站拿到授权码以后，就可以在后端，向 B 网站请求令牌。

```bash
https://b.com/oauth/token?
 client_id=CLIENT_ID&
 client_secret=CLIENT_SECRET&
 grant_type=authorization_code&
 code=AUTHORIZATION_CODE&
 redirect_uri=CALLBACK_URL
```

上面 URL 中，`client_id`参数和`client_secret`参数用来让 B 确认 A 的身份（`client_secret`参数是保密的，因此只能在后端发请求），`grant_type`参数的值是`AUTHORIZATION_CODE`，表示采用的授权方式是授权码，`code`参数是上一步拿到的授权码，`redirect_uri`参数是令牌颁发后的回调网址。

第四步，B 网站收到请求以后，就会颁发令牌。具体做法是向`redirect_uri`指定的网址，发送一段 JSON 数据。

```json
{    
  "access_token":"ACCESS_TOKEN",
  "token_type":"bearer",
  "expires_in":2592000,
  "refresh_token":"REFRESH_TOKEN",
  "scope":"read",
  "uid":100101,
  "info":{...}
}
```

上面 JSON 数据中，`access_token`字段就是令牌，A 网站在后端拿到了。

 

## 简化模式

- a站请求b站，验证成功直接返回access_token
- a站带access_token请求资源

第一步，A 网站提供一个链接，要求用户跳转到 B 网站，授权用户数据给 A 网站使用。

```bash
https://b.com/oauth/authorize?
  response_type=token&
  client_id=CLIENT_ID&
  redirect_uri=CALLBACK_URL&
  scope=read
```

上面 URL 中，`response_type`参数为`token`，表示要求直接返回令牌。

 第二步，用户跳转到 B 网站，登录后同意给予 A 网站授权。这时，B 网站就会跳回`redirect_uri`参数指定的跳转网址，并且把令牌作为 URL 参数，传给 A 网站。

```bas
https://a.com/callback#token=ACCESS_TOKEN
```

上面 URL 中，`token`参数就是令牌，A 网站因此直接在前端拿到令牌。

注意，令牌的位置是 URL 锚点（fragment），而不是查询字符串（querystring），这是因为 OAuth 2.0 允许跳转网址是 HTTP 协议，因此存在"中间人攻击"的风险，而浏览器跳转时，锚点不会发到服务器，就减少了泄漏令牌的风险。

这种方式把令牌直接传给前端，是很不安全的。因此，只能用于一些安全要求不高的场景，并且令牌的有效期必须非常短，通常就是会话期间（session）有效，浏览器关掉，令牌就失效了。

 

## 密码模式

- a站要求有b站的账号密码，a带着b站的账号密码直接请求b站

第一步，A 网站要求用户提供 B 网站的用户名和密码。拿到以后，A 就直接向 B 请求令牌。

```bash
https://oauth.b.com/token?
  grant_type=password&
  username=USERNAME&
  password=PASSWORD&
  client_id=CLIENT_ID
```

上面 URL 中，`grant_type`参数是授权方式，这里的`password`表示"密码式"，`username`和`password`是 B 的用户名和密码。

第二步，B 网站验证身份通过后，直接给出令牌。注意，这时不需要跳转，而是把令牌放在 JSON 数据里面，作为 HTTP 回应，A 因此拿到令牌。

这种方式需要用户给出自己的用户名/密码，显然风险很大，因此只适用于其他授权方式都无法采用的情况，而且必须是用户高度信任的应用。



## 客户端凭证模式

- a站直接用client_id和client_secret请求b站，获取access_token

第一步，A 应用在命令行向 B 发出请求。

```
https://oauth.b.com/token?
  grant_type=client_credentials&
  client_id=CLIENT_ID&
  client_secret=CLIENT_SECRET
```

上面 URL 中，`grant_type`参数等于`client_credentials`表示采用凭证式，`client_id`和`client_secret`用来让 B 确认 A 的身份。

第二步，B 网站验证通过以后，直接返回令牌。

这种方式给出的令牌，是针对第三方应用的，而不是针对用户的，即有可能多个用户共享同一个令牌。



## 令牌的使用

A 网站拿到令牌以后，就可以向 B 网站的 API 请求数据了。

此时，每个发到 API 的请求，都必须带有令牌。具体做法是在请求的头信息，加上一个`Authorization`字段，令牌就放在这个字段里面。

> ```
> curl -H "Authorization: Bearer ACCESS_TOKEN" \
> "https://api.b.com"
> ```

上面命令中，`ACCESS_TOKEN`就是拿到的令牌。



## 更新令牌

令牌的有效期到了，如果让用户重新走一遍上面的流程，再申请一个新的令牌，很可能体验不好，而且也没有必要。OAuth 2.0 允许用户自动更新令牌。

具体方法是，B 网站颁发令牌的时候，一次性颁发两个令牌，一个用于获取数据，另一个用于获取新的令牌（refresh token 字段）。令牌到期前，用户使用 refresh token 发一个请求，去更新令牌。

```bash
https://b.com/oauth/token?
  grant_type=refresh_token&
  client_id=CLIENT_ID&
  client_secret=CLIENT_SECRET&
  refresh_token=REFRESH_TOKEN
```

上面 URL 中，`grant_type`参数为`refresh_token`表示要求更新令牌，`client_id`参数和`client_secret`参数用于确认身份，`refresh_token`参数就是用于更新令牌的令牌。

B 网站验证通过以后，就会颁发新的令牌。



## 数据库表设计

oauth_access_tokens

oauth_auth_codes

### oauth_clients

保存用户申请的client_id，client_secret，redirect_url

oauth_personal_access_clients

oauth_refresh_tokens

