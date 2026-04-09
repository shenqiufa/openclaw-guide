# 記憶系統腳本集合

**版本**: v4.8.3  
**創建時間**: 2026-04-08  
**最後更新**: 2026-04-09  
**用途**: 成長計劃記憶系統相關腳本備份

---

## 📂 腳本清單

| 腳本 | 用途 | 執行頻率 | 大小 | 版本 |
|------|------|---------|------|------|
| `weekly-summary.sh` | 每週總結（合併版） | 每週五 15:00 | 4.5K | v4.8.3 |
| `content-review.sh` | 內容審查（合併版） | 每週五 16:00 | 5.5K | v4.8.3 |
| `scan-core-files.sh` | 7 個核心文件掃描 | 每週五 15:00 | 9.8K | v4.8.2 |
| `auto-memory-hook.sh` | 實時記憶記錄鉤子 | 事件觸發 | 8.6K | v4.7.2 |
| `memory-capture.sh` | 手動記憶捕獲 | 用戶要求 | 1.3K | - |
| `memory-consolidate.sh` | 記憶巩固（WARM→COLD） | 每週一 05:00 | 13K | - |
| `memory-freshness.sh` | 記憶新鮮度檢查 | 按需 | 3.5K | - |
| `memory-hygiene.sh` | 記憶清潔（COLD→ARCHIVE） | 每月 1 日 06:00 | 8.2K | - |
| `memory-rank.sh` | 記憶重要性評分 | 按需 | 8.4K | - |
| `memory-retell.sh` | 記憶復述（HOT→WARM） | 每天 08:30 | 12K | - |

**v4.8.3 優化說明**：
- `weekly-summary.sh` 合併了 `memory-search.sh` + `emotion-detect.sh` + `self-reflect.sh`
- `content-review.sh` 合併了 `weekly-public-summary.sh` + `generate-guide-update-suggestion.sh`
- 週五任務從 5 個減少到 2 個（-60%）

---

## 🎯 腳本用途詳解

### 每週任務類（v4.8.3 新增）

#### weekly-summary.sh

**用途**: 每週總結（合併記憶檢索 + 情緒趨勢 + 自我反思）  
**執行頻率**: 每週五 15:00  
**合併了**: `memory-search.sh` + `emotion-detect.sh` + `self-reflect.sh`

**功能**:
1. 記憶檢索統計
2. 情緒趨勢分析
3. 自我反思

**使用示例**:
```bash
# 手動執行
./weekly-summary.sh

# 查看生成的報告
cat ../memory/weekly-summary-$(date +%Y%m%d).md
```

**輸出**:
- 報告：`memory/weekly-summary-YYYYMMDD.md`
- 包含：檢索統計、情緒分析、自我反思、下週計劃

---

#### content-review.sh

**用途**: 內容審查和公開分享（合併 Public Sharing + 指南更新）  
**執行頻率**: 每週五 16:00  
**合併了**: `weekly-public-summary.sh` + `generate-guide-update-suggestion.sh`

**功能**:
1. 學習記錄審查
2. 文檔管理審查
3. 公開分享建議
4. 指南更新建議
5. 版本號一致性檢查

**使用示例**:
```bash
# 手動執行
./content-review.sh

# 查看生成的報告
cat ../memory/content-review-$(date +%Y%m%d).md
```

**輸出**:
- 報告：`memory/content-review-YYYYMMDD.md`
- 包含：審查結果、分享建議、更新建議、行動清單

---

### 實時捕獲類

#### scan-core-files.sh（v4.8.2 新增）

**用途**: 7 個核心文件掃描  
**執行頻率**: 每週五 15:00  
**檢查內容**:  
1. 文件內容是否符合定義  
2. 不同文件之間的重複內容  
3. 需要刪除/移除/遷移的內容  

**使用示例**:
```bash
# 手動執行掃描
./scan-core-files.sh

# 查看掃描報告
cat ../memory/scan-report-$(date +%Y%m%d).md
```

**輸出**:
- 掃描報告：`memory/scan-report-YYYYMMDD.md`
- 飛書通知（待配置）

---

#### auto-memory-hook.sh
**用途**: 實時記憶記錄鉤子  
**觸發**: 事件驅動（Bug 修復、配置變更、會話結束等）  
**記錄位置**: `.learnings/LEARNINGS.md`、`memory/YYYY-MM-DD.md`  

**使用示例**:
```bash
# Bug 修復
./auto-memory-hook.sh bugfix "修復飛書推送失敗" "原因是 appSecret 無效"

# 配置變更
./auto-memory-hook.sh config "更新飛書 appSecret" "新 Secret: xxx"

# 會話結束
./auto-memory-hook.sh session-end "完成 Obsidian 調研" "已保存報告"
```

