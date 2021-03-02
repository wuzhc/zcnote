所有异常都由类 `App\Exceptions\Handler` 处理，该类包含两个方法：`report` 和 `render`。下面我们详细阐述这两个方法。

 `report`方法将错误写到日志，`render`方法将错误响应给客户端（json和渲染页面的方式）