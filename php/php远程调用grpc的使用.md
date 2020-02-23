```proto
syntax = "proto3";
package lotteryservice;
service Greeter {
    rpc lottery(lotteryReq) returns (lotteryRes){}
}

message lotteryReq {
    string param = 1;
}

message lotteryRes {
    string data = 1;
}
```
执行：
```bash
protoc --php_out=. lottery.proto
```