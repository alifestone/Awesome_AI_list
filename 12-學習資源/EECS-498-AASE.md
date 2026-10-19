# EECS 498 AASE

- **分類**：學習資源 / 課程 / 教材
- **連結**：https://github.com/eecs498-aase/materials
- **課程網站**：https://eecs498-aase.github.io

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：repo 標語為 *Lecture and lab slides for EECS 498 AASE (Applied Agentic Software Engineering), UMich Fall 2026.* 是密西根大學（University of Michigan）2026 秋季的大學部課程 EECS 498-016 的公開教材，內容是投影片、demo 程式碼與一組 Agent Skills，不是軟體工具。repo 沒有附 LICENSE 檔。

## 概述

EECS 498 AASE（Applied Agentic Software Engineering，應用代理式軟體工程）是一門把「指揮 coding agent 寫程式」當成工程學科來教的課。課程網站的說法：整學期圍繞一個對象——coding agent——分三個角度：先用 agent 做出一個 agent、再把人從 agent 的迴圈中拿掉並量測哪裡壞掉、最後把它養成值得長期使用的助理。

三個階段（依課程網站）：

1. **Apply（第 1～6 週，L01～L06）**：用 Aider 規格化並實作一個 pair-programmer，從架構設計、規格、圖到實作與測試都要交。
2. **Analyze（第 4～7 週，L07～L14）**：直接呼叫 LLM API，自己寫工具呼叫與 agent 迴圈，再加上核准層（approval layer）、停止條件與評測套件。
3. **Create（第 8～15 週，L15～L28）**：替 agent 加上可讀的 wiki、設計 skill、強化防護與部署。

這個 repo 只放教材，投影片隨上課進度公開（查詢當下 2026-10-19 公開到 L14，最近一次更新 2026-10-15）。repo 於 2026-08-31 建立，查詢當下約 160 顆星。

## 核心功能／特色

- **投影片三種格式**：每講一個資料夾，含 `slides.md`（Slidev 原始碼）、`slides.pdf`、`slides.pptx`；`slides.md` 依賴 repo 外的主題，無法直接建置，但可閱讀、搜尋與重用內容。
- **可自己跑的 demo**：`demos/` 收錄上課 live demo 用的小型程式庫，每個附 README 與 `reset` 腳本，執行後會產生一份設定好、可直接交給 Aider 的拋棄式工作副本。
- **EGM 五個 Agent Skills**：`egm/` 把 Dave Rensin 的 Elephant-Goldfish Model 做成可安裝的 skill，並逐一拆解 skill 的設計：
  - `peanuts`：替大型程式庫由下而上產生每個目錄的 README，每一層都有人工審核關卡。
  - `elephant`：進行不寫程式的設計對話，產出四段式設計文件。
  - `goldfish`：把設計文件丟給三個全新、沒有上下文的 reviewer 平行審查，反覆修改到只剩小問題。
  - `egm-implement`：只實作設計文件列出的檔案，現實與文件不一致時停下。
  - `mean-review`：用腳本強制的四種掃描嚴格審查 diff。
- **核心觀念**：「Big Three」（context、model、prompt）診斷框架；把模型視為設定而非廠商，並自行部署模型。

## 課程／教材結構

**講義（查詢當下已公開）**

- L01 課程介紹與 AI coding 現況
- L02 LLM 如何寫程式（底層機制）
- L03 Big Three：Context、Model、Prompt
- L04 規格驅動開發（Spec-Driven Development）
- L05 現代 agentic CLI
- L06 從結對寫程式到 agent 編排
- L07 呼叫內部：messages、串流與工具呼叫
- L08 Hackathon 1 說明
- L09 停止條件與核准層
- L10 Skills 與 Elephant-Goldfish Model
- L11 Guardrails：錯誤、重試與核准關卡
- L13 瀏覽器擴充功能與可傳訊息的助理
- L14 Subagents

（L12 在 repo 中沒有資料夾。）

**實驗課**：Lab00（環境設定）、Lab01（Aider 如何運作）、Lab02、Lab03（從 Aider 開始）、Lab04（觸及電腦：Shell、MCP 與瀏覽器）。

**Demo**：`L01-notes-cli`（約 60 行、有兩個刻意缺陷的筆記 CLI）、`L03-transcript-analytics`、`L04-transcript-analytics`（同一程式加上 `spec.md` 規格）。

## 安裝與使用方式

只想拿投影片或 demo 時，用淺層 clone（repo 歷史大多是編譯後的投影片）：

```bash
git clone --depth 1 https://github.com/eecs498-aase/materials
cd materials/demos/L01-notes-cli
./reset          # 產生拋棄式工作副本，接著用 aider 操作
```

EGM skills 的安裝與用法從 `egm/README.md` 開始讀，作者建議先讀 Dave Rensin 的原文〈Elephants, Goldfish and the New Golden Age of Software Engineering〉。

課程網站示範以 `aider --model ollama/qwen3.5:9b` 在本機跑模型，強調只用一般筆電、不必額外花費。

## 適用情境

- 想系統化學習「怎麼指揮 coding agent」，而不只是零散技巧的工程師或學生。
- 想從零自己寫 tool-using agent（messages、工具呼叫、agent 迴圈、核准層、評測）的人。
- 想參考「設計文件先行、用無上下文 session 檢驗文件」工作流程的人，可直接拿 EGM skills 來用。
- 教學者想參考 AI 輔助軟體工程課程怎麼安排。

## 授權與成本

- repo **未附 LICENSE 檔**（資料不足）：預設著作權保留，重用投影片或程式碼前請先向課程確認。
- 教材免費公開；課程網站稱只需一般筆電、課程本身不需額外費用。若改用雲端 API 模型，費用依各家而定。

## 限制與注意事項

- 教材隨學期進度公開，Create 階段（L15～L28）查詢當下尚未釋出；README 說「缺的週次代表還沒上到」。
- 只有投影片與 demo，沒有上課錄影的說明（資料不足）；作業規格、評分與 Ed 討論區屬修課學生專用。
- `slides.md` 依賴 repo 外的 Slidev 主題，無法直接重新建置投影片。
- 教材為英文。
- 實作以 Aider 為主要工具，使用其他 coding agent 的人需自行對照。

## 相關工具

- [Aider](https://github.com/Aider-AI/aider)：課程前半主要使用的 coding agent。
- [Learn Harness Engineering](Learn-Harness-Engineering.md)：同樣教你讓 coding agent 更可靠，偏 harness 設計。
- [Learn Docker and K8s](Learn-Docker-and-K8s.md)：本清單另一個搭配 AI coding 工具的學習資源。

## 資料來源

- https://github.com/eecs498-aase/materials
- https://github.com/eecs498-aase/materials/blob/main/egm/README.md
- https://eecs498-aase.github.io
- https://drensin.medium.com/elephants-goldfish-and-the-new-golden-age-of-software-engineering-c33641a48874
