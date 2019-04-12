![](https://images2015.cnblogs.com/blog/931154/201703/931154-20170314141524729-978666187.png)

## Scrapy运行流程大概如下：

- 引擎从调度器中取出一个链接(URL)用于接下来的抓取
- 引擎把URL封装成一个请求(Request)传给下载器
- 下载器把资源下载下来，并封装成应答包(Response)
- 爬虫解析Response
- 解析出实体（Item）,则交给实体管道进行进一步的处理
- 解析出的是链接（URL）,则把URL交给调度器等待抓取

## 参考

- ()[https://scrapy-chs.readthedocs.io/zh_CN/latest/topics/architecture.html]