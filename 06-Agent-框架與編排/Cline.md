# Cline

- **分類**：Agent 框架與編排 / Coding agent 與外掛
- **連結**：https://github.com/cline/cline

## 原清單說明

VS Code 裡的自主 coding agent。

> 查證結果：正確但已不完整。Cline 最初以 VS Code 擴充套件起家（Marketplace ID 仍為 `saoudrizwan.claude-dev`），目前官方定位為「在 IDE、終端機與桌面上的開源 coding agent」，同時提供 **CLI、桌面 App（macOS／Windows）、VS Code 擴充套件、JetBrains 外掛與 Node.js SDK**。

## 概述

Cline 是由 Cline Bot Inc. 維護的開源自主 coding agent。它能讀懂專案結構、跨檔案協調修改、在終端機執行指令並即時觀察輸出，並以「Plan / Act」模式與人工核准機制讓使用者保有控制權。不綁定單一模型供應商。

GitHub 數據（2026-10-13 透過 GitHub API 查得）：約 7.0 萬顆星，主要語言 TypeScript，建立於 2024-07-06。GitHub「latest release」顯示為 `desktop-v0.0.45`（2026-10-08，桌面 App 版本）；VS Code 擴充套件、CLI、SDK 各有獨立 CHANGELOG。

## 核心功能／特色

- **跨專案編輯**：理解檔案關聯並協調修改；工作時監看 linter／編譯器錯誤，自動修正缺少 import、型別不符、語法錯誤等。在 VS Code 與 JetBrains 中每次編輯都以 diff 呈現，可檢視、修改或還原；以 **checkpoints** 追蹤變更，可輕鬆撤銷。
- **執行終端機指令**：安裝套件、建置、測試、部署、管理資料庫；對長時間程序（如 dev server）會在背景持續反應新輸出。
- **Plan 與 Act 模式**：Plan 模式探索程式碼並提出策略、詢問澄清問題；Act 模式執行。每次檔案編輯與指令預設需核准，也可開啟 auto-approve 自主執行。
- **Rules 與 Skills**：以 `.clinerules` 定義專案規範（程式風格、架構慣例、部署流程等），CLI、VS Code、JetBrains 都會自動讀取。
- **支援幾乎所有模型**：Anthropic、OpenAI、Google Gemini、OpenRouter（200+ 模型）、Vercel AI Gateway、AWS Bedrock、Azure／GCP Vertex、Cerebras、Groq、Ollama／LM Studio 本地模型，以及任何 OpenAI 相容 API。
- **擴充**：透過 SDK 的 plugin 系統註冊工具與生命週期 hooks；或使用 MCP server 連接資料庫、API、雲端基礎設施，CLI 以 `cline mcp` 管理。
- **多 agent 團隊**：協調者 agent 拆解任務並委派給專家 agent，團隊狀態可跨 session 延續。
- **排程 agent**：以 cron 定期執行（例如每日 PR 摘要、每週相依性檢查），重開機後仍保留。
- **聊天平台連接**：Telegram、Slack、Discord、Google Chat、WhatsApp、Linear，可設定存取控制。
- **Headless CLI**：無互動模式、可 pipe 輸入、輸出 JSON，適合 CI/CD。

## 技術架構或運作原理

- Monorepo（TypeScript）。所有前端（CLI、桌面 App、VS Code、JetBrains）共用同一個 agent 核心，該核心也以 `@cline/sdk` 對外提供。
- 桌面 App 架構：Tauri 外殼 + Bun sidecar + Next.js UI。
- JetBrains 外掛透過共用 agent core 運作，但**目前未開源**。
- Agent 以工具呼叫循環運作：讀檔、編輯（產生 diff）、執行指令、瀏覽網頁、呼叫 MCP 工具，並依核准設定決定是否暫停等待人工確認。

## 安裝與使用方式

```bash
# CLI
npm i -g cline

cline "Run tests and fix any failures"
git diff origin/main | cline "Review these changes for issues"
cline --json "List all TODO comments"
cline --team-name auth-sprint "Plan and implement user authentication with tests"
cline schedule create "PR summary" --cron "0 9 * * MON-FRI" \
  --prompt "List all open PRs and their review status" --workspace /path/to/repo
cline connect telegram -k $BOT_TOKEN

# SDK
npm install @cline/sdk
```

- VS Code：從 Marketplace 安裝（`saoudrizwan.claude-dev`）。
- JetBrains：從 JetBrains Marketplace 安裝（支援 IntelliJ IDEA、PyCharm、WebStorm、GoLand 等）。
- 桌面 App：https://cline.bot/desktop（macOS、Windows）。
- 文件：https://docs.cline.bot

## 適用情境

- 在 IDE 內讓 agent 實作功能、重構、修 bug，同時逐步審核 diff。
- 想自由選擇／切換模型（含本地模型）的開發者。
- CI/CD 中的自動化審查、測試修復；定期報告類排程任務。
- 以 SDK 自建內部 coding agent 或整合工具。

## 授權與成本

- 授權：**Apache-2.0**（© 2026 Cline Bot Inc.）。
- 官網定價頁：開源版對個人開發者**免費**；模型推論依用量計費、無訂閱，也可自帶 API key（BYOK）。另有 **Enterprise** 方案，價格需洽業務（未公開）。具體推論單價**資料不足**。

## 限制與注意事項

- 自主執行指令與編輯檔案具風險，開啟 auto-approve 前應確認環境（建議在版本控制下使用，並善用 checkpoints）。
- 實際能力與成本高度取決於所選模型；長任務可能消耗大量 token。
- JetBrains 外掛未開源。
- VS Code 擴充套件程式碼仍在遷移至新 monorepo 結構中（README 標示 WIP）。
- 桌面 App 目前僅 macOS 與 Windows。

## 相關工具

- Claude Code、OpenAI Codex CLI、Cursor、Aider、OpenCode（同類 coding agent）
- [Claude Octopus](./Claude-Octopus.md)、[agency-agents](./agency-agents.md)（coding agent 的外掛／人設擴充）

## 資料來源

- https://github.com/cline/cline （README）
- https://api.github.com/repos/cline/cline
- https://api.github.com/repos/cline/cline/releases/latest
- https://cline.bot/pricing
