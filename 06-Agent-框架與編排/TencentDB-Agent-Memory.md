# TencentDB Agent Memory

- **分類**：Agent 框架與編排 / Agent 記憶
- **連結**：https://github.com/TencentCloud/TencentDB-Agent-Memory
- **文件網站**：https://tencentcloud.github.io/TencentDB-Agent-Memory/
- **npm（v1 OpenClaw 外掛）**：https://www.npmjs.com/package/@tencentdb-agent-memory/memory-tencentdb

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：騰訊雲 TencentDB 團隊開源的「團隊級」agent 記憶中樞。它把對話、文件、程式碼整理成四種可重複使用的記憶資產：Chat Memory、Skill、Wiki、CodeGraph。這些資產可以在不同 agent 與框架之間共享、審核，並依權限分配給指定 agent。TypeScript 寫成，用 Docker 部署，MIT 授權。注意 repo 有兩條線：預設分支 `feat/server_team` 是 **v2 團隊記憶中樞**（本條目主體），`main` 分支是 **v1 OpenClaw／Hermes 記憶外掛**。

## 概述

出發點是「少做重工」：專案背景講過一次，新 session 就不必再講；文件讀過一次，每個 agent 就不必從頭讀；跑通的流程，下次也不必重新摸索。

v2 的做法是在 coding agent 和上游 LLM 之間放一個 **Proxy**。agent 只要把 API base URL 改指向 Proxy，不必裝外掛、hook 或 MCP server。Proxy 會把每輪對話寫回記憶服務，並在下一輪把該 agent 被分配到的記憶、Skill 與知識注入系統提示詞。另有 **Memory Hub** 網頁面板，人可以在上面建團隊與 agent、審核資產、決定誰能用什麼。

v1（`main` 分支，npm `@tencentdb-agent-memory/memory-tencentdb` 1.0.3）是 OpenClaw 外掛，重點在單一 agent：
- 分層長期記憶（L0–L3）。
- 「符號化短期記憶」：把冗長的工具輸出卸載到檔案，只在 context 裡留一張 Mermaid 任務圖。

repo 建立於 2026-04-07，查詢當下（2026-10-22）約 29.7k 顆星、2.9k forks，最後推送 2026-10-21。最新正式版 v2.0.2（2026-10-09），另有 v2.0.3-beta.1（2026-10-13）。README 的 Roadmap 段落仍寫「目前版本 v2.0.0」，已過時。

## 核心功能／特色

- **四種記憶資產**：
  - **Chat Memory**：從對話抽出偏好、事實、決定與互動歷史，分四層——L0 原始對話 → L1 原子事實 → L2 情境 → L3 人設（Persona）。
  - **Skill**：完成複雜工作後，從對話與工具呼叫抽出可重複使用的流程，帶版本、資源檔、觸發條件、執行步驟與驗證規則。
  - **Wiki**：把產品文件、設計規格、維運手冊轉成有連結圖的結構化頁面（靈感來自 Karpathy 的「LLM Wiki」）。
  - **CodeGraph**：索引程式碼的符號、檔案、呼叫關係與影響路徑，改程式前可做影響分析。
- **Proxy 零程式碼接入**：官方提供 Claude Code、Codex、CodeBuddy、WorkBuddy、DeepSeek Harness、Hermes、OpenClaw、OpenCode、Pi 的接入設定。Proxy 原樣轉發 OpenAI `/v1/chat/completions` 與 Anthropic `/v1/messages`。
- **團隊與權限**：資產有擁有者、版本、狀態與使用次數。可見度分四種：
  - `private`：只有擁有者能讀，團隊管理員也不行。新的 Chat Memory 與 Skill 預設是這種。
  - `team`：團隊成員都能讀。
  - `restricted`：依使用者／角色／agent 的 ACL 開放。
  - `agent`：配給同團隊內指定的 agent。
- **Agent 裝備（loadout）**：在面板上把不同資產綁給不同 agent，例如把「發版 Skill」配給發版 agent，CodeGraph 配給寫程式與審查的 agent。
- **冷啟動匯入**：可直接匯入既有 repo（建 CodeGraph）、文件（建 Wiki）、過去的 agent 對話（抽 Skill 與 Chat Memory）。v2.0.2 起也能從外部任務管理系統匯入 Task。
- **舊資料遷移**：附 v1／v0 → v2 的遷移工具。

