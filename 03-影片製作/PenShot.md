# PenShot

- **分類**：影片製作 / Agent 影片製作系統（劇本 → 分鏡提示詞）
- **連結**：https://pypi.org/project/penshot/
- **原始碼**：https://github.com/neopen/story-shot-agent
- **官網與文件**：https://shot.helpenx.com

## 原清單說明

（使用者提供連結，無附註說明）

> **查證結果**：PyPI 套件 `penshot`（中文名「剧本分镜智能体」），原始碼在 GitHub 的 neopen/story-shot-agent。它不產生影片，而是把劇本拆成鏡頭片段，輸出給 Sora、Veo、Runway、可靈等影片模型用的提示詞。MIT 授權。

## 概述

PenShot 是基於 LangGraph 的多 agent 系統，負責影片製作流程裡「劇本 → 分鏡」這一段。輸入電影、短劇、動漫或小說等任何格式的劇本，它會切出適合 AI 影片模型長度的鏡頭片段，替每段寫好中英雙語畫面提示詞、負面提示詞與音訊提示詞，並用記憶與向量檢索讓角色、服裝、場景在各片段之間保持一致。

GitHub repo 於 2025-10-23 建立，查詢當下（2026-10-14）約 220 顆星；PyPI 首版 0.2.1 發布於 2026-03-29，最新 0.3.10 發布於 2026-10-13，更新頻繁。作者為個人開發者（HiPeng／NeoPen）。

## 核心功能／特色

- **劇本解析**：辨識場景、對白與動作，可分段處理長文本。
- **時長規劃**：依鏡頭切分並分配秒數，配合影片模型的單段長度上限。
- **連續性守護**：短／中／長期三層記憶、Chroma 向量檢索、快照與 RAG，讓相鄰片段的角色狀態與場景一致；每個片段都能追溯回原劇本位置。
- **提示詞輸出**：每段有中英雙語畫面描述、負面提示詞、景別與鏡頭、風格，以及給 AudioLDM 等模型用的音訊提示詞（環境音、角色語音描述、情緒）。
- **輔助生成**：可產生角色三視圖、背景圖、關鍵幀。
- **多種整合方式**：Python SDK、REST API（FastAPI）、LangGraph 節點、A2A 協定、MCP server（工具 `breakdown_script`、`get_task_result`）。
- **LLM 可換**：OpenAI、Qwen、DeepSeek、Ollama 等。

## 技術架構或運作原理

LangGraph 工作流依序經過七個 agent：劇本解析 → 分鏡生成 → 影片分割 → 提示詞轉換 → 品質審查 → 連續性守護 → 輔助生成。每一步失敗時可重試、修復或轉人工介入。記憶層存在 Redis 與 Chroma。輸出是標準化 JSON（`fragments` 陣列，含 `prompt`、`negative_prompt`、`duration`、`model`、`style`、`audio` 等欄位），交給下游的影片模型與 FFmpeg 合成。

## 安裝與使用方式

```bash
pip install penshot   # Python 3.10+
```

`.env` 需設定 LLM、Embedding 模型與 Redis：

```properties
PENSHOT_LLM__DEFAULT__BASE_URL=https://dashscope-intl.aliyuncs.com/api/v1
PENSHOT_LLM__DEFAULT__API_KEY=sk-...
PENSHOT_LLM__DEFAULT__MODEL_NAME=qwen-plus
PENSHOT_EMBED__DEFAULT__MODEL_NAME=text-embedding-v4
PENSHOT_REDIS_URL=redis://:password@localhost:6379/0
```

```python
from penshot.api import create_penshot_agent

agent = create_penshot_agent(max_concurrent=5)
task_id = agent.breakdown_script_async("早晨，一個女孩在咖啡館讀書，陽光透過窗戶...")
result = await agent.wait_for_result_async(task_id)
```

也可以用 Docker（`docker compose up -d`，或 `neotems/penshot`、`ghcr.io/neopen/penshot` 映像），或啟動 MCP server：

```bash
python -m penshot.mcp_server --max-concurrent 5 --queue-size 500
```

## 適用情境

- 把短劇、小說改編劇本批次轉成可直接貼進 Sora／可靈／Veo 的分鏡提示詞。
- 當自建 AI 影片流水線的前段，接自己的生圖、生影片與剪輯工具。
- 讓 Claude Code 等 agent 透過 MCP 呼叫，先拆分鏡再交給其他影片工具。

## 授權與成本

- **授權**：MIT。
- **成本**：本身免費，但需要付費或自架的 LLM 與 Embedding 服務，以及一個 Redis。費用依劇本長度與所選模型而定。

## 限制與注意事項

- 只產生提示詞與結構化資料，**不會直接生成影片**；要成片還得自己串影片模型與剪輯。
- README 表示目前針對中文劇本深度優化，其他語言仍在改進。
- 只提供音訊提示詞，對嘴與環境音融合需要下游工具。
- 預設範例走阿里雲 DashScope；README 提醒需要穩定連線到外部 LLM API。
- 個人專案，版本仍在 0.x，API 可能變動。

## 相關工具

- [ViMax](ViMax.md)：從點子／劇本／小說直接做到成片的多 agent 系統
- [OpenDirector](OpenDirector.md)：自架 AI 影片工作室，內含分鏡 agent
- [AI video drama platform](AI-video-drama-platform.md)：同樣是「故事 → LLM 結構化分鏡」的早期實驗
- [CrewAI](../06-Agent-框架與編排/CrewAI.md)：另一種多 agent 框架

## 資料來源

- https://pypi.org/project/penshot/ （套件摘要、版本、Python 需求、MIT）
- https://pypi.org/pypi/penshot/json （首版與最新版發布日期）
- https://github.com/neopen/story-shot-agent （README：架構、使用方式、輸出格式、注意事項）
- https://api.github.com/repos/neopen/story-shot-agent （repo 中繼資料：建立日期、星數）
