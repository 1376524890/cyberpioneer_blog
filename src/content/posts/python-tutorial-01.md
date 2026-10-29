---
title: Python 入门教程（一）：从安装到第一个程序
published: 2026-10-29
description: 零基础开启 Python 之旅：安装解释器、认识交互式环境、写出第一个程序、理解变量与基本数据类型。本篇是编程语言入门系列的第一步。
tags: [Python, 编程入门, 教程]
category: Python 教程
slug: python-tutorial-01
series: "Python 入门教程"
seriesOrder: 1
---

## 为什么从 Python 开始

在所有编程语言中，Python 几乎是公认最适合入门的语言：语法接近自然英语、不用操心内存和类型声明的细节、装好就能跑，而且它在数据分析、人工智能、自动化脚本、Web 开发领域都是主流工具。学会 Python，等于拿到了信息技术世界的一把万能钥匙。

## 安装 Python

### Windows

1. 访问 [python.org/downloads](https://www.python.org/downloads/) 下载最新版安装包（3.x 系列）
2. 运行安装程序，**务必勾选 "Add Python to PATH"**，这是新手最常见的翻车点
3. 安装完成后打开命令提示符（Win+R 输入 `cmd`），验证：

```bash
python --version
```

看到 `Python 3.x.x` 即安装成功。

### macOS

系统自带 Python，但版本可能较旧，推荐用 Homebrew 安装最新版：

```bash
brew install python
python3 --version
```

### Linux（Ubuntu/Debian）

```bash
sudo apt update && sudo apt install python3 python3-pip
python3 --version
```

> [!TIP]
> Windows 上命令是 `python`，macOS/Linux 上通常是 `python3`，本文后续统一写 `python`，请按自己的系统对应。

## 第一个程序：Hello World

打开命令行，输入 `python` 进入**交互式环境**（出现 `>>>` 提示符），然后输入：

```python
>>> print("Hello, Cyber先锋社!")
Hello, Cyber先锋社!
```

回车即出结果——这就是交互式环境的好处：**即写即测**，非常适合学习阶段做小实验。输入 `exit()` 可退出。

也可以把代码存成文件。新建 `hello.py`：

```python
print("Hello, Cyber先锋社!")
print("我的第一个 Python 程序")
```

在命令行运行：

```bash
python hello.py
```

> [!NOTE]
> `.py` 是 Python 源文件的扩展名。用 VS Code、PyCharm 等编辑器打开编写体验更好。

## 变量与数据类型

### 变量：给数据贴标签

变量就是一个"名字标签"，指向内存里的某个数据。Python 里不需要声明类型，直接赋值即可：

```python
name = "小明"        # 字符串 str
age = 18             # 整数 int
height = 1.75        # 浮点数 float
is_student = True    # 布尔值 bool
```

用 `type()` 函数可以查看任何数据的类型：

```python
>>> type(age)
<class 'int'>
```

### 常用数据类型速览

| 类型 | 名称 | 示例 | 用途 |
| --- | --- | --- | --- |
| `int` | 整数 | `42`, `-7` | 计数、索引 |
| `float` | 浮点数 | `3.14` | 小数运算 |
| `str` | 字符串 | `"hello"` | 文本处理 |
| `bool` | 布尔值 | `True`, `False` | 逻辑判断 |

### 基本运算

```python
a = 10
b = 3

print(a + b)    # 13  加
print(a - b)    # 7   减
print(a * b)    # 30  乘
print(a / b)    # 3.3333... 除（结果一定是 float）
print(a // b)   # 3   整除（舍去小数）
print(a % b)    # 1   取余数
print(a ** b)   # 1000 幂运算
```

### 字符串操作

```python
s = "Cyber Pioneer"

print(len(s))           # 13，字符串长度
print(s.upper())        # CYBER PIONEER
print(s.lower())        # cyber pioneer
print(s + " Club")      # 拼接：Cyber Pioneer Club
print(f"{s} 欢迎你")    # f-string 格式化（推荐）
```

`f-string` 是 Python 3.6+ 的格式化语法，在字符串前加 `f`，用 `{}` 嵌入变量，是现代 Python 的标准写法。

## 输入与输出

程序要与人交互，就需要输入输出：

```python
name = input("你叫什么名字？")
age = int(input("你多大了？"))   # input 返回的是字符串，转成整数

print(f"{name}，你好！明年你就 {age + 1} 岁了")
```

> [!WARNING]
> `input()` 的返回值**永远是字符串**。要做数学运算必须先转换：`int()` 转整数、`float()` 转浮点数。忘记转换是新手第二大翻车点。

## 小练习

1. 定义变量保存你的姓名、年龄、专业，用 f-string 输出一段自我介绍
2. 计算并输出 `123 ÷ 7` 的商（整除）和余数
3. 让用户输入两个数，输出它们的和、差、积、商

## 本篇小结

- Python 通过解释器直接运行，交互式环境适合边学边试
- 变量无需声明类型，赋值即创建
- 四大数据类型：`int` / `float` / `str` / `bool`
- `input()` 返回字符串，运算前记得转换类型

**下一篇**：条件判断与循环——让程序学会"思考"和"重复劳动"。

---

*本系列为 Cyber先锋社原创教程，参考业界通用知识体系编写。有问题欢迎在留言板讨论！*
