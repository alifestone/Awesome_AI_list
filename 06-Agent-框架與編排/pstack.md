# pstack（多 harness 移植版）

- **分類**：Agent 框架與編排 / Coding agent 外掛與 skill 組
- **連結**：https://github.com/michael-denyer/pstack-claude
- **上游**：https://github.com/cursor/plugins/tree/main/pstack

## 原清單說明

（使用者提供連結，無附註說明）

> **查證結果**：這是 Michael Denyer 把 Lauren Tan（poteto）為 Cursor 寫的 pstack skill 組，移植到 Claude Code、Codex、GitHub Copilot、Pi 等 agent 環境的版本，持續追蹤上游。MIT。

## 概述

pstack 是一套「有主見」的 agent 工作流程 skill 組，目標是讓 coding agent 的產出更精簡、更簡單、而且有驗證。入口是 `poteto-mode`：說出目標，它會挑對應的流程（修 bug、做功能、重構、效能、調查、原型、PR 維護、出貨、長期專案），再依需要呼叫其他 skill 做規劃、委派、審查與驗證。

以修 bug 為例：先重現失敗，用 `how`、`why` 調查，再委派修正，最後重跑失敗案例；修正跨越函式邊界時會先叫 `architect` 定好型別與模組形狀。交回的除了修正，還有失敗與通過的證據。

repo 於 2026-05-26 建立，查詢當下（2026-10-16）約 2,500 顆星，最新版本 v0.9.86（2026-10-15，同步到上游 v0.15.25），更新非常頻繁。

## 核心功能／特色

- **63 個 skill**：39 個公開 skill，加上 24 個 `principle-*` 原則參考（如「先減再加」「修根因」「證明它能用」「測行為不測實作」）。
- **多模型協作 skill**：
  - `arena`：同一任務平行跑 N 次，挑出各版本最好的部分。
  - `architect`：寫跨函式邊界的程式前，先定型別與模組形狀。
  - `interrogate`：讓三個不同模型試著擊破一份 diff。
  - `swarm`：把工作切片後平行派給多個 worker，再彙整成一份報告。
- **調查與說明**：`how`（某子系統怎麼運作）、`why`（為什麼這樣設計，平行查多個 MCP 證據）、`teach`、`bro`（改寫成白話）。
- **審查與清理**：`thermo-nuclear-review`（找 bug、資安、破壞性變更）、`thermo-nuclear-code-quality-review`（極嚴格的可維護性審查）、`deslop`、`unslop`（去除 AI 腔）、`no-comments`、`blast-radius`（找出 diff 以外可能壞掉的東西，並實際跑程式證明安全）。
- **PR 與 CI**：`babysit`（盯著 PR、修 CI 與留言）、`fix-ci`、`fix-merge-conflicts`、`get-pr-comments`、`make-pr-easy-to-review`。
- **自我改進**：`reflect`（把長任務的心得寫回 skill）、`correct`（找出 agent 在某 repo 反覆犯的錯，用最高層級的機制讓它不可能再犯）、`automate-me`（從過往對話產生個人化的 -mode skill）、`create-verification-skill`（替專案生成驗證 skill）。
- **自動路由**：Claude Code、Codex、Copilot 外掛會裝一個 session-start hook；任務碰到多個檔案、涉及設計決策、或是原因不明的 bug／效能問題時，自動叫 `poteto-mode`，小任務則直接做。

## 技術架構或運作原理

- 所有環境共用同一個 `plugins/pstack/skills/` 目錄。skill 保留上游的 Claude 原生寫法，Codex、Pi、Copilot 版各有一份工具名稱對照表（`codex-tools.md`、`pi-tools.md`、`copilot-tools.md`），避免改寫每個上游 skill。
- **模型策略**：`models.json` 定義各角色用哪個模型。Claude Code 預設一般角色用 Opus、修 bug 與效能用最強的 Fable，`arena`／`architect`／`interrogate` 用 Opus、Fable、Sonnet、Haiku 組成的模型小組；Codex 則對應 GPT-6 系列。可用 `setup-pstack` 改模型與每個角色的推理強度（如 `arena runners: opus @xhigh`）。
- **與上游同步**：`tools/sync.mjs` 依 `tools/upstream.json` 的上游 SHA 做三方合併；移植版自己的修改需在 `tools/forks.json` 宣告，未宣告的分歧會讓同步失敗。
- `tools/generate.mjs` 從單一來源把版本號、模型設定、指令說明寫進各份副本，CI 用 `--check` 擋下過期的副本。
- 沒有伺服器或遙測；腳本在本機跑，PR 相關工具用你的 GitHub CLI 登入。

