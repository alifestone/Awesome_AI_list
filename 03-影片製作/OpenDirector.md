# OpenDirector

- **分類**：影片製作 / Agent 影片製作系統（從主題到成片）
- **連結**：https://github.com/seme-org/open-director
- **官網**：https://od.seme.cc

## 原清單說明

（使用者提供連結，無附註說明）

> **查證結果**：repo 描述為「開源 AI 影片工作室：從一句話到成片」，有創意模式（AI 導演全流程）與批次模式（短影音量產）兩種模式。2026-05-29 加入 LGPL-3.0 授權檔。

## 概述

OpenDirector 是以 Docker 為主、自行架設的 AI 影片製作工作室。輸入一句構想，由 9 個 agent 組成的流水線依序產出研究筆記、故事、分鏡、角色與場景設定、配音、背景音樂，最後渲染成片。另有一個「批次模式」，用 Pexels／Pixabay 素材加 TTS 與字幕大量產出短影音，概念接近 MoneyPrinterTurbo。

repo 於 2026-05-03 建立，查詢當下（2026-10-14）約 112 顆星，主要語言為 TypeScript。最後一次推送是 2026-05-29，之後約四個半月沒有更新。介面有中、英文版。

## 核心功能／特色

- **創意模式（AI 導演）**：
  - 一句話生成完整企劃：brief、故事、分鏡、配音、圖片、背景音樂。
  - 可選的網路研究：查已知故事、事實、品牌、產品等公開資訊。
  - 34 種內建美術風格，分 9 大類（電影感、商業、未來、復古、動漫、3D、插畫、寫實、實驗）。
  - 故事腳本可手動修改；配音可即時試聽。
  - 分鏡預覽：圖片、配音、背景音樂同步播放。
  - 畫面比例 16:9／9:16／1:1，輸出 480p／720p／1080p。
- **批次模式（短影音量產）**：
  - 輸入主題，AI 產生多份腳本並批次出片。
  - 可設定每段素材 2–10 秒，控制切換節奏。
  - 中、英文腳本；內建免費的 Edge TTS。
  - 字幕可調字型、大小、顏色、位置、描邊。
  - 素材來自 Pexels／Pixabay（免版稅），也可用本機檔案。
  - 一次產生多個版本，挑最好的。

## 技術架構或運作原理

9 個 agent 都是 LangGraph 節點，依序執行並即時串流輸出，可以看著企劃一步步長出來：

1. **Research Agent**：需要時用 OpenAI 的 `web_search_preview` 查資料，產出筆記、注意事項與來源。
2. **Script Agent**：寫故事大綱與敘事結構，參考研究筆記但不照抄。
3. **Art Style Agent**：從 34 種風格中挑選。
4. **Storyboard Agent**：拆成場景，寫鏡頭描述與台詞。
5. **Character Agent**：設計角色的視覺提示詞並指定聲線。
6. **Location Agent**：設計每個場景的環境。
7. **Voice Agent**：依角色個性與性別分配 TTS 聲音。
8. **BGM Agent**：依故事氛圍決定背景音樂。
9. **Media Agent**：協調圖片、語音、音樂生成，整理成最終素材。

系統架構：

| 層 | 技術 |
|---|---|
| 前端 | Next.js 16、React 19、TypeScript、Tailwind CSS 4 |
| AI | LangChain + LangGraph |
| 資料庫 | Prisma + MySQL 8.4 |
| 佇列 | BullMQ + Redis |
| 儲存 | MinIO（S3 相容） |
| 渲染 | FFCreator（基於 FFmpeg）的獨立 worker |

媒體生成：

- **圖片**：預設走 WaveSpeed。角色與場景用文生圖模型（預設 `nano-banana`）；帶角色參考圖的分鏡畫面必須用圖生圖／編輯模型（預設 `nano-banana-2-edit`），否則會忽略參考圖、角色不一致。也可切換為 AiHubMix。
- **語音**：本機 Edge TTS。
- **背景音樂**：README 的「Media Generation」段說明是從 `assets/bgm/default/` 隨機挑本機音軌（程式碼中為 `local-bgm.ts`）。
- **LLM**：OpenAI 相容 API，預設 `gpt-4o-mini`。

