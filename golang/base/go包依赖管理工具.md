# govendor使用
## 参考 
- https://blog.csdn.net/benben_2015/article/details/80614873

如果还没安装`govendor`,需要先安装
```bash
go get -u github.com/kardianos/govendor
```

## 使用
```bash
# 进到项目目录
cd GOPATH/src/your-project
# 自动生成vendor文件夹（存放你项目需要的依赖包）和vendor.json文件（有关依赖包的描述文件）
govendor init
# 添加扩展,比如会将github.com依赖的包放到vendor目录下
govendor add +e
```

## 其他命令
```go
# 快速查看你项目中的外部依赖包
govendor list

# 添加依赖包到vendor目录下，在使用 govendor add命令时，后面需要跟上下面介绍的一些状态，也可以直接跟上缺失包的地址 
govendor add

# 从你的GOPAHT中更新你工程的依赖包
govendor update

# 从你工程下的vendor文件中移除对应的包
govendor remove 

# 添加或者更新vendor文件夹中的包
govendor fetch
```

## govendor list状态说明
```bash
+local     (l) 表示工程中的包
+external  (e) 从GOPATH中引用的包，但不包含在你的当前工程中
+vendor    (v) vendor文件夹中的包
+std       (s) Go标准库中的包
+excluded  (x) 从vendor文件中排除的外部依赖包
+unused    (u) vendor文件中存在但却未使用的包
+missing   (m) 项目引用但却为发现的包
+program   (p) main包中包
```

# glide使用
## 安装 
```
git clone https://github.com/xkeyideal/glide.git $GOPATH/src/github.com/xkeyideal/glide
cd $GOPATH/src/github.com/xkeyideal/glide
make install
```
## 项目使用
- 进到项目中,执行`glide init`,该命令会把项目已经依赖的包写入到`glide.yaml`
- 如果有新导入的包,可以用`glide get github.com/wuzhc/gmq`的命令导入,类似于`go get`用法
- 安装依赖,执行`glide install`,该命令会生成`glide.lock`,这个文件记录依赖包列表和版本,当在其他地方安装时候,会根据`glide.lock`来安装包 
- 使用过程中,可能会升级包版本等等,可以使用`glide update`命令
```
glide init #初始化
glide get <package_name> #获取包
glide install #生成`glide.lock`
glide update #升级或更新包
glide list #查看依赖名称
glide --version #版本
```

## 解决翻墙问题
例如访问不了`https://golang.org/x/sys/unix`,可以将它映射到`github.com`上,如下
```
# 先映射,写入到`mirrors.yaml`文件
glide mirror set https://golang.org/x/sys/unix https://github.com/golang/sys --base golang.org/x/sys
# 再导入
glide get golang.org/x/sys/unix
# 可以查看镜像映射列表
glide mirror list 
```




