---
title: C++ 入门教程（九）：面向对象（下）——继承与多态
published: 2026-10-29
description: 讲透 C++ 继承体系：派生类构造顺序、protected 访问、虚函数与动态绑定原理、override 与 final、纯虚函数与抽象类、虚析构函数、多态实战图形系统与怪奇物语。
tags: [C++, 编程入门, 教程, 面向对象, 多态]
category: 编程教程
slug: cpp-tutorial-09
series: "C++ 入门教程"
seriesOrder: 9
---

## 本篇目标

OOP 三大特性的另外两个：**继承**（代码复用的层级体系）与**多态**（同一接口、不同行为）。虚函数是 C++ 多态的核心机制，也是面试必考。本篇讲透它的语法与原理。

## 一、继承基础

### 基本语法

```cpp
#include <iostream>
#include <string>

// 基类（父类）
class Animal {
public:
    Animal(const std::string& name) : name_(name) {}
    void eat() const { std::cout << name_ << "在吃东西\n"; }
protected:                      // 子类可访问，外部不行
    std::string name_;
};

// 派生类（子类）：public 继承表示"是一个"关系
class Dog : public Animal {
public:
    Dog(const std::string& name, const std::string& breed)
        : Animal(name), breed_(breed) {}       // ⚠ 先调基类构造
    void fetch() const { std::cout << name_ << "去捡球\n"; }   // 直接用 protected 成员
private:
    std::string breed_;
};

class Cat : public Animal {
public:
    Cat(const std::string& name) : Animal(name) {}
    void scratch() const { std::cout << name_ << "在磨爪\n"; }
};

int main() {
    Dog d("旺财", "柴犬");
    d.eat();       // 继承来的
    d.fetch();     // 自己的
    Cat c("咪咪");
    c.eat();
}
```

**三种继承方式**（99% 场景用 public 继承）：

| 继承方式 | 基类 public 成员在子类中变为 | 基类 protected | 基类 private |
| --- | --- | --- | --- |
| `public` 继承 | public | protected | 不可访问 |
| `protected` 继承 | protected | protected | 不可访问 |
| `private` 继承 | private | private | 不可访问 |

### 构造与析构顺序

```cpp
// 构造：基类先构造，再派生类
// 析构：派生类先析构，再基类（完全相反，像穿脱衣服）
class Base {
public:
    Base()  { std::cout << "Base构造\n"; }
    ~Base() { std::cout << "Base析构\n"; }
};
class Derived : public Base {
public:
    Derived()  { std::cout << "Derived构造\n"; }
    ~Derived() { std::cout << "Derived析构\n"; }
};
// Derived d; 输出：
// Base构造 → Derived构造 → Derived析构 → Base析构
```

## 二、虚函数与多态（本篇核心）

### 问题引入

```cpp
Animal* a = new Dog("旺财");   // 基类指针指向子类对象（合法）
```

现在想让每个动物"叫出自己的声音"：

```cpp
class Animal {
public:
    void speak() const {                 // ❌ 普通成员函数
        std::cout << name_ << "在发声\n";
    }
};
class Dog : public Animal {
public:
    void speak() const {                 // 隐藏（不是重写！）
        std::cout << name_ << "汪汪！\n";
    }
};

Animal* a = new Dog("旺财");
a->speak();      // 输出"旺财在发声"——调的是基类版本！
```

普通函数调用在**编译期**按指针类型绑定（静态绑定），所以永远调 Animal 的版本。

### virtual：运行期绑定

```cpp
class Animal {
public:
    Animal(const std::string& name) : name_(name) {}
    virtual ~Animal() = default;         // ⚠ 虚析构（后面讲为什么）

    virtual void speak() const {         // virtual 声明为虚函数
        std::cout << name_ << "在发声\n";
    }
protected:
    std::string name_;
};

class Dog : public Animal {
public:
    Dog(const std::string& n) : Animal(n) {}
    void speak() const override {        // override 显式标记重写（C++11）
        std::cout << name_ << "汪汪！\n";
    }
};

class Cat : public Animal {
public:
    Cat(const std::string& n) : Animal(n) {}
    void speak() const override {
        std::cout << name_ << "喵～\n";
    }
};

int main() {
    Animal* zoo[] = {new Dog("旺财"), new Cat("咪咪")};

    for (Animal* a : zoo)
        a->speak();          // ✅ 汪汪！/ 喵～ 运行期按真实类型绑定！

    for (Animal* a : zoo)
        delete a;            // 虚析构保证正确释放子类部分
}
```

