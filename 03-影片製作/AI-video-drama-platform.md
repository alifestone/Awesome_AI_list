# AI video drama platform

- **分類**：影片製作 / Agent 影片製作系統（從主題到成片）
- **連結**：https://github.com/dc-tw/ai-video-drama-platform

## 原清單說明

AI 短劇製作平台（依名稱判斷）。

> **查證結果**：原說明是「依名稱判斷」。實際讀過 README 後，這個 repo 的確以「AI 短劇」為目標（GitHub 描述為 *Full-stack AI short-drama pipeline with FastAPI, Pydantic structured outputs, ComfyUI and FFmpeg*），但目前只是 **v0.1 的後端骨架**：把故事大綱轉成經過驗證的分鏡 JSON，每個場景用 ComfyUI 產生一張靜態圖，再用 FFmpeg 把這些圖片串成幻燈片式 MP4。它還不是能產出完整短劇（角色一致、配音、影片片段）的平台。

## 概述

AI Video Drama Platform 是以 Python 撰寫的實驗性專案。流程是「故事大綱 → LLM 結構化分鏡 → ComfyUI 產圖 → FFmpeg 合成 MP4」。README 自稱是 *an initial backend skeleton*，之後的階段才會把 ComfyUI 與 FFmpeg 的編排做完整。repo 建立於 2026-10-11，查詢當下（2026-10-13）有 15 顆星，屬於非常早期的專案。

## 核心功能／特色

- **結構化分鏡**：以 OpenAI Structured Outputs 搭配 Pydantic 定義分鏡契約，每個場景包含 `scene_id`、`prompt`、`negative_prompt`、時長、鏡頭資訊、對白清單與 `character_ref`。前綴異常或欄位不明的 JSON 會被拒絕。
- **本地 ComfyUI 產圖**：透過 REST 與 WebSocket 呼叫本機 ComfyUI（`/prompt`、`/ws`、`/history/{prompt_id}`、`/view`），每個場景產生一張 PNG。
- **FFmpeg 合成**：依各場景的 `duration_seconds` 把圖片組成幻燈片式 MP4。
- **三種輸入方式**：
  - CLI 一次跑完整條流程並輸出 MP4。
  - FastAPI 的 Swagger UI 只產生分鏡 JSON。
  - 手動撰寫分鏡 JSON，完全不呼叫 OpenAI。
- **供應商隔離**：各家生成服務的串接集中在 `app/integrations`，之後要改接雲端圖片／影片 API 時，不必更動分鏡 schema。
- **分層測試**：離線單元測試使用假 client；呼叫真實 LLM、ComfyUI 與端到端流程的測試，需設定 `RUN_LIVE_LLM_TESTS`、`RUN_COMFYUI_TESTS`、`RUN_E2E_TESTS` 才會執行。

## 技術架構或運作原理

```text
故事大綱 → FastAPI / CLI → OpenAI Structured Outputs + Pydantic（驗證過的場景）
        → ComfyUI REST + WebSocket（每場景一張 PNG）→ FFmpeg → output.mp4
```

- FastAPI 是應用程式的對外介面。Pydantic 是 LLM 與生成層之間的契約。ComfyUI 負責本地影像推論，FFmpeg 負責可重現的媒體組裝。
- 預設以 `gpt-4o-mini` 規劃三個場景。
- repo 內附 Kandinsky 5.0 T2V Lite 的 ComfyUI 工作流（UI 版與 API 版），但**應用程式目前不會執行它**。README 說明作者機器上沒有約 13.7 GB 的模型，而且 `ComfyUIClient` 還不支援下載影片結果。
- 提供 Dockerfile 與 docker-compose。其中的 ComfyUI 服務只是佔位用的 image，需自行設定 `COMFYUI_IMAGE` 與 GPU。

## 安裝與使用方式

```bash
cp .env.example .env          # 在 .env 填入自己的 OPENAI_API_KEY
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload # API 文件：http://localhost:8000/docs

# 先在 ComfyUI 目錄啟動 ComfyUI（埠 8188）
python main.py --listen 127.0.0.1 --port 8188
# .env 設定 COMFYUI_BASE_URL、COMFYUI_CHECKPOINT（模型檔名）、COMFYUI_WORKFLOW_PATH

# 完整流程：故事 → MP4
python main.py --story "一隻貓在太空漫步，追逐漂浮在太空站外的紅色毛線球。" --output my-cat-video.mp4

# 不使用 OpenAI，直接用手寫分鏡
python main.py --storyboard my-storyboard.json --output my-manual-video.mp4

# Docker
docker compose up --build
```

單元測試：`pip install -r requirements-dev.txt && pytest tests/unit -q`。

## 適用情境

- 學習「LLM 結構化輸出 → ComfyUI → FFmpeg」這類流水線的寫法與測試分層。
- 作為自建 AI 短劇／分鏡產生器的起點，再自行擴充影片生成、TTS 與角色一致性。
- 不適合直接拿來產出可發布的短劇成片。

## 授權與成本

- **授權**：repo 根目錄沒有 LICENSE 檔，GitHub API 也沒有偵測到授權。依 GitHub 預設，未明示授權時不代表可以自由使用。**授權資料不足**，使用前應向作者確認。
- **成本**（README 於 2026-10-11 的估算）：
  - 分鏡規劃只呼叫一次 `gpt-4o-mini`，一份三場景分鏡約 **US$0.001–0.002**。
  - 本地 ComfyUI 與 FFmpeg 不按次計費，成本是自己的硬體與電費。
  - 若改接雲端供應商，README 以 Higgsfield 為例：圖片約每張 US$0.0032–0.06，影片按秒計費。

## 限制與注意事項

- v0.1 沒有瀏覽器前端。API 端點只回傳分鏡 JSON，要產生 MP4 必須用 CLI。
- `character_ref` 目前只是經過驗證的中繼資料，還沒接到 IP-Adapter，角色外觀必須寫進每個場景的 prompt。
- 對白也只是中繼資料，還沒有 TTS，所以成品沒有配音。
- 輸出是「靜態圖幻燈片」，不是 AI 生成的動態影片。影片工作流（Kandinsky）尚未接上。
- Apple Silicon 必須以原生方式在 macOS 上跑 ComfyUI 才能用到 MPS。Docker Desktop 容器無法使用 MPS。
- 必須自備 OpenAI API key 與 ComfyUI checkpoint。
- 專案非常新、星數很少，長期維護狀況不明。

## 相關工具

- ComfyUI（本地影像／影片生成後端）
- [MoneyPrinterTurbo](MoneyPrinterTurbo.md)、[OpenMontage](OpenMontage.md)：同類但成熟許多、從主題到成片的系統
- Kandinsky 5.0 Video Lite（repo 內附但尚未啟用的 T2V 工作流）

## 資料來源

- https://github.com/dc-tw/ai-video-drama-platform （README，以 GitHub API 取得原文）
- https://api.github.com/repos/dc-tw/ai-video-drama-platform （repo 中繼資料：描述、星數、建立日期、授權欄位）
- https://api.github.com/repos/dc-tw/ai-video-drama-platform/contents/ （根目錄檔案清單，確認沒有 LICENSE）
