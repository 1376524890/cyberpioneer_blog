---
title: Java 入门教程（三）：流程控制
published: 2026-10-29
description: 完整讲解 Java 分支（if/switch 语句与 switch 表达式）、三种循环、break/continue 带标签跳转、嵌套循环经典练习（九九表/质数/图形/水仙花），覆盖 Java 14+ 增强 switch 新语法。
tags: [Java, 编程入门, 教程]
category: Java 教程
slug: java-tutorial-03
series: "Java 入门教程"
seriesOrder: 3
---

## 本篇目标

Java 的流程控制与 C/C++ 同源，但更安全（编译器更严格），且 Java 14+ 引入了现代的 **switch 表达式**。本篇全覆盖，含经典练习。

## 一、分支

### if / else if / else

```java
import java.util.Scanner;

public class Grade {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        int score = sc.nextInt();

        if (score >= 90) {
            System.out.println("优秀");
        } else if (score >= 80) {
            System.out.println("良好");
        } else if (score >= 60) {
            System.out.println("及格");
        } else {
            System.out.println("不及格");
        }
    }
}
```

与 C++ 唯一显著差异：Java 条件必须是 `boolean`——`if (score = 90)` 这种笔误**直接编译错误**（比 C++ 安全）。

### 传统 switch 语句

```java
public class Calculator {
    public static void main(String[] args) {
        char op = '+';
        int a = 3, b = 4;

        switch (op) {
            case '+':
                System.out.println(a + b);
                break;                          // ⚠ 照样会贯穿！
            case '-':
                System.out.println(a - b);
                break;
            case '*':
            case 'x':                           // 多标签共享分支
                System.out.println(a * b);
                break;
            default:
                System.out.println("不支持");
        }
    }
}
```

switch 支持的类型：`byte/short/char/int`、`String`（Java 7+！）、枚举。**不支持 long、double、float**。

### switch 表达式（Java 14+，现代首选）

箭头语法：不贯穿、不用 break、可直接返回值：

```java
public class Week {
    public static void main(String[] args) {
        int day = 6;

        // ① 箭头分支（无贯穿烦恼）
        String type = switch (day) {
            case 1, 2, 3, 4, 5 -> "工作日";
            case 6, 7 -> "周末";
            default -> "非法日期";           // 必须穷尽！有 default 才编译通过
        };
        System.out.println(type);            // 周末

        // ② 带代码块的分支（yield 返回值）
        String detail = switch (day) {
            case 6, 7 -> {
                String name = (day == 6) ? "周六" : "周日";
                yield name + "休息";         // yield 产出值
            }
            default -> "上班";
        };
        System.out.println(detail);
    }
}
```

**新语法三大优点**：不贯穿、强制穷尽（编译器查漏）、能当表达式赋值。新代码一律用它。

### 三元运算符

```java
int a = 10, b = 20;
int max = a > b ? a : b;
```

## 二、循环

### while 与 do-while

```java
// 1~100 求和
int sum = 0, i = 1;
while (i <= 100) {
    sum += i;
    i++;
}
System.out.println(sum);      // 5050

// do-while：至少执行一次（菜单场景）
int choice;
do {
    System.out.println("1.开始 0.退出");
    // choice = 读入...
    choice = 0;               // 演示用
} while (choice != 0);
```

### for 经典三段式

```java
for (int i = 1; i <= 9; i++) {
    System.out.printf("%d ", i * i);
}

// 多变量版本
for (int i = 0, j = 10; i < j; i++, j--) {
    System.out.println(i + " " + j);
}

// 死循环
for (;;) { }
while (true) { }
```

### 增强 for（for-each）：遍历数组/集合

```java
int[] nums = {10, 20, 30};
for (int n : nums) {
    System.out.println(n);
}

String[] langs = {"Java", "Python", "C++"};
for (String lang : langs) {
    System.out.println(lang);
}
```

**限制**：拿不到下标、遍历中不能修改数组元素（只读便利）。

## 三、break / continue 与标签

