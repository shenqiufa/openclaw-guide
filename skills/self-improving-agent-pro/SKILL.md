---
name: self-improving-agent-pro
description: "AI 自我改进与记忆系统（增强版）v4.7 - 整合 Claude Code 全套設計，新增 AutoDream 自動做夢、上下文壓縮、CLAUDE.md 配置、斜杠命令、權限 allowlist、記憶提取優化。在 v4.7 基礎上實現從"被動記錄"到"主動整理"的轉變，具備完整的智能體運行時能力。結合 GitHub 原版精華 + ClawHub 中文版優點，解決'同類錯誤反覆犯、用戶糾正不長記性'的痛點。"
version: 4.7.1
author: 發哥的龍蝦（整合版）
homepage: https://github.com/peterskoett/self-improving-agent
license: MIT
metadata:
  openclaw:
    emoji: 🧠
    requires:
      bins: [grep, jq]
---

# Self-Improving Agent Pro - AI 自我改进系统（增强版）

让 AI 从错误中学习，越用越聪明。**结合 GitHub 原版精华 + ClawHub 中文版优点**。

## 🎯 核心解决的问题

| 问题 | 说明 | 解决方式 |
|------|------|----------|
| ❌ **命令失败反复犯** | 同样的操作失败，下次还用同样的错误方式 | 错误记录 + 执行前检查 |
| ❌ **用户纠正不记住** | 反复纠正写法、偏好、风格，下个会话又忘了 | 纠正记录 + 跨会话同步 |
| ❌ **同一个坑反复踩** | 同一个项目里反复踩同一个坑 | 重复模式检测（Recurrence-Count） |
| ❌ **最佳实践没系统化** | 发现更好的做法，却没有系统化记住 | 最佳实践记录 + Promotion |
| ❌ **外部工具变动不知道** | API/工具更新了，AI 还在用旧知识 | 知识更新追踪（knowledge_gap） |
| ❌ **经验不跨会话** | 重要经验只存在于当前会话，跨天/跨项目就丢失 | 全局记忆 + 项目记忆同步 |

---

## 📁 文件结构

```
~/.openclaw/workspace/.learnings/
├── LEARNINGS.md          # 学习记录（纠正、最佳实践、知识更新）
├── ERRORS.md             # 错误记录（命令失败、异常）
├── FEATURE_REQUESTS.md   # 功能请求（用户请求的新能力）
└── index.json            # 快速索引（可选）

~/.openclaw/memory/self-improving/  # 全局记忆（跨项目）
├── LEARNINGS.md
├── ERRORS.md
└── FEATURE_REQUESTS.md
```

---

## 🔍 四种记录类型

| 类型 | 文件 | 触发场景 | 示例 |
|------|------|----------|------|
| **错误记录** | `ERRORS.md` | 命令失败（退出码非 0） | `npm install` 权限失败 |
| **学习记录** | `LEARNINGS.md` | 用户纠正、最佳实践、知识更新 | 项目要求单引号 |
| **功能请求** | `FEATURE_REQUESTS.md` | 用户请求新功能 | "能不能自动备份？" |
| **重复模式** | `LEARNINGS.md` | 类似问题反复出现 | Recurrence-Count >= 3 |

---

## 🆔 唯一 ID 系统

**格式：** `TYPE-YYYYMMDD-XXX`

| 类型 | 前缀 | 示例 |
|------|------|------|
| **学习记录** | `LRN` | `LRN-20260315-001` |
| **错误记录** | `ERR` | `ERR-20260315-A3F` |
| **功能请求** | `FEAT` | `FEAT-20260315-002` |

**生成规则：**
- `TYPE`: LRN / ERR / FEAT
- `YYYYMMDD`: 当前日期
- `XXX`: 序列号 (001, 002) 或随机 3 字符 (A3F, B7X)

---

## 📝 记录格式

### 学习记录（LEARNINGS.md）

