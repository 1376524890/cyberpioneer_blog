---
title: Java 入门教程（十）：文件 IO 与 NIO
published: 2026-10-29
description: 掌握 Java 文件读写全套路：File 与 Path、字节流与字符流、缓冲流、Files 工具类一行流（readString/write/lines/walk）、CSV 通讯录持久化实战、try-with-resources 综合运用。
tags: [Java, 编程入门, 教程, 文件IO]
category: 编程教程
slug: java-tutorial-10
series: "Java 入门教程"
seriesOrder: 10
---

## 本篇目标

让数据活过进程的生命周期——**读写文件**。Java IO 类库庞大（几十个类），但日常 90% 的需求靠 **Files 工具类 + 缓冲流**就能解决。本篇按"现代优先"的路线讲。

## 一、File 与 Path

```java
import java.io.File;
import java.nio.file.*;       // NIO（New IO，Java 7+，推荐）

// 老牌 File
File f = new File("data/demo.txt");
f.exists();
f.isFile(); f.isDirectory();
f.length();                  // 字节数
f.delete();

// 现代 Path（推荐）
Path p = Path.of("data", "demo.txt");        // 自动拼路径（跨平台分隔符）
System.out.println(p.getFileName());          // demo.txt
System.out.println(p.toAbsolutePath());       // /Users/xxx/项目/data/demo.txt

Files.exists(p);
Files.size(p);
Files.createDirectories(Path.of("a/b/c"));    // 递归建目录
Files.delete(p);                              // 删除（不存在抛异常）
Files.copy(Path.of("src"), Path.of("dst"), StandardCopyOption.REPLACE_EXISTING);
Files.move(src, dst);
```

## 二、Files 工具类：一行流（日常首选）

```java
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.io.IOException;

Path file = Path.of("notes.txt");

// —— 文本全家桶 ——
Files.writeString(file, "第一行\n", StandardOpenOption.CREATE);   // 覆盖写
Files.writeString(file, "追加的一行\n",
        StandardOpenOption.CREATE, StandardOpenOption.APPEND);     // 追加写
Files.writeString(file, "第三行\n", StandardOpenOption.APPEND);

String all = Files.readString(file);                  // 一口气读完
System.out.println(all);

List<String> lines = Files.readAllLines(file);        // 按行读进 List
for (String line : lines)
    System.out.println("> " + line);

// 流式逐行（大文件省内存）
try (var stream = Files.lines(file)) {
    stream.filter(l -> l.contains("一"))
          .forEach(System.out::println);
}

// —— 字节读（图片等二进制）——
byte[] bytes = Files.readAllBytes(Path.of("icon.png"));
Files.write(Path.of("copy.png"), bytes);

// —— 遍历目录树 ——
try (var walk = Files.walk(Path.of("."))) {           // 递归所有子目录
    walk.filter(f -> f.toString().endsWith(".java"))
        .limit(5)
        .forEach(System.out::println);
}
```

> [!TIP]
> 小文件（配置、日志、CSV）直接 Files 一行流；大文件用流式 `Files.lines`；两者都自动配 try-with-resources 最稳。

## 三、经典 IO 流体系（读得懂老代码）

### 体系图

```text
字节流（byte）              字符流（char，文本专用）
InputStream                 Reader
├── FileInputStream         ├── FileReader
└── BufferedInputStream ←── └── BufferedReader（缓冲，性能关键）
OutputStream                Writer
├── FileOutputStream        ├── FileWriter
└── BufferedOutputStream    └── BufferedWriter / PrintWriter
```

**选择口诀**：文本用字符流、二进制用字节流、**永远套缓冲**。

### 字符读写模板

```java
import java.io.*;
import java.util.Scanner;

public class IoDemo {
    public static void main(String[] args) {
        // —— 写：PrintWriter（有 println/print/printf，最顺手）——
        try (PrintWriter out = new PrintWriter(
                new BufferedWriter(new FileWriter("diary.txt", true)))) {   // true=追加
            out.println("2026-10-29 学完 Java IO");
            out.printf("用时 %d 分钟%n", 45);
        } catch (IOException e) {
            System.err.println("写失败: " + e.getMessage());
        }

        // —— 读 1：BufferedReader 逐行 ——
        try (BufferedReader br = new BufferedReader(new FileReader("diary.txt"))) {
            String line;
            while ((line = br.readLine()) != null)     // readLine 自动去换行符
                System.out.println("| " + line);
        } catch (IOException e) {
            e.printStackTrace();
        }

        // —— 读 2：Scanner 读文件（nextInt 等 token 化）——
        try (Scanner sc = new Scanner(new File("data.txt"))) {
            while (sc.hasNextInt())
                System.out.println(sc.nextInt());
        } catch (FileNotFoundException e) {
            System.out.println("文件不存在");
        }
    }
}
```

### 编码问题（中文乱码根源）

```java
// FileWriter 用系统默认编码（Windows 是 GBK！）——跨平台乱码之源
// ✅ 显式指定 UTF-8：
try (PrintWriter out = new PrintWriter(new BufferedWriter(
        new OutputStreamWriter(
            new FileOutputStream("data.txt"), java.nio.charset.StandardCharsets.UTF_8)))) {
    out.println("中文内容");
}

// Files 系列默认就是 UTF-8（又一个用它的理由）
Files.readString(file, java.nio.charset.StandardCharsets.UTF_8);
```

