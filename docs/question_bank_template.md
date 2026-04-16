---
# ========== 课程元数据 ==========
id: my_custom_course
name: 我的自定义课程
icon: 📚
description: 这是一个自定义课程示例
version: 1
difficulty: beginner
level: L1
---

# 我的自定义课程

> 本文档是 JellyBuddy 题库模板。按照本结构编写 MD 文件即可导入自定义课程。
>
> **使用方法**：App 内「课程」页 → 右上角 📥 导入 → 选择 .md 文件

---

## Lesson 1: 第一课标题

<!-- lesson-meta
order: 1
xpReward: 50
diamondReward: 1
isBoss: false
-->

### Question 1.1 (choice, easy)

下列哪个是合法的 Python 变量名？

```python
name = "Alice"
age = 25
```

- [ ] 2name
- [x] name2
- [ ] my-name
- [ ] my name

**解析**: 变量名必须以字母或下划线开头，不能包含连字符或空格。

**相关概念**: variable_naming, python_basics

---

### Question 1.2 (fillBlank, easy)

请写出创建一个名为 `score` 值为 `95` 的变量的代码：

```python
# 在此写代码
```

**答案**: `score = 95` | `score=95`

**解析**: 变量赋值使用 `=` 号，等号两边可有空格也可没有。

**相关概念**: variable_assignment

---

### Question 1.3 (sort, medium)

将以下代码按正确执行顺序排列：

- A. `x = 10`
- B. `print(x)`
- C. `x = x + 5`

**顺序**: A, C, B

**解析**: 必须先声明变量，再修改它，最后打印。

---

### Question 1.4 (code, medium)

写一个函数 `add`，接受两个参数返回它们的和：

```python
def add(a, b):
    # 在此写 return 语句
```

**答案**: `return a + b` | `return a+b`

**解析**: 使用 `return` 关键字返回表达式的值。

---

## Lesson 2: 第二课标题

<!-- lesson-meta
order: 2
xpReward: 60
diamondReward: 1
-->

### Question 2.1 (choice, easy)

Python 中如何打印 "Hello, World!"？

- [x] `print("Hello, World!")`
- [ ] `echo "Hello, World!"`
- [ ] `console.log("Hello, World!")`
- [ ] `System.out.println("Hello, World!")`

**解析**: Python 使用 `print()` 函数输出到控制台。

---

## 🎯 BOSS 关卡

<!-- lesson-meta
order: 99
xpReward: 200
diamondReward: 5
isBoss: true
-->

### Question B.1 (choice, hard)

综合题 — 以下哪段代码是合法的 Python？

```python
# 代码片段
def greet(name):
    return f"Hello, {name}!"
```

- [x] 上面的代码
- [ ] `function greet(name) { return "Hello " + name; }`
- [ ] `public String greet(String name) { return "Hello"; }`
- [ ] `greet = name -> "Hello " + name`

**解析**: Python 使用 `def` 关键字定义函数，f-string 是 Python 3.6+ 的语法。

---

# 📖 模版格式说明

## Frontmatter (YAML)

必填字段：
- `id`: 课程唯一 ID（英文小写，下划线分隔）
- `name`: 课程显示名称
- `icon`: 单个 emoji
- `description`: 课程描述

可选字段：
- `version`: 版本号（默认 1）
- `difficulty`: beginner / intermediate / advanced
- `level`: L1 / L2 / L3 / L4 / L5

## Lesson 结构

使用 `## Lesson N: 标题` 作为二级标题。

Lesson 元数据使用 HTML 注释：
```
<!-- lesson-meta
order: 1
xpReward: 50
diamondReward: 1
isBoss: false
-->
```

## Question 结构

使用 `### Question X.Y (类型, 难度)` 作为三级标题。

**类型** (4 种)：
- `choice` — 选择题（单选）
- `fillBlank` — 填空题
- `sort` — 排序题
- `code` — 编程题

**难度** (3 级)：
- `easy` — 简单
- `medium` — 中等
- `hard` — 困难

### Choice 格式

```
题目内容

- [ ] 错误选项 A
- [x] 正确选项 B
- [ ] 错误选项 C
- [ ] 错误选项 D

**解析**: 解释文字
```

### FillBlank / Code 格式

```
题目内容

**答案**: 正确答案1 | 正确答案2 | 正确答案3

**解析**: 解释文字
```

多个正确答案用 `|` 分隔。

### Sort 格式

```
题目内容

- A. 第一项
- B. 第二项
- C. 第三项

**顺序**: A, C, B

**解析**: 解释文字
```

## 可选字段

所有题型都支持：

- **代码片段**: 用 ` ```language ... ``` ` 代码块
- **相关概念**: `**相关概念**: concept1, concept2`

## 完整示例

查看本文档顶部的 Lesson 示例。
