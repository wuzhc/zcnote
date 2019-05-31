![https://beego.me/docs/images/detail.png](https://beego.me/docs/images/detail.png)

- BeforeRouter 过滤器不能用session,应该在 AfterStatic 过滤器使用
- AfterStatic过滤器执行过程中,如果responseWriter 已经有数据输出,提前结束该请求，直接跳转到监控判断