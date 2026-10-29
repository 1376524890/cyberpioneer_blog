---
title: Python 入门教程（三）：条件判断与循环控制
published: 2026-10-29
description: 完整讲解 if/elif/else 分支结构、while 与 for 循环、range 与 enumerate、break/continue/else 子句、循环嵌套与推导式，用经典练习题巩固流程控制。
tags: [Python, 编程入门, 教程]
category: 编程教程
slug: python-tutorial-03
series: "Python 入门教程"
seriesOrder: 3
---

## 本篇目标

前两篇的程序都是"从头跑到尾"，本篇让程序拥有**判断**（走哪条路）和**重复**（反复做事）的能力。这两者是所有程序逻辑的基石，学完本篇你就能写出真正"有逻辑"的程序了。

## 一、代码块与缩进：Python 的命门

Python 不用 `{}` 園代码块，而用**缩进**（官方推荐 4 个空格）：

```python
if score >= 60:
    print("及格")          # 缩进的行属于 if
    print("继续努力")      # 同级缩进 = 同一块代码
print("无论如何都执行")     # 不缩进 = 在 if 外面
```

> [!WARNING]
- 缩进错误（IndentationError）是新手最高频报错。规则：**同级代码缩进必须完全一致**，禁止 tab 和空格混用。把编辑器的 Tab 键设置为"插入 4 空格"一劳永逸。

## 二、条件判断

### 基础 if / else

```python
score = 75

if score >= 60:
    print("及格")
else:
    print("不及格")
```

### 多分支 elif

```python
score = 85

if score >= 90:
    grade = "优秀"
elif score >= 80:
    grade = "良好"
elif score >= 70:
    grade = "中等"
elif score >= 60:
    grade = "及格"
else:
    grade = "不及格"

print(f"等级：{grade}")    # 良好
```

**执行逻辑**：从上往下逐个判断，命中即止——所以条件要**从严格到宽松**排列。如果把 `score >= 60` 放第一个，90 分也会被判"及格"。

### 嵌套判断

```python
age = 20
has_id = True

if age >= 18:
    if has_id:
        print("允许进入")
    else:
        print("请出示证件")
else:
    print("未成年禁止入内")
```

嵌套超过两层就该考虑合并条件：`if age >= 18 and has_id:`。

### 条件表达式（三元运算符）

一行搞定简单二选一：

```python
age = 20
status = "成年" if age >= 18 else "未成年"
print(status)     # 成年
```

### match-case（Python 3.10+ 结构化匹配）

```python
def handle(command):
    match command.split():
        case ["go", direction]:
            return f"向 {direction} 移动"
        case ["look"]:
            return "环顾四周"
        case ["pick", item, "up"]:
            return f"捡起 {item}"
        case _:
            return "未知指令"

print(handle("go north"))     # 向 north 移动
print(handle("pick key up"))  # 捡起 key
```

适合替代长串 elif，`case _` 是兜底分支。

## 三、while 循环：条件驱动

```python
count = 1
while count <= 5:
    print(f"第 {count} 圈")
    count += 1        # 千万别忘了改变条件，否则死循环！
```

**三要素**：初始化（count=1）、条件（<=5）、更新（count+=1）。漏掉第三步就是死循环。

### 经典应用：猜数字游戏

```python
import random

answer = random.randint(1, 100)   # 1~100 随机整数
tries = 0

while True:
    guess = int(input("猜一个 1-100 的数："))
    tries += 1

    if guess < answer:
        print("小了")
    elif guess > answer:
        print("大了")
    else:
        print(f"猜对了！用了 {tries} 次")
        break       # 跳出循环
```

`while True` + `break` 是"先执行、后判断退出"的标准写法。

## 四、for 循环：遍历序列

for 用来**逐个取出**序列（字符串/列表/字典…）里的元素：

```python
# 遍历字符串
for ch in "abc":
    print(ch)          # a b c 各一行

# 遍历列表
for lang in ["Python", "C++", "Java"]:
    print(lang)

# 遍历字典：items() 同时拿键和值
scores = {"小明": 90, "小红": 85}
for name, score in scores.items():
    print(f"{name}: {score}分")
```

### range()：生成数字序列

```python
range(5)         # 0 1 2 3 4        （含头不含尾）
range(1, 6)      # 1 2 3 4 5
range(0, 10, 2)  # 0 2 4 6 8        （步长 2）
range(10, 0, -1) # 10 9 8 ... 1     （倒序）

for i in range(1, 4):
    print(f"{i} 的平方是 {i**2}")
```

### enumerate()：同时拿下标和元素

