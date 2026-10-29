---
title: Java 入门教程（十二）：Stream API 与综合实战
published: 2026-10-29
description: 系列收官：Stream 流式处理全解（创建/中间/终端操作、Collectors 收集、分组统计）、Optional 链式防 NPE、综合实战学生管理系统（控制台 CRUD + 集合 + 文件 + 异常 + 多线程），附全系列总结。
tags: [Java, 编程入门, 教程, Stream, 项目实战]
category: 编程教程
slug: java-tutorial-12
series: "Java 入门教程"
seriesOrder: 12
---

## 本篇目标

双主题收官：**Stream API**（Java 8 最优雅的数据处理武器）+ **综合实战**（用全系列知识写一个学生管理系统）。

## 一、Stream API

### 是什么

Stream 是**数据流水线**：`数据源 → 中间操作（惰性）→ 终端操作（触发）`。它不存数据、不改源，只声明"怎么处理"：

```java
import java.util.List;
import java.util.stream.Collectors;

List<String> names = List.of("小明", "小红", "小刚", "小美", "小强");

List<String> result = names.stream()            // ① 建流
        .filter(n -> n.startsWith("小"))          // ② 中间操作：过滤（还没执行！）
        .map(String::length)                      // ③ 中间操作：变换
        .collect(Collectors.toList());            // ④ 终端操作：触发整条流水线
```

### 创建流的三种方式

```java
// 集合 → stream()
List<Integer> list = List.of(1, 2, 3);
list.stream();

// 数组 → Arrays.stream
int[] arr = {1, 2, 3};
Arrays.stream(arr).sum();

// 静态工厂 → Stream.of / generate / iterate
Stream<Integer> s1 = Stream.of(1, 2, 3);
Stream<Integer> s2 = Stream.iterate(1, n -> n * 2).limit(10);    // 1,2,4,8...1024
```

### 中间操作全家桶

```java
List<Integer> nums = List.of(5, 3, 8, 1, 3, 9, 2);

// filter：过滤
nums.stream().filter(n -> n > 3).forEach(System.out::println);   // 5 8 9

// map：一对一变换
nums.stream().map(n -> n * n).forEach(System.out::println);      // 25 9 64 ...

// distinct / sorted / limit / skip
nums.stream().distinct().sorted().limit(3).toList();             // [1, 2, 3]
nums.stream().sorted(Comparator.reverseOrder()).skip(1).toList(); // [8,5,3,3,2]

// flatMap：一对多展开（流中流拍扁）
List<List<Integer>> nested = List.of(List.of(1, 2), List.of(3, 4));
nested.stream().flatMap(List::stream).toList();                   // [1,2,3,4]

// peek：偷看（调试利器）
nums.stream().peek(n -> System.out.println("处理中: " + n))
     .map(n -> n + 1).toList();
```

### 终端操作全家桶

```java
List<Integer> nums = List.of(5, 3, 8, 1, 9);

// —— 归约计算 ——
nums.stream().count();                          // 5
nums.stream().mapToInt(Integer::intValue).sum();// 26（先转 IntStream 性能更好）
nums.stream().max(Integer::compareTo);          // Optional[9]
nums.stream().min(Integer::compareTo);          // Optional[1]
nums.stream().filter(n -> n > 3).findFirst();   // Optional[5]
nums.stream().filter(n -> n > 3).findAny();

// —— 匹配判断 ——
nums.stream().allMatch(n -> n > 0);             // true（全部满足）
nums.stream().anyMatch(n -> n > 8);             // true（任一满足）
nums.stream().noneMatch(n -> n < 0);            // true（都不满足）

// —— 遍历 ——
nums.stream().forEach(System.out::println);
```

### Collectors：收集器（最强大）

