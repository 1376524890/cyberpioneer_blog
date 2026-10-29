---
title: Python 入门教程（八）：模块、包与常用标准库
published: 2026-10-29
description: 掌握模块的导入四种方式与自定义模块、包的结构与 __init__.py、pip 与虚拟环境实战，以及 os/sys/math/random/json/datetime/time/collections 六大高频标准库的用法详解。
tags: [Python, 编程入门, 教程]
category: 编程教程
slug: python-tutorial-08
series: "Python 入门教程"
seriesOrder: 8
---

## 本篇目标

Python 能长期霸榜，一半功劳属于它的**生态**：标准库自带"充电电池"（batteries included），第三方库超过 50 万个。本篇解决三个问题：怎么组织自己的代码（模块与包）、怎么用别人的代码（导入与 pip）、哪些标准库必须先掌握。

## 一、模块：一个 .py 就是一个模块

### 四种导入方式

假设有一个 `my_utils.py`：

```python
# my_utils.py
PI = 3.14159

def circle_area(r):
    return PI * r * r

def _secret():
    """下划线开头：约定为内部函数，不对外提供"""
    return "internal"
```

在其他文件中使用：

```python
# 方式1：导入整个模块（推荐，命名空间清晰）
import my_utils
print(my_utils.circle_area(2))

# 方式2：导入模块并起别名
import my_utils as mu
print(mu.circle_area(2))

# 方式3：导入特定名称（少打字，但可能命名冲突）
from my_utils import circle_area, PI
print(circle_area(2))

# 方式4：导入全部（不推荐！污染命名空间）
from my_utils import *
```

> [!WARNING]
> `from x import *` 会引入看不见的名字，还可能覆盖你的变量（如覆盖内置函数）。规范工程禁用。

### `if __name__ == "__main__"`：模块的身份检查

每个模块都有魔法属性 `__name__`：

- **直接运行**该文件时，`__name__` 等于 `"__main__"`
- 被**导入**时，`__name__` 等于模块名（如 `"my_utils"`）

```python
# my_utils.py
def circle_area(r):
    return PI * r * r

if __name__ == "__main__":
    # 这段代码只在直接运行时执行，被导入时不执行
    print("自测:", circle_area(1))
```

**这是 Python 项目的标准结构**：功能放函数里，测试/演示代码放 main 保护下——既能当库被导入，又能当脚本运行。

### `__all__` 控制 `import *` 的范围

```python
# my_utils.py
__all__ = ["circle_area", "PI"]    # 只导出这两个
```

## 二、包：目录形式的模块集合

### 结构

包 = 含 `__init__.py` 的目录（Python 3.3+ 该文件可省，但保留是好习惯）：

```text
project/
├── main.py
└── club/                     # 顶层包
    ├── __init__.py           # 让 club 成为包
    ├── utils.py              # club.utils
    └── tools/                # 子包
        ├── __init__.py
        └── net.py            # club.tools.net
```

### 导入包内模块

```python
import club.utils                      # 完整路径
club.utils.circle_area(2)

from club.tools import net             # 从子包导入
from club.tools.net import ping        # 导入具体函数

import club.tools.net as net           # 别名
```

### 绝对导入与相对导入

包内部模块互相引用时：

```python
# club/tools/net.py

from club.utils import helper      # 绝对导入（推荐：清晰）

from ..utils import helper         # 相对导入：.. 上一层包
from . import local_module         # . 当前包
```

相对导入只能用在包内，脚本顶层文件不可用。

## 三、pip 与虚拟环境

### pip：第三方包管理器

```bash
pip install requests               # 安装
pip install requests==2.31.0       # 指定版本
pip install "requests>=2.28"       # 版本范围
pip install -r requirements.txt    # 按清单批量安装
pip uninstall requests             # 卸载
pip list                           # 已装列表
pip show requests                  # 包详情
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple 包名   # 国内镜像加速
```

**requirements.txt**：项目依赖清单，交接与部署必备：

```bash
pip freeze > requirements.txt      # 导出当前环境全部依赖
pip install -r requirements.txt    # 他人一键还原
```

### 虚拟环境：项目隔离的结界

不同项目依赖不同版本的库会互相打架，虚拟环境给每个项目独立空间：

