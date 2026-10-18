# Kit USD Agents

- **分類**：3D 建模與生成 / OpenUSD / Omniverse × Agent
- **連結**：https://github.com/NVIDIA-Omniverse/kit-usd-agents

## 原清單說明

用白話編輯 Omniverse 的 USD 場景，另附 Kit 與 Isaac Sim 的 MCP 伺服器。

> **查證補充**：大致正確，但 MCP 伺服器的用途需要更正。用白話編輯 USD 場景的是 repo 裡的 **Chat USD** 擴充套件（在 Omniverse Kit 內執行的 AI 助理）。repo 另附的 **4 個** MCP 伺服器（USD Code、Kit、OmniUI、Isaac Sim，不只 Kit 與 Isaac Sim）是給 Claude、Cursor 等 AI 程式助理用的**開發文件與 API 知識庫**（語意搜尋擴充套件、API 文件、程式範例、設定），**不會**操作或控制正在執行的 Kit／Isaac Sim 場景。要讓 AI 直接操控 Isaac Sim 場景，需另找其他專案。

## 概述

NVIDIA Omniverse 官方的「建構 Omniverse Kit USD agent 的基礎 repo」，包含兩類工具：

1. **Chat USD**：在 Omniverse Kit 內執行的多 agent AI 助理，能用自然語言產生並執行 USD Python 程式碼、搜尋 USD 素材、分析目前場景、即時修改場景；另有實驗性的 **Stage Builder**，以規劃 agent 分步驟搭建整個場景（如「做一間有家具的客廳」）。
2. **MCP 伺服器**：4 個獨立的 MCP 伺服器，讓 AI 程式助理在寫 OpenUSD、Kit 擴充套件、OmniUI 介面、Isaac Sim 程式時，能查到正確的 API 與範例。

截至 2026-10-18：Apache-2.0 授權、約 111 顆星、主要語言 Python，版本 1.5.3（2026-09-03），最近一次推送為 2026-10-13。README 註明目前**不接受外部貢獻**。

## 核心功能／特色

**Chat USD（Kit 擴充套件）**

- **USD 程式碼生成與執行**：依自然語言產生 USD Python 程式碼並在場景中執行，自動驗證與修正錯誤。
- **素材搜尋**：用對話搜尋 USD 素材並預覽、匯入場景。
- **場景分析**：回答目前場景的結構、物件屬性等問題。
- **omni.ui 介面生成**（omni.ui 版本）：用對話產生互動 UI 元件。
- **可擴充**：可自訂 agent、修改系統提示詞，加入專門能力。
- **Stage Builder**（實驗性）：Supervisor + Planning + USD Code + Scene Info + USD Search 多 agent 協作，先產生高階計畫再逐步執行。

**MCP 伺服器**

| 伺服器 | 工具數 | 內容 | 預設埠 |
| --- | --- | --- | --- |
| USD Code MCP | 7 | 瀏覽 USD 模組與類別、類別／方法 API 文件、語意搜尋程式範例、USD 知識庫 | 9903 |
| Kit MCP | 12 | 搜尋 400+ 個 Kit 擴充套件、擴充套件 API 與相依關係、程式範例與測試模式、Kit 文件與設定 | 9902 |
| OmniUI MCP | 10 | UI 類別與方法、元件文件與範例、視窗樣式範例、樣式文件、scene 系統 API | 9901 |
| Isaac Sim MCP | 5 | 搜尋 Isaac Sim 擴充套件與 API、語意搜尋程式範例、文件與最佳實務、設定 | 9904 |

## 技術架構或運作原理

- **Chat USD** 建構於 NVIDIA 的 LC Agent 框架（LangChain 系）：`ChatUSDNetworkNode` 為入口，`ChatUSDSupervisorNode` 判斷意圖後，把子任務分派給 `USDCodeInteractiveNetworkNode`（產生並執行程式碼）、`USDSearchNetworkNode`（素材搜尋）、`SceneInfoNetworkNode`（場景資訊）等專門 agent，再整合回應。
- Chat USD App 建構於 Omniverse Kit SDK（`kit-kernel` 110.1.1），由 repo 的 packman 工具自動下載。Stage Builder 文件範例使用 build.nvidia.com 上的 `meta/llama-4-maverick` 模型。
- **MCP 伺服器**建構於 NVIDIA NeMo Agent Toolkit（AIQ／NAT），以 FAISS 向量索引 + BM25 混合檢索，再經 NVIDIA reranker 重新排序；支援 MCP 協定 `2025-11-25`。索引資料以 Git LFS 存放。
- 預設使用 NVIDIA 雲端的 embedding 與 reranker 服務（需 `NVIDIA_API_KEY`，不需本機 GPU）；也可用 NIM 容器在本機部署（需 2 張 NVIDIA GPU 與 `NGC_API_KEY`）。

## 安裝與使用方式

