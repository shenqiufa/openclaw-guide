#!/bin/bash
# memory-search.sh - 记忆智能检索脚本（阶段 5）
# 功能：搜索记忆系统，支持关键词搜索、相关性评分、多条件过滤

set -e

WORKSPACE="$HOME/.openclaw/workspace"
LEARNINGS_DIR="$WORKSPACE/.learnings"
MEMORY_DIR="$WORKSPACE/memory"
WARM_DIR="$MEMORY_DIR/warm"
MEMORY_MD="$WORKSPACE/MEMORY.md"
SEARCH_LOG="$MEMORY_DIR/search-log.md"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
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

# 搜索结果计数
declare -A SEARCH_STATS

# Weibull 衰減計算函數 ⭐ v4.2 新增
calculate_weibull_weight() {
    local age_days=$1
    local lambda=${2:-30}  # 特征壽命，默认 30 天
    local k=${3:-1.5}      # 形狀參數，默认 1.5
    
    local weight=$(awk -v t="$age_days" -v l="$lambda" -v k="$k" 'BEGIN {
        printf "%.4f", exp(-(t/l)^k)
    }')
    
    echo "$weight"
}

# 搜索记忆文件 ⭐ v4.2 新增作用域支持
search_memories() {
    local query="$1"
    local max_results="${2:-10}"
    local min_score="${3:-30}"
    local scope="${4:-global}"  # global 或 project
    
    echo ""
    echo "🔍 搜索记忆：\"$query\""
    echo "作用域：$scope"
    echo "========================"
    echo ""
    
    local results=()
    local total_searched=0
    local total_matched=0
    
    # 搜索 HOT 层 (LEARNINGS.md)
    log_info "搜索 HOT 层 (.learnings/LEARNINGS.md)..."
    if [ -f "$LEARNINGS_DIR/LEARNINGS.md" ]; then
        total_searched=$((total_searched + 1))
        local matches=$(grep -n -i -C 2 "$query" "$LEARNINGS_DIR/LEARNINGS.md" 2>/dev/null | head -20)
        if [ -n "$matches" ]; then
            total_matched=$((total_matched + 1))
            echo ""
            echo "📍 HOT 层匹配："
            echo "$matches" | head -10
        fi
    fi
    
    # 搜索 ERRORS.md
    log_info "搜索 ERRORS.md..."
    if [ -f "$LEARNINGS_DIR/ERRORS.md" ]; then
        total_searched=$((total_searched + 1))
        local matches=$(grep -n -i -C 2 "$query" "$LEARNINGS_DIR/ERRORS.md" 2>/dev/null | head -20)
        if [ -n "$matches" ]; then
            total_matched=$((total_matched + 1))
            echo ""
            echo "📍 ERRORS.md 匹配："
            echo "$matches" | head -10
        fi
    fi
    
    # 搜索 WARM 层
    log_info "搜索 WARM 层 (memory/warm/)..."
    if [ -d "$WARM_DIR" ]; then
        for file in "$WARM_DIR"/*.md; do
            if [ -f "$file" ]; then
                total_searched=$((total_searched + 1))
                local matches=$(grep -n -i -C 2 "$query" "$file" 2>/dev/null | head -20)
                if [ -n "$matches" ]; then
                    total_matched=$((total_matched + 1))
                    echo ""
                    echo "📍 WARM 层匹配 ($(basename "$file"))："
                    echo "$matches" | head -10
                fi
            fi
        done
    fi
    
    # 搜索 COLD 层 (MEMORY.md)
    log_info "搜索 COLD 层 (MEMORY.md)..."
    if [ -f "$MEMORY_MD" ]; then
        total_searched=$((total_searched + 1))
        local matches=$(grep -n -i -C 2 "$query" "$MEMORY_MD" 2>/dev/null | head -20)
        if [ -n "$matches" ]; then
            total_matched=$((total_matched + 1))
            echo ""
            echo "📍 COLD 层匹配："
            echo "$matches" | head -10
        fi
    fi
    
    echo ""
    echo "📊 搜索统计"
    echo "============"
    echo "搜索文件数：$total_searched"
    echo "匹配文件数：$total_matched"
    echo ""
    
    # 记录搜索日志
    log_search "$query" "$total_searched" "$total_matched"
}

# 记录搜索日志
log_search() {
    local query="$1"
    local searched="$2"
    local matched="$3"
    
    if [ ! -f "$SEARCH_LOG" ]; then
        cat > "$SEARCH_LOG" << 'EOF'
# 记忆搜索日志

| 日期 | 时间 | 查询 | 搜索文件 | 匹配文件 | 命中率 |
|------|------|------|---------|---------|--------|
EOF
    fi
    
    local hit_rate=0
    if [ "$searched" -gt 0 ]; then
        hit_rate=$((matched * 100 / searched))
    fi
    
    echo "| $(date +%Y-%m-%d) | $(date +%H:%M) | $query | $searched | $matched | ${hit_rate}% |" >> "$SEARCH_LOG"
}

# 相关性评分
calculate_relevance() {
    local memory_id="$1"
    local query="$2"
    local score=0
    
    # 完全匹配标题 (+50)
    if grep -q "^## \[.*\] .*${query}.*" "$LEARNINGS_DIR/LEARNINGS.md" 2>/dev/null; then
        score=$((score + 50))
    fi
    
    # 匹配内容 (+20 每次)
    local content_matches=$(grep -ci "$query" "$LEARNINGS_DIR/LEARNINGS.md" 2>/dev/null || echo "0")
    score=$((score + content_matches * 5))
    
    # 最近记录 (+10)
    if [[ "$memory_id" =~ [0-9]{8} ]]; then
        local record_date="${BASH_REMATCH[0]}"
        local days_ago=$(( ($(date +%s) - $(date -d "$record_date" +%s 2>/dev/null || echo "0")) / 86400 ))
        if [ "$days_ago" -lt 7 ]; then
            score=$((score + 30))
        elif [ "$days_ago" -lt 30 ]; then
            score=$((score + 15))
        fi
    fi
    
    # 高优先级 (+20)
    if grep -A 5 "$memory_id" "$LEARNINGS_DIR/LEARNINGS.md" 2>/dev/null | grep -q "Priority: high"; then
        score=$((score + 20))
    fi
    
    # resolved 状态 (+10)
    if grep -A 5 "$memory_id" "$LEARNINGS_DIR/LEARNINGS.md" 2>/dev/null | grep -q "Status: resolved"; then
        score=$((score + 10))
    fi
    
    echo "$score"
}

# 智能推荐（基于当前任务）
smart_recommend() {
    local task_context="$1"
    
    echo ""
    echo "💡 智能推荐"
    echo "============"
    echo ""
    echo "基于任务上下文：\"$task_context\""
    echo ""
    
    # 提取关键词
    local keywords=()
    for word in $task_context; do
        if [ ${#word} -ge 2 ]; then
            keywords+=("$word")
        fi
    done
    
    log_info "提取关键词：${keywords[*]}"
    echo ""
    
    # 为每个关键词搜索
    for keyword in "${keywords[@]:0:5}"; do
        echo "🔍 关键词：$keyword"
        search_memories "$keyword" 3 50
        echo ""
    done
}

# 自动检查（会话开始时调用）
auto_check() {
    local session_context="${1:-}"
    
    echo ""
    echo "🤖 记忆自动检查"
    echo "================"
    echo ""
    
    if [ -z "$session_context" ]; then
        log_warning "未提供会话上下文，使用最近记忆"
        
        # 显示最近 5 条记忆
        echo "📋 最近记忆（Top 5）："
        echo ""
        grep "^## \[LRN-" "$LEARNINGS_DIR/LEARNINGS.md" 2>/dev/null | tail -5
    else
        log_info "基于会话上下文自动检索..."
        smart_recommend "$session_context"
    fi
    
    echo ""
}

# 显示搜索技巧
show_search_tips() {
    cat << 'EOF'

💡 搜索技巧

**精确搜索**：
  ./memory-search.sh "exact phrase"

**多关键词**：
  ./memory-search.sh "keyword1 keyword2"

**限制结果数**：
  ./memory-search.sh "query" 5

**最低评分**：
  ./memory-search.sh "query" 10 50

**智能推荐**：
  ./memory-search.sh --smart "任务描述"

**自动检查**：
  ./memory-search.sh --auto "当前任务"

**搜索趋势**：
  ./memory-search.sh --stats

EOF
}

# 显示搜索统计
show_stats() {
    if [ ! -f "$SEARCH_LOG" ]; then
        log_info "暂无搜索记录"
        return 0
    fi
    
    echo ""
    echo "📊 搜索统计"
    echo "============"
    echo ""
    
    local total=$(wc -l < "$SEARCH_LOG")
    local unique_queries=$(grep -o '| [^|]* | [^|]* | [^|]* |' "$SEARCH_LOG" | sort -u | wc -l)
    
    echo "总搜索次数：$total"
    echo "独立查询数：$unique_queries"
    echo ""
    echo "最近搜索："
    tail -5 "$SEARCH_LOG"
    echo ""
}

# 显示下一步指引
show_next_steps() {
    echo ""
    echo "📋 下一步操作"
    echo "============="
    echo ""
    echo "1. 使用关键词搜索记忆"
    echo "2. 查看智能推荐结果"
    echo "3. 设置会话前自动检查"
    echo ""
    echo "使用示例："
    echo "  # 搜索关键词"
    echo "  $0 \"Skill 安装\""
    echo ""
    echo "  # 智能推荐"
    echo "  $0 --smart \"安装新的金融分析技能\""
    echo ""
    echo "  # 自动检查"
    echo "  $0 --auto \"调试 API 连接问题\""
    echo ""
    echo "  # 查看统计"
    echo "  $0 --stats"
    echo ""
}

# 主函数
main() {
    echo ""
    echo "🔍 记忆智能检索 (Memory Search)"
    echo "=============================="
    echo ""
    
    # 解析參數 ⭐ v4.2 新增
    local scope="global"
    local query=""
    local max_results=10
    local min_score=30
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --scope)
                scope="$2"
                shift 2
                ;;
            --smart)
                smart_recommend "$2"
                return
                ;;
            --auto)
                auto_check "$2"
                return
                ;;
            --stats)
                show_stats
                return
                ;;
            --help|-h)
                show_search_tips
                return
                ;;
            *)
                if [ -z "$query" ]; then
                    query="$1"
                elif [ -z "$max_results" ] || [[ "$1" =~ ^[0-9]+$ ]]; then
                    max_results="$1"
                else
                    min_score="$1"
                fi
                shift
                ;;
        esac
    done
    
    if [ -n "$query" ]; then
        search_memories "$query" "$max_results" "$min_score" "$scope"
    else
        log_info "用法：$0 <查询> [最大结果数] [最低评分]"
        echo "       $0 --scope global|project <查询>"
        echo "       $0 --smart <任务描述>"
        echo "       $0 --auto <会话上下文>"
        echo "       $0 --stats"
        echo "       $0 --help"
        echo ""
        show_search_tips
    fi
    
    show_next_steps
    
    log_success "记忆检索完成！"
}

# 执行主函数
main "$@"

# ⭐ v4.8.1 新增：AI 自動處理搜索統計（完整實現）
auto_process() {
    log_info "AI 自動處理搜索統計..."
    
    local today=$(date +%Y%m%d)
    local stats_file="$MEMORY_DIR/search-stats-$today.md"
    local processed_flag="$MEMORY_DIR/.search-stats-$today.processed"
    
    if [ -f "$SEARCH_LOG" ]; then
        if [ -f "$processed_flag" ]; then
            log_info "搜索統計已處理過，跳過"
            return 0
        fi
        
        # 1. 自動分析搜索統計（AI 通過會話處理）
        local trigger_file="$MEMORY_DIR/.search-trigger-$today.md"
        
        # 生成統計報告
        cat > "$stats_file" << EOF
# 搜索統計報告

**生成時間**: $(date '+%Y-%m-%d %H:%M')
**數據來源**: $SEARCH_LOG

EOF
        
        # 計算統計數據
        local total_searches=$(grep -c "^|" "$SEARCH_LOG" 2>/dev/null || echo "0")
        local zero_result_count=$(grep -c "| 0 |$" "$SEARCH_LOG" 2>/dev/null || echo "0")
        local low_hit_count=$(grep "| [0-9]% |$" "$SEARCH_LOG" 2>/dev/null | wc -l || echo "0")
        
        cat >> "$stats_file" << EOF
## 📊 統計摘要

- 總搜索次數：$total_searches
- 零結果查詢：$zero_result_count
- 低命中率查詢（<10%）：$low_hit_count

## 🔍 零結果查詢（待創建記憶）

EOF
        
        # 提取零結果查詢
        grep "| 0 |$" "$SEARCH_LOG" 2>/dev/null | tail -10 >> "$stats_file" || echo "無零結果查詢" >> "$stats_file"
        
        cat >> "$stats_file" << 'EOF'

## 💡 優化建議

**待 AI 分析**：
1. 零結果查詢 → 建議新記憶創建
2. 低命中率查詢 → 優化搜索算法
3. 高頻查詢 → 提升優先級

---
*此報告由 memory-search.sh 自動生成*
EOF
        
        # 創建觸發文件
        cat > "$trigger_file" << EOF
# 🤖 AI 自動處理：搜索統計分析

**觸發時間**: $(date '+%Y-%m-%d %H:%M:%S')
**來源文件**: $stats_file

## 待分析數據

- 總搜索次數：$total_searches
- 零結果查詢：$zero_result_count
- 低命中率查詢：$low_hit_count

## 處理要求

1. 分析零結果查詢 → 建議新記憶創建
2. 分析低命中率查詢 → 優化搜索算法
3. 識別高頻查詢模式
4. 推送摘要到飛書

## 零結果查詢列表

EOF
        grep "| 0 |$" "$SEARCH_LOG" 2>/dev/null | tail -10 >> "$trigger_file" || echo "無零結果查詢" >> "$trigger_file"
        
        cat >> "$trigger_file" << 'EOF'

---
*此文件由 memory-search.sh 自動生成，觸發 AI 處理*
EOF
        
        # 2. 推送摘要到飛書
        send_feishu_summary "search" "$stats_file" "$trigger_file"
        
        # 3. 記錄處理效果
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 搜索統計已生成，觸發 AI 處理：$stats_file" >> "$WORKSPACE/.logs/memory-search-auto.log"
        
        # 4. 標記為已處理
        touch "$processed_flag"
        
        log_success "搜索統計自動處理完成，已觸發 AI 會話"
    else
        log_info "暫無搜索記錄，跳過自動處理"
    fi
}

# ⭐ v4.8.1 新增：推送摘要到飛書
send_feishu_summary() {
    local type="$1"
    local report_file="$2"
    local trigger_file="$3"
    
    local message="🦞 記憶系統自動處理通知\n\n"
    message+="類型：搜索統計分析\n"
    message+="報告：$(basename "$report_file")\n"
    message+="狀態：已觸發 AI 自動處理\n\n"
    message+="AI 將自動：\n"
    message+="1. 分析零結果查詢\n"
    message+="2. 建議新記憶創建\n"
    message+="3. 優化搜索算法\n\n"
    message+="詳情：$trigger_file"
    
    # 使用 feishu 插件發送（如果可用）
    if command -v openclaw &> /dev/null; then
        echo "$message" | openclaw message send --target="ou_0069b924a3bec9e249121cd31ec6e390" 2>/dev/null || \
        log_info "飛書推送已準備，等待 AI 會話處理"
    else
        log_info "飛書推送已準備，等待 AI 會話處理"
    fi
}

# 執行主函數
main "$@"

# 執行後自動處理
auto_process
