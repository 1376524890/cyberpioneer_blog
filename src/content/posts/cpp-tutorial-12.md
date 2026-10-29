---
title: C++ 入门教程（十二）：异常处理、文件 IO 与综合实战
published: 2026-10-29
description: 系列收官：C++ 异常体系（throw/try/catch、标准异常层级、自定义异常、 noexcept）、文件流读写（ifstream/ofstream/stringstream）、通讯录项目综合实战与系列总结。
tags: [C++, 编程入门, 教程, 项目实战]
category: C++ 教程
slug: cpp-tutorial-12
series: "C++ 入门教程"
seriesOrder: 12
---

## 本篇目标

最后两块拼图：**异常处理**（出错不崩）与**文件 IO**（数据持久化），随后用一个综合项目收官全系列——做一个支持增删改查、文件持久化的**通讯录管理系统**。

## 一、C++ 异常处理

### 基本语法

```cpp
#include <iostream>
#include <stdexcept>

double safe_divide(double a, double b) {
    if (b == 0)
        throw std::invalid_argument("除数不能为零");   // 抛出异常对象
    return a / b;
}

int main() {
    try {
        std::cout << safe_divide(10, 2) << "\n";     // 5
        std::cout << safe_divide(1, 0) << "\n";      // 这里抛出
        std::cout << "永远执行不到\n";
    }
    catch (const std::invalid_argument& e) {          // 按类型捕获
        std::cout << "参数错误: " << e.what() << "\n";
    }
    catch (const std::exception& e) {                 // 基类兜底（顺序：子类在前！）
        std::cout << "其他异常: " << e.what() << "\n";
    }
    catch (...) {                                     // 万能兜底
        std::cout << "未知异常\n";
    }
}
```

**与 Python 的差异**：C++ 用对象抛出（不是字符串）、按**类型**匹配 catch、catch 顺序敏感（子类必须放基类前面）。

### 标准异常层级（<stdexcept>）

```text
std::exception                 ← 所有标准异常的基类
├── logic_error                ← 程序逻辑错误（可预防）
│   ├── invalid_argument       参数非法
│   ├── out_of_range           下标越界（vector::at 抛的就是它）
│   └── length_error           超长
└── runtime_error              ← 运行期才能发现
    ├── overflow_error         算术上溢
    ├── underflow_error        下溢
    └── range_error            值域错误

另有：bad_alloc（new 失败，<new>）、bad_cast（<typeinfo>）
```

### 自定义异常

```cpp
#include <stdexcept>
#include <string>

class InsufficientFundsError : public std::runtime_error {
    double shortfall_;
public:
    explicit InsufficientFundsError(double shortfall)
        : std::runtime_error("余额不足，还差 " + std::to_string(shortfall) + " 元")
        , shortfall_(shortfall) {}

    double shortfall() const { return shortfall_; }   // 附带业务数据
};

void withdraw(double balance, double amount) {
    if (amount > balance)
        throw InsufficientFundsError(amount - balance);
    // ...
}

int main() {
    try { withdraw(100, 150); }
    catch (const InsufficientFundsError& e) {
        std::cout << e.what() << "\n";          // 余额不足，还差 50.000000 元
        std::cout << "缺口: " << e.shortfall(); // 附带数据
    }
}
```

### noexcept 与栈展开

```cpp
// noexcept 承诺"此函数不抛异常"——编译器可优化，违诺直接 std::terminate
void pure_compute(int x) noexcept { /* 不抛任何东西 */ }

// 异常抛出时的"栈展开"：沿途所有局部对象析构函数被依次调用
// → RAII 对象在异常路径同样安全释放（这就是 RAII 伟大的原因）
void demo() {
    FileLogger log("app.log");     // 第八篇的 RAII 类
    throw std::runtime_error("boom");
}   // log 的析构依然执行，文件被正确关闭！
```

**异常安全军规**：资源交给 RAII 对象管理，异常来了自动清理；不要在析构函数里抛异常。

## 二、文件 IO

### 文本文件：ifstream / ofstream

