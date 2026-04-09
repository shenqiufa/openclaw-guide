#!/bin/bash
# memory-consolidate.sh - 记忆巩固脚本（阶段 3）
# 功能：将短期记忆（HOT/WARM）转移到长期记忆（COLD），实现记忆巩固

set -e

WORKSPACE="$HOME/.openclaw/workspace"
LEARNINGS_DIR="$WORKSPACE/.learnings"
MEMORY_DIR="$WORKSPACE/memory"
WARM_DIR="$MEMORY_DIR/warm"
MEMORY_MD="$WORKSPACE/MEMORY.md"
ARCHIVE_DIR="$WORKSPACE/.archive"

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

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查文件是否存在
check_files() {
    log_info "检查记忆文件..."
    
    local files=(
        "$LEARNINGS_DIR/LEARNINGS.md"
        "$LEARNINGS_DIR/ERRORS.md"
        "$MEMORY_MD"
    )
    
    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            log_error "文件不存在：$file"
            return 1
        fi
    done
    
    log_success "文件检查通过"
}

# 统计各层记忆数量
count_memories() {
    echo ""
    echo "📊 记忆层统计"
    echo "=============="
    
    # HOT 层
    local hot_learnings=$(grep -c "^## \[LRN-" "$LEARNINGS_DIR/LEARNINGS.md" 2>/dev/null || echo "0")
    local hot_errors=$(grep -c "^## \[ERR-" "$LEARNINGS_DIR/ERRORS.md" 2>/dev/null || echo "0")
    echo "HOT 层 (.learnings/):"
    echo "  - LEARNINGS.md: $hot_learnings 条"
    echo "  - ERRORS.md: $hot_errors 条"
    
    # WARM 层
    if [ -d "$WARM_DIR" ]; then
        local warm_files=$(ls -1 "$WARM_DIR"/*.md 2>/dev/null | wc -l || echo "0")
        echo "WARM 层 (memory/warm/): $warm_files 个文件"
    fi
    
    # COLD 层
    if [ -f "$MEMORY_MD" ]; then
        local cold_sections=$(grep -c "^## " "$MEMORY_MD" 2>/dev/null || echo "0")
        echo "COLD 层 (MEMORY.md): $cold_sections 个章节"
    fi
    
    echo ""
}

# ⭐ v4.8.0 新增：自动归档旧记录（>7 天）
archive_old_records() {
    log_info "檢查是否需要歸檔舊記錄..."
    
    local cutoff_date=$(date -d "7 days ago" +%Y-%m-%d 2>/dev/null || date -v-7d +%Y-%m-%d)
    local archive_file="$ARCHIVE_DIR/LEARNINGS-$(date +%Y%m).md"
    
    # 確保歸檔目錄存在
    mkdir -p "$ARCHIVE_DIR"
    
    # 檢查 LEARNINGS.md 是否超限（200 行或 25KB）
    local lines=$(wc -l < "$LEARNINGS_DIR/LEARNINGS.md")
    local size=$(du -k < "$LEARNINGS_DIR/LEARNINGS.md" | cut -f1)
    
    if [ "$lines" -gt 200 ] || [ "$size" -gt 25 ]; then
        log_warning "LEARNINGS.md 超限（$lines 行，${size}KB），開始歸檔..."
        
        # 歸檔舊記錄（>7 天）
        local archived=0
        while IFS= read -r line; do
            if [[ "$line" =~ ^##\ \[LRN-([0-9]+)-([0-9]+)\] ]]; then
                local date_part="${BASH_REMATCH[1]}"
                if [[ "$date_part" < "${cutoff_date//-/}" ]]; then
                    # 歸檔這條記錄
                    echo "$line" >> "$archive_file"
                    archived=$((archived + 1))
                fi
            fi
        done < "$LEARNINGS_DIR/LEARNINGS.md"
        
        if [ $archived -gt 0 ]; then
            log_success "已歸檔 $archived 條舊記錄到 $archive_file"
        else
            log_info "沒有需要歸檔的舊記錄"
        fi
    else
        log_info "LEARNINGS.md 大小正常（$lines 行，${size}KB），無需歸檔"
    fi
}

# 识别需要巩固的记忆（resolves 状态且>7 天）
identify_consolidation_candidates() {
    log_info "识别需要巩固的记忆..."
    
    local candidates=()
    local cutoff_date=$(date -d "7 days ago" +%Y-%m-%d 2>/dev/null || date -v-7d +%Y-%m-%d)
    
    # 查找 resolved 状态的学习记录
    while IFS= read -r line; do
        if [[ "$line" =~ ^##\ \[LRN-([0-9]+)-([0-9]+)\] ]]; then
            local id="${BASH_REMATCH[0]}"
            candidates+=("$id")
        fi
    done < <(grep -A 5 "Status: resolved" "$LEARNINGS_DIR/LEARNINGS.md" 2>/dev/null)
    
    if [ ${#candidates[@]} -eq 0 ]; then
        log_info "没有需要巩固的记忆"
    else
        log_info "找到 ${#candidates[@]} 个候选记忆："
        for candidate in "${candidates[@]}"; do
            echo "  - $candidate"
        done
    fi
    
    echo ""
}

# 生成巩固建议报告
generate_consolidation_report() {
    local report_file="$MEMORY_DIR/consolidation-$(date +%Y%m%d).md"
    
    log_info "生成记忆巩固报告..."
    
    cat > "$report_file" << EOF
# 记忆巩固报告

**生成时间**: $(date '+%Y-%m-%d %H:%M')
**目的**: 识别需要从 HOT/WARM 层转移到 COLD 层（MEMORY.md）的重要记忆

## 📊 当前状态

EOF
    
    count_memories >> "$report_file"
    
    cat >> "$report_file" << 'EOF'

## 🎯 巩固建议

### 高优先级（建议转移到 MEMORY.md）

以下记忆对长期行为有重要影响：

1. **系统配置类** - 如四层记忆架构、Skill 安装规范
2. **用户偏好类** - 如搜索工具偏好、输出格式偏好
3. **核心方法论** - 如通用问题解决方法论

### 中优先级（保留在 HOT 层，定期回顾）

1. **项目相关** - 当前活跃项目的经验
2. **工具使用** - 新工具的使用技巧

### 低优先级（可归档）

1. **临时问题** - 已解决且不太可能重复
2. **过时信息** - 工具/ API 已更新

## 📋 具体建议

**待审查记录：**

EOF
    
    # 提取最近的 resolved 记录
    grep -B 5 "Status: resolved" "$LEARNINGS_DIR/LEARNINGS.md" 2>/dev/null | head -20 >> "$report_file" || echo "无记录" >> "$report_file"
    
    cat >> "$report_file" << 'EOF'

## ✅ 操作指引

### 转移到 MEMORY.md

1. 打开 MEMORY.md
2. 在合适的章节添加内容
3. 在原 LEARNINGS.md 记录中添加 `Promoted-To: MEMORY.md` 标记

### 保留在 HOT 层

1. 保持现状
2. 设置定期回顾（建议每周）

### 归档

1. 移动到 `.archive/YYYY-MM.md`
2. 在原位置保留索引引用

---
*此报告由 memory-consolidate.sh 自动生成*
EOF
    
    log_success "巩固报告已生成：$report_file"
}

# 识别高频模式（阶段 6 新增）⭐
identify_patterns() {
    log_info "识别高频问题模式..."
    
    # 统计 LEARNINGS.md 中的问题类型（从摘要中提取关键词）
    local patterns=$(grep "### Summary" -A 1 "$LEARNINGS_DIR/LEARNINGS.md" 2>/dev/null | \
                     grep -v "### Summary" | \
                     grep -v "^--$" | \
                     sort | uniq -c | sort -rn)
    
    # 找出出现 2 次以上的问题类型
    local frequent_patterns=$(echo "$patterns" | awk '$1 >= 2 {print $0}')
    
    if [ -n "$frequent_patterns" ]; then
        log_warning "发现高频问题模式："
        echo "$frequent_patterns"
        
        # 生成模式库更新建议
        generate_pattern_suggestions "$frequent_patterns"
    else
        log_info "未发现高频模式（阈值：2 次以上）"
    fi
}

# 生成模式建议（阶段 6 新增）⭐
generate_pattern_suggestions() {
    local patterns="$1"
    local suggestion_file="$LEARNINGS_DIR/pattern-suggestions-$(date +%Y%m%d).md"
    
    cat > "$suggestion_file" << EOF
# 模式库更新建议

**生成时间**: $(date '+%Y-%m-%d %H:%M')
**审查状态**: ⏳ 待审查

---

## 📊 高频问题模式

统计结果（出现 2 次以上）：

$patterns

---

## ✅ 建议操作

### 1. 审查上述模式
- 是否足够通用？
- 是否有 2 个以上应用场景？
- 是否能抽象成通用方案？

### 2. 将高价值模式添加到 pattern-library.md
- 分配模式 ID（AUTH-002/AUTO-002/COMM-002/...）
- 填写完整模板
- 关联相关学习记录

### 3. 完善通用方案
- 步骤是否清晰？
- 是否可执行？
- 是否有示例？

### 4. 补充应用场景
- 至少 2 个场景
- 每个场景说明如何应用

---

## 📋 审查清单

- [ ] 模式是否足够通用？
- [ ] 是否有 2 个以上应用场景？
- [ ] 通用方案是否清晰？
- [ ] 预防措施是否有效？
- [ ] 已关联相关学习记录？

---

*此建议由 memory-consolidate.sh 自动生成*
EOF
    
    log_success "模式建议已生成：$suggestion_file"
}

# 显示下一步指引
show_next_steps() {
    echo ""
    echo "📋 下一步操作"
    echo "============="
    echo ""
    echo "1. 打开巩固报告，审查建议"
    echo "2. 手动将重要记忆转移到 MEMORY.md"
    echo "3. 标记已处理的记录"
    echo "4. ⭐ 新增：审查模式建议（pattern-suggestions-YYYYMMDD.md）"
    echo "5. ⭐ 新增：将高价值模式添加到 pattern-library.md"
    echo ""
    echo "转移示例："
    echo "  # 1. 在 MEMORY.md 中添加"
    echo "  ## 技能安装规范（2026-03-15 转移）"
    echo "  - 安装前检查系统内置技能"
    echo "  - 检查 ClawHub"
    echo "  - 检查已安装技能"
    echo ""
    echo "  # 2. 在 LEARNINGS.md 原记录中添加"
    echo "  **Promoted-To**: MEMORY.md"
    echo "  **Promoted-At**: 2026-03-23"
    echo ""
    echo "  # ⭐ 3. 在 pattern-library.md 中添加新模式"
    echo "  ### AUTH-002: 模式名称"
    echo "  **特征**: ..."
    echo "  **解决方案**: ..."
    echo ""
}

# 主函数
main() {
    echo ""
    echo "🧠 记忆巩固脚本 (Memory Consolidation)"
    echo "======================================="
    echo ""
    
    check_files || exit 1
    
    count_memories
    
    identify_consolidation_candidates
    
    generate_consolidation_report
    
    # 阶段 6 新增：识别高频模式
    identify_patterns
    
    show_next_steps
    
    log_success "记忆巩固检查完成！"
}

# ⭐ v4.8.1 新增：AI 自動處理巩固建議（完整實現）
auto_process_consolidate() {
    log_info "AI 自動處理巩固建議..."
    
    local today=$(date +%Y%m%d)
    local report_file="$MEMORY_DIR/consolidation-$today.md"
    local processed_flag="$MEMORY_DIR/.consolidation-$today.processed"
    
    if [ -f "$report_file" ]; then
        if [ -f "$processed_flag" ]; then
            log_info "巩固報告已處理過，跳過"
            return 0
        fi
        
        log_info "找到巩固報告：$report_file"
        
        # 1. 自動評估記憶價值（AI 通過會話處理）
        local trigger_file="$MEMORY_DIR/.consolidate-trigger-$today.md"
        cat > "$trigger_file" << EOF
# 🤖 AI 自動處理：記憶巩固

**觸發時間**: $(date '+%Y-%m-%d %H:%M:%S')
**來源文件**: $report_file

## 待評估記憶

EOF
        # 提取待審查記錄
        grep -E "^\*\*待審查記錄：\*\*" -A 20 "$report_file" >> "$trigger_file" 2>/dev/null || echo "無待審查記錄" >> "$trigger_file"
        
        cat >> "$trigger_file" << 'EOF'

## 處理要求

1. 評估每條記憶的長期價值
2. 高價值記憶 → 轉移到 MEMORY.md
3. 中價值記憶 → 保留在 HOT 層，設定回顧
4. 低價值記憶 → 歸檔
5. 推送摘要到飛書

## 評估標準

**高價值**（轉移到 COLD 層）：
- 系統配置類（如四層記憶架構）
- 用戶偏好類（如搜索工具偏好）
- 核心方法論（如通用問題解決）

**中價值**（保留在 HOT 層）：
- 項目相關（當前活躍項目）
- 工具使用（新工具技巧）

**低價值**（可歸檔）：
- 臨時問題（已解決且不重複）
- 過時信息（工具/API 已更新）

---
*此文件由 memory-consolidate.sh 自動生成，觸發 AI 處理*
EOF
        
        # 2. 推送摘要到飛書
        send_feishu_summary "consolidate" "$report_file" "$trigger_file"
        
        # 3. 記錄處理效果
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 巩固報告已生成，觸發 AI 處理：$report_file" >> "$WORKSPACE/.logs/memory-consolidate-auto.log"
        
        # 4. 標記為已處理
        touch "$processed_flag"
        
        log_success "巩固報告自動處理完成，已觸發 AI 會話"
    else
        log_info "今日巩固報告尚未生成，跳過自動處理"
    fi
}

# ⭐ v4.8.1 新增：推送摘要到飛書
send_feishu_summary() {
    local type="$1"
    local report_file="$2"
    local trigger_file="$3"
    
    local message="🦞 記憶系統自動處理通知\n\n"
    message+="類型：記憶巩固\n"
    message+="報告：$(basename "$report_file")\n"
    message+="狀態：已觸發 AI 自動處理\n\n"
    message+="AI 將自動：\n"
    message+="1. 評估記憶長期價值\n"
    message+="2. 轉移/歸檔記憶\n"
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

# 执行主函数
main "$@"

# ⭐ v4.7.1 新增：執行後自動處理
auto_process_consolidate
