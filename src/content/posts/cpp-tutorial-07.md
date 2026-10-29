---
title: C++ 入门教程（七）：结构体与枚举
published: 2026-10-29
description: 掌握 struct 定义与使用、成员访问与嵌套、结构体数组与 vector、结构体作函数参数、enum 与 enum class 的区别、联合体简介，用学生管理与坐标系统案例练手。
tags: [C++, 编程入门, 教程]
category: C++ 教程
slug: cpp-tutorial-07
series: "C++ 入门教程"
seriesOrder: 7
---

## 本篇目标

int/double/string 只能描述"单点信息"，现实实体往往是"一组信息"：学生有姓名+年龄+成绩，坐标有 x+y。**结构体（struct）** 让你自定义"打包类型"；**枚举（enum）** 让你定义"取值受限"的类型。它们是迈向面向对象（第九篇）前的最后一级台阶。

## 一、结构体基础

### 定义与使用

```cpp
#include <iostream>
#include <string>

// 定义新类型（习惯放 main 前或头文件）
struct Student {
    std::string name;     // 成员变量
    int age;
    double score;
};                        // ⚠ 别忘了分号！

int main() {
    // 创建与初始化（三种方式）
    Student s1 = {"小明", 18, 90.5};          // 顺序初始化
    Student s2{.name="小红", .age=17};        // 指示符初始化（C++20）
    Student s3;                               // 未初始化（成员值随机！）

    // 成员访问：点运算符
    s3.name = "小刚";
    s3.age = 19;
    s3.score = 88;

    std::cout << s1.name << " " << s1.score << "\n";
    std::cout << s2.name << " " << s2.score << "\n";   // 0（缺省补零）
    return 0;
}
```

### 指针访问成员：->

```cpp
Student s = {"小明", 18, 90.5};
Student* p = &s;

std::cout << (*p).name << "\n";    // 括号版（* 优先级低于 .）
std::cout << p->name << "\n";      // 箭头版（完全等价，推荐）
p->score = 95;                     // 通过指针修改成员
```

**规则**：对象/引用用 `.`，指针用 `->`。

### 结构体嵌套

```cpp
struct Date {
    int year, month, day;
};

struct Event {
    std::string title;
    Date date;              // 结构体作成员
    struct Place {          // 内嵌定义
        std::string building;
        int room;
    } place;
};

Event e;
e.title = "C++ 分享会";
e.date = {2026, 10, 29};
e.place.building = "信息楼";
e.place.room = 301;

std::cout << e.title << " @ " << e.place.building
          << e.place.room << "室\n";
```

## 二、结构体与容器/函数

### 结构体数组与 vector

```cpp
#include <vector>
#include <algorithm>

std::vector<Student> students = {
    {"小明", 18, 90}, {"小红", 17, 85}, {"小刚", 19, 92},
};

// 遍历
for (const auto& s : students)
    std::cout << s.name << " " << s.score << "\n";

// 按分数降序（结构化绑定 + lambda）
std::sort(students.begin(), students.end(),
          [](const Student& a, const Student& b) { return a.score > b.score; });

// 找最高分
auto best = *std::max_element(students.begin(), students.end(),
          [](const Student& a, const Student& b) { return a.score < b.score; });
std::cout << "第一名: " << best.name << "\n";
```

### 作函数参数：const 引用优先

```cpp
// 大结构体只读：const& 零拷贝
void print_student(const Student& s) {
    std::cout << s.name << "," << s.age << "岁," << s.score << "分\n";
}

// 要修改：引用
void birthday(Student& s) {
    ++s.age;
}

// 值传递会整体拷贝（string/vector 都复制一遍）——大结构体别这么传
```

### 运算符重载初见（让结构体支持比较/输出）

```cpp
struct Point {
    double x, y;

    // 成员函数（第九篇正式讲）
    double dist() const { return std::sqrt(x*x + y*y); }
};
```

完整的运算符重载（`operator<`、`operator==`）在第十篇面向对象展开。

## 三、枚举

### 传统 enum（无作用域，有坑）

```cpp
enum Color { RED, GREEN, BLUE };        // 默认值 0,1,2

Color c = GREEN;
std::cout << c << "\n";                 // 1（本质是 int）

if (c == GREEN) std::cout << "绿色\n";

enum Level { LOW, MID = 5, HIGH };      // 可指定值：0,5,6
```

坑：枚举名**裸露在全局**，两个 enum 有同名成员就冲突：

```cpp
enum TrafficLight { RED, YELLOW, GREEN };   // ❌ RED/GREEN 与 Color 重复定义！
```

### enum class（C++11，强类型枚举——现代首选）

