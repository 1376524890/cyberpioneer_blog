---
title: C++ 入门教程（五）：数组与字符串
published: 2026-10-29
description: 详解 C 风格数组的局限与二维数组、std::vector 的增删改查全家桶、std::string 的构造与常用操作、C 字符串与 string 互转，掌握现代 C++ 容器优先原则。
tags: [C++, 编程入门, 教程]
category: 编程教程
slug: cpp-tutorial-05
series: "C++ 入门教程"
seriesOrder: 5
---

## 本篇目标

存"一堆数据"的三个层次：**C 数组**（原始、固定大小）、**std::vector**（动态数组，现代首选）、**std::string**（字符串专用容器）。重点放在后两者——现代 C++ 的原则是"能用 vector 不用数组，能用 string 不用 char*"。

## 一、C 风格数组

### 一维数组

```cpp
#include <iostream>

int main() {
    int scores[5] = {90, 85, 78, 92, 66};   // 定义即初始化
    int zeros[10] = {};                      // 全部初始化为 0
    int partial[5] = {1, 2};                 // {1,2,0,0,0} 其余补 0

    // 访问与修改（下标从 0 开始）
    scores[0] = 95;
    std::cout << scores[4] << "\n";          // 66

    // 数组大小（仅对"本作用域数组"有效）
    int n = sizeof(scores) / sizeof(scores[0]);   // 5

    // 遍历
    for (int i = 0; i < n; ++i)
        std::cout << scores[i] << " ";
    std::cout << "\n";

    for (int x : scores)                     // 范围 for 更优雅
        std::cout << x << " ";
    return 0;
}
```

**数组的两大天生局限**：

1. **大小编译期固定**：`int arr[n]`（n 是变量）不是标准 C++（部分编译器扩展支持）
2. **不记录长度**：传给函数后退化成"裸指针"，sizeof 失效

```cpp
void print_arr(int arr[], int size) {        // 数组参数必须附带长度
    // sizeof(arr) 在这里是指针大小（8），不是数组大小！
    for (int i = 0; i < size; ++i)
        std::cout << arr[i] << " ";
}
```

> [!WARNING]
> 数组**不检查越界**：`scores[100]` 编译运行都不报错，直接读写非法内存——未定义行为，可能是乱码、崩溃或安全漏洞。这是 C/C++ 缓冲区溢出漏洞的根源。

### 二维数组

```cpp
int matrix[3][4] = {
    {1,  2,  3,  4},
    {5,  6,  7,  8},
    {9, 10, 11, 12},
};

int rows = 3, cols = 4;
for (int i = 0; i < rows; ++i) {
    for (int j = 0; j < cols; ++j)
        std::cout << matrix[i][j] << "\t";
    std::cout << "\n";
}

// 打擂台找最大值及其位置
int max_v = matrix[0][0], mi = 0, mj = 0;
for (int i = 0; i < rows; ++i)
    for (int j = 0; j < cols; ++j)
        if (matrix[i][j] > max_v) {
            max_v = matrix[i][j]; mi = i; mj = j;
        }
std::cout << "最大 " << max_v << " 在 (" << mi << "," << mj << ")\n";
```

## 二、std::vector：动态数组（现代首选）

### 构造与基本操作

```cpp
#include <vector>
#include <iostream>

int main() {
    std::vector<int> v1;                      // 空
    std::vector<int> v2(5);                   // {0,0,0,0,0}
    std::vector<int> v3(5, 7);                // {7,7,7,7,7}
    std::vector<int> v4 = {1, 2, 3, 4};       // 列表初始化
    std::vector<std::string> names{"小明", "小红"};

    std::cout << v4.size() << "\n";           // 4  元素数
    std::cout << v4.empty() << "\n";          // 0  是否为空

    v4[0] = 100;                              // 修改（同样不查越界）
    std::cout << v4.at(1) << "\n";            // 2  at() 会检查越界并抛异常
    std::cout << v4.front() << " " << v4.back() << "\n";  // 100 4
    return 0;
}
```

### 增删

```cpp
std::vector<int> v = {2, 3};

v.push_back(4);               // 尾部追加：{2,3,4}   —— 最高频操作
v.insert(v.begin(), 1);       // 头部插入：{1,2,3,4}
v.insert(v.begin() + 2, 99);  // 指定位置：{1,2,99,3,4}

v.pop_back();                 // 删除尾部：{1,2,99,3}
v.erase(v.begin() + 2);       // 删除指定位置：{1,2,3}
v.erase(v.begin(), v.begin() + 2);   // 删除区间：{3}

v.clear();                    // 清空：{}
```

**性能提示**：push_back 尾部均摊 O(1)；insert/erase 中间是 O(n)——频繁中间插删的场景后续用 list（进阶）。

### 遍历与修改

```cpp
std::vector<int> v = {5, 3, 8, 1, 9};

// ① 下标循环（需要下标时）
for (std::size_t i = 0; i < v.size(); ++i)   // size() 返回无符号 size_t
    std::cout << v[i] << " ";

// ② 范围 for 只读
for (const auto& x : v) std::cout << x << " ";

// ③ 范围 for 修改
for (auto& x : v) x *= 2;             // 全部翻倍

// 已知量小或有符号运算时，int i 配 static_cast：
for (int i = 0; i < static_cast<int>(v.size()); ++i) { /* ... */ }
```

### 动态增长的实力

```cpp
std::vector<int> v;
for (int i = 1; i <= 100; ++i)
    v.push_back(i * i);        // 数组做不到的"边跑边长"
std::cout << v.size();         // 100
```

### 排序与查找

