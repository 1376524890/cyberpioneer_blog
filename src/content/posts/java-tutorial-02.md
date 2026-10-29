---
title: Java 入门教程（二）：语法基础与运算符
published: 2026-10-29
description: 详解 Java 基本语法：注释、变量与常量、八种基本类型与类型转换规则、七类运算符、Scanner 输入进阶与 printf 格式化，配典型陷阱与对照示例。
tags: [Java, 编程入门, 教程]
category: Java 教程
slug: java-tutorial-02
series: "Java 入门教程"
seriesOrder: 2
---

## 本篇目标

上一篇跑通了第一个程序，本篇夯实 Java 语法地基：类型系统、运算符、输入输出。Java 是强类型语言的典范——类型规则比 Python 严、比 C++ 更"啰嗦"但更统一。

## 一、注释与命名规范

```java
// 单行注释

/* 多行注释 */

/**
 * 文档注释（javadoc）：IDE 悬停提示、官方文档都靠它
 * @param a 加数
 * @return 两数之和
 */
public static int add(int a, int b) { return a + b; }
```

**Java 命名惯例**（社区铁律）：

| 元素 | 规范 | 示例 |
| --- | --- | --- |
| 类名 | 大驼峰 | `StudentManager` |
| 方法/变量 | 小驼峰 | `calcAverage`、`maxScore` |
| 常量 | 全大写下划线 | `MAX_SIZE` |
| 包名 | 全小写 | `com.club.utils` |

## 二、变量与基本类型

### 八大基本类型

```java
public class Types {
    public static void main(String[] args) {
        // 整数家族
        byte b = 127;                  // 1字节 ±128
        short s = 32000;               // 2字节
        int i = 2147483647;            // 4字节（默认整数字面量类型）
        long big = 10000000000L;       // 8字节（注意 L 后缀！）

        // 浮点家族
        float f = 3.14f;               // 4字节（注意 f 后缀！）
        double d = 3.14159265358979;   // 8字节（默认小数字面量类型）

        // 其他
        char c = 'A';                  // 2字节 Unicode 单字符
        char chinese = '先';           // ✓ 中文也是 char
        boolean ok = true;             // true/false（不是 1/0！）

        // 类型大小永不变（跨平台一致，这是 Java 的卖点）
        System.out.println(Integer.SIZE / 8);    // 4 字节
    }
}
```

> [!WARNING]
> 与 C++ 不同：Java 的 `boolean` 不是整数，`if (1)` 直接编译错误；`char` 是 16 位 Unicode。

### var 局部变量推断（Java 10+）

```java
var name = "小明";            // String
var age = 18;                  // int
var scores = new int[]{90, 85};   // int[]
// var x;                      // ❌ 必须初始化
// var 只能用于局部变量，不能用于字段和参数
```

### 常量

```java
public class Config {
    public static final double TAX_RATE = 0.13;    // 类级常量：final + static
    public static final int MAX_RETRY = 3;
}

final int LOCAL_MAX = 100;     // 局部常量：赋值后不可改
// LOCAL_MAX = 200;            // ❌ 编译错误
```

### 默认值（成员变量才有！）

```java
public class Demo {
    static int a;           // 0
    static double d;        // 0.0
    static boolean flag;    // false
    static String s;        // null（引用类型默认 null）
    // ⚠ 局部变量没有默认值，未初始化直接用 → 编译错误
}
```

## 三、类型转换

### 自动转换（小 → 大，安全）

```java
int i = 100;
long l = i;         // ✓ int → long
double d = l;       // ✓ long → double
double d2 = 10;     // ✓ int 字面量直接给 double

char c = 'A';
int code = c;       // ✓ 65
```

### 强制转换（大 → 小，可能丢失）

```java
double pi = 3.99;
int truncated = (int) pi;       // 3（直接截断，不是四舍五入！）

long big = 10000000000L;
int overflow = (int) big;       // 1410065408（高位截断，结果诡异）

// 经典陷阱：两个 int 相除
System.out.println(7 / 2);          // 3（int 除法！）
System.out.println(7 / 2.0);        // 3.5（一侧 double 则 double）
System.out.println((double) 7 / 2); // 3.5（先转再除）
```

### 数值溢出行为

```java
int max = Integer.MAX_VALUE;
System.out.println(max + 1);    // -2147483648（静默回绕！C++ 是未定义，Java 规定为回绕）

long safe = (long) max + 1;     // ✓ 先升格再运算
// 大数运算用 long，再大用 java.math.BigInteger
```

## 四、运算符全解

### 算术

```java
int a = 10, b = 3;

System.out.println(a + b);      // 13
System.out.println(a - b);      // 7
System.out.println(a * b);      // 30
System.out.println(a / b);      // 3   整除截断
System.out.println(a % b);      // 1   取模（Java 的 % 可用于负数与浮点）
System.out.println(-7 % 3);     // -1（余数符号跟被除数）
System.out.println(7.5 % 2);    // 1.5（浮点取模合法！C++ 不行）

// ++ 与 --
int i = 5;
System.out.println(i++);        // 5 先用后加
System.out.println(++i);        // 7 先加后用
```

### 关系与逻辑

```java
int a = 5, b = 10;

System.out.println(a > b);      // false

// 逻辑运算符：& && | || !
boolean r1 = (a > 0) && (b > 0);    // 短路与（推荐日常用）
boolean r2 = (a > 0) &  (b > 0);    // 非短路与（两边都算，位运算语义）
boolean r3 = (a > 0) || (b < 0);    // 短路或

// ⚠ 经典面试点：短路与否影响副作用
int x = 0;
boolean r = (x != 0) && (++x > 0);  // 左边 false，右边不执行
System.out.println(x);              // 0

// Java 特有：异或 ^
System.out.println(true ^ false);   // true
```

