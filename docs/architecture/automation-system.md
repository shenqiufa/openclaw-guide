# 自動化機制

> 讓 AI 主動進化，不依賴人工記憶

**版本**: v4.8.3  
**創建時間**: 2026-04-05  
**最後更新**: 2026-04-09

---

## 📚 相關文檔

- [架構總覽](overview.md) - 5 分鐘了解成長計劃全貌
- [7 個核心文檔](7-docs-architecture.md) - AI 人格定義
- [記憶系統](memory-system.md) - 四層記憶架構
- [記憶流動](memory-flow.md) - 記憶流動機制詳解

---

## 🎯 目標

解決成長計劃起源問題中的「只說不做」、「不主動」、「不記錄」等問題。

---

## 📊 自動化機制架構

```
┌─────────────────────────────────────────────────────────┐
│                    自動化機制                            │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  定時任務（Cron）                                        │
│  ├── 記憶復述 - 每天 08:30                              │
│  ├── 多項目日報 - 每天 09:00                            │
│  ├── 記憶巩固 - 每週一 05:00                            │
│  ├── 每週總結 - 每週五 15:00（v4.8.3 合併）             │
│  ├── 內容審查 - 每週五 16:00（v4.8.3 合併）             │
│  └── 記憶清潔 - 每月 1 日 06:00                         │
│                                                         │
│  心跳檢查（Heartbeat）                                   │
│  └── 每 30 分鐘自動檢查                                  │
│      ├── 檢查待處理報告                                 │
│      ├── AI 自動處理                                     │
│      └── 需要時通知用戶                                 │
│                                                         │
│  鉤子機制（Hooks）                                       │
│  ├── 系統級鉤子（OpenClaw 內建）                         │
│  │   ├── 01-session-start.sh                           │
│  │   ├── 02-post-tool-use.sh                           │
│  │   └── 03-session-end.sh                             │
│  └── 應用層鉤子（自定義）                               │
│      └── auto-memory-hook.sh                           │
│                                                         │
│  版本管理                                                │
│  └── sync-version.sh                                   │
│      └── 同步所有文件的版本號                           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## ⏰ 定時任務（Cron）

### 任務清單

| 任務 | 時間 | 腳本 | 用途 | 狀態 |
|------|------|------|------|------|
| **記憶復述** | 每天 08:30 | `memory-retell.sh` | 回顧 3 條記憶 | ✅ |
| **記憶巩固** | 每週一 05:00 | `memory-consolidate.sh` | 轉移到長期記憶 | ✅ |
| **每週總結** | 每週五 15:00 | `weekly-summary.sh` | 合併記憶檢索 + 情緒 + 反思 | ✅ v4.8.3 |
| **內容審查** | 每週五 16:00 | `content-review.sh` | 合併 Public Sharing + 指南更新 | ✅ v4.8.3 |
| **記憶清潔** | 每月 1 日 06:00 | `memory-hygiene.sh` | 檢查文檔規範 | ✅ |

**v4.8.3 優化說明**：
- `weekly-summary.sh` 合併了 `memory-search.sh` + `emotion-detect.sh` + `self-reflect.sh`
- `content-review.sh` 合併了 `weekly-public-summary.sh` + `generate-guide-update-suggestion.sh`
- 週五任務從 5 個減少到 2 個（-60%）

### 配置位置

```
~/.openclaw/cron/jobs.json
```

### 閉環機制

**改進前**：
```
定時任務 → 生成報告 → ❌ 沒人讀 → ❌ 沒人處理
```

**改進後（v4.7.1）**：
```
定時任務 → 生成報告 → ✅ AI 自動處理 → ⚠️ 需要時通知 → ✅ 形成閉環
```

---

## 💓 心跳檢查（Heartbeat）

### 配置

**位置**：`HEARTBEAT.md`

**頻率**：每 30 分鐘（由 Gateway heartbeat 間隔決定）

### 檢查內容

1. **檢查待處理報告**
   - memory/retells/ 是否有未讀的回顧報告
   - memory/consolidation/ 是否有未處理的巩固建議
   - memory/reflections/ 是否有未讀的反思報告
   - memory/public-update-report/ 是否有未審查的分享報告

2. **AI 自動處理**
   - AI 自動閱讀最新回顧報告
   - AI 自動回答回顧問題
   - AI 自動更新 MEMORY.md（如需要）
   - AI 自動記錄到 LEARNINGS.md

3. **用戶通知**
   - 發現嚴重問題時推送飛書
   - 需要用戶確認時推送飛書
   - 否則保持靜默

### 腳本

**位置**：`.scripts/heartbeat-check.sh`

**執行方式**：自動執行（每 30 分鐘）

---

## 🪝 鉤子機制（Hooks）

### 系統級鉤子（OpenClaw 內建）

**位置**：`~/.openclaw/hooks/self-improvement-memory/`

| 鉤子 | 觸發時機 | 功能 |
|------|---------|------|
| `01-session-start.sh` | 會話開始時 | 加载記憶，檢查待處理事項 |
| `02-post-tool-use.sh` | 工具使用後 | 檢測命令失敗，自動記錄錯誤 |
| `03-session-end.sh` | 會話結束時 | 自動記錄經驗 |

### 應用層鉤子（自定義）

**位置**：`.hooks/auto-memory-hook.sh`

**觸發場景**：

| 場景 | 檢測關鍵詞 | AI 必須調用 |
|------|-----------|----------|
| **版本更新** ⭐ | 修改 SKILL.md version 字段 | `./sync-version.sh [新版本號]` |
| **Bug 修復** | "好了"/"可以了"/"成功了" | `auto-memory-hook.sh bugfix` |
| **配置变更** | 修改了配置文件/插件/設置 | `auto-memory-hook.sh config` |
| **会话结束** | "去吃饭"/"明天"/"先这样" | `auto-memory-hook.sh session-end` |
| **错误解决** | 命令失敗后最終成功 | `auto-memory-hook.sh error` |
| **用户要求** | "记住"/"别忘了"/"记录下" | `memory-capture.sh` |

### 增強功能（v4.7.1）

1. **版本號自動同步**
   - 檢測 SKILL.md 版本號變更
   - 自動運行 sync-version.sh
   - 推送通知

2. **重複問題檢測**
   - 檢查問題出現次數
   - ≥2 次時記錄重複模式
   - 提升優先級為 critical

---

## 🔢 版本管理

### 腳本

**位置**：`.scripts/sync-version.sh`

**用途**：同步所有文件的版本號

**同步的文件**：
- SKILL.md
- HEARTBEAT.md
- AGENTS.md
- TOOLS.md
- PROJECT-TRACKER.md
- VERSION-SYNC-CHECKLIST.md
- FUTURE-PLANS.md

### 使用方式

```bash
~/.openclaw/workspace/.scripts/sync-version.sh [新版本號]
```

### 強制流程

```bash
# 1. 修改 SKILL.md 的 version 字段
# 2. 立即運行：./sync-version.sh [新版本號]
# 3. 手動更新實施報告（LEARNINGS.md）
# 4. 手動更新發布報告（public/docs/）
```

---

## 📈 實施統計（v4.7.1）

| 機制 | 數量 | 狀態 |
|------|------|------|
| **定時任務** | 7 個 | ✅ 已配置 |
| **心跳檢查** | 1 個 | ✅ 已配置 |
| **系統級鉤子** | 3 個 | ✅ 已配置 |
| **應用層鉤子** | 1 個 | ✅ 已增強 |
| **版本管理** | 1 個 | ✅ 已配置 |

---

## 🎯 閉環系統

```
執行 → 記錄 → 回顧 → 優化

1. 執行任務（定時任務、心跳、鉤子）
    ↓
2. 記錄經驗（LEARNINGS.md、ERRORS.md）
    ↓
3. 回顧記憶（記憶復述、自我反思）
    ↓
4. 優化行為（更新文檔、改進機制）
    ↓
回到 1.（閉環完成，進入下一輪進化）
```

---

**最後更新**: 2026-04-05
