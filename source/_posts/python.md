---
title: "python速成"
date: 2026-05-02 14:48:18
tags:
  - note
---

# python速成
# Python字典常用函数/方法（附示例）
字典（dict）是Python核心数据结构，以下是**最常用的字典方法**，每个方法都配了易懂的示例，帮你快速理解用法。

## 一、基础查值（最常用）
### 1. `dict.get(key, default=None)`
- **作用**：获取指定key对应的值；若key不存在，返回`default`（默认None），避免直接用`dict[key]`报错。
- **示例**：
```python
# 定义基础字典
student = {"name": "张三", "age": 20, "gender": "男"}

# 1. 获取存在的key
print(student.get("name"))  # 输出：张三

# 2. 获取不存在的key，返回默认None
print(student.get("score"))  # 输出：None

# 3. 自定义默认值（推荐）
print(student.get("score", 0))  # 输出：0（key不存在时返回0）
```

### 2. `dict.keys()`
- **作用**：返回字典所有key的可迭代对象（视图对象），可转列表。
- **示例**：
```python
student = {"name": "张三", "age": 20, "gender": "男"}

# 获取所有key
keys = student.keys()
print(keys)  # 输出：dict_keys(['name', 'age', 'gender'])
print(list(keys))  # 转列表：['name', 'age', 'gender']

# 遍历key
for k in student.keys():
    print(k)  # 依次输出：name、age、gender
```

### 3. `dict.values()`
- **作用**：返回字典所有value的可迭代对象（视图对象），可转列表。
- **示例**：
```python
student = {"name": "张三", "age": 20, "gender": "男"}

# 获取所有value
values = student.values()
print(values)  # 输出：dict_values(['张三', 20, '男'])
print(list(values))  # 转列表：['张三', 20, '男']

# 遍历value
for v in student.values():
    print(v)  # 依次输出：张三、20、男
```

### 4. `dict.items()`
- **作用**：返回字典所有键值对的可迭代对象（每个元素是`(key, value)`元组），遍历字典的核心方法。
- **示例**：
```python
student = {"name": "张三", "age": 20, "gender": "男"}

# 获取所有键值对
items = student.items()
print(items)  # 输出：dict_items([('name', '张三'), ('age', 20), ('gender', '男')])

# 遍历键值对（最常用）
for k, v in student.items():
    print(f"键：{k}，值：{v}")
# 输出：
# 键：name，值：张三
# 键：age，值：20
# 键：gender，值：男
```

## 二、增/改值
### 1. `dict[key] = value`（基础操作，非方法但最常用）
- **作用**：key存在则修改值，key不存在则新增键值对。
- **示例**：
```python
student = {"name": "张三", "age": 20}

# 1. 修改已有key的值
student["age"] = 21
print(student)  # 输出：{'name': '张三', 'age': 21}

# 2. 新增不存在的key
student["score"] = 90
print(student)  # 输出：{'name': '张三', 'age': 21, 'score': 90}
```

### 2. `dict.update(other)`
- **作用**：批量新增/修改键值对；`other`可以是字典、键值对迭代对象（如列表）。
- **示例**：
```python
student = {"name": "张三", "age": 20}

# 1. 用字典批量更新
student.update({"age": 21, "gender": "男", "score": 90})
print(student)  # 输出：{'name': '张三', 'age': 21, 'gender': '男', 'score': 90}

# 2. 用键值对列表更新
student.update([("score", 95), ("class", "一班")])
print(student)  # 输出：{'name': '张三', 'age': 21, 'gender': '男', 'score': 95, 'class': '一班'}
```

### 3. `dict.setdefault(key, default=None)`
- **作用**：若key不存在，新增`key: default`；若key存在，不修改值（返回原有值）。
- **场景**：确保某个key一定存在（比如初始化默认值）。
- **示例**：
```python
student = {"name": "张三", "age": 20}

# 1. key不存在，新增并返回默认值
score = student.setdefault("score", 0)
print(score)  # 输出：0
print(student)  # 输出：{'name': '张三', 'age': 20, 'score': 0}

# 2. key存在，返回原值（不修改）
age = student.setdefault("age", 25)
print(age)  # 输出：20（原有值）
print(student)  # 输出：{'name': '张三', 'age': 20, 'score': 0}
```

