## 参考
### 样式预览
- https://highlightjs.org/static/demo/
### 样式文件
- https://github.com/highlightjs/highlight.js/tree/master/src/styles
### php解析markdown
- https://github.com/SegmentFault/HyperDown.git

## 使用
```php
<?php
require_once __DIR__ . '/Parser.php';
$parser = new HyperDown\Parser;
$html = $parser->makeHtml(file_get_contents('/data/wwwroot/doc/zcnote/php/install.md'));
?>

<link rel="stylesheet"
      href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.6/styles/an-old-hope.min.css">
<script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.6/highlight.min.js"></script>
<script >hljs.initHighlightingOnLoad();</script>
<div>
    <?php echo $html;?>
</div>

```