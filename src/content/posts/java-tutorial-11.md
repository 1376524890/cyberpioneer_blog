---
title: Java 入门教程（十一）：多线程与 Lambda
published: 2026-10-29
description: 进入并发世界：Thread 创建两法与生命周期、synchronized 与原子类、ExecutorService 线程池、Lambda 与函数式接口、Optional 防空指针，附多线程下载统计实战。
tags: [Java, 编程入门, 教程, 多线程, Lambda]
category: Java 教程
slug: java-tutorial-11
series: "Java 入门教程"
seriesOrder: 11
---

## 本篇目标

两个主题一次讲完：**多线程**（让程序同时干多件事）与 **Lambda**（函数式语法）。它们是 Java 8 的双主角，也是后端面试的必考区。目标：会建线程、懂同步、用线程池、熟练写 Lambda。

## 一、线程基础

### 为什么需要多线程

单线程：下载文件时界面卡死（一件事阻塞一切）。多线程：下载归下载、界面归界面——**并发**提升响应与吞吐。

### 创建线程两法

```java
// 法1：继承 Thread
class Downloader extends Thread {
    private final String file;
    Downloader(String file) { this.file = file; }

    @Override
    public void run() {                     // 线程要做的事
        System.out.println("下载 " + file + " 开始");
        try { Thread.sleep(1000); }         // 模拟耗时
        catch (InterruptedException e) { return; }
        System.out.println("下载 " + file + " 完成");
    }
}

// 法2：实现 Runnable（推荐——不占用继承名额）
class Task implements Runnable {
    @Override
    public void run() {
        System.out.println("任务运行在: " + Thread.currentThread().getName());
    }
}

public class ThreadDemo {
    public static void main(String[] args) throws InterruptedException {
        Thread t1 = new Downloader("a.zip");
        Thread t2 = new Thread(new Task(), "工作线程-2");   // 第二参命名
        Thread t3 = new Thread(() -> System.out.println("Lambda 更简洁"),
                                "工作线程-3");

        t1.start();      // ⚠ 调 start() 不是 run()！run() 只是普通方法调用
        t2.start();
        t3.start();

        t1.join();       // main 线程等 t1 干完再往下走
        System.out.println("main 继续");
    }
}
```

> [!WARNING]
> `start()` 启动新线程执行 run；直接调 `run()` 是在当前线程执行——没有新线程，这是新手第一大坑。

### 常用方法

```java
Thread t = Thread.currentThread();     // 当前线程
t.getName();
Thread.sleep(500);                     // 当前线程睡 500ms（静态方法）
t.join();                              // 等 t 结束
Thread.yield();                        // 建议让出 CPU（了解）
t.setDaemon(true);                     // 守护线程（主程序结束它陪葬）
t.setPriority(Thread.MAX_PRIORITY);    // 优先级（仅建议性）
```

## 二、线程安全与 synchronized

### 竞态条件：多线程第一坑

```java
class Counter {
    private int count = 0;
    public void increment() { count++; }      // count++ 不是原子操作！
    public int get() { return count; }
}

// 1000 个线程各加 1000 次 → 理论 100 万，实际常小于（丢失更新）
```

`count++` 实际是"读→改→写"三步，两线程交错执行就丢更新。

### synchronized：互斥锁

```java
class SafeCounter {
    private int count = 0;

    public synchronized void increment() {   // 同一时刻只有一个线程能进入
        count++;
    }
    public synchronized int get() { return count; }
}

// 同步块版（锁更小范围）
class Pair {
    private int a = 0;
    public void add() {
        synchronized (this) {                // 锁住当前实例
            a++;
        }
    }
}
```

### 原子类：无锁方案（简单计数首选）

```java
import java.util.concurrent.atomic.AtomicInteger;

class AtomicCounter {
    private final AtomicInteger count = new AtomicInteger();
    public void increment() { count.incrementAndGet(); }    // CAS 实现，无锁高效
    public int get() { return count.get(); }
}
```

