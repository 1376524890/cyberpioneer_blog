---
title: Java 入门教程（八）：集合框架
published: 2026-10-29
description: 系统讲解 Java 集合体系：List（ArrayList/LinkedList）、Set（HashSet/TreeSet/LinkedHashSet）、Map（HashMap/TreeMap）核心操作与选型、迭代与 fail-fast、Comparable 与 Comparator 排序、集合工具类，附词频统计与成绩系统案例。
tags: [Java, 编程入门, 教程, 集合框架]
category: 编程教程
slug: java-tutorial-08
series: "Java 入门教程"
seriesOrder: 8
---

## 本篇目标

数组定长，集合（Collection）动态——Java 集合框架是日常开发的绝对主力（前几篇已偷偷用过 ArrayList）。本篇系统讲透 List/Set/Map 三大体系与排序方案。

## 一、集合体系全景

```text
Collection（接口）
├── List   有序可重复
│   ├── ArrayList      动态数组（默认选择）
│   └── LinkedList     双向链表
├── Set    不可重复
│   ├── HashSet        哈希（最快，无序）
│   ├── LinkedHashSet  哈希 + 保插入序
│   └── TreeSet        红黑树（自动排序）
└── Queue  队列（了解）

Map（接口，独立于 Collection）
├── HashMap           哈希键值对（默认选择）
├── LinkedHashMap     保插入序
└── TreeMap           按键排序
```

**泛型 `<T>`**：集合声明元素类型，编译期防类型错误——`List<String>` 只能装 String。

## 二、List

### ArrayList（默认选择）

```java
import java.util.ArrayList;
import java.util.List;

List<String> langs = new ArrayList<>();

// —— 增 ——
langs.add("Java");                       // 尾部追加
langs.add(0, "C++");                     // 指定位置（O(n)）
langs.addAll(List.of("Python", "Go"));   // 批量

// —— 删 ——
langs.remove("Go");                      // 按对象删第一个
langs.remove(0);                         // 按下标删（返回被删元素）
langs.removeIf(s -> s.startsWith("P"));  // 条件删除（Java 8+）

// —— 改查 ——
langs.set(0, "Java17");
String first = langs.get(0);             // O(1) 随机访问
System.out.println(langs.contains("C++"));
System.out.println(langs.indexOf("Java"));
System.out.println(langs.size());
System.out.println(langs.isEmpty());

// —— 遍历 ——
for (String lang : langs) { }                    // 增强 for
for (int i = 0; i < langs.size(); i++) { }       // 下标
langs.forEach(s -> System.out.println(s));       // 函数式

// —— 不可变集合（Java 9+）——
List<String> frozen = List.of("a", "b");         // 不可增删改！
```

### ArrayList vs LinkedList

| | ArrayList | LinkedList |
| --- | --- | --- |
| 随机访问 | O(1) | O(n) |
| 尾部增删 | 均摊 O(1) | O(1) |
| 中间增删 | O(n) | 定位 O(n) + 修改 O(1) |
| 实践建议 | **99% 场景** | 极少胜出 |

### 安全删除：ConcurrentModificationException

```java
List<Integer> nums = new ArrayList<>(List.of(1, 2, 3, 4));

// ❌ 遍历中直接 remove → ConcurrentModificationException（fail-fast）
// for (Integer n : nums) { if (n % 2 == 0) nums.remove(n); }

// ✅ 三种正确姿势
nums.removeIf(n -> n % 2 == 0);                       // ① 条件删除（最简）
for (Iterator<Integer> it = nums.iterator(); it.hasNext(); ) {   // ② 迭代器
    if (it.next() % 2 == 0) it.remove();
}
// ③ 倒序下标循环（正序会跳元素）
```

## 三、Set

