# 成長計劃快速開始指南

**版本**: v4.8.2  
**最後更新**: 2026-04-08  
**閱讀時間**: 5 分鐘

---

## 🎯 5 分鐘了解成長計劃

### 成長計劃是什麼？

成長計劃是一個**持續進化的 AI 助手優化系統**，讓 AI 從錯誤中學習，越用越聰明。

**核心功能**：
- ✅ 自動記錄經驗教訓
- ✅ 定期回顧舊記憶
- ✅ 自動優化行為規範
- ✅ 7 個核心文件掃描

---

## 🚀 快速開始

### 步驟 1：了解 7 個核心文檔

成長計劃通過 7 個文檔定義 AI 人格：

| 文檔 | 核心問題 | 內容 |
|------|---------|------|
| **SOUL.md** | 「你是誰？」 | 價值觀、邊界、原則 |
| **USER.md** | 「你在幫助誰？」 | 用戶信息、偏好 |
| **AGENTS.md** | 「你如何做？」 | 行為規範、工作流程 |
| **TOOLS.md** | 「你用什麼工具？」 | 本地配置、設備信息 |
| **MEMORY.md** | 「你記住了什麼？」 | 長期記憶、經驗教訓 |
| **HEARTBEAT.md** | 「你主動做什麼？」 | 心跳檢查、定時任務 |

👉 詳細閱讀：[7 個核心文檔架構](architecture/7-docs-architecture.md)

---

### 步驟 2：理解記憶系統

成長計劃使用**四層記憶架構**：

```
HOT 層（.learnings/）    ← 7 天內活躍記憶
    ↓ 記憶復述（每天 08:30）
WARM 層（memory/warm/）  ← 30 天內近期經驗
    ↓ 記憶巩固（每週一 05:00）
COLD 層（MEMORY.md）     ← 永久保存精選記憶
    ↓ 記憶清潔（每月 1 日 06:00）
ARCHIVE 層（.archive/）  ← 按需歸檔歷史記錄
```

👉 詳細閱讀：[記憶系統架構](architecture/memory-system.md)

---

### 步驟 3：使用自動化機制

#### 定時任務

| 任務 | 頻率 | 自動化 |
|------|------|--------|
| 記憶復述 | 每天 08:30 | ✅ AI 自動處理 |
| 記憶巩固 | 每週一 05:00 | ✅ AI 自動轉移 |
| 記憶檢索 | 每週五 10:00 | ✅ AI 自動分析 |
| 文件掃描 | 每週五 15:00 | ✅ v4.8.2 新增 |

#### 心跳檢查

每 30 分鐘自動檢查：
- 待處理報告
- 記憶記錄
- 待確認事項

---

### 步驟 4：使用文件掃描（v4.8.2 新增）

每週五 15:00 自動掃描 7 個核心文件：

**檢查內容**：
1. 文件內容是否符合定義
2. 不同文件之間的重複內容
3. 需要刪除/移除/遷移的內容

**使用方式**：
```bash
# 手動執行掃描
~/.openclaw/workspace/.scripts/scan-core-files.sh

# 查看掃描報告
cat ~/.openclaw/workspace/memory/scan-report-$(date +%Y%m%d).md
```

👉 詳細閱讀：[文件掃描指南](guides/scan-guide.md)

---

## 📚 下一步學習

### 初學者路線

```
1. 快速開始（本文檔）✅
    ↓
2. 架構總覽（5 分鐘）
    ↓
3. 7 個核心文檔（10 分鐘）
    ↓
4. 記憶系統（10 分鐘）
    ↓
5. 自動化機制（10 分鐘）
```

### 進階學習

```
1. 記憶流動詳解（15 分鐘）
    ↓
2. 腳本集合說明
    ↓
3. 實施經驗記錄
    ↓
4. 版本發布報告
```

---

## 🔧 常用命令

### 版本管理

```bash
# 查看當前版本
grep "version:" ~/.openclaw/workspace/skills/self-improving-agent-pro/SKILL.md

# 同步版本號
~/.openclaw/workspace/.scripts/sync-version.sh [新版本號]
```

### 文件掃描

```bash
# 執行掃描
~/.openclaw/workspace/.scripts/scan-core-files.sh

# 查看報告
cat ~/.openclaw/workspace/memory/scan-report-$(date +%Y%m%d).md
```

### 記憶管理

```bash
# 記憶復述（手動測試）
~/.openclaw/workspace/.scripts/memory-retell.sh daily

# 記憶巩固（手動測試）
~/.openclaw/workspace/.scripts/memory-consolidate.sh

# 記憶清潔（手動測試）
~/.openclaw/workspace/.scripts/memory-hygiene.sh
```

---

## 📖 文檔導航

| 類型 | 文檔 | 說明 |
|------|------|------|
| **架構** | [架構總覽](architecture/overview.md) | 5 分鐘了解全貌 |
| **架構** | [7 個核心文檔](architecture/7-docs-architecture.md) | AI 人格定義 |
| **架構** | [記憶系統](architecture/memory-system.md) | 四層記憶架構 |
| **指南** | [文件掃描](guides/scan-guide.md) | 掃描使用說明 |
| **版本** | [變更日誌](releases/CHANGELOG.md) | 所有版本記錄 |
| **索引** | [文檔索引](README.md) | 快速找到文檔 |

---

## ❓ 常見問題

### Q1：成長計劃如何自動記錄經驗？

**A**: 通過 `auto-memory-hook.sh` 腳本，在以下場景自動記錄：
- Bug 修復完成
- 配置變更
- 會話結束
- 用戶要求記住

### Q2：記憶系統如何工作？

**A**: 記憶從 HOT 層 → WARM 層 → COLD 層 → ARCHIVE 層流動：
- HOT 層：7 天內活躍記憶
- WARM 層：30 天內近期經驗
- COLD 層：永久保存精選記憶
- ARCHIVE 層：按需歸檔歷史

### Q3：文件掃描有什麼用？

**A**: 每週五自動掃描 7 個核心文件，確保：
- 文件內容符合定義
- 沒有重複內容
- 及時清理過期內容

### Q4：如何查看 AI 的改進？

**A**: 查看版本發布報告：
- [releases/](releases/) - 所有發布報告
- [CHANGELOG.md](releases/CHANGELOG.md) - 變更日誌

---

## 🦞 需要幫助？

- 📖 查看 [文檔索引](README.md) 找到需要的文檔
- 📊 查看 [架構總覽](architecture/overview.md) 了解全貌
- 🔧 查看 [腳本集合](../scripts/README.md) 了解自動化腳本

---

**最後更新**: 2026-04-08  
**維護者**: 發哥的龍蝦 🦞
