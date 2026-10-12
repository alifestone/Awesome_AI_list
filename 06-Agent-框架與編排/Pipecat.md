# Pipecat

- **分類**：Agent 框架與編排 / 框架
- **連結**：https://github.com/pipecat-ai/pipecat

## 原清單說明

即時語音／多模態對話 agent 框架。（原放在 Video，已移到這裡）

> 查證結果：與 README 相符。官方描述為「用於建構即時語音與多模態對話 agent 的開源 Python 框架」，由 Daily 與社群維護。雖然支援視訊輸入輸出與數位人頭像服務，但本質是對話 agent 編排框架，移至「Agent 框架與編排」分類合理。

## 概述

Pipecat 是開源 Python 框架，用來把語音辨識（STT）、大型語言模型（LLM）、語音合成（TTS）、傳輸層等服務串成即時對話管線。可以只做單一語音 agent，也能建構多 agent 系統：各專家 agent 可交接（handoff）、平行展開（fan out），或透過共享 bus 協調，並可在本機或跨程序／跨機器分散部署。官方文件稱一般語音互動延遲可達 500–800ms。

GitHub 數據（2026-10-13 透過 GitHub API 查得）：約 1.6 萬顆星，主要語言 Python，建立於 2023-12-27，最新 Release 為 **v1.12.0**（2026-09-26）。

## 核心功能／特色

- **Voice-first**：整合語音辨識、語音合成與對話輪替處理。
- **可插拔服務**（節錄自 README）：
  - STT：AssemblyAI、AWS、Azure、Cartesia、Deepgram、ElevenLabs、Gladia、Google、Groq（Whisper）、OpenAI（Whisper）、Soniox、Speechmatics、Whisper（本地）等。
  - LLM：Anthropic、AWS、Azure、Cerebras、DeepSeek、Fireworks AI、Gemini、Grok、Groq、Mistral、NVIDIA NIM、Ollama、OpenAI（含 Responses）、OpenRouter、Perplexity、Qwen、Together AI 等。
  - TTS：Cartesia、Deepgram、ElevenLabs、Fish、Google、Hume、Inworld、Kokoro、MiniMax、OpenAI、Piper、Rime、XTTS 等。
  - Speech-to-Speech：AWS Nova Sonic、Azure Voice Live、Gemini Multimodal Live、Grok Voice Agent、OpenAI Realtime、Ultravox。
  - 傳輸：Daily（WebRTC）、LiveKit（WebRTC）、Vonage（WebRTC）、SmallWebRTCTransport、FastAPI WebSocket、WebSocket Server、WhatsApp；電話序列化器支援 Twilio、Telnyx、Plivo、Exotel、Genesys。
  - 視訊／頭像：HeyGen、Tavus、Simli、LemonSlice；記憶：mem0；視覺與影像：Moondream、fal、Google Imagen。
  - 音訊處理：Silero VAD、Krisp Viva、Koala、ai-coustics、RNNoise；監控：OpenTelemetry、Sentry。
- **Pipecat Flows**（已內建）：預先定義或動態的結構化對話路徑與狀態管理。
- **多 agent**：每條 pipeline 即一個 agent，可用 handoff、平行 fan-out、sidecar worker 或分散式部署組合。
- **生態系**：用戶端 SDK（JavaScript、React、React Native、Swift、Kotlin、C++、ESP32）、Pipecat UI（shadcn 元件庫）、Whisker（即時除錯器）、Tail（終端機儀表板）、Pipecat CLI（建專案、監控、部署）、Claude Code 用的 Pipecat Skills。

## 技術架構或運作原理

官方文件說明四個核心概念：

- **Frames（訊框）**：在應用中流動的資料封包，例如麥克風音訊、轉錄文字、LLM 回應、合成音訊。
- **Frame Processors（處理器）**：處理特定任務的積木，如 STT 處理器把音訊 frame 轉成文字 frame、LLM 處理器產生回應 frame、TTS 處理器轉回音訊 frame；不處理的 frame 會直接往下傳。
- **Pipelines**：把處理器串接起來，自動完成編排；frame 可往下游或上游流動。
- **Workers**：執行 pipeline 的單位；擁有 pipeline 的 worker 就是一個 agent（`PipelineWorker`），由 `WorkerRunner` 啟動並管理生命週期，多個 worker 可透過共享 bus 協調。

典型流程：使用者說話 → Transport 接收串流音訊並產生 audio frame → STT 即時轉錄 → Context 聚合器結合對話歷史 → LLM 串流生成 → TTS 轉語音 → Transport 傳回使用者。各階段以串流平行進行（LLM 還在產生後段內容時，前段已在合成並播放）。

## 安裝與使用方式

需先安裝 uv：

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

用 CLI 建立新專案（最快）：

```bash
uv tool install "pipecat-ai[cli]"
pipecat init               # 互動式建立電話或 web/行動 bot
pipecat init quickstart    # 依 quickstart 指南建立
```

手動安裝：

```bash
uv init my-pipecat-app && cd my-pipecat-app
uv add pipecat-ai
cp env.example .env
uv add "pipecat-ai[option,...]"   # 依需要加入第三方服務的額外相依
# 或使用 pip：pip install pipecat-ai / pip install "pipecat-ai[option,...]"
```

預設只安裝核心框架，第三方 AI 服務需以 extras 另外加入。範例程式：repo 內 `examples/`（單一概念範例）與 pipecat-examples repo（完整應用）。參與開發需 Python 3.11 以上（建議 ≥ 3.12）。

## 適用情境

- 語音助理、客服／電話接聽 bot、客戶資料收集等商業 agent。
- AI 陪伴、教練、會議助理、角色扮演角色。
- 多模態介面（語音 + 視訊 + 影像）、互動式說故事。
- 需要結構化對話流程的複雜對話系統。
- 多專家 agent 互相交接的語音系統。

## 授權與成本

- 授權：**BSD-2-Clause**。
- 框架免費；費用來自所接的 STT、LLM、TTS、傳輸（如 Daily、LiveKit、Twilio）等服務。
- 官方另有 **Pipecat Cloud**（在 Daily 託管區域執行 agent）與 **Pipecat Enterprise**（部署於自有 VPC），以及 Daily 提供的企業支援；其價格**資料不足**。

## 限制與注意事項

- 端到端延遲與語音品質高度取決於所選服務供應商與網路；「500–800ms」為官方文件的典型值。
- 需管理多家服務的 API key 與相依套件；部分 extras（如 local、gstreamer）需額外系統相依。
- 版本更新頻繁，服務整合清單持續變動，請以官方文件為準。

## 相關工具

- LiveKit Agents（同類即時語音 agent 框架，本次未查證）
- Daily（維護者，也是支援的 WebRTC 傳輸）
- OpenAI Realtime、Gemini Multimodal Live（可接入的 speech-to-speech 服務）
- [CrewAI](./CrewAI.md)、[DSPy](./DSPy.md)（文字為主的 agent／LLM 框架）

## 資料來源

- https://github.com/pipecat-ai/pipecat （README）
- https://api.github.com/repos/pipecat-ai/pipecat
- https://api.github.com/repos/pipecat-ai/pipecat/releases/latest
- https://docs.pipecat.ai/llms.txt
- https://docs.pipecat.ai/pipecat/learn/overview.md
