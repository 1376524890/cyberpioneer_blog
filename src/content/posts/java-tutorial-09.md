---
title: Java 入门教程（九）：异常处理
published: 2026-10-29
description: 完整讲解 Java 异常体系：异常层级分类（受检/非受检）、try/catch/finally 执行规则、try-with-resources、throw 与 throws、自定义异常、异常设计最佳实践与常见误区。
tags: [Java, 编程入门, 教程, 异常处理]
category: 编程教程
slug: java-tutorial-09
series: "Java 入门教程"
seriesOrder: 9
---

## 本篇目标

Java 的异常体系是所有语言里最"操心"的——编译器强制你处理部分异常。本篇讲透分类、语法、资源管理与设计原则。

## 一、异常体系

```text
Throwable
├── Error                  ← 严重错误，程序管不了（OutOfMemoryError、StackOverflowError）
└── Exception
    ├── RuntimeException   ← 非受检异常（unchecked）：编译器不强制处理
    │   ├── NullPointerException        空指针
    │   ├── ArrayIndexOutOfBoundsException
    │   ├── ArithmeticException        除零（整数）
    │   ├── ClassCastException         强转失败
    │   ├── NumberFormatException     parseInt("abc")
    │   └── IllegalArgumentException   参数非法
    └── 其他 Exception    ← 受检异常（checked）：编译器强制 try 或 throws
        ├── IOException
        ├── SQLException
        └── FileNotFoundException
```

**受检 vs 非受检**：

```java
// 受检异常：不处理 → 编译不过
public void readFile() {
    FileReader f = new FileReader("a.txt");   // ❌ 编译错误：未处理的 FileNotFoundException
}

// 非受检异常：处理与否自愿（通常是程序 bug 的信号）
public int div(int a, int b) {
    return a / b;      // 可能 ArithmeticException，但不强制处理
}
```

## 二、try / catch / finally

### 基本结构

```java
public class ExceptDemo {
    static int parse(String s) {
        return Integer.parseInt(s);       // 可能 NumberFormatException
    }

    public static void main(String[] args) {
        try {
            System.out.println(parse("42"));
            System.out.println(parse("abc"));       // 这里抛出
            System.out.println("到不了这里");
        } catch (NumberFormatException e) {
            System.out.println("格式错误: " + e.getMessage());
        } catch (Exception e) {                       // 兜底（子类在前父类在后！）
            System.out.println("其他: " + e);
        } finally {
            System.out.println("finally 总会执行");
        }
    }
}
```

**执行规则**：

- try 中抛出位置之后的代码**不执行**，直接跳到匹配的 catch
- catch 按**顺序**匹配，父类必须放后面（`catch (Exception)` 放第一会"吃掉"一切并导致后面不可达的编译错误）
- finally **无论如何都执行**：正常结束、异常、甚至 try 里有 return

```java
static int mystery() {
    try {
        return 1;
    } finally {
        System.out.println("finally 还是执行了！");   // 先打印，再 return 1
    }
}
```

### 多异常合并捕获（Java 7+）

```java
try {
    // ...
} catch (IOException | SQLException e) {      // 竖线合并
    log(e);
}
```

### 获取异常信息

```java
catch (Exception e) {
    e.getMessage();           // 简短描述
    e.toString();             // 类名 + 描述
    e.printStackTrace();      // 完整堆栈（调试用，别用于生产日志）
}
```

## 三、throw 与 throws

```java
// throws：声明"本方法可能抛出这些异常，调用者负责"
public static void setAge(int age) throws IllegalArgumentException {
    if (age < 0 || age > 150) {
        // throw：真正抛出异常对象
        throw new IllegalArgumentException("年龄非法: " + age);
    }
}

// 自定义受检异常：继承 Exception
class InsufficientFundsException extends Exception {
    private final double shortfall;

    public InsufficientFundsException(double shortfall) {
        super(String.format("余额不足，还差 %.2f 元", shortfall));
        this.shortfall = shortfall;
    }
    public double getShortfall() { return shortfall; }
}

public class Account {
    private double balance;

    // 受检异常：调用方必须 try-catch 或继续 throws（编译器盯着）
    public void withdraw(double amount) throws InsufficientFundsException {
        if (amount > balance)
            throw new InsufficientFundsException(amount - balance);
        balance -= amount;
    }
}

// 调用方
public static void main(String[] args) {
    Account acc = new Account();
    try {
        acc.withdraw(100);
    } catch (InsufficientFundsException e) {
        System.out.println(e.getMessage());           // 余额不足，还差 100.00 元
        System.out.println(e.getShortfall());          // 100.0
    }
}
```

**受检/非受检的选型**：调用方**有能力恢复**的（文件不存在→提示重选）→ 受检；**程序 bug**（空指针、参数错误）→ 非受检 RuntimeException，让它炸出来好修。

## 四、try-with-resources：资源管理正解

### 传统 finally 关资源的啰嗦

```java
// 老写法：嵌套深、易漏
FileReader fr = null;
try {
    fr = new FileReader("a.txt");
    int c = fr.read();
} catch (IOException e) {
    e.printStackTrace();
} finally {
    if (fr != null) {
        try { fr.close(); } catch (IOException e) { e.printStackTrace(); }
    }
}
```

### try-with-resources（Java 7+，必用）

