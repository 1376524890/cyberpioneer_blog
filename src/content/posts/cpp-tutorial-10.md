---
title: C++ 入门教程（十）：运算符重载与友元
published: 2026-10-29
description: 掌握 C++ 特色能力：运算符重载的规则与常用实现（算术/比较/流/下标/函数调用）、成员与非成员重载的选择、friend 友元机制、Matrix 与 Fraction 完整实现，理解何时不该重载。
tags: [C++, 编程入门, 教程, 运算符重载]
category: 编程教程
slug: cpp-tutorial-10
series: "C++ 入门教程"
seriesOrder: 10
---

## 本篇目标

`a + b`、`cout << obj`、`obj[i]`——内置类型天然支持这些运算，**自定义类型也可以**。运算符重载让 `Money + Money`、`Vector * Matrix` 写起来像数学公式。这是 C++ 区别于多数语言的特性，用好了代码优雅，用滥了灾难现场。

## 一、基本概念与规则

### 什么能重载、什么不能

```text
✅ 可重载：+ - * / % == != < > += -= << >> && || ! [] () -> new...
❌ 不可重载：:: . .* sizeof typeid ?:（三目） .*
```

**两条硬规则**：

1. 至少一个操作数是自定义类型（不能重载 `int + int`）
2. 不能发明新运算符、不能改变优先级与结合性

**心法**：重载后的行为要**符合直觉**——`+` 就该是加法语义。把 `+` 重载成减法，同事会杀人。

### 成员 vs 非成员

```cpp
class Money {
    long cents_;                        // 用"分"存，避免浮点误差
public:
    // 成员函数版：左操作数必须是本类
    Money operator+(const Money& rhs) const {
        return Money(cents_ + rhs.cents_);
    }
};

// 非成员版（常配友元）：左操作数可以是其他类型
Money operator-(const Money& a, const Money& b);
std::ostream& operator<<(std::ostream&, const Money&);   // 流运算符必须非成员
```

**选择**：会修改左操作数（`+=`、`=`、`[]`）用成员；对称双目（`+`、`==`）与流运算符用非成员。

## 二、算术与比较运算符

### 完整的 Fraction（分数）实现

```cpp
#include <iostream>
#include <numeric>      // std::gcd

class Fraction {
    long num_, den_;                        // 分子/分母

    void reduce() {                         // 内部工具：约分并规范化符号
        long g = std::gcd(num_, den_);
        if (g != 0) { num_ /= g; den_ /= g; }
        if (den_ < 0) { num_ = -num_; den_ = -den_; }   // 分母保持正
    }

public:
    Fraction(long n, long d = 1) : num_(n), den_(d) {
        if (d == 0) throw std::invalid_argument("分母为零");
        reduce();
    }

    // —— 算术：返回新对象，const ——
    Fraction operator+(const Fraction& r) const {
        return Fraction(num_ * r.den_ + r.num_ * den_, den_ * r.den_);
    }
    Fraction operator-(const Fraction& r) const {
        return Fraction(num_ * r.den_ - r.num_ * den_, den_ * r.den_);
    }
    Fraction operator*(const Fraction& r) const {
        return Fraction(num_ * r.num_, den_ * r.den_);
    }
    Fraction operator/(const Fraction& r) const {
        if (r.num_ == 0) throw std::invalid_argument("除以零");
        return Fraction(num_ * r.den_, den_ * r.num_);
    }

    // —— 复合赋值：修改自身，返回 *this 引用 ——
    Fraction& operator+=(const Fraction& r) {
        return *this = *this + r;           // 复用 operator+
    }

    // —— 比较：写成一对，其余用逻辑推导 ——
    bool operator==(const Fraction& r) const {
        return num_ == r.num_ && den_ == r.den_;   // 已约分，直接比
    }
    bool operator<(const Fraction& r) const {
        return num_ * r.den_ < r.num_ * den_;
    }

    double value() const { return double(num_) / den_; }
    long num() const { return num_; }
    long den() const { return den_; }
};

// 非成员：流输出
std::ostream& operator<<(std::ostream& os, const Fraction& f) {
    if (f.den() == 1) return os << f.num();
    return os << f.num() << "/" << f.den();
}

int main() {
    Fraction a(1, 2), b(3, 4);

    std::cout << a << " + " << b << " = " << a + b << "\n";   // 5/4
    std::cout << a << " * " << b << " = " << a * b << "\n";   // 3/8
    std::cout << a << " - " << b << " = " << a - b << "\n";   // -1/4
    std::cout << (a < b ? "a<b" : "a>=b") << "\n";

    Fraction c(2, 4);        // 自动约分成 1/2
    std::cout << c << "\n";  // 1/2
}
```

