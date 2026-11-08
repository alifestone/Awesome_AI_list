#!/usr/bin/env bash
# 把 tool-finder agent 與 /find-tool 指令以 symlink 安裝到 ~/.claude，讓所有專案都能使用。
# 用法：bash scripts/install-tool-finder.sh
# 因為是 symlink，repo 裡的 agent／skill 改動（含 git pull）會直接生效，不必重新安裝；
# 只有移動 repo 位置後需要重跑。移除：bash scripts/install-tool-finder.sh --uninstall
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
AGENT_SRC="$REPO_DIR/.claude/agents/tool-finder.md"
SKILL_SRC="$REPO_DIR/.claude/skills/find-tool/SKILL.md"
AGENT_DST="$CLAUDE_DIR/agents/tool-finder.md"
SKILL_DST="$CLAUDE_DIR/skills/find-tool/SKILL.md"
# agent 會讀這個檔取得 repo 位置（repo 內的 agent 檔不寫死絕對路徑）
PATH_FILE="$CLAUDE_DIR/awesome-ai-list.path"

if [[ "${1:-}" == "--uninstall" ]]; then
  rm -f "$AGENT_DST" "$PATH_FILE"
  rm -rf "$CLAUDE_DIR/skills/find-tool"
  echo "已移除 $AGENT_DST、$PATH_FILE 與 $CLAUDE_DIR/skills/find-tool"
  exit 0
fi

mkdir -p "$CLAUDE_DIR/agents" "$CLAUDE_DIR/skills/find-tool"

printf '%s\n' "$REPO_DIR" > "$PATH_FILE"
# 先刪掉舊版安裝留下的一般檔案，再建立 symlink
rm -f "$AGENT_DST" "$SKILL_DST"
ln -s "$AGENT_SRC" "$AGENT_DST"
ln -s "$SKILL_SRC" "$SKILL_DST"

echo "已安裝（symlink）："
echo "  agent: $AGENT_DST -> $AGENT_SRC"
echo "  skill: $SKILL_DST -> $SKILL_SRC  （/find-tool <需求>）"
echo "  repo 位置記錄於：$PATH_FILE"
if [[ -n "${CLAUDE_CONFIG_DIR:-}" ]]; then
  echo "注意：agent 會讀 ~/.claude/awesome-ai-list.path；你設定了 CLAUDE_CONFIG_DIR，在其他專案中 agent 可能找不到 repo 位置。"
fi
echo "重新啟動 Claude Code 後即可在任何專案中使用。之後 repo 的更新會直接生效；移動 repo 後請重跑此腳本。"
