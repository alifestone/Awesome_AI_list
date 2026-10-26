# ARTEX

- **分類**：資安 / 滲透測試
- **連結**（皆為第三方備份／fork，原倉庫已下架）：
  - https://github.com/Hinln/ARTEX — 原專案 v0.3.15 原始碼備份，保留原 commit 歷史（458 commits，約 1.1k stars／1.6k forks）
  - https://github.com/jiwoochris/artex-global — 在地化 fork（Global Edition），UI 與 agent 輸出支援英／韓／中／西／日，附防禦偵測資料（約 2.2k stars／2.3k forks，793 commits）
  - https://github.com/trhhubsd/ARTEX — 自稱延續維護原專案（464 commits，約 2.0k stars／955 forks）

## 原清單說明

AI 自主滲透測試系統，百度「agent+」攻防挑戰賽冠軍專案。AGPL-3.0。

> **查證結果**：
> - 「AI 自主滲透測試系統」「AGPL-3.0」：與 README 一致。
> - 「百度 agent+ 攻防挑戰賽冠軍專案」：僅見於專案自己的 GitHub 簡介與 Trendshift 轉錄的專案標籤，未找到百度或主辦方的獨立公告，**無法證實**。
> - **重要補充**：以上連結皆非原作者主倉庫；先前收錄的 `mhtsec/ARTEX` 是原專案最終版本的「純原始碼備份」，不是原作者的主倉庫。據 Cloud Security Alliance 研究筆記，原作者（代號 Autumn-27）於 2026-10-08 以工具遭濫用為由下架 GitHub 專案，並表示不再更新、改為閉源（詳見「限制與注意事項」）。

## 概述

ARTEX 是一套以多個 LLM agent 協作的自主滲透測試平台。後端用 Go，前端用 Next.js，資料庫是 PostgreSQL，透過 Web UI 管理任務、檢視 agent 的工具呼叫軌跡、資產圖與發現項目。據 CSA 研究筆記，它在 2026-07-26 首次釋出，採 AGPL-3.0。CSA 也指出 ARTEX 本身不是語言模型，而是調度外部模型與資安工具的編排框架。

先前收錄的 `mhtsec/ARTEX` 為備份倉庫（約 3.5k stars、5.9k forks）。README 說明原 Docker 映像 `autumn27/artex` 已從 Docker Hub 移除，備份改維護 `mianhuatang11/artex`。

### 目前收錄的三個倉庫