```bash
# 创建（venv 是标准库自带）
python -m venv venv                 # 在项目目录生成 venv/ 目录

# 激活
source venv/bin/activate            # macOS / Linux
venv\Scripts\activate               # Windows

# 激活后命令行前缀出现 (venv)，此后 pip 装的包只进这个环境
(venv) pip install requests

# 退出
deactivate
```

**铁律**：每个项目一个虚拟环境，`venv/` 目录加入 `.gitignore` 不进版本库。

> [!TIP]
> 现代替代品 `uv`（pip + venv 的极速合一）、`poetry` 也值得了解，但 venv + pip 是基本功，先掌握它。

## 四、六大高频标准库详解

### 1. os：操作系统交互

```python
import os

# 路径操作（最常用）
os.path.join("club", "docs", "a.md")    # club/docs/a.md（跨平台拼接）
os.path.exists("/etc/hosts")            # True 是否存在
os.path.isfile("a.py")                  # 是否文件
os.path.isdir("club")                   # 是否目录
os.path.basename("/a/b/c.txt")          # c.txt
os.path.dirname("/a/b/c.txt")           # /a/b
os.path.splitext("photo.jpg")           # ('photo', '.jpg')
os.path.getsize("a.py")                 # 字节大小

# 目录操作
os.getcwd()                             # 当前工作目录
os.listdir(".")                         # 列出目录内容
os.makedirs("a/b/c", exist_ok=True)     # 递归建目录（存在不报错）
os.remove("temp.txt")                   # 删文件
```

**跨平台路径推荐用 `pathlib`（面向对象风格）**：

```python
from pathlib import Path

p = Path("club") / "docs" / "a.md"      # 用 / 拼路径，优雅
print(p.exists(), p.suffix)             # True .md
for md in Path(".").glob("**/*.md"):    # 递归找所有 md
    print(md)
```

### 2. sys：解释器信息

```python
import sys

print(sys.version)              # Python 版本串
print(sys.platform)             # darwin / win32 / linux
print(sys.argv)                 # 命令行参数列表！
sys.exit(1)                     # 退出程序（非0=异常退出）
sys.path.append("/my/libs")     # 追加模块搜索路径
```

**命令行参数实战**：

```python
# args_demo.py
import sys

if __name__ == "__main__":
    # python args_demo.py hello 42
    print(sys.argv)             # ['args_demo.py', 'hello', '42']
    name = sys.argv[1] if len(sys.argv) > 1 else "陌生人"
    print(f"你好, {name}")
```

### 3. math 与 random

```python
import math

print(math.sqrt(16))        # 4.0 平方根
print(math.ceil(3.2))       # 4   向上取整
print(math.floor(3.8))      # 3   向下取整
print(math.pi, math.e)      # 3.141592653589793 2.718281828459045
print(math.gcd(12, 18))     # 6   最大公约数
print(math.log(math.e))     # 1.0 自然对数
print(math.radians(180))    # 3.1415... 角度转弧度
```

```python
import random

random.seed(42)                     # 固定种子：结果可复现
print(random.random())              # 0.639  [0,1) 浮点
print(random.randint(1, 6))         # 1~6 整数（含两端）——掷骰子
print(random.uniform(1.5, 3.5))     # 区间浮点

fruits = ["苹果", "香蕉", "橘子"]
print(random.choice(fruits))        # 随机选一个
print(random.sample(fruits, 2))     # 随机选2个（不重复）

nums = [1, 2, 3, 4, 5]
random.shuffle(nums)                # 原地打乱
print(nums)                         # 例如 [3, 1, 5, 2, 4]
```

### 4. json：数据交换格式（前后端/存储必备）

```python
import json

student = {"name": "小明", "age": 18, "scores": [90, 85], "vip": True}

# 序列化：Python → JSON 字符串
text = json.dumps(student, ensure_ascii=False, indent=2)
print(text)
# {
#   "name": "小明",
#   "age": 18, ...
# }

# 反序列化：JSON 字符串 → Python
data = json.loads(text)
print(data["scores"][0])          # 90

# 读写 JSON 文件
with open("data.json", "w", encoding="utf-8") as f:
    json.dump(student, f, ensure_ascii=False, indent=2)

with open("data.json", encoding="utf-8") as f:
    loaded = json.load(f)
```

