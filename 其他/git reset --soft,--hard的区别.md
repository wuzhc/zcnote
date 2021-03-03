## 参考
https://www.jianshu.com/p/c6927e80a01d

```bash
git reset [<mode>] [<commit>]
```
常用的有三种模式，`--soft`, `--mixed`, `--hard`，如果没有给出mode则默认是`--mixed`

## --soft
使用--soft参数将会仅仅重置HEAD到指定的版本，不会修改暂存区和工作目录

## --mixed
使用--mixed参数与--soft的不同之处在于，--mixed修改了暂存区，使其与第二个版本匹配

## --hard
使用--hard同时也会修改working tree，也就是当前的工作目录，如果我们执行git reset --hard HEAD~，那么最后一次提交的修改，包括本地文件的修改都会被清楚，彻底还原到上一次提交的状态且无法找回。所以在执行reset --hard之前一定要小心
*这个命令是强制回退到某一次历史commit的版本，并清除本地修改！*