---
title: C++ 入门教程（四）：函数详解
published: 2026-10-29
description: 深入 C++ 函数：声明与定义分离、参数传递三种方式（值/引用/指针）、默认参数与函数重载、内联与递归、作用域与生命周期、头文件组织，配工资计算器与斐波那契实战。
tags: [C++, 编程入门, 教程]
category: 编程教程
slug: cpp-tutorial-04
series: "C++ 入门教程"
seriesOrder: 4
---

## 本篇目标

C++ 的函数体系比 Python 严格也强大：**函数必须先声明后使用**、参数传递方式直接决定性能与语义、还有重载与默认参数两大利器。本篇一次讲透，这是 C++ 分水岭之一。

## 一、定义、声明与头文件

### 为什么需要"先声明"

编译器从上往下读文件，调用函数前必须"见过"它。大项目里函数分散在多文件，靠**声明（原型）**解决：

```cpp
// 函数声明（原型）：告诉编译器"有这个函数，长这样"
double calc_bmi(double weight, double height);

int main() {
    std::cout << calc_bmi(70, 1.75);    // ✓ 编译器已认识它
    return 0;
}

// 函数定义：真正实现
double calc_bmi(double weight, double height) {
    return weight / (height * height);
}
```

**声明与定义的区别**：声明是"预告"（无函数体），定义是"实现"。声明可多次，定义只能一次。

### 多文件组织（.h / .cpp）

```cpp
// ===== math_utils.h（头文件：放声明）=====
#ifndef MATH_UTILS_H          // 包含保护：防止重复包含
#define MATH_UTILS_H

double calc_bmi(double weight, double height);
bool   is_prime(int n);

#endif
```

```cpp
// ===== math_utils.cpp（源文件：放定义）=====
#include "math_utils.h"       // 自己的头文件用 ""

double calc_bmi(double weight, double height) {
    return weight / (height * height);
}

bool is_prime(int n) {
    if (n < 2) return false;
    for (int i = 2; i * i <= n; ++i)
        if (n % i == 0) return false;
    return true;
}
```

```cpp
// ===== main.cpp =====
#include <iostream>
#include "math_utils.h"       // 用谁的头文件就 include 谁

int main() {
    std::cout << calc_bmi(70, 1.75) << "\n";
}
```

编译：`g++ main.cpp math_utils.cpp -o app`（所有 cpp 都要参与编译）。

## 二、参数传递：C++ 的灵魂

### 1. 值传递（默认）：拷贝一份

```cpp
void try_change(int x) {      // x 是实参的副本
    x = 100;
}

int main() {
    int n = 5;
    try_change(n);
    std::cout << n;           // 5 —— 原值不变
}
```

### 2. 引用传递（&）：起别名，可修改原值

```cpp
void actually_change(int& x) {    // x 是 n 的别名
    x = 100;
}

int main() {
    int n = 5;
    actually_change(n);
    std::cout << n;           // 100 ✓ 改的是原值
}
```

**引用的经典用途 1：多返回值（出参）**

```cpp
// 同时返回商和余数
void divmod(int a, int b, int& quotient, int& remainder) {
    quotient = a / b;
    remainder = a % b;
}

int main() {
    int q, r;
    divmod(17, 5, q, r);
    std::cout << q << " 余 " << r;    // 3 余 2
}
```

### 3. const 引用传递：大对象只读零拷贝

```cpp
#include <string>

// 值传递会拷贝整个字符串（浪费）；const& 既不拷贝又不可改
void print_banner(const std::string& text) {
    std::cout << "==== " << text << " ====\n";
}
```

**参数传递决策表**：

| 参数类型 | 写法 | 场景 |
| --- | --- | --- |
| 小对象（int/double/指针） | 值传递 `T x` | 默认 |
| 要修改实参 | 引用 `T& x` | 出参、原地修改 |
| 大对象只读（string/vector） | `const T& x` | 默认 |
| 可能为空/要改指向 | 指针 `T* x`（第六篇） | C 风格接口 |

### 默认参数

```cpp
double power(double base, int exp = 2);     // 声明处给默认值

int main() {
    std::cout << power(3) << "\n";          // 9（用默认 exp=2）
    std::cout << power(3, 3) << "\n";       // 27
}

double power(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; ++i) result *= base;
    return result;
}
```

**规矩**：默认参数必须从右往左连续给——`f(int a, int b=1, int c=2)` ✓，`f(int a=1, int b)` ❌。声明与定义分离时，默认值只能写在**声明**里。

## 三、函数重载（Overload）

同名函数、参数不同（个数或类型），编译器按实参自动匹配：

```cpp
#include <iostream>
#include <string>

int    max_of(int a, int b)             { return a > b ? a : b; }
double max_of(double a, double b)       { return a > b ? a : b; }
int    max_of(int a, int b, int c)      { return max_of(max_of(a, b), c); }
std::string max_of(const std::string& a, const std::string& b) { return a > b ? a : b; }

int main() {
    std::cout << max_of(3, 7) << "\n";            // int 版 → 7
    std::cout << max_of(3.14, 2.71) << "\n";      // double 版 → 3.14
    std::cout << max_of(1, 9, 4) << "\n";         // 三参版 → 9
    std::cout << max_of("apple", "banana") << "\n"; // string 版 → banana
}
```

