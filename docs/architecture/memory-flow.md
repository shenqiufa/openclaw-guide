# 記憶流動機制詳解

**版本**: v4.8.2  
**創建時間**: 2026-04-08  
**最後更新**: 2026-04-08  
**文檔類型**: 深度解析

---

## 🎯 核心概念

**記憶流動** = 經驗教訓從「短期活躍」到「長期沉澱」的完整生命周期。

---

## 📊 完整流動圖

```
┌─────────────────────────────────────────────────────────────────┐
│                        記憶流動全景                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  實時捕獲                                                        │
│  ├── 用戶說「記住這個」                                         │
│  ├── Bug 修復完成                                               │
│  ├── 配置變更完成                                               │
│  └── 會話結束                                                   │
│         ↓                                                       │
│  HOT 層（.learnings/）                                           │
│  ├── LEARNINGS.md（活躍記憶，7 天內）                           │
│  ├── ERRORS.md（錯誤記錄）                                      │
│  └── 特點：快速訪問、頻繁更新                                   │
│         ↓ 記憶復述（每天 08:30）                                │
│  WARM 層（memory/warm/）                                         │
│  ├── corrections.md（糾正記錄，30 天內）                        │
│  ├── best-practices.md（最佳實踐）                              │
│  └── 特點：常用經驗、定期回顧                                   │
│         ↓ 記憶巩固（每週一 05:00）                              │
│  COLD 層（MEMORY.md）                                            │
│  ├── 用戶偏好（永久）                                           │
│  ├── 重要項目背景（永久）                                       │
│  ├── 核心工作原則（永久）                                       │
│  └── 特點：長期記憶、精選記憶                                   │
│         ↓ 記憶清潔（每月 1 日 06:00）                           │
│  ARCHIVE 層（.archive/）                                         │
│  └── 按月歸檔的歷史記錄                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 流動階段詳解

### 階段 1：實時捕獲（HOT 層入口）

**觸發場景**：

| 場景 | 觸發條件 | AI 行為 | 記錄位置 |
|------|---------|--------|---------|
| **版本更新** ⭐ | 修改 SKILL.md version 字段 | 自動運行 sync-version.sh | LEARNINGS.md |
| **Bug 修復** | "好了"/"可以了"/"成功了" | auto-memory-hook.sh bugfix | LEARNINGS.md |
| **配置變更** | 修改了配置文件/插件/設置 | auto-memory-hook.sh config | LEARNINGS.md |
| **會話結束** | "去吃饭"/"明天"/"先这样" | auto-memory-hook.sh session-end | memory/YYYY-MM-DD.md |
| **錯誤解決** | 命令失敗后最終成功 | auto-memory-hook.sh error | ERRORS.md |
| **用戶要求** | "记住"/"别忘了"/"记录下" | memory-capture.sh | LEARNINGS.md |
| **回顾总结** ⭐ | "回顾总结"/"总结一下" | review-summary.sh | LEARNINGS.md |

**實例**：
```bash
# 用戶說：「記住，我喜歡用繁體中文」
AI 調用：
~/.openclaw/workspace/.hooks/auto-memory-hook.sh bugfix "用戶語言偏好" "用戶說喜歡用繁體中文"

結果：
寫入 .learnings/LEARNINGS.md
```

---

### 階段 2：HOT 層（活躍記憶）

**特點**：
- 📍 **位置**: `.learnings/` 目錄
- ⏰ **周期**: 7 天內（最新記錄）
- 🔥 **頻率**: 頻繁更新（每天數次）
- 📄 **文件**:
  - `LEARNINGS.md` - 學習記錄（糾正、最佳實踐）
  - `ERRORS.md` - 錯誤記錄（命令失敗、異常）
  - `FEATURE_REQUESTS.md` - 功能請求

**記憶格式**：
```markdown
## [LRN-20260408-001] 用戶語言偏好

