---
title: Java 入门教程（六）：面向对象（下）——继承、多态与接口
published: 2026-10-29
description: 讲透 Java OOP 完全体：继承与 super、方法重写规则、多态与动态绑定、抽象类、接口（默认/静态方法）、Object 核心方法（equals/hashCode/toString）、final 三用法与组合原则。
tags: [Java, 编程入门, 教程, 面向对象, 接口]
category: 编程教程
slug: java-tutorial-06
series: "Java 入门教程"
seriesOrder: 6
---

## 本篇目标

OOP 剩余两大支柱**继承与多态**，以及 Java 的招牌——**接口**。Spring 等主流框架的根基全在本篇。学完后你能读懂 JDK 源码结构和绝大多数 Java 项目的类设计。

## 一、继承

### extends 与 super

```java
// 父类
class Animal {
    protected String name;          // protected：子类可用

    public Animal(String name) {
        this.name = name;
    }

    public void eat() {
        System.out.println(name + " 在吃东西");
    }
}

// 子类：Java 单继承（一个类只能 extends 一个父类）
class Dog extends Animal {
    private String breed;

    public Dog(String name, String breed) {
        super(name);                // ⚠ 必须第一行：调用父类构造
        this.breed = breed;
    }

    public void fetch() {           // 子类新增方法
        System.out.println(name + " 去捡球");
    }
}

Dog d = new Dog("旺财", "柴犬");
d.eat();        // 继承的
d.fetch();      // 自己的
```

**构造顺序**：父类构造先执行（super）→ 子类构造。不写 super(...) 时编译器默认补 `super()`（父类必须有无参构造，否则报错）。

### 方法重写（Override）

```java
class Cat extends Animal {
    public Cat(String name) { super(name); }

    @Override                          // 注解：让编译器检查重写合法性
    public void eat() {                // 方法签名与父类完全一致
        System.out.println(name + "：吃小鱼干");
    }
}
```

**重写规则（两同两小一大）**：

- 方法名、参数列表**相同**
- 返回值**小于等于**父类（相同或是子类型）
- 异常**小于等于**父类抛的
- 访问权限**大于等于**父类（父 public 子不能 protected）

**@Override 必写**——拼写错误、签名不匹配时编译器立刻报错。

## 二、多态

### 向上转型与动态绑定

```java
Animal a1 = new Dog("旺财", "柴犬");    // 向上转型：子对象当父类型用
Animal a2 = new Cat("咪咪");

a1.eat();      // ？——调用谁的 eat？
a2.eat();
// 输出：旺财 在吃东西 / 咪咪：吃小鱼干
// dog 覆写了 eat → 运行期按真实对象类型绑定！
// a1.fetch();  ❌ 编译错误：Animal 类型看不见 Dog 特有方法
```

**多态三条件**：继承体系 + 方法重写 + 父类引用指向子类对象。

**编译看左、运行看右**：能调什么方法由**引用类型**（左边）决定，实际执行哪个版本由**对象类型**（右边）决定。

### 多态的威力：统一处理

```java
public class Zoo {
    public static void feedAll(Animal[] animals) {   // 一个方法管所有动物
        for (Animal a : animals) {
            a.eat();                                  // 各自动态绑定
        }
    }

    public static void main(String[] args) {
        feedAll(new Animal[]{
            new Dog("旺财", "柴犬"),
            new Cat("咪咪"),
            new Animal("神秘生物"),
        });
    }
}
```

新增 `Bird` 子类？`feedAll` 一行不改——**开闭原则**。

### 向下转型与 instanceof

```java
Animal a = new Dog("旺财", "柴犬");

if (a instanceof Dog) {              // 先判断再转（否则 ClassCastException）
    Dog d = (Dog) a;                 // 向下转型：恢复子类能力
    d.fetch();
}

// Java 16+ 模式匹配（一步到位）
if (a instanceof Dog d) {
    d.fetch();                       // d 已就绪
}
```

## 三、抽象类

```java
abstract class Shape {                      // abstract 类不能 new
    protected String name;

    protected Shape(String name) { this.name = name; }

    public abstract double area();          // 抽象方法：无实现，子类必须实现

    public void describe() {                // 普通方法：可复用
        System.out.printf("%s 的面积 = %.2f%n", name, area());   // 多态调用
    }
}

class Circle extends Shape {
    private final double r;
    public Circle(double r) { super("圆"); this.r = r; }

    @Override
    public double area() { return Math.PI * r * r; }
}

class Rect extends Shape {
    private final double w, h;
    public Rect(double w, double h) { super("矩形"); this.w = w; this.h = h; }

    @Override
    public double area() { return w * h; }
}

// Shape s = new Shape("x");   ❌ 抽象类不能实例化
Shape s = new Circle(2);
s.describe();
```

**抽象类定位**：模板/半成品——提取公共部分（字段、实现），强制子类完成"填空"（抽象方法）。

## 四、接口（Java 的招牌）

### 定义与实现

```java
// 接口：纯契约（方法默认 public abstract）
interface Comparable2<T> {
    int compareTo(T other);                 // 抽象方法
}

interface Swimmer {
    void swim();

    // Java 8+ 允许默认方法（有实现！）
    default void swimFast() {
        System.out.println("加速游动");
    }

    // Java 8+ 静态方法
    static void info() {
        System.out.println("游泳接口 v1.0");
    }
}

interface Walker {
    void walk();
}

// 类可实现多个接口（多继承能力的替代品！）
class Duck implements Swimmer, Walker {
    @Override
    public void swim() { System.out.println("鸭子划水"); }
    @Override
    public void walk() { System.out.println("鸭子摇摆走"); }
}

Duck d = new Duck();
d.swim(); d.walk(); d.swimFast();          // 默认方法直接用
Swimmer.info();                             // 静态方法接口名调
```

