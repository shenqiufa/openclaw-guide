#!/bin/bash
# memory-rank.sh - 检索结果排序脚本（阶段 5）
# 功能：对搜索结果进行多条件排序（时间/相关性/使用频率）

set -e

WORKSPACE="$HOME/.openclaw/workspace"
LEARNINGS_DIR="$WORKSPACE/.learnings"
MEMORY_DIR="$WORKSPACE/memory"
MEMORY_MD="$WORKSPACE/MEMORY.md"
RANK_LOG="$MEMORY_DIR/rank-log.md"

# 颜色定义
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

# 计算记忆评分
calculate_score() {
    local memory_id="$1"
    local query="$2"
    local sort_by="${3:-relevance}"
    
    local score=0
    local max_score=100
    
    # 获取记忆元数据
    local memory_block=$(grep -A 15 "## \[$memory_id\]" "$LEARNINGS_DIR/LEARNINGS.md" 2>/dev/null)
    
    if [ -z "$memory_block" ]; then
        echo "0"
        return
    fi
    
    # 1. 相关性评分 (0-40 分)
    if [ "$sort_by" == "relevance" ] || [ "$sort_by" == "all" ]; then
        local keyword_matches=$(echo "$memory_block" | grep -ci "$query" 2>/dev/null || echo "0")
        local relevance_score=$((keyword_matches * 5))
        if [ $relevance_score -gt 40 ]; then
            relevance_score=40
        fi
        score=$((score + relevance_score))
    fi
    
    # 2. 时间评分 (0-30 分)
    if [[ "$memory_id" =~ ([0-9]{8}) ]]; then
        local record_date="${BASH_REMATCH[1]}"
        local days_ago=0
        
        # 计算天数差
        if command -v date &> /dev/null; then
            local record_ts=$(date -d "$record_date" +%s 2>/dev/null || echo "0")
            local now_ts=$(date +%s)
            if [ "$record_ts" -gt 0 ]; then
                days_ago=$(( (now_ts - record_ts) / 86400 ))
            fi
        fi
        
        if [ $days_ago -lt 7 ]; then
            score=$((score + 30))  # 7 天内 +30
        elif [ $days_ago -lt 30 ]; then
            score=$((score + 20))  # 30 天内 +20
        elif [ $days_ago -lt 90 ]; then
            score=$((score + 10))  # 90 天内 +10
        else
            score=$((score + 5))   # 90 天以上 +5
        fi
    fi
    
    # 3. 优先级评分 (0-20 分)
    local priority=$(echo "$memory_block" | grep "Priority:" | head -1)
    if [[ "$priority" == *"critical"* ]]; then
        score=$((score + 20))
    elif [[ "$priority" == *"high"* ]]; then
        score=$((score + 15))
    elif [[ "$priority" == *"medium"* ]]; then
        score=$((score + 10))
    else
        score=$((score + 5))  # low 或未指定
    fi
    
    # 4. 状态评分 (0-10 分)
    local status=$(echo "$memory_block" | grep "Status:" | head -1)
    if [[ "$status" == *"resolved"* ]]; then
        score=$((score + 10))  # 已解决 +10
    elif [[ "$status" == *"in_progress"* ]]; then
        score=$((score + 5))   # 进行中 +5
    fi
    
    echo "$score"
}

# 对记忆进行排序
rank_memories() {
    local query="$1"
    local sort_by="${2:-relevance}"
    local top_n="${3:-10}"
    
    echo ""
    echo "📊 记忆排序结果"
    echo "================"
    echo ""
    echo "查询：$query"
    echo "排序方式：$sort_by"
    echo "显示数量：$top_n"
    echo ""
    
    # 提取所有记忆 ID
    local memory_ids=$(grep "^## \[LRN-" "$LEARNINGS_DIR/LEARNINGS.md" 2>/dev/null | sed 's/## \[\(.*\)\].*/\1/')
    
    if [ -z "$memory_ids" ]; then
        log_warning "未找到记忆记录"
        return 0
    fi
    
    # 计算每个记忆的评分
    declare -A scores
    for id in $memory_ids; do
        local score=$(calculate_score "$id" "$query" "$sort_by")
        scores[$id]=$score
    done
    
    # 排序并显示 Top N
    echo "🏆 Top $top_n 记忆："
    echo ""
    echo "| 排名 | ID | 评分 | 优先级 | 状态 | 摘要 |"
    echo "|------|-----|------|--------|------|------|"
    
    local rank=0
    for id in $(for k in "${!scores[@]}"; do echo "$k ${scores[$k]}"; done | sort -k2 -rn | head -$top_n | awk '{print $1}'); do
        rank=$((rank + 1))
        local score=${scores[$id]}
        
        # 获取记忆信息
        local memory_block=$(grep -A 10 "## \[$id\]" "$LEARNINGS_DIR/LEARNINGS.md" 2>/dev/null)
        local priority=$(echo "$memory_block" | grep "Priority:" | head -1 | sed 's/.*Priority: *\([^ ]*\).*/\1/')
        local status=$(echo "$memory_block" | grep "Status:" | head -1 | sed 's/.*Status: *\([^ ]*\).*/\1/')
        local summary=$(echo "$memory_block" | grep "### Summary" -A 1 | tail -1 | head -c 30)
        
        printf "| %d | %s | %d | %s | %s | %s... |\n" \
            "$rank" "$id" "$score" "${priority:-N/A}" "${status:-N/A}" "${summary:-N/A}"
    done
    
    echo ""
}

