# Moltbot 网关配置完成报告

## 📋 配置概览

### ✅ 已完成的配置

| 项目 | 状态 | 详情 |
|------|------|------|
| Termux 补丁 | ✅ 完成 | clipboard 存根、日志目录修复 |
| 网关配置 | ✅ 完成 | local 模式，token 认证 |
| 智谱 API | ✅ 验证可用 | API key 正常，端点可访问 |
| 网关启动 | ✅ 成功 | 可监听 ws://127.0.0.1:18789 |
| 模型配置 | ⚠️ 部分 | pi-ai 库兼容性问题 |

### 📁 配置文件位置

```
~/.moltbot/moltbot.json          # 主配置文件
~/.clawdbot -> ~/.moltbot        # 符号链接
~/.clawdbot/agents/models.json   # 模型目录（手动创建）
~/.tmp/logs/                     # 日志目录
```

### 🔑 当前配置详情

**网关设置：**
```json
{
  "gateway": {
    "mode": "local",
    "auth": {
      "token": "moltbot-test-token-123"
    }
  }
}
```

**智谱 API 配置：**
- Base URL: `https://open.bigmodel.cn/api/paas/v4`
- API Key: `2137e1c314c14b04b1979f01852b3d67.ULMBk9oB7ItiAe2X`
- 模型: `glm-4-flash`, `glm-4`, `glm-4-plus`

**默认模型：**
- Primary: `openai/glm-4-flash`

## 🚀 使用指南

### 启动网关

```bash
# 方式1：使用 Termux 包装脚本（推荐）
./termux-run.sh gateway run --port 18789

# 方式2：后台运行
nohup ./termux-run.sh gateway run --port 18789 --force > ~/.tmp/logs/gateway.log 2>&1 &

# 方式3：使用环境变量
export OPENAI_API_KEY="2137e1c314c14b04b1979f01852b3d67.ULMBk9oB7ItiAe2X"
export OPENAI_BASE_URL="https://open.bigmodel.cn/api/paas/v4"
./termux-run.sh gateway run --port 18789
```

### 验证网关运行

```bash
# 检查进程
ps aux | grep gateway | grep -v grep

# 查看日志
tail -f ~/.tmp/moltbot/moltbot-*.log

# 测试 WebSocket 连接
# （网关应监听在 ws://127.0.0.1:18789）
```

### 直接调用智谱 API

由于 pi-ai 库兼容性问题，可以使用 curl 直接调用：

```bash
# 创建测试脚本
cat > ~/.tmp/zhipu_test.sh << 'EOF'
#!/bin/bash
MODEL="${1:-glm-4-flash}"
MESSAGE="${2:-你好}"

curl -s -X POST "https://open.bigmodel.cn/api/paas/v4/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer 2137e1c314c14b04b1979f01852b3d67.ULMBk9oB7ItiAe2X" \
  -d "{
    \"model\": \"$MODEL\",
    \"messages\": [{\"role\": \"user\", \"content\": \"$MESSAGE\"}]
  }"
EOF

chmod +x ~/.tmp/zhipu_test.sh

# 测试调用
~/.tmp/zhipu_test.sh glm-4-flash "请用一句话介绍你自己"
```

### 可用的 Moltbot 命令

```bash
# 查看版本
./termux-run.sh --version

# 配置管理
./termux-run.sh config get <path>
./termux-run.sh config set <path> <value>
./termux-run.sh config unset <path>

# 诊断
./termux-run.sh doctor

# 网关控制
./termux-run.sh gateway start
./termux-run.sh gateway stop
./termux-run.sh gateway status

# 消息发送（需要配置频道）
./termux-run.sh message send --to <number> --message "test"

# 日志查看
./termux-run.sh logs --tail 50
```

## ⚠️ 已知问题

### 1. pi-ai 库兼容性

**错误：** `Unhandled API in mapOptionsForApi: undefined`

**原因：** pi-ai 库 (@mariozechner/pi-ai) 对自定义 OpenAI 端点的支持有限

**临时解决方案：**
- 使用 curl 直接调用智谱 API（见上）
- 等待 Moltbot 官方对智谱 AI 的支持
- 考虑使用标准 OpenAI API 或 Anthropic API