**Logged**: 2026-04-08T15:30:00+08:00  
**類型**: user-preference  
**Priority**: high  
**Status**: resolved  
**Usage-Count**: 1  
**Success-Rate**: 1.0  

### Summary
用戶說喜歡用繁體中文

### Metadata
- Source: user-instruction
- Pattern-Key: user.preference.language
```

**指標追蹤**（自動）：
- `Usage-Count` - 使用次數
- `Success-Rate` - 成功率 (0-1)
- `First-Used` - 首次使用時間
- `Last-Used` - 最後使用時間

---

### 階段 3：記憶復述（HOT → WARM）

**時間**：每天 08:30

**腳本**：`memory-retell.sh daily`

**流程**：

```
1. 隨機選擇 3 條記憶
   - 從 HOT 層、WARM 層、COLD 層隨機選擇
   - 優先選擇高價值記憶（使用次數 >= 3）
   ↓
2. 生成回顧報告
   - 位置：memory/retells/daily-YYYY-MM-DD.md
   - 包含回顧問題：
     - 這條記憶還適用嗎？
     - 需要更新或補充嗎？
     - 與其他記憶有聯繫嗎？
   ↓
3. AI 自動處理（v4.7.1 新增）
   - AI 自動閱讀回顧報告
   - AI 自動回答回顧問題（80% 自動化）
   - AI 自動更新 MEMORY.md（如需要）
   ↓
4. 推送飛書通知
   - 摘要推送到用戶
   - 需要確認時標記
```

**實例輸出**：
```markdown
# 每日記憶回顧 (2026-04-08)

## 📚 今日回顧 (3 條)

### LRN-20260408-001 - 用戶語言偏好

**回顧問題：**
- [x] 這條記憶還適用嗎？ ✅ 適用
- [x] 需要更新或補充嗎？ ❌ 不需要
- [x] 與其他記憶有聯繫嗎？ ✅ 關聯到 AGENTS.md 溝通規範

**AI 處理結果**：
- 已確認記憶有效
- 無需更新
- 已建立關聯
```

---

### 階段 4：WARM 層（近期經驗）

**特點**：
- 📍 **位置**: `memory/warm/` 目錄
- ⏰ **周期**: 30 天內（近期經驗）
- 📊 **頻率**: 定期回顧（每週）
- 📄 **文件**:
  - `corrections.md` - 糾正記錄
  - `best-practices.md` - 最佳實踐

**進入條件**：
- ✅ 記憶復述確認有效（連續 3 次）
- ✅ 使用次數 >= 3
- ✅ 成功率 >= 0.7

**轉移流程**：
```bash
# 記憶巩固腳本自動執行
~/.openclaw/workspace/.scripts/memory-consolidate.sh

# 將 HOT 層記錄轉移到 WARM 層
cp .learnings/LEARNINGS.md#LRN-XXX memory/warm/corrections.md
```

---

### 階段 5：記憶巩固（WARM → COLD）

**時間**：每週一 05:00

**腳本**：`memory-consolidate.sh`

**流程**：

```
1. 識別需要巩固的記憶
   - Status: resolved 且 >7 天的記錄
   - 使用次數 >= 5
   - 成功率 >= 0.8
   ↓
2. 評估記憶價值
   - 高置信度（>= 0.9）→ 自動轉移到 MEMORY.md
   - 中置信度（0.7-0.9）→ 推送飛書請求確認
   - 低置信度（< 0.7）→ 保留在 WARM 層
   ↓
3. 生成巩固報告
   - 位置：memory/consolidation-YYYYMMDD.md
   - 包含轉移建議和理由
   ↓
4. AI 自動處理（v4.7.1 新增）
   - AI 自動閱讀巩固報告
   - AI 自動執行轉移（高置信度）
   - AI 推送飛書通知（中置信度）
```

**實例**：
```markdown
# 記憶巩固報告 (2026-04-08)

## 🧠 建議轉移的記憶（3 條）