```cpp
#include <fstream>
#include <iostream>
#include <string>

int main() {
    // —— 写文件（ofstream）——
    std::ofstream out("diary.txt");           // 默认覆盖模式
    if (!out) {                               // 检查打开是否成功！
        std::cerr << "无法创建文件\n";
        return 1;
    }
    out << "2026-10-29 学完 C++ 文件IO\n";
    out << "今天写了 " << 3 << " 个模块\n";
    out.close();                              // 可显式关，析构也会关

    // 追加模式
    std::ofstream append("diary.txt", std::ios::app);
    append << "追加一行\n";

    // —— 读文件（ifstream）——
    std::ifstream in("diary.txt");
    if (!in) { std::cerr << "文件不存在\n"; return 1; }

    std::string line;
    while (std::getline(in, line))            // 逐行读（自动去 \n）
        std::cout << "> " << line << "\n";

    // 第二种：流提取（按空格分词）
    std::ifstream in2("diary.txt");
    std::string word;
    while (in2 >> word)
        std::cout << word << "\n";
}
```

### 状态检查与打开模式

| 模式 | 含义 |
| --- | --- |
| `std::ios::in` | 读 |
| `std::ios::out` | 写（截断） |
| `std::ios::app` | 追加 |
| `std::ios::ate` | 打开即定位到末尾 |
| `std::ios::binary` | 二进制模式 |

```cpp
std::ifstream f("data.txt");
if (!f.is_open()) { /* 打不开 */ }
if (f.eof())  { /* 读到文件尾 */ }
f.clear();                                 // 清除错误状态（重读前）
```

### stringstream：内存中的流（第五篇分割的完整版）

```cpp
#include <sstream>

// 字符串 → 数值：split 一行 CSV
std::string line = "小明,18,90.5";
std::stringstream ss(line);
std::string name; int age; double score;
std::getline(ss, name, ',');
ss >> age; ss.ignore(1, ',');     // 跳过逗号
ss >> score;

// 数值 → 字符串（to_string 之外的格式化方式）
std::ostringstream os;
os << "成绩: " << std::fixed << std::setprecision(1) << score;
std::string result = os.str();
```

## 三、综合实战：通讯录管理系统

全系列知识集大成：struct + vector + STL 算法 + 异常 + 文件持久化 + 菜单循环。

```cpp
// ===== contacts.cpp 完整可编译运行 =====
// g++ contacts.cpp -o contacts -std=c++17
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
#include <algorithm>
#include <iomanip>

struct Contact {
    std::string name;
    std::string phone;
    std::string group;      // 分组：朋友/家人/同学...
};

class ContactBook {
    std::vector<Contact> data_;
    const std::string path_ = "contacts.txt";

public:
    class ContactError : public std::runtime_error {
    public: using std::runtime_error::runtime_error;
    };

    ContactBook() { load(); }
    ~ContactBook() { save(); }

    void add(const std::string& name, const std::string& phone,
             const std::string& group) {
        if (name.empty()) throw ContactError("姓名不能为空");
        if (find(name))   throw ContactError("联系人已存在: " + name);
        data_.push_back({name, phone, group});
    }

    bool remove(const std::string& name) {
        auto it = std::remove_if(data_.begin(), data_.end(),
            [&](const Contact& c){ return c.name == name; });
        if (it == data_.end()) return false;
        data_.erase(it, data_.end());            // erase-remove 惯用法
        return true;
    }

    const Contact* find(const std::string& name) const {
        auto it = std::find_if(data_.begin(), data_.end(),
            [&](const Contact& c){ return c.name == name; });
        return it == data_.end() ? nullptr : &*it;
    }

    void list_by_group() const {                 // 分组有序输出
        std::map<std::string, std::vector<std::string>> groups;
        for (const auto& c : data_)
            groups[c.group].push_back(c.name + " (" + c.phone + ")");

        for (const auto& [g, names] : groups) {
            std::cout << "【" << g << "】\n";
            for (const auto& n : names) std::cout << "  " << n << "\n";
        }
    }

    void search(const std::string& keyword) const {   // 模糊查找
        std::cout << "搜索 \"" << keyword << "\":\n";
        for (const auto& c : data_)
            if (c.name.find(keyword) != std::string::npos ||
                c.phone.find(keyword) != std::string::npos)
                std::cout << "  " << c.name << " " << c.phone
                          << " [" << c.group << "]\n";
    }

    size_t size() const { return data_.size(); }

private:
    void load() {                                // 每行: name,phone,group
        std::ifstream in(path_);
        if (!in) return;
        std::string line;
        while (std::getline(in, line)) {
            std::stringstream ss(line);
            std::string n, p, g;
            if (std::getline(ss, n, ',') &&
                std::getline(ss, p, ',') &&
                std::getline(ss, g))
                data_.push_back({n, p, g});
        }
    }
    void save() const {
        std::ofstream out(path_);                // 覆盖重写
        for (const auto& c : data_)
            out << c.name << "," << c.phone << "," << c.group << "\n";
    }
};

int main() {
    ContactBook book;

    std::cout << "=== 通讯录 ===\n"
              << "add 名字 电话 分组 | del 名字 | find 名字 | "
                 "search 关键词 | list | quit\n";

    std::string cmd;
    while (true) {
        std::cout << "\n> ";
        if (!(std::cin >> cmd)) break;

        try {
            if (cmd == "quit") break;
            else if (cmd == "add") {
                std::string n, p, g;
                std::cin >> n >> p >> g;
                book.add(n, p, g);
                std::cout << "✅ 已添加 " << n << "（共 " << book.size() << " 人）\n";
            }
            else if (cmd == "del") {
                std::string n; std::cin >> n;
                std::cout << (book.remove(n) ? "🗑 已删除" : "没找到") << "\n";
            }
            else if (cmd == "find") {
                std::string n; std::cin >> n;
                const Contact* c = book.find(n);
                if (c) std::cout << c->name << " " << c->phone
                                 << " [" << c->group << "]\n";
                else   std::cout << "没找到\n";
            }
            else if (cmd == "search") { std::string k; std::cin >> k; book.search(k); }
            else if (cmd == "list")   { book.list_by_group(); }
            else std::cout << "未知命令\n";
        }
        catch (const ContactBook::ContactError& e) {
            std::cout << "❌ " << e.what() << "\n";
        }
    }
    std::cout << "数据已保存，再见！\n";      // 析构也会 save
}
```

