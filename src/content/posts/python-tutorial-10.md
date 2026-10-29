---
title: Python 入门教程（十）：面向对象编程
published: 2026-10-29
description: 从类的定义到完整面向对象：属性与方法、__init__ 与 self、封装与访问控制、继承与 super、方法重写与多态、魔法方法、property 与 dataclass，用图书馆管理系统贯穿全部知识点。
tags: [Python, 编程入门, 教程, 面向对象]
category: Python 教程
slug: python-tutorial-10
series: "Python 入门教程"
seriesOrder: 10
---

## 本篇目标

函数把"动作"打包，**类**把"数据 + 动作"一起打包。面向对象编程（OOP）是组织大型程序的主流范式——游戏里的每个角色、Web 框架里的每个请求对象、AI 库里的每个模型，都是"类的实例"。本篇从零讲透 Python OOP。

## 一、类与实例：图纸与产品

### 最小类

```python
class Student:
    """学生类——图纸"""
    school = "Cyber先锋社"        # 类属性：所有实例共享

    def __init__(self, name, age):    # 构造方法：创建实例时自动调用
        self.name = name              # 实例属性：每个实例独有
        self.age = age

    def introduce(self):              # 实例方法
        return f"我是{name}..."
```

**核心概念对照**：

| 概念 | 类比 | 归属 |
| --- | --- | --- |
| 类 class | 图纸 | 一份 |
| 实例 instance | 按图纸造的产品 | 可以很多个 |
| 类属性 | 产品系列共同配置 | 所有实例共享 |
| 实例属性 | 单个产品的编号 | 各自独立 |

### 创建与使用

```python
class Student:
    school = "Cyber先锋社"

    def __init__(self, name, age):
        self.name = name
        self.age = age

    def introduce(self):
        return f"我是{self.name}，{self.age}岁，来自{self.school}"

ming = Student("小明", 18)          # 自动调用 __init__
hong = Student("小红", 17)

print(ming.introduce())     # 我是小明，18岁，来自Cyber先锋社
print(hong.introduce())     # 我是小红，17岁，来自Cyber先锋社
print(ming.name)            # 直接访问属性
print(Student.school)       # 类属性通过类访问
```

### self 到底是什么

`self` 就是**实例自己**。`ming.introduce()` 实际是 `Student.introduce(ming)` 的语法糖——Python 把实例自动传给第一个参数：

```python
print(Student.introduce(ming))    # 与 ming.introduce() 完全等价
```

**三条铁律**：实例方法第一个参数必须是 self（名字可换但别换）；调用时不传 self；`self.xxx = 值` 创建实例属性。

### 类属性 vs 实例属性的坑

```python
class Student:
    school = "先锋社"

s1 = Student()
s2 = Student()

s1.school = "吉他社"        # 给 s1 创建了同名实例属性（遮蔽类属性）
print(s1.school)            # 吉他社（实例属性优先）
print(s2.school)            # 先锋社（s2 没有实例属性，找到类属性）

Student.school = "篮球社"   # 改类属性本身
print(s2.school)            # 篮球社
```

**查找顺序**：实例属性 → 类属性 → 父类属性。

### 实例方法 / 类方法 / 静态方法

```python
from datetime import date

class Student:
    school = "先锋社"

    def __init__(self, name, birth_year):
        self.name = name
        self.birth_year = birth_year

    def grade(self):                        # 实例方法：访问实例数据
        return date.today().year - self.birth_year

    @classmethod
    def from_birth_year(cls, name, age):    # 类方法：备选构造器（常用！）
        return cls(name, date.today().year - age)

    @staticmethod
    def is_valid_age(age):                  # 静态方法：与实例无关的工具函数
        return 6 <= age <= 100

ming = Student.from_birth_year("小明", 18)   # 类方法创建实例
print(Student.is_valid_age(ming.grade()))   # True
```

