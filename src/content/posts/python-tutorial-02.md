---
title: Python 入门教程（二）：运算符与字符串详解
published: 2026-10-29
description: 详解 Python 全部七类运算符（算术/比较/赋值/逻辑/成员/身份/位运算）与字符串的索引切片、常用方法、格式化输出，配套大量可运行示例。
tags: [Python, 编程入门, 教程]
category: 编程教程
slug: python-tutorial-02
series: "Python 入门教程"
seriesOrder: 2
---

## 本篇目标

上一篇我们让程序"跑了起来"，本篇把两块地基打牢：**运算符**（程序怎么算）和**字符串**（文本怎么处理）。这两块内容贯穿所有后续教程，务必动手把每个示例跑一遍。

## 一、运算符全解

Python 有七类运算符，逐一来看。

### 1. 算术运算符

```python
a, b = 10, 3

print(a + b)    # 13    加
print(a - b)    # 7     减
print(a * b)    # 30    乘
print(a / b)    # 3.3333333333333335  除，结果一定是 float
print(a // b)   # 3     整除（向下取整）
print(a % b)    # 1     取模（余数）
print(a ** b)   # 1000  幂
```

**三个易错点**：

1. `/` 永远返回 float，哪怕能整除：`10 / 2` 得 `5.0`
2. `//` 是**向下取整**，负数时要小心：

```python
print(-10 // 3)   # -4  （不是 -3！向负无穷方向取）
print(-10 % 3)    # 2   （余数符号跟除数一致）
```

3. 浮点数有精度问题，这是所有语言的通病：

```python
print(0.1 + 0.2)            # 0.30000000000000004
print(0.1 + 0.2 == 0.3)     # False！
```

需要精确计算（如金额）时用 `decimal` 模块：

```python
from decimal import Decimal
print(Decimal("0.1") + Decimal("0.2") == Decimal("0.3"))   # True
```

### 2. 比较运算符

```python
print(3 > 2)      # True
print(3 < 2)      # False
print(3 >= 3)     # True
print(3 == 3)     # True   相等是两个等号！
print(3 != 3)     # False  不等号
```

> [!WARNING]
> 新手第一大坑：`=` 是赋值，`==` 才是比较。写 `if x = 3:` 会直接报语法错误——这是 Python 刻意设计的保护。

Python 支持链式比较，很优雅：

```python
age = 20
print(18 <= age < 60)   # True，等价于 18 <= age and age < 60
```

### 3. 赋值运算符

```python
x = 10
x += 5    # x = x + 5 → 15
x -= 3    # 12
x *= 2    # 24
x //= 5   # 4
x **= 2   # 16
```

**多重赋值与解包**：

```python
a, b = 1, 2          # 同时赋值
a, b = b, a          # 经典：一行交换两个变量（无需临时变量）
x = y = 0            # 链式赋值，x 和 y 都是 0

first, *rest = [1, 2, 3, 4]   # 星号解包：first=1, rest=[2,3,4]
print(first, rest)   # 1 [2, 3, 4]
```

### 4. 逻辑运算符

Python 用英文单词而非符号：

```python
age = 20
has_card = True

print(age >= 18 and has_card)    # True  且
print(age < 18 or has_card)      # True  或
print(not has_card)              # False 非
```

**短路求值**：`and` 左边为假时右边不再计算，`or` 左边为真时同理。常用于安全访问：

```python
# 列表非空才取第一个元素（若右边执行而列表为空会报错）
nums = []
if nums and nums[0] > 0:
    print("正数")
```

**真值表速记**（哪些值被视为 False）：

| 假值 | 说明 |
| --- | --- |
| `False`、`None` | |
| `0`、`0.0` | 数字零 |
| `""`、`[]`、`{}`、`()`、`set()` | 空容器 |

其余一切值都为真，包括 `"False"` 这个非空字符串。

### 5. 成员运算符

```python
print("py" in "python")        # True
print(3 in [1, 2, 3])          # True
print("x" not in ["a", "b"])   # True
print("name" in {"name": "Tom"})   # True（查的是键）
```

### 6. 身份运算符

`is` 比较两个变量是否指向**同一个对象**，`==` 只比较值：

```python
a = [1, 2, 3]
b = [1, 2, 3]
print(a == b)    # True  值相等
print(a is b)    # False 不是同一个对象

c = a
print(c is a)    # True  c 和 a 指向同一列表
```

> [!TIP]
> 判断 None 必须用 `is None` 而不是 `== None`，这是 PEP 8 规范。

### 7. 位运算符（了解即可）

直接对整数的二进制位操作，底层开发、算法优化才会常用：

```python
print(5 & 3)    # 1   按位与：0b101 & 0b011 = 0b001
print(5 | 3)    # 7   按位或
print(5 ^ 3)    # 6   按位异或
print(5 << 1)   # 10  左移一位相当于 ×2
print(5 >> 1)   # 2   右移一位相当于 //2
```

**经典应用**：`x << 1` 比 `x * 2` 快；判断奇偶 `x & 1`（结果 1 为奇数）。

### 运算符优先级（简表）

从高到低：`**` → 一元负号 → `* / // %` → `+ -` → 比较运算 → `not` → `and` → `or`。**记不住就加括号**，括号永远最清晰。

## 二、字符串详解

### 字符串的本质：不可变序列

字符串是字符组成的**序列**，可以按位置访问；但它是**不可变的**——任何"修改"都是创建新字符串：

