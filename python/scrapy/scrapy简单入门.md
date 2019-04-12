## 基本流程
- - 1.创建项目：scrapy startproject 项目名称
- 2.新建爬虫：scrapy genspider 爬虫文件名 爬虫基础域名
- 3.编写item (这里定义了要爬虫的数据结构)
- 4.spider最后return item
- 5.在setting中修改pipeline配置
- 6.在对应pipeline中进行数据持久化操作

##  设置日志输出级别
scrapy默认情况下是debug级别,console会输出很多很乱的东西;为了简化console的输出,我们可以设置`LOG_LEVEL`的级别;如下:

```python
# settings.py
LOG_LEVEL = 'ERROR'
```

支持的级别有:
- CRITICAL - 严重错误
- ERROR - 一般错误
- WARNING - 警告信息
- INFO - 一般信息
- DEBUG - 调试信息

## 
```bash
scrapy crawl your-spider-name -s JOBDIR=job-dir
```