### 生产者-消费者（BlockingQueue，工程正解）

```java
import java.util.concurrent.*;

public class ProducerConsumer {
    public static void main(String[] args) throws Exception {
        BlockingQueue<Integer> queue = new LinkedBlockingQueue<>(5);  // 容量5

        // 生产者：往队列放（满了自动阻塞等待）
        Thread producer = new Thread(() -> {
            try {
                for (int i = 1; i <= 10; i++) {
                    queue.put(i);
                    System.out.println("生产 " + i);
                }
                queue.put(-1);                       // 结束信号
            } catch (InterruptedException ignored) {}
        });

        // 消费者：从队列取（空了自动阻塞等待）
        Thread consumer = new Thread(() -> {
            try {
                int v;
                while ((v = queue.take()) != -1)
                    System.out.println("  消费 " + v);
            } catch (InterruptedException ignored) {}
        });

        producer.start();
        consumer.start();
        producer.join();
        consumer.join();
    }
}
```

## 三、线程池：生产标配

手动 new Thread 有创建销毁开销、无法控数量。**线程池 = 线程复用 + 队列排队 + 限流**：

```java
import java.util.concurrent.*;

public class PoolDemo {
    public static void main(String[] args) throws Exception {
        // 固定 4 个工作线程的池
        ExecutorService pool = Executors.newFixedThreadPool(4);

        // 提交 10 个任务（自动排队分发）
        for (int i = 1; i <= 10; i++) {
            final int taskId = i;
            pool.submit(() -> {                        // submit 接收 Runnable/Callable
                System.out.printf("任务%d 由 %s 处理%n",
                        taskId, Thread.currentThread().getName());
                try { Thread.sleep(300); }
                catch (InterruptedException e) { Thread.currentThread().interrupt(); }
                return taskId * taskId;                 // Callable 可返回结果
            });
        }

        // Callable + Future：拿异步结果
        Future<Integer> future = pool.submit(() -> {
            Thread.sleep(500);
            return 42;
        });
        System.out.println("等结果...");
        System.out.println("结果 = " + future.get());    // 阻塞直到完成

        pool.shutdown();                                 // 温和关闭（等任务做完）
        // pool.awaitTermination(5, TimeUnit.SECONDS);
    }
}
```

**池的选型**：

| 工厂方法 | 适用 |
| --- | --- |
| `newFixedThreadPool(n)` | 负载稳定（默认首选） |
| `newCachedThreadPool()` | 短时大量小任务 |
| `newSingleThreadExecutor()` | 任务需严格串行 |

> [!TIP]
> 生产环境推荐 `new ThreadPoolExecutor(...)` 手动配七个参数（核心数/最大数/队列/拒绝策略），框架（Spring/Tomcat）内部全是定制池——入门先会 Executors，进阶再读源码。

## 四、Lambda 与函数式接口

### 从匿名内部类到 Lambda

```java
// 需求：按长度排序
List<String> list = new ArrayList<>(List.of("banana", "apple", "fig"));

// 远古写法
list.sort(new Comparator<String>() {
    @Override
    public int compare(String a, String b) { return a.length() - b.length(); }
});

// Lambda 写法
list.sort((a, b) -> a.length() - b.length());

// 方法引用：更极致的简洁
list.sort(Comparator.comparingInt(String::length));
```

### Lambda 语法全解

```java
// (参数) -> 表达式 或 { 语句块 }
Runnable r1 = () -> System.out.println("无参");
Runnable r2 = () -> {
    System.out.println("多行");
    System.out.println("要花括号");
};

// 单参可省括号（类型自动推断）
java.util.function.Function<String, Integer> len = s -> s.length();
java.util.function.Function<String, Integer> len2 = String::length;   // 方法引用

// 有返回值的
java.util.function.BinaryOperator<Integer> add = (a, b) -> a + b;
```

### 四大函数式接口（java.util.function）

