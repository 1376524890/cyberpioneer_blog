---
title: Python 入门教程（五）：字典与集合
published: 2026-10-29
description: 掌握键值对容器字典的增删改查、get 与 setdefault、遍历三件套与嵌套结构，以及集合的去重、交并差运算，附词频统计与通讯录管理完整实战。
tags: [Python, 编程入门, 教程]
category: 编程教程
slug: python-tutorial-05
series: "Python 入门教程"
seriesOrder: 5
---

## 本篇目标

列表用"位置"找数据（`nums[0]`），但很多时候我们需要用"名字"找数据——学号查成绩、用户名查密码、单词查释义。**字典**就是干这个的；**集合**则是自动去重的数学容器。学完本篇，Python 四大容器（列表/元组/字典/集合）就集齐了。

## 一、字典：键值对映射

### 创建与基本访问

```python
# 键值对：{键: 值, ...}
student = {
    "name": "小明",
    "age": 18,
    "major": "计算机科学",
    "scores": {"python": 90, "cpp": 85},   # 字典可以嵌套
}

print(student["name"])            # 小明
print(student["scores"]["python"])   # 90（链式访问嵌套）

# 空字典
empty = {}
also_empty = dict()

# dict() 构造
ages = dict(小明=18, 小红=17)      # {'小明': 18, '小红': 17}
pairs = dict([("a", 1), ("b", 2)]) # {'a': 1, 'b': 2}
```

**键的要求**：必须不可变（字符串/数字/元组可以，列表不行），且唯一（重复定义后者覆盖前者）。

### 增与改

```python
user = {"name": "小明"}

user["age"] = 18          # 键不存在 → 新增
user["age"] = 19          # 键已存在 → 修改
user.update({"city": "北京", "age": 20})   # 批量增改
print(user)               # {'name': '小明', 'age': 20, 'city': '北京'}
```

### 查：安全访问三件套

```python
user = {"name": "小明", "age": 18}

# 1. [] 直接访问：键不存在直接报错
print(user["name"])          # 小明
# print(user["email"])       # ❌ KeyError!

# 2. .get()：不存在返回 None（或默认值），推荐
print(user.get("email"))             # None
print(user.get("email", "未填写"))    # 未填写

# 3. in：先判断再访问
if "age" in user:
    print("年龄:", user["age"])
```

> [!TIP]
> 日常写法用 `.get()`；确定键必存在（如自己刚放进去的）才用 `[]`。

### setdefault：不存在才设置

```python
stats = {}
# 统计字符出现次数的优雅写法
for ch in "hello":
    stats.setdefault(ch, 0)   # 没有该键就先设为 0
    stats[ch] += 1
print(stats)     # {'h': 1, 'e': 1, 'l': 2, 'o': 1}
```

### 删

```python
user = {"name": "小明", "age": 18, "city": "北京"}

age = user.pop("age")      # 删除并返回值：18
del user["city"]           # del 语句删除
user.pop("email", None)    # 键不存在不报错（给了默认值）

last = user.popitem()      # 删除并返回最后一个键值对
print(user)                # {}
```

### 遍历三件套

```python
scores = {"小明": 90, "小红": 85, "小刚": 92}

# 遍历键（默认就是遍历键）
for name in scores:
    print(name)

# 遍历值
for score in scores.values():
    print(score)

# 同时遍历键和值（最常用）
for name, score in scores.items():
    print(f"{name}: {score} 分")
```

### 其他常用操作

```python
scores = {"小明": 90, "小红": 85}

print(len(scores))            # 2
print(max(scores, key=scores.get))   # 小刚→最高分的人名（key=按值比较）
print(list(scores.keys()))    # ['小明', '小红']
print(list(scores.values()))  # [90, 85]

# 合并（Python 3.5+）
extra = {"小刚": 92}
all_scores = {**scores, **extra}
# Python 3.9+ 更简洁：
all_scores = scores | extra
```

### 案例：词频统计（字典最经典应用）

```python
text = """python is simple and python is powerful
learn python and code python"""

# 方法：setdefault 计数
freq = {}
for word in text.split():
    freq.setdefault(word, 0)
    freq[word] += 1

# 按次数降序输出 Top 3
for word, count in sorted(freq.items(), key=lambda x: x[1], reverse=True)[:3]:
    print(f"{word}: {count} 次")
# python: 4 次
# and: 2 次
# is: 2 次
```

### 案例：通讯录（嵌套字典）

```python
contacts = {
    "小明": {"phone": "138xxxx", "city": "北京", "tags": ["同学", "编程组"]},
    "小红": {"phone": "139xxxx", "city": "上海", "tags": ["同学"]},
}

def show(name):
    info = contacts.get(name)
    if info is None:
        print(f"没有 {name} 的联系方式")
        return
    tags = "/".join(info["tags"])
    print(f"{name}｜{info['phone']}｜{info['city']}｜标签: {tags}")

def search_by_city(city):
    found = [n for n, i in contacts.items() if i["city"] == city]
    print(f"{city} 的联系人: {found}")

show("小明")           # 小明｜138xxxx｜北京｜标签: 同学/编程组
search_by_city("上海")  # 上海 的联系人: ['小红']
```

