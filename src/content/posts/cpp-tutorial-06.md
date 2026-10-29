---
title: C++ 入门教程（六）：指针与引用
published: 2026-10-29
description: 征服 C++ 深水区：内存模型与地址、指针定义解引用、指针与数组、动态内存 new/delete、悬空指针与内存泄漏、引用与指针对比、智能指针 unique_ptr/shared_ptr 入门。
tags: [C++, 编程入门, 教程, 指针]
category: C++ 教程
slug: cpp-tutorial-06
series: "C++ 入门教程"
seriesOrder: 6
---

## 本篇目标

指针是 C++ 的分水岭：理解了它，才算真正理解"程序如何在内存中运行"。本篇从内存模型讲起，覆盖裸指针、动态内存、引用对比与智能指针入门。**请逐个示例亲手运行**——这一篇没有捷径。

## 一、内存模型：变量住在哪里

```cpp
int age = 18;
```

这行代码发生的事：程序在**栈内存**里划出 4 字节，存入 18，并把这块空间标记为 `age`。

每块内存都有编号——**地址**（一串十六进制数）。`&` 取地址运算符可以拿到它：

```cpp
#include <iostream>
int main() {
    int age = 18;
    std::cout << &age << "\n";      // 0x7ffee4c0a8bc（每次运行可能不同）
    std::cout << sizeof(age);       // 4 字节
}
```

**类比**：内存是一整条街的房间，变量是房间里的住户，地址是门牌号。

## 二、指针：存地址的变量

### 定义与解引用

```cpp
int age = 18;
int* p = &age;          // p 是指针，存的是 age 的地址

std::cout << p << "\n";     // 地址：0x7ffee4c0a8bc
std::cout << *p << "\n";    // 18：* 解引用——顺着地址找到值
std::cout << &p << "\n";    // p 自己的地址（指针也是变量）

*p = 20;                    // 通过地址改写 age！
std::cout << age << "\n";   // 20
```

**两个符号记牢**：

- `&x`：取 x 的**地址**
- `*p`：顺 p 存的地址**取值**（或写入）

```cpp
int* p1, p2;        // ⚠ 坑：p1 是指针，p2 是 int！
int *p3, *p4;       // 两个都是指针
```

### 空指针与安全

```cpp
int* p = nullptr;       // C++11 空指针（替代 NULL 与 0）

if (p != nullptr) {
    std::cout << *p;    // 用前判空
}
// *p;                  // ❌ 解引用空指针 = 段错误（Segfault），程序崩溃
```

> [!WARNING]
> 永远不要解引用空指针或未初始化的指针（野指针）。现代写法：定义指针就初始化（给值或给 nullptr）。

### 指针作为函数参数

C 风格的"修改实参"方式（C++ 更推荐引用，但必须会读）：

```cpp
void swap(int* a, int* b) {      // 接收地址
    int t = *a;                  // 通过地址取值
    *a = *b;                     // 通过地址写值
    *b = t;
}

int main() {
    int x = 1, y = 2;
    swap(&x, &y);                // 传地址
    std::cout << x << "," << y;  // 2,1
}
```

### 指针与数组

数组名本质是"首元素地址"：

```cpp
int arr[] = {10, 20, 30, 40};
int* p = arr;                    // 等价于 &arr[0]

std::cout << *p << "\n";         // 10
std::cout << *(p + 1) << "\n";   // 20：指针算术，+1 移动一个 int
std::cout << p[2] << "\n";       // 30：指针也能用下标（等价 *(p+2)）

// 遍历
for (int* q = arr; q != arr + 4; ++q)
    std::cout << *q << " ";
```

**指针算术**：`p + 1` 移动的字节数 = 指向类型的大小（int* 移 4 字节，double* 移 8 字节）。

## 三、动态内存：new / delete

栈上的变量函数结束自动销毁；**堆内存**由你手动管理——能跨函数存活、大小运行期决定。

```cpp
// 单个变量
int* p = new int(42);            // 堆上开 4 字节，初始化 42
std::cout << *p << "\n";
delete p;                        // 手动释放！
p = nullptr;                     // 置空好习惯

// 动态数组（大小可以是变量！）
int n;
std::cin >> n;
int* arr = new int[n]{};         // n 个 int 全 0
for (int i = 0; i < n; ++i) arr[i] = i * i;
delete[] arr;                    // 数组用 delete[]
```

**两条铁律**：

1. 每个 `new` 必须对应一个 `delete`（数组 `delete[]`）
2. `delete` 后指针置 `nullptr`，防止"悬空指针"再次使用

### 内存泄漏：忘记 delete

```cpp
void leak() {
    int* p = new int(100);
    // 函数结束，p 这个"门牌号"没了，但堆上 4 字节还占着——永远无法释放
}   // 💥 内存泄漏

void worse() {
    int* p = new int(1);
    p = new int(2);              // 第一个内存块地址丢失，泄漏！
    delete p;
}
```

