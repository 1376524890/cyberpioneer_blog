---
title: CTF 入门指南：什么是 CTF，如何开始你的第一道题？
published: 2026-10-28
description: CTF（Capture The Flag）是网络安全领域最流行的竞赛形式。本文带你了解 CTF 的五大方向、常见题型与入门学习路径，帮你迈出网络安全竞赛的第一步。
tags: [CTF, 网络安全, 入门指南]
category: 网络安全
slug: ctf-beginners-guide
---

## 什么是 CTF？

**CTF（Capture The Flag，夺旗赛）** 是网络安全领域最流行的技术竞赛形式。参赛选手需要通过分析题目环境，找到隐藏在其中的特定格式的字符串（即 "Flag"），例如：

```text
flag{w3lc0me_t0_cyber_p10neer}
```

CTF 不仅是一场比赛，更是检验和提升安全技能的最佳实践场。社团后续的训练营也将围绕 CTF 展开。

## 五大主流方向

| 方向 | 主要内容 | 需要的基础 |
| --- | --- | --- |
| **Web** | SQL 注入、XSS、SSRF、文件上传漏洞等 | HTTP 协议、Python、前后端基础 |
| **Pwn** | 栈溢出、堆漏洞、格式化字符串等二进制利用 | C 语言、汇编、Linux 系统 |
| **Reverse** | 逆向分析程序逻辑、破解算法 | C/C++、汇编、耐心 |
| **Crypto** | 古典密码、RSA、AES 等密码学攻击 | 数论、Python |
| **Misc** | 流量分析、隐写、取证等杂项 | 广泛的知识面 |

> [!TIP]
> 新手建议从 **Web** 或 **Misc** 入手，门槛相对友好；有 C 语言基础的同学可以直接挑战 **Pwn** 和 **Reverse**。

## 入门学习路径

### 第一步：搭建环境

一台 Linux 虚拟机（推荐 Ubuntu 或 Kali）几乎是标配：

```bash
# Ubuntu 下安装常用工具
sudo apt update
sudo apt install python3 python3-pip git curl burpsuite wireshark
```

### 第二步：刷题入门

推荐从国内的新手友好平台开始：

- **BUUCTF**（buuoj.cn）：题目收录全面，writeup 丰富
- **攻防世界**（adworld.xctf.org.cn）：分类清晰，适合按方向刷题
- **PicoCTF**：纯英文，但题目设计非常适合零基础

### 第三步：学会复盘

每做完一道题，建议写一篇简短的 writeup，记录：

1. 题目考察的知识点
2. 自己卡壳的地方
3. 别人的更优解法

坚持复盘是快速成长的关键，优秀的 writeup 也可以投稿到本站，与大家分享。

## 社团训练计划

社团 CTF 训练营每两周一次线下活动，形式包括：

- **入门专题讲座**：由高年级社员或校外讲师主讲
- **组队模拟赛**：还原真实比赛节奏，赛后集体复盘
- **年度重点赛事**：组队参加 XCTF、强网杯、网鼎杯等赛事

具体时间安排请关注站内公告与社团群通知。

---

*有问题随时在社团群里提问，期待在赛场上看到你的身影！*
