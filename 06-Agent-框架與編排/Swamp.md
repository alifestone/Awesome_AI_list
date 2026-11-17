# Swamp

- **分類**：Agent 框架與編排 / 框架
- **連結**：https://github.com/swamp-club/swamp
- **官網／手冊**：https://swamp-club.com/manual

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：repo 標語為「The right way to build with AI」，自稱「Behavior-Centric AI」。Elder Swamp Club, Inc. 出品，TypeScript（Deno）寫成的單一 CLI。原始碼為 AGPLv3（另附「Extension and Definition Exception」），但官方發行的 `swamp` 執行檔走商業授權協議，且**每個指令都要 swamp-club.com 帳號**。截至 2026-11-17 約 830 顆星、66 個 fork；repo 建立於 2026-01-28，發版非常頻繁（版本號是時間戳，2026-11-17 一天就有多個 release）。不收外部 PR，改由 issue 回報、維護者用 Claude 實作。

## 概述

Swamp 的主張是：與其讓 agent 每次都從頭推理、燒大量 token，不如讓 agent 把問題拆成**可重複使用的 behavior**，再把 behavior 接成**可審查、可分享、可重跑的 workflow**。官方手冊稱它是「設計給 AI agent 操作的自適應自動化框架」。

實際用法是：在 repo 裡 `swamp repo init`，Swamp 會把自己的 skill 與指示寫進你的 coding agent（Claude Code、Cursor、Codex 等），然後你直接跟 agent 說「盤點所有區域的 EC2，標出沒有 cost-center tag 的」或「做一個輪替資料庫憑證並存進 vault 的 workflow」。Agent 會找或寫 behavior、產出 YAML 定義與 workflow、執行它們；所有定義都是 repo 裡的檔案，上線前可以先 review。範例偏向基礎設施與維運（雲端資源、DNS 稽核、伺服器健康檢查、憑證輪替）。

## 核心概念

- **Behavior**（舊稱 model，`swamp model` 仍可用）：工作的基本單位，分兩半。
  - **Type**：TypeScript 寫的可重用邏輯（一種雲端資源、一個 CLI 工具、一個 API），宣告方法、輸入輸出 schema 與執行方式。
  - **Definition**：YAML 設定，把某個 type 套用到一個具體情境，可用 CEL 表達式取動態值或引用其他 behavior 的輸出。因為只是符合 schema 的結構化資料，agent 不需要寫程式就能產出。
- **Workflow**：由 job 組成的 DAG，job 依相依順序執行、job 內的 step 平行執行。Step 之間用 CEL 串資料（例如 `data.latest("check-swamp-club", "result").attributes.status`），前一步沒產出時會直接失敗而不是傳空值。可巢狀呼叫其他 workflow、加 `manual_approval` 人工核准關卡、在遠端 worker 上執行、排程執行。
- **Extension**：現成的 API、資料庫、服務整合，從官方 registry 拉，或自己寫後發布。
- **Vault**：憑證儲存，只在需要時注入並在輸出中遮蔽；定義檔透過 CEL 引用。
- **Datastore**：每次方法執行都產生不可變、有版本的資料（resource、log、檔案），可查詢、可設保存期限、可加 tag。預設在 repo 內的 `.swamp/`，也可改到外部檔案系統（如 NFS）或用 `@swamp/s3-datastore` 放 S3 供團隊共用（附分散式鎖）。

定義、workflow、vault 設定分別放在 repo 的 `models/`、`workflows/`、`vaults/`，跟著 Git 版控；執行資料進 datastore。每次執行都有紀錄（稽核時間軸）。

## 支援的 agent

`swamp repo init --tool <名稱>` 會把內建在執行檔裡的 skill 寫到對應目錄，可重複 `--tool` 同時設定多個：

| Agent | 旗標 | Skill 目錄 | 指示檔 |
| --- | --- | --- | --- |
| Claude Code | （預設） | `.claude/skills/` | `CLAUDE.md` |
| Cursor | `cursor` | `.cursor/skills/` | `.cursor/rules/swamp.mdc` |
| OpenCode | `opencode` | `.agents/skills/` | `AGENTS.md` |
| Codex | `codex` | `.agents/skills/` | `AGENTS.md` |
| Kiro | `kiro` | `.kiro/skills/` | `.kiro/steering/swamp-rules.md` |
| Amp、Copilot CLI、Pi、Antigravity | `amp`／`copilot`／`pi`／`antigravity` | `.agents/skills/` | `AGENTS.md` |