## 安裝與使用方式

```text
# Claude Code
/plugin marketplace add michael-denyer/pstack-claude
/plugin install pstack@pstack-claude
```

```bash
# Codex
codex plugin marketplace add michael-denyer/pstack-claude
codex plugin add pstack@pstack-claude

# Pi
pi install git:github.com/michael-denyer/pstack-claude

# GitHub Copilot CLI / App
copilot plugin marketplace add michael-denyer/pstack-claude
copilot plugin install pstack@pstack-claude
```

使用：

```text
Use poteto-mode to fix the search filter resetting when I change pages.
```

- Claude Code 的指令格式是 `/pstack:<name>`，Pi 是 `/skill:<name>`。
- 改模型或關掉自動路由：Claude Code 裡執行 `/pstack:setup-pstack`。
- Prime Agent、OpenCode、Gemini CLI 可用「只裝 skill」的方式（symlink 到 `~/.agents/skills/`）。

## 適用情境

- 想讓 Claude Code／Codex 在非小型任務上走固定的「重現 → 調查 → 設計 → 實作 → 審查 → 驗證」流程。
- 重要變更前要多模型交叉審查，或平行嘗試多種解法再取最好的。
- 照顧 PR：修 CI、處理審查留言、解衝突，直到可以合併。
- 團隊想把 agent 反覆犯的錯、專案的驗證方式寫成 skill 長期累積。

## 授權與成本

- 授權：**MIT**（移植版 © 2026 Michael Denyer；原始 pstack © 2026 Lauren Tan；引入的 cursor-team-kit、thermos skill © 2026 Cursor，另見 `LICENSE-cursor-team-kit`、`LICENSE-thermos`）。
- 外掛免費；費用來自模型用量。`arena`、`interrogate`、`swarm` 等會同時跑多個模型或多個子 agent，token 消耗明顯較高。

## 限制與注意事項

- 版本更新很快（v0.9.x，幾乎每天發版），skill 數量與預設模型常變。
- 自動路由 hook 預設開啟，會在 session 開始時注入指示；不想要可用 `setup-pstack` 關掉或在設定檔寫 `session hook: off`。Codex 需先透過 `/hooks` 信任該 hook。
- 委派與多模型流程只在 Claude Code、Codex、Pi、Copilot 上驗證過；Prime Agent、OpenCode、Gemini CLI 只驗證了 skill 能被發現。
- Copilot 版沒有預設模型，第一次用到需先跑 `setup-pstack` 選模型；Copilot CLI 1.0.92 的 `copilot -p` 模式有找不到 skill 的已知問題。
- skill 讀取的內容（包括對話紀錄）都會送到你的模型供應商。

## 相關工具

- [Claude Octopus](./Claude-Octopus.md)（另一個多模型交叉審查的 Claude Code 外掛）
- [agency-agents](./agency-agents.md)（專業角色人設集合）
- [Cline](./Cline.md)（開源 coding agent）
- [agent-formal-verify](https://github.com/michael-denyer/agent-formal-verify)（同作者，加上 TLA+ 模型檢查與 Lean 證明）

## 資料來源

- https://github.com/michael-denyer/pstack-claude （README、`docs/reference.md`、`CONTEXT.md`、`CHANGES.md`、`plugins/pstack/models.json`）
- https://api.github.com/repos/michael-denyer/pstack-claude
- https://api.github.com/repos/michael-denyer/pstack-claude/releases/latest