- 实例方法：第一个参数 `self`
- 类方法 `@classmethod`：第一个参数 `cls`，常用于**备选构造方式**
- 静态方法 `@staticmethod`：不带自动参数，就是放在类里的普通函数

## 二、封装：藏好内部实现

### 下划线约定

```python
class Account:
    def __init__(self, owner, balance=0):
        self.owner = owner          # 公开：随意访问
        self._bank_no = "6222..."   # 单下划线：约定为"内部"，外部别碰（语言不禁止）
        self.__password = "123456"  # 双下划线：名称改写，外部无法直接访问

    def verify(self, pwd):
        return self.__check(pwd)    # 内部方法公开调用

    def __check(self, pwd):         # 私有方法
        return pwd == self.__password

acc = Account("小明")
# print(acc.__password)    # ❌ AttributeError
# print(acc.__check("123"))  # ❌ 同理
print(acc.verify("123456"))    # True：通过公开接口使用内部实现
```

Python 的私有是"君子协定"：`__name` 被改写为 `_Account__name`（用 `acc._Account__password` 其实能访问到，但永远别这么干）。

### property：像属性一样调用的方法

```python
class Circle:
    def __init__(self, radius):
        self._radius = radius

    @property
    def radius(self):              # getter：c.radius 触发
        return self._radius

    @radius.setter
    def radius(self, value):       # setter：c.radius = x 触发（带校验）
        if value <= 0:
            raise ValueError("半径必须为正数")
        self._radius = value

    @property
    def area(self):                # 只读属性：只提供 getter
        return 3.14159 * self._radius ** 2

c = Circle(5)
print(c.area)          # 78.53975 —— 像属性，实际在计算
c.radius = 10          # 走 setter 校验
print(c.area)          # 314.159
# c.area = 100         # ❌ AttributeError 只读
```

**使用时机**：属性需要计算（面积）或赋值需要校验（半径）时，对外仍保持 `obj.attr` 的简洁语法。

## 三、继承与多态

### 继承：代码复用

```python
class Animal:
    def __init__(self, name):
        self.name = name

    def speak(self):
        return f"{self.name}在发出声音"

    def info(self):
        return f"[{type(self).__name__}] {self.name}"

class Dog(Animal):                     # Dog 继承 Animal
    def fetch(self):                   # 子类新增方法
        return f"{self.name}去捡球！"

class Cat(Animal):
    def speak(self):                   # 方法重写（override）
        return f"{self.name}：喵～"

dog = Dog("旺财")
cat = Cat("咪咪")

print(dog.info())        # [Dog] 旺财（继承来的方法）
print(dog.fetch())       # 旺财去捡球！（自己的新方法）
print(dog.speak())       # 旺财在发出声音（没重写，用父类版）
print(cat.speak())       # 咪咪：喵～（重写了自己的版本）
```

### super()：调用父类

```python
class Animal:
    def __init__(self, name, age):
        self.name = name
        self.age = age

class Dog(Animal):
    def __init__(self, name, age, breed):
        super().__init__(name, age)    # 先让父类完成初始化
        self.breed = breed             # 再补充子类特有的

d = Dog("旺财", 3, "柴犬")
print(d.name, d.age, d.breed)
```

### 多态：同一接口，不同行为

```python
def let_it_speak(animal):
    """不关心具体类型，只管调用 speak——多态的威力"""
    print(animal.speak())

animals = [Dog("旺财"), Cat("咪咪"), Animal("神秘生物")]
for a in animals:
    let_it_speak(a)
# 旺财在发出声音
# 咪咪：喵～
# 神秘生物在发出声音
```

`let_it_speak` 对"任何有 speak 方法的对象"都有效——这叫**鸭子类型**（走起来像鸭子叫起来像鸭子，那就是鸭子）。Python 不检查继承关系，只看"有没有这个方法"：