```cpp
#include <algorithm>

std::vector<int> v = {5, 3, 8, 1, 9};

std::sort(v.begin(), v.end());              // 升序 {1,3,5,8,9}
std::sort(v.begin(), v.end(), std::greater<int>());   // 降序

auto it = std::find(v.begin(), v.end(), 8); // 查找，返回迭代器
if (it != v.end())
    std::cout << "找到，下标 " << (it - v.begin()) << "\n";

// 排序复杂数据（lambda 第四篇提过，第十篇详讲）
std::vector<std::pair<std::string, int>> st{{"小明",90},{"小红",92}};
std::sort(st.begin(), st.end(),
          [](const auto& a, const auto& b) { return a.second > b.second; });
```

## 三、std::string 详解

### 构造与拼接

```cpp
#include <string>

std::string s1 = "hello";
std::string s2("world");
std::string s3(5, 'a');            // "aaaaa" 重复字符
std::string s4 = s1 + " " + s2;    // "hello world"（+ 随便拼）
s4 += "!";                          // 追加

// 数值拼接需先转换（第二篇）：
int age = 18;
std::string info = "年龄: " + std::to_string(age);
```

### 索引与常用方法

```cpp
std::string s = "CyberPioneer";

std::cout << s.size() << "\n";         // 12（size 与 length 等价）
std::cout << s[0] << s.back() << "\n"; // Cr
s[0] = 'c';                            // ✓ 可修改（不同于 Python！）

// 子串：substr(起点, 长度)
std::cout << s.substr(0, 5) << "\n";   // cyber
std::cout << s.substr(5) << "\n";      // Pioneer（到结尾）

// 查找：find 找不到返回 string::npos
if (s.find("Pioneer") != std::string::npos)
    std::cout << "包含 Pioneer，位置 " << s.find("Pioneer") << "\n";

// 修改
std::string t = "  hi  ";
std::cout << "|" << t.substr(1, 2) << "|\n";   // 手动去空格（无现成 strip）

std::string u = "a,b,c";
// 按","分割（STL 惯用法，sstream 第十一篇还会见）
#include <sstream>
std::vector<std::string> parts;
std::stringstream ss(u);
std::string item;
while (std::getline(ss, item, ','))
    parts.push_back(item);          // {"a","b","c"}
```

### 比较

```cpp
std::string a = "apple", b = "banana";
if (a == b) std::cout << "相等";
if (a < b)  std::cout << "a 在前";   // 字典序，直接用比较运算符
int r = a.compare(b);                 // <0 / 0 / >0，与 strcmp 类似
```

### C 字符串互转

```cpp
std::string cpp_s = "hello";
const char* c_s = cpp_s.c_str();     // string → C 串（用于旧接口/printf）

std::string back = c_s;              // C 串 → string 直接构造
```

## 四、数组 vs vector 选型

| 维度 | C 数组 | std::vector |
| --- | --- | --- |
| 大小 | 编译期固定 | 运行期动态 |
| 越界检查 | 无（UB） | `at()` 有 |
| 自带长度 | 否 | `size()` |
| 传参 | 退化指针+手动传长度 | 直接传引用 |
| 性能 | 裸奔最快 | 同量级（多了薄封装） |

**结论**：日常一律 vector；只有"大小确定且追求极致"（嵌入式、竞赛固定槽位）用数组。多维场景用 `std::vector<std::vector<int>>`。

## 五、案例：成绩分析器

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <iomanip>

int main() {
    std::vector<std::pair<std::string, int>> students = {
        {"小明", 90}, {"小红", 85}, {"小刚", 92}, {"小美", 66},
    };

    // 按成绩降序
    std::sort(students.begin(), students.end(),
              [](const auto& a, const auto& b) { return a.second > b.second; });

    // 统计
    int total = 0;
    std::vector<int> scores;
    for (const auto& [name, score] : students) {   // 结构化绑定（C++17）
        total += score;
        scores.push_back(score);
    }

    std::cout << std::fixed << std::setprecision(1);
    std::cout << "平均分: " << total * 1.0 / students.size() << "\n";
    std::cout << "最高: " << scores.front() << " 最低: " << scores.back() << "\n";

    // 挂科名单
    std::cout << "挂科: ";
    for (const auto& [name, score] : students)
        if (score < 60) std::cout << name << " ";
    std::cout << "\n";

    // 前三名
    for (int i = 0; i < 3 && i < static_cast<int>(students.size()); ++i)
        std::cout << "No." << i + 1 << " " << students[i].first
                  << " " << students[i].second << "\n";
}
```

## 小练习

1. 不用 sort：手写选择排序把 `{5,2,8,1}` 升序（双重循环打擂台）
2. vector 去重：先排序，再 `std::unique` + `erase` 三连（查文档实现）
3. 统计一句话中每个单词长度：`"the quick brown fox"` → 3 5 5 3（stringstream 分割）
4. 判断回文字符串（string 下标首尾双指针）
5. 二维 vector 乘法表：`std::vector<std::vector<int>>(9, std::vector<int>(9))` 填充并打印

## 本篇小结

- 数组大小固定、不查越界、传参退化——现代 C++ 默认 vector
- vector：push_back 尾增 O(1)、at() 安全访问、insert/erase 中间 O(n)
- 排序查找认准 `<algorithm>` 的 sort/find
- string 可下标修改、substr 切子串、find 配 `string::npos` 判断
- 分割字符串用 stringstream + getline；C 互转靠 c_str()

**下一篇**：指针与引用——C++ 的深水区，也是它强大的根源。

---

*本系列为 Cyber先锋社原创教程。vector 的每个方法都敲一遍，后面 STL 篇会轻松很多。*
