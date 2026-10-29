---
title: Java 入门教程（四）：方法与数组
published: 2026-10-29
description: 掌握 Java 方法定义与重载、可变参数、值传递本质、数组全操作（声明/遍历/工具类 Arrays/二维数组）、命令行参数与 main 签名，附数组统计与矩阵转置实战。
tags: [Java, 编程入门, 教程]
category: Java 教程
slug: java-tutorial-04
series: "Java 入门教程"
seriesOrder: 4
---

## 本篇目标

Java 的函数叫**方法**（method），必须定义在类里；数组是 Java 最原始的容器。本篇讲透两者的规则与工具，为面向对象做准备。

## 一、方法

### 基本结构

```java
public class MathUtils {

    // 修饰符 返回类型 方法名(参数列表)
    public static int add(int a, int b) {
        return a + b;
    }

    // 无返回值用 void
    public static void printLine(int n) {
        for (int i = 0; i < n; i++) System.out.print("-");
        System.out.println();
        // void 方法可单独 return 提前结束
    }

    public static void main(String[] args) {
        int sum = add(3, 4);          // 类内调用静态方法可省类名
        MathUtils.add(1, 2);
        printLine(20);
    }
}
```

**方法签名 = 方法名 + 参数列表**（返回值不算）。`static` 意义在面向对象篇详讲，本系列目前统一加。

### 值传递的本质（重要！）

Java **只有值传递**——传基本类型是拷贝值，传引用类型是拷贝"地址值"：

```java
static void tryChange(int x) { x = 100; }              // 改副本，无效

static void changeElement(int[] arr) { arr[0] = 100; } // 通过地址改内容，有效！

static void changeRef(int[] arr) { arr = new int[]{9}; } // 改的是地址副本，无效

public static void main(String[] args) {
    int n = 5;
    tryChange(n);
    System.out.println(n);        // 5

    int[] a = {1, 2, 3};
    changeElement(a);
    System.out.println(a[0]);     // 100（内容被改）

    int[] b = {1};
    changeRef(b);
    System.out.println(b[0]);     // 1（b 还是指向原数组）
}
```

**类比**：引用类型传的是"门牌号复印件"——拿着复印件能进屋搬东西（改内容），但把复印件改成新地址不影响你手里的原件（改指向）。

### 重载（Overload）

```java
public static int    max(int a, int b)          { return a > b ? a : b; }
public static double max(double a, double b)    { return a > b ? a : b; }
public static int    max(int a, int b, int c)   { return max(max(a, b), c); }

max(3, 7);          // int 版
max(3.5, 2.5);      // double 版
max(1, 9, 4);       // 三参版
```

重载规则：参数个数/类型/顺序不同即可；**仅返回值不同不行**。JDK 的 `System.out.println` 有 10 个重载——这就是重载的日常。

### 可变参数（varargs）

```java
// 类型... 名字 = 语法糖，本质是数组
public static int sum(int... nums) {
    int total = 0;
    for (int n : nums) total += n;
    return total;
}

sum();              // 0
sum(1, 2);          // 3
sum(new int[]{1,2,3});  // 6（直接传数组也行）

// ⚠ 可变参数必须是最后一个参数
public static void log(String level, Object... args) { }
```

### 方法递归

```java
public static long factorial(int n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}
// factorial(20) 已接近 long 上限（选对类型！）
```

## 二、数组

### 声明与初始化

```java
// 静态初始化（定长不可变！）
int[] scores = {90, 85, 78, 92, 66};
int[] primes = new int[]{2, 3, 5, 7};

// 动态初始化（定容，默认值填充）
int[] nums = new int[5];          // {0,0,0,0,0}
String[] names = new String[3];   // {null, null, null}

// 长度是属性（不是方法！）
System.out.println(scores.length);    // 5

// C 风格声明 int scores[] 也合法，但不推荐
```

> [!WARNING]
> Java 数组**长度固定**、越界访问抛 `ArrayIndexOutOfBoundsException`（运行期异常，比 C++ 裸数组安全）。要动态长度用 `ArrayList`（第六篇集合）。

### 遍历三式

```java
int[] v = {3, 1, 4, 1, 5};

// ① 经典下标
for (int i = 0; i < v.length; i++)
    System.out.println(i + ": " + v[i]);

// ② 增强 for
for (int n : v)
    System.out.println(n);

// ③ 带索引的函数式（Java 8+，尝鲜）
java.util.Arrays.stream(v)
    .forEach(n -> System.out.println(n));

// 求 max/min/sum
int max = v[0];
for (int n : v) if (n > max) max = n;

int sum = 0;
for (int n : v) sum += n;
System.out.printf("max=%d avg=%.1f%n", max, sum / (double) v.length);
```

### 数组工具类 java.util.Arrays（必备！）