```markdown
## [LRN-20260315-001] 代码风格规范

**Logged**: 2026-03-15T14:00:00Z
**Priority**: medium
**Status**: pending
**Area**: config

### Summary
项目代码风格要求：字符串使用单引号，不是双引号

### Details
用户纠正：项目规范约定使用单引号
错误示例：const name = "test"
正确示例：const name = 'test'

### Suggested Action
所有新代码使用单引号，现有代码逐步替换

### Metadata
- Source: user_correction
- Trigger Words: ["不对", "应该", "错了"]
- Related Files: AGENTS.md
- Tags: ["code-style", "string", "convention"]
- See Also: (如有相关条目)
- Pattern-Key: code-style.quotes (用于重复检测)
- Recurrence-Count: 1
- First-Seen: 2026-03-15
- Last-Seen: 2026-03-15

---
```

### 错误记录（ERRORS.md）

```markdown
## [ERR-20260315-001] npm_install_global

**Logged**: 2026-03-15T13:30:00Z
**Priority**: high
**Status**: pending
**Area**: infra

### Summary
npm install -g 权限失败

### Error
```
EACCES: permission denied, access '/usr/local/lib/node_modules'
```

### Context
- Command: npm install -g xxx
- Environment: Linux (Alibaba Cloud)
- User: admin (non-root)

### Suggested Fix
1. 使用 sudo: `sudo npm install -g xxx`
2. 或本地安装：`npm install xxx` (不加 -g)
3. 或配置 npm prefix: `npm config set prefix ~/.npm-global`

### Metadata
- Reproducible: yes
- Related Files: ~/.bashrc
- See Also: (如有相关条目)

### Resolution (解决后填写)
- **Resolved**: 2026-03-15T14:00:00Z
- **Fix**: 改用本地安装
- **Notes**: 全局安装需要 root 权限，本地安装足够使用

---
```

### 功能请求（FEATURE_REQUESTS.md）

```markdown
## [FEAT-20260315-001] 自动备份功能

**Logged**: 2026-03-15T15:00:00Z
**Priority**: medium
**Status**: pending
**Area**: infra

### Requested Capability
用户希望安装 skill 前自动备份现有配置

### User Context
防止安装新 skill 后配置被覆盖或破坏

### Complexity Estimate
medium

### Suggested Implementation
1. 安装前检测现有文件
2. 自动备份到 ~/.openclaw/backup/
3. 安装失败时恢复

### Metadata
- Frequency: recurring
- Related Features: skill-vetter

---
```

---

## 🔄 状态管理系统

| 状态 | 说明 | 何时使用 |
|------|------|----------|
| `pending` | 待处理 | 新记录的条目 |
| `in_progress` | 处理中 | 正在解决的问题 |
| `resolved` | 已解决 | 问题已修复 |
| `promoted` | 已提升 | 已 Promote 到 AGENTS.md 等 |
| `wont_fix` | 不修复 | 决定不解决（需说明原因） |

**状态变更示例：**
```markdown
### Resolution
- **Resolved**: 2026-03-15T14:00:00Z
- **Fix**: 改用本地安装
- **Notes**: 全局安装需要 root 权限

### Promotion (如适用)
- **Promoted**: AGENTS.md
- **Promoted At**: 2026-03-15T16:00:00Z
```

---

## 🎯 优先级系统（4 级）

| 优先级 | 说明 | 示例 | 响应要求 |
|--------|------|------|----------|
| **critical** | 阻塞核心功能、数据丢失风险、安全问题 | 凭证泄露、数据删除 | 立即处理 |
| **high** | 重大影响、影响常见工作流、反复出现 | 常用命令失败 | 24 小时内 |
| **medium** | 中等影响、有变通方案 | 代码风格问题 | 本周内 |
| **low** | 小问题、边缘情况、nice-to-have | 文档拼写错误 | 有空时 |

---

## 🏷️ 区域标签（Area Tags）

| Area | 范围 | 示例 |
|------|------|------|
| `frontend` | UI、组件、客户端代码 | React、Vue、CSS |
| `backend` | API、服务、服务端代码 | Node.js、Python、数据库 |
| `infra` | CI/CD、部署、Docker、云 | 服务器、网络、权限 |
| `tests` | 测试文件、测试工具 | Jest、Pytest、E2E |
| `docs` | 文档、注释、README | 说明文档、API 文档 |
| `config` | 配置文件、环境、设置 | .env、openclaw.json |

---

## 🚀 工作流程

