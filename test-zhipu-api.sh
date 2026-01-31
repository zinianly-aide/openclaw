#!/bin/bash
# 智谱 AI API 测试脚本

set -e

API_KEY="2137e1c314c14b04b1979f01852b3d67.ULMBk9oB7ItiAe2X"
BASE_URL="https://open.bigmodel.cn/api/paas/v4"
MODEL="${1:-glm-4-flash}"
MESSAGE="${2:-你好，请用一句话介绍你自己}"

echo "🧪 智谱 AI API 测试"
echo "=================="
echo "模型: $MODEL"
echo "消息: $MESSAGE"
echo ""

echo "📡 发送请求..."
echo ""

RESPONSE=$(curl -s -X POST "$BASE_URL/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "{
    \"model\": \"$MODEL\",
    \"messages\": [{\"role\": \"user\", \"content\": \"$MESSAGE\"}]
  }")

echo "📥 响应:"
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""

# 提取内容
if command -v jq &> /dev/null; then
  CONTENT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content' 2>/dev/null)
  if [ "$CONTENT" != "null" ] && [ -n "$CONTENT" ]; then
    echo "💬 回复内容:"
    echo "$CONTENT"
    echo ""
  fi

  # 显示 token 使用
  TOKENS=$(echo "$RESPONSE" | jq -r '.usage' 2>/dev/null)
  if [ "$TOKENS" != "null" ]; then
    echo "📊 Token 使用:"
    echo "$TOKENS"
  fi
fi

echo "✅ 测试完成"