```java
// 实现了 AutoCloseable 的资源放 try(...) 里，自动 close（哪怕抛异常）
try (FileReader fr = new FileReader("a.txt");
     BufferedReader br = new BufferedReader(fr)) {       // 多资源分号隔开
    System.out.println(br.readLine());
} catch (IOException e) {
    System.out.println("读取失败: " + e.getMessage());
}
// 离开 try 自动关，且后声明的先关（与声明顺序相反）
```

**军规**：文件、数据库连接、网络流——一律 try-with-resources，告别手写 close。

## 五、异常链与抑制

```java
// 异常链：底层异常包装成业务异常，保留根因
public Config loadConfig(String path) {
    try {
        return parse(new String(java.nio.file.Files.readAllBytes(
                java.nio.file.Path.of(path))));
    } catch (IOException e) {
        throw new ConfigException("配置加载失败: " + path, e);   // 传入原因
    }
}

class ConfigException extends RuntimeException {
    ConfigException(String msg, Throwable cause) {
        super(msg, cause);           // cause 保留在堆栈里
    }
}

// 打印时看到 Caused by: ... 链条，定位根因
```

## 六、最佳实践与常见误区

### ✅ 该做的

```java
// 1. 精确捕获，最小范围
try {
    int n = Integer.parseInt(input);
} catch (NumberFormatException e) { /* 只包可能出错的行 */ }

// 2. 捕获后要么处理、要么转换后抛出，别吞
try { ... }
catch (IOException e) {
    log.error("导入失败", e);
    throw new ImportException("数据导入失败", e);   // 转成语义化异常上抛
}

// 3. finally 里别写 return（会覆盖 try 的返回值，极度迷惑）
```

### ❌ 别做的

```java
// 1. 空 catch 吞异常（出 bug 无迹可寻）
try { dangerous(); } catch (Exception e) { }        // 🔥 火灾隐患

// 2. 捕获 Error / 用异常控制正常流程
for (int i = 0; ; i++) {
    try { list.get(i); } catch (IndexOutOfBoundsException e) { break; }   // ❌ 用循环条件
}

// 3. e.printStackTrace() 当日志（生产用日志框架 SLF4J）

// 4. catch (Exception e) 一把梭（除非最外层兜底）
```

### 早抛晚捕

```java
// 参数校验尽早抛（fail fast）——Spring 的 Assert / Objects.requireNonNull
public void transfer(Account to, double amount) {
    Objects.requireNonNull(to, "目标账户不能为空");
    if (amount <= 0) throw new IllegalArgumentException("金额必须为正");
    // ... 业务在可靠的输入上运行
}
```

## 七、实战：健壮的配置读取器

```java
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class AppConfig {
    private final Properties props = new Properties();

    public static class ConfigException extends RuntimeException {
        ConfigException(String msg, Throwable cause) { super(msg, cause); }
    }

    public static AppConfig load(String filename) {
        // try-with-resources + 异常链 + 语义化包装
        try (InputStream in = AppConfig.class
                .getClassLoader().getResourceAsStream(filename)) {
            if (in == null)
                throw new ConfigException("找不到配置文件: " + filename, null);
            AppConfig cfg = new AppConfig();
            cfg.props.load(in);
            return cfg;
        } catch (IOException e) {
            throw new ConfigException("读取 " + filename + " 失败", e);
        }
    }

    public String get(String key, String def) {           // 安全读取
        return props.getProperty(key, def);
    }

    public int getInt(String key, int def) {              // 类型安全读取
        String v = props.getProperty(key);
        try {
            return v == null ? def : Integer.parseInt(v.trim());
        } catch (NumberFormatException e) {
            System.err.printf("配置 %s=%s 不是数字，用默认 %d%n", key, v, def);
            return def;
        }
    }

    public static void main(String[] args) {
        AppConfig cfg = load("application.properties");
        System.out.println("name = " + cfg.get("app.name", "未配置"));
        System.out.println("port = " + cfg.getInt("app.port", 8080));
    }
}
```

**这段代码展示了生产级套路**：资源自动关、根因保留、语义化异常、带默认值的安全读取。

## 小练习

1. 写方法 `divide(int a, int b)`：b 为 0 时抛自定义 `MathException`，main 里捕获处理
2. 用 try-with-resources 读文本文件：文件不存在时给出友好提示（FileNotFoundException 分支）
3. 实现 `safeParse(String[] args, int index)`：下标越界与格式错误都返回默认值 0 并打印警告
4. 写三层调用 `main → service → dao`，dao 抛 IOException，service 包装成 ServiceException（带 cause），main 捕获打印完整链（观察 Caused by）
5. （概念）受检与非受检异常的区别？finally 一定会执行吗（System.exit 呢）？

## 本篇小结

- Error 不救、受检异常必须处理、非受检是 bug 信号
- catch 子类在前父类在后；finally 无条件执行
- throw 抛对象、throws 声明甩锅；自定义异常继承 Exception（受检）或 RuntimeException（非受检）
- 资源管理一律 try-with-resources
- 异常链保留 Caused by；空 catch 与 printStackTrace 是大忌
- 早抛晚捕、精确捕获、fail fast

**下一篇**：文件 IO 与序列化——让数据落盘。

---

*本系列为 Cyber先锋社原创教程。"健壮配置读取器"是框架源码里的标准套路，读懂它。*