## 二、集合：去重与集合运算

### 创建与去重

```python
# 花括号内是元素（不是键值对）就是集合
fruits = {"apple", "banana", "apple", "cherry"}
print(fruits)          # {'apple', 'banana', 'cherry'} 自动去重！
print(len(fruits))     # 3

# ⚠️ 空花括号是字典不是集合！
empty_dict = {}
empty_set = set()      # 空集合必须用 set()

# 从列表去重（最常用场景）
nums = [1, 3, 2, 3, 1, 5]
unique = list(set(nums))
print(unique)          # [1, 2, 3, 5]（顺序不保证！）

# 去重且保序的写法
unique_ordered = list(dict.fromkeys(nums))
print(unique_ordered)  # [1, 3, 2, 5] ✓ 保持原序
```

### 增删

```python
s = {1, 2, 3}

s.add(4)          # 添加单个
s.update([5, 6])  # 添加多个
s.remove(9)       # ❌ 不存在会 KeyError
s.discard(9)      # ✓ 不存在也不报错（推荐）
s.pop()           # 随机弹出一个元素
print(s)
```

### 集合运算：交并差

两个班的选课情况对比：

```python
class_a = {"python", "cpp", "java", "go"}
class_b = {"python", "java", "rust", "js"}

# 交集：都选了的课
print(class_a & class_b)          # {'python', 'java'}
print(class_a.intersection(class_b))   # 同上

# 并集：所有人选过的课
print(class_a | class_b)          # {'python','cpp','java','go','rust','js'}

# 差集：A 选了 B 没选的
print(class_a - class_b)          # {'cpp', 'go'}

# 对称差：只有一方选了的（并集 - 交集）
print(class_a ^ class_b)          # {'cpp', 'go', 'rust', 'js'}

# 子集与超集
print({"python"} <= class_a)      # True 子集判断
print(class_a.issubset(class_a | class_b))   # True
```

**助记**：`&` 交（都有的）、`|` 并（合起来）、`-` 差（我有你没有）、`^` 异（不共有的）。

### 集合推导式与 frozenset

```python
squares = {i**2 for i in range(1, 6)}
print(squares)      # {1, 4, 9, 16, 25}

# frozenset：不可变集合，可作为字典键
fs = frozenset([1, 2, 3])
# fs.add(4)         # ❌ 不可变
cache = {fs: "结果"}   # ✓ 合法
```

### 成员测试的性能优势

`in` 集合是 O(1)，`in` 列表是 O(n)——数据量大时差距巨大：

```python
import time

big_list = list(range(1_000_000))
big_set = set(big_list)

t1 = time.time()
for _ in range(100):
    999_999 in big_list
t2 = time.time()
for _ in range(100):
    999_999 in big_set
t3 = time.time()

print(f"列表查找: {(t2-t1)*1000:.1f}ms")
print(f"集合查找: {(t3-t2)*1000:.1f}ms")   # 快百倍以上
```

**实践建议**：频繁判断"某元素是否在一堆数据里"时，把那堆数据转成集合。

## 三、四大容器总对比

| 特性 | 列表 list | 元组 tuple | 字典 dict | 集合 set |
| --- | --- | --- | --- | --- |
| 符号 | `[1,2]` | `(1,2)` | `{"k":v}` | `{1,2}` |
| 有序 | ✓ | ✓ | ✓（3.7+保序） | ✗ |
| 可变 | ✓ | ✗ | ✓ | ✓ |
| 允许重复 | ✓ | ✓ | 键不行 | ✗ |
| 典型用途 | 序列数据 | 固定数据 | 映射查找 | 去重/集合运算 |
| 查找效率 | O(n) | O(n) | O(1) 按键 | O(1) |

**选型口诀**：排队用列表、锁死用元组、查名用字典、去重用集合。

## 小练习

1. 统计一句话中每个汉字出现的次数，按次数降序输出（用字典）
2. 两个班学生名单去重合并：A 班 `["a","b","c","d"]`、B 班 `["c","d","e","f"]`，输出所有人都名单与"只在一个班"的人
3. 实现简单的英汉字典：支持查词（不存在提示"未收录"）、添加新词、遍历输出所有词条
4. 用集合推导式生成 1~100 中能被 3 或 5 整除的数的平方集合

## 本篇小结

- 字典按键存取 O(1)；安全访问用 `.get()`；计数用 `setdefault`
- 遍历三件套：`keys()` / `values()` / `items()`
- 合并字典：`{**a, **b}` 或 3.9+ 的 `a | b`
- 集合自动去重；`& | - ^` 四大运算；`discard` 比 `remove` 安全
- 空集合用 `set()`；频繁成员测试选集合不选列表
- 四大容器选型口诀：排队列表、锁死元组、查名字典、去重集合

**下一篇**：函数——把代码封装成可复用的积木。

---

*本系列为 Cyber先锋社原创教程。词频统计是面试与实战双高频题，务必独立写一遍。*
