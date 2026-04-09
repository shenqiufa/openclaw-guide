#!/bin/bash
# memory-capture.sh - 会话记忆捕获工具
# 用法：memory-capture "今天修复了飞书图片问题"

set -e

WORKSPACE="$HOME/.openclaw/workspace"
LEARNINGS="$WORKSPACE/.learnings"
MEMORY_DIR="$WORKSPACE/memory"
TODAY=$(date +%Y-%m-%d)
TIMESTAMP=$(date -Iseconds)

# 检查参数
if [ -z "$1" ]; then
  echo "用法：memory-capture \"记忆内容\" [优先级:low|medium|high|critical]"
  echo ""
  echo "示例:"
  echo "  memory-capture \"修复了飞书图片问题\" high"
  echo "  memory-capture \"用户偏好使用 searxng 搜索\" low"
  exit 1
fi

CONTENT="$1"
PRIORITY="${2:-medium}"

# 追加到当日记忆
cat >> "$MEMORY_DIR/$TODAY.md" << EOF

## $(date +%H:%M) 记忆捕获

**优先级**: $PRIORITY

$CONTENT

---
EOF

# 如果是 high 或 critical，同时记录到 LEARNINGS
if [ "$PRIORITY" = "high" ] || [ "$PRIORITY" = "critical" ]; then
  cat >> "$LEARNINGS/LEARNINGS.md" << EOF

## [MEM-$TODAY-$(date +%H%M)] 用户记忆

**Logged**: $TIMESTAMP
**Priority**: $PRIORITY
**Status**: captured
**Area**: memory

### Content
$CONTENT

### Metadata
- Source: user-capture
- Auto-Expire: 30d

---
EOF
  echo "✅ 已记录到 LEARNINGS.md（高优先级）"
fi

echo "✅ 已记录到 memory/$TODAY.md"
echo "📍 路径：$MEMORY_DIR/$TODAY.md"