```java
import java.util.Arrays;

int[] v = {5, 3, 8, 1, 9};

// 打印（toString 解决"打印数组显示乱码地址"问题）
System.out.println(Arrays.toString(v));   // [5, 3, 8, 1, 9]

// 排序（原地）
Arrays.sort(v);                            // [1, 3, 5, 8, 9]

// 查找（必须先有序！返回下标，-1 = 没找到）
int idx = Arrays.binarySearch(v, 8);       // 3

// 填充
int[] filled = new int[5];
Arrays.fill(filled, 7);                    // [7,7,7,7,7]

// 拷贝（真正的复制，不是引用）
int[] copy = Arrays.copyOf(v, v.length);
int[] part = Arrays.copyOfRange(v, 1, 4);  // 下标 [1,4) 的子数组

// 比较（内容比较，== 比较的是地址！）
int[] a = {1, 2};
int[] b = {1, 2};
System.out.println(a == b);                    // false（两个对象）
System.out.println(Arrays.equals(a, b));       // true（内容相等）
```

### 二维数组

```java
int[][] matrix = {
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
};

System.out.println(matrix.length);       // 3（行数）
System.out.println(matrix[0].length);    // 3（列数）

// 遍历求和
int total = 0;
for (int i = 0; i < matrix.length; i++)
    for (int j = 0; j < matrix[i].length; j++)
        total += matrix[i][j];

// 不规则数组（每行长度可以不同——Java 数组本质是"数组的数组"）
int[][] ragged = new int[3][];
ragged[0] = new int[1];
ragged[1] = new int[2];
ragged[2] = new int[3];

// 打印二维：deepToString
System.out.println(Arrays.deepToString(matrix));
```

### main 的 String[] args

```java
public class ArgsDemo {
    public static void main(String[] args) {
        // java ArgsDemo hello 42
        for (String arg : args)
            System.out.println(arg);       // hello \n 42
        // args 是命令行参数数组（不含类名）
    }
}
```

## 三、综合实战

### 1. 数组统计分析器

```java
import java.util.Arrays;

public class ScoreAnalyzer {
    static int max(int[] a) {
        int m = a[0];
        for (int x : a) if (x > m) m = x;
        return m;
    }

    static double average(int[] a) {
        int s = 0;
        for (int x : a) s += x;
        return s / (double) a.length;
    }

    public static void main(String[] args) {
        int[] scores = {90, 85, 78, 92, 66, 88, 73};

        int[] sorted = scores.clone();         // 复制后排，不破坏原序
        Arrays.sort(sorted);

        System.out.println("原始: " + Arrays.toString(scores));
        System.out.println("排序: " + Arrays.toString(sorted));
        System.out.printf("最高 %d 最低 %d 平均 %.1f%n",
                max(scores), sorted[0], average(scores));
        System.out.println("中位数: " +
                (sorted.length % 2 == 1
                    ? sorted[sorted.length / 2]
                    : (sorted[sorted.length/2 - 1] + sorted[sorted.length/2]) / 2.0));

        // 高于平均分的比例
        double avg = average(scores);
        long above = Arrays.stream(scores).filter(x -> x > avg).count();
        System.out.println("高于平均: " + above + " 人");
    }
}
```

### 2. 矩阵转置

```java
public class Transpose {
    public static void main(String[] args) {
        int[][] m = {{1, 2, 3}, {4, 5, 6}};

        int[][] t = new int[m[0].length][m.length];
        for (int i = 0; i < m.length; i++)
            for (int j = 0; j < m[0].length; j++)
                t[j][i] = m[i][j];

        System.out.println(Arrays.deepToString(t));
        // [[1, 4], [2, 5], [3, 6]]
    }
}
```

## 小练习

1. 重载 `area`：圆（半径）、长方形（宽高）、三角形（三边海伦公式）
2. 写 `static void reverse(int[] arr)` 原地反转数组（双指针交换，不用新数组）
3. 统计数组中每个元素出现次数（排序后一段一段数；进阶：两重循环去重）
4. 实现 `static int[] merge(int[] a, int[] b)`：合并两个有序数组为有序数组（归并思想）
5. 模拟"双色球抽奖"：从 1~33 随机取 6 个不重复红球 + 1 个蓝球，Arrays.sort 后输出

## 本篇小结

- 方法必须住类里；签名 = 名字 + 参数；仅返回值不同不构成重载
- Java 只有值传递：传引用改内容有效、改指向无效
- 可变参数 `int...` 本质数组，必须放最后
- 数组定长、length 是属性、越界抛异常
- Arrays 工具类五件套：toString / sort / binarySearch / copyOf / equals
- 二维数组是"数组的数组"，可不规则

**下一篇**：面向对象（上）——类、对象、构造方法与封装。

---

*本系列为 Cyber先锋社原创教程。"值传递本质"的三个实验请务必亲手跑一遍。*