### LRN-20260401-005 - 飛書消息格式限制
- **使用次數**: 8 次
- **成功率**: 1.0
- **置信度**: 高（0.95）
- **建議**: 轉移到 MEMORY.md → 關鍵教訓
- **AI 處理**: ✅ 已自動轉移
```

---

### 階段 6：COLD 層（長期記憶）

**特點**：
- 📍 **位置**: `MEMORY.md`（根目錄）
- ⏰ **周期**: 永久保存
- 📊 **頻率**: 精選記憶（每月數條）
- 📄 **內容**:
  - 用戶偏好
  - 重要項目背景
  - 核心工作原則
  - 關鍵教訓

**進入條件**：
- ✅ 記憶巩固確認高價值
- ✅ 使用次數 >= 5
- ✅ 成功率 >= 0.8
- ✅ 置信度 >= 0.9

**記憶格式**：
```markdown
## 💡 關鍵教訓

### 飛書消息格式限制（2026-04-05）

**教訓來源**: LRN-20260405-002

**核心原則**: 飛書消息表格行數 <5 行

**應用場景**:
- 定時任務報告
- 項目進度報告
- 任何包含多行表格的飛書消息

**實施狀態**:
✅ 已實施到 AGENTS.md
✅ AI 已內化
```

---

### 階段 7：記憶清潔（COLD → ARCHIVE）

**時間**：每月 1 日 06:00

**腳本**：`memory-hygiene.sh`

**流程**：

```
1. 檢查 MEMORY.md 大小
   - 如果 > 50KB → 觸發歸檔
   - 如果 < 20KB → 跳過
   ↓
2. 識別可歸檔記憶
   - 超過 180 天未更新
   - 使用次數 = 0（最近 90 天）
   - 與當前工作無關
   ↓
3. 生成歸檔建議
   - 位置：memory/hygiene-YYYYMM.md
   - 包含歸檔清單和理由
   ↓
4. AI 審查 + 用戶確認
   - AI 自動審查歸檔建議
   - 推送飛書請求確認
   - 用戶確認後執行歸檔
   ↓
5. 執行歸檔
   - 移動到 .archive/YYYY-MM/
   - 更新 MEMORY.md 索引
```

---

## 📈 記憶指標追蹤

### 自動追蹤的指標

| 指標 | 說明 | 追蹤方式 | 閾值 |
|------|------|---------|------|
| `Usage-Count` | 使用次數 | 每次調用 +1 | >= 5 高價值 |
| `Success-Rate` | 成功率 | 成功/總次數 | >= 0.8 優秀 |
| `Success-Count` | 成功次數 | 成功時 +1 | - |
| `Failure-Count` | 失敗次數 | 失敗時 +1 | >= 3 警告 |
| `First-Used` | 首次使用 | 創建時記錄 | - |
| `Last-Used` | 最後使用 | 每次更新 | >90 天未用→歸檔 |

### 自動檢測規則

| 檢測結果 | 標準 | 建議動作 |
|---------|------|---------|
| ⭐⭐⭐ **高價值記憶** | 使用次數 >= 5 且 成功率 >= 0.8 | Promote 到 AGENTS.md 或 TOOLS.md |
| ⭐⭐ **中等價值** | 使用次數 >= 3 且 成功率 >= 0.7 | 繼續使用，觀察趨勢 |
| ⚠️ **高頻失敗** | 失敗次數 >= 3 | 檢查內容是否需要更新 |
| 🗑️ **過期記憶** | 90 天未使用 | 考慮歸檔到 ARCHIVE 層 |

---

## 🎯 記憶流動示例

### 完整案例：用戶語言偏好

```
Day 1: 用戶說「我喜歡用繁體中文」
       ↓
       記錄到 HOT 層 (.learnings/LEARNINGS.md)
       → LRN-20260401-001 [Usage: 1, Success: 1.0]
       
Day 2: AI 使用繁體中文回覆
       ↓
       更新指標 [Usage: 2, Success: 1.0]
       
