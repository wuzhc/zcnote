```bah
sudo sh -c 'echo "hello world" >> test.txt' 
```
`sh -c`可以让bash将一个字符串作为完整的命令来执行

```bash
# 等同于上面命令,tee -a相当于>>,表示追加
echo "hello word" | sudo tee -a test.txt
```