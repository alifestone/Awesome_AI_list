# Cognee

- **分類**：Agent 框架與編排
- **連結**：https://github.com/topoteretes/cognee

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：開源的 AI agent 長期記憶平台。它把文件、程式碼、對話轉成可自架的知識圖譜加向量索引，讓 agent 跨 session 記得專案脈絡與過去的決定。Python 函式庫，另有 CLI、MCP server、Claude Code／Codex 外掛、REST API 與網頁 UI。Apache-2.0。

## 概述

Cognee 是 agent 的「記憶層」。把內容丟進去後，文字會被抽成實體、關係與可搜尋的片段，程式碼會變成符號與相依關係的圖；查詢時再依問題挑圖、向量或程式碼脈絡，交給應用程式或 agent 使用。session 中學到的經驗可以「蒸餾」進永久記憶，供下一個 session 取用。

從 v1.6.0（2026-09）起，沒有 LLM API key 也能跑：用本機 GLiNER 模型抽圖、本機 embedding 模型做向量，靠 CPU 就能執行。設定 LLM key 後才會生成答案，並啟用需要 LLM 的改進步驟。

由 Topoteretes（Vasilije Markovic 等人）開發。repo 於 2023-08 建立，查詢當下（2026-10-21）約 32.6k 顆星、3.4k forks，最新版 v1.6.5（2026-10-16），更新頻繁。團隊另發表論文 [Optimizing the Interface Between Knowledge Graphs and LLMs for Complex Reasoning](https://arxiv.org/abs/2505.24478)（2025）。

## 核心功能／特色

- **四個核心操作**：
  - `remember`：存進永久記憶；給 session ID 時存進 session。
  - `recall`：取回脈絡或答案，可自動選檢索策略。
  - `improve`：補強記憶、套用回饋，把 session 知識併進圖。
  - `forget`：刪除單筆或整個 dataset。
- **免 API key 本機模式**：GLiNER 抽實體與關係，加上本機 embedding；文字匯入、檢索與 session 儲存都不需要 LLM。
- **程式碼記憶**：把程式碼建成符號與相依關係圖。
- **自訂資料模型與本體（ontology）**：依自己的領域定義實體與關係。
- **接 agent**：
  - Claude Code 記憶外掛、Codex 外掛、OpenClaw 外掛。
  - 給 Cursor、Cline 等用的 MCP server。
  - Python、TypeScript、Rust SDK 與 REST API。
- **資料來源連接器**：內建 Google Drive、Gmail OAuth 連接器（v1.6.1）；另可從 Mem0、Letta、Zep、Graphiti 匯入記憶（COGX 交換格式）。
- **網頁 UI 與圖視覺化**：`cognee-cli -ui` 檢視本機記憶與知識圖譜。

## 技術架構或運作原理

- 匯入時跑 pipeline（Task + DataPoint 結構），分三條：匯入、session 學習、自我改進。
- 儲存分三種，預設全在本機：
  - 關係資料庫：預設 SQLite，可換 Postgres、Turso。
  - 向量資料庫：預設 LanceDB，可換 PGVector、Turso。
  - 圖資料庫：預設 Kuzu，可換 Ladybug、Neo4j、Amazon Neptune。
- 自 1.0 起可把整個記憶層放在單一 Postgres 上（⚠️ Postgres 當圖資料庫目前是 demo 功能，正式版為付費授權產品）。
- 設定 LLM key 後預設用 OpenAI 的語言與 embedding 模型，也可改用其他供應商或本機 Ollama。

## 安裝與使用方式

需求：Python 3.10–3.14。

```bash
uv pip install "cognee[gliner]"   # gliner extra：無 LLM key 時的本機抽取模型

# CLI：存入與查詢
cognee-cli remember "Marie Curie was born in Warsaw." -d local_quickstart
cognee-cli recall "Where was Marie Curie born?" -d local_quickstart

# 不下載模型，直接看內建範例圖
cognee-cli demo
```

```python
import asyncio
import cognee

async def main():
    await cognee.remember("Marie Curie was born in Warsaw ...", dataset_name="local_quickstart")
    print(await cognee.recall("Where was Marie Curie born?", datasets=["local_quickstart"]))

asyncio.run(main())
```

接 Claude Code：

```bash
claude plugin marketplace add topoteretes/cognee-integrations
claude plugin install cognee-memory@cognee
```

Docker 部署：`docker compose --profile ui --profile mcp up`。預設埠為 API 8000、UI 3000、MCP 8001。

## 適用情境

- 讓 Claude Code、Codex 等 coding agent 跨 session 記住專案脈絡、修過的 bug 與學到的規則。
- 建「公司大腦」：把文件、對話、工單、程式碼放進共享記憶，查得到決策背後的討論與實作。
- 需要以實體與關係（而不只是向量相似度）檢索的 GraphRAG 應用。
- 不想付 API 費用、想完全在本機 CPU 上建知識圖譜的實驗。

## 授權與成本

- 開源核心為 **Apache-2.0**，本機執行免費。
- 使用 OpenAI 等雲端 LLM 時另計供應商費用。
- 另有付費的 Cognee Cloud（託管服務），以及 Postgres 圖儲存與高精度抽取模型等授權產品。

## 限制與注意事項

- 內建 GLiNER 抽取器官方定位為 demo，準確度與標籤涵蓋有限；正式版需聯繫官方。
- 無 LLM 時只會回傳檢索到的原文片段，不會生成答案；讀圖、轉錄等媒體處理需另設模型。
- Docker 範例的 `ENABLE_BACKEND_ACCESS_CONTROL=false` 是單人本機模式；不關閉時 API 預設為多租戶，每個呼叫都要驗證。對外部署前要另外設定驗證、持久化儲存與權限。
- 官方 BEAM 評測（100K token 0.79、10M token 0.67）是自測，且兩組設定不同，README 提醒不要直接拿去和其他系統比。
- UI 需要 Node.js/npm，UI 的 MCP 服務需要 Docker。
- v1.6.1 起 `dlt` 成為核心相依，自行管理相依時要注意。

## 相關工具

- [RAG-Anything](RAG-Anything.md)：同樣以知識圖譜做檢索，但偏多模態文件問答。
- [AnythingLLM](AnythingLLM.md)：有圖形介面、不用寫程式的本地文件問答 App。
- [TencentDB Agent Memory](TencentDB-Agent-Memory.md)：騰訊雲的團隊級 agent 記憶，偏多 agent 共享、權限與資產分配，用 Proxy 接入。
- Mem0、Letta、Zep、Graphiti：其他 agent 記憶系統，Cognee 支援從它們匯入（未逐一查證）。

## 資料來源

- https://github.com/topoteretes/cognee （README、`.env.template`、資料庫 adapter 目錄；查詢時約 32.6k 星，v1.6.5）
- https://docs.cognee.ai/core-concepts/architecture
- https://arxiv.org/abs/2505.24478