```java
List<Student> st = List.of(
    new Student("小明", "一班", 90),
    new Student("小红", "二班", 85),
    new Student("小刚", "一班", 92),
    new Student("小美", "二班", 78));

// toList / toSet
List<String> names = st.stream().map(s -> s.name).toList();   // Java 16+ 直接 toList

// joining：字符串拼接
String all = st.stream().map(s -> s.name)
        .collect(Collectors.joining(", ", "[", "]"));         // [小明, 小红, 小刚, 小美]

// groupingBy：分组（Map<String, List<Student>>）
Map<String, List<Student>> byClass = st.stream()
        .collect(Collectors.groupingBy(s -> s.clazz));

// 分组 + 下游统计
Map<String, Long> countByClass = st.stream()
        .collect(Collectors.groupingBy(s -> s.clazz, Collectors.counting()));
// {一班=2, 二班=2}

Map<String, Double> avgByClass = st.stream()
        .collect(Collectors.groupingBy(s -> s.clazz,
                 Collectors.averagingDouble(s -> s.score)));
// {一班=91.0, 二班=81.5}

Map<String, Optional<Student>> topByClass = st.stream()
        .collect(Collectors.groupingBy(s -> s.clazz,
                 Collectors.maxBy(Comparator.comparing(s -> s.score))));

// partitioningBy：按布尔分两组
Map<Boolean, List<Student>> passFail = st.stream()
        .collect(Collectors.partitioningBy(s -> s.score >= 60));

// toMap：收集成 Map
Map<String, Integer> scoreMap = st.stream()
        .collect(Collectors.toMap(s -> s.name, s -> s.score,
                (a, b) -> b));                 // 第3参处理键冲突
```

### 并行流一行提速

```java
long sum = java.util.stream.IntStream.rangeClosed(1, 100_000_000)
        .parallel()                             // 一行变多核并行
        .sum();
// 适合：数据量大 + 元素计算重；小数据反而更慢（线程切换开销）
```

## 二、综合实战：学生管理系统

全系列知识总集成：OOP + 集合 + 异常 + IO + 多线程。

```java
// ===== StudentSystem.java 完整可编译 =====
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.*;
import java.util.stream.Collectors;

public class StudentSystem {

    // —— 数据模型（record + 封装）——
    record Student(String id, String name, String className, double score) {
        String toCsv() { return String.join(",", id, name, className, String.valueOf(score)); }
        static Student fromCsv(String line) {
            String[] p = line.split(",", -1);
            if (p.length != 4) return null;
            try { return new Student(p[0], p[1], p[2], Double.parseDouble(p[3])); }
            catch (NumberFormatException e) { return null; }
        }
    }

    // —— 业务异常（第九篇）——
    static class SysException extends RuntimeException {
        SysException(String msg) { super(msg); }
    }

    // —— 服务层：集合 + Stream（第八篇 + 本篇）——
    static class Service {
        private final Map<String, Student> data = new LinkedHashMap<>();
        private final Path file = Path.of("students.csv");

        Service() { load(); }

        Student add(String name, String className, double score) {
            if (score < 0 || score > 100)
                throw new SysException("成绩必须在 0~100: " + score);
            String id = "S" + (data.size() + 1001);
            Student s = new Student(id, name, className, score);
            data.put(id, s);
            save();
            return s;
        }

        void remove(String id) {
            if (data.remove(id) == null)
                throw new SysException("学号不存在: " + id);
            save();
        }

        List<Student> ranking() {
            return data.values().stream()
                    .sorted(Comparator.comparingDouble(Student::score).reversed())
                    .collect(Collectors.toList());
        }

        Map<String, Double> classAverages() {
            return data.values().stream()
                    .collect(Collectors.groupingBy(Student::className,
                             Collectors.averagingDouble(Student::score)));
        }

        List<Student> search(String kw) {
            return data.values().stream()
                    .filter(s -> s.name().contains(kw) || s.id().contains(kw))
                    .collect(Collectors.toList());
        }

        // —— 持久化（第十篇）——
        private void save() {
            try {
                Files.write(file,
                        data.values().stream().map(Student::toCsv).toList(),
                        StandardCharsets.UTF_8,
                        StandardOpenOption.CREATE,
                        StandardOpenOption.TRUNCATE_EXISTING);
            } catch (IOException e) {
                throw new SysException("保存失败: " + e.getMessage());
            }
        }

        private void load() {
            if (!Files.exists(file)) return;
            try {
                Files.readAllLines(file, StandardCharsets.UTF_8).stream()
                     .map(Student::fromCsv)
                     .filter(Objects::nonNull)
                     .forEach(s -> data.put(s.id(), s));
            } catch (IOException e) {
                System.err.println("加载失败: " + e.getMessage());
            }
        }
    }

    // —— 控制台交互（流程控制 + 异常处理）——
    public static void main(String[] args) {
        Service svc = new Service();
        Scanner sc = new Scanner(System.in);

        System.out.println("=== 学生管理系统 ===");
        System.out.println("add 姓名 班级 成绩 | del 学号 | rank | stat | search 关键词 | list | quit");

        while (true) {
            System.out.print("\n> ");
            String line = sc.nextLine().trim();
            if (line.isEmpty()) continue;
            String[] p = line.split("\\s+");
            String cmd = p[0];

            try {
                switch (cmd) {
                    case "quit" -> { System.out.println("再见！"); return; }
                    case "add" -> {
                        if (p.length < 4) throw new SysException("用法: add 姓名 班级 成绩");
                        Student s = svc.add(p[1], p[2], Double.parseDouble(p[3]));
                        System.out.println("✅ 已添加 " + s.id() + " " + s.name());
                    }
                    case "del" -> {
                        svc.remove(p[1]);
                        System.out.println("🗑 已删除");
                    }
                    case "rank" -> svc.ranking().forEach(s ->
                            System.out.printf("  %-6s %-6s %-4s %.1f%n",
                                    s.id(), s.name(), s.className(), s.score()));
                    case "stat" -> {
                        svc.classAverages().forEach((cls, avg) ->
                                System.out.printf("  %s: 平均 %.1f%n", cls, avg));
                        System.out.println("  全员均分: " +
                                svc.ranking().stream()
                                   .mapToDouble(Student::score).average().orElse(0));
                    }
                    case "search" -> svc.search(p[1]).forEach(s ->
                            System.out.println("  " + s));
                    case "list" -> svc.ranking().forEach(s ->
                            System.out.println("  " + s));
                    default -> System.out.println("未知命令");
                }
            } catch (SysException e) {
                System.out.println("❌ " + e.getMessage());
            } catch (Exception e) {
                System.out.println("输入格式错误: " + e.getMessage());
            }
        }
    }
}
```

