# AnythingLLM

- **分類**：Agent 框架與編排 / 知識庫 / 文件問答
- **連結**：https://github.com/Mintplex-Labs/anything-llm

## 原清單說明

一體化本地 LLM 應用：文件 RAG 對話、agent，可接各家模型。

> 查證結果：與 README 相符。官方定位為「all-in-one AI app」，可與文件對話（RAG）、使用 AI Agents、多使用者，預設在本機執行；另提供桌面版（Mac / Windows / Linux）、Docker 自架版與 Android 行動版。

## 概述

AnythingLLM 由 Mintplex Labs 開發，目標是讓使用者建立私有、功能完整的「自己的 ChatGPT」：接上本地或雲端 LLM、匯入文件即可開始對話，內建 agents、多使用者、向量資料庫與文件處理管線，強調「零設定摩擦」與 local-first。

GitHub 數據（2026-10-13 透過 GitHub API 查得）：約 6.7 萬顆星，主要語言 JavaScript，最新 Release 為 **v1.17.0**（2026-10-01）。

## 核心功能／特色

- **文件 RAG 對話**：支援 PDF、TXT、DOCX 等多種格式，拖放上傳、回答附來源引用；針對大型文件集合有內建最佳化。
- **AI Agents**：工作區內的 agent（可瀏覽網頁等）、自訂 AI Agents、**無程式碼 Agent Builder（Agent Flows）**、**MCP 相容**。
- **Intelligent Skill Selection**：宣稱可啟用不限數量的工具，同時每次查詢最多減少約 80% token 用量（官方說法）。
- **Dynamic Model Routing**：依自訂規則把對話自動路由到最適合的供應商與模型。
- **記憶**：自動與使用者管理的 Memories。
- **排程任務**：以 cron 排程執行具完整 agent 能力的定期任務。
- **多模態**：支援開源與閉源 LLM 的多模態。
- **多使用者與權限**、**可嵌入網站的聊天 widget**（兩者皆僅 Docker 版）。
- **完整 Developer API**、Chrome 瀏覽器擴充套件。
- **語音**：內建音訊轉錄；TTS 支援瀏覽器內建、Piper（瀏覽器內執行）、OpenAI TTS、ElevenLabs 與 OpenAI 相容 TTS。

### 支援的模型與元件（節錄自 README）

- **LLM**：任何 llama.cpp 相容開源模型、OpenAI、Azure OpenAI、AWS Bedrock、Anthropic、NVIDIA NIM、Google Gemini、Ollama、LM Studio、LocalAI、Together AI、Fireworks AI、Perplexity、OpenRouter、DeepSeek、Mistral、Groq、Cohere、KoboldCPP、LiteLLM、Text Generation Web UI、xAI、Moonshot AI、Microsoft Foundry Local、Lemonade（AMD）、Cerebras 等數十家。
- **Embedder**：內建 Native Embedder（預設）、OpenAI、Azure、Gemini、Ollama、LM Studio、Cohere、Voyage AI、Mistral 等。
- **向量資料庫**：LanceDB（預設）、PGVector、Astra DB、Pinecone、Chroma、Weaviate、Qdrant、Milvus、Zilliz。

## 技術架構或運作原理

Monorepo 分為六部分：

- `frontend`：Vite + React 前端，用於管理內容。
- `server`：Node.js Express 伺服器，負責所有互動、向量資料庫管理與 LLM 呼叫。
- `collector`：Node.js Express 伺服器，處理並解析從 UI 上傳的文件。
- `docker`：Docker 建置與部署說明。
- `embed`：網頁嵌入 widget（子模組）。
- `browser-extension`：Chrome 擴充套件（子模組）。

運作流程為：collector 解析文件 → server 以 embedder 向量化並存入向量資料庫 → 對話時檢索相關片段並交給所選 LLM 生成回答（RAG）。

## 安裝與使用方式

- **桌面版**：至 https://anythingllm.com/download 下載（macOS / Windows / Linux）。
- **Docker（Linux/macOS）**：

```bash
docker pull mintplexlabs/anythingllm
export STORAGE_LOCATION=$HOME/anythingllm && \
mkdir -p $STORAGE_LOCATION && \
touch "$STORAGE_LOCATION/.env" && \
docker run -d --rm -p 3001:3001 \
--cap-add SYS_ADMIN \
-v ${STORAGE_LOCATION}:/app/server/storage \
-v ${STORAGE_LOCATION}/.env:/app/server/.env \
-e STORAGE_DIR="/app/server/storage" \
mintplexlabs/anythingllm
```

  映像檔支援 amd64 與 arm64；啟動後於 `http://localhost:3001` 使用。官方建議把儲存目錄掛載到主機，以便升級時保留資料。

- **雲端一鍵部署**：README 提供 AWS、GCP、DigitalOcean、Render、Railway、Elestio、Northflank、Sealos、Easypanel 等範本；也可不用 Docker 裸機部署（`BARE_METAL.md`）。
- **開發模式**：`yarn setup` → 填好 `server/.env.development` → `yarn dev:server`、`yarn dev:frontend`、`yarn dev:collector`。

## 適用情境

- 想在本機私密地與內部文件對話、不想把資料送到第三方。
- 團隊自架多使用者知識庫／聊天介面（Docker 版）。
- 需要在同一介面切換多家模型、或結合 MCP 工具與排程 agent 的使用者。
- 在網站嵌入客服式聊天 widget。

## 授權與成本

- 授權：**MIT**。
- 桌面版：官網標示免費下載，並稱「No accounts, no API keys, no token limits」（使用本地模型時）。
- 若接雲端模型，費用依各供應商計費。
- 官方另有 Hosted Instance／Cloud（團隊用）選項，但官網首頁未列方案名稱與價格 —— **資料不足**。

## 限制與注意事項

- **遙測**：預設蒐集匿名使用資料（安裝類型、文件新增／刪除事件、向量資料庫類型、LLM 供應商與模型、送出對話事件；官方稱不含內容與 IP），供應商為 PostHog。可於 `.env` 設 `DISABLE_TELEMETRY="true"` 或在 App 側欄 Privacy 關閉。
- 關閉遙測後仍可能連線至 `cdn.anythingllm.com`（模型鏡像）與 GitHub（快取檔案）。
- 多使用者權限與嵌入 widget 僅 Docker 版提供。
- 在 Linux Docker 中存取主機上的服務（如本機 Chroma）需加 `--add-host=host.docker.internal:host-gateway`。
- 本地模型效果受硬體限制；「token 減少 80%」等數字為官方說法，未見獨立驗證。

## 相關工具

- Open WebUI、LibreChat、LM Studio、Ollama（類似的本地 LLM 介面／執行環境；Ollama、LM Studio 亦為其支援的後端）
- AnythingLLM Mobile（Android，開源）、AnythingLLM Browser Extension、AnythingLLM Embed
- [CrewAI](./CrewAI.md)、[DSPy](./DSPy.md)（偏開發者的程式化框架，對照用）
- [Cognee](cognee.md)：以知識圖譜＋向量做 agent 長期記憶的開源平台

## 資料來源

- https://github.com/Mintplex-Labs/anything-llm （README）
- https://api.github.com/repos/Mintplex-Labs/anything-llm
- https://api.github.com/repos/Mintplex-Labs/anything-llm/releases/latest
- https://raw.githubusercontent.com/Mintplex-Labs/anything-llm/master/docker/HOW_TO_USE_DOCKER.md
- https://anythingllm.com/
