# dsh-superagent

- **分類**：Agent 框架與編排 / Coding agent
- **連結**：https://github.com/deepseek-ai/dsh-superagent-prototype

## 概述

dsh-superagent 是 DeepSeek 發布的**主動式 coding agent 研究原型**：負責一個 GitHub repo，以 [DeepSeek Harness](https://www.deepseek.com/en/harness/)（DSH）bundle 的形式執行。它監聽 GitHub（選用：飛書）上的事件，有被允許的人開口要求時，就開一張工單，在獨立的 DSH session 與目錄裡完成工作，再回到原本的對話回覆，例如開一個 pull request。另有 web 面板列出需要人處理的事。

它同時是一套和 agent 共事的原則：**盡量少佔用人的注意力，盡量多給價值**。agent 只在被要求、或團隊寫好的規則允許時才行動；只在有人必須處理、或有結果可用時才發言：接單時確認一次，工作期間保持安靜，有結果、需要決定或做不完時才再出聲，一次只問一個具體問題。

README 開頭聲明這**不是 DeepSeek 的正式產品**，是團隊日常開發長出來的研究程式碼，大部分工程由 coding agent 完成，可能有 bug、風格不一致；發布版也和內部版本、以及文章 *Exploring Super-agent Design: Towards a More Autonomous Agent System* 描述的實作不完全相同，文中部分設計只是未來方向。

查閱時（2026-11-10）GitHub 顯示約 21.7k stars、2.6k forks；repo 建立於 2026-10-31，只有一個初始 commit（同日），最後 push 為 2026-11-03，沒有 release，`package.json` 版本 0.1.0。

## 核心功能／特色

### 工作流程

事件依「Trigger → Eval → 執行」流動：

1. **Source** 產生 **Trigger**（一個不可變的事件）。內建兩種 Source：
   - **GitHub**：通知、訂閱的 Issue 與 PR、CI 變化、PR 合併或關閉；開啟「全收」開關時，連 repo 裡每個新 Issue、PR、留言和預設分支的 CI 都會收到
   - **飛書**：即時事件、歷史補讀、訂閱話題的輪詢
2. **Eval** 判斷一批 Trigger 要不要開新工作，分兩層：確定性的 **gate**（誰可以發起、強度多少）加上模型的 **assessment**。結果是 accept／stop／ignore／unavailable。
3. Accept 時建立 **Ticket**（工單），附一份不可變的 **Mandate**（授權）：記錄當時的 Policy 版本、範圍、強度、符合的規則與發起者身分。範圍要擴大就得開新工單。
4. **Executor** 為每張工單開一個 `worker-<ticket id>` session 和一個目錄（通常由 prepare 指令用 `git worktree` 建 checkout）。
5. 結果透過 **Channel** 寫回原本的對話：飛書話題回覆、GitHub 留言、review thread 回覆、PR。

工單會**訂閱**相關的 thread，之後在 Issue 或 PR 上的討論會自動送到負責的 executor，不必再 @ agent；已結束的工單被人留言時可在同一份授權下恢復。

### 授權與主動工作

- **明確請求**：在允許清單上的人 @ agent 或私訊，或在已有工單的 thread 上追問。
- **推斷候選**：沒 @ agent 的訊息、清單外的人追問、bot 清單上的 bot（例如 `dependabot[bot]`）的訊息。bot 永遠不能發出明確請求，也不能停止工單。
- 每個 Source 有一張**准入表**，依接收範圍（GitHub 的新 Issue／新 PR／留言／預設分支 CI、飛書的各個群與私訊）決定訊息算明確、推斷還是忽略。
- **Accept 模式**：`off`（不產生推斷候選）、`observe`（預設：評估但只記錄「會接」，不實際接單）、`auto`（評估通過就接）。主動工作至少要符合一條團隊寫的規則。
- Policy 一變，進行中的 Eval 作廢重排；受影響的工單收到通知，但不會被取消。恢復已結束的工單前會依現行 Policy 重新驗證授權。
- 人在 thread 裡說「停」是一般 Trigger，由 Eval 判定；面板上的 Stop 則是直接指令。executor 不能自己宣稱「有人要我停」。

### 執行與交付

- 工單有明確的階段：等人（輸入送不到、等回答、等 review、受阻／失敗）、排隊、等待 Trigger、工作中。
- Executor 的 shell 指令超過 5 秒就轉成背景工作，讓它在下一步就能收到新訊息；每輪結束後背景工作最多再跑 30 分鐘。
- 並行上限之外保留一個額外名額給人的訊息或狀態查詢，新工作不會擋住人接續既有工單。
- 所有後續動作（轉送、啟動、送輸入、回覆）都先存起來再執行，失敗以退避重試；重啟後會帶著「先檢查目錄、git 歷史與 GitHub 再重複對外動作」的提示恢復。
- Auto-merge 由 Delivery requirements prompt 控制：預設不以 agent 帳號開啟（GitHub 會把合併記在開啟者名下），需要另一個有合併權限帳號的 CLI；預設規則只允許替工單開的、已核准、增刪合計少於 200 行的 PR。

### 面板

在 DSH Web 側邊欄打開 **Superagent**，依序回答三個問題：現在有沒有事要我處理？系統健康、做的事對不對？某件工作從 Trigger、Eval 到工單的完整歷史？分頁為 Overview、Source、Trigger、Eval、Execution、Settings；健康的狀態不佔版面。Prompt 可編輯團隊段落、內建段落與 skill，有版本歷史，升級後預設內容有變會提示比較。

## 技術架構或運作原理

- TypeScript（Node.js 22.19+ 或 24+、pnpm），以 DSH plugin bundle 形式安裝到獨立的 DSH profile（建議叫 `superagent`），面板預設在 `127.0.0.1:3082`。
- 主 session（程式碼中稱 `orchestrator`，preset `dsh-superagent-router`）負責評估、派工與回覆；每張工單的 executor session（`worker`，preset `dsh-superagent-worker`）負責實作。
- 核心類別：`Runtime`、`Engine`、`Store`、`Policy`、`MasterAssessor`、`DshExecutor`、`Outbox` 等；新增 Source 的方式寫在 `docs/008-cookbook.md`。
- Executor 透過 `<stateDir>/worker-bin` 裡的 shim 使用 agent 帳號的 `gh` 與飛書 bot 的 `lark-cli`，另有專用的 git 設定（用 agent CLI 當 credential helper、移除 `GH_TOKEN`／`GITHUB_TOKEN`）；名稱含 KEY、PASSWORD、SECRET、TOKEN 的環境變數會被移除。
- 文件依序編號（000 理念 → 001 領域模型 → 002 授權 → 003 執行 → 004 Prompt → 005 面板 → 006 部署 → 007 架構 → 008 Cookbook），每份只建立在前面幾份之上。

## 安裝與使用方式

設定步驟很多，官方建議交給 coding agent 帶你做：

> Read SETUP.md in this repository and set up dsh-superagent with me.

agent 會一次問一個問題（Source、repo、agent 帳號、允許清單、checkout、commit 身分、要不要 auto-merge），整理成一份計畫讓你確認後才執行；密碼與登入由你自己在終端機完成。

需要：Node.js 22.19+／24+、pnpm、git 2.32+、tmux、Python 3.8+、GitHub CLI 2.48+、符合 `engines.dsh`（`^0.2.1-alpha.2`）的 DSH 與一個已設定的模型供應商；一個**專用的** GitHub 帳號給 agent；用飛書時另需 `lark-cli` 與飛書／Lark bot app。

手動安裝（取自 `docs/006-deployment.md`）：

```sh
npm install -g @deepseek-ai/dsh@0.2.1-rc.3
git clone https://github.com/deepseek-ai/dsh-superagent-prototype dsh-superagent && cd dsh-superagent
pnpm install && pnpm build
dsh superagent --from-default-profile web --dump-config > /dev/null   # 只在全新安裝時執行
dsh plugin --profile superagent add "link:$PWD"

# 複製 examples/profile.cordis.patch.yml 到 ~/.dsh/profiles/superagent/ 並填好 stateDir 等
scripts/dsh-superagent start
scripts/dsh-superagent status
```

之後在面板（或 Management API）設定 Source、Policy、Executor 與 prompt。試用：用允許清單上的帳號在 repo 的 Issue 留言 `@<agent 帳號> <要求>`，約一分鐘內面板會出現工單。

## 適用情境

- 想讓一個 agent 以團隊成員身分常駐在 repo，接 Issue 上的請求、開 PR、跟進 review 與 CI
- 團隊在飛書協作，希望在群裡 @ bot 就能派工給 coding agent
- 想讓 agent 依團隊寫的規則主動處理某類事（例如 dependabot PR），但先用 `observe` 看它會怎麼做
- 研究「主動式 agent 如何控制噪音、授權與恢復」的設計參考：領域模型、授權規則與失敗處理都有完整文件

## 授權與成本

- **授權**：MIT。
- **成本**：程式免費；需要 DSH 與模型供應商（模型費用依供應商計）。Eval 與每張工單的 executor 都會呼叫模型。

## 限制與注意事項

- **研究原型**：官方明說不是正式產品、非 production-ready；目前只有一個初始 commit、沒有 release。
- **沒有隔離**：兩個 preset 都以 `danger-full-access`、操作者的 OS 帳號執行，worker 不需核准就能跑指令，可以用絕對路徑執行程式、讀取操作者的家目錄。帳號 wrapper 和被封鎖的指令只是預設值，不是安全邊界；官方建議用只放 agent 憑證的專用 OS 帳號。同時 agent 會讀取 Issue、留言等不受信任的內容（文件把「哪些 Trigger 欄位可信」列為未決問題）。
- **代表團隊發言**：agent 以團隊每天看到的帳號留言、開 PR。官方建議允許清單從短開始、主動工作先用 `observe`、太吵就把 prompt 改短改嚴，並為它說的話負責；不要用它大量開 PR 或廣播訊息。
- 綁定 DSH（DeepSeek Harness）與其 alpha／rc 版本；只支援 github.com，不支援 GitHub Enterprise Server。
- 一個部署只負責一個 repo。
- Plugin 會改動整個程序的 `PATH` 與 git 設定，所以必須放在獨立的 DSH profile，不要和自己平常工作的 profile 混用。

## 相關工具

- [Cline](Cline.md)：在 IDE 裡由人逐步審核的 coding agent；dsh-superagent 則是常駐在 GitHub／飛書、由人派工的團隊成員型 agent
- [claude-work-mode](claude-work-mode.md)：同樣在處理「agent 什麼時候該打擾人」，但作用在單一 Claude Code session

## 資料來源

- https://github.com/deepseek-ai/dsh-superagent-prototype
- https://raw.githubusercontent.com/deepseek-ai/dsh-superagent-prototype/HEAD/README.md
- https://raw.githubusercontent.com/deepseek-ai/dsh-superagent-prototype/HEAD/SETUP.md
- https://raw.githubusercontent.com/deepseek-ai/dsh-superagent-prototype/HEAD/docs/000-philosophy.md
- https://raw.githubusercontent.com/deepseek-ai/dsh-superagent-prototype/HEAD/docs/001-domain.md
- https://raw.githubusercontent.com/deepseek-ai/dsh-superagent-prototype/HEAD/docs/002-authorization.md
- https://raw.githubusercontent.com/deepseek-ai/dsh-superagent-prototype/HEAD/docs/003-execution.md
- https://raw.githubusercontent.com/deepseek-ai/dsh-superagent-prototype/HEAD/docs/005-panel.md
- https://raw.githubusercontent.com/deepseek-ai/dsh-superagent-prototype/HEAD/docs/006-deployment.md
- https://raw.githubusercontent.com/deepseek-ai/dsh-superagent-prototype/HEAD/docs/007-architecture.md
- https://api.github.com/repos/deepseek-ai/dsh-superagent-prototype
