- $#：传入脚本的参数个数；
- $0:  脚本自身的名称；　　
- $1:  传入脚本的第一个参数；
- $2:  传入脚本的第二个参数；
- $@: 传入脚本的所有参数；
- $*：传入脚本的所有参数；
- $$:  脚本执行的进程id；
- $?:  上一条命令执行后的状态，结果为0表示执行正常，结果为1表示执行异常；

在shell中,`$@`和`$*`都表示命令行所有参数(不包含`$0`),但是`$*`将命令行的所有参数看成一个整体，而`$@`则区分各个参数，如下
```bash
for i in "$@"
do
   echo $i   #会经历$#次循环
done

for i in "$*"
do
   echo $i  #只会进行一次循环,如果$*没有加双引号则会进行$#次循环
done
```