### 位运算（与 C++ 一致）

```java
int a = 0b1010;

System.out.println(a & 0b0110);    // 2
System.out.println(a | 0b0101);    // 15
System.out.println(a ^ 0b1111);    // 5
System.out.println(~a);            // -11
System.out.println(a << 2);        // 40
System.out.println(a >> 1);        // 5  算术右移（补符号位）
System.out.println(-8 >>> 1);      // 2147483644 逻辑右移（Java 特有 >>>，补 0）
```

### 三元与 instanceof

```java
int age = 20;
String status = age >= 18 ? "成年" : "未成年";

// instanceof：判断引用类型（面向对象篇重用）
Object obj = "hello";
if (obj instanceof String) {
    System.out.println("长度: " + ((String) obj).length());
}

// Java 16+ 模式匹配版（免强转）
if (obj instanceof String s) {
    System.out.println("长度: " + s.length());
}
```

### 运算符优先级记忆

`!` > 算术 > 比较 > `&` > `^` > `|` > `&&` > `||` > 三元 > 赋值。**拿不准就加括号**。

## 五、输入与格式化输出

### Scanner 进阶

```java
import java.util.Scanner;

public class Input {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);

        System.out.print("姓名: ");
        String name = sc.next();               // 读一个词

        sc.nextLine();                          // ⚠ 清掉残留换行（经典坑）

        System.out.print("整行介绍: ");
        String intro = sc.nextLine();          // 读整行

        System.out.print("年龄: ");
        if (sc.hasNextInt()) {                  // 先判断再读（防崩）
            int age = sc.nextInt();
            System.out.printf("%s，%d岁%n", name, age);
        } else {
            System.out.println("年龄必须是数字");
        }

        System.out.print("成绩(double): ");
        double score = sc.nextDouble();
        sc.close();
    }
}
```

**next 与 nextLine 混用坑**：`nextInt()` 不消耗行尾换行符，之后紧跟 `nextLine()` 会读到空串——中间补一次 `sc.nextLine()` 冲掉。

### printf 格式化

```java
double price = 9.87654;
int n = 42;

System.out.printf("两位小数: %.2f%n", price);     // 9.88
System.out.printf("宽度10右对齐: [%10.2f]%n", price);
System.out.printf("宽度10左对齐: [%-10.2f]%n", price);
System.out.printf("补零: %08d%n", n);             // 00000042
System.out.printf("千分位: %,d%n", 1234567890);   // 1,234,567,890
System.out.printf("百分比: %.1f%%%n", 0.856);     // 85.6%
System.out.printf("类型: %s / %d / %b / %c%n", "文本", 1, true, 'A');

// %n 是跨平台换行符；String.format 同款语法返回字符串
String s = String.format("排名 No.%03d", 7);
```

### Math 工具类

```java
System.out.println(Math.abs(-5));       // 5
System.out.println(Math.max(3, 7));     // 7
System.out.println(Math.min(3, 7));     // 3
System.out.println(Math.sqrt(16));      // 4.0
System.out.println(Math.pow(2, 10));    // 1024.0
System.out.println(Math.round(3.5));    // 4（四舍五入，区别于强转截断）
System.out.println(Math.ceil(3.1));     // 4.0 向上
System.out.println(Math.floor(3.9));    // 3.0 向下
System.out.println(Math.random());      // [0,1) 随机
```

## 六、典型陷阱速查

```java
// 1. 整数除法
System.out.println((1 + 2) / 2);        // 1 不是 1.5

// 2. char 参与算术
char c = 'A';
System.out.println(c + 1);              // 66（int）
System.out.println((char)(c + 1));      // B

// 3. = 与 ==（编译器会拦大部分，但 boolean 变量场景要小心）
boolean done = false;
if (done = true) { }                    // ⚠ 合法但几乎必是 bug

// 4. 负数取模
System.out.println(-10 % 3);            // -1（跟被除数）

// 5. float 精度（金额别用 float/double！）
System.out.println(0.1 + 0.2 == 0.3);   // false
// 金额用 long 存"分"，或 java.math.BigDecimal
```

## 小练习

1. 输入三角形三边，用海伦公式输出面积（保留 2 位小数，注意整数转 double）
2. 输入秒数，格式化输出 `X天X小时X分X秒`
3. 验证 `(char)('a' + 3)` 输出什么？写循环打印 a-z（`char` 与 `int` 的关系）
4. 用位运算判断整数奇偶、交换两个 int（不用第三变量）
5. `int` 逆序输出各位数字（12345 → 5 4 3 2 1；循环 + % /）

## 本篇小结

- 八大基本类型大小跨平台固定；整数字面量默认 int、小数默认 double
- `long` 加 L、`float` 加 f；`boolean` 不是整数
- 自动转换小→大；强转大→小会截断；两个 int 相除必得 int
- `&&`/`||` 短路；`>>>` 是 Java 特有逻辑右移
- Scanner 的 next/nextLine 混用要清残留；printf 与 String.format 同语法
- 金额远离浮点——用 long 分或 BigDecimal

**下一篇**：流程控制——分支、循环与 Java 的 switch 表达式。

---

*本系列为 Cyber先锋社原创教程。类型转换的每个例子请上机验证，坑见一次胜过听十次。*