## 三、删值
### 1. `dict.pop(key, default=None)`
- **作用**：删除指定key的键值对，并返回对应的值；若key不存在，返回`default`（无默认则报错）。
- **示例**：
```python
student = {"name": "张三", "age": 20, "score": 90}

# 1. 删除存在的key，返回值
age = student.pop("age")
print(age)  # 输出：20
print(student)  # 输出：{'name': '张三', 'score': 90}

# 2. 删除不存在的key，指定默认值（避免报错）
gender = student.pop("gender", "未知")
print(gender)  # 输出：未知

# 3. 删除不存在的key且无默认值 → 报错
# student.pop("gender")  # KeyError: 'gender'
```

### 2. `dict.popitem()`
- **作用**：删除并返回最后插入的键值对（Python3.7+有序）；空字典调用报错。
- **场景**：需要按插入顺序删除键值对时使用。
- **示例**：
```python
student = {"name": "张三", "age": 20, "score": 90}

# 删除最后插入的键值对（score）
last_item = student.popitem()
print(last_item)  # 输出：('score', 90)
print(student)  # 输出：{'name': '张三', 'age': 20}

# 再删一次（age）
last_item = student.popitem()
print(last_item)  # 输出：('age', 20)
print(student)  # 输出：{'name': '张三'}
```

### 3. `dict.clear()`
- **作用**：清空字典所有键值对，字典变为空。
- **示例**：
```python
student = {"name": "张三", "age": 20}
student.clear()
print(student)  # 输出：{}
```

### 4. `del dict[key]`（关键字，非方法）
- **作用**：删除指定key的键值对；key不存在则报错。
- **示例**：
```python
student = {"name": "张三", "age": 20}

# 删除存在的key
del student["age"]
print(student)  # 输出：{'name': '张三'}

# 删除不存在的key → 报错
# del student["score"]  # KeyError: 'score'
```

## 四、其他实用方法
### 1. `dict.copy()`
- **作用**：返回字典的浅拷贝（新字典，修改新字典不影响原字典）。
- **示例**：
```python
student = {"name": "张三", "age": 20, "hobby": ["篮球", "游戏"]}

# 浅拷贝
student2 = student.copy()
student2["age"] = 21  # 修改新字典的普通值，原字典不变
student2["hobby"].append("读书")  # 浅拷贝：嵌套列表共享，原字典会变

print(student)  # 输出：{'name': '张三', 'age': 20, 'hobby': ['篮球', '游戏', '读书']}
print(student2) # 输出：{'name': '张三', 'age': 21, 'hobby': ['篮球', '游戏', '读书']}
```

### 2. `dict.fromkeys(iterable, value=None)`
- **作用**：创建新字典，以`iterable`中的元素为key，所有key的默认值为`value`。
- **场景**：快速初始化有固定key的字典。
- **示例**：
```python
# 1. 基础用法：key列表 + 默认值None
keys = ["name", "age", "gender"]
student = dict.fromkeys(keys)
print(student)  # 输出：{'name': None, 'age': None, 'gender': None}

# 2. 指定默认值
student = dict.fromkeys(keys, "未知")
print(student)  # 输出：{'name': '未知', 'age': '未知', 'gender': '未知'}

# 注意：value为可变类型（如列表）时，所有key共享同一个对象
student = dict.fromkeys(keys, [])
student["name"].append("张三")
print(student)  # 输出：{'name': ['张三'], 'age': ['张三'], 'gender': ['张三']}
```

