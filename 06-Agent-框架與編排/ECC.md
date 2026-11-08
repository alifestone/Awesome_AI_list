# ECC

- **分類**：Agent 框架與編排 / Coding agent 外掛與 skill 組
- **連結**：https://github.com/affaan-m/ECC
- **官網**：https://ecc.tools
- **npm**：`ecc-universal`（安裝器）、`ecc-agentshield`（資安掃描）

## 概述

ECC 自稱「agent harness 效能最佳化系統」／「agent harness 作業系統」：替 Claude Code 等 coding agent 一次裝上一整套工程系統——規劃、測試、實作、審查、驗證、記憶、改進（`plan -> test -> implement -> review -> verify -> remember -> improve`），而不是每次在 prompt 裡重建流程。口號是「Optimize the context window. Persist everything else.」CHANGELOG 中仍可見舊名 `everything-claude-code`。

作者 Affaan Mustafa（GitHub `affaan-m`）表示自 Claude Code 實驗階段就開始使用，2025-09 贏得 Anthropic × Forum Ventures 黑客松，這些設定在多個正式上線的應用中實戰過。README 稱目前主要由一位維護者每週發版。

查閱時（2026-11-09）GitHub 顯示約 300k stars、44k forks；最新 release 為 v2.2.3（2026-10-01），repo 建立於 2026-01。

## 核心功能／特色

### 內容規模

| 內容 | 數量 | 用途 |
| --- | ---: | --- |
| Agents | 71 | 規劃、審查、修 build、資安、架構與各語言／領域審查 |
| Skills | 314 | TDD、研究、資安、文件、前端、資料、ML、維運等 |
| Commands | 98 | 舊式斜線指令入口（正在轉向以 skill 為主） |
| Hooks 與記憶 | — | 強制規則、session 摘要、持續學習、instincts、context 控制 |
| Rules | 依語言挑選 | 常駐載入的規範：`common/` 加 TypeScript、Python、Go、Rust、Swift、Java、Kotlin 等 20 多種語言／框架包 |
| AgentShield | 內含 | 掃描 prompt、hooks、MCP 設定、權限、機密與 agent 檔案 |

### 常用入口

| 要做的事 | 從這裡開始 |
| --- | --- |
| 做新功能 | `/ecc:plan "描述功能"`（planner agent）→ `tdd-workflow` skill |
| 修 bug | 用失敗測試重現 → `tdd-workflow` |
| 審查新程式碼 | `/code-review`（以全新 context 審查） |
| 分流 GitHub issue | `/ecc:issue-review <編號>` |
| 修 build | `/build-fix` |
| 整理 codebase | `/refactor-clean` |
| 查 context 壓力 | `/context-budget` |
| 結束／恢復長 session | `/save-session`、`/learn-eval` ／ `/resume-session` |
| 稽核 agent 設定 | `/security-scan` 或 `agentshield scan --path .` |

### 特色機制

- **持續學習（continuous-learning-v2）**：用 hooks 觀察 session，產生帶信心分數的原子「instinct」，再演化成 skill、指令或 agent；v2.1 起 instinct 以專案為範圍，避免跨專案汙染
- **Skill Creator**：`/skill-create` 在本機分析 git 歷史產生 `SKILL.md` 與 instinct；大型 repo、自動 PR、團隊分享則走付費 GitHub App
- **GateGuard**：執行前攔下破壞性 shell 指令（`rm`、強制 `git checkout`、破壞性 `find -exec` 等）
- **Token 最佳化指南**：建議預設用 Sonnet、子 agent 用 Haiku、自動壓縮門檻降到 50%，以及 `strategic-compact` skill 在合適斷點建議 `/compact`
- **跨 harness 共用 context**、統一記憶庫（`ecc memory`）、Plan Canvas 瀏覽器審閱、worktree 生命週期服務與 `orch-*` 編排器系列

## 技術架構或運作原理

