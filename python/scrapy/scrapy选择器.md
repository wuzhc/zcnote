# 选择器
> 用于从html源码中提取数据

## 构造选择器
```python
 from scrapy.selector import Selector
 body = '<html><body><span>good</span></body></html>'
 Selector(text=body).xpath('//span/text()').extract()
 # ['good']
```
或者
```python
response = HtmlResponse(url='http://example.com', body=body)
response.selector.xpath('//span/text()').extract()
# ['good']
```

## 使用选择器
其为响应的response， 并且在其 response.selector 属性上绑定了一个selector,提取文字如下: `response.selector.xpath('//title/text()')`  
python提供了两个快捷方法`response.xpath`和`response.css`,返回的`SelectorList`的实例,提取数据只需要调用`.extract()`即可,如下:
```python
response.xpath('//title/text()').extract()
# 或者
response.css('title::text').extract()
```
### 正确表达式匹配
`.re()`返回的是unicode字符串列表,使用如下:
```python
# <a href="image1.html">Name: My image 1 <br><img src="image1_thumb.jpg"></a>
 response.xpath('//a[contains(@href, "image")]/text()').re(r'Name:\s*(.*)')
 # My image 1
```

## xpath

### 节点选择
- nodename	选取此节点的所有子节点。
- / 从根节点选取。
- // 从匹配选择的当前节点选择文档中的节点，而不考虑它们的位置。
	 .	选取当前节点。
- ..  选取当前节点的父节点。
- @ 选取属性。

### 例子
```python
xpath('//div[contains(@class,"a") and contains(@class,"b")]') #它会取class含有有a和b的元素

xpath('//div[contains(@class,"a") or contains(@class,"b")]') #它会取class 含有 a 或者 b满足时，或者同时满足时的元素

 xpath('//a[contains(@href, "image")]/img/@src') # 选择属性href含有image的子标签img的src属性
 
 xpath('input[starts-with(@name,'name1')]') # 查找name属性中开始位置包含'name1'关键字的页面元素
 
 xpath('//div[contains(text(),"ma")') # 选择节点文本包含ma的div节点
 
 # <li class="item-0"><a href="link1.html">first item</a></li>
 xpath('//li[re:test(@class, "item-\d$")]//@href') # 正则匹配获取href属性
 
 # <a href="#">Click here to go to the <strong>Next Page</strong></a>
 xpath('//a//text()').extract() 
 # 输出[u'Click here to go to the ', u'Next Page']
 # 如果不想输出strong标签的东西,使用如下
 xpath("string(//a[1]//text())").extract()
```

### 其他例子
`//node[1]`和`(//node)[1]`的区别
```bash
>>> from scrapy import Selector
>>> sel = Selector(text="""
....:     <ul class="list">
....:         <li>1</li>
....:         <li>2</li>
....:         <li>3</li>
....:     </ul>
....:     <ul class="list">
....:         <li>4</li>
....:         <li>5</li>
....:         <li>6</li>
....:     </ul>""")
>>> xp = lambda x: sel.xpath(x).extract()
```
```bash
>>> xp("//li[1]")
[u'<li>1</li>', u'<li>4</li>']
```
`//li[1]`返回所有父元素第一个li
```bash
>>> xp("(//li)[1]")
[u'<li>1</li>']
```
`(//li)[1]`返回整个文档的第一个li

## 参考
- [选择器(Selectors)](https://scrapy-chs.readthedocs.io/zh_CN/latest/topics/selectors.html#topics-selectors)
