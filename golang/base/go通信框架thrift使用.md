## 参考
- https://www.jianshu.com/p/211ba5f5e787

## 1. 概述
RPC 是远程调用,主要是解决不在同一个进程内两个服务之间通信;是一种通过网络从远程计算机程序上请求服务的方式，它使得调用包括网络分布式多程序在内的应用程序更加容易。  

thrift数据传输上相对于 JSON 和 XML 无论在性能、传输大小上有明显的优势。Thrift 不仅仅是个高效的序列化工具，它是一个完整的 RPC 框架体系   

在流行的序列化/反序列化框架（如protocal buffer）中，Thrift是少有的提供多语言间RPC服务的框架。这是Thrift的一大特色。  

## 2. IDL定义通用服务接口
thrift 采用IDL（Interface Definition Language）来定义通用的服务接口，并通过生成不同的语言代理实现来达到跨语言、平台的功能。在thrift的IDL中可以定义以下一些类型：基本数据类型，结构体，容器，异常、服务
### 2.1 基本数据类型
- bool: 布尔值 (true or false), one byte
- byte: 有符号字节
- i16: 16位有符号整型
- i32: 32位有符号整型
- i64: 64位有符号整型
- double: 64位浮点型
- string: Encoding agnostic text or binary string
### 2.2 结构体
optional是不填充则部序列化，required是必须填充也必须序列化,如果不指定则为无类型,可以不填充该值
```
struct Report
{
  1: required string msg, //required表示字段必须填写
  2: optional i32 type = 0; //默认值
  3: i32 time //默认字段类型为optional
}
```
### 2.3 容器
- `list<t>`, 有序表，容许元素重复
- `set<t>`, 无序表，不容许元素重复
- `map<t,t>`, 值类型为t的kv对，键不容许重复
```
3: list<Stusers> users
```
具体结构不知
### 2.4 枚举类型
```
enum EnOpType {
CMD_OK = 0, // (0) 　　
CMD_NOT_EXIT = 2000, // (2000)
CMD_EXIT = 2001, // (2001)  　　
CMD_ADD = 2002 // (2002)
}

struct StUser {
1: required i32 userId;
2: required string userName;
3: optional EnOpType cmd_code = EnOpType.CMD_OK; // (0)
4: optional string language = "english"
}
```
### 2.5 常量定义
```
const i32 INT_CONST = 1234; const EnOpType myEnOpType = EnOpType.CMD_EXIT; //2001
```
### 2.6 异常
类似于结构体,但关键字是`exception`
```
exception Extest {
1: i32 errorCode,
2: string message,
3: StUser userinfo
}
```
### 2.7 服务
```
service Echo {
    EchoRes echo(1: EchoReq req);
}
```
### 2.8 命名空间
```
namespace php com.example.test  
```
### 2.9 include
```bash
include "test.thrift" // 没有分号
...
struct StSearchResult {
    1: in32 uid; 
	...
}
```


