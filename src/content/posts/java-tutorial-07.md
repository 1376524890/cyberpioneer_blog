---
title: Java 入门教程（七）：核心类库——String、包装类与常用工具
published: 2026-10-29
description: 深入 String 不可变性与常量池、StringBuffer 与 StringBuilder 选型、== 与 equals 的坑、包装类与自动装箱、Integer 缓存陷阱、BigDecimal 金额计算、LocalDateTime 新日期 API。
tags: [Java, 编程入门, 教程, JavaAPI]
category: Java 教程
slug: java-tutorial-07
series: "Java 入门教程"
seriesOrder: 7
---

## 本篇目标

日常 Java 开发 80% 的时间在和字符串、包装类、日期打交道。本篇把 JDK 自带的核心类库讲透——特别是那些"面试必考、实战必踩"的坑。

## 一、String 深入

### 不可变性（核心！）

```java
String s = "hello";
s.toUpperCase();          // 产生新对象 "HELLO"
System.out.println(s);    // hello——原串纹丝不动！

s = s.toUpperCase();      // ✓ 必须接住返回值
```

**String 内部的字符数组是 final 的**——任何"修改"操作都返回新对象。好处：线程安全、可作 HashMap 的键、字符串常量池可复用。

### 常量池与 == 的坑（面试 TOP3）

```java
// 字面量赋值：进常量池，同字面量共享一个对象
String a = "hello";
String b = "hello";
System.out.println(a == b);         // true（常量池同一对象）

// new 出来的：堆里新对象
String c = new String("hello");
System.out.println(a == c);         // false（地址不同！）
System.out.println(a.equals(c));    // true（内容相同）

// 拼接陷阱：编译期能确定的进池，运行期拼接产生新对象
String d = "hel" + "lo";            // 编译期合并
System.out.println(a == d);         // true

String part = "lo";
String e = "hel" + part;            // 运行期拼接
System.out.println(a == e);         // false！
System.out.println(a == e.intern());// true（intern 取常量池版本）
```

**铁律：字符串内容比较永远用 equals，== 只用来判断"是不是同一个对象"**。

### 常用方法全家桶

```java
String s = "  Hello, Java World  ";

System.out.println(s.length());              // 20
System.out.println(s.trim());                // 去两端空白 "Hello, Java World"
System.out.println(s.strip());               // Java 11+（还能处理全角空格）

System.out.println(s.charAt(1));             // 'H'
System.out.println(s.indexOf("Java"));       // 8
System.out.println(s.contains("Java"));      // true
System.out.println(s.startsWith("  He"));    // true
System.out.println(s.endsWith("  "));        // true

System.out.println(s.substring(8, 12));      // "Java"（含头不含尾）
System.out.println(s.replace("Java", "Python"));
System.out.println("a,b,c".split(",").length);       // 3
System.out.println("ab".repeat(3));          // ababab（Java 11+）

System.out.println("abc".toUpperCase());
System.out.println("ABC".toLowerCase());
System.out.println("".isEmpty());            // true
System.out.println("  ".isBlank());          // true（Java 11+ 纯空白）
System.out.println(String.join("-", "2026", "10", "29"));  // 2026-10-29

// 文本块（Java 15+）：多行字符串
String json = """
        {
          "name": "小明",
          "age": 18
        }""";
```

### 判等空串与 null 的正确姿势

```java
String input = /* 可能为 null */ null;

// ❌ if (input.equals("")) → NPE 空指针
// ✅ 常量放前面 / 先判 null
if (input == null || input.isEmpty()) { }
if (input != null && "yes".equals(input)) { }    // 常量在前防 NPE
```

### StringBuilder：循环拼接必用

```java
// ❌ 循环里 + 拼接：每次循环产生新 String 对象，O(n²)
String result = "";
for (int i = 0; i < 10000; i++) {
    result += i;
}

// ✅ StringBuilder：内部可变字符数组，O(n)
StringBuilder sb = new StringBuilder();
for (int i = 0; i < 10000; i++) {
    sb.append(i);
}
String fast = sb.toString();

sb.append("-").append(42).append("!");    // 链式
sb.insert(0, "头");
sb.deleteCharAt(sb.length() - 1);
sb.reverse();                             // 反转
```

