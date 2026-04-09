# 記憶系統

> 四層記憶架構，讓 AI 真正記住經驗教訓

**版本**: v4.8.2  
**創建時間**: 2026-04-05  
**最後更新**: 2026-04-08

---

## 📚 相關文檔

- [架構總覽](overview.md) - 5 分鐘了解成長計劃全貌
- [7 個核心文檔](7-docs-architecture.md) - AI 人格定義
- [自動化機制](automation-system.md) - 定時任務、心跳、鉤子
- [記憶流動](memory-flow.md) - 記憶流動機制詳解

---

## 🎯 目標

解決成長計劃起源問題中的「常態失憶」、「不長記性」等問題。

---

## 📊 四層記憶架構

```
┌─────────────────────────────────────────────────────────┐
│                    四層記憶架構                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  HOT 層（.learnings/）                                   │
│  ├── LEARNINGS.md - 學習記錄（糾正、最佳實踐）          │
│  ├── ERRORS.md - 錯誤記錄（命令失敗、異常）             │
│  └── FEATURE_REQUESTS.md - 功能請求                     │
│  特點：當前活躍記憶（7 天內），快速訪問，頻繁更新        │
│                                                         │
│  WARM 層（memory/warm/）                                 │
│  ├── corrections.md - 糾正記錄                          │
│  └── best-practices.md - 最佳實踐                       │
│  特點：近期經驗（30 天內），常用經驗，定期回顧          │
│                                                         │
│  COLD 層（MEMORY.md）                                    │
│  ├── 用戶偏好                                           │
│  ├── 重要項目背景                                       │
│  ├── 核心工作原則                                       │
│  └── 關鍵教訓                                           │
│  特點：長期記憶（永久保存），精選記憶，手動管理          │
│                                                         │
│  ARCHIVE 層（.archive/）                                 │
│  └── 按月歸檔的歷史記錄                                 │
│  特點：已歸檔歷史，按需檢索                             │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 🔄 記憶流動

```
實時捕獲
    ↓
HOT 層（.learnings/）
    ↓
記憶復述（每天 08:30）
    ↓
WARM 層（memory/warm/）
    ↓
記憶巩固（每週一 05:00）
    ↓
COLD 層（MEMORY.md）
    ↓
ARCHIVE 層（.archive/，按需歸檔）
```

---

## 📝 實時記憶捕獲

### 必須手動觸發記憶記錄的場景

| 場景 | 檢測關鍵詞 | AI 必須調用 |
|------|-----------|----------|
| **版本更新** ⭐ | 修改 SKILL.md version 字段 | `./sync-version.sh [新版本號]` |
| **Bug 修復** | "好了"/"可以了"/"成功了" | `auto-memory-hook.sh bugfix` |
| **配置变更** | 修改了配置文件/插件/設置 | `auto-memory-hook.sh config` |
| **会话结束** | "去吃饭"/"明天"/"先这样" | `auto-memory-hook.sh session-end` |
| **错误解决** | 命令失敗后最終成功 | `auto-memory-hook.sh error` |
| **用户要求** | "记住"/"别忘了"/"记录下" | `memory-capture.sh` |
| **回顾总结** ⭐ | "回顾总结"/"总结一下" | `review-summary.sh` |

### 腳本

**位置**：`.hooks/auto-memory-hook.sh`

**使用方式**：
```bash
# Bug 修復
~/.openclaw/workspace/.hooks/auto-memory-hook.sh bugfix "標題" "詳情"

# 配置变更
~/.openclaw/workspace/.hooks/auto-memory-hook.sh config "標題" "詳情"

# 会话结束
~/.openclaw/workspace/.hooks/auto-memory-hook.sh session-end "總結" "詳情"
```

---

## 📖 記憶復述

### 配置

**時間**：每天 08:30

**腳本**：`memory-retell.sh daily`

### 流程

1. **隨機選擇 3 條記憶**
   - 從 HOT 層、WARM 層、COLD 層隨機選擇

2. **生成回顧報告**
   - 位置：`memory/retells/daily-YYYY-MM-DD.md`

3. **AI 自動處理**（v4.7.1 新增）
   - AI 自動閱讀回顧報告
   - AI 自動回答回顧問題
   - AI 自動更新 MEMORY.md（如需要）

4. **檢查可分享內容**（v4.3 新增）
   - 檢查昨日學習記錄
   - 自動添加到周汇总

---

## 🧠 記憶巩固

### 配置

**時間**：每週一 05:00

**腳本**：`memory-consolidate.sh`

### 流程

1. **識別需要巩固的記憶**
   - Status: resolved 且 >7 天的記錄

2. **評估記憶價值**
   - 高置信度 → 自動轉移到 MEMORY.md
   - 低置信度 → 推送飛書請求確認

3. **生成巩固報告**
   - 位置：`memory/consolidation-YYYYMMDD.md`

4. **AI 自動處理**（v4.7.1 新增）
   - AI 自動閱讀巩固報告
   - AI 自動執行轉移（高置信度）

---

## 📈 記憶系統指標（v4.4 新增）

### 追蹤指標

| 指標 | 說明 | 自動追蹤 |
|------|------|---------|
| `Usage-Count` | 使用次數 | ✅ |
| `Success-Rate` | 成功率 (0-1) | ✅ |
| `Success-Count` | 成功次數 | ✅ |
| `Failure-Count` | 失敗次數 | ✅ |
| `First-Used` | 首次使用時間 | ✅ |
| `Last-Used` | 最後使用時間 | ✅ |

### 自動檢測

| 檢測結果 | 標準 | 建議 |
|---------|------|------|
| ⭐⭐⭐ **高價值記憶** | 使用次數 >= 5 且 成功率 >= 0.8 | Promote 到 AGENTS.md 或 TOOLS.md |
| ⭐⭐ **中等價值** | 使用次數 >= 3 且 成功率 >= 0.7 | 繼續使用，觀察趨勢 |
| ⚠️ **高頻失敗** | 失敗次數 >= 3 | 檢查內容是否需要更新 |

### 腳本

**位置**：`.scripts/update-learning-metrics.sh`

**使用方式**：
```bash
# 記錄使用結果
~/.openclaw/workspace/.scripts/update-learning-metrics.sh LEARNING_ID RESULT

# 查看指標
~/.openclaw/workspace/.scripts/view-learning-metrics.sh
```

---

## 📊 實施統計（v4.7.1）

| 組件 | 數量 | 狀態 |
|------|------|------|
| **四層架構** | 4 層 | ✅ 已創建 |
| **自動化腳本** | 11 個 | ✅ 已創建 |
| **記憶復述** | 每天 08:30 | ✅ 已配置 |
| **記憶巩固** | 每週一 05:00 | ✅ 已配置 |
| **記憶檢索** | 按需 | ✅ 已實現 |
| **指標追蹤** | 6 個指標 | ✅ 已實現 |

---

## 🎯 閉環系統

```
實時捕獲 → 四層架構 → 定期回顧 → 記憶巩固

1. 實時捕獲（auto-memory-hook.sh）
    ↓
2. HOT 層（.learnings/）
    ↓
3. 記憶復述（每天 08:30）
    ↓
4. 記憶巩固（每週一 05:00）
    ↓
5. COLD 層（MEMORY.md）
    ↓
6. 優化行為（閉環完成）
```

---

**最後更新**: 2026-04-05
