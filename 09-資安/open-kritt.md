# open-kritt

- **分類**：資安 / 程式碼漏洞研究 / 弱點掃描
- **連結**：https://github.com/Kritt-ai/open-kritt

## 原清單說明

原清單只列名稱「open-kritt」，沒有連結或說明。

> **查證結果**：GitHub 上有多個同名 repo，但都是 fork；原始專案為 `Kritt-ai/open-kritt`，本條目以它為準。README 自述為「Orchestrate AI agents to find real vulnerabilities in code」，是自架的 AI 漏洞研究平台。

## 概述

open-kritt（README 寫作 open·kritt）是開源、自架的程式碼漏洞研究平台。它不叫單一模型一次審完整個 repo，而是把研究拆成許多小而明確的任務，平行分派給 AI agent 執行，再把結果彙整成可驗證、可排序的發現（findings）。

README 表示，Kritt 團隊以研究者名義「Blockian」累積超過 150 萬美元的漏洞賞金，open-kritt 是其內部系統的開源精簡版；此說法為專案自述，未獨立查證。專案由 Harel Rom 與 Gabriel Balko 共同維護。

查閱時 GitHub 頁面顯示約 2.3k stars、392 forks。

## 核心功能／特色

依 README：

- **任務拆解與工作流程**：把漏洞研究拆成小任務，串成可重複使用的 workflow
- **平行 agent 執行**：多個 agent 同時處理不同任務，最後合併輸出
- **Post-script 驗證**：以後處理腳本確認問題、建立 PoC、產生報告
- **排序與去重**：自訂嚴重度 ranker、統一的 finding schema、自動去除重複
- **可分析遠端或本機 repo 及其相依套件**；私有 repo 需提供 `GITHUB_TOKEN`
- **匯出**：掃描結果可下載為 ZIP（附可分享的 manifest）；中止或失敗的掃描會標示為部分匯出
- **Headless 模式**：`./kritt-headless` 可在無桌面的伺服器上匯入 workflow、post-script、skill、ranker（JSON），建立掃描、查看狀態並匯出；但不會在終端機顯示發現內容

## 技術架構或運作原理

- **Agent 後端**：Codex、Claude Code、Grok Build
- **模型存取**：Codex 登入，或 OpenAI、Anthropic、DeepSeek、OpenRouter、xAI 的 API
- **元件**：`backend`、`frontend`、`engine`、`database`、`executor-view`、`docs-site` 等目錄，以 Docker Compose 啟動
- **執行環境**：需要工具的 agent 在一次性 Docker job container 中執行；README 說明這些 agent 以 **root** 身分執行、擁有可寫的 repo 副本與**直接網路存取**，以便安裝工具、編譯目標與建立 PoC

## 安裝與使用方式

需求：Git、Docker（含 Docker Compose）、Node.js 20+。

```bash
git clone https://github.com/Kritt-ai/open-kritt
cd open-kritt
./kritt setup   # 互動式設定模型存取
./kritt start
```

接著開啟 `http://localhost:5173`。

文件站預覽：`npm install -g mint && cd docs-site && npm run dev`（`http://localhost:3001`）。

## 適用情境

- 漏洞賞金（bug bounty）研究者對授權範圍內的開源程式碼做大規模審查
- 資安團隊對自家程式碼與相依套件做 AI 輔助的程式碼審計
- 研究如何把漏洞研究流程拆解成可重複的 agent 工作流程

## 授權與成本

- **授權**：AGPL-3.0。修改後以網路服務形式提供，也必須公開原始碼。
- **成本**：軟體免費；需自備模型存取（Codex 訂閱或各家 API 費用）。

## 限制與注意事項

- **無應用層認證**：預設 port 綁在 `127.0.0.1`，後端沒有登入機制，切勿暴露到外部網路。
- **Agent 權限大**：job container 內以 root 執行且可連網。README 建議在專用 Docker 主機或 VM 上執行，掃描不受信任的程式碼前先閱讀 `docs/threat-model.md`。
- **程式碼外流**：被掃描的程式碼會送到所選的 LLM 服務，私有或客戶程式碼需確認合約允許。
- README 沒有提供基準測試或準確率數據；AI 發現的漏洞仍需人工驗證。
- 只審查有權審查的程式碼。

## 相關工具

- [Pentest Swarm AI](./Pentest-Swarm-AI.md)：以 agent swarm 進行黑箱滲透測試（同為 AGPL-3.0）
- [Foundry Security Spec](./Foundry-Security-Spec.md)：Cisco 的 agentic 安全評估系統規格，設計理念相近（拆角色、驗證、去重）
- [Pentest Copilot](./Pentest-Copilot.md)：AI 滲透測試 agent

## 資料來源

- https://github.com/Kritt-ai/open-kritt
- https://github.com/Kritt-ai
