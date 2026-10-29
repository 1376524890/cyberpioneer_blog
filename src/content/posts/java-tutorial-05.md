---
title: Java 入门教程（五）：面向对象（上）——类与封装
published: 2026-10-29
description: 深入 Java OOP 基础：类与对象、构造方法与方法重载、this 关键字、封装三私有一公开规范、static 与静态成员、包与访问修饰符四档权限，用银行账户与图书系统案例贯穿。
tags: [Java, 编程入门, 教程, 面向对象]
category: 编程教程
slug: java-tutorial-05
series: "Java 入门教程"
seriesOrder: 5
---

## 本篇目标

Java 是纯面向对象语言——**一切代码都在类里**。本篇讲 OOP 第一支柱**封装**：类的设计规范、构造方法、this、static 与包管理。Java 的 OOP 比 C++ 更"强制"也更统一。

## 一、类与对象

### 第一个正式的类

```java
public class Student {
    // 成员变量（字段）—— 对象的属性
    private String name;
    private int age;
    private double score;

    // 构造方法 —— 创建对象的入口
    public Student(String name, int age, double score) {
        this.name = name;          // this.name 是字段，name 是参数
        this.age = age;
        this.score = score;
    }

    // 无参构造（重载）
    public Student() {
        this("未命名", 0, 0);       // this(...) 调用另一个构造
    }

    // getter / setter —— 封装的对外接口
    public String getName() { return name; }

    public void setAge(int age) {
        if (age < 0 || age > 150) {           // setter 里做校验！
            throw new IllegalArgumentException("年龄非法: " + age);
        }
        this.age = age;
    }
    public int getAge() { return age; }

    public double getScore() { return score; }

    // 成员方法 —— 对象的行为
    public void study(String course) {
        System.out.println(name + " 正在学习 " + course);
    }

    public String introduce() {
        return String.format("我是%s，%d岁，成绩%.1f", name, age, score);
    }
}
```

```java
public class Main {
    public static void main(String[] args) {
        Student ming = new Student("小明", 18, 90.5);   // new 创建对象
        Student anon = new Student();

        ming.study("Java");
        System.out.println(ming.introduce());
        System.out.println(anon.introduce());

        ming.setAge(19);       // ✓ 走 setter 校验
        // ming.setAge(-1);    // 抛 IllegalArgumentException —— 封装的价值
    }
}
```

**对象内存图**（理解关键）：`new` 在**堆**里开辟对象空间，变量 `ming` 存的是它的**引用**（地址）；多个变量可引用同一对象。

```java
Student a = new Student("小明", 18, 90);
Student b = a;               // b 和 a 指向同一个对象！
b.setAge(20);
System.out.println(a.getAge());   // 20
System.out.println(a == b);       // true（同一地址）
```

### JavaBean 规范

字段私有 + 公有 getter/setter + 无参构造——行业通用的数据类写法，IDE 与框架都认这个约定（IDEA 里 `Alt+Insert` 一键生成）。

## 二、this 关键字

```java
public class Account {
    private String owner;
    private double balance;

    public Account(String owner) {
        this.owner = owner;              // ① 区分字段与同名参数
    }

    public Account(String owner, double balance) {
        this(owner);                     // ② this(...) 调用兄弟构造（必须第一行）
        this.balance = balance;
    }

    public Account deposit(double amount) {
        if (amount > 0) this.balance += amount;
        return this;                     // ③ 返回自身 → 链式调用
    }
}

new Account("小明", 100).deposit(50).deposit(30);
```

## 三、封装三私有一公开

```java
// 反例：字段公开
public class Bad {
    public double balance;          // 任何代码都能写 account.balance = -999
}

// 正例：私有字段 + 校验入口
public class Good {
    private double balance;         // 外部不可见

    public void deposit(double amount) {
        if (amount <= 0) throw new IllegalArgumentException("金额必须为正");
        balance += amount;          // 修改必经校验
    }
    public double getBalance() { return balance; }
}
```

**封装心法**：字段全部 private，外界只通过方法访问——**所有修改必须经过你的检查**，不变量（余额非负）由类自己守护。

## 四、static：属于类的成员

```java
public class GameCharacter {
    // 静态字段：全类共享一份（不属于任何对象）
    private static int createdCount = 0;
    static final int MAX_LEVEL = 99;          // 静态常量

    // 实例字段：每个对象一份
    private String name;
    private int level;

    public GameCharacter(String name) {
        this.name = name;
        this.level = 1;
        createdCount++;                        // 每创建一个 +1
    }

    // 静态方法：属于类，没有 this（不能访问实例成员！）
    public static int getCreatedCount() {
        // System.out.println(this.name);     // ❌ 编译错误，静态无 this
        return createdCount;
    }

    public static void main(String[] args) {
        new GameCharacter("勇者");
        new GameCharacter("法师");

        System.out.println(GameCharacter.getCreatedCount());   // 2（用类名调）
        System.out.println(GameCharacter.MAX_LEVEL);
    }
}
```

