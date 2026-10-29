---
title: Python 入门教程（七）：迭代器与生成器
published: 2026-10-29
description: 理解 for 循环背后的迭代协议、迭代器与可迭代对象的区别、生成器函数与生成器表达式的懒加载、yield 的执行原理、无限序列与管道式数据处理，掌握省内存的 Pythonic 写法。
tags: [Python, 编程入门, 教程]
category: Python 教程
slug: python-tutorial-07
series: "Python 入门教程"
seriesOrder: 7
---

## 本篇目标

你每天都在用 `for x in ...`，但有没有想过 for 到底是怎么"一个个取出"元素的？这背后是 Python 的**迭代协议**。理解它，你就能用**生成器**写出处理百万行数据也不爆内存的代码——这是 Python 进阶的第一道分水岭。

## 一、for 循环的真相：迭代协议

### 可迭代对象与迭代器

```python
nums = [1, 2, 3]

for n in nums:
    print(n)
```

这段代码的幕后流程：

1. Python 对 `nums` 调用 `iter()` 拿到一个**迭代器**
2. 反复对迭代器调用 `next()` 取元素
3. 抛出 `StopIteration` 异常时结束循环

手动模拟一遍：

```python
nums = [1, 2, 3]
it = iter(nums)          # 列表 → 迭代器

print(next(it))          # 1
print(next(it))          # 2
print(next(it))          # 3
# print(next(it))        # ❌ StopIteration！取完了
```

**两个概念**：

| 概念 | 说明 | 例子 |
| --- | --- | --- |
| **可迭代对象 Iterable** | 实现了 `__iter__`，能被 for 遍历 | 列表、字符串、字典、文件 |
| **迭代器 Iterator** | 实现了 `__iter__` 和 `__next__`，能被 next() | `iter(列表)` 的返回值 |

关系：迭代器一定可迭代；可迭代对象要通过 iter() 变成迭代器才能 next()。

```python
from collections.abc import Iterable, Iterator

nums = [1, 2, 3]
print(isinstance(nums, Iterable))     # True
print(isinstance(nums, Iterator))     # False！列表本身不是迭代器
print(isinstance(iter(nums), Iterator))   # True
```

### 迭代器是一次性的

```python
it = iter([1, 2, 3])
for x in it:
    print(x, end=" ")     # 1 2 3
for x in it:
    print(x, end=" ")     # （空！已耗尽）
```

而列表可以反复 for——因为每次 for 都会重新 `iter()` 出新迭代器。

## 二、生成器函数：yield 的魔法

### 从写一个开始

函数体里出现 `yield`，它就不再是普通函数，而是**生成器函数**——调用它不执行代码，而是返回一个生成器（一种迭代器）：

```python
def count_down(n):
    print("开始倒数")
    while n > 0:
        yield n          # 产出 n，在此暂停！
        n -= 1

gen = count_down(3)
print(gen)               # <generator object ...> 还没执行！

print(next(gen))         # 打印"开始倒数"，返回 3
print(next(gen))         # 2（从暂停处继续）
print(next(gen))         # 1
# next(gen)              # ❌ StopIteration
```

**yield 与 return 的本质区别**：

- `return`：交值、函数终结
- `yield`：交值、函数**暂停**，下次 next 从暂停行继续，局部变量全部保留

### 生成器 + for：正常使用姿势

```python
def count_down(n):
    while n > 0:
        yield n
        n -= 1

for x in count_down(5):
    print(x, end=" ")     # 5 4 3 2 1
```

## 三、为什么用生成器：省内存

### 对比实验

生成 1000 万个平方数：

```python
import sys

# 列表：一次性全造好放内存
big_list = [x**2 for x in range(10_000_000)]
print(f"列表占用: {sys.getsizeof(big_list)/1024/1024:.0f} MB")   # 约 80+ MB

# 生成器：用时才算，只存"当前位置"
big_gen  = (x**2 for x in range(10_000_000))
print(f"生成器占用: {sys.getsizeof(big_gen)} 字节")              # 约 200 字节！
```

**生成器表达式**：把列表推导式的 `[]` 换成 `()` 即可。数据流"边生成边消费"，内存占用恒定——处理大文件、大数据集的标准姿势。

### 求和场景实测

```python
# 一亿个数求和：列表版可能内存吃紧
total = sum(x for x in range(100_000_000))    # 生成器：平稳跑完
print(total)
```

## 四、生成器实战模式

### 1. 无限序列

生成器不预生成全部，所以能表达"无限"：

```python
def fibonacci():
    """无限斐波那契数列"""
    a, b = 0, 1
    while True:            # 死循环？配合 yield 就是无限流
        yield a
        a, b = b, a + b

# 取前 10 个：islice 从无限流切片
from itertools import islice
print(list(islice(fibonacci(), 10)))
# [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]

# 找到第一个大于 1000 的斐波那契数
for f in fibonacci():
    if f > 1000:
        print(f)          # 1597
        break
```

