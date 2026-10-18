# Claude Octopus

- **分類**：Agent 框架與編排 / Coding agent 外掛與 skill 組
- **連結**：https://github.com/nyldn/claude-octopus

## 原清單說明

Claude Code 外掛，讓 Codex、Gemini 等多個模型交叉審查、辯論，有共識閘門。

> 查證結果：大致相符，但「Gemini」一項需更正。目前 README 列出的外部供應商為 Codex、Antigravity CLI、Copilot、Qwen、Ollama、Perplexity、OpenRouter、OrcaRouter、OpenCode、Cursor CLI、Grok、Kimi Code 共 12 家；README 明確提到 **Gemini CLI 已被標為「retired」（退役）**，Google 方面改由 **Antigravity CLI（`agy`）** 提供觀點；Gemini 模型僅能透過 Cursor CLI 席位間接使用。「共識閘門」屬實，門檻為 **75% 一致**。

## 概述

Claude Octopus 是由 nyldn 維護的獨立開源專案（README 聲明與 Anthropic 無隸屬或背書關係），以 Claude Code 外掛形式，讓多個 AI 模型針對同一研究、設計或寫程式任務各自作答、互相審查與辯論，在出貨前揭露分歧（「Surface disagreements before you ship」）。設計原則是「Claude-native first, Octopus for escalation」：一般工作用 Claude Code 原生的 `/review`、`/security-review` 等；需要多模型意見、對抗式審查或更嚴格的多 LLM 流程時，才明確呼叫 `/octo:*`。

GitHub 數據（2026-10-13 透過 GitHub API 查得）：約 4,200 顆星，主要語言 Shell，建立於 2026-01-15，最新 Release 為 **v11.13.2**（2026-10-11）。

## 核心功能／特色

- **多模型協作**：內建 Claude Code 宿主，另可逐一加入最多 12 家外部供應商；零外部供應商也能使用（此時無多 AI 功能，但保有 persona、工作流程與技能）。
- **75% 共識閘門（consensus gate）**：多模型結果一致度不足時攔下，避免有疑慮的成果出貨。
- **Double Diamond 四階段**：Discover → Define → Develop → Deliver（改編自英國 Design Council 方法），可用 `/octo:embrace` 一次跑完，階段間有品質閘門；自主程度可選 supervised／semi-autonomous／autonomous。
- **Multi-LLM Council**（`/octo:council`）：3/5/7 個 persona 的結構化審議，具目標模式（advice、decision、plan、implement、review）、風格（balanced、adversarial、red-team…）、法定人數與關鍵否決閘門、預算預檢。
- **Provider Debate**（`/octo:debate`）：多供應商結構化辯論並產出共識。
- **Dark Factory**（`/octo:factory`）：輸入規格，自主跑完研究→定義→開發→交付流程。
- **規模**：README 自述 31 個專家 persona、54 個指令、63 個技能。
- **Reaction Engine**：監看 agent 建立的 PR，CI 失敗、被要求修改、agent 卡住等事件會自動收集日誌或升級給人處理。
- **跨 session 記憶**：可整合 claude-mem、agentmemory、deja-vu。
- **成本可視化**：`/octo:costs` 事前估算，`/octo:usage` 事後依供應商與技能拆帳；預估超過 1 美元會在派送前提示。
- **MCP Server**：提供 `octopus_discover`、`octopus_embrace`、`octopus_debate`、`octopus_council`、`octopus_review`、`octopus_security` 等 12 個 MCP 工具，供 Cursor 等 MCP 客戶端使用。

## 技術架構或運作原理

- 以 Claude Code 外掛形式安裝，掛上多個生命週期 hooks（session 開始／結束、prompt 送出、工具使用、壓縮、worktree 等，見 `hooks/hooks.json`）。
- 核心派送腳本為 `orchestrate.sh`，透過各供應商 CLI 或 API 分派任務；MCP 架構為 `MCP Client ─ MCP Server ─ orchestrate.sh ─ provider CLIs/APIs`。
- **角色路由**（v11.13.2 預設）：Claude Opus 5.5 負責架構、規劃、資安推理與最終判斷；GPT-5.6 Sol（經 Codex）為獨立實作／審查同儕；Claude Sonnet 5.5 為標準 Claude 席位；Fable 5.1、GPT-6 Astra 為需明確選用的高價席位。既有的模型釘選設定優先。
- **預設休眠**：安裝後不會自動攔截一般 prompt，所有指令與技能都需以 `/octo:*` 手動觸發；自動路由（`OCTOPUS_AUTO_ROUTER_MODE=suggest|invoke`）需自行開啟。
- 平行工作包使用獨立 git 分支／worktree。
- 資料位置：結果 `~/.claude-octopus/results/`、日誌 `~/.claude-octopus/logs/`、專案狀態 `.octo/`。