## 五、常用函数对比（避坑）
| 操作                | 方法/语法          | 优点                          | 缺点                          |
|---------------------|--------------------|-------------------------------|-------------------------------|
| 查值                | `dict[key]`        | 简洁                          | key不存在报错                 |
| 查值                | `dict.get()`       | 安全，可设默认值              | 略繁琐                        |
| 删除键值对          | `dict.pop()`       | 可返回值，可设默认值          | 需指定key                     |
| 删除最后键值对      | `dict.popitem()`   | 按插入顺序删除                | 无法指定key                   |
| 批量更新            | `dict.update()`    | 高效，支持多种输入形式        | 无法返回修改前的值            |
| 初始化字典          | `dict.fromkeys()`  | 快速创建固定key的字典         | 可变value会共享               |

## 总结
1. **查**：优先用`get()`（安全），遍历用`items()`；
2. **增/改**：单个用`dict[key] = value`，批量用`update()`；
3. **删**：指定key用`pop()`（带默认值），清空用`clear()`；
4. **初始化**：固定key用`fromkeys()`，普通场景直接`{}`定义。

这些是字典最核心的用法，掌握后能覆盖99%的日常字典操作场景。

# Python集合（set）超详细讲解（附示例）
集合（set）是Python中**无序、不重复、元素不可变**的核心数据结构，核心价值在于**去重**和**集合运算**（交集、并集、差集等），完全对标数学中的“集合”概念。下面从基础定义到高级用法，一步步讲透。

## 一、集合的核心特性
先明确集合的3个关键特性，避免踩坑：
1. **无序性**：集合没有索引，无法通过`[索引]`取值，也不保证元素的存储顺序（Python3.7+虽会保留插入顺序，但不建议依赖）；
2. **唯一性**：集合自动去重，重复元素会被自动剔除；
3. **元素不可变**：集合中的元素必须是「不可变类型」（字符串、数字、元组），列表、字典、集合等可变类型不能作为集合元素（否则报错）。

## 二、集合的定义与创建
### 1. 基础创建方式
| 创建方式                | 语法示例                          | 说明                                  |
|-------------------------|-----------------------------------|---------------------------------------|
| 直接用`{}`              | `s = {1, 2, 3}`                   | 最常用，注意：`{}`是空字典，不是空集合 |
| 空集合                  | `s = set()`                       | 必须用`set()`，不能用`{}`              |
| 从可迭代对象转换        | `s = set(可迭代对象)`             | 可迭代对象：列表、字符串、元组、字典等 |

#### 示例：不同创建方式
```python
# 1. 基础创建（自动去重）
s1 = {1, 2, 2, 3, 3, 3}
print(s1)  # 输出：{1, 2, 3}（重复元素被自动剔除）

# 2. 空集合（关键！）
s_empty = set()
print(type(s_empty))  # 输出：<class 'set'>
print({})  # 输出：{}（这是空字典）
print(type({}))  # 输出：<class 'dict'>

# 3. 从可迭代对象转换（核心去重场景）
# 列表去重
lst = [1, 2, 2, 3]
s2 = set(lst)
print(s2)  # 输出：{1, 2, 3}

# 字符串去重（按字符拆分）
s3 = set("hello")
print(s3)  # 输出：{'h', 'e', 'l', 'o'}（重复的'l'被剔除）

# 元组去重
tup = (10, 20, 20, 30)
s4 = set(tup)
print(s4)  # 输出：{10, 20, 30}

# 字典转换（只取key，忽略value）
dic = {"name": "张三", "age": 20}
s5 = set(dic)
print(s5)  # 输出：{'name', 'age'}
```

### 2. 错误创建示例（避坑）
```python
# 错误1：元素是可变类型（列表）
# s = {1, [2, 3]}  # 报错：TypeError: unhashable type: 'list'

# 错误2：元素是字典
# s = {1, {"name": "张三"}}  # 报错：TypeError: unhashable type: 'dict'

# 正确：元素是元组（不可变）
s = {1, (2, 3)}
print(s)  # 输出：{1, (2, 3)}
```