**类型对应表**：

| Python | JSON |
| --- | --- |
| dict | object |
| list / tuple | array |
| str | string |
| int / float | number |
| True / False | true / false |
| None | null |

`ensure_ascii=False` 让中文正常显示，`indent=2` 美化缩进——两个参数是日常标配。

### 5. datetime：日期时间

```python
from datetime import datetime, date, timedelta

now = datetime.now()
print(now)                    # 2026-10-29 12:00:00.123456
print(now.year, now.month, now.day, now.hour)
print(now.weekday())          # 0=周一 ... 6=周日

# 格式化输出 ↔ 解析
print(now.strftime("%Y-%m-%d %H:%M:%S"))    # 2026-10-29 12:00:00
print(now.strftime("%Y年%m月%d日 %A"))       # 2026年10月29日 Thursday

t = datetime.strptime("2026-10-01 09:00", "%Y-%m-%d %H:%M")
print(t.year)                 # 2026

# 时间差 timedelta
birthday = datetime(2026, 12, 25)
delta = birthday - now
print(f"还剩 {delta.days} 天")

three_days_later = now + timedelta(days=3)
last_hour = now - timedelta(hours=1)

# 常用格式码：%Y年 %m月 %d日 %H时 %M分 %S秒 %A星期 %B月名
```

### 6. collections：加强版容器

```python
from collections import Counter, defaultdict, deque

# Counter：计数器（词频统计一步到位）
words = "the quick the lazy the dog".split()
c = Counter(words)
print(c)                    # Counter({'the': 3, 'quick': 1, ...})
print(c.most_common(2))     # [('the', 3), ('quick', 1)]

# defaultdict：带默认值的字典（告别 KeyError）
groups = defaultdict(list)
for name, cls in [("小明","A"), ("小红","B"), ("小刚","A")]:
    groups[cls].append(name)          # 键不存在自动建空列表
print(dict(groups))        # {'A': ['小明', '小刚'], 'B': ['小红']}

# deque：双端队列（头尾操作都是 O(1)，列表头部操作是 O(n)）
dq = deque([1, 2, 3])
dq.appendleft(0)           # deque([0, 1, 2, 3])
dq.append(4)               # deque([0, 1, 2, 3, 4])
dq.popleft()               # 0（当队列用：append 入队，popleft 出队）
```

## 五、组织你自己项目的建议

```text
my_project/
├── main.py              # 入口：只做调度
├── config.py            # 配置集中管理
├── requirements.txt     # 依赖清单
├── utils/               # 工具包
│   ├── __init__.py
│   ├── files.py         # 文件相关函数
│   └── net.py           # 网络相关函数
└── tests/               # 测试
    └── test_utils.py
```

三条军规：**入口薄、功能分文件、依赖写清单**。

## 小练习

1. 写模块 `math_extra.py`：提供 `is_prime`、`fib_list(n)`，带 `__main__` 自测块；在另一文件导入验证
2. 用 `pathlib` 递归统计某目录下所有 `.py` 文件的总行数
3. 用 `json` 把一个"通讯录字典"保存到文件，重启程序后能加载回来
4. 用 `Counter` 统计一段英文中出现频率最高的 5 个单词（去掉 the/a/is 等停用词）
5. （综合）写"倒计时提醒器"：输入目标日期字符串，输出距今还有几天几小时，用 `datetime` 实现

## 本篇小结

- 四种导入方式，推荐 `import x` / `import x as y`；禁用 `import *`
- `if __name__ == "__main__"` 让模块既能导入又能运行
- 包 = 目录 + `__init__.py`；一项目一虚拟环境，依赖写 requirements.txt
- 六大标准库：os(path)/sys(argv)/math/random/json/datetime/collections
- 路径处理认准 pathlib，词频统计认准 Counter，默认值字典认准 defaultdict

**下一篇**：文件操作与异常处理——让程序可靠地读写与容错。

---

*本系列为 Cyber先锋社原创教程。json 与 datetime 在 Web/爬虫/数据处理的出镜率接近 100%。*
