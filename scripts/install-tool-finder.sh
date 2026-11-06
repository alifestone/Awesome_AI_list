#!/usr/bin/env bash
# 把 tool-finder agent 與 /find-tool 指令安裝到 ~/.claude，讓所有專案都能使用。
# 用法：bash scripts/install-tool-finder.sh
# 更新 repo 後若 agent 有改動，重新執行一次即可。移除：bash scripts/install-tool-finder.sh --uninstall
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
AGENT_DST="$CLAUDE_DIR/agents/tool-finder.md"
SKILL_DST="$CLAUDE_DIR/skills/find-tool/SKILL.md"

if [[ "${1:-}" == "--uninstall" ]]; then
  rm -f "$AGENT_DST"
  rm -rf "$CLAUDE_DIR/skills/find-tool"
  echo "已移除 $AGENT_DST 與 $CLAUDE_DIR/skills/find-tool"
  exit 0
fi

mkdir -p "$CLAUDE_DIR/agents" "$CLAUDE_DIR/skills/find-tool"

# 在「## Repo 結構」下方插入 repo 的絕對路徑，讓 agent 在任何專案都找得到清單
awk -v repo="$REPO_DIR" '
  { print }
  /^## Repo 結構$/ {
    print ""
    print "**Repo 位置：`" repo "`**。你可能是在其他專案中被呼叫，以下所有路徑都相對於這個目錄；讀檔、搜尋時一律使用絕對路徑（例如 `" repo "/AI_tool_list_分類版.md`），回答中引用條目時也給絕對路徑。"
  }
' "$REPO_DIR/.claude/agents/tool-finder.md" > "$AGENT_DST"

cp "$REPO_DIR/.claude/skills/find-tool/SKILL.md" "$SKILL_DST"

echo "已安裝："
echo "  agent: $AGENT_DST"
echo "  skill: $SKILL_DST  （/find-tool <需求>）"
echo "清單位置：$REPO_DIR"
echo "重新啟動 Claude Code 後即可在任何專案中使用。"
