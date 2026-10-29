---
title: Python 入门教程（十一）：综合实战——命令行待办事项管理器
published: 2026-10-29
description: 系列收官之作：从需求分析到架构设计，综合运用函数、字典、JSON 持久化、异常处理、模块拆分，完整开发一个可增删改查、筛选统计、命令行交互的待办事项管理器，含完整源码。
tags: [Python, 项目实战, 教程]
category: 编程教程
slug: python-tutorial-11
series: "Python 入门教程"
seriesOrder: 11
---

## 本篇目标

十篇知识点集于一身：**做一个完整可用的命令行待办事项管理器（Todo CLI）**。你会经历真实项目的全流程——需求分析 → 架构设计 → 分模块实现 → 测试 → 打磨。做完这个项目，你就不是"学过 Python"，而是"用 Python 做过东西"。

## 一、需求分析

先明确产品要做什么（真实项目第一步）：

```text
功能需求：
1. 添加任务：标题 + 可选优先级（高/中/低）+ 可选截止日期
2. 查看任务：全部 / 未完成 / 已完成 / 按优先级筛选
3. 完成任务：按编号标记完成
4. 删除任务
5. 数据持久化：退出后数据还在（JSON 文件）
6. 统计：总数、完成率、逾期数

非功能需求：
- 输入容错：非法输入不崩溃，给出友好提示
- 单文件可运行，也方便扩展成多模块
```

## 二、架构设计

数据结构先行——一个任务长什么样：

```python
{
    "id": 1,                       # 自增编号
    "title": "写Python作业",        # 标题
    "priority": "high",            # high / mid / low
    "due": "2026-11-05",           # 截止日期（可空）
    "done": False,                 # 是否完成
    "created": "2026-10-29 12:00"  # 创建时间
}
```

**模块划分**：

```text
todo.py
├── 数据层：load / save（JSON 读写，第九篇）
├── 业务层：add / done / delete / list / stats（函数，第六篇）
├── 展示层：渲染表格、彩色输出
└── 交互层：main 循环解析命令（第八篇 sys.argv 思想 → 交互式菜单）
```

分层原则：**业务函数不 print 结果而是返回数据，展示层负责打印**——这样以后加 Web 界面能直接复用业务层。

## 三、完整实现

逐段实现（可直接拼成完整文件）：

### 1. 数据层

```python
import json
import os
from datetime import datetime

DATA_FILE = "todos.json"

def load_todos():
    """读取数据文件；不存在或损坏时返回空列表（健壮性）"""
    if not os.path.exists(DATA_FILE):
        return []
    try:
        with open(DATA_FILE, encoding="utf-8") as f:
            return json.load(f)
    except (json.JSONDecodeError, OSError):
        print("⚠ 数据文件损坏，已重置")
        return []

def save_todos(todos):
    with open(DATA_FILE, "w", encoding="utf-8") as f:
        json.dump(todos, f, ensure_ascii=False, indent=2)
```

### 2. 业务层

```python
VALID_PRIORITIES = {"high": "🔴高", "mid": "🟡中", "low": "🟢低"}

def next_id(todos):
    return max((t["id"] for t in todos), default=0) + 1

def add_todo(todos, title, priority="mid", due=None):
    """新增任务，返回新任务"""
    if priority not in VALID_PRIORITIES:
        raise ValueError(f"优先级必须是 {list(VALID_PRIORITIES)}")
    if due:
        try:
            datetime.strptime(due, "%Y-%m-%d")    # 校验日期格式
        except ValueError:
            raise ValueError("日期格式应为 YYYY-MM-DD")
    todo = {
        "id": next_id(todos),
        "title": title.strip(),
        "priority": priority,
        "due": due,
        "done": False,
        "created": datetime.now().strftime("%Y-%m-%d %H:%M"),
    }
    todos.append(todo)
    save_todos(todos)
    return todo

def finish_todo(todos, todo_id):
    """标记完成，返回该任务；不存在抛 KeyError"""
    for t in todos:
        if t["id"] == todo_id:
            t["done"] = True
            save_todos(todos)
            return t
    raise KeyError(f"找不到编号 {todo_id} 的任务")

def delete_todo(todos, todo_id):
    for i, t in enumerate(todos):
        if t["id"] == todo_id:
            removed = todos.pop(i)
            save_todos(todos)
            return removed
    raise KeyError(f"找不到编号 {todo_id} 的任务")

def query(todos, status="all", priority=None):
    """筛选：status = all/todo/done；priority = high/mid/low"""
    result = todos
    if status == "todo":
        result = [t for t in result if not t["done"]]
    elif status == "done":
        result = [t for t in result if t["done"]]
    if priority:
        result = [t for t in result if t["priority"] == priority]
    return result

def is_overdue(todo):
    """已过期：未完成且截止日早于今天"""
    if todo["done"] or not todo["due"]:
        return False
    return todo["due"] < datetime.now().strftime("%Y-%m-%d")
```

### 3. 展示层

```python
def print_todos(todos, title="任务列表"):
    if not todos:
        print("（空空如也）")
        return
    print(f"\n== {title} ==")
    print(f"{'ID':<5}{'状态':<6}{'优先级':<8}{'截止':<12}标题")
    print("-" * 50)
    for t in todos:
        status = "✅" if t["done"] else ("⏳" if not is_overdue(t) else "❗逾期")
        due = t["due"] or "-"
        print(f"{t['id']:<5}{status:<6}{VALID_PRIORITIES[t['priority']]:<6}"
              f"{due:<12}{t['title']}")

def print_stats(todos):
    total = len(todos)
    done = sum(1 for t in todos if t["done"])
    overdue = sum(1 for t in todos if is_overdue(t))
    rate = done / total * 100 if total else 0
    print(f"\n📊 统计：共 {total} 项｜完成 {done} 项"
          f"（{rate:.0f}%）｜逾期 {overdue} 项")
```