**多态成立的三个条件**：基类函数是 `virtual`、子类 `override` 重写、通过**基类指针或引用**调用。

> [!TIP]
> `override` 关键字让编译器帮你检查签名是否真的重写成功（拼错函数名会直接报错）——**重写必写 override**。

### 虚函数原理（面试高频，简版）

每个含虚函数的类都有一张**虚函数表（vtable）**，对象头部存指向 vtable 的指针（vptr）：

```text
Animal* a → [vptr] → Animal::vtable  [ &Animal::speak ]
Dog 对象  → [vptr] → Dog::vtable     [ &Dog::speak    ]   ← Dog 覆盖了槽位

调用 a->speak() 编译为：a->vptr->speak槽位()   ← 运行期查表
```

代价：每对象多 8 字节指针 + 一次间接跳转。所以"不需要多态就别加 virtual"。

## 三、纯虚函数与抽象类

```cpp
class Shape {                        // 抽象类：含纯虚函数，不能实例化
public:
    virtual double area() const = 0;     // = 0 纯虚：子类必须实现
    virtual ~Shape() = default;

    // 可以有普通成员与实现
    void describe() const {
        std::cout << "面积 = " << area() << "\n";   // 调用延迟到子类
    }
};

class Circle : public Shape {
    double r;
public:
    explicit Circle(double r) : r(r) {}
    double area() const override { return 3.14159 * r * r; }
};

class Rect : public Shape {
    double w, h;
public:
    Rect(double w, double h) : w(w), h(h) {}
    double area() const override { return w * h; }
};

// Shape s;              // ❌ 抽象类不能造对象
// Shape* p = new Shape; // ❌ 同上

int main() {
    Shape* shapes[] = {new Circle(2), new Rect(3, 4)};
    double total = 0;
    for (auto* s : shapes) {
        s->describe();           // 多态：各算各的面积
        total += s->area();
    }
    std::cout << "总面积 " << total << "\n";
}
```

**抽象类 = 接口契约**：规定"所有 Shape 必须会算面积"，实现交给子类。纯虚析构除外，接口类通常只含纯虚函数。

## 四、虚析构函数（必考）

```cpp
class BadBase {
public:
    ~BadBase() { std::cout << "~BadBase\n"; }    // ❌ 非虚析构
};
class BadDerived : public BadBase {
    int* big_;
public:
    BadDerived() : big_(new int[1000]) {}
    ~BadDerived() { delete[] big_; std::cout << "~BadDerived\n"; }
};

int main() {
    BadBase* p = new BadDerived();
    delete p;      // ⚠ 只输出 ~BadBase！子类析构没执行 → big_ 泄漏 4000 字节
}
```

**修正**：基类析构函数声明为 `virtual ~Base() = default;`。**军规：只要类会被继承且通过基类指针删除，析构必须是 virtual**。

## 五、final 与类型识别

```cpp
class Locked : public Base {
public:
    void speak() const final;      // final：禁止后代再重写
};
// class Sub : public Locked {};  // 也可 final 整个类：禁止再继承

// 运行期类型识别 dynamic_cast（向下转型，需多态类型）
Animal* a = new Dog("旺财");
if (Dog* d = dynamic_cast<Dog*>(a)) {   // 成功返回指针，失败返回 nullptr
    d->fetch();
}

// typeid 拿到真实类型名
#include <typeinfo>
std::cout << typeid(*a).name();         // 3Dog（名字修饰因编译器而异）
```

## 六、综合实战：RPG 战斗模拟器

综合继承+多态+虚析构+抽象类：

