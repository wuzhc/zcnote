查看远程库信息：git remote -v（Note:参数v表示详细信息）
推送分支：git push <remote> <name>
查看分支：git branch
创建分支：git branch <name>
切换分支：git checkout <name>
创建+切换分支：git checkout -b <name> （Note:命令加上-b参数表示创建并切换）
创建远程分支：git checkout -b <name> git push origin <name>
本地合并某分支到当前分支：git merge <name>
删除分支：git branch -d <name>
删除远程分支：git push origin :<name>
查看远程分支：git branch -r
查看所有分支：git branch -a
查看日志（单行显示）：git log --pretty=oneline
查看日志（分支合并图显示）：git log --graph --pretty=oneline --abbrev-commit
撤销暂存区文件：git reset HEAD -- file
撤销工作区文件：git checkout -- file
从远程获取最新版本到本地：git fetch（Note:不会自动merge,后续git merge origin/master）
从远程获取最新版本到本地：git pull（Note:从远程获取最新版本并merge到本地）
从远程库checkout文件：git checkout origin/master file（如果本地仓库文件被删除，可以使用该命令重新获取远程库最新文件）
回退版本到上一个版本：git reset --hard HEAD^
回退到指定版本：git reset --hard <commit_id>
获取远程分支并在本地新建分支localName : git checkout origin/remoteName -b localName

重命名文件和文件夹（window下注意大小写问题）：
git mv -f oldfolder newfolder
git add -u newfolder (-u选项会更新已经追踪的文件和文件夹)
git commit -m "changed the foldername whaddup"
git mv foldername tempname && git mv tempname folderName (在大小写不敏感的系统中，如windows，重命名文件的大小写,使用临时文件名)
git mv -n foldername folderName (显示重命名会发生的改变，不进行重命名操作)

合并文件到另一个远程分支：
git checkout origin/ketang31 -b kt31 基于远程分支ketang31创建一支新的本地分支kt31，并切换到新本地分支kt31
git checkout master protected/controllers/KtUserController.php 复制本地分支master的KtUserController文件到kt31分支上
(这里只是简单的复制文件，也可以用打补丁的方式get checkout --patch master protected/controllers/KtUserController.php)
git commit -m "message"  提交
git push origin ketang31 推送到远程分支ketang31

创建远程库：
git init
git add README.md
git commit -m “first commit”
git remote add origin https://github.com/test/test.git
git push -u origin master

git文件权限改变问题：
git文件权限修改引起的冲突，可以加入忽略文件权限的配置，
git config core.filemode false  // 当前版本库
git config --global core.fileMode false // 所有版本库
cat .git/config // 查看git的配置文件

git apply --ignore-space-change --ignore-whitespace mychanges.patch

## 添加SSH
- ssh-keygen -t rsa -C "wuzhc2016@163.com" 生成key

以上步骤可得到了两个文件：id_rsa和id_rsa.pub
- 进入C:\Users\Administrator\.ssh文件夹，复制id_rsa.pub文本到github.com上即可
- ssh git@github.com 测试是否成功

### 添加多个SSH,以github和gitlab为例
https://www.cnblogs.com/sheting/p/7992063.html
ssh-keygen -t rsa -C "wuzhc2016@163.com" 
ssh-keygen -t rsa -C "1716220125@qq.com"
分别把.pub文件内存复制到gitlab和github上即可

-t 指定要创建的密钥类型。可以使用："rsa1"(SSH-1) "rsa"(SSH-2) "dsa"(SSH-2)
-C 提供一个新注释
-f 指定密钥文件名。

配置config文件
####  gitlab
```bash
Host gitlab.com
    HostName gitlab.com
    PreferredAuthentications publickey
User wuzhc
Port xxx
    IdentityFile ~/.ssh/id_rsa_gitlab
```
#### github
```bash
Host github.com
    HostName github.com
User wuzhc
Port 22 (22端口可以省略)
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/id_rsa_github
```

## .gitignore 添加已经被追踪的文件或文件夹
```bash
git rm -r --cached <filename>   # -r 表示递归
git commit -m "delete filename"
git push origin master
# 手动添加<filename>到.gitignore
git commit -m "add filename to .gitignore"
git push origin master
# 说明：--cached 表示删除暂存区或分支上的文件,不删除工作区的文件
```

撤销分支合并merge
git log   # 获取上一个commitID
git reset --hard commitID  # 貌似撤销后不能恢复，所以注意备份

撤销add文件
git reset HEAD .  # 撤销所有已经add文件
git reset HEAD <filename> # 撤销filename文件

恢复被删除分支
git log -g    # 查找被删除分支的最新的commitID
git branch <name> commitID   # 以commitID新创建name的分支，内容和被删除分支一样，只是name可以重新命名或用之前的名字

删除文件或目录
git rm <filename>
git rm -r <directory>
git commit -m "delete something" # 注意是commit，不要用git add .

本地分支和远程分支没有建立关联
git branch --set-upstream-to=origin/<remote-branch>   <local-branch> 

差异对比查看:
git add之前用 git diff
git commit( 已经add过了 )之前用 git diff --cached
git push之前用 git diff origin/分支名 HEAD (--name-status)
对比两个commit用 git diff commitID commitID (--name-status)

git配置过程中fatal:拒绝合并无关的历史
首先将远程仓库和本地仓库关联起来：
git branch --set-upstream-to=origin/master master
然后使用git pull整合远程仓库和本地仓库，
git pull --allow-unrelated-histories    (忽略版本不同造成的影响)


ssh-keygen参数说明： http://killer-jok.iteye.com/blog/1853451
配置多个SSH ： http://blog.csdn.net/birdben/article/details/51824788
