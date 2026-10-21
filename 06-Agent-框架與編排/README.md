# 🧠 Agent 框架與編排

建構與組織 AI agent 的工具：寫 LLM 應用與多 agent 系統的框架、coding agent 與它的外掛和 skill 組、知識庫與文件問答工具，以及 LLM 應用的評測框架。

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

## Coding agent

### [Cline](Cline.md)

開源自主 coding agent，有 VS Code 擴充套件、CLI、桌面 App 與 SDK。以 Plan／Act 模式和人工核准讓使用者保有控制權，不綁定模型供應商。

可以做到：
- 在 IDE 裡讓 agent 實作功能、重構、修 bug，並逐步審核 diff。
- 自由切換模型，包含本地模型。
- 在 CI/CD 裡做自動審查與修測試；用 SDK 自建內部 coding agent。

## Coding agent 外掛與 skill 組

### [Claude Octopus](Claude-Octopus.md)

Claude Code 外掛，讓 Codex、Gemini 等多個模型對同一任務各自作答、互相審查與辯論，在出貨前揭露分歧。平常用 Claude Code 原生功能，需要多模型意見時才呼叫 `/octo:*`。

可以做到：
- 重要架構決策或技術選型時，取得多個模型的獨立意見與對抗式辯論。
- 讓不同廠商的模型交叉檢查程式碼與資安審查的盲點。
- 把既有的 ChatGPT、Copilot、Cursor 訂閱納入審查流程。

### [pstack](pstack.md)

把 Cursor 的 pstack skill 組移植到 Claude Code、Codex、GitHub Copilot、Pi 的版本。對 `poteto-mode` 說出目標，它會挑對應流程，經過調查、設計、委派、多模型審查與驗證，交回修正和證據。

可以做到：
- 修 bug 時先重現、再調查、修正、重跑失敗案例，附上前後證據。
- 用 `arena` 平行嘗試多種解法、用 `interrogate` 讓三個模型挑一份 diff 的毛病。
- 用 `babysit`、`fix-ci` 照顧 PR 直到可合併；用 `reflect`、`correct` 把教訓寫回 skill。

### [agency-agents](agency-agents.md)

230 多個專業 agent 人設的合集，每個是一份 `.md`，定義角色身分、工作流程、交付物與成功指標，橫跨工程、設計、行銷、銷售、資安、遊戲開發等部門。

可以做到：
- 一次替 Claude Code、Cursor、Codex 加上大量專業子 agent。
- 用多角色分工模擬一個小型團隊，完成 MVP、行銷活動等。
- 當撰寫自訂 agent 人設的範本。

### [Claude Code Game Studios](Claude-Code-Game-Studios.md)

Claude Code 的遊戲開發工作室模板：49 個分層 agent（總監／主管／專才）、74 個 slash 指令、hooks 與路徑規則，支援 Godot、Unity、Unreal。採「提問 → 給選項 → 由你決定」的協作模式，不是全自動。

可以做到：
- 單人用 AI 從點子、GDD、架構決策、Sprint 到發行檢查，走完整遊戲開發流程。
- 用 `modes.rigor` 調整流程重量，從 game jam 速度到完整審查。
- 以 hooks 與規則自動把關 commit、資產與程式碼標準。

### [yao-meta-skill](yao-meta-skill.md)

建立、評測、打包與治理 agent skill 的 meta-skill（2.0 版自稱「Skill OS」），可輸出給 Claude、OpenAI 與通用 Agent Skills 相容平台。附一套 skill 供應鏈安全政策：發布前需核准網路、檔案寫入、子程序權限並產出信任報告。MIT，beta。

可以做到：
- 用固定流程製作、測試並打包可跨平台安裝的 agent skill。
- 建立團隊內部發布 agent skill 前的安全審查流程。
- 參考如何把權限寫成可稽核的核准紀錄與阻擋規則。

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

## LLM 評測

### [DeepEval](DeepEval.md)

Confident AI 的 LLM 評測框架，寫法像 Pytest：30 多種現成指標（G-Eval、幻覺、RAG、agent 任務完成度與工具正確性、多輪對話、MCP），可評整條 agent 軌跡。評測為主，紅隊不是重點。Apache-2.0。

可以做到：
- 用 Python 替 RAG、chatbot、agent 寫品質測試，`deepeval test run` 放進 CI。
- 換模型或改 prompt 前後做回歸比較；評估 agent 是否用對工具與 MCP。
- 產生合成測試資料，跑 MMLU、GSM8K 等標準基準。

## 怎麼挑

- **寫 LLM 應用程式**：要自動最佳化品質用 DSPy，要多角色協作用 CrewAI，要語音即時對話用 Pipecat。
- **寫程式的 agent**：Cline。
- **替 Claude Code 等 agent 加能力**：多模型審查用 Claude Octopus；從調查到驗證的固定工作流程用 pstack；現成角色用 agency-agents；用 Claude Code 做遊戲用 Claude Code Game Studios（直接操作引擎見 [🎮 遊戲引擎 × Agent](../13-遊戲引擎-×-Agent/)）；自己做 skill 並在發布前做安全審查用 yao-meta-skill。
- **和文件對話、建知識庫**：不寫程式、要本機私密用 AnythingLLM；寫程式處理圖表公式多的文件用 RAG-Anything；讓 agent 操作 NotebookLM 用 notebooklm-py。
- **讓 agent 跨 session 記住事情**：Cognee。
- **評測自己的 LLM 應用**：在 Python 裡寫細緻的 agent／RAG 評測用 DeepEval；要紅隊測試見資安類的 [Promptfoo](../09-資安/Promptfoo.md)。