```python
class Robot:                # 没继承 Animal！
    def speak(self):
        return "嘀嘀——"

let_it_speak(Robot())       # ✓ 照样工作
```

### 继承层次检查

```python
print(isinstance(dog, Dog))       # True
print(isinstance(dog, Animal))    # True（Dog 是 Animal 的子类）
print(issubclass(Dog, Animal))    # True
print(issubclass(Cat, Dog))       # False
```

## 四、魔法方法：给类装上"系统接口"

双下划线包裹的方法在特定场景被 Python 自动调用：

```python
class Book:
    def __init__(self, title, price):
        self.title = title
        self.price = price

    def __str__(self):                    # print / str() 时调用
        return f"《{self.title}》¥{self.price}"

    def __repr__(self):                   # 调试/容器内显示时调用
        return f"Book({self.title!r}, {self.price})"

    def __eq__(self, other):              # == 比较
        return isinstance(other, Book) and self.title == other.title

    def __lt__(self, other):              # < 比较（配合 sort）
        return self.price < other.price

    def __len__(self):                    # len() 行为
        return len(self.title)

    def __add__(self, other):             # + 行为
        return self.price + other.price

b1 = Book("Python入门", 59)
b2 = Book("Python入门", 79)

print(b1)                    # 《Python入门》¥59
print(b1 == b2)              # True（同名即相等）
books = [Book("A书", 49), Book("B书", 29)]
books.sort()                 # 按 __lt__ 排序
print(len(b1))               # 9（标题字符数）
print(b1 + b2)               # 138（价格相加）
```

**常用魔法方法速查**：

| 方法 | 触发时机 |
| --- | --- |
| `__init__` | 创建实例 |
| `__str__` / `__repr__` | print / 调试显示 |
| `__eq__` / `__lt__` | `==` / `<`（排序） |
| `__len__` | `len(obj)` |
| `__add__` | `obj + x` |
| `__iter__` / `__next__` | for 遍历（第七篇） |
| `__enter__` / `__exit__` | with 语句 |
| `__getitem__` | `obj[key]` |

## 五、dataclass：数据类的省事写法（3.7+）

纯存数据的类（学生、订单、配置）可用 `@dataclass` 自动生成 `__init__`、`__repr__`、`__eq__`：

```python
from dataclasses import dataclass, field

@dataclass
class Student:
    name: str
    age: int
    scores: list = field(default_factory=list)   # 可变默认值的安全写法

    def average(self):
        return sum(self.scores) / len(self.scores) if self.scores else 0

s = Student("小明", 18, [90, 85])
print(s)                 # Student(name='小明', age=18, scores=[90, 85])
print(s.average())       # 87.5
```

相比手写，省掉 80% 样板代码，现代 Python 写数据类的首选。

## 六、综合实战：图书馆管理系统

把本篇全部知识串起来：

