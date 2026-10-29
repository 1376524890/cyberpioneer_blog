---
title: Python 入门教程（四）：列表与元组
published: 2026-10-29
description: 深入 Python 最核心的容器：列表的增删改查全家桶、切片操作、排序与遍历技巧、浅拷贝与深拷贝的坑、元组的不可变特性与解包，附购物车与成绩统计完整案例。
tags: [Python, 编程入门, 教程]
category: 编程教程
slug: python-tutorial-04
series: "Python 入门教程"
seriesOrder: 4
---

## 本篇目标

单个变量存单个值，但现实数据往往是"一堆"：一门课的所有成绩、购物车里的商品、通讯录联系人。**列表**和**元组**就是 Python 存放"一堆数据"的基础容器，也是使用频率最高的数据结构。

## 一、列表：可变的有序容器

### 创建与访问

```python
# 直接创建
scores = [90, 85, 78, 92, 66]
empty = []                     # 空列表
mixed = [1, "hello", 3.14, True]   # 可以混装类型（但不建议）
nested = [1, [2, 3], [4, [5]]]     # 列表可以嵌套

# list() 从其他序列转换
print(list("abc"))             # ['a', 'b', 'c']
print(list(range(5)))          # [0, 1, 2, 3, 4]
```

索引与切片规则与字符串完全一致（含头不含尾、负数索引）：

```python
scores = [90, 85, 78, 92, 66]

print(scores[0])      # 90
print(scores[-1])     # 66
print(scores[1:4])    # [85, 78, 92]
print(scores[::-1])   # 倒序列表
print(len(scores))    # 5
```

### 增：四种方式

```python
langs = ["Python"]

langs.append("Java")           # 尾部追加单个 → ['Python', 'Java']
langs.insert(1, "C++")         # 指定位置插入 → ['Python', 'C++', 'Java']
langs.extend(["Go", "Rust"])   # 合并另一个序列 → [..., 'Go', 'Rust']
langs += ["C#"]                # += 等价于 extend
```

> [!WARNING]
> `append` 与 `extend` 的经典坑：
> ```python
> a = [1, 2]
> a.append([3, 4])    # [1, 2, [3, 4]]   整个列表作为一个元素！
> b = [1, 2]
> b.extend([3, 4])    # [1, 2, 3, 4]     逐个合并 ✓
> ```

### 删：三种方式

```python
nums = [10, 20, 30, 20, 40]

nums.remove(20)        # 按值删：只删第一个匹配项 → [10, 30, 20, 40]
last = nums.pop()      # 按索引删并返回该值：40，nums → [10, 30, 20]
first = nums.pop(0)    # 弹出索引0：10
del nums[0]            # del 语句删除：30 被删
# nums 现在是 [20]

# 值不存在时 remove 会报 ValueError，安全写法：
if 999 in nums:
    nums.remove(999)
```

### 改：直接赋值

```python
scores = [90, 85, 78]
scores[0] = 95             # 单个改
scores[1:3] = [80, 88]     # 切片批量改
```

### 查：in / index / count

```python
langs = ["Python", "C++", "Java"]

print("Go" in langs)          # False
print(langs.index("Java"))    # 2（不存在会报 ValueError）
print([1, 2, 2, 3].count(2))  # 2
```

## 二、列表排序

### sort 与 sorted 的区别（必考题）

```python
nums = [3, 1, 4, 1, 5, 9, 2, 6]

# sorted()：返回新列表，原列表不动
new = sorted(nums)
print(new)               # [1, 1, 2, 3, 4, 5, 6, 9]
print(nums)              # [3, 1, 4, 1, 5, 9, 2, 6] 原样

# .sort()：原地排序，返回 None
nums.sort()
print(nums)              # [1, 1, 2, 3, 4, 5, 6, 9]

# 降序
nums.sort(reverse=True)
print(sorted(nums, reverse=True))
```

> [!WARNING]
> `nums = nums.sort()` 是经典错误——sort 返回 None，这句执行后 nums 变成 None。

### 按自定义规则排序：key 参数

```python
words = ["banana", "apple", "cherry", "fig"]

words.sort()                        # 字典序
words.sort(key=len)                 # 按长度：['fig', 'apple', ...]
words.sort(key=len, reverse=True)   # 按长度降序

# 排序复杂数据：按成绩降序
students = [("小明", 90), ("小红", 85), ("小刚", 92)]
students.sort(key=lambda s: s[1], reverse=True)
print(students)     # [('小刚', 92), ('小明', 90), ('小红', 85)]
```

`lambda s: s[1]` 是匿名函数（第六篇详讲），意思是"取每个元素的第 1 位作为排序依据"。

### max / min / sum

```python
scores = [90, 85, 78, 92, 66]

print(max(scores), min(scores), sum(scores))
# 92 66 411
print(f"平均分 {sum(scores)/len(scores):.1f}")   # 82.2
```

## 三、遍历与复制：深浅拷贝的坑

### 直接赋值 ≠ 复制

```python
a = [1, 2, 3]
b = a              # 不是复制！b 和 a 指向同一个列表
b.append(4)
print(a)           # [1, 2, 3, 4] —— a 也"变"了
print(a is b)      # True
```