## 安裝與使用方式

```bash
# 在終端機（非 Claude Code session 內）
claude plugin marketplace add https://github.com/nyldn/plugins.git
claude plugin install octo@nyldn-plugins

# 進入 Claude Code 後
/octo:setup        # 偵測已安裝供應商並引導設定
```

常用指令：

```bash
/octo:embrace build stripe integration          # 完整四階段流程
/octo:factory "build a CLI that converts CSV to JSON"
/octo:council --goal decision "Should we keep this service monolithic?"
/octo:debate monorepo vs microservices
/octo:research --breadth=standard htmx vs react in 2026
/octo:review    /octo:tdd    /octo:security    /octo:prd    /octo:debug
/octo:auto <描述>   # 由智慧路由挑選流程
```

- 另支援安裝於 Codex CLI（`codex plugin marketplace add ...`）、Factory AI Droid、OpenCode，Cursor 則以 MCP Server 方式接入。
- 診斷：`octopus doctor`、`octopus capabilities --json`、`octopus cache-check --json`、`octopus security-audit --json`。
- 最低需求：Claude Code **v2.1.14+**。平台：Linux、macOS 原生；Windows 需在 WSL 或桌面版 SSH 環境中使用（不支援原生 Git Bash、MSYS2、Cygwin）。

## 適用情境

- 重要架構決策、技術選型需要多個模型的獨立意見與對抗式辯論。
- 程式碼審查、資安審查時希望由不同廠商模型交叉檢查盲點。
- 多供應商研究（附來源歸屬）、PRD 撰寫、從規格到程式的自主流程。
- 已訂閱 ChatGPT／Copilot／Cursor 等服務，想把既有訂閱納入審查流程的開發者。

## 授權與成本

- 授權：**MIT**（部分技能改編自 mattpocock/skills、obra/superpowers 等，皆為 MIT，詳見 `THIRD_PARTY_NOTICES.md`）。
- 外掛本身免費；費用來自各模型供應商。README 指出 Codex、Antigravity CLI、Copilot、Cursor CLI 可沿用既有訂閱／本地認證，Ollama 本地執行免費；**Qwen 免費 OAuth 方案已於 2026-04-15 結束**，需 API key 或 Coding Plan。
- README 的示意 API token 成本（以 2026-09-22 費率估算、不含工具費）：單一快速詢問約 $0.01–0.20；辯論約 $0.20–1.00；Council 約 $0.50–2.50；完整 embrace 約 $1.00–6.00+。Perplexity Sonar Pro 另有每千次請求 $6–14 的請求費。

## 限制與注意事項

- 多模型流程會把 prompt 與脈絡送到所設定的外部供應商，資料保留依各供應商帳戶政策；`invoke` 自動路由模式可能在無意間啟動付費流程，官方建議使用 `suggest`。
- 版本迭代非常快（v7 → v11），預設模型、供應商清單常變動，升級前需看 CHANGELOG 與遷移指南（如 v10、v11 MCP 需傳入絕對路徑 `project_root`）。
- Claude Code 對第三方 marketplace 預設不自動更新，需手動開啟或執行更新指令。
- 解除安裝（`claude plugin uninstall octo`）不會刪除 `~/.claude-octopus/` 與 `.octo/` 內的資料。
- 31 persona／63 技能等數字為專案自述；README 中的品質效益未見獨立評測。

## 相關工具

- Claude Code（宿主）、OpenAI Codex CLI、Google Antigravity CLI、Cursor CLI、OpenCode（可作為席位的供應商）
- obra/superpowers（README 中比較的單 agent 方法論外掛）
- [agency-agents](./agency-agents.md)（專業角色人設集合）
- [Cline](./Cline.md)（另一套具多 agent 團隊功能的 coding agent）

## 資料來源

- https://github.com/nyldn/claude-octopus （README）
- https://api.github.com/repos/nyldn/claude-octopus
- https://api.github.com/repos/nyldn/claude-octopus/releases/latest