### 完整流程

```
┌─────────────────┐
│  用户指令/任务   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 执行前检查记忆   │ ← grep 搜索 .learnings/
│ "这个命令之前失败过吗？"│
└────────┬────────┘
         │
    ┌────┴────┐
    │ 有记忆  │ 没有记忆
    │         │
    ▼         ▼
┌────────┐ ┌──────────┐
│ 应用经验│ │ 正常执行 │
│ "上次失败，改用..." │ │
└────────┘ └────┬─────┘
                │
                ▼
         ┌──────────────┐
         │   执行结果    │
         └──────┬───────┘
                │
         ┌──────┴───────┐
         │              │
    成功 ✅         失败 ❌
         │              │
         │              ▼
         │      ┌──────────────┐
         │      │ 记录错误记忆  │ ← log_error()
         │      │ "npm install 权限失败"│
         │      └──────────────┘
         │
         ▼
┌────────────────┐
│ 用户反馈        │
│ "不对，应该..." │
└───────┬────────┘
        │
        ▼
┌────────────────┐
│ 记录纠正记忆    │ ← log_correction()
│ "项目用单引号"  │
└────────────────┘
```

---

## 🔍 触发词库

### 用户纠正触发词

| 触发词 | 含义 | 示例 |
|--------|------|------|
| "不对" | 直接否定 | "不对，应该用单引号" |
| "错了" | 指出错误 | "错了，参数顺序反了" |
| "应该" | 给出正确方式 | "应该先检查权限" |
| "不对，我之前说过" | 反复纠正 | "不对，我之前说过用这个 API" |
| "不是...是..." | 对比纠正 | "不是 npm 是 pnpm" |
| "请记住" | 明确要求记忆 | "请记住这个配置" |
| "No, that's wrong" | 英文纠正 | "No, that's wrong..." |
| "Actually..." | 英文纠正 | "Actually, it should be..." |

### 最佳实践触发词

| 触发词 | 含义 | 示例 |
|--------|------|------|
| "更好的" | 改进建议 | "有个更好的方法" |
| "更高效" | 效率提升 | "这样更高效" |
| "最优" | 最佳方案 | "这是最优解" |
| "推荐" | 推荐做法 | "推荐用这个库" |
| "最佳实践" | 明确最佳 | "这是最佳实践" |
| "better way" | 英文 | "There's a better way" |

### 知识过时触发词

| 触发词 | 含义 | 示例 |
|--------|------|------|
| "过时了" | 知识过期 | "这个 API 过时了" |
| "已废弃" | 明确废弃 | "v1 已废弃，用 v2" |
| "新版是" | 版本更新 | "新版是这样写的" |
| "不再支持" | 功能移除 | "不再支持这个参数" |
| "deprecated" | 英文 | "This is deprecated" |

---

## 📤 Promotion 机制（核心功能）

### 何时 Promotion

当学习记录满足以下条件时，Promote 到永久记忆：

| 条件 | 说明 |
|------|------|
| **跨项目适用** | 不只适用于当前项目 |
| **防止反复犯错** | 能避免常见错误 |
| **项目规范** | 任何贡献者（人类或 AI）都应该知道 |
| **重复出现 >= 3 次** | Recurrence-Count >= 3 |
| **跨越 >= 2 个任务** | 在不同任务中都出现过 |
| **30 天窗口内** | 最近 30 天内发生 |

### Promotion 目标

| 学习类型 | Promote 到 | 示例 |
|---------|-----------|------|
| **行为规范** | `SOUL.md` | "简洁回复，避免免责声明" |
| **工作流改进** | `AGENTS.md` | "长任务 spawn sub-agent" |
| **工具注意事项** | `TOOLS.md` | "Git push 需要先配置 auth" |
| **项目规范** | `CLAUDE.md` 或项目文档 | "使用 pnpm，不是 npm" |
| **通用经验** | `MEMORY.md` | 长期记忆 |

### Promotion 示例

**学习记录（详细）：**
```markdown
项目使用 pnpm workspaces。尝试 `npm install` 但失败。
Lock 文件是 `pnpm-lock.yaml`。必须使用 `pnpm install`。
```

