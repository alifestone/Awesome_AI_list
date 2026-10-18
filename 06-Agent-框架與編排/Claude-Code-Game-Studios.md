# Claude Code Game Studios

- **分類**：Agent 框架與編排 / Coding agent 外掛與 skill 組
- **連結**：https://github.com/Donchitos/Claude-Code-Game-Studios

## 概述

Claude Code Game Studios（CCGS）是 Donchitos 維護的開源模板，把單一 Claude Code session 組織成一間遊戲工作室：49 個專職 agent、74 個 slash 指令（skills）、12 個事件 hooks、13 條路徑範圍規則與 39 份文件範本。目的是替「一個人搭配 AI 做遊戲」補上結構——設計文件審查、架構決策、QA、里程碑與發行流程，避免硬編碼數值、跳過設計文件、缺少把關。

專案強調**協作而非全自動**：agent 先提問、列出 2–4 個選項與利弊，由使用者決定，草稿經核准才寫入檔案。

GitHub 資訊（2026-10-15 查閱）：MIT 授權，最新版 v1.1.3（2026-10-08）。

## 核心功能／特色

- **三層工作室架構**：Tier 1 總監（creative-director、technical-director、producer）、Tier 2 部門主管（game-designer、lead-programmer、art-director、qa-lead 等）、Tier 3 專才（gameplay-programmer、level-designer、sound-designer、writer、security-engineer 等）。衝突依層級上報給共同上層。
- **三大引擎專用 agent 組**：Godot 4（GDScript、Shaders、GDExtension）、Unity（DOTS/ECS、Addressables、UI Toolkit 等）、Unreal Engine 5（GAS、Blueprints、Replication、UMG/CommonUI）。
- **74 個 skills 涵蓋全流程**：`/start` 引導入門，`/brainstorm`、`/design-system`（設計）、`/create-architecture`、`/architecture-decision`（架構）、`/create-epics`、`/create-stories`、`/dev-story`、`/story-done`（開發）、`/qa-plan`、`/smoke-check`、`/gate-check`（品質）、`/release-checklist`、`/patch-notes`（發行），以及 `/team-combat`、`/team-ui` 等多 agent 協作指令。
- **`modes.rigor` 流程重量**：`minimal`（預設，接近 game jam 速度）、`standard`、`full`，單一設定連動 GDD 必填章節、文件密度、QA 證據、審查人數等；可用 `/settings` 調整，也可用 `project.local.yaml` 做個人覆寫。
- **實測取向**：README 附上不同 rigor 等級的實測——`standard` 在第一行遊戲程式碼前產生 30 份文件、耗時 58 分鐘，但盲測排名反而最後，因此預設為 `minimal`。涉及玩家可見變更的 story 必須實際啟動遊戲並留存截圖證據，才算完成。
- **Hooks 自動把關**：commit／push 驗證、資產 JSON 與命名檢查、session 生命週期紀錄、subagent 稽核軌跡、缺漏設計文件偵測；`settings.json` 內建權限規則，封鎖 force push、`rm -rf`、讀取 `.env` 等危險操作。
- **路徑範圍規則**：依檔案位置強制不同標準（如 `src/gameplay/**` 資料驅動、`src/networking/**` 伺服器權威）。
- **Skill 測試框架**：`CCGS Skill Testing Framework/` 提供 `/skill-test`、`/skill-improve`，用來驗證自行修改的 skills 與 agents。

## 安裝與使用方式

```bash
git clone https://github.com/Donchitos/Claude-Code-Game-Studios.git my-game
cd my-game
claude          # 務必在專案根目錄（有 CLAUDE.md 與 project.yaml 處）啟動
```

進入 Claude Code 後執行 `/start`，系統會詢問目前進度（沒想法、有概念、設計完成、既有專案）並導向對應流程；已知需求可直接 `/brainstorm`、`/setup-engine godot 4.6` 或 `/project-stage-detect`。

- 前置需求：Git、Claude Code、Python 3（所有 skill 與 hook 都靠它讀 `project.yaml`）、Bash；建議安裝 jq。
- 平台：主要在 Windows 10（Git Bash）開發，亦測試 macOS 與 Linux；`notify.sh` 的桌面通知僅 Windows 有效。

## 適用情境

- 單人或小團隊用 Claude Code 從點子一路做到發行的遊戲專案。
- 想把設計文件（GDD）、架構決策紀錄（ADR）、Sprint 與 QA 流程交給 AI 協助，但每一步仍保留人工決策。
- 作為「角色化多 agent 團隊」模板，參考其目錄、hooks 與規則設計，改造成其他領域的工作流程。

## 授權與成本

- 授權：**MIT**。
- 模板本身免費；費用來自 Claude Code 使用量。三位總監 agent 指定 Opus，lead-programmer 與 15 位專才指定 Sonnet，其餘 30 個繼承目前 session 的模型。

## 限制與注意事項

- 這是**模板而非遊戲產出器**：倉庫不附成品遊戲，README 也坦承重流程不等於更好的遊戲，建議從 `minimal` 開始、需要時再提高。
- 必須在專案根目錄啟動 Claude Code，否則 hooks、deny 規則與詢問優先的權限模式不會生效。
- 若缺少 Python，所有設定會靜默退回預設值；暫存 data JSON 的 commit 在無 Python 時會被擋下。
- 專案 `settings.json` 的 git 規則會連 commit 訊息文字一併比對（例如訊息含 `push +` 會被拒），需改寫訊息。
- 數字（49 agents、74 skills 等）為專案自述。

## 相關工具

- [agency-agents](./agency-agents.md)（含遊戲開發在內的專業角色人設集合）
- [Claude Octopus](./Claude-Octopus.md)（Claude Code 外掛，多模型交叉審查）
- Claude Code（宿主）；Godot、Unity、Unreal Engine（支援的遊戲引擎）

## 資料來源

- https://github.com/Donchitos/Claude-Code-Game-Studios （README、CHANGELOG、LICENSE）