### 浅拷贝的三种写法

```python
a = [1, 2, 3]
b = a.copy()       # 写法1
c = a[:]           # 写法2 切片
d = list(a)        # 写法3 构造

b.append(4)
print(a)           # [1, 2, 3] ✓ a 不受影响
print(a is b)      # False
```

### 浅拷贝依然有坑：嵌套结构

```python
a = [1, [2, 3]]
b = a.copy()       # 浅拷贝：只复制第一层
b[1].append(4)
print(a)           # [1, [2, 3, 4]] —— 内层列表是共享的！

# 深拷贝：彻底独立
import copy
c = copy.deepcopy(a)
c[1].append(99)
print(a)           # [1, [2, 3, 4]] 不受影响 ✓
```

**记忆法**：`=` 是"贴标签"，`.copy()` 是"复印一层"，`deepcopy` 是"整棵复印"。

## 四、案例：成绩统计与购物车

### 成绩统计

```python
scores = [90, 85, 78, 92, 66, 88, 73]

print(f"人数: {len(scores)}")
print(f"最高: {max(scores)}  最低: {min(scores)}")
print(f"平均: {sum(scores)/len(scores):.1f}")

# 统计各分数段
a = [s for s in scores if s >= 90]
b = [s for s in scores if 80 <= s < 90]
c = [s for s in scores if s < 60]
print(f"90+ 有 {len(a)} 人，挂科 {len(c)} 人")

# 排名（保留原下标）
ranking = sorted(enumerate(scores), key=lambda x: x[1], reverse=True)
for rank, (idx, s) in enumerate(ranking, 1):
    print(f"第{rank}名：{s}分（第{idx+1}位同学）")
```

### 购物车

```python
cart = []            # [(商品名, 单价, 数量), ...]

def add_item(name, price, qty=1):
    for i, (n, p, q) in enumerate(cart):
        if n == name:                    # 已存在则加数量
            cart[i] = (n, p, q + qty)
            return
    cart.append((name, price, qty))

def checkout():
    total = sum(p * q for _, p, q in cart)
    print("---- 账单 ----")
    for name, price, qty in cart:
        print(f"{name} × {qty} = ¥{price*qty:.2f}")
    print(f"合计：¥{total:.2f}")

add_item("键盘", 199, 1)
add_item("鼠标", 89, 2)
add_item("键盘", 199, 1)    # 再买一把 → 数量变 2
checkout()
```

## 五、元组：不可变的列表

### 创建与使用

```python
point = (3, 5)
single = (42,)          # ⚠️ 单元素必须带逗号！
also_tuple = 1, 2, 3    # 括号可省，逗号才是本质
x, y = point            # 解包：x=3, y=5
print(also_tuple)
```

元组支持索引、切片、len、in、遍历——**一切"读"操作都与列表相同**；但不能增删改：

```python
point = (3, 5)
print(point[0], len(point), 3 in point)   # ✓ 都可以
point[0] = 10     # ❌ TypeError
point.append(6)   # ❌ 没有这个方法
```

### 为什么需要元组

1. **安全**：不希望被修改的数据（坐标、配置、日期）用元组，防止误改
2. **字典键**：列表不可哈希不能做键，元组可以：`locations = {(39.9, 116.4): "北京"}`
3. **函数多返回值**：`return x, y` 本质就是返回元组
4. **性能**：比列表省内存、创建更快

### 元组与列表互转

```python
t = (1, 2, 3)
lst = list(t)          # (1,2,3) → [1,2,3]
back = tuple(lst)      # [1,2,3] → (1,2,3)
```

## 六、列表 vs 元组选择指南

| 场景 | 选择 |
| --- | --- |
| 会增删改的数据（待办、消息队列） | 列表 |
| 固定不变的数据（坐标、常量组） | 元组 |
| 需要做字典的键 | 元组 |
| 函数返回多个值 | 元组（自动） |

## 小练习

1. 合并两个列表并去重排序：`[1,3,5]` 与 `[2,3,6]` → `[1,2,3,5,6]`（提示：set 或 手写）
2. 统计列表中出现次数最多的元素（不用库，提示：count + max）
3. 矩阵转置：`[[1,2,3],[4,5,6]]` → `[[1,4],[2,5],[3,6]]`（提示：嵌套推导式）
4. 交换 `a = (1, [2, 3])` 元组中内层列表的第 0 个元素为 99——会报错吗？（动手验证：元组不可变，但内层列表可以）

## 本篇小结

- 列表增删改查：append/extend、insert、remove/pop/del、index/count
- sorted 返回新列表，.sort() 原地排序；key 参数自定义规则
- `=` 是引用，`.copy()` 浅拷贝只复制一层，嵌套结构用 deepcopy
- 元组不可变但可读；单元素要带逗号；适合做字典键与返回值
- 容器选型：要改用列表，固定用元组

**下一篇**：字典与集合——用键查值的"通讯录"与自动去重的"收纳盒"。

---

*本系列为 Cyber先锋社原创教程。深浅拷贝的例子请务必亲手跑一遍，坑过一次就记住了。*
