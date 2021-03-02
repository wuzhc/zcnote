https://blog.csdn.net/qq_27384769/category_7521591.html


## ik配置文件地址：es/plugins/ik/config目录
    IKAnalyzer.cfg.xml：用来配置自定义词库
    main.dic：ik原生内置的中文词库，总共有27万多条，只要是这些单词，都会被分在一起
    quantifier.dic：放了一些单位相关的词
    suffix.dic：放了一些后缀
    surname.dic：中国的姓氏
    stopword.dic：英文停用词

## ik原生最重要的两个配置文件
    main.dic：包含了原生的中文词语，会按照这个里面的词语去分词
    stopword.dic：包含了英文的停用词
    
## 可以支持mysql驱动的热更新