## 四、对象序列化（了解）

对象 ↔ 字节的相互转换，用于暂存或网络传输：

```java
import java.io.*;

class User implements Serializable {          // ① 实现标记接口
    private static final long serialVersionUID = 1L;   // ② 版本号（改类不炸旧数据）
    String name;
    transient String password;                 // transient：敏感字段不序列化

    User(String n, String p) { name = n; password = p; }
}

public class SerDemo {
    public static void main(String[] args) throws Exception {
        User u = new User("小明", "123456");

        // 序列化
        try (ObjectOutputStream oos = new ObjectOutputStream(
                new FileOutputStream("user.dat"))) {
            oos.writeObject(u);
        }

        // 反序列化
        try (ObjectInputStream ois = new ObjectInputStream(
                new FileInputStream("user.dat"))) {
            User back = (User) ois.readObject();
            System.out.println(back.name + " / " + back.password);   // 小明 / null
        }
    }
}
```

**现代项目更多用 JSON（Jackson/Gson）替代原生序列化**——可读、跨语言。原生序列化主要用于面试与理解机制。

## 五、综合实战：CSV 通讯录（文件持久化）

```java
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.List;
import java.util.StringJoiner;

public class ContactBook {
    record Contact(String name, String phone, String group) {
        String toCsv() { return String.join(",", name, phone, group); }   // 简单场景（值无逗号）
        static Contact fromCsv(String line) {
            String[] p = line.split(",", -1);        // -1 保留空字段
            return p.length == 3 ? new Contact(p[0], p[1], p[2]) : null;
        }
    }

    private final Path file = Path.of("contacts.csv");
    private final List<Contact> data = new ArrayList<>();

    public ContactBook() { load(); }

    public void add(String name, String phone, String group) {
        data.add(new Contact(name, phone, group));
        save();
    }

    public boolean delete(String name) {
        boolean removed = data.removeIf(c -> c.name().equals(name));
        if (removed) save();
        return removed;
    }

    public List<Contact> search(String kw) {
        return data.stream()
                .filter(c -> c.name().contains(kw) || c.phone().contains(kw))
                .toList();
    }

    public void listAll() {
        StringJoiner sj = new StringJoiner("\n");
        data.forEach(c -> sj.add(String.format("%-8s %-12s [%s]",
                c.name(), c.phone(), c.group())));
        System.out.println(sj);
    }

    private void load() {                          // 启动时读
        if (!Files.exists(file)) return;
        try {
            for (String line : Files.readAllLines(file, StandardCharsets.UTF_8)) {
                Contact c = Contact.fromCsv(line);
                if (c != null) data.add(c);
            }
        } catch (IOException e) {
            System.err.println("读取失败: " + e.getMessage());
        }
    }

    private void save() {                          // 每次变更整写（小数据够用）
        try {
            Files.write(file,
                    data.stream().map(Contact::toCsv).toList(),
                    StandardCharsets.UTF_8,
                    StandardOpenOption.CREATE,
                    StandardOpenOption.TRUNCATE_EXISTING);
        } catch (IOException e) {
            System.err.println("保存失败: " + e.getMessage());
        }
    }

    public static void main(String[] args) {
        ContactBook book = new ContactBook();       // 重启自动加载旧数据！

        book.add("小明", "138xxxx", "同学");
        book.add("小红", "139xxxx", "家人");
        book.listAll();

        System.out.println("搜索'小': " + book.search("小").size() + " 条");
        System.out.println("删除小红: " + book.delete("小红"));
        book.listAll();
    }
}
```

**技术点清单**：record 数据类、Files 读写（UTF-8 显式）、stream 过滤、启动加载 + 变更即存——把它扩展成命令行交互就是毕业设计级作品。

## 六、IO 选型决策

| 场景 | 方案 |
| --- | --- |
| 小文本读写 | `Files.readString` / `writeString` |
| 逐行处理大文本 | `Files.lines`（流式） |
| 按行写/格式化输出 | `PrintWriter` + 缓冲 |
| 读数字等 token | `Scanner` |
| 二进制（图片） | `Files.readAllBytes` / 字节流 |
| 遍历目录树 | `Files.walk` |
| 对象持久化 | JSON 库（实战）/ Serializable（了解） |

## 小练习

1. 统计文本文件：行数、字符数、最长的一行
2. 合并多个日志文件为一个大文件（Files.readAllLines + write 追加）
3. 找出某目录下所有大于 1MB 的文件并按大小排序输出（Files.walk + Files.size）
4. 给通讯录加 `update` 命令与"导出为可读文本报表"功能
5. 简易"日记本"：`write 内容` 追加带时间戳的一行，`list` 显示全部，`grep 关键词` 过滤

## 本篇小结

- Path + Files 是现代首选：readString/writeString/readAllLines/lines/walk
- 流体系：文本字符流、二进制字节流、必套缓冲
- 编码显式 UTF-8，告别乱码；try-with-resources 管所有流
- transient 排除敏感字段；实战持久化用 JSON 更香
- 启动加载 + 变更即存 = 最简持久化模型

**下一篇**：多线程与 Lambda——并发的世界与函数式语法糖。

---

*本系列为 Cyber先锋社原创教程。CSV 通讯录几乎串联了全系列知识，建议默写一遍。*
