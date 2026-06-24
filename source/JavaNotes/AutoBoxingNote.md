---
title: "自动装箱"
date: 2026-05-02 14:48:18
tags:
  - note
---

---
title: InterfaceNote
date: 2025-11-5
tags:
  - note
categories: 未分类
---

# 自动装箱
首先，**Java**中有八大包装类
|byte | Byte
|short | Short
|int |Integer
|long |Long
|float |Float
|double |Double
|char | Character
|boolean | Boolean

自动装箱的过程就是程序自动将int类型转换成Integer包装类，在Java中方便调用
```java
    int num = 100;
    Integer n = num; //编译器自动转换成Intger.valueOf(num);
```

# 自动拆箱
将包装类对象的值赋给基本数据类型
```java
    Integer num = 100;
    int n = num; //n = 100;
```

# 注意事项
包装类的对象可能是null空指针，所以拆箱的时候要验证

# 缓存机制
除了Float，Double这两个包装类，其他包装类有缓存机制
举Integer来说，从-128~127，都被缓存下来，当这个数在这个范围之内，是直接指向这个缓存对象的，如果超出了这个范围，就需要重新创建一个新的对象。这时引用就会有所不同。