```java
import java.util.*;

// HashSet：去重最快（依赖 hashCode/equals）
Set<String> tags = new HashSet<>();
tags.add("java");
tags.add("python");
tags.add("java");                         // 重复添加被忽略
System.out.println(tags.size());          // 2
System.out.println(tags.contains("java")); // true

// 列表去重一行流
List<Integer> dup = new ArrayList<>(List.of(3, 1, 3, 2, 1));
Set<Integer> uniq = new LinkedHashSet<>(dup);    // 保序去重
System.out.println(uniq);                 // [3, 1, 2]

// TreeSet：自动排序
Set<Integer> sorted = new TreeSet<>(List.of(5, 1, 4));
System.out.println(sorted);               // [1, 4, 5]
// 首尾与范围
TreeSet<Integer> ts = new TreeSet<>(List.of(1, 3, 5, 7, 9));
System.out.println(ts.first() + " " + ts.last());   // 1 9
System.out.println(ts.headSet(5));       // [1, 3]（小于5）
System.out.println(ts.tailSet(5));       // [5, 7, 9]
System.out.println(ts.floor(6));         // 5（≤6 的最大）
```

**自定义对象入 HashSet/HashMap 的前提**：正确重写 `hashCode` + `equals`（第六篇）——忘了重写，"相等"的两个对象会被当成两个存两份。

## 四、Map

### HashMap（默认选择）

```java
import java.util.HashMap;
import java.util.Map;

Map<String, Integer> ages = new HashMap<>();

// —— 增改 ——
ages.put("小明", 18);                     // 不存在则增，存在则改（返回旧值！）
ages.putIfAbsent("小红", 17);             // 不存在才放
ages.put("小明", 19);                     // 覆盖为 19

// —— 查 ——
int age = ages.get("小明");               // 19
Integer none = ages.get("不存在");        // null
int def = ages.getOrDefault("不存在", 0); // 0（推荐！防 null）

System.out.println(ages.containsKey("小明"));
System.out.println(ages.containsValue(19));

// —— 删 ——
ages.remove("小红");
ages.remove("小明", 19);                  // 键值都对上才删

// —— 遍历三式 ——
for (String key : ages.keySet()) { }                  // 遍历键
for (Integer val : ages.values()) { }                 // 遍历值
for (Map.Entry<String, Integer> e : ages.entrySet()) // 键值对（最常用）
    System.out.println(e.getKey() + " = " + e.getValue());

// Java 8+ 函数式遍历
ages.forEach((k, v) -> System.out.println(k + ":" + v));

// —— 统计利器 ——
ages.merge("小明", 1, Integer::sum);      // 计数器模式：旧值+1
System.out.println(ages);                 // {小明=20}
ages.computeIfAbsent("列表", k -> new java.util.ArrayList<String>())
     .add("元素");                        // 多值 Map 的构建块
```

### merge 计数器（词频统计一行核心）

```java
String[] words = "the quick the lazy the dog".split(" ");
Map<String, Integer> freq = new HashMap<>();
for (String w : words) {
    freq.merge(w, 1, Integer::sum);       // 没有则放1，有则 +1
}
System.out.println(freq);                 // {the=3, quick=1, lazy=1, dog=1}
```

### HashMap vs TreeMap vs LinkedHashMap

| | HashMap | LinkedHashMap | TreeMap |
| --- | --- | --- | --- |
| 查找 | O(1) | O(1) | O(log n) |
| 顺序 | 无 | 插入序 | 键排序 |
| 场景 | 默认 | 需保序（LRU） | 范围查询/排序遍历 |

## 五、排序：Comparable 与 Comparator

### Comparable：自然顺序（类自己定义）

```java
class Student implements Comparable<Student> {
    String name;
    int score;

    Student(String name, int score) { this.name = name; this.score = score; }

    @Override
    public int compareTo(Student o) {
        return Integer.compare(this.score, o.score);   // 升序（反过来即降序）
    }

    @Override
    public String toString() { return name + ":" + score; }
}
```

### Comparator：外部策略（灵活多变）

```java
import java.util.*;

List<Student> st = new ArrayList<>(List.of(
        new Student("小明", 90), new Student("小红", 92),
        new Student("小刚", 85)));

// 策略1：按分数降序（匿名内部类老写法 → lambda 新写法）
st.sort((a, b) -> b.score - a.score);
st.sort(Comparator.comparingInt((Student s) -> s.score).reversed());

// 策略2：按姓名排序
st.sort(Comparator.comparing(s -> s.name));

// 策略3：多级排序（分数降序，同分按姓名升序）
st.sort(Comparator.comparingInt((Student s) -> s.score).reversed()
                  .thenComparing(s -> s.name));

System.out.println(st);   // [小红:92, 小明:90, 小刚:85]
```