| 倉庫 | 性質 | 特色 |
|---|---|---|
| [Hinln/ARTEX](https://github.com/Hinln/ARTEX) | 原專案 v0.3.15 備份 | 保留原 commit 歷史與 AGPL-3.0；提供預編譯 release 與 `start.sh`；README 提到自動更新需 `ARTEX_UPDATE_GITHUB_TOKEN`，且更新來源為私有倉庫，一般使用者無法依賴 |
| [jiwoochris/artex-global](https://github.com/jiwoochris/artex-global) | 多語系 fork | 5 種 UI 語言（內部推理 prompt 仍為原語言）；附防禦／偵測指南、Sigma 與 Suricata 規則、MITRE ATT&CK Navigator layer、IOC 清單與唯讀主機排查腳本；README 稱上游目前無法存取（2026-10 查閱） |
| [trhhubsd/ARTEX](https://github.com/trhhubsd/ARTEX) | 自稱延續維護 | 無 GitHub「forked from」標示；README 範例版本 0.3.3，含 Nginx SSE 反向代理設定；維護者身分與程式碼是否被改動未驗證 |

三者 README 皆保留相同的使用限制與 AGPL-3.0。上述數字為 2026-10-27 查閱時的頁面顯示，未逐一比對原始碼差異。

## 核心功能／特色

依 README 所列：

- 儀表板、任務清單，以及含工具呼叫軌跡的執行 session
- 探索圖（exploration graph）與資產圖（asset graph），含資產覆蓋率檢視
- 發現項目與資產管理；透過 MITM 代理記錄流量
- Human-in-the-loop 對話：人員可介入指揮 agent
- 在 UI 中管理 agent 與設定 LLM
- 工具呼叫的審批攔截（approval gate）與審批紀錄
- 可從 ScopeSentry 同步資產
- 手動漏洞複測，以獨立 agent session 執行
- UI 一鍵更新，可回滾到上一版執行檔

## 技術架構或運作原理

- **Agent SDK**：建構在 `norma` SDK 上，含 `agentcore`、`tool`、`permission`、`harness`、`memory`、`transcript` 等套件。
- **Agent 角色分工**：
  - `goals`：拆解目標、擷取測試範圍（scope）
  - `planner`：唯一負責產生「意圖（intent）」的元件，並在多次喚醒之間維護共享待辦清單，讓多步驟任務依相依順序推進
  - `worker`：執行意圖，每個任務可有多個實例（預設 3 個，可在系統設定調整）；worker 可搜尋同任務中其他 worker 的執行軌跡，重用觀察結果
  - `mainagent`：負責與人員的對話
- **雙圖設計**：資產圖是跨任務共享的儲存（根網域、子網域、IP、服務、應用、端點）；探索圖則每個任務一份，記錄目標、意圖、事實、發現與提示，兩圖以 anchor 相連。
- **周邊子系統**：帶 CA 的錄製代理、審批閘門（guard/intercept）、DNS/HTTP 資訊補強、MCP（可連遠端 `http`/`sse` MCP server）、skills、記憶與報告。
- **LLM**：支援 Anthropic（`ANTHROPIC_API_KEY`）或 OpenAI（`OPENAI_API_KEY`），也可在 UI 設定 provider、模型、base URL 與代理。README 未指定特定模型。
- **工具環境**：Docker 映像內含 ripgrep、curl、vim、npm、nmap 等常見工具。

## 安裝與使用方式

需求：PostgreSQL（必要）、LLM API key（探索功能必要）、Docker（選用）、Go 與 Node.js（僅從原始碼建置時需要）。

README 提供三種方式（以下只列部署指令，不涉及測試操作）：

```bash
# 方式一：一鍵腳本（README 推薦）
git clone https://github.com/Hinln/ARTEX.git   # 或 jiwoochris/artex-global
cd ARTEX
./install.sh

# 方式二：Docker Compose
cp .env.example .env
docker compose up -d

# 方式三：從原始碼建置
cd web && npm ci && npm run build:static && cd ..
cp -r web/out server/webui/dist
CGO_ENABLED=0 go build -tags embedui -o artex ./cmd/artex
```

- Web UI 預設在 `http://localhost:8787`，首次進入 `/setup` 設定管理員密碼。
- 更新用 `./update.sh` 或 UI 內建更新器；開發用 `./dev.sh`，測試用 `go test ./...`。
- 備份倉庫不提供預編譯執行檔；README 中的建置範例版本為 0.3.3。
- README 提到的線上 demo（artex-demo.mhtsec.com）只有模擬資料。

## 適用情境

- 研究「多 agent 自主滲透測試」的架構設計，例如規劃者／執行者分工、雙圖記憶、審批閘門
- 在**完全隔離的本機實驗環境**中做技術驗證與教學
- 防守方了解此類工具的能力與流量特徵，用於偵測與防禦規劃（CSA 研究筆記即從這個角度提出建議）

## 授權與成本

- **授權**：AGPL-3.0。修改後若以網路服務形式提供，須向使用者公開完整對應原始碼。
- **成本**：軟體本身免費；使用時需自行負擔 LLM API 費用與運算資源。實際費用資料不足。

## 限制與注意事項

- **README 的使用限制比一般滲透測試工具更嚴格**：README 聲明本專案僅供個人學習、程式碼研究與本機技術驗證，**明確禁止對任何網站或線上系統做掃描、探測、利用或攻擊，即使已取得授權也不行**，也禁止用於正式環境或真實滲透測試。軟體依「現狀（AS IS）」提供，使用者自負全部法律責任。
- **濫用事件**：據 CSA 研究筆記（2026-10-09）整理，CrowdStrike 於 2026-10-07 報告，一名身分未確認的攻擊者在 2026 年 9 月下旬至 10 月初，結合 ARTEX 與多個 LLM 攻擊南韓金融機構。CrowdStrike 以「中等信心」評估攻擊者講中文、以獲利為動機。這個關聯主要來自攻擊者自己的 session 紀錄，受害方與主管機關在當時尚未獨立證實；各媒體報導的受害機構數也不一致（5、7 或 9 家）。
- **專案狀態**：原作者於 2026-10-08 下架專案並宣布轉為閉源、停止維護。目前流通的多為 fork 或鏡像（包括本連結），來源可信度與後續維護都不確定。CSA 建議只使用經過審查、在本地檢查過的版本，避免來路不明的 fork。
- **技術限制（README）**：複測紀錄尚未納入報告匯出與任務封存；更新會重啟程序並中斷執行中的任務；Docker 更新只替換程式，不更新映像內附工具；UPX 壓縮的執行檔可能與部分核心或安全政策不相容，因此預設不啟用。
- **法律提醒**：未經授權對他人系統做任何探測或攻擊，在多數司法管轄區都是違法行為。即使用於研究，也應在自行擁有、完全隔離的環境中進行，並遵守 README 的限制。

## 相關工具

- [Pentest Copilot](./Pentest-Copilot.md)：同樣是 AI 滲透測試 agent，採 MIT 授權，強調危險指令需人工審批
- [Promptfoo](./Promptfoo.md)：用於 LLM 應用本身的紅隊與安全評測
- ScopeSentry：README 提到可同步其資產資料

## 資料來源

- https://github.com/Hinln/ARTEX
- https://github.com/jiwoochris/artex-global
- https://github.com/trhhubsd/ARTEX
- https://github.com/mhtsec/ARTEX（先前收錄的備份）
- https://trendshift.io/repositories/289644
- https://labs.cloudsecurityalliance.org/research/csa-research-note-artex-agentic-pentest-bank-breaches-202610/
- 搜尋結果標題（未能完整讀取內文）：The Hacker News〈artex ai pentesting tool used in data〉https://thehackernews.com/2026/10/artex-ai-pentesting-tool-used-in-data.html（嘗試讀取時回傳 403）
