---
title: "引言"
date: 2026-05-02 14:48:18
tags:
  - note
---

---
title: Generics
date: 2025-11-12
tags:
  - note
categories: 未分类
---
# 引言
在Java 5之前，程序员必须使用`Object`类来兼容适合多种类型的代码，但是麻烦的是，总是会有需要类型转换的时候，这样编译和运行就容易出错。
# 介绍泛型
Java泛型的核心就是“编译时期的语法糖 + 类型擦除”，在程序员视角，能够提高效率，兼容多种类型。
## 泛型类
```java
public class  Pair<T>{
  private T first;
  private T second;
  Pair(T first,T second){
    this.first = first;
    this.second = second;
  }
}
```
引入一个泛型变量T，用<>括起来放在类名后面。也可以有多个类型变量
```java
public class Pair<T,V>{...}
```
**类型变量用于指定方法的返回类型以及字段和局部变量的类型**
---
## 泛型方法
```java
public static <T> T getMiddle(T... a){//java内部将多参数传入转换成数组
  return a[a.lenght / 2];
}
```
调用这个函数的时候，就把类型放在<>里面，也可以省略，因为编译器会推断出这个是什么类型的方法。
---
## 泛型的限定
有时候使用泛型的方法或者类的时候必须要调用一个该泛型共有的方法，但是这就需要限定被调用类型的范围，要求他们**必须是某一个类的子类**
```java
class ArrayAlg{
  public static <T> T min(T[] a){
    if(a == null || a.length == 0) return null;
    T smallest = a[0];
    for(int i=0; i<length; i++){
      if(smallest.compareTo(a[i])>0) smallest = a[i];
    }
    return smallest;
  }
}
```
在这个程序里面就要求了被调用进来的泛型必须都是`Comparable`的子类，但是`Rectangle`没有实现`Comparable`接口，所以它调用min会产生编译错误。
通过限制类型变量可以解决问题
```java
public static <T extends Comparable> T min(T[] a)...
```
也可以有多个限定，使用`&`隔开，e.g. 
```java
T extends Comparable & Serializable
```
`T`和限定类型可以是类也可以是接口，这也就是为什么是`extends`而不是`implments`的原因。
---
## 泛型代码和虚拟机
正如之前所言，泛型本质上只是一种语法糖，在虚拟机视角还是一样将它转换成`Object`类来处理。
区别就在于泛型是会在**编译时期类型检查 + 自动插入强制转换代码**，而以前没有泛型的时候都是在**运行时发生错误**
```java
// 泛型模式（源码）
String str = list.get(0); // 无手动强转

// 编译后（JVM 执行的逻辑，等效于 Object 模式）
String str = (String) list.get(0); // 编译器自动插入强转
```
**核心价值：**既简化了代码，又避免了强制类型错误的问题。
---
## 问题和局限
但是这样的机制也会导致一些问题：
### 无法创建泛型类型的实例
运行时`T`已经被擦除成`Object`，JVM不知道具体是哪个类，无法调用其构造方法。
```java
public <T> T createInstance() {
    return new T(); // 编译报错：Cannot instantiate the type T
}
```
### 无法创建泛型类型的数组
类型擦除之后，`T[]`编译之后会擦除成`Object[]`，直接创建会导致类型不安全。
```java
public <T> T[] createArray(int size) {
    return new T[size]; // 编译报错：Cannot create a generic array of T
}
```
### 无法创建基本数据类型的变量
因为擦除变成`Object`的缘故们，所以<>内的类型必须继承`Object`类，这就导致了基本数据类型无法直接作为参数
```java
List<int> intList = new ArrayList<>(); // 编译报错：Unexpected type, required: reference, found: int
```