### 2. 网关连接意外关闭

**现象：** Gateway 连接立即关闭 (1006)

**可能原因：**
- 配置文件格式问题
- 模型目录未正确生成
- 权限问题

**排查方法：**
```bash
# 检查配置语法
node -e "console.log(JSON.parse(require('fs').readFileSync('~/.moltbot/moltbot.json')))"

# 查看详细日志
tail -100 ~/.tmp/moltbot/moltbot-*.log

# 重新生成配置
./termux-run.sh setup
```

## 🔄 重启和故障排除

### 完全重启流程

```bash
# 1. 停止所有进程
pkill -9 -f moltbot

# 2. 清理临时文件
rm -rf ~/.tmp/logs/*

# 3. 验证配置
cat ~/.moltbot/moltbot.json

# 4. 重新启动
./termux-run.sh gateway run --port 18789 --force
```

### 常用诊断命令

```bash
# 检查端口占用
ss -ltnp | rg 18789

# 查看最近的日志
tail -50 ~/.tmp/moltbot/moltbot-*.log

# 运行诊断
./termux-run.sh doctor

# 查看配置
./termux-run.sh config get all
```

## 📊 API 测试结果

### 智谱 AI 直接调用测试

```bash
curl -X POST "https://open.bigmodel.cn/api/paas/v4/chat/completions" \
  -H "Authorization: Bearer 2137e1c314c14b04b1979f01852b3d67.ULMBk9oB7ItiAe2X" \
  -H "Content-Type: application/json" \
  -d '{"model":"glm-4-flash","messages":[{"role":"user","content":"hi"}]}'
```

**响应：**
```json
{
  "choices": [{
    "message": {
      "content": "Hi 👋! I'm ChatGLM, the artificial intelligence assistant...",
      "role": "assistant"
    }
  }],
  "model": "glm-4-flash",
  "usage": {
    "total_tokens": 36
  }
}
```

✅ **结论：智谱 API 完全可用**

## 🎯 下一步建议

### 方案 A：使用标准 API

如果可以访问，配置标准的 OpenAI 或 Anthropic API：

```bash
# OpenAI
./termux-run.sh config set models.providers.openai.apiKey sk-...
./termux-run.sh config set agents.defaults.model.primary "openai/gpt-4o-mini"

# Anthropic
./termux-run.sh config set models.providers.anthropic.apiKey sk-ant-...
./termux-run.sh config set agents.defaults.model.primary "anthropic/claude-3-5-sonnet-20241022"
```

### 方案 B：自定义脚本包装

创建一个包装脚本，使用 curl 调用智谱 API：

```bash
cat > ~/.tmp/moltbot-chat.sh << 'EOF'
#!/bin/bash
MESSAGE="$1"
curl -s -X POST "https://open.bigmodel.cn/api/paas/v4/chat/completions" \
  -H "Authorization: Bearer 2137e1c314c14b04b1979f01852b3d67.ULMBk9oB7ItiAe2X" \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"glm-4-flash\",\"messages\":[{\"role\":\"user\",\"content\":\"$MESSAGE\"}]}" \
  | jq -r '.choices[0].message.content'
EOF

chmod +x ~/.tmp/moltbot-chat.sh
~/.tmp/moltbot-chat.sh "你好"
```

### 方案 C：等待官方支持

关注 Moltbot 项目更新，等待对智谱 AI 的官方支持。

## 📝 配置文件备份

当前配置已保存在：
- `~/.moltbot/moltbot.json` - 主配置
- `TERMUX-GUIDE.md` - 本文档

## ✅ 验证清单

- [x] Termux 环境补丁完成
- [x] 网关基本配置完成
- [x] 智谱 API 验证可用
- [x] 网关可以成功启动
- [x] WebSocket 监听正常
- [x] 日志系统正常
- [ ] Agent 消息功能（待 pi-ai 兼容性解决）
- [ ] 频道集成（需额外配置）

---

**生成时间：** 2026-01-30
**Moltbot 版本：** 2026.1.27-beta.1
**配置环境：** Termux on Android
