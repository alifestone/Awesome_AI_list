# 🧠 Agent 框架與編排

建構與組織 AI agent 的工具：寫 LLM 應用與多 agent 系統的框架、coding agent 與它的外掛和 skill 組，以及 LLM 應用的評測與紅隊工具。知識庫、RAG 與 agent 記憶另見 [🗂️ RAG、知識庫與記憶](../14-RAG-知識庫與記憶/)。

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

### [yao-meta-skill](yao-meta-skill.md)

建立、評測、打包與治理 agent skill 的 meta-skill（2.0 版自稱「Skill OS」），可輸出給 Claude、OpenAI 與通用 Agent Skills 相容平台。附一套 skill 供應鏈安全政策：發布前需核准網路、檔案寫入、子程序權限並產出信任報告。MIT，beta。

可以做到：
- 用固定流程製作、測試並打包可跨平台安裝的 agent skill。
- 建立團隊內部發布 agent skill 前的安全審查流程。
- 參考如何把權限寫成可稽核的核准紀錄與阻擋規則。

### [TokenEconomizer](TokenEconomizer.md)

Microsoft Research 與 UC Berkeley 的 coding agent 成本控制外掛，支援 Claude Code、Codex、Copilot CLI、Pi。不改 agent 本身，從同一個 repo 過去的 session 學經驗：記住 repo 的事實（micro-skills）、排除一直沒用到的工具（tool pruning）、在卡進失敗迴圈時提示換方法（loop guard）。Apache-2.0。

可以做到：
- 在常用的 repo 裡降低 coding agent 的 token 成本（論文自述 SWE-Bench 上平均降 18.4–30.9%）。
- 自動把沒用到的工具與 MCP server 從 agent 設定中排除，一個指令就能還原。
- 偵測 agent 原地打轉並提示換方法，但不會自己中斷。

⚠️ v0.1.0，支援的 agent 版本範圍很窄；成效數字為作者自己的量測。

### [desloppify](desloppify.md)

讓 coding agent 把 vibe coding 出來的程式碼整理乾淨的 harness（Python 3.11+）：機械式偵測（死碼、重複、複雜度、測試缺口）加上 LLM 主觀審查（命名、抽象、模組邊界），算出 0–100 的健康分數，再照排好優先順序的佇列 `next` → 修 → `resolve` 反覆進行。狀態存在 `.desloppify/`，可跨 session 推進；分數設計成難以刷分。支援 Claude Code、Codex、Cursor、Copilot 等，29 種語言。

可以做到：
- 讓 agent 有系統地整理 AI 生成的 codebase：結構、命名、重複、錯誤處理一致性。
- 跨多個 session 持續重構，進度不會每次歸零。
- 在 CI 設整體程式碼品質門檻；產生分數徽章放在 README。

⚠️ 授權為作者自訂的 OSNL，非 OSI 開源：內部使用免費，非開源公司把它包進產品散布要依營收付費。分數有 75% 來自 LLM 審查。

## LLM 評測

### [DeepEval](DeepEval.md)

Confident AI 的 LLM 評測框架，寫法像 Pytest：30 多種現成指標（G-Eval、幻覺、RAG、agent 任務完成度與工具正確性、多輪對話、MCP），可評整條 agent 軌跡。評測為主，紅隊不是重點。Apache-2.0。

可以做到：
- 用 Python 替 RAG、chatbot、agent 寫品質測試，`deepeval test run` 放進 CI。
- 換模型或改 prompt 前後做回歸比較；評估 agent 是否用對工具與 MCP。
- 產生合成測試資料，跑 MMLU、GSM8K 等標準基準。

### [Promptfoo](Promptfoo.md)

LLM 應用的評測、回歸測試與紅隊工具：用 YAML 定義 prompt、模型與測試案例，在本機執行。MIT。

可以做到：
- 並排比較不同模型與 prompt 的輸出。
- 把 LLM 應用的品質回歸測試放進 CI/CD。
- 上線前對 chatbot、RAG、agent 做紅隊測試（prompt injection、資料外洩、越權、有害輸出），並為 OWASP LLM Top 10 等合規需求準備證據。

## 怎麼挑

- **寫 LLM 應用程式**：要自動最佳化品質用 DSPy，要多角色協作用 CrewAI，要語音即時對話用 Pipecat。
- **寫程式的 agent**：Cline。
- **替 Claude Code 等 agent 加能力**：多模型審查用 Claude Octopus；從調查到驗證的固定工作流程用 pstack；現成角色用 agency-agents；用 Claude Code 做遊戲見 [🎮 遊戲引擎 × Agent](../13-遊戲引擎-×-Agent/) 的 Claude Code Game Studios；自己做 skill 並在發布前做安全審查用 yao-meta-skill；降低 agent 在常用 repo 的 token 成本用 TokenEconomizer；讓 agent 有系統地整理 AI 生成的程式碼、追一個品質分數用 desloppify。
- **和文件對話、建知識庫、讓 agent 記住事情**：見 [🗂️ RAG、知識庫與記憶](../14-RAG-知識庫與記憶/)。
- **評測自己的 LLM 應用**：在 Python 裡寫細緻的 agent／RAG 評測用 DeepEval；用 YAML 設定、比較多個模型或要做紅隊測試用 Promptfoo（其他資安工具見 [🔐 資安](../09-資安/)）。