**省力技巧（C++20 `<=>`）**：三路比较一行顶六行：

```cpp
// C++20：自动生成 == != < <= > >=
auto operator<=>(const Fraction&) const = default;   // 需成员逐一可比较
```

## 三、流运算符 << 与 >>

```cpp
// << 必须是非成员（左操作数是 ostream，不是我们的类）
std::ostream& operator<<(std::ostream& os, const Fraction& f) {
    return os << f.num() << "/" << f.den();   // 返回 os 引用 → 支持链式
}

// >> 输入版
std::istream& operator>>(std::istream& is, Fraction& f) {
    long n, d;
    char slash;
    if (is >> n >> slash >> d && slash == '/')
        f = Fraction(n, d);                   // 输入合法才更新
    else
        is.setstate(std::ios::failbit);       // 标记失败
    return is;
}
// 用法：std::cout << a << " " << b << "\n";  链式全靠返回 os
```

## 四、下标、调用与类型转换运算符

### operator[]：让对象像数组

```cpp
class IntArray {
    std::vector<int> data_;
public:
    explicit IntArray(size_t n) : data_(n) {}

    int& operator[](size_t i) { return data_.at(i); }          // 可写版本
    const int& operator[](size_t i) const { return data_.at(i); }  // 只读版本

    size_t size() const { return data_.size(); }
};

IntArray arr(5);
arr[0] = 42;                  // 调可写版
std::cout << arr[0];          // 调只读版（const 场景）
```

### operator()：仿函数（函数对象）

```cpp
class Multiplier {                    // "行为像函数的对象"
    int factor_;
public:
    explicit Multiplier(int f) : factor_(f) {}
    int operator()(int x) const {     // 重载调用运算符
        return x * factor_;
    }
};

Multiplier triple(3);
std::cout << triple(10);              // 30——像调用函数一样使用对象

// STL 中 lambda 本质就是编译器生成的仿函数类！
auto quadruple = [](int x) { return x * 4; };
```

### 类型转换运算符

```cpp
class Fraction {
    // ...
public:
    explicit operator double() const {      // 显式转 double
        return double(num_) / den_;
    }
};

Fraction f(1, 2);
double d = static_cast<double>(f);   // ✓ 显式转换
// double e = f;                    // ❌ explicit 禁止隐式转换（防意外）
```

## 五、友元（friend）

### 问题：非成员函数想访问私有成员

```cpp
class BankAccount {
    friend std::ostream& operator<<(std::ostream&, const BankAccount&);
    // ↑ 声明这个函数是"朋友"：允许它访问我的 private

private:
    std::string owner_;
    double balance_;

public:
    BankAccount(std::string o, double b) : owner_(std::move(o)), balance_(b) {}
};

// 友元函数不是成员函数，但能访问私有成员
std::ostream& operator<<(std::ostream& os, const BankAccount& acc) {
    return os << acc.owner_ << ": ¥" << acc.balance_;   // ✓ 访问 private
}

int main() {
    BankAccount a("小明", 100.5);
    std::cout << a << "\n";    // 小明: ¥100.5
}
```

### 友元类与要点

```cpp
class Matrix;
class MatrixIterator {
    friend class Matrix;      // Matrix 的所有成员函数都可访问我的私有
    // ...
};
```