```python
from dataclasses import dataclass, field
from datetime import date, timedelta

class LibraryError(Exception):
    """图书馆业务异常"""
    pass

@dataclass
class Book:
    isbn: str
    title: str
    copies: int = 1
    borrowers: list = field(default_factory=list)

    @property
    def available(self) -> int:
        return self.copies - len(self.borrowers)

class Member:
    def __init__(self, mid: int, name: str):
        self.mid = mid
        self.name = name
        self.borrowed: dict[str, date] = {}     # isbn -> 应还日期

    def __str__(self):
        return f"会员{self.mid}-{self.name}（在借{len(self.borrowed)}本）"

class Library:
    LOAN_DAYS = 30
    MAX_BOOKS = 3

    def __init__(self):
        self._books: dict[str, Book] = {}
        self._members: dict[int, Member] = {}

    def add_book(self, isbn, title, copies=1):
        if isbn in self._books:
            self._books[isbn].copies += copies
        else:
            self._books[isbn] = Book(isbn, title, copies)

    def register(self, name) -> Member:
        mid = max(self._members, default=0) + 1
        m = Member(mid, name)
        self._members[mid] = m
        return m

    def borrow(self, member: Member, isbn: str):
        """借书：封装所有业务规则校验"""
        book = self._books.get(isbn)
        if book is None:
            raise LibraryError(f"无此书: {isbn}")
        if book.available <= 0:
            raise LibraryError(f"《{book.title}》已全部借出")
        if len(member.borrowed) >= self.MAX_BOOKS:
            raise LibraryError(f"{member.name} 已达借阅上限{self.MAX_BOOKS}本")

        book.borrowers.append(member.name)
        member.borrowed[isbn] = date.today() + timedelta(days=self.LOAN_DAYS)

    def return_book(self, member: Member, isbn: str):
        if isbn not in member.borrowed:
            raise LibraryError(f"{member.name} 没借这本书")
        self._books[isbn].borrowers.remove(member.name)
        del member.borrowed[isbn]

    def __len__(self):                          # len(图书馆) = 藏书种数
        return len(self._books)

    def __contains__(self, isbn):               # isbn in 图书馆
        return isbn in self._books

# —— 使用 ——
lib = Library()
lib.add_book("978-7-111-40701-0", "Python编程：从入门到实践", copies=2)
lib.add_book("978-7-115-53608-2", "算法（第4版）")

ming = lib.register("小明")
lib.borrow(ming, "978-7-111-40701-0")
print(ming)                                   # 会员1-小明（在借1本）
print(f"馆藏 {len(lib)} 种；'978-7-115-53608-2' 在馆: {'978-7-115-53608-2' in lib}")

lib.return_book(ming, "978-7-111-40701-0")
print(ming)                                   # 会员1-小明（在借0本）
```

**这个案例用到的知识点**：dataclass、property、封装（`_books` 内部字典）、自定义异常、魔法方法 `__len__`/`__contains__`、类型注解。建议自己敲一遍再扩展（比如加逾期罚款计算）。

## 七、什么时候用 OOP

| 场景 | 建议 |
| --- | --- |
| 一次脚本、简单流程 | 函数式足够，别硬上类 |
| 多个实体有各自状态（游戏角色、订单） | 类 |
| 框架开发 / 库开发 | 类（用户需要可组合的抽象） |
| 数据 + 行为强绑定 | 类 |
| 纯数据传递 | dataclass |

Python 支持多范式：**工具函数直接写函数，业务实体才建类**，不要为了 OOP 而 OOP。

## 小练习

1. 定义 `Rectangle` 类：宽高属性、`area`/`perimeter` 方法、`__eq__`（面积相等即相等）
2. 写 `BankAccount`：`__init__(owner, balance)`、`deposit`、`withdraw`（余额不足抛自定义 `InsufficientFundsError`）、`__str__`
3. 定义 `Shape` 基类 + `Circle`/`Square` 子类，各实现 `area()`，写函数打印一组图形的面积与总和（多态）
4. 给 `Book` 加 `__iter__`，使其能 `for chapter in book` 遍历章节名列表
5. （综合）扩展图书馆：会员分级（学生可借 3 本 30 天 / 教师可借 10 本 60 天），用继承实现

## 本篇小结

- 类是图纸、实例是产品；`__init__` 构造、`self` 是实例自己
- 类属性共享、实例属性独立；查找顺序实例 → 类 → 父类
- 封装靠 `_` 约定；property 让方法像属性（可校验可只读）
- 继承复用、`super().__init__` 先父后子；重写实现多态；鸭子类型只看方法不看血统
- 魔法方法接入 Python 语法（print/==/len/+）；数据类用 `@dataclass`
- OOP 时机：多实体 + 各自状态；脚本工具用函数就好

**下一篇**：综合项目实战——从需求到成品的完整开发流程。

---

*本系列为 Cyber先锋社原创教程。图书馆案例值得反复把玩——把它扩展成你的期末作品也毫不逊色。*
