---
title: "InterfaceNote"
date: 2026-05-02 14:48:18
tags:
  - note
---

---
title: InterfaceNote
date: 2025-10-28
tags:
  - note
categories: 未分类
---
# 关键字
**interface**，**implements**

# 定义
接口是一个完全抽象的引用类型，用于定义一组**行为规范**或者**能力标准**，但是不提供具体的实现（除非使用default方法）。

# Code
## interface
```Java
    package Interface_Exercise;

    public interface Animals {
        public void eat();
        public void sleep();
    }
```
## Dog和Cat
```Java
    public class Dog_Interface implements Animals{
        @Override
        public void eat(){
            System.out.println("Dog is eatting");
        }
        @Override
        public void sleep() {
            System.out.println("Dog is sleeping");
        }
    }

    public class Cat_Interface implements Animals{
        @Override
        public void eat() {
            System.out.println("Cat is eatting");
        }
        @Override
        public void sleep(){
            System.out.println("Cat is sleeping");
        }
    }

    public class Pet {
        public void work(Animals animal){
            animal.eat();
            animal.sleep();
        }
    }
```
## 调用
```Java
    public class Interface_animal {
        public static void main(String[] args){
            Dog_Interface dog = new Dog_Interface();
            Cat_Interface cat = new Cat_Interface();
            //有点类似向上转型，然后调用其方法
            Pet pet = new Pet();
            pet.work(dog);
            pet.work(cat);
        }
    }
```

# 核心目的
实现相同的接口来达成一致的契约，从而实现*多态性*和*低耦合*的设计。
同时支持多继承，一个类可以实现多个接口的标准。

```Java
    public class example implements inteface_a,interface_b{
        ...
    }
```

## 比较表格（抽象类）
| **问题** | **抽象类** | **接口**
|------|------|------
| 能否多继承？ | 不能 | 能（多实现）
| 适合什么场景？ | “是什么”的层次关系 | “能做什么”的行为约定
| 典型应用 | 模板方法模式 | 策略模式、回调机制 
