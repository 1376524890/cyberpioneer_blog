---
title: C++ 入门教程（三）：流程控制
published: 2026-10-29
description: 完整讲解 C++ 分支（if/switch）、三种循环（while/do-while/for）、范围 for 与 auto、break/continue、嵌套与经典算法练习（九九表/质数/图形打印/猜数字）。
tags: [C++, 编程入门, 教程]
category: C++ 教程
slug: cpp-tutorial-03
series: "C++ 入门教程"
seriesOrder: 3
---

## 本篇目标

程序的三种结构：**顺序、分支、循环**。本篇讲全 C++ 的流程控制语法，与 Python 对比着学效率最高——逻辑相同，只是换了"语法外壳"。

## 一、分支结构

### if / else if / else

```cpp
#include <iostream>
int main() {
    int score;
    std::cout << "输入成绩: ";
    std::cin >> score;

    if (score >= 90) {
        std::cout << "优秀\n";
    } else if (score >= 80) {
        std::cout << "良好\n";
    } else if (score >= 60) {
        std::cout << "及格\n";
    } else {
        std::cout << "不及格\n";
    }
    return 0;
}
```

与 Python 的差异：条件必须带**圆括号**、代码块用**花括号**、else if 中间有空格。

### switch：多值分发

当条件是"一个变量等于哪些值"时，switch 比 if 链清晰：

```cpp
#include <iostream>
int main() {
    char op;
    double a, b;
    std::cout << "输入: 数 运算符 数（如 3 + 4）: ";
    std::cin >> a >> op >> b;

    switch (op) {
        case '+':
            std::cout << a + b << "\n";
            break;                    // ⚠ 不写 break 会"贯穿"到下一分支！
        case '-':
            std::cout << a - b << "\n";
            break;
        case '*':
            std::cout << a * b << "\n";
            break;
        case '/':
            if (b != 0) std::cout << a / b << "\n";
            else        std::cout << "除数不能为0\n";
            break;
        default:                      // 兜底分支
            std::cout << "不支持的运算符\n";
    }
    return 0;
}
```

**switch 的规矩**：case 值必须是**整数或枚举常量**（不能是 double、不能是字符串）；每个分支末尾写 break，除非刻意利用贯穿。

> [!WARNING]
> 忘 break 是 switch 第一大坑：
> ```cpp
> int x = 1;
> switch (x) {
>     case 1: std::cout << "一";    // 输出"一二"——贯穿了！
>     case 2: std::cout << "二"; break;
> }
> ```

### 三元运算符

```cpp
int a = 10, b = 20;
int max_val = (a > b) ? a : b;
```

## 二、循环结构

### while：条件前置

```cpp
#include <iostream>
int main() {
    int n, sum = 0;
    std::cout << "输入 n: ";
    std::cin >> n;

    int i = 1;
    while (i <= n) {
        sum += i;
        ++i;              // 别忘了推进条件
    }
    std::cout << "1~" << n << " 的和是 " << sum << "\n";
    return 0;
}
```

### do-while：先斩后奏（C++ 特有常见）

```cpp
int choice;
do {
    std::cout << "1.开始 2.设置 0.退出\n请选择: ";
    std::cin >> choice;
    // 处理 choice...
} while (choice != 0);      // 注意末尾分号

// 至少执行一次——天然适合"菜单系统"
```

### for：计数循环

```cpp
// 打印 1~10 的平方
for (int i = 1; i <= 10; ++i) {
    std::cout << i << "²= " << i * i << "\n";
}

// 死循环的两种写法
for (;;) { /* ... */ }
while (true) { /* ... */ }

// for 的三个部分都可空：分号不能省
int i = 0;
for (; i < 5;) {
    std::cout << i << " ";
    ++i;
}
```

### 范围 for + auto（C++11，遍历首选）

```cpp
#include <iostream>
#include <vector>
#include <string>

int main() {
    int arr[]{10, 20, 30, 40};
    for (int x : arr)                    // 遍历数组
        std::cout << x << " ";           // 10 20 30 40
    std::cout << "\n";

    std::vector<std::string> langs{"C++", "Python", "Java"};
    for (const auto& lang : langs)       // 只读遍历用 const auto&（免拷贝）
        std::cout << lang << " ";
    std::cout << "\n";

    std::string s = "Cyber";
    for (char c : s)                     // 遍历字符串
        std::cout << c << "-";
    return 0;
}
```

**遍历三姿势**：

| 写法 | 语义 | 适用 |
| --- | --- | --- |
| `for (auto x : c)` | 拷贝每个元素 | 小对象/基本类型 |
| `for (auto& x : c)` | 引用，可修改元素 | 要改内容 |
| `for (const auto& x : c)` | 只读引用，零拷贝 | 大对象只读（默认选它） |