Day 3-7: 持續使用繁體中文
       ↓
       更新指標 [Usage: 7, Success: 1.0]
       
Day 8: 記憶復述（每天 08:30）
       ↓
       AI 回顧：✅ 記憶有效，繼續使用
       
Day 15: 記憶巩固（每週一 05:00）
       ↓
       評估：使用次數=15, 成功率=1.0, 置信度=0.95
       轉移：WARM 層 → memory/warm/corrections.md
       
Day 30: 記憶巩固
       ↓
       評估：使用次數=30, 成功率=1.0, 置信度=0.98
       轉移：COLD 層 → MEMORY.md（用戶偏好）
       
Day 180: 記憶清潔（每月 1 日）
       ↓
       評估：仍在活躍使用
       決定：保留在 COLD 層（不歸檔）
```

---

## 📊 流動統計

### 典型流動速度

| 記憶類型 | HOT→WARM | WARM→COLD | COLD→ARCHIVE |
|---------|----------|-----------|--------------|
| **高價值** | 7-15 天 | 30-60 天 | >180 天 |
| **中等價值** | 15-30 天 | 60-90 天 | >365 天 |
| **低價值** | 不轉移 | 不轉移 | 90 天未用 |

### 各層容量

| 層 | 典型大小 | 記錄數量 | 更新頻率 |
|----|---------|---------|---------|
| **HOT** | <25KB | <100 條 | 每天數次 |
| **WARM** | <50KB | <300 條 | 每週數次 |
| **COLD** | <20KB | <50 條 | 每月數次 |
| **ARCHIVE** | 不限 | 不限 | 按需訪問 |

---

## 🔧 相關腳本詳解

### 腳本總覽

| 腳本 | 用途 | 執行頻率 | 對應階段 |
|------|------|---------|---------|
| `auto-memory-hook.sh` | 實時記憶捕獲 | 事件觸發 | 階段 1 |
| `memory-capture.sh` | 手動記憶捕獲 | 用戶要求 | 階段 1 |
| `sync-version.sh` | 版本號同步 | 版本變更 | 階段 1 |
| `memory-retell.sh` | 記憶復述 | 每天 08:30 | 階段 3 |
| `memory-consolidate.sh` | 記憶巩固 | 每週一 05:00 | 階段 5 |
| `memory-hygiene.sh` | 記憶清潔 | 每月 1 日 06:00 | 階段 7 |
| `update-learning-metrics.sh` | 更新記憶指標 | 每次使用後 | 全階段 |
| `view-learning-metrics.sh` | 查看記憶指標 | 按需 | 全階段 |

---

### 階段 1：實時捕獲腳本

#### auto-memory-hook.sh

**位置**: `.hooks/auto-memory-hook.sh`

**用途**: 自動檢測並記錄記憶

**觸發場景**:
- Bug 修復完成
- 配置變更
- 會話結束
- 錯誤解決

**使用方式**:
```bash
# Bug 修復
~/.openclaw/workspace/.hooks/auto-memory-hook.sh bugfix "標題" "詳情"

# 配置變更
~/.openclaw/workspace/.hooks/auto-memory-hook.sh config "標題" "詳情"

# 會話結束
~/.openclaw/workspace/.hooks/auto-memory-hook.sh session-end "總結" "詳情"

# 錯誤解決
~/.openclaw/workspace/.hooks/auto-memory-hook.sh error "錯誤描述" "解決方案"
```

**輸出**:
- 寫入 `.learnings/LEARNINGS.md`
- 自動添加 Metadata（Usage-Count, Success-Rate 等）

**示例**:
```bash
# 用戶說：「記住，我喜歡用繁體中文」
~/.openclaw/workspace/.hooks/auto-memory-hook.sh bugfix "用戶語言偏好" "用戶說喜歡用繁體中文"

