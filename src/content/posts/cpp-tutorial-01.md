---
title: C++ 入门教程（一）：开发环境与第一个程序
published: 2026-10-29
description: 走进 C++ 的世界：认识编译型语言、搭建开发环境、理解 main 函数与编译流程、掌握变量与输入输出流。性能之王的起点从这里开始。
tags: [C++, 编程入门, 教程]
category: 编程教程
slug: cpp-tutorial-01
series: "C++ 入门教程"
seriesOrder: 1
---

## 为什么值得学 C++

C++ 是一门"越学越值钱"的语言：操作系统、游戏引擎、数据库、高性能计算、嵌入式设备的底层几乎都由 C++ 驱动。它直接操作内存、贴近硬件，运行效率极高；同时现代 C++（11/17/20 标准）也提供了大量便利特性。

学 C++ 的过程能让你真正理解**计算机是怎么工作的**——这也是为什么很多高校把 C++ 作为第一门语言。相比 Python，它更严格，但也更锻炼基本功。

## 编译型语言 vs 解释型语言

开始前先建立一个关键概念：

| | Python | C++ |
| --- | --- | --- |
| 执行方式 | 解释器逐行执行 | **先编译成机器码，再运行** |
| 源文件 | `.py` | `.cpp` / `.cc` |
| 类型检查 | 运行时 | **编译时（更严格）** |
| 运行速度 | 较慢 | 极快 |

写好的 C++ 代码不能直接运行，要经过 **预处理 → 编译 → 汇编 → 链接** 四步生成可执行文件。入门阶段不需要深究细节，只需知道：**编辑器写代码，编译器造程序**。

## 搭建开发环境

### Windows：安装 MinGW-w64（VS Code + g++）

1. 下载 [MSYS2](https://www.msys2.org/) 并安装
2. 在 MSYS2 终端执行：

```bash
pacman -S mingw-w64-ucrt-x86_64-gcc
```

3. 把 `C:\msys64\ucrt64\bin` 加入系统 PATH
4. 验证：

```bash
g++ --version
```

推荐搭配 VS Code + C/C++ 扩展使用。也可以直接安装 Visual Studio Community（一体化但体积大）。

### macOS

```bash
xcode-select --install   # 安装命令行工具（含 clang++）
clang++ --version
```

### Linux（Ubuntu/Debian）

```bash
sudo apt update && sudo apt install build-essential
g++ --version
```

## 第一个程序

新建 `hello.cpp`：

```cpp
#include <iostream>   // 引入输入输出库

int main() {          // main 函数：程序的入口
    std::cout << "Hello, Cyber先锋社!" << std::endl;
    return 0;         // 返回 0 表示程序正常结束
}
```

编译并运行：

```bash
g++ hello.cpp -o hello   # 编译，-o 指定输出文件名
./hello                   # 运行
Hello, Cyber先锋社!
```

**逐行解读**：

- `#include <iostream>`：预处理指令，引入标准输入输出流库
- `int main()`：每个 C++ 程序都从 main 函数开始执行，`int` 表示它返回一个整数
- `std::cout`：标准输出流对象，`<<` 把内容"流向"屏幕
- `std::endl`：换行符（并刷新缓冲区）
- `return 0`：向操作系统报告程序成功执行

## 变量与数据类型

C++ 是**静态类型语言**，变量必须先声明类型：

```cpp
#include <iostream>
#include <string>

int main() {
    int age = 18;                  // 整数（通常 4 字节）
    double height = 1.75;          // 双精度浮点数（8 字节）
    char grade = 'A';              // 单个字符，用单引号
    bool is_member = true;         // 布尔值
    std::string name = "小明";     // 字符串（需 #include <string>）

    std::cout << "姓名: " << name << std::endl;
    std::cout << "年龄: " << age << std::endl;
    std::cout << "身高: " << height << std::endl;
    return 0;
}
```

### 常用类型速览

| 类型 | 字节 | 范围/说明 |
| --- | --- | --- |
| `int` | 4 | 约 ±21 亿 |
| `long long` | 8 | 约 ±9.2×10¹⁸ |
| `double` | 8 | 15~16 位有效数字 |
| `char` | 1 | 单字符 |
| `bool` | 1 | true / false |
| `std::string` | 动态 | 任意长度文本 |

> [!TIP]
> 用 `sizeof(类型)` 可以查看字节数，如 `std::cout << sizeof(int)`。理解内存大小是 C++ 的基本功。

## 输入与输出

```cpp
#include <iostream>
#include <string>

int main() {
    std::string name;
    int age;

    std::cout << "输入你的姓名: ";
    std::cin >> name;          // 从键盘读取

    std::cout << "输入你的年龄: ";
    std::cin >> age;

    std::cout << name << " 明年 " << age + 1 << " 岁" << std::endl;
    return 0;
}
```

`std::cin` 与 `std::cout` 方向相反：`>>` 把输入"流入"变量。

### 用 using 简化书写

每次写 `std::` 很啰嗦，可以在文件开头声明：

```cpp
#include <iostream>
using namespace std;    // 之后直接写 cout / cin / endl

int main() {
    cout << "简洁多了!" << endl;
    return 0;
}
```

> [!NOTE]
> `using namespace std` 在大型工程中可能引发命名冲突，教学代码中用没问题，工程实践中建议保留 `std::` 前缀或局部使用。

## 小练习

1. 编写程序输出你选的课表（每行一门课），体会 `endl` 与 `\n` 的用法
2. 定义变量保存圆的半径，计算并输出周长与面积（`3.14159 * r * r`）
3. 用 `cin` 读入两个整数，输出它们的和、差、积

## 本篇小结

- C++ 是编译型语言：`g++ 源文件 -o 可执行文件` → `./可执行文件`
- 程序入口是 `main` 函数，`return 0` 表示正常结束
- 变量必须声明类型，`int` / `double` / `char` / `bool` / `std::string` 是五大基础类型
- `std::cout <<` 输出、`std::cin >>` 输入，`using namespace std` 可简化书写

**下一篇**：分支与循环 + `vector` 容器入门——写出真正有逻辑的程序。

---

*本系列为 Cyber先锋社原创教程，参考业界通用知识体系编写。*
