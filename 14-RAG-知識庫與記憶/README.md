# 🗂️ RAG、知識庫與記憶

讓 LLM 和 agent 用上你自己的資料：和文件對話的知識庫應用、多模態 RAG 框架、操作 NotebookLM 的工具，以及讓 agent 跨 session 記住事情的記憶層。建構 agent 本身的框架見 [🧠 Agent 框架與編排](../06-Agent-框架與編排/)。

## 知識庫 / 文件問答

### [AnythingLLM](AnythingLLM.md)

一體化、local-first 的 LLM 應用：接上本地或雲端模型、匯入文件就能對話，內建 agent、多使用者、向量資料庫與文件處理。

可以做到：
- 在本機私密地和內部文件對話（RAG），資料不送第三方。
- 團隊用 Docker 自架多使用者知識庫。
- 在同一介面切換多家模型，搭配 MCP 工具與排程 agent；在網站嵌入客服聊天 widget。

### [RAG-Anything](RAG-Anything.md)

港大 HKUDS 的多模態 RAG 框架，建在 LightRAG 之上：用 MinerU 等解析器把 PDF、Office、圖片裡的文字、圖、表格、公式拆出來，交給視覺與語言模型理解，再建成多模態知識圖譜做混合檢索。Python 函式庫，沒有圖形介面。MIT。

可以做到：
- 對圖表、表格、公式很多的論文、技術文件、財報建問答系統。
- 用一套流程處理 PDF、PPT、Excel、掃描檔混雜的企業知識庫。
- 搭配 Ollama、vLLM 等本機模型，全程不上雲。

### [notebooklm-py](notebooklm-py.md)

非官方的 Google NotebookLM（現稱 Gemini Notebook）Python API、CLI 與 agent skill：讓 Claude Code、Codex 等 agent 直接操作筆記本，並提供網頁沒有的批次下載與結構化匯出。使用未公開 API，可能隨時失效。

可以做到：
- 把大量文件交給 NotebookLM 分析、取得帶引用的回答，agent 只負責編排以省 token。
- 批次生成 podcast、影片、簡報、測驗、心智圖並下載成 MP3／PDF／CSV／JSON。
- 用筆記本當 agent 的跨 session 記憶或專案知識庫。

## Agent 記憶

### [Cognee](cognee.md)

開源的 agent 長期記憶平台：把文件、程式碼、對話轉成可自架的知識圖譜加向量索引，agent 用 `remember`／`recall` 跨 session 存取，session 學到的經驗也能併進永久記憶。沒有 LLM API key 也能用本機小模型在 CPU 上跑。Apache-2.0。⚠️ 內建本機抽取模型官方定位為 demo，準確度有限。

可以做到：
- 裝 Claude Code 或 Codex 外掛，讓 coding agent 記住專案脈絡、過去的決定與修正。
- 用 MCP server 接 Cursor、Cline 等工具。
- 把文件、工單、程式碼建成「公司大腦」，從決策查到背後的討論與實作。
- 自訂本體與資料模型，並在網頁 UI 看知識圖譜。

### [TencentDB Agent Memory](TencentDB-Agent-Memory.md)

騰訊雲開源的團隊級 agent 記憶中樞：把對話、文件、程式碼整理成 Chat Memory（L0–L3 分層）、Skill、Wiki、CodeGraph 四種記憶資產，在 Memory Hub 面板上審核、設可見度與 ACL，再分配給指定 agent。agent 只要把 base URL 改指向 Proxy 就能接入，不必裝外掛。Docker 自架，MIT。⚠️ 所有 agent 流量都經過 Proxy 並被記錄；Team Memory 仍是 Beta，效益數字為官方自測。

可以做到：
- 讓 Claude Code、Codex、CodeBuddy 等不同 agent 共用同一份團隊記憶。
- 把驗證過的流程沉澱成有版本、可審核、可分享的 Skill，配給需要的 agent。
- 匯入既有 repo、文件與過去對話，替新 agent 冷啟動；改程式前用 CodeGraph 查影響範圍。

## 怎麼挑

- **和文件對話、建知識庫**：不寫程式、要本機私密用 AnythingLLM；寫程式處理圖表公式多的文件用 RAG-Anything；讓 agent 操作 NotebookLM 用 notebooklm-py。
- **讓 agent 跨 session 記住事情**：單一 agent、要知識圖譜與 Python 整合用 Cognee；多個 agent 或多人共享記憶、要權限與資產分配用 TencentDB Agent Memory。
- **評測 RAG 的品質**：見 Agent 框架類的 [DeepEval](../06-Agent-框架與編排/DeepEval.md)。
