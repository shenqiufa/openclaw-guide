#!/bin/bash
# memory-retell.sh - 记忆复述脚本（阶段 3）
# 功能：定期回顾重要记忆，强化长期记忆，发现新连接

set -e

WORKSPACE="$HOME/.openclaw/workspace"
LEARNINGS_DIR="$WORKSPACE/.learnings"
MEMORY_DIR="$WORKSPACE/memory"
WARM_DIR="$MEMORY_DIR/warm"
MEMORY_MD="$WORKSPACE/MEMORY.md"
RETLL_DIR="$MEMORY_DIR/retells"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
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

# 确保目录存在
mkdir -p "$RETLL_DIR"

# 复述周期配置
DAILY_REVIEW_COUNT=3      # 每日回顾数量
WEEKLY_CONNECTIONS=5      # 每周发现新连接数
MONTHLY_CLUSTER_COUNT=10  # 每月聚类数量

# 公开分享检查函数 ⭐ v4.4 新增
check_public_potential() {
    log_info "检查可分享的学习记录..."
    
    local weekly_summary="$MEMORY_DIR/weekly-public-summary.md"
    local today=$(date +%Y-%m-%d)
    local yesterday=$(date -d "yesterday" +%Y-%m-%d)
    
    # 检查昨日学习记录
    local new_learnings=$(grep -c "Logged.*$yesterday\|Logged.*$today" "$LEARNINGS_DIR/LEARNINGS.md" 2>/dev/null || echo "0")
    
    if [ "$new_learnings" -gt 0 ]; then
        log_info "检测到 $new_learnings 条新的学习记录"
        
        # 添加到周汇总
        cat >> "$weekly_summary" << EOF

## 新增学习记录 ($today)

- 新增学习记录：$new_learnings 条
- 待审查：请检查 LEARNINGS.md 中的新条目
- 标记可分享：在 LEARNINGS.md 中添加 Public Sharing 字段

EOF
        
        log_success "已添加到周汇总：$weekly_summary"
    else
        log_info "昨日无新增学习记录"
    fi
}

# ⭐ v4.8.0 新增：从对话中学习用户偏好
learn_user_preferences() {
    log_info "檢查用戶偏好學習..."
    
    local user_file="$WORKSPACE/USER.md"
    local learnings_file="$LEARNINGS_DIR/LEARNINGS.md"
    
    # 檢測偏好觸發詞
    local preferences=$(grep -E "我喜歡 | 我習慣 | 我偏好 | 記住我" "$learnings_file" 2>/dev/null | head -5)
    
    if [ -n "$preferences" ]; then
        log_info "發現用戶偏好，正在學習..."
        
        # ⭐ v4.8.1 修復：檢查是否已存在相同偏好（去重）
        local existing_count=$(grep -c "$(echo "$preferences" | head -1)" "$user_file" 2>/dev/null || echo "0")
        
        if [ "$existing_count" -gt 0 ]; then
            log_info "該偏好已存在於 USER.md，跳過添加"
        else
            # 添加到 USER.md
            cat >> "$user_file" << INNEREOF

## 自動學習偏好（$(date +%Y-%m-%d)）

**記錄**：
$preferences

INNEREOF
            
            log_success "已學習 $(echo "$preferences" | wc -l) 條用戶偏好"
        fi
    else
        log_info "未發現新的用戶偏好"
    fi
}

