---
title: "JavaCollection"
date: 2026-05-02 14:48:18
tags:
  - note
---

---
title: JavaCollection
date: 2025-11-8
tags:
  - note
categories: 未分类
---

# 集合框架总览
```markdown
Java 集合框架总览
┌─────────────────────────────────────────────────────────────────────┐
│                         java.util.Collection (接口)                  │
├───────────────────────┬──────────────────────┬───────────────────────┤
│    java.util.List     │    java.util.Set      │   java.util.Queue     │
│ (有序, 可重复)        │ (无序, 不可重复)      │ (通常FIFO)            │
├──────────┬───────────┼──────────┬────────────┼──────────┬────────────┤
│ArrayList │LinkedList │ HashSet  │TreeSet     │LinkedList│PriorityQueue│
│(数组)    │(链表)     │(哈希表)  │(红黑树)    │(链表)    │(堆)        │
└──────────┴───────────┴──────────┴────────────┴──────────┴────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                           java.util.Map (接口)                      │
│                     (键值对, key唯一)                               │
├───────────────────────┬──────────────────────┬───────────────────────┤
│    HashMap            │    LinkedHashMap     │    TreeMap            │
│ (哈希表, 无序)        │ (哈希表+链表,有序)   │ (红黑树, 按键排序)     │
└───────────────────────┴──────────────────────┴───────────────────────┘
```
## 一、Java集合主要分成两大类
1、`Collection`：存储单个元素的集合
    - `List`：有序、可重复
    - `Set`：无序、不可重复