- 主體為 Markdown（agents、skills、commands、rules）加上 Node.js 安裝器／CLI（`scripts/ecc.js`，需 Node.js 18+）；部分選用功能需要 Bash 或 Python
- Claude Code plugin 的 hooks 涵蓋 SessionStart、UserPromptSubmit、PreToolUse、PostToolUse、PreCompact、Stop、SessionEnd
- 安裝器以 manifest 驅動並記錄安裝狀態，提供 `doctor`、`repair`、`uninstall`；會帶入 hook runtime 的安裝必須明確選 `--enable-hooks` 或 `--no-hooks`
- 三個名稱不能混用：GitHub repo `affaan-m/ECC`、Claude plugin `ecc@ecc`、npm 套件 `ecc-universal`

### 平台支援（README 自評）

| Harness | 狀態 |
| --- | --- |
| Claude Code | 穩定，主要平台 |
| Codex、Qoder | 支援原生 plugin |
| Cursor、OpenCode、GitHub Copilot CLI | Beta 轉接 |
| GitHub Copilot Chat | 僅指示檔 |
| Gemini、Zed、Antigravity、Qwen、Hermes、Kimi 等 | 實驗性／最小轉接 |

作業系統：Linux、macOS、WSL 支援核心功能；原生 Windows 有已知缺陷（持續學習的 observer daemon、記憶庫寫入）。

## 安裝與使用方式

```bash
# 建議：引導式安裝（Claude Code、Codex、Kimi Code）
npx ecc-universal@2.2.3 setup

# 或在 Claude Code 內用原生 plugin 指令（兩者擇一）
/plugin marketplace add https://github.com/affaan-m/ECC
/plugin install ecc@ecc

# 低 context、不裝 hook runtime
npx ecc-universal@2.2.3 install --profile minimal --target claude
```

Claude Code plugin 無法散布 rules，需自行複製想要的規範包，例如 `rules/common` 加一個常用語言：

```bash
git clone https://github.com/affaan-m/ECC.git && cd ECC
mkdir -p ~/.claude/rules/ecc
cp -R rules/common rules/typescript ~/.claude/rules/ecc/
```

**同一個 harness 只能用一種安裝方式**，疊加安裝會讓 skill、指令與 hooks 重複（hooks 可能觸發兩次）。

## 適用情境

- 想一次取得大量現成的 agent、skill 與語言規範，再挑需要的用
- 想讓 agent 從過去的 session 自動累積經驗（instincts）
- 想稽核自己的 agent 設定、hooks、MCP 與權限有沒有資安風險（AgentShield）
- 在 Claude Code、Codex 等多個 harness 間共用同一套工作方式

## 授權與成本

- **授權**：MIT（README 承諾開源部分永遠 MIT）。
- **成本**：開源版免費；ECC Pro（託管的 GitHub App，用於私有 repo）每席每月 19 美元起，公開 repo 可免費安裝 GitHub App。

## 限制與注意事項

- **體積大、吃 context**：README 自己提醒 plugin 會把已安裝的整份目錄告訴模型，在意 context 時應改用選擇性或 minimal 安裝；先從需要的流程開始，不要全裝。
- **只從官方管道安裝**：README 警告第三方轉傳與非官方鏡像可能含惡意程式。Hooks 會執行 shell 指令，應視為可執行設定、裝前先看過。
- 除 Claude Code 外的平台功能並不對等，請先查支援矩陣。
- README 首頁有大量贊助商與付費方案推廣；數字（agents／skills 數量）以專案自述為準。
- 主要由單一維護者維護。
- 更新頻繁，舊文章中的安裝識別碼可能已過時。

## 相關工具

- [Superpowers](Superpowers.md)：小而聚焦的自動觸發方法論（15 個 skill）
- [Matt Pocock Skills](Matt-Pocock-Skills.md)：輕量、手動呼叫的工程紀律 skill 組
- [agency-agents](agency-agents.md)：大量專業 agent 人設合集
- [TokenEconomizer](TokenEconomizer.md)：同樣從過去 session 學習、降低 token 成本

## 資料來源

- https://github.com/affaan-m/ECC
- https://raw.githubusercontent.com/affaan-m/ECC/main/README.md
- https://github.com/affaan-m/ECC/blob/main/skills/continuous-learning-v2/SKILL.md
- https://github.com/affaan-m/ECC/blob/main/CHANGELOG.md
- https://ecc.tools