# 每日回顾（随机选择 N 条记忆）
daily_review() {
    log_info "每日回顾：随机选择 $DAILY_REVIEW_COUNT 条记忆..."
    
    local review_file="$RETLL_DIR/daily-$(date +%Y-%m-%d).md"
    
    cat > "$review_file" << EOF
# 每日记忆回顾

**日期**: $(date +%Y-%m-%d)
**目的**: 回顾旧记忆，强化长期记忆

## 📚 今日回顾 ($DAILY_REVIEW_COUNT 条)

EOF
    
    # 从多个来源收集记忆
    local temp_file=$(mktemp)
    
    # 1. 从 LEARNINGS.md 收集
    grep "^## \[LRN-" "$LEARNINGS_DIR/LEARNINGS.md" 2>/dev/null >> "$temp_file" || true
    
    # 2. 从最近 7 天的每日记忆文件收集
    for i in 1 2 3 4 5 6 7; do
        local check_date=$(date -d "$i days ago" +%Y-%m-%d)
        local daily_file="$MEMORY_DIR/$check_date.md"
        if [ -f "$daily_file" ]; then
            # 提取每日记忆中的重要事件标题
            grep -E "^## |^### " "$daily_file" 2>/dev/null | sed 's/^## /## [LRN-'"$check_date"'-DAILY] /' | sed 's/^### /## [LRN-'"$check_date"'-DAILY] /' >> "$temp_file" || true
        fi
    done
    
    # 随机选择记忆
    local count=0
    while IFS= read -r line && [ $count -lt $DAILY_REVIEW_COUNT ]; do
        # 提取 ID 和标题
        local lrn_id=$(echo "$line" | grep -oE '\[LRN-[^]]+\]' | tr -d '[]')
        local lrn_title=$(echo "$line" | sed 's/.*\] //')
        
        if [ -n "$lrn_id" ] && [ -n "$lrn_title" ]; then
            echo "### $lrn_id - $lrn_title" >> "$review_file"
            echo "" >> "$review_file"
            echo "**回顾问题：**" >> "$review_file"
            echo "- [ ] 这条记忆还适用吗？" >> "$review_file"
            echo "- [ ] 需要更新或补充吗？" >> "$review_file"
            echo "- [ ] 与其他记忆有联系吗？" >> "$review_file"
            echo "" >> "$review_file"
            count=$((count + 1))
        fi
    done < <(tac "$temp_file" 2>/dev/null | sort -u | tail -20 | shuf)
    
    rm -f "$temp_file"
    
    cat >> "$review_file" << 'EOF'

## 💡 回顾心得

**新的理解或发现：**


**需要更新的内容：**


**发现的联系：**


---
*此回顾由 memory-retell.sh 自动生成*
EOF
    
    log_success "每日回顾已生成：$review_file"
    
    # 检查可分享的学习记录
    check_public_potential
}

# 每周连接发现
weekly_connections() {
    log_info "每周连接：发现记忆之间的新联系..."
    
    local connection_file="$RETLL_DIR/weekly-$(date +%Y-%W).md"
    
    cat > "$connection_file" << EOF
# 每周记忆连接发现

**周次**: $(date +%Y-%W)
**日期范围**: $(date -d "monday" +%Y-%m-%d 2>/dev/null || date -v-mon +%Y-%m-%d) - $(date +%Y-%m-%d)
**目的**: 发现记忆之间的新联系和模式

## 🔗 潜在连接

### 主题聚类

**待分析的记忆组：**

1. **技能安装相关**
   - LRN-20260315-004: Skill 安装/创建规范
   - (其他相关记忆...)

2. **记忆系统相关**
   - LRN-20260315-002: 四层记忆架构实施
   - LRN-20260315-003: 四层记忆架构实施完成
   - (其他相关记忆...)

3. **工具使用相关**
   - (相关记忆...)

## 🎯 连接建议

**可能的关系类型：**
- DERIVED_FROM: 派生自
- PREFERS_OVER: 优先于
- EVOLVED_INTO: 演化为
- RELATED_TO: 相关于
- DEPENDS_ON: 依赖于

**待确认的连接：**


## 📊 模式发现

**重复出现的主题：**


**需要进一步探索的方向：**


---
*此报告由 memory-retell.sh 自动生成*
EOF
    
    log_success "每周连接报告已生成：$connection_file"
}

# 每月聚类分析
monthly_clustering() {
    log_info "每月聚类：分析记忆模式和趋势..."
    
    local cluster_file="$RETLL_DIR/monthly-$(date +%Y-%m).md"
    
    cat > "$cluster_file" << EOF
# 每月记忆聚类分析

**月份**: $(date +%Y-%m)
**目的**: 识别记忆模式和趋势，优化记忆组织

## 📊 月度统计

**新增记忆数量：**
- LEARNINGS.md: 待统计
- ERRORS.md: 待统计
- FEATURE_REQUESTS.md: 待统计

**记忆状态分布：**
- resolved: 待统计
- in_progress: 待统计
- pending: 待统计

## 🎯 主要主题

**本月热门主题：**

1. 
2. 
3. 

## 📈 趋势分析

**记忆增长趋势：**


**需要关注的领域：**


## 🔄 优化建议

**记忆组织优化：**


**检索效率优化：**


**归档建议：**


---
*此报告由 memory-retell.sh 自动生成*
EOF
    
    log_success "每月聚类报告已生成：$cluster_file"
}