## 三、集合的基础操作（增/删/查）
集合没有“改”操作！因为集合无序且元素唯一，若要修改元素，需先删除旧元素，再添加新元素。

### 1. 增（添加元素）
| 方法                | 语法          | 作用                                  | 示例                                          |
|---------------------|---------------|---------------------------------------|-----------------------------------------------|
| `add()`             | `s.add(x)`    | 添加单个元素；x已存在则无操作         | `s = {1,2}; s.add(3); print(s)` → {1,2,3}     |
| `update()`          | `s.update(iter)` | 批量添加元素；iter是可迭代对象（列表/字符串等） | `s = {1}; s.update([2,3]); print(s)` → {1,2,3} |

#### 示例：添加元素
```python
# 1. add()：添加单个元素
s = {1, 2}
s.add(3)
print(s)  # 输出：{1, 2, 3}
s.add(2)  # 元素已存在，无操作
print(s)  # 输出：{1, 2, 3}

# 2. update()：批量添加
s = {1}
s.update([2, 3])  # 从列表添加
print(s)  # 输出：{1, 2, 3}

s.update("ab")  # 从字符串添加（拆分为'a'和'b'）
print(s)  # 输出：{1, 2, 3, 'a', 'b'}

s.update((4, 5))  # 从元组添加
print(s)  # 输出：{1, 2, 3, 4, 5, 'a', 'b'}
```

### 2. 删（删除元素）
| 方法                | 语法          | 作用                                  | 注意点                                          |
|---------------------|---------------|---------------------------------------|-------------------------------------------------|
| `remove(x)`         | `s.remove(x)` | 删除指定元素；x不存在则报错           | 需确保元素存在，否则抛KeyError                  |
| `discard(x)`        | `s.discard(x)`| 删除指定元素；x不存在则无操作         | 推荐！比remove()更安全                          |
| `pop()`             | `s.pop()`     | 随机删除一个元素并返回；空集合报错    | 集合无序，无法指定删除哪个元素                  |
| `clear()`           | `s.clear()`   | 清空集合，变为空集合                  | -                                               |

#### 示例：删除元素
```python
s = {1, 2, 3, 4, 5}

# 1. remove()：删除存在的元素
s.remove(3)
print(s)  # 输出：{1, 2, 4, 5}
# s.remove(10)  # 元素不存在，报错：KeyError: 10

# 2. discard()：安全删除（推荐）
s.discard(4)
print(s)  # 输出：{1, 2, 5}
s.discard(10)  # 元素不存在，无操作（不报错）
print(s)  # 输出：{1, 2, 5}

# 3. pop()：随机删除
deleted = s.pop()
print("删除的元素：", deleted)  # 输出随机（如1）
print(s)  # 输出剩余元素（如{2, 5}）

# 4. clear()：清空
s.clear()
print(s)  # 输出：set()（空集合）
```

### 3. 查（判断元素/集合关系）
集合没有“取值”操作（无索引），只能判断元素是否存在，或集合间的关系。

#### （1）判断元素是否在集合中（`in`/`not in`）
```python
s = {1, 2, 3}
print(2 in s)      # 输出：True（元素存在）
print(4 not in s)  # 输出：True（元素不存在）
```

#### （2）判断集合间的关系（子集、超集、不相交）
| 关系       | 运算符       | 方法                | 示例（s1={1,2}, s2={1,2,3}） |
|------------|--------------|---------------------|--------------------------------|
| 子集       | `s1 <= s2`   | `s1.issubset(s2)`   | True（s1的所有元素都在s2中）   |
| 真子集     | `s1 < s2`    | -                   | True（s1是子集且s1≠s2）        |
| 超集       | `s1 >= s2`   | `s1.issuperset(s2)` | False（s2是s1的超集）          |
| 真超集     | `s1 > s2`    | -                   | False                          |
| 不相交     | -            | `s1.isdisjoint(s2)` | False（有共同元素1、2）        |