## 技術架構或運作原理

v2 由三個 Docker 容器組成（Docker Hub `agentmemory/*`，amd64 + arm64）：

| 元件 | 預設埠 | 用途 |
| --- | --- | --- |
| memory-core | 8420 | 記憶讀寫、驗證、Skill／RAG 資料面 |
| memory-hub | 8125（面板）、8424（知識服務） | 管理面板 + Wiki／CodeGraph 服務 |
| proxy | 8096 | coding agent 的 API 入口，轉發到上游 LLM |

- **每個 session 綁定 team／agent／task**：Claude Code 開新 session 時，Proxy 會用 Claude Code 原生的 `AskUserQuestion` 讓你依序選 Team → Agent →（可略過的）Task，之後每輪都注入該 agent 的 L2／L3 記憶、Skill 與知識。
- **分層召回**：平常用 L2／L3 快速建立脈絡；需要具體事實時，用 BM25 + 向量檢索 + RRF 退回 L1／L0 查。結果有筆數、字數與逾時上限，避免記憶塞爆 context。L0／L1 以唯讀工具提供給模型主動查詢，官方說這樣可避免上游 KV cache 失效。
- **Wiki 與 CodeGraph 按需呼叫**：不整包注入，agent 先用 `/v3/tools/list` 看有哪些工具，再用 `/v3/tools/call` 讀頁面、原始碼或影響路徑。
- **背景 pipeline**：對話先存成 L0，累積到門檻後由背景 worker 依序抽出 L1 → L2 → L3。
- **儲存**：預設 SQLite，資料放在 Docker volume；MongoDB 後端（需 7.0+ 且帶 mongot）為實驗功能，預設關閉。
- **可插拔決策服務（v2.0.3-beta.1，預設關閉）**：Skill 選擇與「要不要更新 L3」的判斷可交給決策服務，內建 TypeSafe 的 JEV（見 [⚡ Jev 決策模型生態](../07-Jev-決策模型生態/)）。範例端點是騰訊 TokenHub 的 `/v1/systemone`，也可改接 TypeSafe 原生端點。
- **沿用的開源程式碼**：CodeGraph 模組用了 [colbymchenry/codegraph](https://github.com/colbymchenry/codegraph)（MIT）的程式碼；Skill 管理用了部分 [Hermes Agent](https://github.com/nousresearch/hermes-agent)（Nous Research）的 Skill 程式碼。

## 安裝與使用方式

需求：Docker（Docker Desktop／colima／OrbStack 皆可），以及兩組 LLM 設定。兩組可以填同一個供應商：
- `MEMORY_LLM_*`：記憶與知識服務內部用，負責 embedding、摘要與 Wiki 生成。協定可選 `openai` 或 `anthropic`。
- `PROXY_UPSTREAM_*`：Proxy 把 agent 的請求轉發到的上游模型。

```bash
git clone https://github.com/TencentCloud/TencentDB-Agent-Memory.git
cd TencentDB-Agent-Memory/deploy/global-images
./start-all.sh     # 互動式：填兩組 LLM 參數、測試連線、啟動三個容器
# ./verify.sh      # 只檢查不啟動（--skip-llm 略過 LLM 測試）
```

首次啟動會建立管理員，並把 `sk-mem-...` 金鑰存到 `./.admin-key`。之後：

1. 開面板 http://localhost:8125，用管理員金鑰登入。
2. 建 Team，在 Team 的「Members」裡建一個業務使用者並抄下它的 `user_key`。這把金鑰只顯示一次。官方建議別拿管理員金鑰驅動 agent。
3. 在 Team 裡至少建一個 Agent，填清楚描述與系統提示詞；Task 可選。
4. 把 Claude Code 指向 Proxy：

```bash
export ANTHROPIC_BASE_URL=http://127.0.0.1:8096/claude-code/default
export ANTHROPIC_AUTH_TOKEN='sk-mem-<業務使用者的 user_key>'
claude --model <PROXY_UPSTREAM_MODEL 設定的模型名>
```

其他 agent 的設定見 repo 的 `agents/` 資料夾與 `INSTALL.md`。只要面板、已有 Memory Core 時，可單獨跑 `docker.io/agentmemory/memory-hub:latest`。

v1 OpenClaw 外掛（`main` 分支）：

```bash
openclaw plugins install @tencentdb-agent-memory/memory-tencentdb
openclaw gateway restart
# 再於 ~/.openclaw/openclaw.json 設 "memory-tencentdb": { "enabled": true }，預設用本機 SQLite + sqlite-vec
```

## 適用情境

- 多個 agent 或多人共用一套專案記憶：讓審查 agent、寫程式 agent、發版 agent 各拿到需要的 Wiki、CodeGraph 與 Skill。
- 想把「踩過的坑、驗證過的流程」沉澱成有版本、可審核、可分享的 Skill。
- 新 agent 或新成員上手：先匯入既有 repo、文件和過去對話，再開始工作。
- 混用 Claude Code、Codex、CodeBuddy 等多種 agent，又想要同一份記憶。

## 授權與成本

- **MIT**（`LICENSE` 為騰訊版權聲明加 MIT 條款，GitHub 因此顯示為「Other」）。自架免費。
- 執行時要付兩組 LLM 的 API 費用；記憶抽取與 Wiki 生成會額外消耗 token。
- Proxy 程式內有計費回報（依價目表計算 CreditDelta），只在路徑帶 `/proxy/<spaceId>/` 的請求生效，看起來是給騰訊雲託管版用的。託管版的價格與方案資料不足。

## 限制與注意事項

- **所有 agent 流量都經過 Proxy**：
  - prompt 與模型回覆會寫進記憶服務。v2.0.3-beta.1 起還會記錄每輪發往上游的完整訊息與回覆。
  - Claude Code 改用 `sk-mem-` 金鑰與你自己設的上游模型，不是用 Claude 訂閱登入。
  - 對外部署前要自行處理網路暴露與金鑰管理。
- **效益數字為官方自測**：
  - v2 README 只列 PersonaMem 準確率 48% → 76%。
  - v1 README 另列 WideSearch、SWE-bench、AA-LCR 的成功率與 token 節省，數字是在 OpenClaw 上、長 session 連續任務的設定下測得。
  - 兩者都未見第三方重現。
- **還在快速迭代**：README 自稱 Team Memory 為 Beta；Hub 目前只支援手動綁定資產，全自動記憶路由仍在開發中。
- Wiki 與 CodeGraph 非同步建立，要等狀態變成 `ready` 才能用。CodeGraph 以公開 HTTPS repo 為主；私有 repo 的 SSH 支援到 v2.0.3-beta.1 才加入。
- MongoDB 後端為實驗功能；切換 SQLite 與 MongoDB 不會自動搬資料，要先備份、手動遷移。
- 在面板上只有管理員能建 Team，業務使用者要自建 Team 得呼叫 API。
- 預設分支不是 `main`。從 GitHub 首頁看到的是 v2；直接 clone `main` 或看 npm 套件，得到的是 v1。

## 相關工具

- [Cognee](cognee.md)：同類的開源 agent 記憶，以知識圖譜為主、偏單一 agent 與 Python 生態；TencentDB Agent Memory 偏團隊共享、權限與「資產分配」，用 Proxy 接入。
- [notebooklm-py](notebooklm-py.md)：也能當 agent 的跨 session 知識庫，但記憶存在 Google NotebookLM。
- [⚡ Jev 決策模型生態](../07-Jev-決策模型生態/)：v2.0.3-beta.1 的可插拔決策服務內建 JEV；[Laya](../07-Jev-決策模型生態/Laya.md) 提供相同 `/v1/systemone` 介面的開源替代品（未實測能否直接接上）。
- Hermes Agent、OpenClaw：官方支援接入的 agent 框架，本清單未收錄。

## 資料來源

- https://github.com/TencentCloud/TencentDB-Agent-Memory （預設分支 `feat/server_team` 的 README、INSTALL.md、CHANGELOG.md、LICENSE、`deploy/global-images/.env.example`、`MemoryProxy/README.md`；查詢時約 29.7k 星）
- https://github.com/TencentCloud/TencentDB-Agent-Memory/tree/main （v1 README）
- https://www.npmjs.com/package/@tencentdb-agent-memory/memory-tencentdb （latest 1.0.3）
- https://github.com/colbymchenry/codegraph （MIT）