# 设置 cron 任务
setup_cron_jobs() {
    log_info "设置定期复述任务..."
    
    echo ""
    echo "📅 建议的 cron 设置："
    echo ""
    echo "# 每日回顾（每天早上 8:00）"
    echo "0 8 * * * $WORKSPACE/.scripts/memory-retell.sh daily"
    echo ""
    echo "# 每周连接（每周一早上 9:00）"
    echo "0 9 * * 1 $WORKSPACE/.scripts/memory-retell.sh weekly"
    echo ""
    echo "# 每月聚类（每月 1 号早上 10:00）"
    echo "0 10 1 * * $WORKSPACE/.scripts/memory-retell.sh monthly"
    echo ""
}

# 显示下一步指引
show_next_steps() {
    echo ""
    echo "📋 下一步操作"
    echo "============="
    echo ""
    echo "1. 查看生成的复述报告"
    echo "2. 回答回顾问题，记录心得"
    echo "3. 确认或添加记忆连接"
    echo "4. 设置定期 cron 任务"
    echo ""
}

# 主函数
main() {
    echo ""
    echo "📖 记忆复述脚本 (Memory Retell)"
    echo "==============================="
    echo ""
    
    local mode="${1:-all}"
    
    case "$mode" in
        daily)
            daily_review
            learn_user_preferences
            ;;
        weekly)
            weekly_connections
            ;;
        monthly)
            monthly_clustering
            ;;
        all)
            daily_review
            learn_user_preferences
            echo ""
            weekly_connections
            echo ""
            monthly_clustering
            ;;
        cron)
            setup_cron_jobs
            ;;
        *)
            log_error "未知模式：$mode"
            echo "可用模式：daily, weekly, monthly, all, cron"
            exit 1
            ;;
    esac
    
    show_next_steps
    
    log_success "记忆复述完成！"
}

# ⭐ v4.8.1 新增：AI 自動處理回顧報告（完整實現）
auto_process_retell() {
    log_info "AI 自動處理回顧報告..."
    
    local today=$(date +%Y-%m-%d)
    local retell_file="$RETLL_DIR/daily-$today.md"
    local processed_flag="$RETLL_DIR/.daily-$today.processed"
    
    if [ -f "$retell_file" ]; then
        if [ -f "$processed_flag" ]; then
            log_info "回顧報告已處理過，跳過"
            return 0
        fi
        
        log_info "找到回顧報告：$retell_file"
        
        # 1. 自動回答回顧問題（AI 通過會話處理）
        # 添加處理標記文件，觸發 AI 會話
        local trigger_file="$RETLL_DIR/.retell-trigger-$today.md"
        cat > "$trigger_file" << EOF
# 🤖 AI 自動處理：記憶回顧

**觸發時間**: $(date '+%Y-%m-%d %H:%M:%S')
**來源文件**: $retell_file

## 待處理問題

EOF
        # 提取回顧問題
        grep -E "^- \[ \]" "$retell_file" >> "$trigger_file" 2>/dev/null || echo "無待處理問題" >> "$trigger_file"
        
        cat >> "$trigger_file" << 'EOF'

## 處理要求

1. 回答每個回顧問題
2. 更新 MEMORY.md（如有新發現）
3. 推送摘要到飛書

---
*此文件由 memory-retell.sh 自動生成，觸發 AI 處理*
EOF
        
        # 2. 推送摘要到飛書
        send_feishu_summary "retell" "$retell_file" "$trigger_file"
        
        # 3. 記錄處理效果
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 回顧報告已生成，觸發 AI 處理：$retell_file" >> "$WORKSPACE/.logs/memory-retell-auto.log"
        
        # 4. 標記為已處理
        touch "$processed_flag"
        
        log_success "回顧報告自動處理完成，已觸發 AI 會話"
    else
        log_info "今日回顧報告尚未生成，跳過自動處理"
    fi
}

# ⭐ v4.8.1 新增：推送摘要到飛書
send_feishu_summary() {
    local type="$1"
    local report_file="$2"
    local trigger_file="$3"
    
    local message="🦞 記憶系統自動處理通知\n\n"
    message+="類型：記憶復述\n"
    message+="報告：$(basename "$report_file")\n"
    message+="狀態：已觸發 AI 自動處理\n\n"
    message+="AI 將自動：\n"
    message+="1. 回答回顧問題\n"
    message+="2. 更新長期記憶\n"
    message+="3. 記錄處理效果\n\n"
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

# ⭐ v4.7.1 新增：執行後自動處理
auto_process_retell
