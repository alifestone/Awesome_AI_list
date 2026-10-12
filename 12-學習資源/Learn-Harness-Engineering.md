# Learn Harness Engineering

- **分類**：學習資源
- **連結**：https://github.com/walkinglabs/learn-harness-engineering
- **課程網站**：https://walkinglabs.github.io/learn-harness-engineering/

## 原清單說明

從零到一的 Harness Engineering 課程：如何替 AI coding agent 打造可靠的工作環境（講義 + 實作專案）。

## 概述

以專案為主軸的入門課程，教你為 AI coding agent 建立「工作環境、狀態管理、驗證與控制機制」，讓 agent 能在真實程式庫中可靠地完成工作。課程的核心主張是：**模型不變，決定結果是否可靠的是 harness**；Harness Engineering 不是寫更好的 prompt，而是圍繞模型打造完整的工作環境。課程提供 15 種語言版本，包含繁體中文。

## 核心功能／特色

README 將 harness 拆為五個子系統：

1. **Instructions（指令）**：agent 要做什麼、順序為何、先讀哪些檔案。
2. **State（狀態）**：進度紀錄、功能清單、git 歷史等跨 session 保存在磁碟上的資訊。
3. **Verification（驗證）**：測試、lint、型別檢查、smoke run，作為「完成」的證據。
4. **Scope（範圍）**：一次只做一個功能，並清楚定義完成條件。
5. **Session lifecycle（工作階段生命週期）**：開始時初始化、結束時清理並留下重新啟動的路徑。

附加內容：

- **前沿 harness 設計拆解**：分析 Pi、Claude Code、Codex、DeepSeek 如何設計其 harness。
- **資源庫**：`AGENTS.md`、`feature_list.json`、`init.sh` 等範本。
- **Skill**：`skills/harness-creator`，可替你的專案搭建 harness 骨架。
- **工具**：`tools/audit-harness.sh`，零依賴的 shell 稽核腳本，對應 L03～L12 的檢查項目。

## 課程／教材結構

**講義（14 講）**

- L01 為什麼有能力的 agent 仍會失敗
- L02 harness 到底是什麼
- L03 為什麼程式庫必須是唯一事實來源（system of record）
- L04 為什麼單一巨大指令檔會失效
- L05 為什麼長時間任務會失去連續性
- L06 為什麼初始化需要獨立階段
- L07 為什麼 agent 會做過頭又做不完
- L08 為什麼功能清單是 harness 的基本元件
- L09 為什麼 agent 會過早宣告完成
- L10 為什麼端對端測試會改變結果
- L11 為什麼可觀測性應屬於 harness
- L12 為什麼每個 session 都必須留下乾淨狀態
- L13 Loop engineering（從 prompting 走向自動化迴圈）
- L14 Graph engineering（單一迴圈擴展為圖）

**實作專案（8 個）**：全部建立在同一個 Electron 應用（個人知識庫）上

- P01 基準 vs. 最小 harness
- P02 agent 可讀的工作區
- P03 多 session 連續性
- P04 增量索引（執行期回饋與範圍控制）
- P05 有依據的問答驗證
- P06 執行期可觀測性與除錯（capstone harness）
- P07 第一個自動化迴圈
- P08 把工作流程畫成圖

## 安裝與使用方式

快速上手：在你的專案加入四個起始檔案——`AGENTS.md`（或 `CLAUDE.md`）、`init.sh`、`feature_list.json`、`claude-progress.md`。

本地建置文件站（需 npm）：

```bash
npm install
npm run docs:dev        # 開發伺服器（hot reload）
npm run docs:build      # 正式建置
npm run docs:preview    # 預覽建置結果
npm run pdf:build       # 產生 PDF 講義到 artifacts/pdfs/
bash tools/audit-harness.sh /path/to/your/repo   # 稽核你的 repo 的 harness
```

前置知識：

- 必要：熟悉終端機、git 與本地開發；能用一種常見技術棧讀寫程式；基本除錯經驗；願意實際動手實作。
- 加分：Electron／桌面應用經驗、測試或 logging 背景、用過 coding agent。

## 適用情境

- 已在使用 Claude Code、Codex 等 coding agent，想讓 agent 在長任務、多 session 中更穩定的工程師。
- 研究 harness 設計的研究者或開發者。
- 評估「環境設計如何影響 agent 表現」的技術主管。

不適合（README 明列）：想要零程式碼 AI 入門的人、只關注 prompt 的人、不願讓 agent 在真實程式庫中工作的人。

## 授權與成本

- **MIT** 授權，課程免費。
- 實作需自備可編輯檔案、執行指令並處理多步驟任務的 IDE 或 CLI agent（README 點名 Claude Code、Codex；另提到 Codex、OpenHands、Antigravity 可使用進度檔）；這些工具本身的費用依各家而定。

## 限制與注意事項

- 實作專案以 Electron 應用為載體，不熟悉 Electron 者可能需要額外時間。
- 需要讓 agent 在真實程式庫中執行指令，應注意權限與資料安全。
- 課程網站以前端動態載入，直接抓取頁面可能看不到內容；繁體中文版在網站上的確切路徑本條目未能查證（資料不足），可從 GitHub README 的語言連結進入。

## 相關工具

- [Claude Code](https://github.com/anthropics/claude-code)、Codex：課程點名的 coding agent。
- [Learn Docker and K8s](https://github.com/ericboy0224/learn-docker-and-k8s)：本清單另一個以 AI 編輯器為核心的學習資源。

## 資料來源

- https://github.com/walkinglabs/learn-harness-engineering
- https://walkinglabs.github.io/learn-harness-engineering/
