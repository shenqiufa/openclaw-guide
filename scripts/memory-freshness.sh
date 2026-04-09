#!/bin/bash
# memory-freshness.sh - 記憶新鮮度檢查腳本
# 用法：./memory-freshness.sh [記憶文件]

set -e

MEMORY_FILE="$1"

# 物理限制常量
MAX_LINES=200
MAX_SIZE_KB=25
MAX_SIZE_BYTES=$((MAX_SIZE_KB * 1024))

if [ -z "$MEMORY_FILE" ]; then
    echo "❌ 錯誤：請指定記憶文件"
    echo "用法：./memory-freshness.sh ~/.openclaw/workspace/.learnings/LEARNINGS.md"
    exit 1
fi

if [ ! -f "$MEMORY_FILE" ]; then
    echo "❌ 錯誤：文件不存在：$MEMORY_FILE"
    exit 1
fi

# ============================================
# 檢查物理限制（行數和大小）
# ============================================
check_physical_limits() {
    local file="$1"
    local line_count=$(wc -l < "$file")
    local file_size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
    
    echo "=== 物理限制檢查 ==="
    echo ""
    echo "當前狀態："
    echo "  行數：$line_count / $MAX_LINES"
    echo "  大小：$((file_size / 1024))KB / ${MAX_SIZE_KB}KB"
    echo ""
    
    local exceeded=false
    
    if [ $line_count -gt $MAX_LINES ]; then
        echo "⚠️ 警告：行數超過限制（$line_count > $MAX_LINES）"
        exceeded=true
    fi
    
    if [ $file_size -gt $MAX_SIZE_BYTES ]; then
        echo "⚠️ 警告：大小超過限制（$((file_size / 1024))KB > ${MAX_SIZE_KB}KB）"
        exceeded=true
    fi
    
    if [ "$exceeded" = true ]; then
        echo ""
        echo "建議："
        echo "  1. 運行歸檔腳本：./.scripts/archive-old-learnings.sh"
        echo "  2. 手動審查並删除過時記錄"
        echo "  3. 將舊記錄移動到 .archive/ 目錄"
        echo ""
        return 1
    else
        echo "✅ 物理限制檢查通過"
        echo ""
        return 0
    fi
}

# 執行物理限制檢查
check_physical_limits "$MEMORY_FILE" || true

# ============================================
# 獲取文件修改時間（秒）
# ============================================
if [[ "$OSTYPE" == "darwin"* ]]; then
    MTIME=$(stat -f %m "$MEMORY_FILE" 2>/dev/null)
else
    MTIME=$(stat -c %Y "$MEMORY_FILE" 2>/dev/null)
fi

# 計算年齡（天數）
NOW=$(date +%s)
AGE_SECONDS=$((NOW - MTIME))
AGE_DAYS=$((AGE_SECONDS / 86400))

# 輸出結果
if [ $AGE_DAYS -eq 0 ]; then
    echo "✅ 今天"
    echo ""
    echo "記憶狀態：新鮮（今天創建）"
elif [ $AGE_DAYS -eq 1 ]; then
    echo "✅ 昨天"
    echo ""
    echo "記憶狀態：新鮮（昨天創建）"
else
    echo "⚠️ $AGE_DAYS 天前"
    echo ""
    echo "記憶狀態：可能過時"
    echo ""
    echo "警告："
    echo "  這條記憶是 $AGE_DAYS 天前的。"
    echo "  記憶是時間點的觀察，不是實時狀態。"
    echo "  執行前請驗證當前狀態。"
    echo ""
    
    if [ $AGE_DAYS -ge 30 ]; then
        echo "建議："
        echo "  這條記憶已超過 30 天，建議："
        echo "  1. 審查記憶內容是否仍然有效"
        echo "  2. 如果過時，更新或删除"
        echo "  3. 如果仍然有效，標記為'已驗證'"
        echo ""
    fi
    
    if [ $AGE_DAYS -ge 90 ]; then
        echo "嚴重警告："
        echo "  這條記憶已超過 90 天，強烈建議："
        echo "  1. 立即審查"
        echo "  2. 考慮歸檔到 .archive/ 目錄"
        echo "  3. 如果無價值，直接删除"
        echo ""
    fi
fi

# 返回年齡天數（供其他腳本使用）
echo "年齡：$AGE_DAYS 天"