**v4.7.2 新增功能**:
- ✅ AI 主動分類（規範/配置/記憶/價值觀）
- ✅ 邊界違規檢查（避免放錯文檔）
- ✅ 重複檢測（避免重複記錄）

---

#### memory-capture.sh
**用途**: 手動記憶捕獲  
**觸發**: 用戶主動要求（「記住這個」）  

**使用示例**:
```bash
./memory-capture.sh "用戶說喜歡用繁體中文" high
```

---

### 記憶流動類

#### memory-retell.sh
**用途**: 每日記憶回顧，促進 HOT→WARM 流動  
**執行**: 每天 08:30  

**使用示例**:
```bash
# 手動執行
./memory-retell.sh daily

# 查看生成的回顧報告
cat memory/retells/daily-$(date +%Y-%m-%d).md
```

---

#### memory-consolidate.sh
**用途**: 每週記憶巩固，促進 WARM→COLD 流動  
**執行**: 每週一 05:00  

**使用示例**:
```bash
# 手動執行
./memory-consolidate.sh

# 查看生成的巩固報告
cat memory/consolidation-$(date +%Y%m%d).md
```

---

#### memory-hygiene.sh
**用途**: 每月記憶清潔，促進 COLD→ARCHIVE 流動  
**執行**: 每月 1 日 06:00  

**使用示例**:
```bash
# 手動執行
./memory-hygiene.sh

# 查看生成的清潔報告
cat memory/hygiene-$(date +%Y%m).md
```

---

### 記憶檢索類

#### memory-search.sh
**用途**: 記憶檢索優化，分析搜索統計  
**執行**: 每週五 10:00  

**使用示例**:
```bash
# 生成搜索統計
./memory-search.sh --stats

# 查看搜索日誌
cat memory/search-log.md
```

---

#### memory-rank.sh
**用途**: 記憶重要性評分  
**執行**: 按需  

**使用示例**:
```bash
# 查看所有記憶評分
./memory-rank.sh

# 查看高價值記憶
./memory-rank.sh --high-value
```

---

#### memory-freshness.sh
**用途**: 記憶新鮮度檢查  
**執行**: 按需  

**使用示例**:
```bash
# 檢查記憶新鮮度
./memory-freshness.sh
```

---

## 📊 腳本執行時序

```
實時捕獲（事件觸發）
    ↓
auto-memory-hook.sh
    ↓
寫入 HOT 層 (.learnings/)
    ↓
[每天 08:30]
memory-retell.sh → 生成回顧報告 → AI 自動處理
    ↓
[每週一 05:00]
memory-consolidate.sh → 生成巩固報告 → AI 自動轉移
    ↓
[每週五 10:00]
memory-search.sh → 生成統計報告 → AI 自動分析
    ↓
[每月 1 日 06:00]
memory-hygiene.sh → 生成歸檔建議 → 用戶確認 → 執行歸檔
```

---

## 🔧 相關文檔

**架構文檔**:
- `GROWTH-PLAN/docs/architecture/memory-system.md` - 記憶系統架構
- `GROWTH-PLAN/docs/architecture/memory-flow.md` - 記憶流動機制 + 腳本詳解

**實施記錄**:
- `GROWTH-PLAN/implementation/` - 實施經驗記錄

**日誌位置**:
- `.logs/memory-retell-auto.log` - 記憶復述日誌
- `.logs/memory-consolidate.log` - 記憶巩固日誌
- `.logs/memory-hygiene.log` - 記憶清潔日誌
- `.logs/memory-metrics.log` - 指標更新日誌

---

## 📝 備份說明

**備份來源**: `/home/admin/.openclaw/workspace/.hooks/` 和 `/home/admin/.openclaw/workspace/.scripts/`  
**備份時間**: 2026-04-08  
**備份目的**: 方便查閱和版本管理

**注意**: 這些腳本是**參考備份**，實際執行時請使用原始位置的腳本：
- `.hooks/auto-memory-hook.sh`
- `.scripts/memory-*.sh`

---

## 🦞 維護者

**維護者**: 發哥的龙虾  
**最後更新**: 2026-04-08  
**版本**: v1.0

---

## 📚 相關文檔

- [文檔索引](../docs/README.md) - 快速找到文檔
- [架構總覽](../docs/architecture/overview.md) - 5 分鐘了解成長計劃
- [記憶系統](../docs/architecture/memory-system.md) - 四層記憶架構
- [記憶流動](../docs/architecture/memory-flow.md) - 記憶流動詳解
- [文件掃描指南](../docs/guides/scan-guide.md) - scan-core-files.sh 使用說明
