# OpenMontage

- **分類**：影片製作 / Agent 影片製作系統（從主題到成片）
- **連結**：https://github.com/calesthio/OpenMontage

## 原清單說明

開源 agentic 影片製作系統，把 Claude Code / Cursor 變成影片工作室；多條 pipeline（解說動畫、預告片、紀錄片、Podcast 剪片、多語配音…），可接本地 ComfyUI。AGPL-3.0。

> **查證結果**：大致相符，有兩點需要修正。
> - **ComfyUI**：README 只在影片生成供應商表格中，提到 WAN 2.1／2.2 有「accelerated ComfyUI workflows」。本地生成的主要做法是 `make install-gpu` 後設定 `VIDEO_GEN_LOCAL_MODEL`（wan2.2-ti2v-5b、hunyuan-1.5、ltx2-local、cogvideo-5b 等），所以「可接本地 ComfyUI」只能說是部分屬實。
> - **支援的 agent**：不只 Claude Code 與 Cursor，也支援 Copilot、Windsurf、Codex。
>
> 授權 AGPL-3.0 已確認。

## 概述

OpenMontage 自稱是「第一個開源的 agentic 影片製作系統」，目標是把 AI coding assistant 變成完整的影片製作工作室。使用者以自然語言描述需求，agent 負責研究、寫腳本、產生素材、剪輯與最終合成。

GitHub 描述為：12 條製作 pipeline、100+ 工具、700+ 份 agent skill 與製作知識檔（README 內文寫「10+ pipelines」）。查詢當下（2026-10-13）約 67.4k 顆星，以 Python 為主，官網為 openmontage.video。

## 核心功能／特色

- **Pipeline**：README 表格列出 11 條，另外提到 `character-animation`（SVG 角色動畫）：

  | Pipeline | 產出 |
  |---|---|
  | Animated Explainer | 解說動畫 |
  | Animation | 動態圖像 |
  | Avatar Spokesperson | 虛擬主播影片 |
  | Cinematic | 預告片、前導片 |
  | Clip Factory | 從長片切出多支短片 |
  | Documentary Montage | 以真實素材剪成的紀錄片式蒙太奇 |
  | Hybrid | 真實素材加 AI 補充畫面 |
  | Localization & Dub | 字幕、翻譯、配音 |
  | Podcast Repurpose | Podcast 精華轉成影片 |
  | Screen Demo | 軟體操作示範 |
  | Talking Head | 以拍攝素材為主的說話影片 |

- **從參考影片出發**：貼上 YouTube、Shorts、Reels、TikTok 或本地影片，agent 會分析逐字稿、節奏、場景與風格，提出 2–3 個差異化的概念，並附上工具路徑與成本估算。
- **真實素材的紀錄片路徑**：從 Archive.org、NASA、Wikimedia Commons、Pexels、Unsplash 建立可用 CLIP 搜尋的素材庫，挑出真正的動態影片片段剪成成片，而不是只把靜態圖做成動畫。
- **零 API key 也能用**：Piper TTS 旁白、開放素材、Remotion（React）或 HyperFrames（HTML/GSAP）合成、FFmpeg 後製、自動產生逐字時間的字幕。
- **供應商評分選擇**：從 7 個維度（任務契合度 30%、品質 20%、控制性 15%、可靠性 15%、成本 10%、延遲 5%、連續性 5%）自動選出供應商，所有決策都寫進稽核紀錄。
- **品質關卡**：
  - 提案、腳本、場景規劃、素材、發布各階段都必須經過人工核准。
  - 合成前檢查「投影片感」風險。
  - 渲染後自我檢查：ffprobe、在 4 個位置抽幀、音訊分析、字幕檢查。
- **預算控管**：先估算、預留、事後對帳。有 `observe`、`warn`、`cap` 三種模式；單次動作超過 US$0.50 需要確認，總預算上限預設 US$10。
- **Backlot 即時分鏡板**：本地看板會隨製作進度自動更新，也是逐場景的核准關卡，完成後可以回放整個製作過程。

## 技術架構或運作原理

- **agent 優先，沒有程式碼層的 orchestrator**，AI coding assistant 本身就是 orchestrator。
- **製作流程**：
  1. agent 讀取 YAML 格式的 pipeline manifest（`pipeline_defs/`）。
  2. 讀取各階段的導演 skill（Markdown，`skills/pipelines/`）。
  3. 呼叫 Python 工具（`tools/`，registry 會自動發現）。
  4. 自我審查，並以 JSON 寫入 checkpoint，可以中斷後續跑。
  5. 送交使用者核准。
  6. 合成前驗證，以 Remotion、HyperFrames 或 FFmpeg 渲染。
  7. 渲染後自我審查。
