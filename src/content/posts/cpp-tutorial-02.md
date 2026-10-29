---
title: C++ 入门教程（二）：语法基础与运算符详解
published: 2026-10-29
description: 详解 C++ 注释规范、七类运算符（算术/关系/逻辑/位/赋值/杂项）、类型转换规则（隐式/显式/constexpr）、auto 与 typedef、常量定义，配可运行示例与典型陷阱。
tags: [C++, 编程入门, 教程]
category: 编程教程
slug: cpp-tutorial-02
series: "C++ 入门教程"
seriesOrder: 2
---

## 本篇目标

上一篇搭好了环境、跑通了第一个程序。本篇把 C++ 的**语法地基**打牢：注释、变量细节、全部运算符与类型转换。C++ 是强类型语言，这些规则比 Python 严格得多，理解它们能少走很多弯路。

## 一、注释与代码风格

```cpp
// 单行注释：解释"为什么"而不是"是什么"

/*
   多行注释
   常用于文件头说明、暂时禁用大段代码
*/

/**
 * 文档注释（Doxygen 风格）
 * @brief 计算两数之和
 * @param a 加数
 * @param b 被加数
 * @return 和
 */
int add(int a, int b) {
    return a + b;
}
```

## 二、变量进阶

### 初始化的三种写法

```cpp
int a = 10;       // 传统 C 风格（拷贝初始化）
int b(20);        // 直接初始化
int c{30};        // 列表初始化（C++11，现代推荐）

// 列表初始化的杀手锏：禁止窄化转换（丢失精度直接报错）
int x{3.14};      // ❌ 编译错误！double → int 会丢失
int y = 3.14;     // ⚠ 编译器仅警告，y = 3（静默截断）
```

### 未初始化变量的危险

```cpp
int n;            // ⚠ 值是随机的（栈上残留数据）！
std::cout << n;   // 可能输出任何数

int m{};          // ✅ 值初始化为 0
```

**军规：定义变量时永远给初值**，尤其是之后要累加的计数器。

### 常量

```cpp
const double PI = 3.14159;        // 运行时常量：定义后不可修改
PI = 3.14;                        // ❌ 编译错误

// 编译期常量（C++11）：值必须在编译期可计算，性能更好
constexpr int MAX_SIZE = 100;
constexpr double AREA = PI * 2;   // ✓ 由编译期常量组合而来

int arr[MAX_SIZE];                // 数组大小需要编译期常量 ✓
```

### 类型别名

```cpp
typedef unsigned long ulong_t;        // 传统写法
using score_t = double;               // C++11 别名声明（推荐，更清晰）

score_t math = 95.5;
ulong_t big = 100000UL;
```

### auto 类型推断（C++11）

```cpp
auto i = 42;              // int
auto d = 3.14;            // double
auto s = std::string("hi");   // std::string
auto v = std::vector<int>{1, 2, 3};   // 配合 STL 极大减少书写

// auto 用于复杂类型（迭代器）是真香现场：
std::vector<int> nums{1, 2, 3};
std::vector<int>::iterator it1 = nums.begin();   // 啰嗦
auto it2 = nums.begin();                          // 优雅
```

> [!NOTE]
> `auto` 是"让编译器推断类型"，不是"动态类型"——推断完成后类型就固定了，且 auto 变量必须有初始化。

## 三、运算符全解

### 1. 算术运算符

```cpp
#include <iostream>
int main() {
    int a = 10, b = 3;

    std::cout << a + b << "\n";    // 13
    std::cout << a - b << "\n";    // 7
    std::cout << a * b << "\n";    // 30
    std::cout << a / b << "\n";    // 3   ⚠ 整数除法，小数被截断！
    std::cout << a % b << "\n";    // 1   取模（两侧必须是整数）
    std::cout << 10.0 / 3 << "\n"; // 3.33333 有一侧是浮点就是浮点除法

    // ⚠⚠ 整数除法是 C++ 第一大坑：
    std::cout << 7 / 2 << "\n";        // 3
    std::cout << -7 / 2 << "\n";       // -3（C++11 起向零取整）
    std::cout << 7 % -2 << "\n";       // 1（商向零取整，余数符号跟被除数）

    // 后缀/前缀 自增自减
    int i = 5;
    std::cout << i++ << "\n";   // 5（先用后加）
    std::cout << ++i << "\n";   // 7（先加后用）
    return 0;
}
```

**整数溢出**（了解但重要）：

```cpp
int big = 2147483647;    // int 最大值
big = big + 1;           // 溢出！值回绕成 -2147483648（未定义行为的常见形式）
// 大数运算用 long long，检测用 <limits>
#include <limits>
std::cout << std::numeric_limits<int>::max() << "\n";
```

### 2. 关系与逻辑运算符

```cpp
int a = 5, b = 10;

std::cout << (a > b) << "\n";       // 0    ⚠ 布尔值输出是 1/0
std::cout << (a == b) << "\n";      // 0
std::cout << std::boolalpha;        // 切换为 true/false 输出
std::cout << (a < b) << "\n";       // true

// 逻辑：&& 且  || 或  ! 非
int age = 20;
bool has_id = true;
std::cout << (age >= 18 && has_id) << "\n";    // true
std::cout << !has_id << "\n";                  // false
```