2、`Map`：存储键值对（`key-value`）的集合（像一个字典，通过拼音查汉字）
## 二、List接口
`List`是一个**有序**且**可重复**的集合。抽象上可以理解成数组，但是他的长度可变。
**1、`ArrayList`**
实现List接口，底层是动态数组，查询速度快，而增删慢。
```java
import java.util.ArrayList;
import java.util.List;

public class ArrayListExample {
    public static void main(String[] args) {
        // 1. 创建一个 ArrayList 对象，尖括号里是元素类型
        List<String> names = new ArrayList<>();//()括号里指定容量，空则长度为10

        // 2. 添加元素 (add)
        names.add("Alice");       // 在末尾添加
        names.add("Bob");
        names.add(1, "Charlie"); // 在指定索引处添加，后面的元素会自动后移
        System.out.println("添加后: " + names); // 输出: [Alice, Charlie, Bob]

        // 3. 获取元素 (get)
        String firstElement = names.get(0);
        System.out.println("索引 0 的元素是: " + firstElement); // 输出: Alice

        // 4. 修改元素 (set)
        names.set(2, "David"); // 将索引 2 的元素修改为 "David"
        System.out.println("修改后: " + names); // 输出: [Alice, Charlie, David]

        // 5. 删除元素 (remove)
        names.remove(1); // 根据索引删除
        // names.remove("Alice"); // 也可以根据元素内容删除
        System.out.println("删除后: " + names); // 输出: [Alice, David]

        // 6. 获取集合大小 (size)
        System.out.println("集合的大小是: " + names.size()); // 输出: 2

        // 7. 判断元素是否存在 (contains)
        System.out.println("是否包含 Bob? " + names.contains("Bob")); // 输出: false

        // 8. 遍历集合 (最常用的两种方式)
        System.out.println("\n--- 方式1: 使用 for-each 循环 (推荐) ---");
        for (String name : names) {
            System.out.println(name);
        }

        System.out.println("\n--- 方式2: 使用普通 for 循环 (需要索引时用) ---");
        for (int i = 0; i < names.size(); i++) {
            System.out.println("索引 " + i + ": " + names.get(i));
        }
        
        // 9. 清空集合 (clear)
        names.clear();
        System.out.println("\n清空后集合是否为空? " + names.isEmpty()); // 输出: true
    }
}
```
**2、`LinkedList`**
`LinkedList`底层是双向链表，增删快，遍历/查询慢，大部分方法和`ArrayList`一致
```java
import java.util.LinkedList;
import java.util.List;

public class LinkedListExample {
    public static void main(String[] args) {
        List<String> list = new LinkedList<>();

        list.add("A");
        list.add("B");
        System.out.println("普通添加: " + list); // [A, B]

        // LinkedList 特有方法，操作两端更高效
        ((LinkedList<String>) list).addFirst("头");
        ((LinkedList<String>) list).addLast("尾");
        System.out.println("头尾添加后: " + list); // [头, A, B, 尾]

        System.out.println("获取头: " + ((LinkedList<String>) list).getFirst());
        System.out.println("获取尾: " + ((LinkedList<String>) list).getLast());
        
        ((LinkedList<String>) list).removeFirst();
        ((LinkedList<String>) list).removeLast();
        System.out.println("头尾删除后: " + list); // [A, B]
    }
}
```
> **注意**：addFirst, getLast 等是 LinkedList 特有的方法，
> List 接口没有定义，所以需要强制转换类型才能使用。
## 三、`Set`接口
`Set`接口是一个**无序**且**不可重复**的集合
**1、`HashSet`**
`HashSet`是`Set`的主要实现类，特点是无序、不可重复，查找效率高
```java
import java.util.HashSet;
import java.util.Set;

public class HashSetExample {
    public static void main(String[] args) {
        // 1. 创建 HashSet
        Set<String> uniqueNames = new HashSet<>();

        // 2. 添加元素 (add)
        uniqueNames.add("Apple");
        uniqueNames.add("Banana");
        uniqueNames.add("Apple"); // 尝试添加重复元素，会失败，集合不会改变
        System.out.println("添加后: " + uniqueNames); // 输出: [Apple, Banana] (顺序不固定)

        // 3. 删除元素 (remove)
        uniqueNames.remove("Banana");
        System.out.println("删除后: " + uniqueNames); // 输出: [Apple]

        // 4. 判断元素是否存在 (contains)
        System.out.println("是否包含 Apple? " + uniqueNames.contains("Apple")); // true

        // 5. 获取集合大小 (size)
        System.out.println("集合大小: " + uniqueNames.size()); // 1
        
        // 6. 遍历集合 (只能用 for-each 或迭代器，因为无序，没有索引)
        System.out.println("\n--- 遍历 HashSet ---");
        for (String name : uniqueNames) {
            System.out.println(name);
        }
    }
}
```
**2、`TreeSet`**
`TreeSet`会先对元素进行**自动排序**，同样不可重复。
```java
import java.util.TreeSet;
import java.util.Set;

public class TreeSetExample {
    public static void main(String[] args) {
        Set<Integer> numbers = new TreeSet<>();

        numbers.add(5);
        numbers.add(2);
        numbers.add(8);
        numbers.add(2); // 重复元素，添加失败
        
        // TreeSet 会自动排序
        System.out.println("TreeSet 中的元素: " + numbers); // 输出: [2, 5, 8]
    }
}
```
## 四、`Map`接口
`Map`用于存储**键值对**（`key-value`），`key`不能重复，`value`可以重复
**1、`HashMap`**
`HashMap`是`Map`最主要实现类，查询和修改效率高。
```java
import java.util.HashMap;
import java.util.Map;

public class HashMapExample {
    public static void main(String[] args) {
        // 1. 创建 HashMap，尖括号里是 <Key类型, Value类型>
        Map<String, Integer> studentScores = new HashMap<>();

        // 2. 添加键值对 (put)
        studentScores.put("Alice", 95);
        studentScores.put("Bob", 88);
        studentScores.put("Charlie", 92);
        studentScores.put("Alice", 98); // key 重复，会覆盖原来的 value
        System.out.println("添加后: " + studentScores); // {Alice=98, Bob=88, Charlie=92}

        // 3. 根据 key 获取 value (get)
        int aliceScore = studentScores.get("Alice");
        System.out.println("Alice 的分数是: " + aliceScore); // 98

        // 4. 删除键值对 (remove)
        studentScores.remove("Bob");
        System.out.println("删除 Bob 后: " + studentScores); // {Alice=98, Charlie=92}

        // 5. 判断 key 是否存在 (containsKey)/判断 value 是否存在（containsValue）
        System.out.println("是否有 Charlie 的分数? " + studentScores.containsKey("Charlie")); // true
        System.out.println("是否有分数是 95 ? " + studentScores.containsValue(95)); // true

        // 6. 获取 Map 的大小 (size)
        System.out.println("共有 " + studentScores.size() + " 个学生的成绩"); // 2
        
        // 7. 遍历 Map (重点)
        System.out.println("\n--- 方式1: 遍历所有的 key，再通过 key 获取 value ---");
        for (String name : studentScores.keySet()) {
            int score = studentScores.get(name);
            System.out.println(name + ": " + score);
        }

        System.out.println("\n--- 方式2: 直接所有的value ---");
        for (Integer value : map.values()) {
            System.out.println(value);
        }

        System.out.println("\n--- 方式3: 直接遍历键值对 (entrySet，推荐，更高效) ---");
        for (Map.Entry<String, Integer> entry : studentScores.entrySet()) {
            String name = entry.getKey();
            int score = entry.getValue();
            System.out.println(name + ": " + score);
        }

        // 8. 重写toString方法
        System.out.println(studentScores);//输出{...=...,...}的形式
    }
}
```

