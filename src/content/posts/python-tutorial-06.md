---
title: Python 入门教程（六）：函数详解
published: 2026-10-29
description: 系统讲解函数的定义与调用、参数全家族（默认/关键字/可变/仅关键字）、*与**解包、返回值、作用域与闭包、lambda 与高阶函数、装饰器入门，附实战重构案例。
tags: [Python, 编程入门, 教程]
category: 编程教程
slug: python-tutorial-06
series: "Python 入门教程"
seriesOrder: 6
---

## 本篇目标

前面所有代码都是"线性剧本"——从上往下一次演完。**函数**让你把一段逻辑打包成"招式"，随叫随到、反复使用。函数是代码复用的最小单元，也是从"写脚本"迈向"写工程"的第一步。

## 一、定义与调用

```python
def greet(name):
    """向指定的人问好"""          # docstring 文档字符串
    print(f"你好，{name}！")

greet("小明")        # 调用：你好，小明！
greet("小红")        # 同一段代码，复用无需复制粘贴
```

**语法要点**：

- `def 函数名(参数):` 定义；`函数名(实参)` 调用
- 定义不执行、调用才执行——函数可以定义在调用之前（Python 从上往下读）
- 三引号 docstring 描述函数用途，`help(greet)` 可查看
- 函数名规则：小写+下划线（`calc_average`），动词开头更佳

## 二、参数全家族

### 1. 位置参数：按顺序对号入座

```python
def introduce(name, age, major):
    print(f"我是{name}，{age}岁，专业{major}")

introduce("小明", 18, "计算机")    # 顺序必须一致
```

### 2. 关键字参数：指名道姓

```python
introduce(major="计算机", name="小明", age=18)   # 顺序随意
introduce("小明", major="软件工程", age=19)        # 位置在前，关键字在后 ✓
```

### 3. 默认参数：不传就用默认值

```python
def greet(name, greeting="你好"):
    print(f"{greeting}，{name}！")

greet("小明")                # 你好，小明！
greet("Tom", "Hello")        # Hello, Tom!
```

> [!WARNING]
> **默认参数的头号大坑——用可变对象做默认值**：
> ```python
> def add_item(item, items=[]):      # ❌ 危险！
>     items.append(item)
>     return items
>
> print(add_item(1))    # [1]
> print(add_item(2))    # [1, 2]！！默认列表被"记住"了
>
> # ✅ 正确姿势
> def add_item(item, items=None):
>     if items is None:
>         items = []
>     items.append(item)
>     return items
> ```
> 原因：默认值在函数定义时只创建一次。面试高频题。

### 4. 可变参数 *args：接收任意个数

```python
def total(*nums):
    print(type(nums))         # <class 'tuple'> 收进元组
    return sum(nums)

print(total(1, 2))            # 3
print(total(1, 2, 3, 4, 5))   # 15
```

### 5. 关键字可变参数 **kwargs：接收任意关键字参数

```python
def show_info(name, **extra):
    print(f"姓名：{name}")
    for k, v in extra.items():
        print(f"  {k}: {v}")

show_info("小明", age=18, city="北京", major="计算机")
# 姓名：小明
#   age: 18
#   city: 北京
#   major: 计算机
```

### 参数顺序铁律

```python
def func(位置参数, 默认参数=x, *args, **kwargs): ...
```

即：**普通 → 带默认 → *args → **kwargs**。

### * 与 ** 的解包妙用

```python
def area(a, b, c):
    # 海伦公式算三角形面积
    s = (a + b + c) / 2
    return (s*(s-a)*(s-b)*(s-c)) ** 0.5

sides = [3, 4, 5]
print(area(*sides))            # * 把列表拆成三个参数

info = {"name": "小明", "age": 18}
greet_info = lambda **kw: kw
print(greet_info(**info))      # ** 把字典拆成关键字参数
```

## 三、返回值

### return 的规则

```python
def is_even(n):
    if n % 2 == 0:
        return True
    return False               # 函数遇 return 立即结束

# 无 return 或只写 return → 返回 None
def say_hi():
    print("hi")

result = say_hi()
print(result)                  # None
```

### 返回多个值（本质是元组）

```python
def min_max(nums):
    return min(nums), max(nums)    # 打包成元组

low, high = min_max([3, 1, 4, 1, 5])   # 解包接收
print(low, high)                        # 1 5
```

### 函数与解包配合

```python
def divide(a, b):
    if b == 0:
        return None, "除数不能为 0"      # 失败返回错误信息
    return a / b, None

result, error = divide(10, 2)
if error:
    print("出错:", error)
else:
    print(f"结果: {result}")
```

## 四、作用域：变量看得见谁

### LEGB 规则

Python 查找变量的顺序：**L**ocal（函数内）→ **E**nclosing（外层函数）→ **G**lobal（模块级）→ **B**uilt-in（内置）。

```python
x = 10                  # 全局变量

def outer():
    y = 20              # outer 的局部变量
    def inner():
        z = 30          # inner 的局部变量
        print(x, y, z)  # 10 20 30：都能看到（LEGB 逐层向外找）
    inner()

outer()
```

### 局部改全局：global（慎用）

```python
count = 0

def click():
    global count        # 声明我要改全局变量
    count += 1

click(); click()
print(count)            # 2
```

> [!TIP]
> 需要 `global` 通常说明设计有问题——更好的做法是通过参数传入、返回值传出。多线程环境 global 是重灾区。

### 闭包：外层函数的变量被"记住"

