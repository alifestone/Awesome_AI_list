# ffmpeg-skill

- **分類**：影片製作 / 剪輯 / 處理
- **連結**：https://github.com/kajisho5/ffmpeg-skill

## 原清單說明

給 coding agent 的本地 FFmpeg 剪輯 skill：剪接、字幕、響度、調色、平台交付檢查等 42 個工具，也可當 MCP。

> **查證結果**：與 README 相符。README 明確寫 **42 tools**，全部都能以 MCP 工具的形式呼叫。MCP 的 `tools/list` 預設只列出核心 12 個；設定 `FFMPEG_SKILL_MCP_FULL=1` 才會列出全部 42 個。

## 概述

ffmpeg-skill 是給 Claude Code、Cursor、Codex 等能讀取 `SKILL.md` 的 agent 使用的 Agent Skill，標語是 *Give your coding agent a video editor*。它教 agent 一套固定流程：先量測檔案（probe），盡量無損剪輯，再檢查，最後驗證結果。實際工作由 42 支 Python 腳本呼叫 `ffmpeg`／`ffprobe` 完成。

全程在本機執行，不用雲端、不用 API key，只用 Python 標準函式庫。查詢當下（2026-10-13）約 1.9k 顆星，npm 套件最新版為 2.8.6。作者 kajisho5 另有一系列影片製作 repo，在那套生態系中，本工具扮演負責執行的「手」：它不決定剪哪裡，只負責剪、量測、匯出，並回報 JSON 結果。

## 核心功能／特色

- **42 個工具**，大致分類如下：
  - 分析：`probe`、`scenes`、`look`（產生聯絡表 PNG 給 agent 看）
  - 剪輯：`cut`、`join`、`silence`（刪除靜音段，可選擇刪除贅詞）、`fit`（調整時長或畫面比例，例如 16:9 → 9:16）、`crop`、`speedramp`、`multicam` 等
  - 音訊：`audio`、`sync`（含漂移修正）、`loudness`（例如 −14 LUFS）
  - 字幕與圖像：`caption`（含卡拉 OK 式逐字亮起）、`overlay`、`graphics`
  - 色彩：`color`（HDR → SDR、LUT）
  - 交付：`export`、`check`（檢查是否符合平台規格）、`render`（整個專案或平台模板）、`batch`
- **平台模板**：tiktok、reels、shorts／youtube-shorts、youtube、x、linkedin、facebook、podcast。模板會考慮各 App 介面的安全區，例如字幕會放在 TikTok 說明欄上方。`--template all` 可一次輸出所有平台的版本。
- **共用旗標**：每支工具都支援 `--dry-run`、`--plan FILE`、`--json`／`--json-brief`、`--fast`、`--progress`、`--timeout`、`--overwrite`。
- **重新編碼選項**：需要重新編碼的工具支援 `--codec h264|hevc|av1|prores`。`export` 可選擇使用 Apple VideoToolbox 硬體加速。
- **SPEC（Self-Producing Execution Contract）**：每支工具的 `input_schema` 直接由該工具 CLI 的 argparse 定義在執行時產生。CI 會檢查兩者是否一致，因此 MCP 的工具定義不會與 CLI 脫節。
- **能力偵測**：`doctor` 讀取 `ffmpeg -encoders/-filters/-bsfs`，回報每項能力為 available、missing 或 unknown。
- **安全設計**：
  - 不透過 shell 執行，也不接受呼叫者傳入的 filter graph。
  - 不覆寫原始檔。
  - 盡量使用 stream copy（無損）。
- **選用的本地轉錄**：可接 Parakeet、faster-whisper 或 openai-whisper，音訊不會上傳。

## 技術架構或運作原理

- **agent 端**：agent 讀取 `SKILL.md`（工作流程、需求與工具對照表、回報格式），再執行 `scripts/<name>.py`。每支工具都有型別化參數，並對應一份 contract，記載輸入 schema、所需的 FFmpeg 能力與驗證政策。
- **執行流程**：probe 量測 → FFmpeg 執行 → 驗證（probe、check、`look.py` 產生聯絡表）→ 輸出結構化 JSON 結果。
- **MCP 端**：`mcp/server.py` 是 stdio JSON-RPC 伺服器。`tools/list` 在啟動時由 contract 產生，本身不維護另一份工具表。另提供 5 個 prompt 範本：`reel`、`podcast`、`multicam`、`delivery_check`、`hdr`。
- **相容性**：README 標示 CI 測試過 FFmpeg 5.1、6.1、7.1、8、9，以及 Python 3.9 與 3.13。