```cpp
#include <iostream>
#include <memory>
#include <vector>
#include <string>
#include <random>

class Character {                          // 抽象基类
public:
    Character(std::string name, int hp, int atk)
        : name_(std::move(name)), hp_(hp), atk_(atk) {}
    virtual ~Character() = default;

    virtual void attack(Character& target) const = 0;   // 纯虚：每种角色攻击方式不同
    virtual void take_damage(int dmg) {
        hp_ -= dmg;
        std::cout << "  " << name_ << " 受到 " << dmg
                  << " 伤害（剩 " << (hp_ > 0 ? hp_ : 0) << "）\n";
    }

    bool alive() const { return hp_ > 0; }
    const std::string& name() const { return name_; }
    int atk() const { return atk_; }

protected:
    std::string name_;
    int hp_, atk_;
};

class Warrior : public Character {         // 战士：稳定输出
public:
    Warrior(const std::string& n) : Character(n, 120, 15) {}
    void attack(Character& t) const override {
        std::cout << name_ << " 挥剑攻击 " << t.name() << "！\n";
        t.take_damage(atk());
    }
};

class Mage : public Character {            // 法师：30% 概率暴击
public:
    Mage(const std::string& n) : Character(n, 80, 25) {}
    void attack(Character& t) const override {
        static std::mt19937 rng{std::random_device{}()};
        bool crit = std::uniform_int_distribution<>(1, 10)(rng) <= 3;
        int dmg = atk() * (crit ? 2 : 1);
        std::cout << name_ << (crit ? " 释放暴击火球！" : " 释放火球") << "\n";
        t.take_damage(dmg);
    }
};

int main() {
    // 智能指针数组管理多态对象
    std::vector<std::unique_ptr<Character>> team = {
        std::make_unique<Warrior>("勇者"),
        std::make_unique<Mage>("大法师"),
    };
    Character* monster = new Warrior("哥布林王");

    int round = 1;
    while (monster->alive() &&
           std::any_of(team.begin(), team.end(),
                       [](auto& c) { return c->alive(); })) {
        std::cout << "—— 回合 " << round++ << " ——\n";
        for (auto& c : team)
            if (c->alive() && monster->alive())
                c->attack(*monster);        // 多态调用
        if (monster->alive())
            monster->attack(*team[0]);
    }
    std::cout << (monster->alive() ? "团灭……" : "胜利！") << "\n";
    delete monster;
}
```

新增"刺客""治疗者"只需继承 Character 实现 attack——**对扩展开放，对修改关闭**，这就是多态的工程价值。

## 七、组合优先原则

```cpp
// 继承："是一个"（Dog 是 Animal）——强耦合
// 组合："有一个"（Car 有 Engine）——灵活
class Engine { public: void start() {} };
class Car {
    Engine engine_;                  // 组合
public:
    void start() { engine_.start(); }   // 委托
};
```

**经验法则**：能用组合就用组合，"is-a"关系明确才用继承。

## 小练习

1. Shape 体系加 `Triangle`（三边长，海伦公式）与 `Square`
2. 写 `Employee` 抽象类 + `Manager/Sales`：月薪计算方式不同（虚函数 `salary()`），打印全员工资
3. 给 Character 加 `heal(Character&)` 接口与 Priest 职业实现治疗
4. 验证虚析构：把 BadBase 析构改成 virtual，观察输出变化
5. （概念）多态三条件是什么？override 和 final 分别解决什么问题？

## 本篇小结

- public 继承表达 is-a；构造先基后派、析构反序
- virtual 开启动态绑定：基类指针/引用按真实类型调函数；重写必标 override
- `= 0` 定义纯虚 → 抽象类不可实例化，作接口契约
- 基类析构必 virtual（通过基类指针删除时防泄漏）
- dynamic_cast 安全向下转型；组合优先于继承
- 新增子类不改老代码——开闭原则的 C++ 实现

**下一篇**：运算符重载与友元——让自定义类型像内置类型一样自然运算。

---

*本系列为 Cyber先锋社原创教程。RPG 案例的扩展性实验（加职业不动主逻辑）是多态最好的注脚。*