```python
def make_counter():
    n = 0
    def counter():
        nonlocal n      # 声明改的是外层函数的变量（不是全局）
        n += 1
        return n
    return counter      # 返回函数本身（不带括号！）

c = make_counter()
print(c(), c(), c())    # 1 2 3：n 被 counter 记住了
```

`nonlocal` 用于修改**外层函数**的变量（`global` 是改模块级，别混淆）。

## 五、lambda 与高阶函数

### lambda：一行的小函数

```python
# lambda 参数: 表达式
square = lambda x: x ** 2
print(square(5))         # 25

# 等价的 def 写法
def square(x):
    return x ** 2
```

lambda 的定位：**临时、简单、用完即弃**，尤其作为参数传递时：

```python
students = [("小明", 90), ("小红", 85), ("小刚", 92)]
students.sort(key=lambda s: s[1])            # 按成绩排序
best = max(students, key=lambda s: s[1])     # 成绩最高的
```

复杂逻辑禁止写 lambda——写不下也读不懂，老实用 def。

### 三大高阶函数

**函数当参数传**的函数叫高阶函数：

```python
nums = [1, 2, 3, 4, 5, 6]

# map：逐个变换
squares = list(map(lambda x: x**2, nums))
print(squares)          # [1, 4, 9, 16, 25, 36]

# filter：按条件筛选
evens = list(filter(lambda x: x % 2 == 0, nums))
print(evens)            # [2, 4, 6]

# sorted（前面讲过）：带 key 排序
```

实际上推导式通常更清晰，map/filter 了解即可：

```python
squares = [x**2 for x in nums]          # 与 map 等价，更 Pythonic
evens = [x for x in nums if x % 2 == 0] # 与 filter 等价
```

## 六、递归：函数调用自己

```python
def factorial(n):
    """阶乘：n! = n × (n-1)!"""
    if n <= 1:               # 基线条件（出口）——必须有！
        return 1
    return n * factorial(n - 1)   # 递归调用

print(factorial(5))    # 120 = 5×4×3×2×1
```

**递归两要素**：基线条件（何时停）+ 递推关系（如何缩小学）。缺出口就是无限递归，触发 `RecursionError`（默认上限约 1000 层）。

经典：斐波那契的递归写法与低效问题——

```python
def fib(n):
    if n < 2:
        return n
    return fib(n-1) + fib(n-2)

print(fib(10))    # 55（fib(35) 就已经很慢——重复计算爆炸）
```

## 七、装饰器入门（进阶预告）

装饰器是"给函数套一层壳"的语法，Python 工程必用。看懂下面这个计时器，你就理解了它的工作原理：

```python
import time
from functools import wraps

def timer(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)      # 调用原函数
        cost = (time.time() - start) * 1000
        print(f"[{func.__name__}] 耗时 {cost:.2f}ms")
        return result
    return wrapper

@timer                        # 等价于 slow_sum = timer(slow_sum)
def slow_sum(n):
    return sum(range(n))

slow_sum(10_000_000)          # [slow_sum] 耗时 187.35ms
```

`@timer` 只是个语法糖。装饰器链、带参数的装饰器等进阶内容，等做项目时再深入。

## 八、实战重构：把脚本函数化

**重构前**（线性脚本，无法复用）：

```python
scores = [90, 85, 78, 92, 66]
total = sum(scores)
avg = total / len(scores)
print(f"平均 {avg:.1f}")
above = [s for s in scores if s >= avg]
print(f"高于平均: {above}")
```

**重构后**（函数化，可测试可复用）：

```python
def analyze(scores, precision=1):
    """分析成绩：返回统计摘要字典"""
    if not scores:
        return None
    avg = sum(scores) / len(scores)
    return {
        "count": len(scores),
        "avg": round(avg, precision),
        "max": max(scores),
        "min": min(scores),
        "above_avg": [s for s in scores if s >= avg],
    }

def report(data):
    """打印摘要"""
    if data is None:
        print("无数据")
        return
    print(f"人数 {data['count']}，平均 {data['avg']}，"
          f"最高 {data['max']}，高于平均 {len(data['above_avg'])} 人")

report(analyze([90, 85, 78, 92, 66]))
report(analyze([]))            # 无数据
```

**函数化三原则**：一个函数做一件事、参数进结果出（少用 global）、起个说清楚的名字。

## 小练习

1. 写 `is_prime(n)` 判断质数，再用它输出 100 内所有质数（重构第三篇的循环版）
2. 写 `apply_twice(func, x)`：把 func 应用两次，如 `apply_twice(lambda x: x*2, 5)` → 20
3. 写可变参数函数 `average(*nums)`，不传参数时返回 0
4. 用闭包写一个"密码尝试计数器"：每调用一次 `try_login()` 计数 +1，超过 3 次返回"已锁定"
5. （选做）给第三篇的猜数字游戏包一个 `play()` 函数，支持参数"最大范围"与"最多机会"

## 本篇小结

- 参数顺序：普通 → 默认 → `*args` → `**kwargs`；默认参数别用可变对象
- `*` 拆序列、`**` 拆字典；return 多值是元组
- LEGB 作用域；改全局用 global、改外层用 nonlocal，但都应少用
- lambda 用于临时的 key/短逻辑；map/filter 会被推导式替代
- 递归 = 基线条件 + 递推；装饰器 = 函数的"包装壳"
- 工程习惯：单一职责、参数进结果出、好名字

**下一篇**：迭代器与生成器——省内存的懒加载艺术。

---

*本系列为 Cyber先锋社原创教程。默认参数的坑和闭包计数器请亲手复现一遍。*