# 結果：
## [LRN-20260408-001] 用戶語言偏好
**Logged**: 2026-04-08T15:30:00+08:00
**Summary**: 用戶說喜歡用繁體中文
```

---

#### memory-capture.sh

**位置**: `.scripts/memory-capture.sh`

**用途**: 手動捕獲記憶（用戶主動要求）

**觸發場景**:
- 用戶說「記住這個」
- 用戶說「別忘了」
- 用戶說「記錄下來」

**使用方式**:
```bash
~/.openclaw/workspace/.scripts/memory-capture.sh "記憶內容" [priority]

# priority 可選：low, medium, high（默認 medium）
```

**示例**:
```bash
# 用戶說：「記住，明天早上 9 點開會」
~/.openclaw/workspace/.scripts/memory-capture.sh "明天早上 9 點開會" high
```

---

#### sync-version.sh

**位置**: `.scripts/sync-version.sh`

**用途**: 版本號同步（特殊類型的記憶捕獲）

**觸發場景**:
- 修改 SKILL.md version 字段

**使用方式**:
```bash
~/.openclaw/workspace/.scripts/sync-version.sh [新版本號]

# 示例：
~/.openclaw/workspace/.scripts/sync-version.sh 4.8.0
```

**同步的文件**:
- `skills/self-improving-agent-pro/SKILL.md`
- `HEARTBEAT.md`
- `AGENTS.md`
- `TOOLS.md`
- `releases/CHANGELOG.md`
- `GROWTH-PLAN/README.md`

---

### 階段 3：記憶復述腳本

#### memory-retell.sh

**位置**: `.scripts/memory-retell.sh`

**用途**: 每日記憶回顧，促進 HOT→WARM 流動

**執行時間**: 每天 08:30（cron 自動執行）

**執行方式**:
```bash
# 手動執行
~/.openclaw/workspace/.scripts/memory-retell.sh daily

# cron 配置（自動執行）
0 8 * * * ~/.openclaw/workspace/.scripts/memory-retell.sh daily
```

**執行流程**:
```bash
1. 隨機選擇 3 條記憶
   - 從 HOT 層、WARM 層、COLD 層隨機選擇
   - 優先選擇高價值記憶（使用次數 >= 3）
   
2. 生成回顧報告
   - 位置：memory/retells/daily-YYYY-MM-DD.md
   - 包含回顧問題：
     - 這條記憶還適用嗎？
     - 需要更新或補充嗎？
     - 與其他記憶有聯繫嗎？
   
3. AI 自動處理（v4.7.1 新增）
   - AI 自動閱讀回顧報告
   - AI 自動回答回顧問題（80% 自動化）
   - AI 自動更新 MEMORY.md（如需要）
   
4. 推送飛書通知
   - 摘要推送到用戶
   - 需要確認時標記
```

**輸出示例**:
```markdown
# 每日記憶回顧 (2026-04-08)

## 📚 今日回顧 (3 條)

### LRN-20260408-001 - 用戶語言偏好

**回顧問題：**
- [x] 這條記憶還適用嗎？ ✅ 適用
- [x] 需要更新或補充嗎？ ❌ 不需要
- [x] 與其他記憶有聯繫嗎？ ✅ 關聯到 AGENTS.md

**AI 處理結果：**
- 已確認記憶有效
- 無需更新
- 已建立關聯
```

**日誌位置**:
- `.logs/memory-retell-auto.log`

---

### 階段 5：記憶巩固腳本

#### memory-consolidate.sh

**位置**: `.scripts/memory-consolidate.sh`

**用途**: 每週記憶巩固，促進 WARM→COLD 流動

**執行時間**: 每週一 05:00（cron 自動執行）

**執行方式**:
```bash
# 手動執行
~/.openclaw/workspace/.scripts/memory-consolidate.sh

# cron 配置（自動執行）
0 5 * * 1 ~/.openclaw/workspace/.scripts/memory-consolidate.sh
```

**執行流程**:
```bash
1. 識別需要巩固的記憶
   - Status: resolved 且 >7 天的記錄
   - 使用次數 >= 5
   - 成功率 >= 0.8
   
