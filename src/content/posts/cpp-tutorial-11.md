---
title: C++ 入门教程（十一）：STL 标准模板库
published: 2026-10-29
description: 系统遍历 STL 三大件：容器（vector/deque/list/map/set/unordered）选型对比、迭代器体系与常用算法（sort/find/count/accumulate/for_each/remove），附词频统计与成绩系统综合案例。
tags: [C++, 编程入门, 教程, STL]
category: C++ 教程
slug: cpp-tutorial-11
series: "C++ 入门教程"
seriesOrder: 11
---

## 本篇目标

**STL（Standard Template Library）** 是 C++ 自带的"兵器库"：6+ 种容器、几十个算法、通用迭代器粘合两者。学完本篇，你写 C++ 的效率会翻倍——不再手写链表、排序、查找，组合现成部件即可。

## 一、STL 全景图

```text
STL 三大件：
├── 容器（Containers）：存数据    vector / list / map / set ...
├── 迭代器（Iterators）：胶水     统一遍历所有容器的方式
└── 算法（Algorithms）：处理数据  sort / find / count / accumulate ...
+ 仿函数 & lambda：算法的"策略参数"
```

头文件速记：容器各有头（`<vector>` `<map>`...），算法统一 `<algorithm>`，数值算法 `<numeric>`。

## 二、顺序容器

### vector（复习+补强）

```cpp
#include <vector>

std::vector<int> v{3, 1, 4};
v.push_back(5);
v.reserve(100);            // 预留容量，避免反复扩容拷贝
std::cout << v.capacity() << " " << v.size();   // 100 4
```

### deque：双端队列

```cpp
#include <deque>

std::deque<int> dq{2, 3};
dq.push_front(1);      // 头部 O(1)！
dq.push_back(4);       // {1,2,3,4}
dq.pop_front();        // {2,3,4}
```

vs vector：头插头删 O(1)，但内存不连续（缓存稍差）。需要双端操作选它。

### list：双向链表

```cpp
#include <list>

std::list<int> lst{1, 2, 4};
auto it = std::next(lst.begin());      // 指向 2
lst.insert(it, 3);                     // {1,2→3,4} 任意位置 O(1)
lst.remove(2);                         // 按值删
lst.sort();                            // list 自带 sort（std::sort 不支持它）
lst.splice(lst.end(), another_list);   // O(1) 拼接另一链表
```

**list 的取舍**：中间插删 O(1) 但不支持随机访问 `[i]`（要 O(n) 走链）、缓存不友好。**90% 场景 vector 更快**——包括"中间插删"（vector 移动内存飞快），实测再说。

### 顺序容器对比

| | vector | deque | list |
| --- | --- | --- | --- |
| 随机访问 | O(1) | O(1) | O(n) |
| 头插删 | O(n) | O(1) | O(1) |
| 中间插删 | O(n) | O(n) | **O(1)**（有迭代器） |
| 内存 | 连续 | 分块 | 节点散布 |
| 默认选择 | ⭐ | 双端需求 | 特殊链表需求 |

## 三、关联容器

### map：有序键值对（红黑树）

```cpp
#include <map>
#include <string>

std::map<std::string, int> ages;

// 插入三种方式
ages["小明"] = 18;                          // 不存在则插入，存在则覆盖
ages.insert({"小红", 17});
ages.emplace("小刚", 19);                    // 原地构造（推荐）

// 安全访问：at 越界抛异常，[] 越界会"悄悄创建"！
try { ages.at("不存在"); } catch (const std::out_of_range&) { }
int cnt = ages.count("小明");                // 0 或 1
// ages["不存在的键"];                       // ⚠ 危险：会插入默认值！

// 遍历（按键自动排序）
for (const auto& [name, age] : ages)        // 结构化绑定
    std::cout << name << " " << age << "\n";

// 查找
if (auto it = ages.find("小明"); it != ages.end())
    std::cout << it->second << "\n";
```

