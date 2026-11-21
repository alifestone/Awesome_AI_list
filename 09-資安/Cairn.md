# Cairn

- **分類**：資安 / 滲透測試（通用 AI 狀態空間搜尋引擎，首先用在自主滲透測試與 CTF）
- **連結**：https://github.com/oritera/Cairn

## 原清單說明

（使用者新增，無原清單說明。）

## 概述

Cairn 自稱「通用問題求解引擎」：只要有明確的起點（例如目標 IP）、明確的成功條件（拿到 shell、取得 flag），中間路徑未知，就把它當成在未知狀態空間裡找路。它沒有預先定義的角色或工作流程。目前驗證過的領域是 AI 自主滲透測試。

作者團隊在騰訊雲黑客松「AI 滲透測試挑戰賽」第二屆（610 隊）解出全部 54 題，README 說他們是唯一全解的隊伍，最終排名第 3。

查閱時 GitHub 顯示約 5.6k stars、1.2k forks，主要語言 Python。

## 核心功能／特色

- **黑板架構**：所有 agent 只透過一張共享的「事實－意圖圖」協作（stigmergy），彼此不直接溝通
- **三種基本元素**：
  - **Fact**：已確認的客觀發現
  - **Intent**：宣告要探索、還沒執行的方向
  - **Hint**：人類隨時可以注入的判斷，agent 下一次讀圖時就會吸收
- **沒有固定角色**：任務在執行時依圖的當前狀態產生，同一個 Worker 執行所有任務類型
- **不需領域工具**：README 說比賽時沒用任何 MCP 工具、RAG 或預設 agent 角色
- **Worker 後端**：Claude Code、Codex、Pi，可設定優先順序與並行上限

## 技術架構或運作原理

三種任務，都由同一種 Worker 執行：

| 任務 | 做什麼 | 產出 |
|------|--------|------|
| **Bootstrap** | 專案開始時先嘗試直接解題 | Fact，可能直接完成 |
| **Reason** | 讀整張圖：目標達成了嗎？接下來探索什麼？ | 完成／新 Intent（每次上限可設，預設 2）／不動作 |
| **Explore** | 認領一個 Intent，實際探索並回報 | 一個 Fact |

Worker 跑 OODA 迴圈（觀察整張圖 → 判斷現況 → 決定意圖 → 行動），結果寫回成新的 Fact，圖從 origin 往 goal 長。

元件分工：

- **Cairn Server**：只負責維持圖的一致性（預設 port 8000）
- **Cairn Dispatcher**：讀圖、排程任務、啟動與回收 Worker 容器，是唯一寫入協定的元件
- **Worker 容器**：每個專案一個容器，裡面同時跑多個 agent worker；worker 只收 prompt、回傳結構化輸出
- **本機模式**：worker 也可以直接在 dispatcher 主機上跑，沿用已登入的 `claude`／`codex`／`pi` CLI，不需 Docker、設定檔不需 API key

## 安裝與使用方式

需求：macOS 或 Linux、Python ≥ 3.12；容器模式需要 Docker。

```bash
docker pull --platform=linux/amd64 ghcr.io/oritera/cairn-worker-container:latest
cp dispatch.example.yaml dispatch.yaml   # 填入 LLM 端點與 API key

# Docker Compose（建議）
docker pull ghcr.io/astral-sh/uv:python3.13-trixie
docker compose up --build

# 或手動
uv run --project cairn cairn serve
uv run --project cairn cairn dispatch --config dispatch.yaml
```

本機模式（不用 Docker）：

```bash
cp dispatch.local.example.yaml dispatch.yaml   # runtime.execution: local
uv run --project cairn cairn serve
uv run --project cairn cairn dispatch --config dispatch.yaml
```

測試：`uv run --project cairn --group dev pytest`（不需 Docker 或模型端點）。

## 適用情境

- 已取得授權的黑箱滲透測試、CTF 解題
- 研究多 agent 透過共享黑板協作、沒有固定角色的架構
- 其他「起點與目標明確、路徑未知」的問題，例如漏洞研究（作者也提到數學證明，但目前只在滲透測試上驗證過）

## 授權與成本

- **授權**：AGPL-3.0（README 寫「供個人與教育用途」）。商業或專有環境若不想受 AGPL 約束，需向作者取得商業授權；送 PR 即同意貢獻內容可用於 AGPL 與商業授權兩者。
- **成本**：開源免費，需自付 LLM 費用（或使用已訂閱的 Claude Code／Codex 等 CLI）。

## 限制與注意事項

- **僅限授權測試**：README 免責聲明要求只在明確授權的環境使用，未經許可的測試可能違法。
- **本機模式沒有沙箱**：agent 以你的使用者權限直接在主機上執行，README 也要求不要在 Docker 裡跑 dispatcher。建議用專用機器或 VM。
- 預設容器設定使用 `network_mode: host`。
- 比賽成績為專案自述；README 也說系統賽前從未測試過，整條流程在比賽當天凌晨 4 點才第一次跑通。
- 「通用問題求解」目前是方向，除了滲透測試之外還沒有公開的驗證結果。
- 延伸閱讀（賽後檢討、設計理念）都是中文微信公眾號文章。

## 相關工具

- [Pentest Swarm AI](./Pentest-Swarm-AI.md)：同樣用共享黑板協作的多 agent 滲透測試，但有固定的 recon／exploit 等角色
- [ARTEX](./ARTEX.md)：另一個中國 AI 攻防比賽的冠軍專案（規劃者／執行者分工）
- [PentestCode](./PentestCode.md)、[Pentest Copilot](./Pentest-Copilot.md)：其他自主滲透測試 agent

## 資料來源

- https://github.com/oritera/Cairn
- https://github.com/oritera/Cairn/blob/main/dispatch.example.yaml