**选择**：类的"天生顺序"用 Comparable；临时/多种排序策略用 Comparator（组合万岁）。

### Collections 工具类

```java
Collections.sort(list);                 // = list.sort(null)
Collections.reverse(list);
Collections.shuffle(list);              // 随机打乱
Collections.max(list);
Collections.frequency(list, "a");       // 出现次数
Collections.swap(list, 0, 1);
Collections.unmodifiableList(list);     // 不可变视图
```

## 六、综合案例：学生成绩管理系统

```java
import java.util.*;
import java.util.stream.Collectors;

public class ScoreSystem {
    record Student(String name, String clazz, int score) {}   // Java 16+ 数据类

    public static void main(String[] args) {
        List<Student> all = List.of(
            new Student("小明", "一班", 90),
            new Student("小红", "二班", 85),
            new Student("小刚", "一班", 92),
            new Student("小美", "二班", 78),
            new Student("小强", "一班", 66)
        );

        // 1. 排行榜（多级排序）
        List<Student> rank = new ArrayList<>(all);
        rank.sort(Comparator.comparingInt(Student::score).reversed());
        rank.forEach(s -> System.out.printf("  %s %s %d%n",
                s.name(), s.clazz(), s.score()));

        // 2. 按班级分组
        Map<String, List<Student>> byClass = new LinkedHashMap<>();
        for (Student s : all)
            byClass.computeIfAbsent(s.clazz(), k -> new ArrayList<>()).add(s);

        byClass.forEach((cls, list) -> {
            double avg = list.stream().mapToInt(Student::score)
                             .average().orElse(0);
            System.out.printf("%s: %d人 平均%.1f%n", cls, list.size(), avg);
        });

        // 3. 词频式统计分数段
        Map<String, Integer> dist = new TreeMap<>();
        for (Student s : all) {
            String band = s.score() >= 90 ? "90+" : s.score() >= 80 ? "80+" :
                          s.score() >= 60 ? "60+" : "挂科";
            dist.merge(band, 1, Integer::sum);
        }
        System.out.println("分数段: " + dist);

        // 4. 挂科名单（stream 预告第十二篇）
        List<String> failed = all.stream()
                .filter(s -> s.score() < 60)
                .map(Student::name)
                .collect(Collectors.toList());
        System.out.println("挂科: " + (failed.isEmpty() ? "无" : failed));
    }
}
```

## 七、容器选型决策表

| 需求 | 选择 |
| --- | --- |
| 动态列表（默认） | `ArrayList` |
| 自动去重 | `HashSet` / 保序用 `LinkedHashSet` |
| 有序集合/排名 | `TreeSet` |
| 键值查找（默认） | `HashMap` |
| 键值保插入序 | `LinkedHashMap` |
| 键有序遍历/范围查 | `TreeMap` |
| 一键多值 | `Map<K, List<V>>` + `computeIfAbsent` |
| 只读常量集合 | `List.of` / `Set.of` / `Map.of` |

## 小练习

1. 词频统计 Top3：按次数降序、同次数按字典序（entrySet 搬进 List 多级排序）
2. 两个班级名单求：并集（去重）、交集、只在一班的人
3. 用 `Map<String, List<String>>` 实现"分组通讯录"：录入若干 (姓名, 分组)，按组输出
4. 模拟抽签：ArrayList 装 30 人，`Collections.shuffle` 后取前 5 名（TreeSet 记录已中签防重复）
5. 给第四篇的 `merge(int[] a, int[] b)` 改用 `List<Integer>` 实现，对比两种容器的代码差异

## 本篇小结

- List 有序可重复（ArrayList 默认）；Set 去重；Map 键值对
- 遍历中删除用 removeIf / 迭代器，防 fail-fast
- 自定义对象进 HashSet/HashMap：hashCode + equals 成对重写
- merge/computeIfAbsent 是计数与分组的黄金搭档
- Comparable 定天生序，Comparator 定策略序（comparing/reversed/thenComparing）
- List.of 系列做不可变集合

**下一篇**：异常体系——try/catch 全解与自定义异常。

---

*本系列为 Cyber先锋社原创教程。merge 计数器 + computeIfAbsent 分组 = 集合实战双绝，务必掌握。*