**Promote 到 AGENTS.md（简洁 actionable）：**
```markdown
## 构建与依赖
- 包管理器：pnpm (不是 npm) - 使用 `pnpm install`
- Lock 文件：pnpm-lock.yaml
```

---

## 🔁 重复模式检测

### 检测流程

```bash
# 1. 搜索类似条目
grep -r "关键词" ~/.openclaw/workspace/.learnings/

# 2. 检查 Pattern-Key
grep -n "Pattern-Key: code-style.quotes" ~/.learnings/LEARNINGS.md

# 3. 如果找到：
#    - Recurrence-Count +1
#    - 更新 Last-Seen
#    - 添加 See Also 链接

# 4. 如果 Recurrence-Count >= 3：
#    - 提升优先级
#    - 考虑 Promotion
#    - 考虑系统性修复
```

### 重复模式处理

| Recurrence-Count | 行动 |
|-----------------|------|
| **1** | 正常记录 |
| **2** | 添加 See Also 链接，提升注意 |
| **3+** | 提升优先级，考虑 Promotion |
| **5+** | 系统性修复（文档/自动化/架构） |

---

## 🛠️ 使用方法

### 1. 初始化（首次使用）

```bash
# 创建学习目录
mkdir -p ~/.openclaw/workspace/.learnings
mkdir -p ~/.openclaw/memory/self-improving

# 创建记录文件（带表头）
cat > ~/.openclaw/workspace/.learnings/LEARNINGS.md << 'EOF'
# Learnings

记录用户纠正、最佳实践、知识更新。

## 索引
| ID | 日期 | 类别 | 优先级 | 状态 | 摘要 |
|----|------|------|--------|------|------|
EOF

cat > ~/.openclaw/workspace/.learnings/ERRORS.md << 'EOF'
# Errors

记录命令失败、异常。

## 索引
| ID | 日期 | 命令 | 优先级 | 状态 | 摘要 |
|----|------|------|--------|------|------|
EOF

cat > ~/.openclaw/workspace/.learnings/FEATURE_REQUESTS.md << 'EOF'
# Feature Requests

记录用户请求的新功能。

## 索引
| ID | 日期 | 功能 | 优先级 | 状态 | 摘要 |
|----|------|------|--------|------|------|
EOF
```

### 2. 记录错误

```bash
# 手动记录（推荐格式）
cat >> ~/.openclaw/workspace/.learnings/ERRORS.md << 'EOF'

## [ERR-20260315-001] npm_install_global

**Logged**: 2026-03-15T13:30:00Z
**Priority**: high
**Status**: pending
**Area**: infra

### Summary
npm install -g 权限失败

### Error
```
EACCES: permission denied
```

### Suggested Fix
use sudo or install locally

---
EOF
```

### 3. 记录用户纠正

```bash
# 当用户说"不对，应该用单引号"
cat >> ~/.openclaw/workspace/.learnings/LEARNINGS.md << 'EOF'

## [LRN-20260315-001] 代码风格规范

**Logged**: 2026-03-15T14:00:00Z
**Priority**: medium
**Status**: pending
**Area**: config

### Summary
项目代码风格：字符串使用单引号

### Details
用户纠正：项目规范约定使用单引号

### Metadata
- Source: user_correction
- Pattern-Key: code-style.quotes
- Recurrence-Count: 1

---
EOF
```

### 4. 执行前检查

```bash
# 执行命令前，检查是否有相关记忆
grep -i "npm install" ~/.openclaw/workspace/.learnings/ERRORS.md

# 如果有记录，会显示：
# ## [ERR-20260315-001] npm_install_global
# npm install -g 权限失败 → 改用本地安装
```

### 5. 定期审查

```bash
# 统计待处理条目
grep -h "Status\*\*: pending" ~/.openclaw/workspace/.learnings/*.md | wc -l

# 列出高优先级待处理项
grep -B5 "Priority\*\*: high" ~/.openclaw/workspace/.learnings/*.md | grep "^## \["

# 查找特定区域的记录
grep -l "Area\*\*: infra" ~/.openclaw/workspace/.learnings/*.md

# 查找重复模式（Recurrence-Count >= 3）
grep -B10 "Recurrence-Count: [3-9]" ~/.openclaw/workspace/.learnings/LEARNINGS.md
```

