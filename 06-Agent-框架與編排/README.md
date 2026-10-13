# 🧠 Agent 框架與編排

建構與組織 AI agent 的工具：寫 LLM 應用與多 agent 系統的框架、IDE 裡的 coding agent 與外掛、現成的 agent 角色集，以及本地一體化 LLM 應用。

## 框架

### [DSPy](DSPy.md)

Stanford NLP 的 Python 框架：用「簽章」描述任務、用程式組合 AI 系統，再由最佳化器依指標自動調整 prompt 與權重，而不是手調 prompt。

可以做到：
- 建構資訊擷取、分類、RAG、多跳問答、agent 等需要穩定品質的 LLM 應用。
- 有標註資料或評分函式時，自動最佳化 prompt。
- 換底層模型時重新編譯就好，不必重寫 prompt。

### [CrewAI](CrewAI.md)

多 agent 協作框架，兩個核心：Crews（以角色分工、自主協作的 agent 團隊）與 Flows（事件驅動、可精確控制的工作流）。

可以做到：
- 做多步驟、多專家角色分工的任務（研究 → 分析 → 撰寫報告）。
- 把自主 agent 包在確定性的業務流程裡。
- 從原型一路用到上線，不必換框架。

### [Pipecat](Pipecat.md)

即時語音／多模態對話 agent 框架：把語音辨識、LLM、語音合成與傳輸層串成管線，一般語音互動延遲約 500–800ms。

可以做到：
- 語音助理、客服或電話接聽 bot。
- AI 陪伴、教練、會議助理、角色扮演。
- 語音 + 視訊 + 影像的多模態介面；多個專家 agent 互相交接的語音系統。

## Coding agent 與外掛

### [Cline](Cline.md)

開源自主 coding agent，有 VS Code 擴充套件、CLI、桌面 App 與 SDK。以 Plan／Act 模式和人工核准讓使用者保有控制權，不綁定模型供應商。

可以做到：
- 在 IDE 裡讓 agent 實作功能、重構、修 bug，並逐步審核 diff。
- 自由切換模型，包含本地模型。
- 在 CI/CD 裡做自動審查與修測試；用 SDK 自建內部 coding agent。

### [Claude Octopus](Claude-Octopus.md)

Claude Code 外掛，讓 Codex、Gemini 等多個模型對同一任務各自作答、互相審查與辯論，在出貨前揭露分歧。平常用 Claude Code 原生功能，需要多模型意見時才呼叫 `/octo:*`。

可以做到：
- 重要架構決策或技術選型時，取得多個模型的獨立意見與對抗式辯論。
- 讓不同廠商的模型交叉檢查程式碼與資安審查的盲點。
- 把既有的 ChatGPT、Copilot、Cursor 訂閱納入審查流程。

### [agency-agents](agency-agents.md)

230 多個專業 agent 人設的合集，每個是一份 `.md`，定義角色身分、工作流程、交付物與成功指標，橫跨工程、設計、行銷、銷售、資安、遊戲開發等部門。

可以做到：
- 一次替 Claude Code、Cursor、Codex 加上大量專業子 agent。
- 用多角色分工模擬一個小型團隊，完成 MVP、行銷活動等。
- 當撰寫自訂 agent 人設的範本。

## 本地應用

### [AnythingLLM](AnythingLLM.md)

一體化、local-first 的 LLM 應用：接上本地或雲端模型、匯入文件就能對話，內建 agent、多使用者、向量資料庫與文件處理。

可以做到：
- 在本機私密地和內部文件對話（RAG），資料不送第三方。
- 團隊用 Docker 自架多使用者知識庫。
- 在同一介面切換多家模型，搭配 MCP 工具與排程 agent；在網站嵌入客服聊天 widget。

## 怎麼挑

- **寫 LLM 應用程式**：要自動最佳化品質用 DSPy，要多角色協作用 CrewAI，要語音即時對話用 Pipecat。
- **寫程式的 agent**：Cline；已在用 Claude Code 想加多模型審查：Claude Octopus；想要現成角色：agency-agents。
- **不寫程式、直接用**：AnythingLLM。