**静态 vs 实例决策**：跟着**对象**走的（名字、等级）→ 实例成员；**全类共享/统计/常量/工具方法** → 静态成员。

**main 为什么是 static**：程序启动时还没有任何对象，JVM 只能用类名调起入口。

## 五、包与访问权限

### 包（package）：类的目录组织

```java
// 文件 src/com/club/utils/MathUtils.java
package com.club.utils;                    // 第一行声明包（对应目录结构）

public class MathUtils {
    public static boolean isPrime(int n) { /* ... */ return true; }
}

// 使用方
import com.club.utils.MathUtils;           // 导入

public class Main {
    public static void main(String[] args) {
        MathUtils.isPrime(7);
    }
}
```

IDEA 建 `com.club.utils` 包，把类放进去即可自动管理。

### 四档访问权限

| 修饰符 | 本类 | 同包 | 子类 | 其他包 |
| --- | --- | --- | --- | --- |
| `private` | ✓ | | | |
| （默认，不写） | ✓ | ✓ | | |
| `protected` | ✓ | ✓ | ✓ | |
| `public` | ✓ | ✓ | ✓ | ✓ |

**实用建议**：字段 private；方法按需要 public；仅供包内协作的用默认/protected。

## 六、综合案例：图书借阅系统（封装版）

```java
import java.util.ArrayList;
import java.util.List;

public class Library {
    // ===== 内部数据类 =====
    private static class Book {
        private final String isbn;
        private final String title;
        private boolean borrowed;

        Book(String isbn, String title) {
            this.isbn = isbn;
            this.title = title;
        }
        String getTitle() { return title; }
        String getIsbn() { return isbn; }
        boolean isBorrowed() { return borrowed; }
    }

    // ===== 业务异常 =====
    public static class LibraryException extends RuntimeException {
        LibraryException(String msg) { super(msg); }
    }

    // ===== 状态封装在 Library 内 =====
    private final List<Book> books = new ArrayList<>();

    public void addBook(String isbn, String title) {
        if (findBook(isbn) != null)
            throw new LibraryException("ISBN 已存在: " + isbn);
        books.add(new Book(isbn, title));
    }

    public void borrow(String isbn) {
        Book b = requireBook(isbn);
        if (b.borrowed)
            throw new LibraryException("《" + b.getTitle() + "》已借出");
        b.borrowed = true;
    }

    public void giveBack(String isbn) {
        requireBook(isbn).borrowed = false;
    }

    public void listAll() {
        System.out.println("—— 馆藏 " + books.size() + " 本 ——");
        for (Book b : books)
            System.out.printf("%-14s %-20s %s%n",
                    b.getIsbn(), b.getTitle(),
                    b.isBorrowed() ? "[借出]" : "[在架]");
    }

    private Book findBook(String isbn) {          // 私有工具方法
        for (Book b : books)
            if (b.getIsbn().equals(isbn)) return b;
        return null;
    }

    private Book requireBook(String isbn) {
        Book b = findBook(isbn);
        if (b == null) throw new LibraryException("无此书: " + isbn);
        return b;
    }

    public static void main(String[] args) {
        Library lib = new Library();
        lib.addBook("978-7-111", "Java 核心技术");
        lib.addBook("978-7-115", "算法（第4版）");

        lib.borrow("978-7-111");
        lib.listAll();

        try {
            lib.borrow("978-7-111");          // 重复借
        } catch (LibraryException e) {
            System.out.println("❌ " + e.getMessage());
        }
        lib.giveBack("978-7-111");
        lib.listAll();
    }
}
```

**设计观察**：Book 是 private static 内部类（外界无需知道它的存在）、books 私有（只能通过借/还改变状态）、所有业务错误抛统一异常——这就是封装的完整形态。ArrayList 细节下下篇讲。

## 小练习

1. 实现 `Rectangle` JavaBean：私有宽高 + getter/setter（负数抛异常）+ `area()`/`perimeter()`
2. 写 `Counter` 类：静态字段统计创建的对象数、实例方法 `id()` 返回自己的序号
3. 银行账户 `BankAccount`：私有余额，`deposit`/`withdraw`（不足抛异常）、静态方法统计总账户数与总存款
4. 建 `com.club.shape` 包放 Shape 类、`com.club.main` 包写 Main 调用（练习 package/import）
5. 给 Student 加 `compareTo` 风格方法 `betterThan(Student other)` 按成绩比较，main 里造 3 个对象找学霸

## 本篇小结

- 字段私有 + getter/setter + 无参构造 = JavaBean 规范
- this 三用：区名字 / this(...) 链构造 / 返回自身链式调用
- 引用变量存地址；`==` 比地址、内容比较用 equals（第七篇详讲）
- static 属于类；静态方法无 this 不能摸实例成员
- 四档权限：private → 默认 → protected → public
- 封装的本质：状态私有，修改必经校验

**下一篇**：面向对象（下）——继承、多态、接口与抽象类，Java OOP 的完全体。

---

*本系列为 Cyber先锋社原创教程。IDEA 的 Alt+Insert（生成 getter/setter/构造）先练熟，生产力 ×10。*