前置需求：[NVIDIA API Key](https://build.nvidia.com/)、Docker（建議）或 Python 3.11+ 與 Poetry、Git LFS。

**MCP 伺服器（Docker，一次啟動全部）**：

```bash
git clone https://github.com/NVIDIA-Omniverse/kit-usd-agents.git
cd kit-usd-agents/source/mcp
export NVIDIA_API_KEY=你的金鑰
./build-wheels.sh all
docker compose -f docker-compose.ngc.yaml up --build
```

**MCP 伺服器（純 Python，單一伺服器）**：

```bash
git lfs install && git lfs pull      # 少了這步，搜尋工具會回報 Extension data is not available
cd source/mcp && cp .env.example .env   # 填入 NVIDIA_API_KEY
cd usd_code_mcp
./setup-dev.sh
./run.sh                             # http://localhost:9903/mcp
```

接著在 Claude Code、Cursor 等 MCP 用戶端加入對應的 HTTP 端點（如 `http://localhost:9903/mcp`）。

**Chat USD（在 Omniverse Kit 中執行）**：

```bash
# Linux
./build.sh -r
./_build/linux-x86_64/release/omni.app.chat_usd.sh
# Windows
build.bat -r
_build\windows-x86_64\release\omni.app.chat_usd.bat
```

Stage Builder 範例提示：「Create a living room with furniture」、「Build a conference room setup」。

## 適用情境

- 在 Omniverse 中用對話搭建、修改 OpenUSD 場景（工廠、室內、數位分身原型）。
- 讓 Claude Code、Cursor 寫 Kit 擴充套件、OmniUI 介面、Isaac Sim 腳本時，少產生不存在的 API（降低幻覺）。
- 作為參考範本，開發自家的 Omniverse／USD 專用 agent。

## 授權與成本

- **授權**：Apache-2.0（本 repo 原始碼）。第三方相依套件列於 `3RD_PARTY.md`。
- ⚠️ 建置 Chat USD 時下載的 **Omniverse Kit SDK 不在 Apache-2.0 範圍內**，適用 NVIDIA 自家的授權條款；Kit SDK 的具體授權條款本次未查閱，資料不足。
- **成本**：程式免費；需 NVIDIA API Key（build.nvidia.com）呼叫雲端 LLM、embedding 與 reranker，免費額度與計費方式依 NVIDIA 當時政策，資料不足。本機部署 NIM 需自備 2 張 NVIDIA GPU。

## 限制與注意事項

- MCP 伺服器只提供**文件與程式範例檢索**，不會連線到執行中的 Kit 或 Isaac Sim，也無法直接修改場景。
- Chat USD 需在 Omniverse Kit 環境中執行，建置流程（packman、premake）較重，且需要能跑 Kit 的 NVIDIA GPU 環境（具體硬體需求資料不足）。
- 必須安裝 Git LFS，否則索引檔只是指標檔，伺服器能啟動但搜尋會失敗。
- 沒有有效的 `NVIDIA_API_KEY` 時，Isaac Sim 搜尋會直接回錯誤（最新 CHANGELOG），不再退回純關鍵字搜尋。
- Stage Builder 仍屬初期藍圖，「智慧擺放（含碰撞偵測與風格比對）」為未來功能。
- 專案不接受外部貢獻。

## 相關工具

- 同資料夾：[USD BRep](USD-BRep.md)（同為 NVIDIA Omniverse 開源，OpenUSD 精確實體建模）、[3D Gaussian Splatting for model city](3D-Gaussian-Splatting-for-model-city.md)（把 3DGS 場景放進 Isaac Sim）、[MCP for Blender](MCP-for-Blender.md)（Blender 版的 AI 場景操作）
- [OpenUSD](https://openusd.org/)、[NVIDIA Omniverse](https://www.nvidia.com/omniverse/)、[NeMo Agent Toolkit](https://github.com/NVIDIA/NeMo-Agent-Toolkit)

## 資料來源

- 原清單來源：Threads @davepoon128 貼文 https://www.threads.com/@davepoon128/post/DenVxBCkyaN
- https://github.com/NVIDIA-Omniverse/kit-usd-agents （README）
- https://github.com/NVIDIA-Omniverse/kit-usd-agents/blob/main/QUICKSTART.md （純 Python 安裝、各伺服器埠號）
- https://github.com/NVIDIA-Omniverse/kit-usd-agents/blob/main/CHANGELOG.md 、VERSION.md （版本 1.5.3）
- https://github.com/NVIDIA-Omniverse/kit-usd-agents/tree/main/source/extensions/omni.ai.chat_usd.bundle/docs （Chat USD 架構）
- https://github.com/NVIDIA-Omniverse/kit-usd-agents/tree/main/source/extensions/omni.ai.nat.stage_builder/docs （Stage Builder）
- https://github.com/NVIDIA-Omniverse/kit-usd-agents/blob/main/source/mcp/isaacsim_mcp/README.md （Isaac Sim MCP）
- https://api.github.com/repos/NVIDIA-Omniverse/kit-usd-agents （授權、星數、推送日期）
