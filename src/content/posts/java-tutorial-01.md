---
title: Java 入门教程（一）：JDK、IDEA 与第一个程序
published: 2026-10-29
description: 进入 Java 的世界：理解"一次编写，到处运行"的原理、安装 JDK 与 IDEA、解剖第一个程序的结构、掌握变量与数据类型。企业级开发语言的起点。
tags: [Java, 编程入门, 教程]
category: 编程教程
slug: java-tutorial-01
series: "Java 入门教程"
seriesOrder: 1
---

## Java 的定位

"一次编写，到处运行"（Write Once, Run Anywhere）是 Java 的招牌。它能做到这一点，靠的是 **JVM（Java 虚拟机）**：Java 源代码先编译成"字节码"（`.class` 文件），再由各平台的 JVM 执行——同一个字节码能在 Windows、macOS、Linux 上运行。

Java 是企业级开发的主力语言：银行系统、安卓 App、大型电商后端、大数据生态（Hadoop/Spark 均为 Java 系）都有它的身影。岗位多、生态成熟，是就业市场的常青树。

## JDK / JRE / JVM 的关系

初学必懂的三层概念：

```text
JDK（开发工具包）
 ├── JRE（运行环境）
 │    ├── JVM（虚拟机：真正执行字节码）
 │    └── 核心类库
 ├── javac（编译器）
 └── 其他开发工具
```

- 只想**运行** Java 程序 → 装 JRE 就够
- 想**开发** Java 程序 → 装 JDK（包含 JRE）

## 安装 JDK 与开发环境

### 安装 JDK（推荐 LTS 版本 17 或 21）

**Windows/macOS**：从 [Adoptium](https://adoptium.net/)（Eclipse Temurin 发行版）下载安装包，一路下一步。

**Linux（Ubuntu/Debian）**：

```bash
sudo apt update && sudo apt install openjdk-21-jdk
```

### 验证安装

```bash
java -version     # 运行环境版本
javac -version    # 编译器版本
```

两个命令都有输出即安装成功。

### 安装 IDEA

Java 开发的事实标准 IDE 是 **IntelliJ IDEA**（JetBrains 出品）：

1. 到 [jetbrains.com/idea](https://www.jetbrains.com/idea/) 下载
2. 学生可申请免费的教育许可（Community 社区版本身也免费且够用）
3. 首次使用学生邮箱激活 Ultimate 教育版更香

> [!TIP]
> 新手完全可以用 Community 社区版起步，功能足够写完整个入门系列。

## 第一个程序

新建 `Hello.java`（**文件名必须与类名一致**，这是 Java 的硬规矩）：

```java
public class Hello {
    public static void main(String[] args) {
        System.out.println("Hello, Cyber先锋社!");
    }
}
```

编译运行：

```bash
javac Hello.java    # 生成 Hello.class 字节码
java Hello          # JVM 执行（注意不带 .class 后缀）
Hello, Cyber先锋社!
```

在 IDEA 里只需右键 → Run，IDE 会自动完成编译执行。

**解剖这个程序**：

| 部分 | 含义 |
| --- | --- |
| `public class Hello` | 定义一个公开类，类名与文件名一致 |
| `public static void main(String[] args)` | 主方法：程序入口，格式固定照抄 |
| `System.out.println(...)` | 向控制台输出一行内容 |
| `;` | 每条语句以分号结尾 |

> [!WARNING]
> Java 对大小写极其敏感：`System` 写成 `system` 直接报错。`main` 方法的签名必须一字不差。

## 变量与数据类型

Java 同样是静态类型语言，且区分**基本类型**与**引用类型**：

```java
public class Types {
    public static void main(String[] args) {
        // 基本类型（8 种，入门先掌握这几种）
        int age = 18;               // 整数
        long views = 10000000000L;  // 长整数（注意 L 后缀）
        double price = 9.9;         // 双精度浮点
        char grade = 'A';           // 单字符，单引号
        boolean passed = true;      // 布尔值

        // 引用类型：字符串（双引号）
        String name = "小明";

        // var 关键字（Java 10+）：编译器自动推断类型
        var message = "类型推断";

        System.out.println(name + " " + age + " 岁");
        System.out.printf("价格: %.2f 元%n", price);   // 格式化输出
    }
}
```

### 基本类型速览

| 类型 | 字节 | 说明 |
| --- | --- | --- |
| `byte` | 1 | 小整数 ±128 |
| `int` | 4 | 常用整数 ±21 亿 |
| `long` | 8 | 大整数，字面量加 `L` |
| `double` | 8 | 常用小数 |
| `char` | 2 | 单字符（Unicode） |
| `boolean` | — | true / false |

### 类型转换

```java
int a = 10;
double b = a;          // 自动转换（小 → 大，安全）

double pi = 3.99;
int c = (int) pi;      // 强制转换（大 → 小，截断小数），c = 3
```

## 输入：Scanner

Java 读键盘输入用 `Scanner` 类：

```java
import java.util.Scanner;   // 导包

public class InputDemo {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);

        System.out.print("输入你的名字: ");
        String name = sc.next();          // 读一个词

        System.out.print("输入你的年龄: ");
        int age = sc.nextInt();           // 读一个整数

        System.out.println(name + " 明年 " + (age + 1) + " 岁");
        sc.close();
    }
}
```

## 三个语言横向对比（入门篇）

学到这里可以横向看看三姐妹的差异：

| 特性 | Python | C++ | Java |
| --- | --- | --- | --- |
| 执行方式 | 解释执行 | 编译为机器码 | 编译为字节码 + JVM |
| 类型系统 | 动态 | 静态 | 静态 |
| 语法复杂度 | 最低 | 最高 | 中等 |
| 典型用途 | AI、脚本、数据 | 游戏、系统、嵌入式 | 企业后端、安卓 |
| 入门友好度 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |

## 小练习

1. 写程序输出你的个人信息卡（姓名/年龄/专业/一句座右铭），每行一项
2. 用 `Scanner` 读入长和宽，输出矩形面积与周长
3. 已知某商品原价与折扣（如 88 折），计算折后价并保留两位小数（`printf` 的 `%.2f`）

## 本篇小结

- JDK = 开发工具集；JVM 负责执行字节码，实现跨平台
- `javac` 编译 → `java` 运行；IDEA 可以一键搞定
- 文件名必须与 `public` 类名一致；`main` 方法是固定入口
- 8 种基本类型 + `String` 引用类型；`var` 可自动推断
- `Scanner` 处理键盘输入，用完记得 `close()`

**下一篇**：流程控制与方法——把逻辑组织成可复用的积木。

---

*本系列为 Cyber先锋社原创教程，参考业界通用知识体系编写。*