2. 評估記憶價值
   - 高置信度（>= 0.9）→ 自動轉移到 MEMORY.md
   - 中置信度（0.7-0.9）→ 推送飛書請求確認
   - 低置信度（< 0.7）→ 保留在 WARM 層
   
3. 生成巩固報告
   - 位置：memory/consolidation-YYYYMMDD.md
   - 包含轉移建議和理由
   
4. AI 自動處理（v4.7.1 新增）
   - AI 自動閱讀巩固報告
   - AI 自動執行轉移（高置信度）
   - AI 推送飛書通知（中置信度）
```

**輸出示例**:
```markdown
# 記憶巩固報告 (2026-04-08)

## 🧠 建議轉移的記憶（3 條）

### LRN-20260401-005 - 飛書消息格式限制
- **使用次數**: 8 次
- **成功率**: 1.0
- **置信度**: 高（0.95）
- **建議**: 轉移到 MEMORY.md → 關鍵教訓
- **AI 處理**: ✅ 已自動轉移
```

**日誌位置**:
- `.logs/memory-consolidate.log`

---

### 階段 7：記憶清潔腳本

#### memory-hygiene.sh

**位置**: `.scripts/memory-hygiene.sh`

**用途**: 每月記憶清潔，促進 COLD→ARCHIVE 流動

**執行時間**: 每月 1 日 06:00（cron 自動執行）

**執行方式**:
```bash
# 手動執行
~/.openclaw/workspace/.scripts/memory-hygiene.sh

# cron 配置（自動執行）
0 6 1 * * ~/.openclaw/workspace/.scripts/memory-hygiene.sh
```

**執行流程**:
```bash
1. 檢查 MEMORY.md 大小
   - 如果 > 50KB → 觸發歸檔
   - 如果 < 20KB → 跳過
   
2. 識別可歸檔記憶
   - 超過 180 天未更新
   - 使用次數 = 0（最近 90 天）
   - 與當前工作無關
   
3. 生成歸檔建議
   - 位置：memory/hygiene-YYYYMM.md
   - 包含歸檔清單和理由
   
4. AI 審查 + 用戶確認
   - AI 自動審查歸檔建議
   - 推送飛書請求確認
   - 用戶確認後執行歸檔
   
5. 執行歸檔
   - 移動到 .archive/YYYY-MM/
   - 更新 MEMORY.md 索引
```

**輸出示例**:
```markdown
# 記憶清潔報告 (2026-04-01)

## 🗑️ 建議歸檔的記憶（2 條）

### LRN-20251001-003 - 舊項目背景
- **最後更新**: 2025-10-01（180 天前）
- **使用次數**: 0（最近 90 天）
- **建議**: 歸檔到 .archive/2025-10/
- **AI 處理**: ⏳ 待用戶確認
```

**日誌位置**:
- `.logs/memory-hygiene.log`

---

### 全階段：指標追蹤腳本

#### update-learning-metrics.sh

**位置**: `.scripts/update-learning-metrics.sh`

**用途**: 更新記憶指標（每次使用後自動執行）

**執行方式**:
```bash
# 記錄使用結果
~/.openclaw/workspace/.scripts/update-learning-metrics.sh LEARNING_ID RESULT

# 示例：
~/.openclaw/workspace/.scripts/update-learning-metrics.sh LRN-20260408-001 success
```

**追蹤的指標**:
- `Usage-Count` - 使用次數（每次 +1）
- `Success-Rate` - 成功率（成功/總次數）
- `Success-Count` - 成功次數（成功時 +1）
- `Failure-Count` - 失敗次數（失敗時 +1）
- `Last-Used` - 最後使用時間（每次更新）

---

#### view-learning-metrics.sh

**位置**: `.scripts/view-learning-metrics.sh`

**用途**: 查看記憶指標統計

**執行方式**:
```bash
# 查看所有記憶指標
~/.openclaw/workspace/.scripts/view-learning-metrics.sh