---

## 📊 与现有记忆系统集成

### OpenClaw 记忆层级

```
~/.openclaw/
├── workspace/
│   ├── SOUL.md              # 行为规范（Promotion 目标）
│   ├── AGENTS.md            # 工作流改进（Promotion 目标）
│   ├── TOOLS.md             # 工具注意事项（Promotion 目标）
│   ├── MEMORY.md            # 长期记忆（Promotion 目标）
│   └── .learnings/          # 本技能记录
│       ├── LEARNINGS.md
│       ├── ERRORS.md
│       └── FEATURE_REQUESTS.md
└── memory/
    ├── self-improving/      # 全局记忆（跨项目）
    │   ├── LEARNINGS.md
    │   ├── ERRORS.md
    │   └── FEATURE_REQUESTS.md
    └── YYYY-MM-DD.md        # 每日记忆
```

### 同步规则

| 类型 | 项目级 | 全局级 |
|------|--------|--------|
| **项目特定** | `.learnings/` | ❌ |
| **通用经验** | `.learnings/` + `~/.openclaw/memory/self-improving/` | ✅ |
| **Promotion** | `SOUL.md` / `AGENTS.md` / `TOOLS.md` / `MEMORY.md` | ✅ |

---

## 💡 最佳实践

1. **立即记录** — 上下文最新时记录
2. **具体详细** — 未来 agent 需要快速理解
3. **包含复现步骤** — 特别是错误
4. **链接相关文件** — 便于修复
5. **建议具体修复** — 不只是"调查"
6. **使用一致分类** — 便于过滤
7. **积极 Promotion** — 如果不确定，就 Promote
8. **定期审查** — 过时的学习失去价值

---

## 🔧 自动化脚本（可选）

### log_error.sh

```bash
#!/bin/bash
# 记录错误
# 用法：log_error.sh "命令" "错误信息" "修复建议"

ID="ERR-$(date +%Y%m%d)-$(printf '%03d' $(shuf -i 1-999 -n 1))"
DATE=$(date -Iseconds)

cat >> ~/.openclaw/workspace/.learnings/ERRORS.md << EOF

## [$ID] $(echo $1 | tr ' ' '_')

**Logged**: $DATE
**Priority**: high
**Status**: pending
**Area**: infra

### Summary
$1 失败

### Error
\`\`\`
$2
\`\`\`

### Suggested Fix
$3

---
EOF

echo "记录完成：$ID"
```

### log_correction.sh

```bash
#!/bin/bash
# 记录用户纠正
# 用法：log_correction.sh "主题" "错误方式" "正确方式"

ID="LRN-$(date +%Y%m%d)-$(printf '%03d' $(shuf -i 1-999 -n 1))"
DATE=$(date -Iseconds)

cat >> ~/.openclaw/workspace/.learnings/LEARNINGS.md << EOF

## [$ID] $(echo $1 | tr ' ' '_')

**Logged**: $DATE
**Priority**: medium
**Status**: pending
**Area**: config

### Summary
$1: $2 → $3

### Metadata
- Source: user_correction
- Pattern-Key: $(echo $1 | tr ' ' '-').$(date +%s)

---
EOF

echo "记录完成：$ID"
```

---

## 📋 快速参考表

| 场景 | 行动 |
|------|------|
| 命令/操作失败 | 记录到 `ERRORS.md` |
| 用户纠正你 | 记录到 `LEARNINGS.md` (category: correction) |
| 用户请求缺失功能 | 记录到 `FEATURE_REQUESTS.md` |
| API/外部工具失败 | 记录到 `ERRORS.md` (带集成详情) |
| 知识过时/错误 | 记录到 `LEARNINGS.md` (category: knowledge_gap) |
| 发现更好方法 | 记录到 `LEARNINGS.md` (category: best_practice) |
| 简化/强化重复模式 | 记录/更新 `LEARNINGS.md` (带 Pattern-Key) |
| 与现有条目相似 | 链接 `**See Also**`，考虑优先级提升 |
| 广泛适用的学习 | Promote 到 `AGENTS.md` / `SOUL.md` / `TOOLS.md` |
| 工作流改进 | Promote 到 `AGENTS.md` |
| 工具注意事项 | Promote 到 `TOOLS.md` |
| 行为模式 | Promote 到 `SOUL.md` |