**友元三原则**：friend 是"授予"而非"索取"（类自己声明谁是我朋友）；友元破坏封装，能不用就不用；**合法场景**：运算符重载、紧密协作的类对（Container 与它的 Iterator）。

**友元不被继承、不是双向的、不传递**。

## 六、何时不该重载

| 场景 | 建议 |
| --- | --- |
| 数学类型（向量/分数/矩阵/复数） | ✅ 重载 + - * /，天然合适 |
| 逻辑比较（排序、去重需要） | ✅ `<` `==`（配 STL 容器） |
| 输出调试 | ✅ `<<` |
| `&&` `||` | ❌ 重载后失去短路求值！ |
| 逗号 `，`、取地址 `&` | ❌ 语义迷惑，别碰 |
| 为了少打字把 `+` 当"追加"用于文件/网络 | ⚠ 语义存疑，用命名方法 `append` 更清晰 |

## 七、实战：二维向量 Vector2D 完整版

```cpp
#include <iostream>
#include <cmath>

class Vec2 {
    double x_, y_;
public:
    Vec2(double x = 0, double y = 0) : x_(x), y_(y) {}

    Vec2 operator+(const Vec2& r) const { return {x_ + r.x_, y_ + r.y_}; }
    Vec2 operator-(const Vec2& r) const { return {x_ - r.x_, y_ - r.y_}; }
    Vec2 operator*(double k) const { return {x_ * k, y_ * k}; }        // 数乘
    Vec2 operator-() const { return {-x_, -y_}; }                       // 取负

    bool operator==(const Vec2& r) const { return x_==r.x_ && y_==r.y_; }

    double dot(const Vec2& r) const { return x_ * r.x_ + y_ * r.y_; }
    double length() const { return std::sqrt(dot(*this)); }             // 复用 dot

    double& operator[](size_t i) { return i == 0 ? x_ : y_; }           // v[0]/v[1]

    friend std::ostream& operator<<(std::ostream& os, const Vec2& v) {
        return os << "(" << v.x_ << ", " << v.y_ << ")";
    }
};

Vec2 operator*(double k, const Vec2& v) { return v * k; }   // 3*v 也成立

int main() {
    Vec2 a(1, 2), b(3, 4);

    std::cout << "a=" << a << " b=" << b << "\n";
    std::cout << "a+b=" << a + b << "\n";       // (4, 6)
    std::cout << "a·b=" << a.dot(b) << "\n";    // 11
    std::cout << "|b|=" << b.length() << "\n";  // 5
    std::cout << "3a=" << 3 * a << "\n";        // (3, 6)

    Vec2 c = a + b * 2;                          // 数学式表达式
    std::cout << c[0] << "," << c[1] << "\n";   // 7,10
}
```

## 小练习

1. 给 Fraction 补全 `>= <= > !=`（用 `<` 和 `==` 组合实现）
2. 实现 `Temperature` 类：内部存摄氏，`operator+`、转华氏方法、`<<` 输出两种温标
3. 实现 `Str` 简易字符串类：`operator+` 拼接、`operator[]` 访问、`operator==` 比较
4. 写 `Accumulator` 仿函数：每次 `()` 调用累加并返回累计值（对比第六篇闭包计数器）
5. （思考）为什么 `operator<<` 不能是成员函数？为什么 `operator+=` 通常是成员而 `operator+` 常是非成员？

## 本篇小结

- 可重载绝大多数运算符，但语义必须符合直觉；`&&`/`||` 别重载（失短路）
- 修改自身用成员（`+= = [] ()`），对称与流用非成员（`+ == << >>`）
- 算术返回新值 const，复合赋值返回 `*this&`
- `<<` 返回 ostream 引用支撑链式；C++20 `<=>` 一行生成全套比较
- friend 授予外部访问私有的权限，仅用于运算符/姊妹类
- 仿函数 `operator()` 是 lambda 的本质

**下一篇**：STL 标准模板库总览——容器、迭代器与算法的完整武器库。

---

*本系列为 Cyber先锋社原创教程。Fraction 与 Vec2 是面试白板题常客，建议默写一遍。*