## 补充
一般使用集合，都是用接口来定义指针类型，然后初始化实现类的对象
```java
    List<Integer> array = new ArrayList<Integer>();
```
**Map不是Collection的子类型**，所以使用`values`，`keySet`，`entrySet`来提供集合视图，不是副本，所作的操作都会**影响背后的`Map`**
- keySet(): 返回所有键组成的 Set。

- values(): 返回所有值组成的 Collection。所有值是允许无序重复的，而且不同的Map实现类是返回不同的具体类，使用Collection接口能够更好的表现

- entrySet(): 返回所有键值对（Map.Entry对象）组成的 Set。这是遍历 Map最高效的方式。


---
# 集合的初始化

## 一、`List` 接口的初始化

`List` 是有序可重复集合，常用实现类为 `ArrayList` 和 `LinkedList`，初始化方式如下：

### 1. `ArrayList` 初始化（补充）
除了之前提到的三种方式，还有一种是使用 `List.of()`（Java 9+）：
```java
List<String> list = new ArrayList<>(List.of("A", "B", "C"));
```
- `List.of()` 返回一个不可变列表，用它来初始化 `ArrayList` 可以快速填充元素，且避免了 `Arrays.asList()` 的固定大小问题。

### 2. `LinkedList` 初始化
`LinkedList` 底层是双向链表，初始化方式与 `ArrayList` 类似：
```java
// 1. 无参构造
List<String> linkedList = new LinkedList<>();

// 2. 用其他集合初始化
List<String> list = new ArrayList<>(Arrays.asList("X", "Y"));
List<String> linkedList2 = new LinkedList<>(list); // 将 ArrayList 转为 LinkedList
```

---

## 二、`Set` 接口的初始化

`Set` 是无序不可重复集合，常用实现类为 `HashSet`、`LinkedHashSet`、`TreeSet`。

### 1. `HashSet` 初始化
```java
// 1. 无参构造
Set<String> set = new HashSet<>();

// 2. 指定初始容量和负载因子（负载因子默认0.75）
Set<String> set2 = new HashSet<>(16, 0.75f);

// 3. 用其他集合初始化
List<String> list = Arrays.asList("A", "B", "C");
Set<String> set3 = new HashSet<>(list); // 自动去重
```

### 2. `LinkedHashSet` 初始化
`LinkedHashSet` 继承自 `HashSet`，能保持插入顺序：
```java
Set<String> linkedHashSet = new LinkedHashSet<>();
linkedHashSet.add("Z");
linkedHashSet.add("Y");
linkedHashSet.add("X");
// 遍历顺序：Z -> Y -> X（插入顺序）
```