不在清單上的 agent 可用 `swamp agent setup` 自行定義。若 repo 已有自己的 `AGENTS.md` 而沒有 `CLAUDE.md`，Claude Code 的指示會改寫到 `.claude/rules/swamp.md`。

## 安裝與使用方式

支援 macOS、Linux（x86_64、arm64）與 Windows（x86_64）。

```bash
# macOS / Linux
curl -fsSL https://swamp-club.com/install.sh | sh
# Windows（PowerShell）
irm https://swamp-club.com/install.ps1 | iex

# 方式一：開瀏覽器登入、選工作區、描述任務，Swamp 幫你在新終端機開好 agent
swamp start

# 方式二：在既有專案裡用
swamp auth login
swamp repo init                 # 預設 Claude Code
swamp repo init --tool codex    # 或其他 agent
# 然後在 repo 裡啟動 agent，直接描述想自動化的事
```

其他常用指令：`swamp update`（自我更新）、`swamp completions <shell>`、`swamp datastore setup|status|sync`、`swamp workspace create|import|list`。`swamp start` 建立的工作區放在 `~/.swamp/workspaces/`，每個任務的 brief 存在 `tasks/`。

## 授權與費用

- **原始碼**：AGPLv3 only，加上「Swamp Extension and Definition Exception」——只透過官方 extension API／定義 schema 與官方版本互動的 extension 與定義檔，可用任何授權（包含閉源）發布。
- **官方執行檔**：OSS-FAQ 明說「Swamp 是用開源軟體做成的商業產品」，模式類似 Red Hat／VS Code；官方發行版走[軟體授權協議](https://swamp-club.com/software-license-agreement)。自己編譯散布必須拿掉所有商標，`swamp` 指令也要改名。
- **方案**（2026-11 官網）：Personal $0（個人專案、社群支援）；Team 每人每月 $9（年繳，1–10 人）；Business $15（11–30 人）；Enterprise 另議（含 on-prem 與 AGPL 豁免）。全部方案功能相同，30 天免費試用。「使用者」包含透過依賴 Swamp 的應用、agent、chatbot 間接使用的人。

## 注意事項

- ⚠️ **必須有 swamp-club.com 帳號**：除了 `--help`、`version`、`auth`、`start` 等少數指令，連 `swamp repo init` 與只用本機 datastore 的 repo 都要先登入。登入後會存一份 14 天有效的簽章憑證，有效期內可離線執行；CI 與 daemon 要用 `SWAMP_API_KEY`。
- ⚠️ **預設開啟使用遙測**：每個指令送一筆事件（指令名稱、耗時、結果，以及 behavior／workflow 名稱；輸入值、路徑、輸出會遮蔽）。關閉方式：`swamp config set telemetry.collection disabled`、`.swamp.yaml` 設 `telemetryDisabled: true`，或設 `SWAMP_NO_TELEMETRY` / `DO_NOT_TRACK` 環境變數。OpenTelemetry 追蹤則是另外選擇開啟。
- 執行完全在本機，使用你 shell 的環境變數（AWS 憑證、SSH key、kubeconfig 等），除非 behavior 主動呼叫外部 API，憑證不會離開本機。但這也代表 agent 寫出的 workflow 能動到你這些憑證能動到的東西，跑之前要 review。
- 發版極頻繁、概念還在改名（model → behavior），文件與舊教學可能對不上。
- 不接受外部 PR；功能需求與 bug 走 [swamp-club.com/lab](https://swamp-club.com/lab) 的 issue。

## 適合誰

- 想讓 coding agent 做重複性的維運、雲端盤點、稽核、憑證輪替，而且希望產出是**可版控、可審查、可重跑**的 workflow，而不是每次重新對話。
- 需要執行紀錄、版本化資料、vault 與人工核准關卡的團隊自動化。
- 不適合：不想註冊帳號或不能送遙測的環境（遙測可關，帳號不行）；只想要一個寫 LLM 應用的函式庫（那用 DSPy、CrewAI）。
