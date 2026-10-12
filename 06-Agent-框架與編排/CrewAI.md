# CrewAI

- **分類**：Agent 框架與編排 / 框架
- **連結**：https://github.com/crewAIInc/crewAI

## 原清單說明

多 agent 角色協作框架。（原放在 Video，已移到這裡）

> 查證結果：與 README 相符。官方描述為「用於編排角色扮演式自主 AI agents 的框架」，是開源 Python 多 agent 自動化框架；本身與影片生成無關，移至「Agent 框架與編排」分類是正確的。

## 概述

CrewAI 是一個開源 Python 框架，同時提供高階抽象與低階 API，用於建構可上線的多 agent 工作流程。它有兩個互補核心：**Crews**（具自主性、以角色分工協作的 agent 團隊）與 **Flows**（事件驅動、可精確控制流程的工作流）。README 稱其為獨立框架，擁有自己的 agents、tasks、crews、flows、tools 與編排原語。

GitHub 數據（2026-10-13 透過 GitHub API 查得）：約 6.0 萬顆星，主要語言 Python，建立於 2023-10-27，最新 Release 為 **1.15.27**（2026-10-09）。README 宣稱已有超過 10 萬名開發者透過其社群課程（learn.crewai.com）取得認證。

## 核心功能／特色

- **Crews**：以 role（角色）、goal（目標）、backstory（背景）、tools、LLM 定義 agent，並以 Task 指派工作；支援 agent 間自主決策、動態委派與協作。
- **Process**：`sequential`（依序）與 `hierarchical`（自動指派 manager agent 負責規劃、委派與驗證結果）。
- **Flows**：以 `@start`、`@listen`、`@router` 裝飾器建立事件驅動流程，搭配 Pydantic 結構化 state，支援條件分支與 `or_`／`and_` 邏輯組合；可在 Flow 步驟中呼叫 Crew。
- **Agent 能力**：工具、記憶（memory）、知識（knowledge）、checkpointing、非同步執行、人類介入（human input）、結構化輸出（`output_pydantic`、`output_json`）、guardrails。
- **協定支援**：MCP 與 A2A。
- **模型連接**：預設使用 OpenAI API，也可連接其他供應商與本地模型（如 Ollama、LM Studio）。
- **AI coding agent 技能**：官方提供 CrewAI Skills（`getting-started`、`design-agent`、`design-task`、`ask-docs`），可裝進 Claude Code、Cursor、Codex 等。

## 技術架構或運作原理

- 新版專案為「JSON-first」：`crewai create crew` 產生 `agents/*.jsonc`（每個 agent 一檔）、`crew.jsonc`（tasks、process、inputs 預設值），以及 `knowledge/`、`skills/`、`tools/` 目錄；`crewai run` 直接載入 JSON 定義執行。
- 舊式（`--classic`）結構則為 `crew.py` + `config/agents.yaml` + `config/tasks.yaml`。
- 文字中可用 `{placeholder}` 參數，於 `crew.jsonc` 的 `inputs` 設預設值，執行時缺值會提示輸入。
- 任務可透過 `context` 引用前一任務的輸出，形成資料流；Flow 層則負責確定性的控制邏輯與狀態管理。

## 安裝與使用方式

需求：Python **>=3.10 且 <3.14**；使用 uv 管理相依。

```bash
# 安裝 uv（macOS/Linux）
curl -LsSf https://astral.sh/uv/install.sh | sh

# 安裝 CrewAI CLI
uv tool install crewai
uv tool list                      # 驗證安裝

# 建立並執行專案
crewai create crew latest-ai-development
cd latest_ai_development
crewai install
crewai run
```

執行前需在 `.env` 填入模型供應商 API key；若使用網路搜尋工具 SerperDevTool，需設定 `SERPER_API_KEY`。Windows 上若遇 `chroma-hnswlib` 編譯錯誤，需安裝 Visual Studio Build Tools（C++ 桌面開發）。

Python 程式碼範例（節錄自 README）：

```python
from crewai import Crew, Agent, Task, Process
analyst = Agent(role="Senior Market Analyst", goal="...", backstory="...")
task = Task(description="Analyze {sector} sector data", expected_output="...", agent=analyst)
crew = Crew(agents=[analyst], tasks=[task], process=Process.sequential, verbose=True)
crew.kickoff(inputs={"sector": "tech"})
```

## 適用情境

- 需要多步驟、多專家角色分工的任務（研究 → 分析 → 撰寫報告）。
- 想把自主 agent 行為包在確定性、事件驅動的業務流程中。
- 從原型到上線不想更換框架的團隊。
- 官方範例：落地頁產生器、旅遊規劃、股票分析、職缺描述撰寫（見 crewAI-examples repo）。

## 授權與成本

- 授權：**MIT**。
- 開源框架免費；執行成本主要來自 LLM 與外部工具 API。
- 商業版 **CrewAI AMP Suite** 提供託管部署、可觀測性、治理、安全與企業支援，支援雲端與地端部署；其中 Crew Control Plane 可免費試用（app.crewai.com）。AMP 的具體價格**資料不足**。

## 限制與注意事項

- **遙測**：預設蒐集匿名使用資料（CrewAI／Python 版本、作業系統、agent 與 task 數量、process 類型、是否使用 memory／delegation、所用 LLM、agent 角色、工具名稱等），官方稱不蒐集 prompt、任務描述、API 回應等內容；若開啟 `share_crew=True` 則會分享詳細執行資料（goal、backstory、context、output）。
- Python 版本上限為 3.13。
- 新舊專案結構（JSON-first vs. classic YAML）並存，參考舊教學時需注意差異。
- 多 agent 自主協作會增加 LLM 呼叫次數與成本，且輸出不確定性較高。
- 「100,000+ 認證開發者」「High Performance」等為官方自述。

## 相關工具

- LangGraph、AutoGen、OpenAI Agents SDK（同類多 agent 框架，本次未逐一查證）
- [DSPy](./DSPy.md)（偏向程式化最佳化 LLM 管線）
- [agency-agents](./agency-agents.md)（角色人設集合，可作為 agent backstory 參考）
- crewAI-examples、crewAIInc/skills（官方範例與技能 repo）

## 資料來源

- https://github.com/crewAIInc/crewAI （README）
- https://api.github.com/repos/crewAIInc/crewAI
- https://api.github.com/repos/crewAIInc/crewAI/releases/latest