> [!WARNING]
> 重载只看**参数**，不看返回值——`int f()` 与 `double f()` 不构成重载，直接编译错误。
> Python 没有重载（用默认参数模拟），这是 C++ 的"编译期多态"。

## 四、递归

```cpp
#include <iostream>

unsigned long long factorial(int n) {
    if (n <= 1) return 1;                       // 基线
    return n * factorial(n - 1);                // 递推
}

// 输出斐波那契第 n 项（递归版——直观但慢）
long long fib(int n) {
    if (n < 2) return n;
    return fib(n - 1) + fib(n - 2);
}

int main() {
    for (int i = 1; i <= 10; ++i)
        std::cout << factorial(i) << " ";
    std::cout << "\n";
    std::cout << fib(40) << "\n";       // 102334155（已经要跑一会儿了）
}
```

注意 `unsigned long long`：20! 已超 int 范围，选对类型是 C++ 的日常。

## 五、作用域与生命周期

```cpp
#include <iostream>

int g = 100;                    // 全局变量（尽量少用）

void demo() {
    int local = 1;              // 局部：函数结束销毁
    static int count = 0;       // 静态局部：只初始化一次，函数间保留
    ++count;
    std::cout << "local=" << local++ << " count=" << count << "\n";
}

int main() {
    demo();    // local=1 count=1
    demo();    // local=1 count=2（local 每次重建，count 保留！）
    {
        int block_var = 42;     // 块作用域
    }
    // std::cout << block_var;  // ❌ 出块即亡
}
```

`static` 局部变量 = "只属于这个函数的全局变量"，常用于调用计数、缓存。

## 六、内联函数与 constexpr 函数

```cpp
// inline：建议编译器把函数体直接展开到调用处（省调用开销）
// 现代编译器很聪明，inline 更多语义是"允许多文件安全定义"
inline int square(int x) { return x * x; }

// constexpr 函数（C++11/14）：可在编译期求值
constexpr int cube(int x) { return x * x * x; }

int arr[cube(3)];          // ✓ 27 作为编译期数组大小
constexpr int c = cube(4); // 编译期计算出 64
```

## 七、实战：个税与工资计算器

综合本篇知识（声明分离、引用出参、重载、默认参数）：

```cpp
#include <iostream>
#include <iomanip>

// ===== salary.h 的声明部分（这里合并演示）=====
double calc_tax(double taxable);                       // 按超额累进
void   split_salary(double gross, double& net, double& tax);   // 出参

// ===== 实现 =====
double calc_tax(double taxable) {
    // 简化版超额累进（月度，免征额已扣除）
    if (taxable <= 0)    return 0;
    if (taxable <= 3000) return taxable * 0.03;
    if (taxable <= 12000) return 3000 * 0.03 + (taxable - 3000) * 0.10;
    return 3000 * 0.03 + 9000 * 0.10 + (taxable - 12000) * 0.20;
}

void split_salary(double gross, double& net, double& tax) {
    tax = calc_tax(gross - 5000.0);      // 免征额 5000
    net = gross - tax;
}

int main() {
    double gross;
    std::cout << std::fixed << std::setprecision(2);
    while (true) {
        std::cout << "\n输入税前月薪（0退出）: ";
        if (!(std::cin >> gross)) break;
        if (gross <= 0) break;

        double net, tax;
        split_salary(gross, net, tax);
        std::cout << "税前: " << gross << "\n税额: " << tax
                  << "\n到手: " << net << "\n";
    }
}
```

## 小练习

1. 写 `swap(int&, int&)` 验证引用交换；再写值传递版对比为什么不行
2. 重载 `area`：正方形（1 参）、长方形（2 参）、圆（半径，double 参）
3. 写 `void stats(const std::vector<int>& v, double& avg, int& max_v, int& min_v)` 一次算三个统计量
4. 递归实现"数字倒序打印"：`print_digits(1234)` 输出 `4 3 2 1`
5. 把本篇工资计算器拆成 salary.h / salary.cpp / main.cpp 三文件编译通过

## 本篇小结

- 声明与定义分离；头文件放声明（含包含保护），源文件放实现
- 值传递拷贝、`T&` 可修改实参、`const T&` 大对象只读零拷贝
- 默认参数靠右、写在声明处；重载按参数区分、与返回值无关
- static 局部变量跨调用保留；递归必须有基线
- inline/constexpr 提示编译期优化

**下一篇**：数组与 std::string/vector 三剑客——C++ 数据容器的正确打开方式。

---

*本系列为 Cyber先锋社原创教程。"声明放头文件"是多文件编程的第一课，练习 5 必做。*
