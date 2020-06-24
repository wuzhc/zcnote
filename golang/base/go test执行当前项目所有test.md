- 运行当前目录及所有子目录下的测试用例
```bash
go test ./...
```

- 运行指定目录及所有子目录下的测试用例
```bash
go test foo/...
```

- 运行指定前缀的测试用例
```bash
go test foo...
```

- 运行GOPATH下的所有测试用例
```bash
go test ...
```