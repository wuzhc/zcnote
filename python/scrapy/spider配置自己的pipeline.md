> 在settings.py里面配置pipeline，这里的配置的pipeline会作用于所有的spider，我们可以为每一个spider配置不同的pipeline，

设置 Spider 的 custom_settings对象属性

```python
class UserInfoSpider(CrawlSpider):
 # 自定义配置
 custom_settings = {
     'ITEM_PIPELINES': {
     'tutorial.pipelines.TestPipeline.TestPipeline': 1,
     }
 }
```

新版本的这个属性让每个spider都有一个专门的pipeline处理数据了，当同时运行多个spider的时候会非常有用，老版本的时候还要进行判断