```python
langs = ["Python", "C++", "Java"]

# 笨办法
for i in range(len(langs)):
    print(i, langs[i])

# 优雅办法
for i, lang in enumerate(langs):
    print(f"第{i}名：{lang}")
# 第0名：Python ...
```

### zip()：并行遍历多个序列

```python
names = ["小明", "小红", "小刚"]
scores = [90, 85, 78]

for name, score in zip(names, scores):
    print(f"{name}: {score}分")
```

## 五、break、continue 与循环 else

```python
# break：立即终止整个循环
for n in [3, 7, 12, 5, 8]:
    if n > 10:
        print(f"找到大于10的数：{n}")
        break

# continue：跳过本次，进入下一次
for n in range(10):
    if n % 2 == 0:
        continue       # 偶数跳过
    print(n, end=" ")  # 1 3 5 7 9
```

**循环的 else 子句**（Python 特色，别处没有）：循环**没被 break 打断**而正常结束才执行：

```python
# 找质数的标准姿势
n = 13
for i in range(2, n):
    if n % i == 0:
        print(f"{n} 不是质数，能被 {i} 整除")
        break
else:
    print(f"{n} 是质数")     # 循环正常跑完没 break → 是质数
```

## 六、循环嵌套：二维世界

```python
# 九九乘法表
for i in range(1, 10):
    for j in range(1, i + 1):
        print(f"{j}×{i}={i*j}", end="\t")
    print()    # 每行结束换行
```

输出（三角形排布）：

```text
1×1=1
1×2=2  2×2=4
1×3=3  2×3=6  3×3=9
...（共 9 行）
```

嵌套循环次数是**相乘**的：外 3 次内 4 次共 12 次，层数越多越要小心性能。

## 七、推导式：循环的语法糖（进阶必备）

用一行表达"遍历 + 处理 + 收集"：

```python
# 列表推导式：[表达式 for 变量 in 序列 if 条件]
squares = [i**2 for i in range(1, 6)]
print(squares)          # [1, 4, 9, 16, 25]

evens = [i for i in range(20) if i % 2 == 0]
print(evens)            # [0, 2, 4, 6, 8, ...]

# 带条件表达式
labels = ["偶" if i % 2 == 0 else "奇" for i in range(5)]
print(labels)           # ['偶', '奇', '偶', '奇', '偶']

# 字典推导式
word = "hello"
freq = {ch: word.count(ch) for ch in set(word)}
print(freq)             # {'h': 1, 'e': 1, 'l': 2, 'o': 1}
```

**可读性原则**：逻辑超过一层嵌套就老实写 for 循环，别炫技。

## 八、经典练习（附思路）

### 1. 计算 1~100 的和

```python
total = 0
for i in range(1, 101):
    total += i
print(total)    # 5050
# 数学解法彩蛋：print(100*101//2)
```

### 2. 打印斐波那契数列前 20 项

```python
a, b = 0, 1
for _ in range(20):
    print(a, end=" ")
    a, b = b, a + b
# 0 1 1 2 3 5 8 13 21 ...
```

### 3. 判断质数（函数版在第六篇会重写）

```python
n = int(input("输入一个数："))

if n < 2:
    print("不是质数")
else:
    for i in range(2, int(n**0.5) + 1):    # 只需检查到平方根
        if n % i == 0:
            print(f"不是质数，{n} = {i} × {n//i}")
            break
    else:
        print("是质数")
```

**优化点**：判断到 `n**0.5` 即可——若 n 有大于平方根的因子，必然对应一个小于平方根的因子。

### 4. 水仙花数（三位数 = 各位数字立方和）

```python
for n in range(100, 1000):
    digits = str(n)
    if int(digits[0])**3 + int(digits[1])**3 + int(digits[2])**3 == n:
        print(n)      # 153 370 371 407
```

## 小练习

1. 输入一个整数，倒序逐位输出（如 1234 → 4 3 2 1），分别用 while 和字符串切片两种方法实现
2. 打印 100 内所有能被 3 整除但不含数字 3 的数（提示：`"3" not in str(n)`）
3. 用嵌套循环打印直角三角形星号图案（5 行）
4. 用列表推导式生成 1~50 中所有奇数的平方列表

## 本篇小结

- 缩进即语法：同级一致，4 空格，禁混 tab
- if/elif 从严到宽；三元表达式一行二选一；3.10+ 可用 match-case
- while 三要素；for 遍历序列；range 生成数字；enumerate 带下标；zip 并行
- break 终止 / continue 跳过 / 循环 else 表示"没被 break"
- 推导式是"遍历+收集"的语法糖，一层以内使用

**下一篇**：列表与元组——Python 最常用的数据容器。

---

*本系列为 Cyber先锋社原创教程。练习务必亲手做，答案写进你自己的代码笔记本。*