> [!WARNING]
> `map::operator[]` 对不存在的键**会插入默认值**——只读查询场景永远用 `find` 或 `count`，这是 map 的第一大坑。

### set：有序去重集合

```cpp
#include <set>

std::set<int> s{3, 1, 4, 1, 5};         // {1,3,4,5} 自动去重排序
s.insert(2);
s.erase(1);

if (s.count(3)) std::cout << "3 在集合\n";
std::cout << s.size();                   // 4
```

### unordered_map / unordered_set（哈希表）

```cpp
#include <unordered_map>

std::unordered_map<std::string, int> fast;
fast["apple"] = 5;
// 接口与 map 完全一致！区别在实现：
// map         红黑树   查找 O(log n)   键有序遍历
// unordered   哈希表   查找 O(1) 均摊  遍历无序
```

**选型**：需要有序遍历/范围查询用 map/set；纯查找用 unordered（更快，日常默认）。

### multimap / multiset

允许重复键：`std::multimap<std::string, int>` 一个键多个值（如一个学生多门课成绩）。

## 四、迭代器

### 统一的遍历语法

```cpp
std::vector<int> v{1,2,3};
std::map<std::string,int> m{{"a",1}};

for (auto it = v.begin(); it != v.end(); ++it)
    std::cout << *it;

for (const auto& [k, val] : m)      // 范围 for 底层就是迭代器
    std::cout << k << val;
```

### 常用操作

```cpp
std::vector<int> v{10, 20, 30, 40, 50};

auto it = v.begin();
std::advance(it, 2);                    // 前进 2 → 指向 30
int d = std::distance(v.begin(), it);   // 2
auto it2 = std::next(v.begin());        // 第二个（原迭代器不动）
auto it3 = std::prev(v.end());          // 最后一个

// ⚠ 迭代器失效头号场景：边遍历边删
// for (auto it = v.begin(); it != v.end(); ++it)
//     if (*it % 2) v.erase(it);        // ❌ erase 后 it 失效！

// ✅ 正确姿势：用 erase 的返回值
for (auto it = v.begin(); it != v.end(); )
    if (*it % 2 != 0) it = v.erase(it);     // erase 返回下一个有效迭代器
    else ++it;
```

## 五、算法库（<algorithm> / <numeric>）

### 查找与统计

```cpp
#include <algorithm>
#include <numeric>

std::vector<int> v{3, 1, 4, 1, 5, 9, 2, 6};

std::find(v.begin(), v.end(), 5);            // 找值，end()=没找到
std::count(v.begin(), v.end(), 1);           // 2
std::accumulate(v.begin(), v.end(), 0);      // 31 求和（<numeric>）
std::max_element(v.begin(), v.end());        // 指向 9 的迭代器
std::minmax_element(v.begin(), v.end());     // pair<min_it, max_it>

// 条件版
auto cnt_even = std::count_if(v.begin(), v.end(),
                              [](int x){ return x % 2 == 0; });
auto it_big = std::find_if(v.begin(), v.end(),
                           [](int x){ return x > 5; });
```

### 排序与变换

```cpp
std::sort(v.begin(), v.end());                          // 升序
std::sort(v.begin(), v.end(), std::greater<int>());     // 降序
std::stable_sort(...);                                  // 稳定（相等保持原序）
std::partial_sort(v.begin(), v.begin()+3, v.end());     // 只排前 3

std::reverse(v.begin(), v.end());
std::transform(v.begin(), v.end(), v.begin(),           // 原地变换
               [](int x){ return x * x; });

std::vector<int> dst(v.size());
std::copy(v.begin(), v.end(), dst.begin());
```

### 经典三连：remove + erase 真删除

```cpp
// remove 只把"要删的"挪到末尾，返回新逻辑末尾——容器 size 不变！
auto new_end = std::remove_if(v.begin(), v.end(),
                              [](int x){ return x < 3; });
v.erase(new_end, v.end());      // 真正删除（erase-remove 惯用法）
```