# 查看特定記憶指標
~/.openclaw/workspace/.scripts/view-learning-metrics.sh LRN-20260408-001
```

**輸出示例**:
```markdown
## 📊 記憶指標統計

### LRN-20260408-001 - 用戶語言偏好

| 指標 | 值 |
|------|-----|
| **Usage-Count** | 15 |
| **Success-Rate** | 1.0 |
| **Success-Count** | 15 |
| **Failure-Count** | 0 |
| **First-Used** | 2026-04-01 |
| **Last-Used** | 2026-04-08 |
| **價值評估** | ⭐⭐⭐ 高價值 |
```

---

## 📊 腳本執行時序圖

```
實時捕獲（事件觸發）
    ↓
auto-memory-hook.sh
    ↓
寫入 HOT 層
    ↓
[每次使用]
update-learning-metrics.sh
    ↓
[每天 08:30]
memory-retell.sh → 生成回顧報告 → AI 自動處理
    ↓
[每週一 05:00]
memory-consolidate.sh → 生成巩固報告 → AI 自動轉移
    ↓
[每月 1 日 06:00]
memory-hygiene.sh → 生成歸檔建議 → 用戶確認 → 執行歸檔
    ↓
[按需]
view-learning-metrics.sh → 查看指標統計
```

---

## 🦞 腳本快速參考

### 手動執行命令

```bash
# 實時捕獲（Bug 修復）
~/.openclaw/workspace/.hooks/auto-memory-hook.sh bugfix "標題" "詳情"

# 實時捕獲（用戶要求）
~/.openclaw/workspace/.scripts/memory-capture.sh "內容" high

# 記憶復述（測試）
~/.openclaw/workspace/.scripts/memory-retell.sh daily

# 記憶巩固（測試）
~/.openclaw/workspace/.scripts/memory-consolidate.sh

# 記憶清潔（測試）
~/.openclaw/workspace/.scripts/memory-hygiene.sh

# 查看指標
~/.openclaw/workspace/.scripts/view-learning-metrics.sh
```

### 查看日誌

```bash
# 記憶復述日誌
tail -10 ~/.openclaw/workspace/.logs/memory-retell-auto.log

# 記憶巩固日誌
tail -10 ~/.openclaw/workspace/.logs/memory-consolidate.log

# 記憶清潔日誌
tail -10 ~/.openclaw/workspace/.logs/memory-hygiene.log

# 指標更新日誌
tail -10 ~/.openclaw/workspace/.logs/memory-metrics.log
```

### Cron 配置檢查

```bash
# 查看 cron 任務
cat ~/.openclaw/cron/jobs.json | grep -A 2 "memory"
```

---

## 💡 最佳實踐

### 加速記憶流動

1. **提高使用頻率**
   - 主動應用新記錄的記憶
   - 在相關場景中刻意使用

2. **提高成功率**
   - 記錄時確保準確性
   - 失敗時立即更新記憶

3. **建立關聯**
   - 記憶復述時主動尋找聯繫
   - 將新記憶與舊記憶掛鉤

### 避免記憶堆積

1. **定期歸檔**
   - 每月執行記憶清潔
   - 果斷歸檔過期記憶

2. **保持精簡**
   - COLD 層只保留真正重要的記憶
   - 寧可遺漏，不要臃腫

3. **質量優先**
   - 重視記憶質量而非數量
   - 一條高價值記憶 > 十條低價值

---

**最後更新**: 2026-04-08  
**維護者**: 發哥的龙虾 🦞

---

## 📚 相關文檔

- [架構總覽](overview.md) - 5 分鐘了解成長計劃全貌
- [7 個核心文檔](7-docs-architecture.md) - AI 人格定義
- [記憶系統](memory-system.md) - 四層記憶架構
- [自動化機制](automation-system.md) - 定時任務、心跳、鉤子
