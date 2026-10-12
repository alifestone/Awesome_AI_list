# MoneyPrinterTurbo

- **分類**：影片製作 / Agent 影片製作系統（從主題到成片）
- **連結**：https://github.com/harry0703/MoneyPrinterTurbo/blob/main/README-en.md

## 原清單說明

輸入主題，自動產生文案、素材、字幕、配音與背景音樂的短影音生成器。

> **查證結果**：與 README 相符。README 原文：輸入影片主題或關鍵字，自動產生腳本、配對素材、字幕與背景音樂，輸出高畫質短影片。目前版本除了使用素材庫，也能接各家 AI 文生影片服務產生素材，並可直接發布到 TikTok、Instagram、YouTube Shorts。

## 概述

MoneyPrinterTurbo 是 harry0703 開發的開源 AI 短影音生成器，以 Python 撰寫，自稱 *An All-in-One AI Short Video Generator*。它把「主題 → 腳本 → 配音 → 素材 → 字幕 → 配樂 → 剪輯」整條流程自動化，同時保留每個階段的手動控制。

提供四種使用方式：AI Agent（Skill）、WebUI（Streamlit）、API（FastAPI）、CLI。repo 建立於 2024-03，查詢當下（2026-10-13）約 130k 顆星，是同類專案中最熱門的之一。README 有英文、簡中、日文三個版本。

## 核心功能／特色

- **腳本生成**：AI 生成或改寫多語言腳本，也可以直接貼上自己的完整腳本。
- **LLM 供應商**：Kimi／Moonshot、OpenAI、Anthropic Claude、Google Gemini、DeepSeek、阿里雲通義千問等，也可透過聚合閘道接入（Cloudflare AI Gateway、ModelScope、AIHubMix 等）。
- **素材來源**：
  - 本地圖片與影片。
  - Pexels、Pixabay 免費素材，Coverr。
  - AI 文生影片服務：秘塔 MiniMax H3、勝算雲、火山引擎 Seedance、WaveSpeed、OFox、MuAPI。
  - OpenAI 相容的文生圖服務，產生的圖片會轉成動態片段。
- **配音**：
  - Edge TTS 免費、免 API key（WebUI 中的「Azure TTS V1」實際上就是 Edge TTS）。
  - 另支援 Azure TTS V2、SiliconFlow、Gemini、小米 MiMo、MiniMax、ElevenLabs、Chatterbox、Kokoro、Fish Audio、VoxCPM（可從參考音訊複製聲音）等。
- **字幕**：兩種模式。
  - `edge`：預設，用 TTS 時間戳，不需要 GPU。
  - `whisper`：本地 faster-whisper，時間軸較準。
  - 可調整字型、位置、顏色、大小、描邊與背景樣式。
- **背景音樂**：隨機、本地或 AI 生成，音量可獨立調整。
- **輸出規格**：9:16（1080×1920）、16:9（1920×1080）、1:1（1080×1080）。
- **批次與發布**：可一次產生多個版本，保留任務歷史，匯入／匯出設定；CLI 支援 JSON／JSONL 批次清單；可直接發布到 TikTok、Instagram、YouTube Shorts。
- **可編輯的本地專案**：可替換場景素材、比較不同版本，只重建受影響的階段。

## 技術架構或運作原理

- 以 Python 3.11+ 撰寫，依賴以 `pyproject.toml` 與 `uv.lock` 管理（`requirements.txt` 只保留給舊式 pip 安裝）。
- WebUI 為 Streamlit（預設 http://127.0.0.1:8501）。API 為 FastAPI，文件在 `:8080/docs`。
- 影片處理依賴 FFmpeg；正常情況下會自動下載，也可在 `config.toml` 指定 `ffmpeg_path`。
- 第一次啟動時，會從 `config.example.toml` 自動建立 `config.toml`，API key 可在 WebUI 的基本設定中填入。
- Whisper 字幕模式預設使用約 3 GB 的 `large-v3` 模型，也可改用約 1.6 GB 的 `large-v3-turbo`。

## 安裝與使用方式

```bash
# 讓 AI Agent 代為安裝並產生影片（目前支援 macOS／Windows），把下面這段貼給 agent：
# Use this Skill: https://raw.githubusercontent.com/harry0703/MoneyPrinterTurbo/main/docs/skill/SKILL.md
# Create a video with the topic "How AI is changing everyday life."

# 手動安裝（uv）
git clone https://github.com/harry0703/MoneyPrinterTurbo.git
cd MoneyPrinterTurbo
uv python install 3.11
uv sync --frozen
sh webui.sh                    # Windows 用 .\webui.bat
uv run python main.py          # 啟動 API 服務

# 純 CLI
uv run python cli.py --video-subject "How AI is changing everyday life"
uv run python cli.py --batch-file ./tasks.json --stop-at video

# Docker（預建 image：ghcr.io/harry0703/moneyprinterturbo:latest）
docker compose -f docker-compose.release.yml up
```

- Windows 有一鍵整合包：到 Releases 下載 `.7z`，先執行 `update.bat`，再執行 `start.bat`。
- 也可以在 Google Colab 上執行。

## 適用情境

- 大量產出知識型、資訊型短影音（TikTok、Reels、YouTube Shorts）。
- 從關鍵字快速做出含配音與字幕的影片草稿，再人工微調。
- 透過 API 或 CLI 接入 n8n 等自動化流程，批次生成影片。

## 授權與成本

- **授權**：MIT（GitHub API 偵測到 MIT；README 的授權段落只寫「請見 LICENSE 檔」）。
- **成本**：軟體本身免費。可以全程用免費資源（Edge TTS、Pexels／Pixabay 素材），但腳本生成需要 LLM API。AI 影片、雲端 TTS 等依各供應商計費。README 列出多家贊助商的優惠方案，這些屬於贊助內容，不是本專案的收費。
- **硬體**（README 建議）：

  | 項目 | 最低 | 建議 |
  |---|---|---|
  | CPU | 4 核 | 6–8 核 |
  | RAM | 4 GB | 8 GB |
  | GPU | 不需要 | 4 GB 以上 VRAM，可加速 whisper 與批次處理 |

## 限制與注意事項

- 內附的部分背景音樂來自 YouTube 影片，README 自己提醒若有版權疑慮請刪除。商用前務必替換。
- Windows 的專案路徑請避免非 ASCII 字元、特殊字元與空格。
- 常見問題：
  - FFmpeg 自動下載失敗時，需手動設定 `ffmpeg_path`。
  - 出現「Too many open files」時，用 `ulimit -n` 調高上限。
  - Whisper 模型從 Hugging Face 下載失敗時，需手動放到 `models/whisper-large-v3`。
- 使用素材庫時，成品品質取決於素材配對結果，素材可能與內容不完全吻合。
- README 首頁有大量贊助商推廣內容，選擇供應商時應自行評估。
- 最新版本號：查詢時 GitHub API 已達速率上限，**資料不足**。

## 相關工具

- [OpenMontage](OpenMontage.md)：更完整的多 pipeline agentic 影片製作系統
- [video-autopilot-kit](video-autopilot-kit.md)：偏向頻道經營方法論的短影音框架
- Edge TTS、faster-whisper、Pexels／Pixabay API、FFmpeg

## 資料來源

- https://github.com/harry0703/MoneyPrinterTurbo/blob/main/README-en.md （英文 README，透過 raw.githubusercontent.com 取得原文）
- https://api.github.com/repos/harry0703/MoneyPrinterTurbo （repo 中繼資料：描述、星數、建立日期、MIT 授權）