### 3. `TreeSet` 初始化
`TreeSet` 会自动排序，初始化时可以指定比较器：
```java
// 1. 无参构造（自然排序，元素需实现 Comparable 接口）
Set<Integer> treeSet = new TreeSet<>();
treeSet.add(3);
treeSet.add(1);
treeSet.add(2);
// 遍历顺序：1 -> 2 -> 3（自然排序）

// 2. 自定义比较器（倒序排序）
Set<Integer> treeSet2 = new TreeSet<>((a, b) -> b - a);
treeSet2.add(3);
treeSet2.add(1);
treeSet2.add(2);
// 遍历顺序：3 -> 2 -> 1（自定义排序）
```

---

## 三、`Map` 接口的初始化

`Map` 是键值对集合，常用实现类为 `HashMap`、`LinkedHashMap`、`TreeMap`。

### 1. `HashMap` 初始化
```java
// 1. 无参构造
Map<String, Integer> map = new HashMap<>();

// 2. 指定初始容量和负载因子
Map<String, Integer> map2 = new HashMap<>(16, 0.75f);

// 3. 用其他 Map 初始化
Map<String, Integer> oldMap = new HashMap<>();
oldMap.put("A", 1);
Map<String, Integer> newMap = new HashMap<>(oldMap);

// 4. Java 9+ 新方式（快速初始化）
Map<String, Integer> map3 = Map.of(
    "A", 1,
    "B", 2,
    "C", 3
);
// 注意：Map.of() 返回的是不可变 Map，不能修改
```

### 2. `LinkedHashMap` 初始化
`LinkedHashMap` 保持插入顺序或访问顺序：
```java
// 1. 保持插入顺序
Map<String, Integer> linkedHashMap = new LinkedHashMap<>();
linkedHashMap.put("A", 1);
linkedHashMap.put("B", 2);
// 遍历顺序：A -> B（插入顺序）

// 2. 保持访问顺序（适用于 LRU 缓存）
Map<String, Integer> lruMap = new LinkedHashMap<>(16, 0.75f, true);
lruMap.put("A", 1);
lruMap.put("B", 2);
lruMap.get("A"); // 访问 A
// 遍历顺序：B -> A（最近访问的元素在后面）
```

### 3. `TreeMap` 初始化
`TreeMap` 按键排序：
```java
// 1. 自然排序（key 需实现 Comparable）
Map<String, Integer> treeMap = new TreeMap<>();
treeMap.put("C", 3);
treeMap.put("A", 1);
treeMap.put("B", 2);
// 遍历顺序：A -> B -> C（按键自然排序）

// 2. 自定义比较器
Map<String, Integer> treeMap2 = new TreeMap<>((k1, k2) -> k2.compareTo(k1));
treeMap2.put("C", 3);
treeMap2.put("A", 1);
treeMap2.put("B", 2);
// 遍历顺序：C -> B -> A（按键倒序排序）
```

---

## 四、注意事项
1. **不可变集合**：`List.of()`、`Set.of()`、`Map.of()`（Java 9+）返回的是不可变集合，不能添加、删除或修改元素，否则会抛出 `UnsupportedOperationException`。
2. **线程安全**：上述集合默认都是非线程安全的。如果需要在多线程环境中使用，可以使用 `Collections.synchronizedList()`、`ConcurrentHashMap` 等线程安全的实现。
3. **初始化效率**：
   - 对于已知元素数量的集合，指定初始容量可以减少扩容次数，提高效率（如 `new ArrayList<>(100)`）。
   - 使用 `Arrays.asList()` 或 `List.of()` 初始化时，注意其返回的集合是否可修改。

---

## 总结
不同集合接口的初始化方式各有特点：
- `List` 常用 `ArrayList` 和 `LinkedList`，支持多种初始化方式。
- `Set` 常用 `HashSet`（无序去重）、`TreeSet`（有序去重）。
- `Map` 常用 `HashMap`（无序）、`LinkedHashMap`（有序）、`TreeMap`（按键排序）。
- 初始化时要根据需求选择合适的实现类，并注意集合的可变性、线程安全性和初始化效率。
