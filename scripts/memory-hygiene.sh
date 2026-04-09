#!/bin/bash
# memory-hygiene.sh - 記憶清潔腳本
# 
# 功能：
# 1. 檢查內容邊界違規
# 2. 檢查重複內容
# 3. 生成審查報告
#
# 執行頻率：每月 1 日 6:00
# Cron 配置：0 6 1 * *

set -e

WORKSPACE="$HOME/.openclaw/workspace"
REPORT_FILE="$WORKSPACE/memory/memory-hygiene-report-$(date +%Y-%m-%d).md"

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ============================================
# 檢查內容邊界違規
# ============================================
check_boundaries() {
    log_info "檢查內容邊界違規..."
    
    local violations=0
    
    # 檢查 TOOLS.md 是否有規範類內容
    if grep -qE "應該 | 不應該 | 必須 | 禁止 | 規範" "$WORKSPACE/TOOLS.md" 2>/dev/null; then
        log_warning "TOOLS.md 發現規範類內容（應該在 AGENTS.md）"
        grep -nE "應該 | 不應該 | 必須 | 禁止 | 規範" "$WORKSPACE/TOOLS.md" | head -5 >&2
        violations=$((violations + 1))
    fi
    
    # 檢查 SOUL.md 是否有配置/規範類內容
    if grep -qE "配置|appId|appSecret|URL|端口|應該 | 不應該" "$WORKSPACE/SOUL.md" 2>/dev/null; then
        log_warning "SOUL.md 發現配置/規範類內容（應該在 TOOLS.md/AGENTS.md）"
        grep -nE "配置|appId|appSecret|URL|端口|應該 | 不應該" "$WORKSPACE/SOUL.md" | head -5 >&2
        violations=$((violations + 1))
    fi
    
    # 檢查 MEMORY.md 是否有配置/規範類內容
    if grep -qE "配置|appId|appSecret|應該 | 不應該 | 規範" "$WORKSPACE/MEMORY.md" 2>/dev/null; then
        log_warning "MEMORY.md 發現配置/規範類內容（應該在 TOOLS.md/AGENTS.md）"
        grep -nE "配置|appId|appSecret|應該 | 不應該 | 規範" "$WORKSPACE/MEMORY.md" | head -5 >&2
        violations=$((violations + 1))
    fi
    
    # 檢查 AGENTS.md 是否有配置類內容
    if grep -qE "appId|appSecret|http.*://|192\.168\." "$WORKSPACE/AGENTS.md" 2>/dev/null; then
        log_warning "AGENTS.md 發現具體配置值（應該在 TOOLS.md）"
        grep -nE "appId|appSecret|http.*://|192\.168\." "$WORKSPACE/AGENTS.md" | head -5 >&2
        violations=$((violations + 1))
    fi
    
    if [ "$violations" -eq 0 ]; then
        log_success "✅ 未發現邊界違規"
    else
        log_error "❌ 發現 $violations 個邊界違規"
    fi
    
    # 返回 violations 數量（作為退出碼）
    return $violations
}