**用到的知识点清单**：struct、class 封装、vector + 算法（find_if/remove_if）、map 分组、异常（自定义 + try/catch）、文件读写（ifstream/ofstream）、stringstream 解析、RAII（析构自动保存）。

**运行演示**：

```text
> add 小明 138xxxx 同学
✅ 已添加 小明（共 1 人）
> add 小红 139xxxx 家人
✅ 已添加 小红（共 2 人）
> add 小明 137xxxx 朋友
❌ 联系人已存在: 小明
> list
【同学】
  小明 (138xxxx)
【家人】
  小红 (139xxxx)
> quit
数据已保存，再见！
```

## 四、系列总结

| 篇 | 主题 | 关键收获 |
| --- | --- | --- |
| 1 | 环境与第一个程序 | g++ 编译流程、main、cout/cin |
| 2 | 语法与运算符 | 七类运算、类型转换、cin 校验 |
| 3 | 流程控制 | switch/循环/范围 for/经典练习 |
| 4 | 函数 | 声明定义分离、三种传参、重载、默认参数 |
| 5 | 数组与字符串 | 数组局限、vector/string 全家桶 |
| 6 | 指针与引用 | 内存模型、new/delete、智能指针 |
| 7 | 结构体与枚举 | 自定义类型、enum class |
| 8 | 面向对象（上） | 封装、构造析构、三法则、RAII |
| 9 | 面向对象（下） | 继承、虚函数多态、抽象类、虚析构 |
| 10 | 运算符重载 | 算术/流/下标重载、友元 |
| 11 | STL | 容器选型、迭代器、算法库 |
| 12 | 异常/IO/实战（本篇） | try/catch、文件流、综合项目 |

**下一步**：数据结构与算法（用 C++ 实现一遍链表/栈/队列/树）、或挑战小型项目（JSON 解析器、简易 HTTP 服务器、贪吃蛇）。做出作品欢迎投稿本站！

## 小练习（毕业设计）

1. 通讯录加"修改"命令（update 名字 新电话）与"导入导出 CSV"
2. 把通讯录数据改成 JSON 风格存储（自己设计转义规则）
3. 用 class 重写第三篇猜数字为 `GuessGame` 类，含 `play()` 与统计功能

---

*本系列为 Cyber先锋社原创教程，共 12 篇完结。欢迎在留言板晒出你的毕业设计！*
