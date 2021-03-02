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