```java
// Function<T,R>：T → R（转换）
Function<String, Integer> parse = Integer::parseInt;
System.out.println(parse.apply("42"));

// Predicate<T>：T → boolean（判断）
Predicate<String> isEmpty = String::isEmpty;
System.out.println(isEmpty.test(""));        // true

// Consumer<T>：T → void（消费）
Consumer<String> printer = s -> System.out.println("⚡ " + s);
printer.accept("hello");

// Supplier<T>：() → T（生产/惰性）
Supplier<Double> random = Math::random;
System.out.println(random.get());
```

**Lambda 能出现在任何"函数式接口"（只有一个抽象方法的接口）的位置**——Runnable、Comparator、以及上面四大金刚。

### 方法引用四式

```java
String::length            // 对象方法：x -> x.length()
System.out::println       // 特定对象方法：x -> System.out.println(x)
Integer::parseInt         // 静态方法：s -> Integer.parseInt(s)
ArrayList::new            // 构造器：() -> new ArrayList<>()
```

## 五、Optional：告别 NPE

```java
import java.util.Optional;

// 包装可能为 null 的返回值
Optional<String> findUser(int id) {
    return id == 1 ? Optional.of("小明") : Optional.empty();
}

// 使用方（再也不写 if (x != null)）
findUser(1).ifPresent(name -> System.out.println("找到 " + name));

String name = findUser(2).orElse("游客");                 // 默认值
String n2 = findUser(2).orElseGet(() -> "懒加载默认");     // 惰性默认
String n3 = findUser(1).orElseThrow(
        () -> new RuntimeException("用户不存在"));          // 强制要求
```

## 六、实战：并发下载统计

```java
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicLong;

public class DownloadSimulator {
    public static void main(String[] args) throws Exception {
        String[] files = {"a.zip", "b.zip", "c.zip", "d.zip", "e.zip"};
        AtomicLong totalBytes = new AtomicLong();        // 原子累计
        ExecutorService pool = Executors.newFixedThreadPool(3);

        var futures = new java.util.ArrayList<Future<Long>>();
        long start = System.currentTimeMillis();

        for (String f : files) {
            futures.add(pool.submit(() -> {              // Callable 返回本文件字节数
                Thread.sleep(500);                       // 模拟下载
                long size = (long) (Math.random() * 1_000_000);
                totalBytes.addAndGet(size);
                System.out.printf("  [%s] %s 完成: %,d B%n",
                        Thread.currentThread().getName(), f, size);
                return size;
            }));
        }

        long sum = 0;
        for (Future<Long> fu : futures) sum += fu.get(); // 收齐结果

        pool.shutdown();
        System.out.printf("全部完成：%d 文件，共 %,d 字节，并发耗时 %d ms%n",
                files.length, sum,
                System.currentTimeMillis() - start);     // 约 1 秒（串行要 2.5 秒）
    }
}
```

## 小练习

1. 创建 3 个线程分别打印 1~20，观察输出交错；用 `join` 让它们严格顺序执行
2. 用 AtomicInteger 写"10 线程各加 10 万次"验证总数正确；改成普通 int 对比丢失
3. 线程池提交 20 个计算任务（平方），用 `Future` 收集结果求和
4. 用 `Function` 链式组合：`andThen` 实现"字符串 → 长度 → 平方"
5. 用 Optional 重写"根据 id 查学生成绩"：找不到返回默认 0 并打印提示

## 本篇小结

- Thread 两种创建法；start() 启动、join() 等待；sleep 静态方法
- count++ 非原子；synchronized 互斥、AtomicInteger 无锁计数
- BlockingQueue 天然解决生产者消费者
- 线程池三工厂 + submit/Future 收结果；生产用 ThreadPoolExecutor 定制
- Lambda 只认函数式接口；四大金刚 Function/Predicate/Consumer/Supplier
- 方法引用四式；Optional 优雅防空

**下一篇**：Stream API 与综合实战——系列的收官之战。

---

*本系列为 Cyber先锋社原创教程。"并发耗时 vs 串行耗时"的对比实验请亲手跑，体感最深刻。*