```cpp
enum class Status { Idle, Running, Error };
enum class Color2 { Red, Green };          // 同名不冲突：有作用域

Status s = Status::Running;                 // 必须带作用域 Status::

if (s == Status::Running)
    std::cout << "运行中\n";

// int n = s;               // ❌ 不隐式转 int（类型安全）
int n = static_cast<int>(s); // 显式转换 ✓

// 指定底层类型
enum class Priority : char { Low = 'L', Mid = 'M', High = 'H' };
```

**enum class 三大优点**：作用域隔离（不污染全局）、不隐式转 int（防误比较）、可指定底层类型。**新代码一律 enum class**。

### 枚举 + switch：状态机标配

```cpp
enum class OrderState { Created, Paid, Shipped, Done, Cancelled };

void handle(OrderState state) {
    switch (state) {
        case OrderState::Created:  std::cout << "待支付\n"; break;
        case OrderState::Paid:     std::cout << "已支付，备货中\n"; break;
        case OrderState::Shipped:  std::cout << "运输中\n"; break;
        case OrderState::Done:     std::cout << "已完成\n"; break;
        case OrderState::Cancelled:std::cout << "已取消\n"; break;
        // ⚠ 开了 -Wall 编译选项时，漏分支会警告——enum+switch 的安全网
    }
}
```

## 四、联合体与位域（了解）

```cpp
// union：所有成员共享同一块内存（省空间，底层开发用）
union Packet {
    uint32_t raw;                 // 4 字节
    struct { uint8_t b0,b1,b2,b3; } bytes;   // 也是 4 字节，与 raw 重叠
};

Packet p;
p.raw = 0x11223344;
std::cout << std::hex << (int)p.bytes.b0 << "\n";   // 44（小端序）
```

应用场景：硬件寄存器、网络协议解析。日常业务开发用得少，知道即可。

## 五、综合案例：图书管理（结构体版）

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <iomanip>

enum class BookState { Available, Borrowed, Lost };

struct Book {
    std::string isbn;
    std::string title;
    BookState state;

    std::string state_str() const {           // const 成员函数
        switch (state) {
            case BookState::Available: return "在架";
            case BookState::Borrowed:  return "借出";
            case BookState::Lost:      return "遗失";
        }
        return "?";
    }
};

struct Library {
    std::vector<Book> books;

    void add(const std::string& isbn, const std::string& title) {
        books.push_back({isbn, title, BookState::Available});
    }

    bool borrow(const std::string& isbn) {
        for (auto& b : books)
            if (b.isbn == isbn && b.state == BookState::Available) {
                b.state = BookState::Borrowed;
                return true;
            }
        return false;
    }

    void report() const {
        int avail = 0;
        for (const auto& b : books)
            if (b.state == BookState::Available) ++avail;
        std::cout << "共 " << books.size() << " 本，在架 " << avail << " 本\n";

        for (const auto& b : books)
            std::cout << std::left << std::setw(14) << b.isbn
                      << std::setw(16) << b.title
                      << b.state_str() << "\n";
    }
};

int main() {
    Library lib;
    lib.add("978-7-111", "C++ Primer");
    lib.add("978-7-115", "算法导论");
    lib.add("978-7-121", "深入理解计算机系统");

    lib.borrow("978-7-111");
    lib.borrow("不存在的ISBN");
    lib.report();
}
```

这个案例在第十篇会用 class + 封装重写，对比着看能体会 struct→class 的演进。

## 小练习

1. 定义 `Rectangle{width, height}` + 函数 `double area(const Rectangle&)`，输入尺寸输出面积周长
2. 定义 `Student{name, scores: vector<double>}`，写函数计算每人平均分并输出最高的姓名
3. 用 enum class 表示"星期"写函数：输入 1-7 返回中文星期名（switch）
4. 结构体数组按多级排序：先按年龄升序，同龄按分数降序（lambda 组合比较）
5. 定义 `Vec2{x,y}` 并写 `add/sub/dot` 三个函数（const 引用传参），实现向量加减与点积

## 本篇小结

- struct 把相关数据打包成自定义类型；定义后别忘分号
- 对象用 `.`、指针用 `->` 访问成员；结构体可嵌套
- 结构体传参：只读 `const&`、要改 `&`；配 vector/sort 食用最佳
- 枚举新代码用 enum class：作用域安全、不隐式转 int
- union 了解即可；struct 是 class 的"公开版"，面向对象见第九篇

**下一篇**：面向对象（上）——类、构造析构、封装。

---

*本系列为 Cyber先锋社原创教程。图书管理案例先自己扩展"还书"功能，第十篇再见证它的进化。*