### 二分查找（需先有序）

```cpp
std::sort(v.begin(), v.end());
bool found = std::binary_search(v.begin(), v.end(), 5);   // 是否存在
auto lb = std::lower_bound(v.begin(), v.end(), 5);        // 第一个 >= 5
auto ub = std::upper_bound(v.begin(), v.end(), 5);        // 第一个 > 5
std::cout << ub - lb << "\n";                             // 值 5 的个数
```

## 六、综合案例

### 1. 词频统计（map 的主场）

```cpp
#include <map>
#include <sstream>
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    std::string text = "the quick the lazy the dog and the end";
    std::map<std::string, int> freq;

    std::istringstream ss(text);
    std::string word;
    while (ss >> word) ++freq[word];        // 一行完成计数！

    // 按次数降序输出：搬进 vector 排序
    std::vector<std::pair<std::string, int>> items(freq.begin(), freq.end());
    std::sort(items.begin(), items.end(),
              [](const auto& a, const auto& b){ return a.second > b.second; });

    for (const auto& [w, c] : items)
        std::cout << w << ": " << c << "\n";
}
```

### 2. 学生成绩系统（多容器协作）

```cpp
struct Record { std::string name; int score; };

int main() {
    std::vector<Record> records = {
        {"小明", 90}, {"小红", 85}, {"小刚", 92}, {"小红", 88},   // 小红两次
    };

    // 1. 总分与平均（accumulate + lambda 初始化值注意类型）
    int total = std::accumulate(records.begin(), records.end(), 0,
        [](int sum, const Record& r){ return sum + r.score; });
    std::cout << "平均 " << total / double(records.size()) << "\n";

    // 2. 每人最高分（map<string,int>）
    std::map<std::string, int> best;
    for (const auto& r : records)
        best[r.name] = std::max(best[r.name], r.score);   // 默认 0 起步

    // 3. 排名（拷贝+排序，不破坏原序）
    auto ranked = records;
    std::sort(ranked.begin(), ranked.end(),
              [](const Record& a, const Record& b){ return a.score > b.score; });

    // 4. 及格人数
    auto passed = std::count_if(records.begin(), records.end(),
                                [](const Record& r){ return r.score >= 60; });
}
```

## 七、容器选型决策表

| 需求 | 容器 |
| --- | --- |
| 动态数组（默认） | `vector` |
| 双端频繁插删 | `deque` |
| 键值查找（默认） | `unordered_map` |
| 键值 + 有序遍历 | `map` |
| 去重集合（默认） | `unordered_set` |
| 有序集合/排行 | `set` |
| 一键多值 | `multimap` / `unordered_map<K, vector<V>>` |
| 优先队列（堆） | `priority_queue`（进阶了解） |

## 小练习

1. 用 `map<char,int>` 统计字符串各字符出现次数，输出出现最多的字符
2. 两个小组名单合并去重：`vector<string>` + `sort` + `unique` + `erase`
3. 用 `erase-remove` 惯用法删除 vector 中所有负数
4. 用 `accumulate` 计算字符串向量所有元素的总长度
5. 模拟"商品库存"：unordered_map<string,int>，支持进货、售出（减到 0 提示缺货）、按名称排序输出全部

## 本篇小结

- 顺序容器默认 vector；关联容器默认 unordered 系列；有序需求才 map/set
- `map[]` 会插入默认值，只读用 find/count
- 迭代器是容器与算法的胶水；erase 返回值防迭代器失效
- 算法库三板斧：sort/count_if/accumulate + find_if/max_element
- 真删除用 erase-remove 惯用法；二分先排序
- 组合容器+算法，绝大多数需求无需手写数据结构

**下一篇**：异常处理与文件 IO——系列的收官与综合实战。

---

*本系列为 Cyber先锋社原创教程。STL 的熟练度 = C++ 的日常生产力，练习 5 的库存系统务必完整实现。*