> [!WARNING]
> C++ 的布尔本质是 int（0 为假，非 0 为真）。经典错误：`if (x = 5)` 把比较写成赋值——条件永远为真，部分编译器加 `-Wall` 才会警告。

短路求值与 Python 一致：`&&` 左假右不算，`||` 左真右不算。

### 3. 位运算符

```cpp
unsigned a = 0b1010;    // 10（C++14 二进制字面量）

std::cout << (a & 0b0110) << "\n";   // 2   按位与
std::cout << (a | 0b0101) << "\n";   // 15  按位或
std::cout << (a ^ 0b1111) << "\n";   // 5   异或
std::cout << (~a) << "\n";           // 按位取反（含符号位）
std::cout << (a << 2) << "\n";       // 40  左移 = ×4
std::cout << (a >> 1) << "\n";       // 5   右移 = ÷2

// 实用技：
bool is_odd = a & 1;             // 判奇偶
int half = a >> 1;               // 快速除2（现代编译器会自动优化，写 / 2 更清晰）
```

### 4. 赋值与逗号

```cpp
int x = 10;
x += 5;      // 15
x -= 3;      // 12
x *= 2;      // 24
x /= 5;      // 4
x %= 3;      // 1
x <<= 2;     // 4（位运算也有复合赋值）

int a, b, c;
a = (b = 1, c = 2, b + c);   // 逗号表达式：依次求值取最后结果，a = 3（少用，可读性差）
```

### 5. 三元与 sizeof

```cpp
int age = 20;
std::string s = (age >= 18) ? "成年" : "未成年";

std::cout << sizeof(int) << "\n";            // 4 字节
std::cout << sizeof(double) << "\n";         // 8
std::cout << sizeof("hello") << "\n";        // 6（含 '\0'）
int arr[]{1, 2, 3};
std::cout << sizeof(arr) / sizeof(arr[0]);   // 3 —— C 风格数组求长度
```

## 四、类型转换

### 隐式转换（自动发生，注意方向）

```cpp
int i = 42;
double d = i;          // ✓ int → double（安全提升）
int j = 3.99;          // ⚠ double → int（窄化，j = 3）

char c = 'A';
std::cout << c + 1 << "\n";    // 66（char 提升为 int 参与运算）
std::cout << char(c + 1);      // 'B'
```

### 显式转换四种cast（重点）

```cpp
double pi = 3.14;

// C 风格（能用但不推荐——一刀切，语义不明）
int a = (int)pi;
int b = int(pi);

// C++ 四种具名 cast：
int c1 = static_cast<int>(pi);            // ① static_cast：常规数值转换（90%场景用它）
// ② dynamic_cast：继承体系安全向下转型（第十篇）
// ③ const_cast：去除 const（几乎不用）
// ④ reinterpret_cast：位模式重解释（底层操作，慎用）
```

**现代 C++ 建议**：数值转换统一 `static_cast<T>(x)`，一眼看懂意图、便于搜索。

### 字符串与数值互转（C++11）

```cpp
#include <string>

int n = std::stoi("42");            // string → int
double d = std::stod("3.14");       // string → double
long l = std::stol("100000");

std::string s1 = std::to_string(42);        // int → string
std::string s2 = std::to_string(3.14);      // "3.140000"
```

## 五、cin 的状态与错误输入

```cpp
#include <iostream>
#include <limits>

int main() {
    int n;
    std::cout << "输入一个数: ";
    while (!(std::cin >> n)) {              // 输入失败（如输入字母）
        std::cin.clear();                    // 清除错误标志
        std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');  // 丢弃坏输入
        std::cout << "无效输入，请重新输入: ";
    }
    std::cout << "你输入了 " << n << "\n";
    return 0;
}
```

这段"输入校验循环"是 C++ 命令行程序的标准配件，值得整段背下来。

## 小练习

1. 计算 BMI：输入身高(m)体重(kg)，输出 `体重/身高²`，保留 1 位小数（`std::fixed` + `std::setprecision(1)`，需 `<iomanip>`）
2. 用位运算实现：交换两个 int 变量（不用第三个变量；提示 `^`）
3. `7/2*2` 等于几？`7.0/2*2` 呢？先笔算再上机验证
4. 输入秒数，换算为"X小时Y分Z秒"输出（用到 / 和 %）

## 本篇小结

- 三种初始化，`{}` 值初始化最安全（禁窄化）；变量定义必给初值
- `const` 运行期常量、`constexpr` 编译期常量；`using` 别名优于 `typedef`
- `auto` 让编译器推断类型，配 STL 神器
- 整数除法截断、`i++` vs `++i`、`=` 与 `==` 是三大新手坑
- 显式转换用 `static_cast`；字符串数值互转用 `stoi`/`to_string`
- cin 错误状态要 clear + ignore 才能恢复

**下一篇**：流程控制——分支、循环与 C++ 特有的范围 for。

---

*本系列为 Cyber先锋社原创教程。整数除法与类型转换请亲手验证每个示例。*