长期运行的服务（服务器程序）泄漏累积会耗尽内存——这是裸 new/delete 逐渐被弃用的原因。

## 四、引用 vs 指针

| 维度 | 引用 `int& r = x` | 指针 `int* p = &x` |
| --- | --- | --- |
| 本质 | 变量的别名 | 存地址的变量 |
| 初始化 | **必须**初始化，不可换绑 | 可空、可改指向 |
| 空值 | 不存在 | nullptr |
| 用法 | 直接当原变量用 | 需 `*` 解引用 |
| 安全性 | 高 | 低（野指针/泄漏） |

```cpp
int x = 10;

int& r = x;          // r 就是 x 的第二个名字
r = 99;              // x 变 99
// int& bad;         // ❌ 引用必须初始化

int* p = &x;         // p 指向 x
p = nullptr;         // ✓ 指针可以为空
int y = 5;
p = &y;              // ✓ 指针可换指向
```

**选择**：能用引用就用引用（安全简洁）；需要"可能为空"或"改指向"才用指针。

## 五、智能指针（现代 C++ 的答案）

C++11 用智能指针把 new/delete 交给对象自动管理——**RAII**：资源获取即初始化，析构自动释放。

### unique_ptr：独占所有权

```cpp
#include <memory>
#include <iostream>

int main() {
    // make_unique 创建（C++14）
    std::unique_ptr<int> p = std::make_unique<int>(42);

    std::cout << *p << "\n";     // 像普通指针一样用
    // 离开作用域自动 delete，无需也无法手动 delete

    // auto q = p;               // ❌ unique 不可拷贝（独占）
    auto q = std::move(p);       // ✓ 只能转移所有权（p 变空）
    if (!p) std::cout << "p 已交出\n";
    std::cout << *q << "\n";
}   // q 析构 → 自动释放内存
```

### shared_ptr：共享所有权（计数引用）

```cpp
#include <memory>

auto a = std::make_shared<int>(100);   // 引用计数 = 1
{
    auto b = a;                        // 计数 = 2，可以拷贝
    std::cout << *b << "\n";
}                                      // b 销毁，计数 = 1
std::cout << a.use_count() << "\n";    // 1
// a 销毁时计数归零 → 内存自动释放
```

**选型**：默认 unique_ptr；确实多方持有才 shared_ptr。

## 六、实战：链表节点（指针的第一次真实应用）

```cpp
#include <iostream>

struct Node {              // 结构体第八篇详讲，先看用法
    int data;
    Node* next;            // 指向下一个节点——链表的骨架
};

int main() {
    // 用 new 造三个节点
    Node* head = new Node{1, nullptr};
    head->next = new Node{2, nullptr};      // -> 通过指针访问成员
    head->next->next = new Node{3, nullptr};

    // 遍历
    for (Node* cur = head; cur != nullptr; cur = cur->next)
        std::cout << cur->data << " -> ";
    std::cout << "null\n";

    // 逐个释放（防泄漏）
    Node* cur = head;
    while (cur != nullptr) {
        Node* next = cur->next;    // 先记住下一个
        delete cur;                // 再释放当前
        cur = next;
    }
}
```

这个例子同时展示了：堆分配、`->` 运算符、指针串联结构、手动释放顺序。以后用 `std::unique_ptr<Node> next` 重写它，就是现代 C++ 风格。

## 小练习

1. 写 `int* find_max(int* arr, int n)` 返回最大元素的**地址**（不是值）
2. 用 new 申请一个 `double` 数组存 10 个成绩，输出平均分后正确 delete
3. 验证"值传递不改原值、指针与引用传递改原值"：同一功能写三个版本对比
4. 用 unique_ptr 管理一个动态 int 数组（`std::unique_ptr<int[]> arr{new int[5]{}}`），体会自动释放
5. （概念题）`int* p = new int(5); delete p; std::cout << *p;` 会发生什么？（悬空指针，未定义行为——说说为什么不能这么写）

## 本篇小结

- `&` 取地址、`*p` 解引用；指针存地址，是"携带门牌号的变量"
- 数组名≈首元素地址，指针算术按类型大小移动
- new/delete 手动管理堆：一一配对、delete 后置空、防泄漏
- 引用是必须初始化的别名，优先用引用；可为空/换指向才用指针
- 现代 C++ 用 unique_ptr/shared_ptr 自动管理内存（RAII）
- `->` 是"指针访问成员"的语法糖

**下一篇**：结构体与枚举——把相关数据打包成自定义类型。

---

*本系列为 Cyber先锋社原创教程。指针是 C++ 的门槛也是魅力：内存模型想通了，后面豁然开朗。*
