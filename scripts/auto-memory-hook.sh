#!/bin/bash
# auto-memory-hook.sh - 實時記憶記錄鉤子
# 在重大事件發生時自動記錄
# 
# v4.7.2 新增功能：
# - 重複檢測（關鍵詞檢測）
# - AI 主動分類（根據內容類型自動分類到正確文檔）

set -e

WORKSPACE="$HOME/.openclaw/workspace"
LEARNINGS="$WORKSPACE/.learnings"
MEMORY_DIR="$WORKSPACE/memory"
TODAY=$(date +%Y-%m-%d)
TIMESTAMP=$(date -Iseconds)

# 參數：$1=事件類型，$2=標題，$3=詳情
EVENT_TYPE="$1"
TITLE="$2"
DETAILS="$3"

# ============================================
# v4.7.2 新增：重複檢測函數（關鍵詞檢測）
# ============================================
check_duplicate() {
    local content_type="$1"
    local target_doc="$2"
    
    echo "🔍 檢查重複內容（$content_type → $target_doc）..."
    
    case "$content_type" in
        "規範")
            # 檢查規範類內容是否已在 AGENTS.md
            if grep -qE "應該 | 不應該 | 必須 | 禁止 | 規範" "$WORKSPACE/AGENTS.md" 2>/dev/null; then
                echo "⚠️ AGENTS.md 已有規範類內容，請檢查是否重複"
                return 1
            fi
            ;;
        "配置")
            # 檢查配置類內容是否已在 TOOLS.md
            if grep -qE "配置|appId|appSecret|URL|端口" "$WORKSPACE/TOOLS.md" 2>/dev/null; then
                echo "⚠️ TOOLS.md 已有配置類內容，請檢查是否重複"
                return 1
            fi
            ;;
        "記憶")
            # 檢查記憶類內容是否已在 MEMORY.md
            if grep -qE "經驗 | 教訓 | 偏好 | 背景" "$WORKSPACE/MEMORY.md" 2>/dev/null; then
                echo "⚠️ MEMORY.md 已有記憶類內容，請檢查是否重複"
                return 1
            fi
            ;;
    esac
    
    echo "✅ 未發現重複內容"
    return 0
}

# ============================================
# v4.7.2 新增：AI 主動分類函數
# ============================================
classify_content() {
    local content="$1"
    
    # 判斷內容類型
    if echo "$content" | grep -qE "應該 | 不應該 | 必須 | 禁止 | 規範 | 流程"; then
        echo "規範"
    elif echo "$content" | grep -qE "配置|appId|appSecret|URL|端口|SSH|API"; then
        echo "配置"
    elif echo "$content" | grep -qE "經驗 | 教訓 | 偏好 | 背景 | 用戶"; then
        echo "記憶"
    elif echo "$content" | grep -qE "價值觀 | 原則 | 信念 | 道德"; then
        echo "價值觀"
    else
        echo "未知"
    fi
}

# ============================================
# v4.7.2 新增：邊界違規檢查
# ============================================
check_boundary_violation() {
    local content_type="$1"
    local target_doc="$2"
    
    # 檢查是否放錯位置
    case "$target_doc" in
        "TOOLS.md")
            if [ "$content_type" = "規範" ]; then
                echo "⚠️ 警告：規範類內容不應該放在 TOOLS.md，應該放在 AGENTS.md"
                return 1
            fi
            ;;
        "SOUL.md")
            if [ "$content_type" = "配置" ] || [ "$content_type" = "規範" ]; then
                echo "⚠️ 警告：配置/規範類內容不應該放在 SOUL.md"
                return 1
            fi
            ;;
        "MEMORY.md")
            if [ "$content_type" = "配置" ] || [ "$content_type" = "規範" ]; then
                echo "⚠️ 警告：配置/規範類內容不應該放在 MEMORY.md，應該分別放在 TOOLS.md/AGENTS.md"
                return 1
            fi
            ;;
    esac
    
    return 0
}

case "$EVENT_TYPE" in
  "bugfix")
    # Bug 修复完成时记录
    cat >> "$LEARNINGS/LEARNINGS.md" << EOF

## [LRN-$TODAY-$(date +%H%M)] $TITLE

**Logged**: $TIMESTAMP
**Priority**: high
**Status**: resolved
**Area**: bugfix

### Summary
$DETAILS

### Metadata
- Source: auto-capture
- Pattern-Key: bugfix.$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

---
EOF
    echo "✅ [BUGFIX] 已记录：$TITLE"
    ;;

  "error")
    # 错误解决时记录
    cat >> "$LEARNINGS/ERRORS.md" << EOF

## [ERR-$TODAY-$(date +%H%M)] $TITLE

**Logged**: $TIMESTAMP
**Priority**: medium
**Status**: resolved
**Area**: error

### Error
$DETAILS

### Solution
（待补充）

### Metadata
- Reproducible: unknown