## 三、break / continue

```cpp
// break：终止所在层循环
for (int i = 1; i <= 100; ++i) {
    if (i * i > 500) {
        std::cout << "第一个平方超500的是 " << i << "\n";
        break;
    }
}

// continue：跳过本次
for (int i = 1; i <= 20; ++i) {
    if (i % 3 == 0) continue;    // 跳过 3 的倍数
    std::cout << i << " ";       // 1 2 4 5 7 8 ...
}
```

C++ 没有 Python 的"循环 else"，等价逻辑用一个标志变量实现。

## 四、嵌套循环与经典练习

### 1. 九九乘法表

```cpp
for (int i = 1; i <= 9; ++i) {
    for (int j = 1; j <= i; ++j) {
        printf("%d×%d=%-4d", j, i, i * j);   // %-4d 左对齐宽4
    }
    std::cout << "\n";
}
```

### 2. 判断质数（带输入校验）

```cpp
#include <iostream>
#include <cmath>

bool is_prime(int n) {                 // bool 函数，第五篇详讲
    if (n < 2) return false;
    for (int i = 2; i <= std::sqrt(n); ++i) {
        if (n % i == 0) return false;
    }
    return true;
}

int main() {
    int n;
    std::cin >> n;
    std::cout << n << (is_prime(n) ? " 是" : " 不是") << "质数\n";
}
```

### 3. 打印图形（嵌套循环的空间感）

```cpp
// 金字塔（5行）
int rows = 5;
for (int i = 1; i <= rows; ++i) {
    for (int s = 0; s < rows - i; ++s) std::cout << " ";   // 左侧空格
    for (int j = 0; j < 2 * i - 1; ++j) std::cout << "*";  // 星号
    std::cout << "\n";
}
//     *
//    ***
//   *****
//  *******
// *********
```

### 4. 猜数字（do-while 的主场）

```cpp
#include <iostream>
#include <cstdlib>      // rand/srand
#include <ctime>

int main() {
    std::srand(std::time(nullptr));        // 播种子
    int answer = std::rand() % 100 + 1;    // 1~100
    int guess, tries = 0;

    do {
        std::cout << "猜(1-100): ";
        if (!(std::cin >> guess)) {        // 输入校验（上篇）
            std::cin.clear();
            std::cin.ignore(10000, '\n');
            std::cout << "请输入数字！\n";
            continue;
        }
        ++tries;
        if (guess < answer)      std::cout << "小了\n";
        else if (guess > answer) std::cout << "大了\n";
        else                     std::cout << "对了！用了 " << tries << " 次\n";
    } while (guess != answer);
    return 0;
}
```

### 5. FizzBuzz（面试名题）

```cpp
for (int i = 1; i <= 30; ++i) {
    if (i % 15 == 0)      std::cout << "FizzBuzz ";
    else if (i % 3 == 0)  std::cout << "Fizz ";
    else if (i % 5 == 0)  std::cout << "Buzz ";
    else                  std::cout << i << " ";
}
```

## 五、goto：知道但别用

```cpp
    // C++ 保留了 goto，但现代编码规范一律禁用——破坏结构化、难以追踪
    goto end;
    std::cout << "这行被跳过";
end:
    return 0;
```

唯一"合理"场景是多层嵌套循环的一次性跳出，但那也该用函数 + return 重构。

## 小练习

1. 输入一个整数，逆序输出各位数字（1234 → 4321；while + % /）
2. 求两个数的最大公约数（辗转相除：while ((b %= a %= b) ...) 或标准三行版）
3. 打印 100~999 的所有水仙花数（各位立方和等于自身）
4. 用范围 for 统计 `std::vector<int>{3,7,1,9,4}` 的最大值、最小值与平均值
5. 双重循环找"百钱买百鸡"：公鸡5元/只、母鸡3元/只、小鸡1元3只，100元买100只，输出所有方案

## 本篇小结

- if 条件必带括号；switch 只认整型/枚举、必带 break 与 default
- while 先判后做、do-while 先做后判（菜单场景）、for 三段式
- 范围 for + `const auto&` 是遍历容器的默认姿势
- break 跳出本层、continue 跳过本次；没有循环 else
- goto 是历史遗迹，现代 C++ 禁用

**下一篇**：函数——定义、声明、重载与默认参数，C++ 的函数比 Python 讲究得多。

---

*本系列为 Cyber先锋社原创教程。五个经典练习建议全部独立敲一遍，比看十遍教程有效。*