## 安裝與使用方式

```bash
npx ffmpeg-skill              # 安裝到 Claude Code（~/.claude/skills/ffmpeg-skill）
npx ffmpeg-skill --cursor     # Cursor
npx ffmpeg-skill --codex      # Codex（~/.agents/skills/ffmpeg-skill）
npx ffmpeg-skill --all        # 三者都裝
npx ffmpeg-skill doctor       # 檢查 FFmpeg 元件是否齊全
npx ffmpeg-skill contract --json

# 或以 Claude Code plugin 安裝
claude plugin install kajisho5/ffmpeg-skill
```

MCP 設定範例：

```json
{"mcpServers": {"ffmpeg-skill": {"command": "python3", "args": ["/Users/you/.claude/skills/ffmpeg-skill/mcp/server.py"]}}}
```

直接從終端機使用：

```bash
S=~/.claude/skills/ffmpeg-skill/scripts
python3 $S/probe.py input.mp4 --compact
python3 $S/fit.py input.mp4 --duration 60 --aspect 9:16 --dry-run
python3 $S/render.py talk.mp4 --template tiktok --cues cues.txt
```

對 agent 下指令的範例：「把 interview.mp4 保留 0:45–3:10 與 5:00–6:30，剪成剛好 60 秒的 Reels。」

## 適用情境

- 讓 coding agent 處理日常剪輯：剪片段、刪靜音、加字幕、做響度標準化、轉成直式畫面。
- 一支影片輸出多個平台版本，並自動檢查是否符合規格。
- 不想上傳到雲端的素材（例如內部影片、客戶素材）。
- 作為 MCP 工具，接到 Claude Desktop、Cursor 等 MCP client。

## 授權與成本

- **授權**：MIT。
- **成本**：免費。不需要 API key，也不需要帳號。
- 作者透過 GitHub Sponsors 接受贊助。

## 限制與注意事項

- 需要 FFmpeg 5.0 以上，且必須包含 `libx264`、`aac`，以及 `drawtext`、`subtitles`（libass）、`loudnorm`、`xfade`、`acrossfade`、`scdet`、`silencedetect`、`tile` 等 filter。
- macOS 上 Homebrew 的一般 `ffmpeg` 缺少 subtitles、drawtext、zscale，建議改裝 `ffmpeg-full`（它是 keg-only，需要另外處理 PATH）。
- 本工具**不做內容判斷**：
  - 不偵測人臉或主體，也不判斷「精彩片段」。
  - 裁切的錨點要由具備視覺能力的 agent 看過 `look.py` 的 PNG 後決定；沒有指定時預設為置中裁切。
  - `scenes.py --highlights` 只依音量或長度等可量測的代理指標排序。
- 字幕文字會原樣燒入，不會被改寫。
- Windows 從 python.org 安裝的 Python，指令是 `python` 而不是 `python3`。
- 已安裝的副本不會自動更新，需要重新執行 `npx ffmpeg-skill`（以 plugin 安裝的可用 `claude plugin update`）。

## 相關工具

- 同作者生態系：`video-production-agent`、`AI-video-production-OS`、`video-editing-skill`、`audio-production-skill`、`media-analysis-skill`、`transcription-skill`、`subtitle-skill` 等（README 列出，未逐一查證內容）
- [claude-video（/watch）](claude-video（-watch）.md)：讓 agent「看」影片
- [video-autopilot-kit](video-autopilot-kit.md)：同樣以 ffmpeg 做 QA 的短影音框架

## 資料來源

- https://github.com/kajisho5/ffmpeg-skill （README，以 GitHub API 取得原文）
- https://api.github.com/repos/kajisho5/ffmpeg-skill （repo 中繼資料：星數、MIT 授權）
- https://registry.npmjs.org/ffmpeg-skill/latest （npm 最新版本號 2.8.6）