### 2. 读大文件（最经典场景）

```python
def read_large_file(path):
    """逐行读取大文件，绝不整体载入"""
    with open(path, encoding="utf-8") as f:
        for line in f:            # 文件对象本身可迭代（懒加载）
            yield line.strip()

# 统计一个 10GB 日志也只用几 MB 内存
error_count = 0
for line in read_large_file("app.log"):
    if "ERROR" in line:
        error_count += 1
print(f"错误行数: {error_count}")
```

### 3. 管道式处理（生成器链）

多个生成器串成流水线，数据像水流过每一站：

```python
def lines(path):
    with open(path, encoding="utf-8") as f:
        yield from f            # yield from：把子生成器的值逐个转发

def only_errors(lines_iter):
    for line in lines_iter:
        if "ERROR" in line:
            yield line

def with_lineno(lines_iter):
    for i, line in enumerate(lines_iter, 1):
        yield f"行{i}: {line.rstrip()}"

# 组装流水线：此刻什么都没发生（全懒）
pipeline = with_lineno(only_errors(lines("app.log")))

# 消费时数据才逐条流过三层
for item in pipeline:
    print(item)
```

`yield from iterable` 等价于 `for x in iterable: yield x` 的简写。

### 4. 生成器实现滑窗

```python
def window(seq, size):
    """滑动窗口：[1,2,3,4] size=2 → (1,2) (2,3) (3,4)"""
    for i in range(len(seq) - size + 1):
        yield tuple(seq[i:i+size])

print(list(window([1, 2, 3, 4, 5], 3)))
# [(1, 2, 3), (2, 3, 4), (3, 4, 5)]
```

## 五、itertools：迭代器工具箱（标准库）

```python
from itertools import chain, product, combinations, islice, count

# chain：拼接多个可迭代对象
print(list(chain([1, 2], "ab", (3,))))      # [1, 2, 'a', 'b', 3]

# product：笛卡尔积（嵌套循环的扁平写法）
print(list(product("AB", "12")))
# [('A','1'), ('A','2'), ('B','1'), ('B','2')]

# combinations：组合（不重复）
print(list(combinations([1, 2, 3], 2)))     # [(1,2), (1,3), (2,3)]

# count：无限计数器
for i in count(10, 5):      # 从10开始步进5：10,15,20...
    if i > 25: break
    print(i, end=" ")       # 10 15 20 25

# islice：给无限流"切片"
print(list(islice(count(1, 2), 5)))         # [1, 3, 5, 7, 9]
```

## 六、自定义迭代器类（预习面向对象）

给类实现 `__iter__` 和 `__next__`，就能被 for 遍历：

```python
class Countdown:
    def __init__(self, start):
        self.n = start

    def __iter__(self):
        return self          # 自己就是迭代器

    def __next__(self):
        if self.n <= 0:
            raise StopIteration
        self.n -= 1
        return self.n + 1

for x in Countdown(3):
    print(x, end=" ")        # 3 2 1
```

类的语法下一篇详讲，此处先混个脸熟。

## 七、何时用生成器 vs 列表

| 场景 | 选择 |
| --- | --- |
| 数据大（文件/百万行） | 生成器 |
| 只遍历一次 | 生成器 |
| 需反复遍历 / 下标访问 / len() | 列表 |
| 需要切片、排序完整结果 | 列表 |
| 无限/未知长度的流 | 只能生成器 |

**性能口诀**：一次消费用生成，多次使用存列表。

## 小练习

1. 写生成器 `running_average(nums)`：每接收一个数 yield 当前的平均值
2. 用生成器表达式求 1~1000 中所有素数的平方和（提示：配合第五篇的 is_prime 思路）
3. 写无限生成器 `cycle(seq)`：`cycle("AB")` 产出 A B A B...（不许看 itertools 源码）
4. 用管道模式实现：读入一组英文句子 → 只保留含 "python" 的行 → 全部转小写 → 前 5 条（三层生成器链）
5. （选做）对比 `sum([i**2 for i in range(10**7)])` 与 `sum(i**2 for i in range(10**7))` 的内存占用差异（用 `sys.getsizeof` 或内存监视器）

## 本篇小结

- for 的本质：`iter()` 拿迭代器 → 反复 `next()` → StopIteration 结束
- 可迭代 ≠ 迭代器；迭代器是一次性的
- `yield` 让函数暂停/恢复；生成器函数调用返回生成器
- 生成器表达式 `(x for x in ...)` 惰性求值，内存恒定
- 四大实战模式：无限序列、大文件、管道链、滑窗
- itertools 提供现成工具：chain/product/combinations/islice/count

**下一篇**：模块与标准库——站在 Python 自带的"百宝箱"上开发。

---

*本系列为 Cyber先锋社原创教程。把"管道处理日志"例子跑通，你会对数据流有全新体感。*
