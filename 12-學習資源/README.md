# 📚 學習資源

搭配 AI coding agent 學習的課程與教材，以及用 AI 輔助閱讀與研究的學習工具。

## 課程 / 教材

### [Learn Docker and K8s](Learn-Docker-and-K8s.md)

開源、互動式的 Docker、Linux、網路與 Kubernetes 學習遊戲。沒有網頁也沒有影片：在 Claude Code、Cursor 等 AI 編輯器中開啟專案，AI 扮演導師 Sarah，帶你在虛構咖啡新創公司的 DevOps 情境中解決問題。教材為英文。

可以做到：
- 用動手解題的方式學 DevOps 入門。
- 一邊用 AI coding 工具，一邊練習容器化與 K8s 基礎。
- 用故障排除情境複習 Docker 網路、儲存、Compose 與 K8s 部署。

### [Learn Harness Engineering](Learn-Harness-Engineering.md)

以專案為主軸的課程，教你替 AI coding agent 打造工作環境、狀態管理、驗證與控制機制。核心主張：模型不變，決定結果是否可靠的是 harness，而不是 prompt 寫得多好。有 15 種語言版本，含繁體中文。

可以做到：
- 讓 Claude Code、Codex 等 agent 在長任務、多 session 中更穩定。
- 理解環境設計如何影響 agent 的表現。
- 不適合想要零程式碼入門、或只關注 prompt 的人。

### [EECS 498 AASE](EECS-498-AASE.md)

密西根大學 2026 秋季 EECS 498-016「Applied Agentic Software Engineering」的公開教材：每講的投影片（Markdown／PDF／PPTX）、上課 live demo 的小型程式庫，以及把 Elephant-Goldfish Model 做成五個 Agent Skills 的 `egm/`。課程從用 Aider 做出 pair-programmer，到自己寫 agent 迴圈、核准層與評測。教材隨進度公開，英文，未附 LICENSE 檔。

可以做到：
- 跟著投影片學 Big Three（context、model、prompt）、規格驅動開發、工具呼叫與 subagents。
- 用 `reset` 腳本建立 demo 工作副本，自己操作 Aider 重現上課示範。
- 安裝 EGM skills，走「設計文件 → 無上下文 reviewer 審查 → 照文件實作 → 嚴格 code review」流程。

### [50 ML Projects to Understand LLMs](ML4LLM-Book.md)

Mike X Cohen 的書《50 ML projects to understand LLMs》配套程式碼：50 個專案，把 GPT-2、BERT 的 hidden states、注意力與 embedding 當成資料，用迴歸、分類、RSA、降維等機器學習方法分析 transformer 內部機制。每個專案有 helper（自己補完）與 solution 兩份 notebook，全部可在 Colab 跑。程式碼 MIT，書需另購，英文。

可以做到：
- 從斷詞、embedding、logits 一路到 attention 與 MLP，逐章拆解 transformer。
- 動手練 logit lens、activation patching、head 靜音、probing 等可解釋性技巧。
- 拿 LLM 當題材練機器學習與資料視覺化。

## 學習工具

### [PaperRead](PaperRead.md)

以繁體中文閱讀學術論文的個人研究工作區（EasyRead 的 fork）。結合論文探索、候選清單、閱讀看板、閱讀路徑、心智圖與原文／譯文並排的 PDF 精讀，可接雲端或本地模型。MIT 授權；提供 Windows、Linux 與 Docker 版。

可以做到：
- 依主題或會議／期刊找論文，並整理成待讀清單與看板。
- 為論文產生摘要、心智圖與有順序的閱讀路徑。
- 用中英對照與 AI 標註輔助精讀英文論文。
- 注意：macOS 沒有桌面版；AI 只整理已搜尋到的論文。

## 怎麼挑

- **想學容器與 K8s**：Learn Docker and K8s。
- **已經在用 coding agent，想讓它更可靠**：Learn Harness Engineering。
- **想要一整學期、有系統的大學課程，或想自己從零寫 agent**：EECS 498 AASE。
- **想知道 LLM 內部怎麼運作（可解釋性入門）**：50 ML Projects to Understand LLMs。
- **要讀學術論文、想要繁體中文輔助**：PaperRead。
