---
title: Python 入门教程（九）：文件操作与异常处理
published: 2026-10-29
description: 完整讲解文件读写模式与 with 上下文管理、编码问题排查、逐行处理与追加写入，异常处理全语法（try/except/else/finally/raise）、自定义异常与工程化容错策略，附日志记录实战。
tags: [Python, 编程入门, 教程]
category: Python 教程
slug: python-tutorial-09
series: "Python 入门教程"
seriesOrder: 9
---

## 本篇目标

程序的价值在于**持久化**（数据存下来）和**健壮性**（出错不崩）。本篇把文件操作与异常处理一次讲透——这两个主题天然是一对：凡是碰文件、网络、用户输入的代码，都必须考虑"出错怎么办"。

## 一、文件操作

### 打开模式与编码

```python
f = open("demo.txt", "r", encoding="utf-8")
```

**常用模式**：

| 模式 | 含义 | 文件不存在 | 文件存在 |
| --- | --- | --- | --- |
| `"r"` | 只读（默认） | ❌ 报错 | 从头读 |
| `"w"` | 只写 | ✅ 创建 | **清空重写！** |
| `"a"` | 追加 | ✅ 创建 | 末尾追加 |
| `"x"` | 独占创建 | ❌ 报错 | ❌ 报错（防覆盖） |
| `"r+"` | 读+写 | ❌ 报错 | 读写均可 |
| `"b"` | 二进制（rb/wb/ab） | 组合使用 | 处理图片/音频等 |

**编码**：永远显式写 `encoding="utf-8"`。不写的话 Windows 默认 GBK，同一份代码换个系统就读炸——中文乱码/UnicodeDecodeError 十有八九源自这里。

### with 语句：自动关闭（标准姿势）

```python
# ❌ 手动式：忘了 close，或中途异常导致文件句柄泄漏
f = open("demo.txt", encoding="utf-8")
content = f.read()
f.close()

# ✅ with 式：代码块结束自动关闭，异常也会关闭
with open("demo.txt", encoding="utf-8") as f:
    content = f.read()
print(content)
```

### 读的四种方式

```python
# 1. read()：一次读完整个文件（小文件适用）
with open("demo.txt", encoding="utf-8") as f:
    text = f.read()

# 2. read(n)：读 n 个字符
with open("demo.txt", encoding="utf-8") as f:
    head = f.read(10)          # 前 10 个字符

# 3. readline()：每次读一行
with open("demo.txt", encoding="utf-8") as f:
    first = f.readline()       # 第一行（含 \n）

# 4. readlines()：读出所有行组成列表
with open("demo.txt", encoding="utf-8") as f:
    lines = f.readlines()      # ['第一行\n', '第二行\n', ...]

# ⭐ 最佳实践：直接迭代文件对象（逐行懒加载，大文件友好）
with open("demo.txt", encoding="utf-8") as f:
    for line in f:
        process(line.strip())   # strip 去掉行尾换行符
```

### 写文件

```python
# w 模式：覆盖写
with open("out.txt", "w", encoding="utf-8") as f:
    f.write("第一行\n")
    f.write("第二行\n")
    f.writelines(["三\n", "四\n"])    # 写入字符串列表（不自动加换行！）

# a 模式：追加写（记日志、断点续写）
with open("log.txt", "a", encoding="utf-8") as f:
    f.write(f"新的一条记录\n")
```

> [!WARNING]
> `write` 不自动换行，要自己加 `\n`；`"w"` 模式打开的一瞬间文件就被清空——哪怕你一行都没写。

### 文件指针

```python
with open("demo.txt", encoding="utf-8") as f:
    print(f.read())        # 读完，指针在末尾
    print(f.read())        # ''（空！指针已在末尾）
    f.seek(0)              # 指针拨回开头
    print(f.read())        # 又能读了
    print(f.tell())        # 当前指针位置
```

### 案例：班级成绩管理（CSV 风格）

```python
import csv
from pathlib import Path

def save_students(students, path="students.csv"):
    """保存：[(姓名, 成绩), ...]"""
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["姓名", "成绩"])         # 表头
        writer.writerows(students)

def load_students(path="students.csv"):
    """读取，返回列表"""
    if not Path(path).exists():
        return []
    with open(path, encoding="utf-8") as f:
        reader = csv.reader(f)
        next(reader, None)                        # 跳过表头
        return [(row[0], int(row[1])) for row in reader if row]

save_students([("小明", 90), ("小红", 85)])
print(load_students())
# [('小明', 90), ('小红', 85)]
```

`csv` 模块自动处理逗号转义与引号，比手动 split 可靠得多；`newline=""` 是 csv 写入的标准搭配。

## 二、异常处理

### 没有异常处理的 world

```python
nums = [1, 2, 3]
print(nums[10])          # IndexError，程序当场去世
print("这行永远执行不到")
```

### try / except 基本结构

```python
try:
    risky_code()
except SomeError:
    handle_it()
```

```python
try:
    n = int(input("输入一个数："))     # 输入 "abc" 会抛 ValueError
    print(100 / n)                     # n=0 会抛 ZeroDivisionError
except ValueError:
    print("这不是有效的数字")
except ZeroDivisionError:
    print("除数不能为 0")
```

### 捕获异常信息

```python
try:
    n = int("abc")
except ValueError as e:
    print(f"错误详情：{e}")       # invalid literal for int() with base 10: 'abc'
```