# ============================================
# 檢查重複內容
# ============================================
check_duplicates() {
    log_info "檢查重複內容..."
    
    local duplicates=0
    
    # 檢查常見重複短語
    local phrases=("搜索工具" "安全紅線" "時間詞彙" "記憶系統" "溝通規範")
    
    for phrase in "${phrases[@]}"; do
        count=$(grep -rl "$phrase" "$WORKSPACE"/*.md 2>/dev/null | wc -l)
        if [ "$count" -gt 1 ]; then
            log_warning "'$phrase' 出現在 $count 個文檔中"
            grep -l "$phrase" "$WORKSPACE"/*.md 2>/dev/null | sed 's|.*workspace/||' >&2
            duplicates=$((duplicates + 1))
        fi
    done
    
    if [ "$duplicates" -eq 0 ]; then
        log_success "✅ 未發現明顯重複內容"
    else
        log_error "❌ 發現 $duplicates 組可能的重複內容"
    fi
    
    # 返回 duplicates 數量（作為退出碼）
    return $duplicates
}

# ⭐ v4.8.0 新增：從重複錯誤中生成規範優化建議
optimize_agents_md() {
    log_info "檢查是否需要優化 AGENTS.md..."
    
    local errors_file="$WORKSPACE/.learnings/ERRORS.md"
    local agents_file="$WORKSPACE/AGENTS.md"
    local suggestions=0
    
    # 查找 Recurrence-Count >= 3 的錯誤
    local repeated_errors=$(grep -B10 "\*\*Recurrence-Count\*\*: [3-9]" "$errors_file" 2>/dev/null)
    
    if [ -n "$repeated_errors" ]; then
        log_warning "發現重複錯誤，生成規範建議..."
        
        # ⭐ v4.8.1 修復：檢查是否已存在相同建議（去重）
        local today=$(date +%Y-%m-%d)
        local existing_suggestion=$(grep -c "自動生成的規範建議（$today）" "$agents_file" 2>/dev/null || echo "0")
        
        if [ "$existing_suggestion" -gt 0 ]; then
            log_info "今日已生成過規範建議，跳過添加"
        else
            # 生成規範建議（僅限今天）
            cat >> "$agents_file" << EOF

## 🔄 自動生成的規範建議（$today）

以下規範是根據重複錯誤自動生成的，請審查：

$repeated_errors

---
EOF
            
            suggestions=$((suggestions + 1))
            log_success "已生成 $suggestions 條規範建議"
        fi
    else
        log_info "無需優化 AGENTS.md"
    fi
}

# ============================================
# 檢查文檔大小
# ============================================
check_sizes() {
    log_info "檢查文檔大小..."
    
    echo ""
    echo "文檔大小統計:"
    echo "=============="
    wc -c "$WORKSPACE/SOUL.md" "$WORKSPACE/AGENTS.md" "$WORKSPACE/TOOLS.md" "$WORKSPACE/MEMORY.md" "$WORKSPACE/HEARTBEAT.md" 2>/dev/null | tail -6
    echo ""
}

# ============================================
# 生成審查報告
# ============================================
generate_report() {
    local boundary_violations="$1"
    local duplicate_count="$2"
    
    log_info "生成審查報告..."
    
    cat > "$REPORT_FILE" << EOF
# 記憶清潔報告

**日期**: $(date +%Y-%m-%d)
**執行腳本**: memory-hygiene.sh
**版本**: v4.7.2

---

## 📊 檢查結果

### 邊界違規
**數量**: $boundary_violations 個

$(if [ "$boundary_violations" -gt 0 ]; then echo "⚠️ 需要處理"; else echo "✅ 無違規"; fi)

### 重複內容
**數量**: $duplicate_count 組

$(if [ "$duplicate_count" -gt 0 ]; then echo "⚠️ 需要處理"; else echo "✅ 無明顯重複"; fi)

---

## 📋 文檔大小統計

\`\`\`
$(wc -c "$WORKSPACE/SOUL.md" "$WORKSPACE/AGENTS.md" "$WORKSPACE/TOOLS.md" "$WORKSPACE/MEMORY.md" "$WORKSPACE/HEARTBEAT.md" 2>/dev/null | tail -6)
\`\`\`

---

## 🔧 建議操作

$(if [ "$boundary_violations" -gt 0 ]; then
    echo "1. 檢查邊界違規內容，移動到正確位置"
fi

if [ "$duplicate_count" -gt 0 ]; then
    echo "2. 檢查重複內容，只保留一處"
fi

if [ $boundary_violations -eq 0 ] && [ $duplicate_count -eq 0 ]; then
    echo "✅ 無需操作，文檔狀態良好"
fi)

---

## 📚 參考資源

- **內容邊界表**: \`GROWTH-PLAN/docs/architecture/7-docs-architecture.md\`
- **優化經驗**: \`GROWTH-PLAN/implementation/7-docs-optimization-experience.md\`

---

*本報告由 memory-hygiene.sh 自動生成*
EOF

    log_success "報告已生成：$REPORT_FILE"
}

# ============================================
# 主函數
# ============================================
main() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🧹 記憶清潔檢查 ($(date +%Y-%m-%d))"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # 1. 檢查內容邊界
    check_boundaries || boundary_violations=$?
    echo ""
    
    # 2. 檢查重複內容
    check_duplicates || duplicate_count=$?
    echo ""
    
    # 3. 檢查文檔大小
    check_sizes
    echo ""
    
    # 4. 生成審查報告
    generate_report "$boundary_violations" "$duplicate_count"
    echo ""
    
    # 5. 規範優化（從重複錯誤生成規範建議）
    optimize_agents_md
    echo ""
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 檢查完成"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "邊界違規：$boundary_violations 個"
    echo "重複內容：$duplicate_count 組"
    echo "審查報告：$REPORT_FILE"
    echo ""
}

# 執行主函數
main
