#!/bin/bash
# Moltbot 智谱 AI 快速启动脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🦞 Moltbot 网关启动脚本"
echo "========================="
echo ""

# 检查配置
if [ ! -f ~/.moltbot/moltbot.json ]; then
  echo "❌ 配置文件不存在，请先运行 ./termux-run.sh setup"
  exit 1
fi

echo "✅ 配置文件: ~/.moltbot/moltbot.json"

# 检查日志目录
mkdir -p ~/.tmp/logs

# 检查是否已有网关运行
if pgrep -f "moltbot.*gateway" > /dev/null; then
  echo "⚠️  检测到网关已在运行"
  echo ""
  ps aux | grep -E "moltbot|gateway" | grep -v grep
  echo ""
  read -p "是否停止现有网关并重新启动? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🛑 停止现有网关..."
    pkill -9 -f "moltbot.*gateway" || true
    sleep 2
  else
    echo "✅ 网关继续运行"
    exit 0
  fi
fi

# 设置环境变量
export OPENAI_API_KEY="2137e1c314c14b04b1979f01852b3d67.ULMBk9oB7ItiAe2X"
export OPENAI_BASE_URL="https://open.bigmodel.cn/api/paas/v4"
export CLAWDBOT_LOG_DIR="$HOME/.tmp/moltbot"

echo ""
echo "🚀 启动网关..."
echo "   端口: 18789"
echo "   日志: ~/.tmp/logs/gateway.log"
echo ""

# 启动网关
nohup ./termux-run.sh gateway run --port 18789 --force > ~/.tmp/logs/gateway.log 2>&1 &

# 等待启动
sleep 5

# 检查是否成功
if pgrep -f "moltbot.*gateway" > /dev/null; then
  echo "✅ 网关启动成功！"
  echo ""
  echo "📊 状态信息:"
  ps aux | grep -E "moltbot.*gateway" | grep -v grep
  echo ""
  echo "📝 查看日志:"
  echo "   tail -f ~/.tmp/logs/gateway.log"
  echo ""
  echo "🧪 测试 API:"
  echo "   ./test-zhipu-api.sh"
  echo ""
else
  echo "❌ 网关启动失败，查看日志:"
  echo ""
  tail -30 ~/.tmp/logs/gateway.log
  exit 1
fi