#### 示例：集合关系判断
```python
s1 = {1, 2}
s2 = {1, 2, 3}
s3 = {4, 5}

# 子集/真子集
print(s1.issubset(s2))  # True
print(s1 <= s2)         # True
print(s1 < s2)          # True（s1≠s2）
print(s1 <= s1)         # True（自身是自身的子集）
print(s1 < s1)          # False（不是真子集）

# 超集
print(s2.issuperset(s1))  # True（s2包含s1所有元素）
print(s2 >= s1)           # True
print(s2 > s1)            # True

# 不相交（无共同元素）
print(s1.isdisjoint(s3))  # True（s1和s3无交集）
print(s1.isdisjoint(s2))  # False（有交集）
```

## 四、集合的核心：集合运算（交集/并集/差集/对称差集）
集合最强大的功能是模拟数学中的集合运算，有两种写法：**运算符**（简洁）和**方法**（语义清晰），效果完全一致。

先定义两个基础集合，后续示例都基于这两个集合：
```python
# 定义两个集合
math = {1, 2, 3, 4, 5}  # 数学满分的学生编号
english = {4, 5, 6, 7, 8}  # 英语满分的学生编号
```

### 1. 交集（共同元素）
- **含义**：两个集合中都存在的元素（既数学满分又英语满分的学生）；
- **运算符**：`&`；
- **方法**：`s1.intersection(s2)`；

```python
# 交集
result1 = math & english
result2 = math.intersection(english)
print(result1)  # 输出：{4, 5}
print(result2)  # 输出：{4, 5}
```

### 2. 并集（所有元素）
- **含义**：两个集合的所有元素（去重）（数学或英语满分的学生）；
- **运算符**：`|`；
- **方法**：`s1.union(s2)`；

```python
# 并集
result1 = math | english
result2 = math.union(english)
print(result1)  # 输出：{1, 2, 3, 4, 5, 6, 7, 8}
print(result2)  # 输出：{1, 2, 3, 4, 5, 6, 7, 8}
```

### 3. 差集（独有元素）
- **含义**：s1中有但s2中没有的元素（仅数学满分，英语没满分的学生）；
- **运算符**：`-`；
- **方法**：`s1.difference(s2)`；

```python
# 差集（math - english：仅数学满分）
result1 = math - english
result2 = math.difference(english)
print(result1)  # 输出：{1, 2, 3}
print(result2)  # 输出：{1, 2, 3}

# 反向差集（english - math：仅英语满分）
print(english - math)  # 输出：{6, 7, 8}
```

### 4. 对称差集（互不相同的元素）
- **含义**：两个集合中互不相同的元素（仅数学满分 或 仅英语满分的学生）；
- **运算符**：`^`；
- **方法**：`s1.symmetric_difference(s2)`；

```python
# 对称差集
result1 = math ^ english
result2 = math.symmetric_difference(english)
print(result1)  # 输出：{1, 2, 3, 6, 7, 8}
print(result2)  # 输出：{1, 2, 3, 6, 7, 8}

# 等价于：并集 - 交集
print((math | english) - (math & english))  # 输出：{1, 2, 3, 6, 7, 8}
```

### 5. 集合运算的“原地修改”版本
如果希望运算后直接修改原集合（节省内存），可以用以下方法（无对应运算符）：
| 运算       | 原地修改方法                | 示例（s1={1,2}, s2={2,3}） |
|------------|-----------------------------|-----------------------------|
| 交集修改   | `s1.intersection_update(s2)`| s1变为{2}                   |
| 并集修改   | `s1.update(s2)`             | s1变为{1,2,3}（等价于并集） |
| 差集修改   | `s1.difference_update(s2)`  | s1变为{1}                   |
| 对称差修改 | `s1.symmetric_difference_update(s2)` | s1变为{1,3} |

示例：
```python
s1 = {1, 2}
s2 = {2, 3}

# 原地交集修改
s1.intersection_update(s2)
print(s1)  # 输出：{2}

# 重置s1，演示差集原地修改
s1 = {1, 2}
s1.difference_update(s2)
print(s1)  # 输出：{1}
```