```java
// 常规：作用于本层
for (int i = 0; i < 10; i++) {
    if (i == 5) break;            // 0~4
    if (i % 2 == 0) continue;     // 跳过偶数
    System.out.println(i);
}

// Java 特色：标签跳转（直接跳出多层循环，goto 的安全版）
outer:
for (int i = 1; i <= 9; i++) {
    for (int j = 1; j <= 9; j++) {
        if (i * j > 30) {
            break outer;          // 一口气跳出两层！
        }
        System.out.printf("%d×%d=%d ", i, j, i * j);
    }
    System.out.println();
}

// continue outer：跳到外层下一轮
```

标签语法是 Java 对"多层循环跳出"的正规解（C++ 只能用标志变量或 goto）。

## 四、经典练习

### 1. 九九乘法表

```java
for (int i = 1; i <= 9; i++) {
    for (int j = 1; j <= i; j++) {
        System.out.printf("%d×%d=%-4d", j, i, i * j);
    }
    System.out.println();
}
```

### 2. 质数判断与 100 内质数表

```java
static boolean isPrime(int n) {
    if (n < 2) return false;
    for (int i = 2; (long) i * i <= n; i++) {    // i*i 防溢出用 long 比
        if (n % i == 0) return false;
    }
    return true;
}

public static void main(String[] args) {
    int count = 0;
    for (int n = 2; n < 100; n++) {
        if (isPrime(n)) {
            System.out.printf("%d ", n);
            count++;
        }
    }
    System.out.println("\n共 " + count + " 个");
}
```

### 3. 水仙花数

```java
for (int n = 100; n < 1000; n++) {
    int a = n / 100, b = n / 10 % 10, c = n % 10;
    if (a*a*a + b*b*b + c*c*c == n)
        System.out.println(n);       // 153 370 371 407
}
```

### 4. 菱形图案（嵌套循环的空间训练）

```java
int n = 5;    // 菱形半径
for (int i = -n; i <= n; i++) {
    int row = n - Math.abs(i);           // 当前行星数半径
    for (int s = 0; s < Math.abs(i); s++) System.out.print(" ");
    for (int j = 0; j < 2 * row + 1; j++) System.out.print("*");
    System.out.println();
}
```

### 5. 猜数字（输入校验 + 循环）

```java
import java.util.Random;
import java.util.Scanner;

public class Guess {
    public static void main(String[] args) {
        Random rand = new Random();
        int answer = rand.nextInt(100) + 1;     // 1~100
        Scanner sc = new Scanner(System.in);
        int tries = 0;

        while (true) {
            System.out.print("猜(1-100): ");
            if (!sc.hasNextInt()) {             // 输入校验
                System.out.println("请输入数字！" + sc.next() + " 被忽略");
                continue;
            }
            int guess = sc.nextInt();
            tries++;

            if (guess < answer)      System.out.println("小了");
            else if (guess > answer) System.out.println("大了");
            else {
                System.out.println("对了！用了 " + tries + " 次");
                break;
            }
        }
    }
}
```

## 五、产生随机数的方式

```java
// 方式1：Random 类（推荐）
import java.util.Random;
Random rand = new Random();
int n = rand.nextInt(100) + 1;       // 1~100
double d = rand.nextDouble();         // [0,1)
boolean b = rand.nextBoolean();

// 方式2：Math.random()
int m = (int)(Math.random() * 100) + 1;

// 固定种子 → 可复现（测试用）
Random seeded = new Random(42);
```

## 小练习

1. 输入一个整数，判断是否为回文数（12321 ✓；循环反转数字后比较）
2. 求 1000 内所有"完数"（因子和等于自身，如 6=1+2+3）
3. 用 switch 表达式输出某年某月的天数（注意闰年二月：`(y%4==0&&y%100!=0)||y%400==0`）
4. 打印斐波那契数列前 20 项（for + 两个变量滚动）
5. 二重循环求"3 个数字组合能组成多少个互不相同的三位数"（1、2、3、4）

## 本篇小结

- 条件必须 boolean（if 笔误编译期拦截）；switch 支持 String 与枚举
- switch 表达式（Java 14+）：箭头不贯穿、强制穷尽、可赋值——新代码首选
- 增强 for 遍历数组简洁但无下标
- 标签 break/continue 可直接跳出多层循环
- hasNextInt 先验后读防输入崩溃

**下一篇**：方法与数组——Java 版的函数与第一批容器。

---

*本系列为 Cyber先锋社原创教程。五个经典练习独立完成后再看参考，效果翻倍。*