### 4. 交互层

```python
def main():
    todos = load_todos()
    print("=== 待办事项管理器 ===")
    print("命令：add 标题 [优先级] [日期] / list [all|todo|done] / "
          "done 编号 / del 编号 / stats / quit")

    while True:
        try:
            raw = input("\n> ").strip()
            if not raw:
                continue
            parts = raw.split(maxsplit=3)      # 最多拆 4 段，标题保留空格
            cmd, args = parts[0].lower(), parts[1:]

            if cmd == "quit":
                print("再见！")
                break

            elif cmd == "add":
                title = args[0] if args else ""
                if not title:
                    print("用法：add 标题 [high|mid|low] [YYYY-MM-DD]")
                    continue
                priority = args[1] if len(args) > 1 and args[1] in VALID_PRIORITIES else "mid"
                due = args[2] if len(args) > 2 else None
                t = add_todo(todos, title, priority, due)
                print(f"✅ 已添加 #{t['id']} {t['title']}")

            elif cmd == "list":
                status = args[0] if args and args[0] in ("all", "todo", "done") else "todo"
                print_todos(query(todos, status=status), f"筛选:{status}")

            elif cmd == "done":
                finish_todo(todos, int(args[0]))
                print("🎉 已完成！")

            elif cmd == "del":
                delete_todo(todos, int(args[0]))
                print("🗑 已删除")

            elif cmd == "stats":
                print_stats(todos)

            else:
                print("未知命令，输入 quit 退出")

        except KeyError as e:
            print(f"操作失败：{e}")
        except ValueError as e:
            print(f"参数错误：{e}")
        except IndexError:
            print("缺少参数，请检查命令格式")
        except KeyboardInterrupt:
            print("\n再见！")
            break

if __name__ == "__main__":      # 第八篇：可直接运行，也可被导入复用
    main()
```

## 四、运行演示

```text
=== 待办事项管理器 ===
> add 复习Python教程 high 2026-10-30
✅ 已添加 #1 复习Python教程
> add 给社团投稿
✅ 已添加 #2 给社团投稿
> add 买咖啡 low
✅ 已添加 #3 买咖啡

> list all
== 筛选:all ==
ID   状态    优先级  截止        标题
--------------------------------------------------
1    ⏳    🔴高   2026-10-30 复习Python教程
2    ⏳    🟡中   -          给社团投稿
3    ⏳    🟢低   -          买咖啡

> done 3
🎉 已完成！
> stats
📊 统计：共 3 项｜完成 1 项（33%）｜逾期 0 项
> quit
```

重启程序，数据完好——`todos.json` 在工作目录里。

## 五、自测清单（交付前必做）

真实项目的验收环节，逐项跑一遍：

- [ ] `add` 不带任何参数 → 提示用法，不崩溃
- [ ] `add 测试 xyz`（非法优先级）→ 自动降级为 mid，不崩溃
- [ ] `add 测试 mid 2026-13-99` → 提示日期格式错误
- [ ] `done 999` → 提示找不到，不崩溃
- [ ] 数据文件手动改成乱码 → 启动提示损坏并重置
- [ ] 完成/删除后重启 → 状态保持
- [ ] 造一条昨天截止的任务 → list 显示"❗逾期"

全部通过，才算"完成"。**这就是教程规则里"代码必须可运行"的含义**。

## 六、进阶改造方向

这个骨架能长成什么：

1. **多模块拆分**：按架构图拆成 `storage.py / core.py / ui.py`（第八篇的包结构）
2. **命令行参数版**：用标准库 `argparse` 改造为 `python todo.py add "标题" -p high`
3. **Web 化**：加 Flask/FastAPI 路由包装业务层——因为业务与展示分离，几乎不用改核心
4. **数据升级**：JSON → SQLite（标准库 sqlite3），支持按标题搜索
5. **定时提醒**：结合 `datetime` 循环检测逾期任务并弹通知

## 七、系列总结

11 篇走过的路：

| 篇 | 主题 | 核心收获 |
| --- | --- | --- |
| 1 | 环境与变量 | 安装、交互环境、四大类型 |
| 2 | 运算符与字符串 | 七类运算、切片、f-string |
| 3 | 条件与循环 | if/while/for、break/continue、推导式 |
| 4 | 列表与元组 | 增删改查、排序、深浅拷贝 |
| 5 | 字典与集合 | 键值映射、去重、集合运算 |
| 6 | 函数 | 参数全家族、作用域、lambda、闭包 |
| 7 | 迭代器与生成器 | 迭代协议、yield、省内存 |
| 8 | 模块与标准库 | 导入、虚拟环境、六大库 |
| 9 | 文件与异常 | with、精确捕获、自定义异常 |
| 10 | 面向对象 | 类、封装、继承多态、魔法方法 |
| 11 | 综合实战（本篇） | 分层架构、完整项目流程 |

**下一步建议**：C++ / Java 系列横向对照着学一遍（体会静态类型与编译）；或者直接挑一个小工具（自己用的）从零做出来——**做东西是唯一的学习闭环**。做出作品欢迎投稿到本站，或到留言板晒成果。

## 小练习（毕业设计，三选一）

1. 给 Todo 加"标签"功能：`add 标题 #标签`，`list #作业` 按标签筛
2. 做"单词打卡器"：每日录入生词与释义，随机抽测，答对率统计（random + json + datetime）
3. 把 Todo 拆成三模块的包并加 `argparse` 命令行支持

---

*本系列为 Cyber先锋社原创教程，共 11 篇。完成毕业设计的同学，欢迎在留言板认领晒图名额！*