## 五、集合的常用内置函数
| 函数        | 作用                  | 示例                          |
|-------------|-----------------------|-------------------------------|
| `len(s)`    | 获取集合元素个数      | `len({1,2,3})` → 3            |
| `max(s)`    | 获取集合最大元素      | `max({1,2,3})` → 3            |
| `min(s)`    | 获取集合最小元素      | `min({1,2,3})` → 1            |
| `sum(s)`    | 集合元素求和（数字）| `sum({1,2,3})` → 6            |
| `sorted(s)` | 集合转排序后的列表    | `sorted({3,1,2})` → [1,2,3]   |

示例：
```python
s = {5, 1, 3, 2, 4}
print(len(s))    # 5
print(max(s))    # 5
print(min(s))    # 1
print(sum(s))    # 15
print(sorted(s)) # [1, 2, 3, 4, 5]
```

## 六、集合的应用场景（实战）
### 1. 列表去重（最常用）
```python
lst = [1, 2, 2, 3, 3, 3, 4]
# 集合去重 → 转回列表
new_lst = list(set(lst))
print(new_lst)  # 输出：[1, 2, 3, 4]（顺序可能变化）

# 如需保留原列表顺序（Python3.7+）
new_lst = list(dict.fromkeys(lst))  # 字典key去重且保留顺序
print(new_lst)  # 输出：[1, 2, 3, 4]
```

### 2. 快速判断元素是否存在（比列表高效）
列表的`in`操作是O(n)，集合的`in`操作是O(1)，数据量大时差距极大：
```python
# 大数据量场景
big_lst = [i for i in range(1000000)]
big_set = set(big_lst)

# 列表查找（慢）
import time
start = time.time()
999999 in big_lst
print("列表查找耗时：", time.time() - start)  # 约0.01秒

# 集合查找（快）
start = time.time()
999999 in big_set
print("集合查找耗时：", time.time() - start)  # 约0.0001秒
```

### 3. 统计两个列表的共同元素/独有元素
```python
lst1 = [1, 2, 3, 4]
lst2 = [3, 4, 5, 6]

# 共同元素
common = list(set(lst1) & set(lst2))
print("共同元素：", common)  # [3,4]

# lst1独有元素
only_lst1 = list(set(lst1) - set(lst2))
print("lst1独有：", only_lst1)  # [1,2]

# lst2独有元素
only_lst2 = list(set(lst2) - set(lst1))
print("lst2独有：", only_lst2)  # [5,6]
```

## 七、集合 vs 其他数据结构（对比总结）
| 特性         | 集合(set)       | 列表(list)      | 字典(dict)      | 元组(tuple)     |
|--------------|-----------------|-----------------|-----------------|-----------------|
| 有序性       | 无序            | 有序            | 3.7+有序        | 有序            |
| 重复性       | 不可重复        | 可重复          | key不可重复     | 可重复          |
| 可变性       | 可变（增删元素）| 可变            | 可变            | 不可变          |
| 索引访问     | 不支持          | 支持            | 支持（key索引） | 支持            |
| 核心优势     | 去重、集合运算  | 灵活增删、索引  | 键值对映射      | 不可变、可哈希  |

## 八、总结
1. **核心特性**：无序、不重复、元素不可变；
2. **创建**：`{}`（非空）/`set()`（空）/`set(可迭代对象)`；
3. **基础操作**：
   - 增：`add()`（单个）、`update()`（批量）；
   - 删：`discard()`（安全）、`remove()`（报错）、`pop()`（随机）、`clear()`；
   - 查：`in`/`not in`、集合关系判断（子集/超集）；
4. **核心价值**：集合运算（交集`&`、并集`|`、差集`-`、对称差集`^`）；
5. **常用场景**：列表去重、快速判重、统计元素交集/差集。

掌握这些内容，就能覆盖集合的所有高频使用场景，避坑且高效！