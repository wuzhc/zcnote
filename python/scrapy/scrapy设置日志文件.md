在`settings.py`文件下,添加如下:
```python
import datetime

to_day = datetime.datetime.now()
log_file_path = 'log/scrapy_{}_{}_{}'.fotmat(to_day.year,to_day.month,to_day.day)

LOG_FILE = log_file_path
LOG_LEVEL = 'ERROR'
```

以上设置了日志输出文件,使用时,可以导入`logging`,如下:
```python
import logging
logging.error('this is a error')
```