- **固定階段**：research → proposal → script → scene_plan → assets → edit → compose。研究階段會實際搜尋 YouTube、Reddit、Hacker News、新聞與學術來源，README 寫每次 15–25 次以上的搜尋。
- **三層知識架構**：
  - Layer 1：`tools/` 與 `pipeline_defs/`，說明有哪些能力。
  - Layer 2：`skills/`，說明 OpenMontage 的使用慣例。
  - Layer 3：`.agents/skills/`，各項外部技術的深入知識包。
- **供應商**：
  - 影片生成：Kling、Seedance、Veo 3.1、Runway Gen-4、Grok、MiniMax、HeyGen 等雲端服務，以及本地 WAN、Hunyuan、CogVideo、LTX-Video。
  - 圖片：FLUX、Imagen、GPT Image 2、Seedream 等。
  - TTS 與音樂：ElevenLabs、OpenAI、Google、Suno、Piper 等。
- **內建輸出規格**：YouTube（含 4K）、Shorts、Reels、Instagram Feed、TikTok、LinkedIn、Cinematic 21:9。

## 安裝與使用方式

```bash
git clone https://github.com/calesthio/OpenMontage.git
cd OpenMontage
make setup
# 在 AI coding assistant 中開啟此專案，然後說：
# "Make a 60-second animated explainer about how neural networks learn"

# 選用：有 GPU 時可用本地影片生成
make install-gpu
# .env: VIDEO_GEN_LOCAL_ENABLED=true
#       VIDEO_GEN_LOCAL_MODEL=wan2.2-ti2v-5b

# 開啟 Backlot 看板
python -m backlot open

# 測試
make test-contracts
```

- 前置需求：Python 3.10+、FFmpeg、Node.js 18+，以及一個 AI coding assistant。
- API key 都是選用的，在 `.env` 填入 `FAL_KEY`、`PEXELS_API_KEY`、`ELEVENLABS_API_KEY`、`OPENAI_API_KEY` 等，key 越多，可用的工具越多。
- 各平台的設定檔：Claude Code 用 `CLAUDE.md`，Cursor 用 `CURSOR.md`，Copilot 用 `COPILOT.md`，Codex 用 `CODEX.md`，Windsurf 用 `.windsurfrules`。

## 適用情境

- 從一句描述產出解說動畫、預告片、紀錄片式蒙太奇。
- 把長篇 Podcast 或訪談切成多支社群短片；字幕翻譯與多語配音。
- 想參考某支爆紅影片的節奏，製作原創版本。
- 不付費也想做出以真實影片素材為主的作品。

## 授權與成本

- **授權**：GNU AGPL-3.0。若修改後以網路服務形式提供，需要公開原始碼。
- **成本**：
  - 系統本身免費，零 key 的路徑只需要本地運算。
  - README 提供的估算：接上圖片或影片供應商約 US$0.15–1.50，完整設定約 US$1–3。
  - 範例作品：「THE LAST BANANA」總成本 US$1.33，「Reimagine Your Universe」約 US$4。
  - 各供應商的費率見 repo 內的 `docs/PROVIDERS.md`（本次未讀，**資料不足**）。

## 限制與注意事項

- 品質與成本高度取決於接上了哪些供應商。零 key 的路徑以圖片動畫或開放素材為主。
- 使用本地 GPU 影片模型時，對 VRAM 的需求 README 沒有列出，**資料不足**。
- 需要具備檔案讀寫與執行 Python 能力的 AI coding agent，而且 LLM 的 token 費用另計。
- 支援 Ollama／LM Studio 等本地 LLM 的功能標示為「Coming soon」，目前尚未提供。
- AGPL 的 copyleft 條款會影響商用與 SaaS 整合。

## 相關工具

- [HyperFrames](HyperFrames.md)、Remotion：OpenMontage 使用的兩種合成 runtime
- [MoneyPrinterTurbo](MoneyPrinterTurbo.md)：較單純的主題轉短影音工具
- [claude-video（/watch）](claude-video（-watch）.md)：分析參考影片
- ComfyUI、WAN、Piper TTS

## 資料來源

- https://github.com/calesthio/OpenMontage （README，以 GitHub API 取得原文）
- https://api.github.com/repos/calesthio/OpenMontage （repo 中繼資料：描述、星數、AGPL-3.0、官網）
