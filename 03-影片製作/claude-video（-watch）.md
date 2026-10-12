# claude-video（/watch）

- **分類**：影片製作 / 影片理解
- **連結**：https://github.com/bradautomates/claude-video

## 原清單說明

讓 Claude「看」影片：下載、抽幀、轉錄後交給模型分析。

> **查證補充**：原說明與 README 相符，但這個工具現在多了一種模式。設定 `GEMINI_API_KEY` 後，預設會改用 **Gemini 引擎**，把整支影片（畫面加聲音）交給 Google 的影片模型分析，再轉述帶時間戳的答案。原說明描述的「本地抽幀 + 轉錄」是 `local` 引擎。除了 Claude Code，它也支援 Codex 與其他 Agent Skills 宿主。

## 概述

`/watch`（plugin 名稱為 `watch`，repo 名稱為 claude-video）是一個 Agent Skill／plugin，用途是把影片網址或本地影片檔，轉成 agent 能讀的「影片證據」：帶時間戳的畫面截圖與逐字稿。它會優先使用影片原生字幕；沒有字幕時，可改用本地 WhisperX，或 Groq／OpenAI 的雲端語音轉錄。查詢當下（2026-10-13）有約 18.4k 顆星，授權為 MIT。

## 核心功能／特色

- **兩種引擎**：
  - `gemini`：有 key 時的預設。整支影片上傳給 Google 分析；YouTube 網址直接交給 Google，不必下載。
  - `local`：用 `ffmpeg` + `yt-dlp` 在本機抽幀與取得逐字稿，完全不連線 Google。
  - Watch **不會自動切換引擎**：Gemini 失敗時會回報原因，由使用者決定是否改用 `--engine local`。
- **抽幀細緻度**（`--detail`）：

  | 等級 | 選幀方式 | 預設上限 |
  |---|---|---|
  | `transcript` | 只取逐字稿 | 不抽一般畫面 |
  | `efficient` | 快速關鍵幀 | 50 張 |
  | `balanced` | 依場景變化選幀 | 100 張 |
  | `token-burner` | 依場景變化選幀，不設上限 | 無上限（超過 250 張會警告） |

  另有 16×16 RGB 縮圖去除近似重複的畫面；可用 `--no-dedup` 關閉。
- **聚焦區間與指定時間點**：`--start`/`--end` 只看某一段；agent 讀完逐字稿後，可用 `--timestamps` 指定要截圖的時間點。
- **字幕優先**：自動選擇原語言的字幕軌；`--sub-lang` 可指定語言。
- **語音轉錄備援**：
  - `whisperx`：本地執行，免 key。
  - `groq`：雲端 `whisper-large-v3`。
  - `openai`：雲端 `whisper-1`。
  - `none`：只用字幕。
- **登入驗證**：需要時才啟用，可用 `--cookies` 或 `--cookies-from-browser`；工具不會自動搜尋瀏覽器的登入資訊。

## 技術架構或運作原理

- 核心是 `skills/watch/` 底下的 `SKILL.md` 加上 Python 腳本。主流程只用 Python 標準函式庫，搭配外部的 FFmpeg/ffprobe 與 yt-dlp（下載 YouTube 另需 Deno／EJS 等 JS runtime）。
- **local 引擎流程**：
  1. 取得原生字幕，或下載影片／音訊。
  2. 依細緻度抽出場景變化畫面或關鍵幀；圖片預設最寬 512px，可用 `--resolution 1024` 調高。
  3. 去除重複畫面。
  4. 若沒有字幕，再用轉錄備援產生逐字稿。
- **Gemini 引擎**：
  - YouTube 網址直接交給 Google；其他網址會先用 yt-dlp 下載。
  - 下載的影片與本地檔都會上傳到 Google Files API，回答完就刪除；刪除失敗的檔案會在 48 小時內過期。
  - 預設模型 `gemini-3.7-flash`，可用 `WATCH_GEMINI_MODEL` 更換。
- **WhisperX**：由 `setup.py --install-whisperx` 建立獨立的 Python 3.12 環境並安裝 WhisperX 3.8.6。
  - 預設使用 small 模型、CPU、int8。
  - README 實測數據：Apple M5 Pro 處理 69 秒英文音訊花了 9.6 秒。

## 安裝與使用方式

```text
# Claude Code（在 Claude Code 對話中輸入）
/plugin marketplace add bradautomates/claude-video
/plugin install watch@claude-video
```

```bash
# 一般終端機
claude plugin marketplace add bradautomates/claude-video
claude plugin install watch@claude-video

# Codex
codex plugin marketplace add bradautomates/claude-video
codex plugin add watch@claude-video

# 其他 Agent Skills 宿主（需要 Node.js）
npx skills add bradautomates/claude-video -g --skill watch
```

相依套件安裝範例（macOS）：`brew install python ffmpeg yt-dlp`。

使用範例：

```text
/watch video.mp4 --start 2:15 --end 2:45
/watch video.mp4 --detail efficient --max-frames 30
/watch video.mp4 --detail transcript --timestamps 1:05,2:30
/watch https://example.com/video --cookies-from-browser firefox
```

設定檔位置：`~/.config/watch/.env`，可設定 `GEMINI_API_KEY`、`WATCH_ENGINE`、`WATCH_DETAIL`、`WATCH_WHISPER_BACKEND` 等。

## 適用情境

- 讓 coding agent 看教學影片、產品示範或錄影，並整理成帶時間戳的摘要。
- 分析參考影片的節奏、畫面與台詞（例如競品短片拆解）。
- 檢查螢幕錄影中的程式碼或 UI 變化（建議用 `--resolution 1024`）。
- 處理沒有字幕的私人影片：用 local 引擎加 WhisperX，全程不上傳。

## 授權與成本

- **授權**：MIT。
- **工具本身**：免費。
- **Gemini 引擎**：需要 Google AI Studio API key。README 稱可取得免費 key；超過免費額度後的費率，README 沒有說明，**資料不足**。
- **雲端轉錄**：Groq 或 OpenAI 依各家計費。
- **本地 WhisperX**：免費，但至少需要約 3 GB 磁碟空間與 8 GB RAM（README 建議值）。large-v3 模型約 2.9 GB，執行時峰值約 6 GB RAM。

## 限制與注意事項

- **不支援 Claude Chat 與 Cowork**，網頁版的使用也有限制。README 明確建議在 Claude Code（桌面版 Code 工作階段、VS Code、終端機）或本地 agent 中使用。
- Gemini 模式會把非 YouTube 的影片**上傳到 Google**。私人影片請用 `--engine local`。
- 準確度在 10 分鐘以內的影片，或指定聚焦區間時最好。場景偵測不保證捕捉到每個事件。
- yt-dlp 只支援最新版，網站改版常導致舊版失效。
- 平台驗證狀況：
  - WhisperX 只在 Apple Silicon macOS 上驗證過。
  - Intel Mac、Linux、Windows 的安裝**未經測試**。
  - CUDA 可設定但未測試，也不保證支援 MPS。
- 影像會消耗模型的 token，費用依宿主模型與畫面尺寸而定。

## 相關工具

- yt-dlp、FFmpeg、WhisperX、Groq Whisper、Google Gemini API
- [ffmpeg-skill](ffmpeg-skill.md)：負責剪輯處理的另一類 agent skill
- [OpenMontage](OpenMontage.md)：同樣可以拿參考影片來分析，並延伸成製作企劃

## 資料來源

- https://github.com/bradautomates/claude-video （README，以 GitHub API 取得原文）
- https://api.github.com/repos/bradautomates/claude-video （repo 中繼資料：描述、星數、MIT 授權）