| 类 | 可变 | 线程安全 | 场景 |
| --- | --- | --- | --- |
| String | ✗ | ✓（不可变天然安全） | 绝大多数场景 |
| StringBuilder | ✓ | ✗ | **单线程拼接（默认）** |
| StringBuffer | ✓ | ✓（synchronized） | 多线程（如今少见） |

## 二、包装类

### 基本类型 ↔ 包装类

```java
int → Integer     double → Double     char → Character
long → Long       boolean → Boolean  ...（其余同名首字母大写）

// 自动装箱/拆箱（编译器语法糖）
Integer boxed = 42;            // 装箱：Integer.valueOf(42)
int raw = boxed;               // 拆箱：boxed.intValue()

// 手动转换
Integer m = Integer.valueOf(42);
int n = m.intValue();

// 字符串互转（高频！）
int age = Integer.parseInt("18");          // String → int
double d = Double.parseDouble("3.14");
String s = String.valueOf(42);             // 数 → String
String t = Integer.toString(42);
```

### Integer 缓存陷阱（面试 TOP1）

```java
Integer a = 127, b = 127;
System.out.println(a == b);        // true（-128~127 有缓存，同一对象）

Integer c = 128, d = 128;
System.out.println(c == d);        // false！超出缓存范围，各自 new
System.out.println(c.equals(d));   // true

// 铁律：包装类比较一律 equals
```

> [!WARNING]
> 拆箱空指针：
> ```java
> Integer score = null;
> int s = score;        // ❌ NullPointerException（null 拆箱炸）
> ```
> 数据库字段/外部输入可能为 null 时，用 `Integer` 并先判空。

## 三、BigDecimal：金额计算唯一正解

```java
import java.math.BigDecimal;
import java.math.RoundingMode;

// ⚠ 别用 new BigDecimal(0.1)——浮点误差原样带入！
BigDecimal a = new BigDecimal("0.1");           // ✓ 用字符串构造
BigDecimal b = BigDecimal.valueOf(0.1);         // ✓ 或 valueOf

System.out.println(a.add(b));                    // 0.2（精确！）
System.out.println(new BigDecimal("10").divide(
        new BigDecimal("3"), 2, RoundingMode.HALF_UP));   // 3.33

// 比较用 compareTo（equals 会连精度一起比：1.0 != 1.00）
new BigDecimal("1.0").compareTo(new BigDecimal("1.00"));  // 0（相等）
new BigDecimal("1.0").equals(new BigDecimal("1.00"));     // false！

// 金额展示
BigDecimal price = new BigDecimal("99.999");
System.out.println(price.setScale(2, RoundingMode.HALF_UP));   // 100.00
```

## 四、日期时间（java.time，Java 8+）

> 老的 `Date`/`SimpleDateFormat` 有线程安全与设计问题，**新项目一律用 java.time**。

```java
import java.time.*;
import java.time.format.DateTimeFormatter;

// —— 三大核心类型 ——
LocalDate date = LocalDate.now();               // 2026-10-29（仅日期）
LocalTime time = LocalTime.now();               // 12:30:45.123（仅时间）
LocalDateTime dt = LocalDateTime.now();         // 日期+时间

LocalDate birthday = LocalDate.of(2006, 6, 1);
LocalDateTime specific = LocalDateTime.of(2026, 10, 29, 14, 30);

// —— 格式化与解析 ——
DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy年MM月dd日 HH:mm:ss");
System.out.println(dt.format(fmt));              // 2026年10月29日 12:30:45
LocalDateTime parsed = LocalDateTime.parse("2026-10-29 14:30:00",
        DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

// —— 计算 ——
LocalDate tomorrow = date.plusDays(1);
LocalDate lastMonth = date.minusMonths(1);
LocalDate nextYearSameDay = date.plusYears(1);

Period age = Period.between(birthday, date);
System.out.printf("%d 岁 %d 个月%n", age.getYears(), age.getMonths());

long days = java.time.temporal.ChronoUnit.DAYS.between(birthday, date);
System.out.println("活了 " + days + " 天");

// 判断
System.out.println(date.isBefore(tomorrow));     // true
System.out.println(date.isLeapYear());           // 闰年判断
System.out.println(date.getDayOfWeek());         // THURSDAY

// —— 时间戳互转 ——
Instant now = Instant.now();                     // UTC 时间戳
long epochMilli = now.toEpochMilli();            // 毫秒时间戳
```

