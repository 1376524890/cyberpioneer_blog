---
title: C++ 入门教程（八）：面向对象（上）——类与封装
published: 2026-10-29
description: 深入 C++ 类：class 与 struct 的区别、访问控制 public/private/protected、构造函数与初始化列表、析构函数、拷贝构造与拷贝赋值、深浅拷贝问题、static 成员与 this 指针。
tags: [C++, 编程入门, 教程, 面向对象]
category: C++ 教程
slug: cpp-tutorial-08
series: "C++ 入门教程"
seriesOrder: 8
---

## 本篇目标

C++ 是"多范式语言"，但**面向对象（OOP）** 是它组织大型工程的主力方式。本篇讲 OOP 三大特性中的**封装**：把数据与操作绑定、对外隐藏细节。构造/析构/拷贝这"三巨头"是 C++ 面试与实战的高频考点。

## 一、从 struct 到 class

```cpp
class BankAccount {
private:                 // 私有：只有类自己的成员函数能访问
    std::string owner;
    double balance;

public:                  // 公开：外部的接口
    // 构造函数
    BankAccount(const std::string& name, double init_balance = 0)
        : owner(name), balance(init_balance) {    // 初始化列表
    }

    // 成员函数（方法）
    void deposit(double amount) {
        if (amount <= 0) return;
        balance += amount;
    }

    bool withdraw(double amount) {
        if (amount > balance) return false;
        balance -= amount;
        return true;
    }

    double get_balance() const { return balance; }   // const：承诺不修改成员
};

int main() {
    BankAccount acc("小明", 100);
    acc.deposit(50);
    acc.withdraw(30);
    std::cout << acc.get_balance() << "\n";    // 120

    // acc.balance = -999;      // ❌ private，外部禁止直接改——封装的意义！
}
```

**class 与 struct 的唯一区别**：默认访问权限——class 默认 private，struct 默认 public。习惯：纯数据用 struct，带行为用 class。

**封装的价值**：`balance` 不能被外部直接改成负数——所有修改必须经过 `deposit/withdraw` 的校验，不变量（余额非负）由类自己守护。

## 二、访问控制三档

| 关键字 | 谁能访问 |
| --- | --- |
| `private` | 本类的成员函数（默认） |
| `protected` | 本类 + 子类（第九篇） |
| `public` | 任何人 |

## 三、构造函数详解

### 重载与默认构造

```cpp
class Date {
    int y, m, d;
public:
    Date() : y(2026), m(1), d(1) {}                 // 默认构造
    Date(int y, int m, int d) : y(y), m(m), d(d) {} // 三参构造
    explicit Date(int days) {                        // 单参构造加 explicit（见下）
        y = days / 365 + 1970; m = 1; d = 1;
    }
};

Date a;              // 默认构造（注意：不带括号！）
Date b{2026, 10, 29};
Date c = Date(2026, 10, 29);
// Date d();         // ⚠ 经典陷阱：这是函数声明，不是构造对象！
```

### explicit：防止单参构造的隐式转换

```cpp
void print(const Date& d);

// 若 Date(int) 不加 explicit：
// print(12345);    // 会被悄悄转换成 Date——意外行为！
// 加了 explicit 后必须显式：print(Date(12345));
```

**军规：单参构造一律加 explicit**。

### 委托构造与 default（C++11）

```cpp
class Widget {
public:
    Widget() : Widget(0, 0) {}          // 委托给另一个构造
    Widget(int x, int y) : x_(x), y_(y) {}
    Widget(const Widget&) = default;    // 让编译器生成默认版本
private:
    int x_, y_;
};
```

## 四、析构函数

对象销毁时自动调用，名字是 `~类名`，负责清理资源：

```cpp
#include <iostream>

class FileLogger {
    FILE* fp;
public:
    FileLogger(const char* path) {
        fp = fopen(path, "a");
        std::cout << "[打开日志]\n";
    }

    void log(const char* msg) {
        if (fp) fprintf(fp, "%s\n", msg);
    }

    ~FileLogger() {                     // 析构：对象生命周期结束时自动调用
        if (fp) fclose(fp);
        std::cout << "[关闭日志]\n";
    }
};

void demo() {
    FileLogger logger("app.log");       // 栈对象：demo 结束自动析构
    logger.log("hello");
}                                       // 打印 [关闭日志]——这就是 RAII！

int main() { demo(); std::cout << "demo 之后\n"; }
// 输出顺序：[打开日志] [关闭日志] demo 之后
```

**RAII（资源获取即初始化）**：资源在构造函数获取、析构函数释放——智能指针、锁、文件句柄都靠它。**C++ 程序员最重要的习惯：把资源包进对象，交给析构函数管理**。

## 五、拷贝：三巨头之二

### 拷贝构造与拷贝赋值

```cpp
class Buffer {
    int* data;
    size_t size;
public:
    Buffer(size_t n) : data(new int[n]{}), size(n) {}

    // 拷贝构造：用旧对象构造新对象
    Buffer(const Buffer& other)
        : data(new int[other.size]), size(other.size) {
        std::copy(other.data, other.data + size, data);   // 深拷贝！
        std::cout << "拷贝构造\n";
    }

    // 拷贝赋值：旧对象 = 旧对象
    Buffer& operator=(const Buffer& other) {
        if (this != &other) {          // 防自赋值 a = a
            delete[] data;             // 先释放旧资源
            size = other.size;
            data = new int[size];
            std::copy(other.data, other.data + size, data);
        }
        return *this;                  // 返回自身支持链式 a=b=c
    }

    ~Buffer() { delete[] data; }       // 三巨头之三
};

Buffer a(10);
Buffer b = a;        // 拷贝构造（定义时初始化）
Buffer c(5);
c = a;               // 拷贝赋值（已存在对象赋值）
```