### 接口 vs 抽象类

| 维度 | 抽象类 | 接口 |
| --- | --- | --- |
| 关键词 | `extends` 单继承 | `implements` 多实现 |
| 字段 | 任意 | 只能 `public static final` 常量 |
| 构造方法 | 有 | 无 |
| 方法 | 抽象+具体 | 抽象+default+static |
| 语义 | "是什么"（is-a，模板） | "能做什么"（can-do，能力） |

**经验**：定义"身份与模板"用抽象类（Animal）；定义"能力"用接口（Comparable、Runnable、Swimmer）——类可以同时是动物并能游泳能跑。

### 面向接口编程（框架思维）

```java
interface Storage {
    void save(String key, String value);
    String load(String key);
}

class MemoryStorage implements Storage {
    private final java.util.Map<String, String> data = new java.util.HashMap<>();
    public void save(String k, String v) { data.put(k, v); }
    public String load(String k) { return data.get(k); }
}

class FileStorage implements Storage {          // 换个实现...
    public void save(String k, String v) { /* 写文件 */ }
    public String load(String k) { return null; }
}

// 使用方只依赖接口——实现随换随用（这就是"解耦"）
public class App {
    private final Storage storage;               // 面向接口

    public App(Storage storage) {                // 构造注入（Spring 核心思想雏形）
        this.storage = storage;
    }

    public void run() {
        storage.save("token", "abc123");
        System.out.println(storage.load("token"));
    }

    public static void main(String[] args) {
        new App(new MemoryStorage()).run();      // 内存版
        new App(new FileStorage()).run();        // 文件版——App 一行不改
    }
}
```

## 五、Object 三巨头

所有类隐式继承 `Object`，三个方法必须会改写：

```java
class Money {
    private final long cents;

    Money(long cents) { this.cents = cents; }

    // 1. equals：内容比较（== 才是引用比较）
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;                       // 同一对象
        if (!(o instanceof Money)) return false;          // 类型检查
        return cents == ((Money) o).cents;
    }

    // 2. hashCode：equals 相等 → hashCode 必须相等（HashMap 约定）
    @Override
    public int hashCode() { return Long.hashCode(cents); }

    // 3. toString：打印友好
    @Override
    public String toString() { return "¥" + cents / 100.0; }
}

Money a = new Money(1050), b = new Money(1050);
System.out.println(a.equals(b));    // true
System.out.println(a);              // ¥10.5
// IDEA：Alt+Insert 一键生成三者，日常用工具生成
```

> [!WARNING]
> 只重写 equals 不重写 hashCode 是大坑——HashMap/HashSet 会"找不到"相等的对象。永远两个一起改。

## 六、final 与继承的边界

```java
final class Sealed { }              // final 类：禁止继承（如 String）
// class Sub extends Sealed {}      ❌

class Tool {
    public final void spec() { }    // final 方法：禁止重写
    public static void main(String[] args) {
        final int X = 10;           // final 变量：常量
    }
}
```

## 七、综合实战：图形面积系统（接口版）

```java
import java.util.List;

interface Area {
    double area();
    // 接口 default 提供组合逻辑
    default double areaDifference(Area other) {
        return this.area() - other.area();
    }
}

class Circle2 implements Area {
    private final double r;
    Circle2(double r) { this.r = r; }
    @Override public double area() { return Math.PI * r * r; }
    @Override public String toString() { return String.format("圆(r=%.1f)", r); }
}

class Square implements Area {
    private final double side;
    Square(double side) { this.side = side; }
    @Override public double area() { return side * side; }
    @Override public String toString() { return String.format("正方形(边%.1f)", side); }
}

public class Shapes {
    public static void main(String[] args) {
        List<Area> shapes = List.of(new Circle2(2), new Square(3));

        double total = 0;
        Area biggest = shapes.get(0);
        for (Area s : shapes) {
            System.out.printf("%s = %.2f%n", s, s.area());
            total += s.area();
            if (s.area() > biggest.area()) biggest = s;
        }
        System.out.printf("总面积 %.2f，最大的是 %s%n", total, biggest);
        System.out.printf("圆比正方形大 %.2f%n",
                shapes.get(0).areaDifference(shapes.get(1)));
    }
}
```

## 小练习

1. `Employee` 抽象类 + `Manager`（底薪+提成）/`Sales`（底薪+件数）重写 `salary()`
2. 接口 `Flyable`/`Swimmable`，类 `Duck` 实现两个、`Plane` 只实现飞行，用多态数组演示
3. 自定义 `Point` 类：正确重写 equals/hashCode/toString，放入 HashSet 验证去重
4. 用接口 `Comparator<T>` 实现"按成绩降序"比较器（第六篇预告集合排序）
5. （概念）重载与重写的区别？接口与抽象类的区别？编译看左运行看右什么意思？

## 本篇小结

- 单继承 extends；super 必须第一行；构造先父后子
- 重写遵循"两同两小一大"；@Override 必写
- 多态 = 继承 + 重写 + 向上转型；编译看左、运行看右
- 抽象类是模板，接口是能力（可多实现）；面向接口编程 = 解耦
- equals/hashCode/toString 三件套成对改写
- final 可锁类/方法/变量

**下一篇**：常用类库——String 深入、包装类、日期时间与数学工具。

---

*本系列为 Cyber先锋社原创教程。接口优先的思维方式是读懂 Spring 全家源码的钥匙。*