### 多异常与兜底

```python
try:
    data = load_config()
except (FileNotFoundError, PermissionError):
    print("配置文件读不了，用默认配置")
    data = {"debug": False}
except Exception as e:            # 兜底：捕获所有常规异常
    print(f"未知错误: {e}")
    raise                         # 打印后继续抛出（记日志场景常用）
```

**工程军规**：

1. **精确捕获**优先——裸 `except:` 会连 Ctrl+C 的 KeyboardInterrupt 都吞掉，绝对禁止
2. `except Exception` 只在最外层兜底用
3. 捕获了就要**处理**（降级/默认值/日志），静默 pass 是埋雷

### else 与 finally

```python
def read_score(path):
    try:
        f = open(path, encoding="utf-8")
    except FileNotFoundError:
        print("文件不存在")
        return None
    else:
        # try 没出错才执行（把"成功逻辑"和"危险代码"分离）
        score = int(f.read())
        f.close()
        return score
    finally:
        print("无论如何都执行（常用于清理资源）")
```

- `else`：try 块**没有发生异常**时执行
- `finally`：**无论如何**都执行（成功/失败/return/break），释放资源的最后一道防线

### raise：主动抛出

```python
def set_age(age):
    if not isinstance(age, int):
        raise TypeError("age 必须是整数")
    if not 0 <= age <= 150:
        raise ValueError(f"age 越界: {age}")   # 参数校验的标准做法
    return age

set_age("十八")     # TypeError: age 必须是整数
```

### 异常链与自定义异常

```python
# 自定义异常：继承 Exception（命名以 Error 结尾）
class ConfigError(Exception):
    """配置相关错误"""
    def __init__(self, key, msg=""):
        super().__init__(f"配置项 [{key}] 出错: {msg}")

def load_config(key):
    data = {"host": "localhost"}
    if key not in data:
        raise ConfigError(key, "缺少必填配置")   # 抛出自定义异常

try:
    load_config("port")
except ConfigError as e:
    print(e)        # 配置项 [port] 出错: 缺少必填配置
```

自定义异常的价值：调用方可以精确 catch 你的业务错误，而不是笼统的 Exception。

### 常见异常速查表

| 异常 | 触发场景 |
| --- | --- |
| `ValueError` | 值不合法：`int("abc")` |
| `TypeError` | 类型错误：`"a" + 1` |
| `IndexError` | 下标越界：`[1,2][5]` |
| `KeyError` | 字典键不存在：`d["x"]` |
| `FileNotFoundError` | 打开不存在的文件 |
| `ZeroDivisionError` | 除以零 |
| `AttributeError` | 属性/方法不存在：`"a".push()` |
| `NameError` | 变量未定义 |
| `ImportError` | 导入失败（库没装） |
| `RecursionError` | 递归过深 |

## 三、实战：带日志的健壮读取器

综合本篇知识点（with + 精确捕获 + 自定义异常 + logging）：

```python
import logging

logging.basicConfig(
    filename="app.log", level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)

class DataFormatError(Exception):
    pass

def load_numbers(path):
    """读取每行一个数字的文件，返回 int 列表；格式问题跳行并记日志"""
    numbers = []
    with open(path, encoding="utf-8") as f:
        for lineno, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue
            try:
                numbers.append(int(line))
            except ValueError as e:
                logging.warning("第%d行格式错误，已跳过: %r (%s)",
                                lineno, line, e)
    return numbers

# 运行：合法行全收录，坏行进日志，程序不崩
print(load_numbers("numbers.txt"))
```

这就是生产代码的样子：**预期内的错降级处理，预期外的错明确抛出，全程留痕**。

## 四、EAFP：Python 的容错哲学

Python 社区推崇 **EAFP**（Easier to Ask Forgiveness than Permission，先斩后奏）：

```python
# LBYL：先问许可（先检查再操作——有竞态风险，且啰嗦）
if "port" in config:
    port = config["port"]
else:
    port = 8080

# EAFP：直接干，出错再说（Pythonic）
try:
    port = config["port"]
except KeyError:
    port = 8080

# 当然这个场景还有最简写法（第五篇）：
port = config.get("port", 8080)
```

## 小练习

1. 写函数 `safe_divide(a, b)`：除零时返回 None 并打印友好提示
2. 写"通讯录存取器"：`save(contacts, path)` 存 json、`load(path)` 读 json；文件不存在返回空字典；json 损坏时给出明确错误并返回空字典
3. 用 `try/except` 改写第三篇猜数字游戏：输入非数字不崩溃，提示重输
4. 递归扫描目录，统计所有 `.log` 文件总大小，单文件读取失败时记 warning 继续（OSError）
5. （选做）给 `load_numbers` 加功能：支持"数字,标签"格式（如 `90,数学`），标签非法时跳行

## 本篇小结

- with 自动关文件；读写前想清楚 r/w/a 模式；永远显式 `encoding="utf-8"`
- 大文件逐行迭代 `for line in f`，不 read() 全量
- try/except 精确捕获；else 无错执行；finally 必执行；raise 主动抛
- 禁裸 except；吞异常必须处理；业务错误用自定义异常类
- EAFP：先干再说，是 Python 的方式

**下一篇**：面向对象编程——用类搭建大型程序的组织形态。

---

*本系列为 Cyber先锋社原创教程。把"带日志读取器"读懂改会，你的代码就从"能跑"升级到"可靠"。*