---
EOF
    echo "✅ [ERROR] 已记录：$TITLE"
    ;;

  "config")
    # 配置变更時記錄（v4.7.2 增強：AI 主動分類 + 重複檢測）
    
    # 1. AI 主動分類
    content_type=$(classify_content "$DETAILS")
    echo "📊 AI 分類結果：$content_type"
    
    # 2. 邊界違規檢查
    case "$content_type" in
        "規範")
            echo "⚠️ 檢測到規範類內容，應該記錄到 AGENTS.md"
            target_doc="$WORKSPACE/AGENTS.md"
            ;;
        "配置")
            echo "✅ 檢測到配置類內容，記錄到 TOOLS.md"
            target_doc="$WORKSPACE/TOOLS.md"
            ;;
        "記憶")
            echo "✅ 檢測到記憶類內容，記錄到 MEMORY.md"
            target_doc="$WORKSPACE/MEMORY.md"
            ;;
        *)
            echo "⚠️ 未知內容類型，默認記錄到 LEARNINGS.md"
            target_doc="$LEARNINGS/LEARNINGS.md"
            ;;
    esac
    
    # 3. 重複檢測
    check_duplicate "$content_type" "$target_doc" || true
    
    # 4. 記錄到正確位置
    cat >> "$target_doc" << EOF

## [CFG-$TODAY-$(date +%H%M)] $TITLE

**Logged**: $TIMESTAMP
**Priority**: medium
**Status**: applied
**Area**: config
**Content-Type**: $content_type

### Summary
$DETAILS

### Metadata
- Source: auto-capture (v4.7.2 AI 分類)
- Target-Doc: $(basename "$target_doc")
- Pattern-Key: config.$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

---
EOF
    echo "✅ [CONFIG] 已記錄到 $(basename "$target_doc")：$TITLE"
    ;;;

  "session-end")
    # 会话结束时记录
    cat >> "$MEMORY_DIR/$TODAY.md" << EOF

## 会话结束 $(date +%H:%M)

$DETAILS

---
EOF
    echo "✅ [SESSION] 已记录会话总结"
    ;;

  "approval")
    # 用户认可时记录（v4.6.0 新增）
    cat >> "$LEARNINGS/LEARNINGS.md" << EOF

## [LRN-$TODAY-$(date +%H%M)] $TITLE

**Logged**: $TIMESTAMP
**Priority**: medium
**Status**: active
**Area**: approval

### Summary
$DETAILS

### Metadata
- Source: auto-capture
- Type: user_approval
- Pattern-Key: approval.$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

### Why
用户认可的方法值得继续保持

### How to apply
- 在类似场景下继续使用此方法
- 避免过度保守
- 平衡正反馈和纠正

---
EOF
    echo "✅ [APPROVAL] 已记录用户认可：$TITLE"
    ;;

  "milestone")
    # 重要里程碑
    cat >> "$LEARNINGS/FUTURE-PLANS.md" << EOF

## ✅ 已完成：$TITLE

**时间**: $TIMESTAMP

$DETAILS

---
EOF
    echo "✅ [MILESTONE] 已记录：$TITLE"
    ;;
    
  "version-change")
    # ⭐ v4.7.1 新增：版本號變更時自動同步
    new_version="$DETAILS"
    echo "🔄 檢測到版本號變更：$new_version"
    
    # 自動運行 sync-version.sh
    sync_script="$WORKSPACE/.scripts/sync-version.sh"
    if [ -x "$sync_script" ]; then
        echo "🔄 正在同步版本號到 $new_version..."
        "$sync_script" "$new_version"
        echo "✅ 版本號同步完成"
    else
        echo "⚠️ sync-version.sh 不可用，請手動同步"
    fi
    ;;
    
  "check-recurrence")
    # ⭐ v4.7.1 新增：檢查重複問題
    pattern="$DETAILS"
    count=$(grep -c "$pattern" "$LEARNINGS/ERRORS.md" 2>/dev/null || echo "0")
    
    if [ "$count" -ge 2 ]; then
        echo "⚠️ 重複問題檢測：'$pattern' 已出現 $count 次"
        
        # 記錄重複模式
        cat >> "$LEARNINGS/LEARNINGS.md" << EOF

## [LRN-$TODAY-$(date +%H%M)] 🔁 重複問題：$pattern

**Logged**: $TIMESTAMP
**Priority**: high
**Status**: pending
**Area**: recurrence

### Summary
問題 '$pattern' 已出現 $count 次，需要系統性解決

### Details
- 首次出現：待查
- 最近出現：$TIMESTAMP
- 出現次數：$count 次

### Suggested Action
1. 分析根本原因
2. 制定系統性解決方案
3. 更新相關文檔

### Metadata
- Source: auto-capture (recurrence check)
- Pattern-Key: recurrence.$(echo "$pattern" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
- Recurrence-Count: $count

---
EOF
        echo "✅ 已記錄重複模式到 LEARNINGS.md"
    else
        echo "✅ 問題 '$pattern' 首次出現，無需特別處理"
    fi
    ;;

  *)
    echo "❌ 未知事件类型：$EVENT_TYPE"
    exit 1
    ;;
esac

# 同步到当日记忆文件
cat >> "$MEMORY_DIR/$TODAY.md" << EOF

### $(date +%H:%M) - $TITLE
$DETAILS

EOF

echo "📝 已同步到 memory/$TODAY.md"