## 五、其他高频工具

### Objects 工具类

```java
import java.util.Objects;

Objects.equals(a, b);            // null 安全的判等
Objects.isNull(x);               // x == null
Objects.requireNonNull(param, "参数不能为空");   // 快速判空抛 NPE
Objects.hashCode(x);
```

### 数组与集合桥梁（预热下一篇）

```java
int[] arr = {3, 1, 4};
int[] copy = Arrays.copyOf(arr, arr.length);
List<Integer> list = Arrays.asList(1, 2, 3);       // 固定长度视图
List<Integer> mutable = new ArrayList<>(List.of(1, 2, 3));
```

## 六、综合案例：会员账单生成器

```java
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.StringJoiner;

public class Bill {
    public static void main(String[] args) {
        String name = "小明";
        BigDecimal vipRate = new BigDecimal("0.88");

        String[][] items = {          // [名称, 单价, 数量]
            {"机械键盘", "399", "1"},
            {"鼠标垫", "49.9", "2"},
            {"显示器支架", "159", "1"},
        };

        BigDecimal total = BigDecimal.ZERO;
        StringJoiner lines = new StringJoiner("\n");    // 拼接利器
        for (String[] it : items) {
            BigDecimal line = new BigDecimal(it[1])
                    .multiply(new BigDecimal(it[2]));
            total = total.add(line);
            lines.add(String.format("%s × %s = ¥%s", it[0], it[2],
                    line.setScale(2, RoundingMode.HALF_UP)));
        }

        BigDecimal pay = total.multiply(vipRate)
                .setScale(2, RoundingMode.HALF_UP);

        String time = LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));

        System.out.println("====== 消费账单 ======");
        System.out.println(lines);
        System.out.println("----------------------");
        System.out.printf("合计: ¥%s%n", total);
        System.out.printf("VIP 88折: ¥%s%n", pay);
        System.out.println("时间: " + time);
    }
}
```

## 小练习

1. 统计字符串中每个字符出现次数，按次数降序输出（Map + 排序预热）
2. 反转字符串中的单词顺序（"hello java world" → "world java hello"；split + StringBuilder）
3. 验证 Integer 缓存：循环比较 -200~200 的装箱 == 结果，统计 true 的范围
4. 用 BigDecimal 计算"等额本息月供"：本金 100 万、年利率 3.6%、30 年（公式查资料，重点练 API）
5. 写"倒计时日历"：输入目标日期字符串，输出距今多少天（LocalDate + ChronoUnit）

## 本篇小结

- String 不可变；内容比较永远 equals；常量池与 == 的关系要懂
- 循环拼接用 StringBuilder；StringJoiner 处理分隔符
- 包装类比较一律 equals（Integer 缓存 -128~127）；拆箱 null 会 NPE
- 金额计算只信 BigDecimal（字符串构造 + compareTo 比较）
- 日期新 API：LocalDateTime + DateTimeFormatter + Period/ChronoUnit

**下一篇**：集合框架——ArrayList/HashMap 全家桶，Java 数据处理的发动机。

---

*本系列为 Cyber先锋社原创教程。String 的 == 陷阱与 Integer 缓存是笔试最爱，亲手跑一遍记住结论。*
