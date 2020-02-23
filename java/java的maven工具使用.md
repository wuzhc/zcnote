## 参考
- https://www.liaoxuefeng.com/wiki/1252599548343744/1309301178105890

## maven简介
maven的作用是自动下载安装依赖到classpath，并且可以解决嵌套依赖的问题，可以从maven的中央仓库（repo1.maven.org）下载依赖，下载的依赖会被缓存到`.m2`目录

## 配置文件pom.xml
例如我要新增一个依赖，可以选择官网`https://search.maven.org/`查找有没有符合的依赖，然后复制内容，内容如下：
```xml
<dependency>
    <groupId>commons-logging</groupId>
    <artifactId>commons-logging</artifactId>
    <version>1.2</version>
</dependency>
```
- groupId 公司或组织的名称
- artifactId 项目名称
- version 版本
使用`<dependency>`声明一个依赖后，Maven就会自动下载这个依赖包并把它放到classpath中。

## 多种依赖关系
Maven定义了几种依赖关系，分别是`compile`编译时用到、`test`测试时用到、`runtime`运行时用到和`provided`编译时用到，运行时由jdk或某个服务提供
有什么意义呢？？？

## maven
http://maven.apache.org/download.cgi
远程仓库，本地仓库，核心配置文件`pom.xml`，提供了功能如下：
- 规范化项目，maven项目具有统一的项目结构
- 文档和报告，`mvn site`
- 类库管理，将项目依赖的的类库定义到`pom.xml`配置文件中
- 发布管理
	- `mvn compile`,编译maven项目，并生成target文件夹 
	- `mvn package`,将项目打包，默认打包为jar格式，也可以打包成war格式用于服务器运行
	- `mvn test`,测试
	- `mvn install`,将打包的jar文件安装到maven本地仓库
	- `mvn deploy`,部署
	- `mvn clean`,删除targert，相当于清除缓存

## maven替换为国内源
```xml
<mirrors>
    <mirror>
      <id>alimaven</id>
      <name>aliyun maven</name>
      <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
      <mirrorOf>central</mirrorOf>        
    </mirror>
</mirrors>
```