```python
s = "CyberPioneer"
s[0] = "c"     # ❌ TypeError！字符串不可修改
s = "c" + s[1:]   # ✅ 拼出新字符串
print(s)       # cyperPioneer
```

### 索引与切片（重中之重）

```python
s = "CyberPioneer"

# 索引：从 0 开始，负数从末尾开始
print(s[0])     # C
print(s[-1])    # r
print(len(s))   # 12

# 切片语法 s[起:止:步长]，含头不含尾
print(s[0:5])    # Cyber
print(s[5:])     # Pioneer（省略止 = 到结尾）
print(s[:5])     # Cyber（省略起 = 从开头）
print(s[::2])    # CyePoer（隔一个取一个）
print(s[::-1])   # renoiPreyC（经典倒序！）
```

**切片口诀**：**含头不含尾，省头从头起，省尾到尾止，负步长倒着走**。

切片越界**不会报错**（索引越界才会）：

```python
print(s[0:100])   # 整个字符串，不报错
print(s[100])     # ❌ IndexError
```

### 常用内置方法

```python
s = " hello Cyber Pioneer "

# —— 大小写类 ——
print(s.strip())            # 去两端空白："hello Cyber Pioneer"
print(s.upper())            # 全大写
print(s.lower())            # 全小写
print(s.title())            # 每个单词首字母大写
print("abc".capitalize())   # Abc 首字母大写

# —— 查找类 ——
t = "hello"
print(t.find("l"))       # 2  首次出现的索引，找不到返回 -1
print(t.count("l"))      # 2  出现次数
print(t.startswith("he"))   # True
print(t.endswith("lo"))     # True

# —— 分割与连接 ——
csv = "python,cpp,java"
langs = csv.split(",")       # ['python', 'cpp', 'java']
print("-".join(langs))       # python-cpp-java
print("a b  c".split())      # ['a', 'b', 'c']（无参分割自动处理多空格）

# —— 替换与判断 ——
print("1+1".replace("+", "-"))    # 1-1
print("abc123".isdigit())         # False（含字母）
print("12345".isdigit())          # True
print("abc".isalpha())            # True
print("Python".isupper())         # False
```

**注意**：这些方法都**不修改原字符串**，而是返回新值：

```python
t = "hello"
t.upper()          # 只是返回了新字符串，没有保存！
print(t)           # hello（原样）
t = t.upper()      # ✅ 要用变量接住
print(t)           # HELLO
```

### 三种格式化方式

```python
name, score = "小明", 95.5

# 1. f-string（Python 3.6+，现代标准，推荐）
print(f"{name} 的成绩是 {score}")
print(f"及格了吗：{score >= 60}")
print(f"保留一位小数：{score:.1f}")        # 95.5
print(f"补零对齐：{7:03d}")               # 007
print(f"百分比：{0.856:.1%}")             # 85.6%
print(f"{name=} ")                        # name='小明' 调试神器

# 2. format 方法（老代码常见）
print("{} 的成绩是 {}".format(name, score))
print("{1} 比 {0} 高".format("小明", "小红"))   # 位置参数

# 3. % 占位符（最古老，C 语言风格）
print("%s 的成绩是 %.1f" % (name, score))
```

**f-string 常用格式速查**：

| 写法 | 作用 | 示例结果 |
| --- | --- | --- |
| `{x:.2f}` | 两位小数 | 3.14 |
| `{x:>10}` | 右对齐宽 10 | `      hello` |
| `{x:<10}` | 左对齐宽 10 | `hello      ` |
| `{x:^10}` | 居中宽 10 | `  hello    ` |
| `{x:,}` | 千分位 | 1,234,567 |
| `{x:08.2f}` | 补零宽 8 两位小数 | 0003.14 |

### 转义字符与原始字符串

```python
print("第一行\n第二行")      # \n 换行
print("姓名\t年龄")          # \t 制表符
print("他说：\"你好\"")       # \" 输出双引号
print(r"C:\new\table")       # 原始字符串：\n 不转义，正则/路径必备
print("""多行
字符串
写这里""")                    # 三引号保留换行
```

### 练手小案例：统计单词

```python
text = "the quick brown fox jumps over the lazy dog the end"

words = text.split()                    # ['the','quick',...]
print(f"总词数: {len(words)}")          # 10

the_count = text.count("the")
print(f"the 出现: {the_count} 次")       # 3

# 每个单词倒序输出
for w in words:
    print(w[::-1], end=" ")
# eht kciuq nworb xof spmuj revo eht yzal god eht dne
```

## 小练习

1. 不用 `len()`，用循环统计字符串长度（提示：计数器 + `for` 遍历，下篇揭晓）
2. 实现"回文判断"：`"上海自来水来自海上"` 正读反读一致（提示：切片倒序比较）
3. 把 `"hello world python"` 每个单词首字母大写后用 `-` 连接
4. 用一行代码交换两个变量的值，再用 `is` 验证小整数缓存的存在（提示：`a=1; b=1; a is b` 结果与 `a=257; b=257; a is b` 对比）

## 本篇小结

- 七类运算符：算术/比较/赋值/逻辑/成员/身份/位；`/` 永远得 float，`//` 向下取整
- `==` 比较值，`is` 比较身份；判 None 用 `is`
- 字符串不可变；切片含头不含尾，`[::-1]` 倒序
- `split`/`join` 是文本处理双璧；字符串方法返回新值需接住
- 格式化首选 f-string

**下一篇**：条件判断与循环——让程序学会思考和重复。

---

*本系列为 Cyber先锋社原创教程。动手跑一遍所有示例，比读十遍更有用。*
