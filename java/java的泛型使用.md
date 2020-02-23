泛型主要在编译阶段能够提前知道类型是否有勿用，并且只是在编译阶段有效，运行阶段会擦除泛型的相关信息

## 泛型类
```java
public class MaoGou<T> {
    public T key;
    MaoGou(T key) {
        this.key = key;
    }
    public T getKey() {
        return key;
    }
    public static void main(String[] args) {
        MaoGou<Integer> mg = new MaoGou<>(123456);
        MaoGou<String> mg2 = new MaoGou<>("hello world");
        System.out.println(mg.getKey());
        System.out.println(mg2.getKey());
    }
}
```

## 泛型接口
```java
public interface GenericInterface<T> {
    public T next();
}
class FruitGenerator implements GenericInterface<String>{
    @Override
    public String next() {
        return "hello world";
    }

    public static void main(String[] args) {
        FruitGenerator f = new FruitGenerator();
        System.out.println(f.next());
    }
}
```

## 泛型通配符
主要用于参数中，使用`<?>`表示
```java
public void showName(Person<?> obj) {
    System.out.println(obj.getName());
}
```

## 泛型方法
是用`<T>`声明这是一个泛型方法，另外方法参数中，如果用到泛型，也必须是方式声明过的，否则你需要指定具体的类类型
```java
public <T> T genericMethod(Class<T> tClass)throws InstantiationException ,
  IllegalAccessException{
        T instance = tClass.newInstance();
        return instance;
}

// 可变参数
public <T> void printMsg(T... args){
    for(T t : args){
        Log.d("泛型测试","t is " + t);
    }
}

// 静态方法
public static <T> void show(T t){
}
```

## 泛型上下边界
使用`<? extends 类型>`，上边界是类型实参必须是指定类型的子类型

## 参考
https://www.cnblogs.com/coprince/p/8603492.html