# 按时间排序
sort_by_time() {
    local order="${1:-desc}"
    
    echo ""
    echo "📅 按时间排序"
    echo "=============="
    echo ""
    
    if [ "$order" == "desc" ]; then
        echo "最新记忆（倒序）："
        grep "^## \[LRN-" "$LEARNINGS_DIR/LEARNINGS.md" 2>/dev/null | tail -10
    else
        echo "最早记忆（正序）："
        grep "^## \[LRN-" "$LEARNINGS_DIR/LEARNINGS.md" 2>/dev/null | head -10
    fi
    
    echo ""
}

# 按使用频率排序（基于搜索日志）
sort_by_usage() {
    echo ""
    echo "🔥 按使用频率排序"
    echo "=================="
    echo ""
    
    local search_log="$MEMORY_DIR/search-log.md"
    
    if [ ! -f "$search_log" ]; then
        log_info "暂无搜索记录"
        return 0
    fi
    
    echo "热门搜索查询："
    grep -o '| [^|]* | [^|]* | [^|]* |' "$search_log" | \
        awk -F'|' '{print $3}' | \
        sort | uniq -c | sort -rn | head -10
    
    echo ""
}

# 显示排序选项
show_sort_options() {
    cat << 'EOF'

📊 排序选项

**按相关性** (默认)：
  ./memory-rank.sh "query" --sort relevance
  - 关键词匹配度
  - 优先级
  - 状态

**按时间**：
  ./memory-rank.sh "query" --sort time --order desc
  - desc: 最新优先
  - asc: 最旧优先

**按使用频率**：
  ./memory-rank.sh --usage
  - 基于搜索历史

**综合评分**：
  ./memory-rank.sh "query" --sort all
  - 相关性 + 时间 + 优先级 + 状态

EOF
}

# 显示下一步指引
show_next_steps() {
    echo ""
    echo "📋 下一步操作"
    echo "============="
    echo ""
    echo "1. 使用不同排序方式查看记忆"
    echo "2. 根据排序结果优先查看高评分记忆"
    echo ""
    echo "使用示例："
    echo "  # 按相关性排序"
    echo "  $0 \"Skill 安装\" --sort relevance"
    echo ""
    echo "  # 按时间排序"
    echo "  $0 --sort time --order desc"
    echo ""
    echo "  # 按使用频率"
    echo "  $0 --usage"
    echo ""
}

# 主函数
main() {
    echo ""
    echo "📊 记忆排序脚本 (Memory Ranking)"
    echo "================================"
    echo ""
    
    local sort_by="relevance"
    local order="desc"
    local query=""
    local top_n=10
    
    # 解析参数
    while [ $# -gt 0 ]; do
        case "$1" in
            --sort)
                sort_by="$2"
                shift 2
                ;;
            --order)
                order="$2"
                shift 2
                ;;
            --top)
                top_n="$2"
                shift 2
                ;;
            --usage)
                sort_by="usage"
                shift
                ;;
            --help|-h)
                show_sort_options
                exit 0
                ;;
            *)
                if [ -z "$query" ]; then
                    query="$1"
                fi
                shift
                ;;
        esac
    done
    
    # 执行排序
    case "$sort_by" in
        relevance)
            if [ -n "$query" ]; then
                rank_memories "$query" "relevance" "$top_n"
            else
                log_info "请提供查询关键词"
            fi
            ;;
        time)
            sort_by_time "$order"
            ;;
        usage)
            sort_by_usage
            ;;
        all)
            if [ -n "$query" ]; then
                rank_memories "$query" "all" "$top_n"
            else
                log_info "请提供查询关键词"
            fi
            ;;
        *)
            log_error "未知排序方式：$sort_by"
            show_sort_options
            exit 1
            ;;
    esac
    
    show_next_steps
    
    log_success "记忆排序完成！"
}

# 执行主函数
main "$@"