## 安裝與使用方式

需求：Docker 與 Docker Compose（本機開發另需 Node.js 20+、pnpm）。

```bash
git clone https://github.com/seme-org/open-director.git
cd open-director
cp .env.example .env
# 在 .env 填入 OPENAI_API_KEY、WAVESPEED_API_KEY 等
docker compose up --build
```

啟動後開 http://localhost:3000。一併啟動的服務：MySQL（localhost:3307）、Redis（6379）、MinIO 主控台（localhost:9001）、渲染 worker。

主要環境變數：

- `OPENAI_API_KEY`、`OPENAI_BASE_URL`、`OPENAI_MODEL`：LLM。
- `WAVESPEED_API_KEY`：圖片生成。
- `PEXELS_API_KEY`、`PIXABAY_API_KEY`：批次模式的素材搜尋。
- `SESSION_SECRET`：預設為 `change-me-in-production`，正式環境必須更換。

主要頁面：`/chat`（AI 導演）、`/creation/[id]`（分鏡預覽與匯出）、`/batch`（批次模式）、`/space`（工作區）。

## 適用情境

- 從一句構想快速做出有角色、分鏡、旁白的短故事影片或概念片。
- 不想把資料放到雲端服務，想自架一套 AI 影片工作室。
- 大量產出知識型短影音（批次模式）。
- 參考 LangGraph 多 agent 影片流水線的實作方式。

## 授權與成本

- **授權**：LGPL-3.0（2026-05-29 才加入授權檔，之前的版本沒有授權檔）。
- **成本**：軟體免費，但要自付 LLM（OpenAI 相容 API）與 WaveSpeed／AiHubMix 圖片生成費用。Edge TTS 免費；Pexels／Pixabay API 免費但需申請 key。每支影片的實際花費 README 沒有說明，**資料不足**。

## 限制與注意事項

- 創意模式的成片以「靜態分鏡圖 + 配音 + 背景音樂」為主。README 沒有提到串接影片生成模型；數位人與漫劇動畫列在 Roadmap 尚未完成。
- README 功能清單寫「AI 背景音樂，依故事氛圍自動生成」，但設定說明寫背景音樂取自本機音軌庫。實際上應理解為 AI 依氛圍挑選音軌，而非生成新音樂。
- 功能清單列出 OpenAI、Gemini、DeepSeek、Qwen、MiniMax、Ollama 等多家模型，但設定只有一組 OpenAI 相容 API，其他家需透過相容端點接入。
- 研究功能使用 OpenAI 專有的 `web_search_preview` 工具，改用其他相容端點時可能無法使用。
- `.env.example` 與 Docker 預設帶有固定的 MinIO 帳密（`opendirector` / `opendirector-secret`）與資料庫密碼，對外開放前務必更改。
- 專案很新、星數不多，2026-05-29 之後沒有更新，長期維護狀況待觀察。

## 相關工具

- [MoneyPrinterTurbo](MoneyPrinterTurbo.md)：批次模式的概念與它相近，社群更成熟
- [OpenMontage](OpenMontage.md)：在 coding agent 裡運作的 agentic 影片製作系統，pipeline 更多
- [AI video drama platform](AI-video-drama-platform.md)：同樣是「故事 → 分鏡 → 產圖 → 合成」，但仍是早期骨架
- [AutoMV](AutoMV.md)：多 agent 從整首歌生成 MV
- LangGraph、FFCreator、Edge TTS、WaveSpeed

## 資料來源

- https://github.com/seme-org/open-director （README：功能、9 個 agent、架構、環境變數、Roadmap）
- https://raw.githubusercontent.com/seme-org/open-director/HEAD/.env.example （預設設定值）
- https://api.github.com/repos/seme-org/open-director （repo 中繼資料：建立日期、星數、LGPL-3.0 授權）
- https://api.github.com/repos/seme-org/open-director/commits （最近提交：2026-05-29 加入授權檔）
