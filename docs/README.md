# 成長計劃文檔索引

**版本**: v4.8.2  
**最後更新**: 2026-04-08  
**用途**: 快速找到需要的文檔

---

## 📚 架構文檔

| 文檔 | 說明 | 閱讀時間 |
|------|------|---------|
| [架構總覽](architecture/overview.md) | 5 分鐘了解成長計劃全貌 | 5 分鐘 |
| [7 個核心文檔](architecture/7-docs-architecture.md) | AI 人格定義和關聯 | 10 分鐘 |
| [自動化機制](architecture/automation-system.md) | 定時任務、心跳、鉤子 | 10 分鐘 |
| [記憶系統](architecture/memory-system.md) | 四層記憶架構 | 10 分鐘 |
| [記憶流動](architecture/memory-flow.md) | 記憶流動機制詳解 | 15 分鐘 |

**建議閱讀順序**：
1. 架構總覽（快速了解）
2. 7 個核心文檔（理解 AI 人格）
3. 記憶系統（核心機制）
4. 自動化機制（如何運行）
5. 記憶流動（深入理解）

---

## 📖 使用指南

| 文檔 | 說明 | 閱讀時間 |
|------|------|---------|
| [快速開始](guides/quick-start.md) | 新手入門指南 | 5 分鐘 |
| [文件掃描指南](guides/scan-guide.md) | 7 個核心文件掃描使用說明 | 10 分鐘 |

---

## 📊 版本發布

| 文檔 | 說明 |
|------|------|
| [變更日誌](releases/CHANGELOG.md) | 所有版本變更記錄（權威） |
| [v4.8.2 發布報告](releases/self-improving-agent-pro-v4.8.2-release.md) | 最新版本（文件掃描） |
| [v4.8.1 發布報告](releases/self-improving-agent-pro-v4.8.1-release.md) | 記憶系統自動化 |
| [v4.8.0 發布報告](releases/self-improving-agent-pro-v4.8.0-release.md) | 智能檢索 + 記憶指標 |
| [v4.7 發布報告](releases/self-improving-agent-pro-v4.7-release.md) | 十大機制整合版 |

---

## 🛠️ 實施記錄

| 文檔 | 說明 |
|------|------|
| [7 個文檔優化經驗](implementation/7-docs-optimization-experience.md) | 文檔優化經驗教訓 |
| [OpenClaw 安裝經驗](implementation/openclaw-install-index.md) | 安裝經驗索引 |
| [文檔審查報告](document-review-20260408.md) | 文檔管理審查報告 |

---

## 🔧 腳本集合

| 腳本 | 說明 | 位置 |
|------|------|------|
| [腳本 README](../scripts/README.md) | 所有腳本說明 | `scripts/` |
| `scan-core-files.sh` | 7 個核心文件掃描 | 每週五 15:00 |
| `memory-retell.sh` | 記憶復述 | 每天 08:30 |
| `memory-consolidate.sh` | 記憶巩固 | 每週一 05:00 |
| `memory-hygiene.sh` | 記憶清潔 | 每月 1 日 06:00 |

---

## 🎯 快速導航

### 我想了解...

**成長計劃是什麼**：
- → [README.md](../README.md) - 項目總綱
- → [architecture/overview.md](architecture/overview.md) - 架構總覽

**如何使用**：
- → [guides/quick-start.md](guides/quick-start.md) - 快速開始
- → [guides/scan-guide.md](guides/scan-guide.md) - 文件掃描

**記憶系統**：
- → [architecture/memory-system.md](architecture/memory-system.md) - 記憶系統架構
- → [architecture/memory-flow.md](architecture/memory-flow.md) - 記憶流動詳解

**自動化機制**：
- → [architecture/automation-system.md](architecture/automation-system.md) - 自動化機制
- → [scripts/README.md](../scripts/README.md) - 腳本集合

**版本歷史**：
- → [releases/CHANGELOG.md](releases/CHANGELOG.md) - 變更日誌
- → [releases/](releases/) - 所有發布報告

---

## 📂 目錄結構

```
docs/
├── README.md                ← 本文檔（文檔索引）
├── architecture/            ← 架構文檔
│   ├── overview.md
│   ├── 7-docs-architecture.md
│   ├── automation-system.md
│   ├── memory-system.md
│   └── memory-flow.md
├── guides/                  ← 使用指南
│   ├── quick-start.md
│   └── scan-guide.md
├── releases/                ← 版本發布
│   ├── CHANGELOG.md
│   └── *.md（發布報告）
├── implementation/          ← 實施記錄
│   ├── 7-docs-optimization-experience.md
│   ├── openclaw-install-index.md
│   └── document-review-20260408.md
└── document-review-20260408.md  ← 文檔審查報告
```

---

## 🔗 相關資源

- **Skill 定義**: [skills/self-improving-agent-pro/SKILL.md](../skills/self-improving-agent-pro/SKILL.md)
- **項目 README**: [README.md](../README.md)
- **腳本集合**: [scripts/](../scripts/)

---

**最後更新**: 2026-04-08  
**維護者**: 發哥的龍蝦 🦞
