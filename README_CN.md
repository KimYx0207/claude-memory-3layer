# 🧠 Claude Code 三层记忆系统

<div align="center">

![GitHub stars](https://img.shields.io/github/stars/KimYx0207/claude-memory-3layer?style=social)
![GitHub forks](https://img.shields.io/github/forks/KimYx0207/claude-memory-3layer?style=social)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Claude Code](https://img.shields.io/badge/Claude_Code-v2.1%2B-blueviolet.svg)
![Python](https://img.shields.io/badge/Python-3.8%2B-green.svg)
![Dependencies](https://img.shields.io/badge/Dependencies-Zero-brightgreen.svg)

**给 Claude Code 一个真正的记忆 — 结构化、可追踪、Token可控**

</div>

> 🧠 **官方自动记忆没有的管理层，这个项目帮你补上**

> ⚡ 一行命令安装 | 零依赖 | ~1500 tokens 预算

> 🤝 与官方自动记忆（v2.1.59+）共存互补，不是替代关系

> 🔗 **GitHub**：[https://github.com/KimYx0207/claude-memory-3layer](https://github.com/KimYx0207/claude-memory-3layer)

> [English Version / 英文版本](README.md)

---

## 📞 联系方式

<div align="center">
  <img src="images/二维码基础款.png" alt="联系方式" width="600"/>
  <p><strong>获取更多AI资讯和技术支持</strong></p>
  <p>
    🌐 <a href="https://www.aiking.dev/">aiking.dev</a> | 𝕏 <a href="https://x.com/KimYx0207">@KimYx0207</a> | 微信公众号：<strong>老金带你玩AI</strong> | 个人微信号：备注'AI'加群交流
  </p>
</div>

### ☕ 请我喝杯咖啡

<div align="center">
  <p><strong>如果这个项目对你有帮助，欢迎打赏支持！</strong></p>
  <table align="center">
    <tr>
      <td align="center">
        <img src="images/微信.jpg" alt="微信收款码" width="300"/>
        <br/>
        <strong>微信支付</strong>
      </td>
      <td align="center">
        <img src="images/支付宝.jpg" alt="支付宝收款码" width="300"/>
        <br/>
        <strong>支付宝</strong>
      </td>
    </tr>
  </table>
</div>

---

## 📖 为什么需要这个项目

Claude Code 每次关掉终端，记忆就清零。Anthropic 提供了两个解决方案：

- **CLAUDE.md** — 手动维护的规则文件，你写什么它读什么
- **自动记忆（v2.1.59+）** — AI驱动，Claude自己判断什么值得记

官方自动记忆在**知识发现**上做得很棒。但知识发现只是记忆系统的一半。

**另一半 — 生命周期管理、Git追踪、团队共享、Token精确控制 — 就是这个项目要解决的。**

这不是替代品，而是官方自动记忆没有的管理层。两套一起用，效果最好。

### 🧬 官方 + 三层记忆：各管一半才完整

| 维度 | 官方 v2.1.59 | 三层记忆系统 | 谁更合适 |
|------|-------------|-------------|---------|
| 知识发现 | AI语义理解（智能） | 关键词匹配（规则） | 官方碾压 |
| 安装成本 | 零配置 | 一行命令 | 官方更省心 |
| 存储格式 | Markdown（平面文本+主题文件） | 三层结构（JSON + MD + MD） | 三层更灵活 |
| Git追踪 | ❌ `~/.claude/projects/`（隐藏目录） | ✅ `.claude/memory/`（项目内） | 三层独有 |
| 生命周期 | 只进不出，越写越长 | `status` 字段管理（active/superseded） | 三层独有 |
| Token控制 | 截断前200行（Token数不可控） | 每个主题~1500 tokens（可配置） | 三层更可控 |
| 团队共享 | ❌ 仅本地 | ✅ 通过git共享 | 三层独有 |
| 知识清理 | ❌ 无 | ✅ `/memory-review` 自动建议 | 三层独有 |

---

## ✨ 核心特性

- 🧠 **三层架构** — 知识图谱（JSON）+ 每日笔记（MD）+ 隐性知识（MD）
- ♻️ **生命周期管理** — 知识可以过期（`active` → `superseded`），保持精简
- 📁 **Git可追踪** — 所有记忆存在 `.claude/memory/`，可提交、可共享、可Review
- 🎯 **Token高效** — 每个主题~1500 tokens（<1% 的 200K 上下文窗口），完全可配置
- 📦 **零依赖** — 纯Python标准库，不需要pip install
- 🔌 **Hook驱动** — SessionStart / PostToolUse / PreCompact 生命周期钩子
- 🧹 **智能清理** — `/memory-review` 自动发现过时条目并建议清理
- 🤝 **与官方共存** — 和自动记忆、CLAUDE.md 完美共存

---

## 🚀 快速开始

### 一行命令安装

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/KimYx0207/claude-memory-3layer/main/install.sh | bash

# Windows PowerShell
irm https://raw.githubusercontent.com/KimYx0207/claude-memory-3layer/main/install.ps1 | iex
```

### 手动安装

```bash
git clone https://github.com/KimYx0207/claude-memory-3layer.git
cd claude-memory-3layer
./install.sh   # Windows 用 .\install.ps1
```

### 安装后的目录结构

```
你的项目/
└── .claude/
    ├── hooks/
    │   ├── memory_loader.py      # SessionStart钩子：加载三层记忆
    │   ├── memory_extractor.py   # PostToolUse钩子：提取知识
    │   ├── session_state.py      # 会话状态管理
    │   └── pre_compact.py        # PreCompact钩子：压缩前保存
    ├── memory/
    │   ├── MEMORY.md             # Layer 3：隐性知识
    │   ├── memory/               # Layer 2：每日笔记
    │   └── areas/topics/         # Layer 1：知识图谱
    ├── commands/
    │   ├── memory-review.md      # /memory-review 命令
    │   └── memory-status.md      # /memory-status 命令
    └── settings.json             # Hook注册配置
```

---

## ⚙️ 工作原理

### 架构总览

```
┌─────────────────────────────────────────────────────────────┐
│                    Claude Code 会话                           │
│                                                              │
│  会话启动 ──→ memory_loader.py ──→ 加载三层记忆              │
│       │                                    │                  │
│       ▼                                    ▼                  │
│  [注入 ~1500 tokens 的记忆上下文]                            │
│                                                              │
│  ... 工作中 ...                                              │
│                                                              │
│  工具使用后 ──→ memory_extractor.py ──→ 保存到 L1 + L2       │
│       │                                                      │
│  压缩前 ──→ pre_compact.py ──→ 保存会话状态                  │
│       │                                                      │
│  会话结束 ──→ （状态持久化到下次会话）                        │
└─────────────────────────────────────────────────────────────┘
```

### 三层架构，三个用途

```
┌─────────────────────────────────────────────────┐
│              会话启动时加载                       │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────────┐  │
│  │ Layer 1   │  │ Layer 2   │  │ Layer 3       │  │
│  │ JSON格式  │  │ Markdown  │  │ Markdown      │  │
│  │           │  │           │  │               │  │
│  │ 知识图谱  │  │ 每日笔记  │  │ 隐性知识      │  │
│  │           │  │           │  │               │  │
│  │ 每个主题  │  │ 最近3天   │  │ 全文加载      │  │
│  │ 最近10条  │  │           │  │               │  │
│  └──────────┘  └──────────┘  └──────────────┘  │
│        │              │              │           │
│        └──────────────┴──────────────┘           │
│                       │                          │
│          每个主题 ~1500 tokens                    │
│          （<1% 的 200K 上下文窗口）               │
└─────────────────────────────────────────────────┘
```

### Layer 1：知识图谱（JSON格式）

结构化的知识条目，支持生命周期管理。

```json
{
  "id": "fact-20260227143022",
  "fact": "这个项目用pnpm不用npm",
  "timestamp": "2026-02-27",
  "status": "active"
}
```

- 存储路径：`.claude/memory/areas/topics/<主题>/items.json`
- 每条记录有 `status` 字段：`active`（活跃）或 `superseded`（已过期）
- 会话启动时只加载 `active` 状态的条目
- PostToolUse 钩子自动提取

### Layer 2：每日笔记（Markdown格式）

今天做了什么——自动追加，永不编辑。

```markdown
# 2026-02-27

## 14:30
重构了认证模块，从Session改为JWT
主题：authentication, refactoring

## 16:45
修复了用户列表的N+1查询问题
主题：performance, postgres
```

- 存储路径：`.claude/memory/memory/YYYY-MM-DD.md`
- 会话启动时加载最近3天
- 提供时间维度的上下文（"昨天我在做什么？"）

### Layer 3：隐性知识（Markdown格式）

无法自动提取的宝贵经验。

```markdown
## 架构决策
- 选了FastAPI而不是Flask，因为需要异步支持

## 踩坑记录
- Redis连接池必须在shutdown时显式关闭
- 测试中永远不要用 `datetime.now()`，要mock

## 工具偏好
- 用ruff代替flake8+black
```

- 存储路径：`.claude/memory/MEMORY.md`
- 手动维护（类似官方的 CLAUDE.md）
- 会话启动时全文加载

---

## 🔧 Hook 注册

安装脚本会自动在 `.claude/settings.json` 中注册钩子。如果需要手动添加：

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "python .claude/hooks/memory_loader.py"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "python .claude/hooks/memory_extractor.py"
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "python .claude/hooks/pre_compact.py"
          }
        ]
      }
    ]
  }
}
```

---

## 🛠️ 命令

### `/memory-review`

定期知识清理——发现值得沉淀的模式，清理过时的条目。

- 扫描三层记忆的全量数据，做高频+趋势+衰退三维分析
- 建议将反复出现的模式提升到 `CLAUDE.md` 作为永久规则
- 建议将过时的条目标记为 `superseded`
- 既管"加"也管"减"——保持知识库精简

### `/memory-status`

查看记忆系统统计——条目数量、日期范围、Token估算。

---

## 🎛️ 配置

### 环境变量

| 变量 | 默认值 | 说明 |
|------|-------|------|
| `MEMORY_DIR` | `.claude/memory/` | 自定义记忆目录路径 |
| `MEMORY_MAX_ITEMS` | `10` | 每个主题加载的最大活跃条目数 |
| `MEMORY_DAILY_DAYS` | `3` | 加载最近几天的每日笔记 |
| `MEMORY_TOPICS` | （自动检测） | 自定义主题映射（`关键词:主题,关键词:主题`） |

### 自定义主题

设置 `MEMORY_TOPICS` 来定义自定义的关键词到主题映射：

```bash
export MEMORY_TOPICS="fastapi:backend,react:frontend,stripe:payments"
```

---

## ♻️ 生命周期管理

官方自动记忆没有的核心功能：**知识可以过期**。

```
Active（活跃）──── 正常使用，会话启动时加载
   │
   ▼
Superseded（已过期）──── 已过时，不再加载，保留供参考
```

要标记一条知识为过期，修改 `items.json` 中的 `status`：

```json
{
  "id": "fact-20260101",
  "fact": "用Flask做API服务器",
  "status": "superseded"
}
```

或者用 `/memory-review` 命令自动检测并清理过时条目。

---

## 📊 Token 预算分析

系统设计为每个主题在会话启动时消耗不超过 ~1500 tokens：

| 组件 | 估计Token数 |
|------|------------|
| Layer 3（MEMORY.md，典型值） | ~300 |
| Layer 2（3天 × ~3条记录） | ~400 |
| Layer 1（每个主题10条 × ~15个词） | ~600 |
| 标题和格式化 | ~100 |
| **合计（单主题）** | **~1400** |

多主题线性增长。通过 `MEMORY_MAX_ITEMS` 环境变量控制。

这不到 Claude 200K 上下文窗口的 1%。

---

## ✅ 兼容性

- **Claude Code**：v2.1.0+（需要hooks支持）
- **Python**：3.8+（仅标准库，零依赖）
- **操作系统**：macOS、Linux、Windows
- **可共存**：官方自动记忆（v2.1.59+）、CLAUDE.md

---

## 📁 项目结构

```
claude-memory-3layer/
├── SKILL.md              # Claude Code Skill 清单
├── README.md             # 英文文档
├── README_CN.md          # 中文文档（本文件）
├── LICENSE               # MIT 协议
├── install.sh            # Unix/macOS 安装脚本
├── install.ps1           # Windows 安装脚本
├── images/               # 图片和二维码
├── hooks/
│   ├── memory_loader.py  # SessionStart：加载三层记忆
│   ├── memory_extractor.py # PostToolUse：提取知识
│   ├── session_state.py  # 会话生命周期状态
│   └── pre_compact.py    # PreCompact：压缩前保存
├── commands/
│   ├── memory-review.md  # /memory-review 命令
│   └── memory-status.md  # /memory-status 命令
├── templates/
│   ├── MEMORY.md         # Layer 3 模板
│   └── items.json        # Layer 1 模板
└── docs/
    ├── quickstart.md     # 快速上手指南
    ├── architecture.md   # 系统架构深度解析
    └── vs-official.md    # 与官方方案详细对比
```

---

## 📊 项目统计

| 指标 | 数值 |
|------|------|
| **Hook脚本** | 4个（SessionStart、PostToolUse、PreCompact、State） |
| **记忆层级** | 3层（知识图谱 + 每日笔记 + 隐性知识） |
| **命令** | 2个（`/memory-review`、`/memory-status`） |
| **依赖** | 0（纯Python标准库） |
| **Token预算** | 每个主题~1500（可配置） |
| **Python版本** | 3.8+ |
| **Claude Code版本** | v2.1.0+（已在v2.1.59上测试） |

---

## 🎯 适用人群

- ✅ **Claude Code 重度用户** — 需要结构化的跨会话持久记忆
- ✅ **团队开发者** — 需要可Git追踪、可共享的知识库
- ✅ **Token敏感用户** — 需要精确控制上下文窗口使用
- ✅ **多项目开发者** — 需要按项目管理知识
- ✅ **DIY爱好者** — 想完全掌控Claude记住什么

---

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！请注意：

1. 保持零依赖策略（仅Python标准库）
2. 在 macOS + Windows 上测试
3. 遵循现有代码风格

---

## 📄 许可证

本项目采用 [MIT License](LICENSE) 开源协议。

---

## 🙏 致谢

- [Anthropic](https://www.anthropic.com/) — 感谢构建 Claude Code
- Claude Code 社区 — 感谢反馈和建议
- 所有参与官方自动记忆讨论的贡献者

---

## 👤 作者

**KimYx0207**（老金 / LaojinAI）— 专注 Claude Code 效率工具开发

<div align="center">
  <p>
    🌐 <a href="https://www.aiking.dev/">aiking.dev</a> | 𝕏 <a href="https://x.com/KimYx0207">@KimYx0207</a> | 微信公众号：<strong>老金带你玩AI</strong>
  </p>
</div>

---

## 📋 更新日志

### v1.0.0 (2026-02-27) — 首次发布

- 三层记忆架构（知识图谱 + 每日笔记 + 隐性知识）
- 4个生命周期钩子（SessionStart、PostToolUse、PreCompact、State）
- 一行命令安装（macOS/Linux/Windows）
- `/memory-review` 和 `/memory-status` 命令
- 与官方自动记忆（v2.1.59+）互补设计
- 零依赖（纯Python标准库）
- 完整文档（快速上手、架构解析、方案对比）