---

## 🎯 成功指标

| 指标 | 目标 | 测量方式 |
|------|------|----------|
| **错误复发率** | <10% | 相同 ERR ID 重复出现次数 |
| **Promotion 率** | >30% | promoted / total learnings |
| **平均解决时间** | <7 天 | logged → resolved 时间差 |
| **重复模式检测** | 100% | Recurrence-Count 追踪 |

---

## 📋 更新日志

### v4.7 (2026-03-29) - Public Sharing 机制 ⭐

**核心改进**: 将"分享成长轨迹"集成到自我持续成长计划

**新增功能**:
- ✅ **Public Sharing 字段** - LEARNINGS.md 模板新增分享标记字段
  - `Shareable`: yes/no/pending
  - `Public Level`: tip/guide/architecture
  - `Public Note`: 分享说明
  - `Public Target`: 目标位置
- ✅ **每日检查机制** - memory-retell.sh 添加可分享内容检查
  - 检查昨日学习记录
  - 自动添加到周汇总
- ✅ **每周汇总** - 新增 weekly-public-summary.sh 脚本
  - 审查本周学习记录
  - 生成公开内容更新建议
  - 发送飞书通知
- ✅ **集成自我反思** - self-reflect.sh 添加公开内容审查
  - 检查待审查报告
  - 显示推送命令
- ✅ **Cron 任务** - 每周五 16:00 自动执行周汇总

**工作流**:
```
学习 → 记录 → 每日检查 → 周汇总 → 审查 → 分享 → 反馈 → 改进
```

**意义**:
- 分享从"额外工作"变为"成长自然结果"
- 教学相长（费曼学习法）
- 元认知能力提升
- 知识结构化
- 社区反馈循环

**相关文件**:
- `~/.openclaw/workspace/.learnings/LEARNINGS.md` (v4.3 模板)
- `~/.openclaw/workspace/.scripts/memory-retell.sh` (含每日检查)
- `~/.openclaw/workspace/.scripts/weekly-public-summary.sh` (新增)
- `~/.openclaw/workspace/.scripts/self-reflect.sh` (含公开检查)

---

### v4.7 (2026-03-23) - 举一反三增强版

**新增功能**:
- ✅ 举一反三字段 - LEARNINGS.md 模板新增"类似问题"、"通用方案"、"应用场景"、"模式分类"
- ✅ 模式识别 - pattern-library.md 问题模式库
- ✅ 重复检测 - Recurrence-Count 追踪
- ✅ Promotion 机制 - 从 HOT 层提升到 COLD 层

**核心改进**:
- 从"记录错误"到"提取模式"
- 从"单一经验"到"通用方案"
- 从"被动记录"到"主动反思"

---

### v4.7 (2026-03-15) - 四层记忆架构

**核心功能**:
- ✅ 四层记忆架构（HOT/WARM/COLD/ARCHIVE）
- ✅ 11 个自动化脚本
- ✅ 6 个定时任务（Cron）
- ✅ 唯一 ID 系统（LRN/ERR/FEAT）
- ✅ 状态追踪（pending/in_progress/resolved/promoted）

**脚本清单**:
- memory-capture.sh - 记忆捕获
- memory-consolidate.sh - 记忆巩固
- memory-hygiene.sh - 记忆清洁
- memory-retell.sh - 记忆复述
- memory-search.sh - 记忆搜索
- self-reflect.sh - 自我反思
- ...

---

### v4.7 (2026-03-15) - 基础版

**功能**:
- ✅ 基础记忆记录（LEARNINGS.md/ERRORS.md）
- ✅ 简单 Cron 任务
- ✅ 基础模板

---

**版本命名规则**:
- **主版本号** - 架构级变更（如四层记忆架构）
- **次版本号** - 重要功能新增（如 Public Sharing、举一反三）
- **修订号** - 小改进和 Bug 修复

---

*让 AI 从错误中学习，越用越聪明。Paranoia is a feature. Memory is power.* 🧠🦞