**运行演示**：

```text
> add 小明 一班 90
✅ 已添加 S1001 小明
> add 小红 二班 85
✅ 已添加 S1002 小红
> rank
  S1001  小明   一班  90.0
  S1002  小红   二班  85.0
> stat
  一班: 平均 90.0
  二班: 平均 85.0
> del S1002
🗑 已删除
> quit
```

**涉及知识清单**：record（现代数据类）、LinkedHashMap、Stream 排序/分组/统计、Collectors 全家桶、自定义异常、Files 持久化、switch 表达式、Scanner 交互。这就是"全系列合体"。

## 三、系列总结

| 篇 | 主题 | 关键收获 |
| --- | --- | --- |
| 1 | 环境与第一个程序 | JDK/JVM、IDEA、main 结构 |
| 2 | 语法与运算符 | 八大类型、转换陷阱、printf |
| 3 | 流程控制 | switch 表达式、标签跳转 |
| 4 | 方法与数组 | 重载、值传递本质、Arrays 工具 |
| 5 | 面向对象（上） | 封装、JavaBean、static、包与权限 |
| 6 | 面向对象（下） | 继承、多态、接口、equals/hashCode |
| 7 | 核心类库 | String 不可变、包装类、BigDecimal、日期 |
| 8 | 集合框架 | List/Set/Map、merge 计数、Comparator |
| 9 | 异常处理 | 受检/非受检、try-with-resources |
| 10 | 文件 IO | Files 一行流、编码、CSV 持久化 |
| 11 | 多线程与 Lambda | 线程池、synchronized、函数式接口 |
| 12 | Stream 与实战（本篇） | 流水线、Collectors、综合项目 |

**下一步方向**：Spring Boot 后端开发、Android 应用、大数据生态（Hadoop/Spark 均是 Java 系）、或深入 JVM 原理。做出项目欢迎投稿本站！

## 小练习（毕业设计）

1. 学生系统加"修改成绩"与"按班级删除"命令
2. 把存储从 CSV 升级为 JSON（手写简易序列化或引入 Gson）
3. 加"异步导出报表"功能：线程池执行导出，导出完成后提示（多线程 + Future）
4. 用 Stream 一行实现：求数组中"偶数的平方的平均值"
5. （三系列横向）用 Python 与 C++ 各重写一个命令行 Todo，对比三种语言的代码量与思路差异

---

*本系列为 Cyber先锋社原创教程，共 12 篇完结。至此本站 Python（11篇）/ C++（12篇）/ Java（12篇）三大入门系列全部完结，欢迎在留言板晒毕业设计！*
