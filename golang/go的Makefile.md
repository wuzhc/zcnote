```bash
# 追加变量值
A=apple
A+=apple
# 判断一个变量是否已经定义，如果已经定义了则不做操作，若没有则定义其值。
A?=apple
```

## @
只显示结果,不显示命令
```bash
DIR_OBJ=./obj  
CMD_MKOBJDIR=if [ -d ${DIR_OBJ} ]; then exit 11; else mkdir ${DIR_OBJ}; fi  
  
mkobjdir:  
	@${CMD_MKOBJDIR}  
```
- 有`@`显示`make: *** [Makefile:5：mkobjdir] 错误 11`
- 无`@`显示`if [ -d ./obj   ]; then exit 11; else mkdir ./obj  ; fi make: *** [Makefile:5：mkobjdir] 错误 11`

## $@,$^,$<
- $@  代表目标文件(target)
- $^ 代表所有的依赖文件(components)
- $< 代表第一个依赖文件(components中最左边的那个)。