### 浅拷贝的灾难（编译器默认拷贝的坑）

若不写拷贝构造，编译器生成**逐成员浅拷贝**——指针成员只拷贝地址：

```cpp
// 假设 Buffer 没写拷贝构造：
Buffer b = a;        // b.data 与 a.data 指向同一块内存！
// 析构时：a、b 各 delete 同一块内存 → 💥 双重释放，程序崩溃
```

**规则**：类持有裸资源（指针/文件句柄）就必须遵循**三法则**：自定义析构、拷贝构造、拷贝赋值（或全部 = delete 禁止拷贝）。

### 移动语义预告（C++11）

深拷贝大 Buffer 很浪费，C++11 引入移动：`Buffer d = std::move(a);` 直接"偷"走 a 的资源不复制。进阶内容，此处知道有这回事即可。

## 六、static 成员与 this

### static：属于类而非对象

```cpp
class Counter {
public:
    Counter() { ++count_; }
    static int get_count() { return count_; }    // 静态成员函数：无 this
private:
    static int count_;           // 静态成员变量：所有对象共享一份
};
int Counter::count_ = 0;         // ⚠ 类外定义（C++17 可 inline static int count_ = 0;）

Counter a, b, c;
std::cout << Counter::get_count();   // 3（用类名调用，不需要对象）
```

### this 指针

每个成员函数都隐含 `this`（指向当前对象的指针）：

```cpp
class Chain {
    int value;
public:
    Chain& add(int x) {       // 返回 *this 实现链式调用
        value += x;
        return *this;
    }
};

Chain c;
c.add(1).add(2).add(3);       // 链式：value = 6
```

## 七、常量成员与 mutable

```cpp
class Temp {
    mutable int access_count = 0;    // mutable：const 函数里也可改
    double celsius_ = 25.0;
public:
    double fahrenheit() const {      // const 成员函数：保证不改成员
        ++access_count;              // ✓ mutable 例外
        return celsius_ * 9 / 5 + 32;
    }
};

const Temp t;        // const 对象只能调用 const 成员函数
t.fahrenheit();      // ✓
```

**规则**：不修改成员的函数一律标 `const`——否则 const 对象/引用调不了它，STL 里会到处报错。

## 八、实战：矩阵类

```cpp
#include <vector>
#include <stdexcept>
#include <iomanip>
#include <iostream>

class Matrix {
public:
    Matrix(size_t rows, size_t cols, double init = 0)
        : rows_(rows), cols_(cols), data_(rows * cols, init) {}

    double& at(size_t r, size_t c) {            // 可写访问（带越界检查）
        check(r, c);
        return data_[r * cols_ + c];
    }
    double at(size_t r, size_t c) const {       // 只读访问（重载）
        check(r, c);
        return data_[r * cols_ + c];
    }

    size_t rows() const { return rows_; }
    size_t cols() const { return cols_; }

    Matrix operator*(const Matrix& rhs) const { // 运算符重载：矩阵乘法
        if (cols_ != rhs.rows_)
            throw std::invalid_argument("尺寸不匹配");
        Matrix result(rows_, rhs.cols_);
        for (size_t i = 0; i < rows_; ++i)
            for (size_t k = 0; k < cols_; ++k)
                for (size_t j = 0; j < rhs.cols_; ++j)
                    result.at(i, j) += at(i, k) * rhs.at(k, j);
        return result;
    }

    void print() const {
        for (size_t i = 0; i < rows_; ++i) {
            for (size_t j = 0; j < cols_; ++j)
                std::cout << std::setw(8) << at(i, j);
            std::cout << "\n";
        }
    }

private:
    void check(size_t r, size_t c) const {
        if (r >= rows_ || c >= cols_)
            throw std::out_of_range("矩阵下标越界");
    }
    size_t rows_, cols_;
    std::vector<double> data_;
};

int main() {
    Matrix a(2, 3, 1.0);
    Matrix b(3, 2, 2.0);
    Matrix c = a * b;        // 6 = 全1×全2
    c.print();
}
```

用到的本篇知识：构造初始化列表、private 封装、const 成员函数重载、运算符重载、异常（第十一篇详讲）。

## 小练习

1. 实现 `Fraction`（分数类）：私有分子分母、`reduce()` 约分、`operator+`、`print()`，保证分母永不为 0
2. 给第三篇的猜数字加 `GameStats` 类：static 成员统计总局数与总尝试次数
3. 写 `Timer` 类：构造记录时间、析构时打印存活时长（RAII 计时器，函数性能粗测神器）
4. 实现 `Stack` 类（基于 vector）：push/pop/top/empty/size，pop 空栈时抛异常
5. （概念）说出三法则是什么、为什么持有 `int*` 的类必须遵守

## 本篇小结

- class 默认 private；封装 = 数据私有 + 接口公开
- 构造函数可重载；初始化列表先于构造体执行；单参构造加 explicit
- 析构 `~T()` 自动释放资源——RAII 是 C++ 的核心习惯
- 浅拷贝会双重释放；持有资源遵循三法则（析构+拷贝构造+拷贝赋值）
- static 成员类共享；this 支持链式；只读函数标 const

**下一篇**：面向对象（下）——继承、多态与虚函数，OOP 的另一半拼图。

---

*本系列为 Cyber先锋社原创教程。三法则与 RAII 是 C++ 区别于其他语言的核心概念，值得反复咀嚼。*
