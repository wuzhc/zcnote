https://blog.csdn.net/wangyueshu/article/details/90919019

```bash
git reset --hard commid_id
```
强制回退到某一次历史commit的版本，并清除本地修改,如果使用`git log`查看不到被回退的版本

## 没有commit，没有add
对不起，找不回了，放弃吧。

## 没有commit，但是有add操作
在项目git目录下的 /.git/lost-found/other里有你add过的文件。挨个看看，能救回来多少是多少吧。
```bash
#找回本地仓库里边最近add的60个文件
find .git/objects -type f | xargs ls -lt | sed 60q
```

## 执行过commit
```bash
git reflog
git reset --hard commid_id
```
