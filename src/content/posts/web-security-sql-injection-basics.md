---
title: Web 安全入门：从一个 SQL 注入的诞生说起
published: 2026-10-28
description: SQL 注入是 Web 安全中最经典、影响面最广的漏洞之一。本文以一个极简的登录接口为例，带你直观理解 SQL 注入的成因、利用方式与正确防御手段，适合刚接触 Web 安全的同学阅读。
tags: [Web安全, SQL注入, OWASP]
category: 网络安全
slug: web-security-sql-injection-basics
---

## 从一段有问题的代码说起

假设一个校园活动报名系统，用下面这段 PHP 代码验证用户登录：

```php
<?php
// ⚠️ 危险代码，仅作教学演示
$username = $_POST['username'];
$password = $_POST['password'];

$sql = "SELECT * FROM users
        WHERE username='$username'
        AND password='$password'";

$result = $db->query($sql);
if ($result->num_rows > 0) {
    echo "登录成功";
}
```

这段代码在功能上完全正常——正常用户输入正确的账号密码，就能登录成功。

但问题出在：**用户输入被直接拼接进了 SQL 语句**。

## 注入是如何发生的

如果攻击者在密码框输入：

```sql
' OR '1'='1
```

那么最终执行的 SQL 变成了：

```sql
SELECT * FROM users
WHERE username='admin'
AND password='' OR '1'='1'
```

由于 `'1'='1'` 恒为真，这个查询条件永远成立，攻击者在**不知道密码的情况下以 admin 身份登录**——这就是一次最经典的 SQL 注入攻击。

> [!WARNING]
> 本文所有内容仅用于教学演示。对未授权系统进行测试是违法行为，请在合法靶场环境中练习。

## 更进一步：万能密码与信息刺探

### 探测列数

```sql
admin' ORDER BY 3-- -
```

逐步增大数字，根据页面报错判断查询结果的列数。

### 联合查询读取数据

```sql
' UNION SELECT username, password FROM users-- -
```

通过 `UNION` 把数据库中的敏感数据直接拼进页面返回。

### 数据库指纹

不同数据库的函数和报错信息各有特征：

| 数据库 | 探测语句 |
| --- | --- |
| MySQL | `SELECT version()` |
| PostgreSQL | `SELECT version()` |
| SQLite | `SELECT sqlite_version()` |

## 正确的防御姿势

### 1. 参数化查询（最有效）

预编译让用户输入永远只作为"数据"而不是"代码"被处理：

```php
<?php
// ✅ 正确做法：参数化查询
$stmt = $db->prepare(
    "SELECT * FROM users WHERE username=? AND password=?"
);
$stmt->bind_param("ss", $username, $password);
$stmt->execute();
```

Python (SQLAlchemy) 示例：

```python
from sqlalchemy import text

# ✅ 绑定参数，输入不会被当作 SQL 执行
db.execute(
    text("SELECT * FROM users WHERE username=:u AND password=:p"),
    {"u": username, "p": password},
)
```

### 2. 最小权限原则

应用连接数据库的账号只授予必要权限，即使被注入也难以 `DROP TABLE`。

### 3. 输入校验与 WAF

对输入做白名单校验、部署 WAF 可以增加攻击难度，但**都不能替代参数化查询**。

## 动手练习

想亲手试试？推荐这些合法靶场：

- **sqli-labs**：经典的 SQL 注入练习靶场
- **DVWA**：综合型 Web 漏洞演练平台
- **Pikachu**：中文界面的入门友好靶场

社团活动室常年开放靶机环境，具体开放时间见群公告。

---

*下一篇文章我们聊聊 XSS：当攻击者的脚本在你的浏览器里运行时会发生什么。*
