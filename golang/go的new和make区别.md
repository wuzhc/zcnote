# golang的new和make区别
- make只能用于`map`,`slice`,`channel`,因为这三个类型指向数据结构的引用在使用前必须被初始化,例如，一个slice，是一个包含指向数据（内部array）的指针、长度和容量的三项描述符,在这些项目被初始化之前，slice为nil。对于slice、map和channel来说，make初始化了内部的数据结构，填充适当的值
- new返回指针
- make返回有初始值(非零)的T类型