# agency-agents

- **分類**：Agent 框架與編排 / Coding agent 外掛與 skill 組
- **連結**：https://github.com/msitarzewski/agency-agents

## 原清單說明

各種專業角色的 agent 人設集合。

> 查證結果：與 README 相符。專案名稱為「The Agency」，是一套以 Markdown 撰寫的專業角色 agent 人設（personality + 工作流程 + 交付物）集合，原生支援 Claude Code，並附轉換／安裝腳本供其他 coding agent 工具使用。

## 概述

The Agency（repo：`msitarzewski/agency-agents`）源自一則 Reddit 討論串，經數月迭代成為「AI agent 人設」大型合集。每個 agent 是一份 `.md` 檔，定義該角色的身分與個性、核心任務與工作流程、技術交付物（含程式碼範例）、成功指標與溝通風格。README 宣稱目前有 **230+ 個專業 agent**、超過 10,000 行內容，橫跨工程、設計、行銷、銷售、產品、專案管理、測試、資安、客服、空間運算、財務、遊戲開發、學術、GIS、醫療、研究等部門（Division）。

GitHub 數據（2026-10-13 透過 GitHub API 查得）：約 15.9 萬顆星，主要語言標示為 Shell（安裝／轉換腳本），建立於 2025-10-13；repo 本身沒有 GitHub Release。

## 核心功能／特色

- **依部門分類的角色庫**：例如 Engineering Division 的 Frontend Developer、Backend Architect、Mobile App Builder；Testing Division 的 Evidence Collector；Marketing Division 的 Reddit Community Builder；Design Division 的 Whimsy Injector 等。Game Development 部門另細分跨引擎、Unity、Unreal、Godot、Blender、Roblox Studio。
- **設計理念**：強烈個性、明確交付物、可量測的成功指標、經驗證的工作流程、「Learning Memory」（模式辨識與持續改進）。
- **多工具整合**：原生支援 Claude Code（`~/.claude/agents/`）與 GitHub Copilot；透過 `scripts/convert.sh` 轉成 Antigravity、Gemini CLI、OpenCode、Cursor（`.mdc`）、Aider（`CONVENTIONS.md`）、Windsurf（`.windsurfrules`）、OpenClaw、Qwen Code、Kimi Code、Codex（TOML）、Osaurus、Hermes、DeepSeek Harness 等格式。
- **桌面 App**：另有 Agency Agents 原生 App（macOS / Linux / Windows），可瀏覽整個角色庫並一鍵安裝到 Claude Code、Cursor、Codex、Gemini CLI、OpenCode、Qwen、Osaurus，且會自動更新。
- **Runbook 名單**：`strategy/runbooks.json` 定義情境用的團隊組合（如 `startup-mvp`），可依名單只安裝需要的 agent。
- **社群翻譯**：有簡中、日文、韓文、巴西葡文、俄文、印尼文、阿拉伯文、越南文等社群維護版本（各自獨立維護）。

## 技術架構或運作原理

本身不是執行框架，而是「提示詞／子代理定義檔」集合。每個 agent 是一份帶有角色設定的 Markdown 檔；在 Claude Code 中放進 `~/.claude/agents/` 即成為可呼叫的 subagent。對其他工具，轉換腳本會把同一份內容改寫成對應工具的規則／技能／agent 格式（如 Cursor 的 `.mdc`、Codex 的 TOML、Antigravity 的 `SKILL.md`）。

## 安裝與使用方式

```bash
# 方式一：桌面 App（macOS 可用 Homebrew）
brew install --cask msitarzewski/agency-agents/agency-agents

# 方式二：Claude Code（於 clone 下來的 repo 根目錄執行）
./scripts/install.sh --tool claude-code
# 或只複製單一部門
cp engineering/*.md ~/.claude/agents/

# 方式三：其他工具
./scripts/convert.sh                 # 產生各工具整合檔
./scripts/install.sh                 # 互動式安裝（自動偵測已安裝工具）
./scripts/install.sh --tool cursor --agent frontend-developer,ui-designer
./scripts/install.sh --tool claude-code --division engineering,security
./scripts/install.sh --list teams    # 列出所有團隊與 agent 數量
```

在 Claude Code 中可用自然語言啟用，例如「activate Frontend Developer mode and help me build a React component」。也可單純當參考資料，複製改寫需要的人設。

## 適用情境

- 想快速替 Claude Code／Cursor／Codex 等 coding agent 加上大量專業子代理。
- 以多角色分工模擬「小型代理商團隊」完成 MVP、行銷活動、企業功能開發等（README 提供 6 個情境範例，如 Startup MVP、Paid Media Account Takeover、Smart Campus Digital Twin）。
- 作為撰寫自訂 agent 人設的範本與參考。

## 授權與成本

- 授權：**MIT**（README：可自由商用或個人使用，署名感謝但非必要）。
- 成本：人設檔本身免費；實際執行成本取決於所用 coding agent 與模型供應商的計費。

## 限制與注意事項

- 本質是提示詞集合，品質依角色而異；README 中「battle-tested」「production-ready」等屬專案自述，未見獨立評測。
- 人設檔中部分引述（如「reduces task completion anxiety by 40%」）是角色台詞示範，不是實測數據。
- README 註明 OpenCode 執行環境目前只會註冊約 119 個 agent、其餘會被靜默丟棄（上游 bug），建議用 `--division` 只裝部分。
- 一次安裝全部 230+ 個 agent 可能增加工具載入的上下文負擔，建議依需求挑選。

## 相關工具

- Claude Code subagents、Cursor rules、Codex custom agents（本專案的安裝目標）
- [Claude Octopus](./Claude-Octopus.md)（同樣提供多種專家 persona 的 Claude Code 外掛）
- [CrewAI](./CrewAI.md)（以程式碼定義角色化 agent 的框架）
- obra/superpowers（Claude Code 技能／方法論外掛，資料來源：Claude Octopus README 的比較表）

## 資料來源

- https://github.com/msitarzewski/agency-agents （README 與 GitHub API repo 資訊）
- https://api.github.com/repos/msitarzewski/agency-agents
