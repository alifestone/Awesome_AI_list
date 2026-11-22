# Fabric

- **分類**：Agent 框架與編排 / 應用工作流（prompt 模板庫＋命令列工具）
- **連結**：https://github.com/danielmiessler/Fabric （Patterns 目錄：https://github.com/danielmiessler/Fabric/tree/main/data/patterns ；YouTube 說明：https://github.com/danielmiessler/Fabric/blob/main/docs/YouTube-Processing.md ）
- **教學文章**：https://www.aiposthub.com/fabric-open-source-ai-prompt-patterns-youtube-summary/

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：repo 描述為 *Fabric is an open-source framework for augmenting humans using AI. It provides a modular system for solving specific problems using a crowdsourced set of AI prompts that can be used anywhere.* 作者是資安研究者 Daniel Miessler。查詢當下（2026-11-22）GitHub API 顯示約 44,700 顆星，主要語言 Go，最新 release 為 v1.4.580（2026-11-21），幾乎每天發版。MIT 授權。

## 概述

Fabric 的出發點是「AI 缺的不是能力，而是整合」：把常用的 prompt 依真實任務整理成一個個 **Pattern**（每個是一份 Markdown 的 `system.md`），讓人能收集、版控、重複使用。查證時 `data/patterns/` 下有 267 個 Pattern，涵蓋摘要影片／Podcast、事實查核、論文摘要、改寫文章、解釋程式碼、資安報告分析等。

用法有兩層：

1. **只用 Patterns**：直接到 GitHub 打開某個 Pattern 的 `system.md`，貼進 ChatGPT、Cherry Studio 等任何聊天介面的系統提示欄。README 也說「就算只用 Patterns，這個專案也有價值」。
2. **用 `fabric` 命令列**：Go 寫的單一執行檔，把輸入（stdin、YouTube 字幕、網頁、檔案）丟給指定 Pattern 和模型，輸出可存檔、複製或串接下一個指令。早期是 Python 版，現已改寫成 Go。

## 核心功能／特色

- **Patterns**：Markdown 格式、幾乎只用 system prompt；明確的角色、步驟與輸出格式。`fabric -U` 更新、`-l` 列出、`--readpattern` 印出內容；可設定獨立的自訂 Patterns 目錄，更新時不會被覆蓋。
- **大量模型供應商**：原生支援 OpenAI、Anthropic、Gemini、Ollama、Azure OpenAI、Bedrock、Vertex AI、LM Studio、Perplexity，也能透過訂閱走 Claude Code CLI 或 OpenAI Codex；另有 DeepSeek、Groq、Mistral、OpenRouter、Together、LiteLLM 等數十個 OpenAI 相容供應商。可用 `FABRIC_MODEL_<PATTERN>=vendor|model` 替每個 Pattern 指定模型。
- **輸入來源**：
  - `-y` 抓 YouTube 影片或播放清單字幕（可帶時間戳、留言、metadata；`--visual` 用 OCR＋FFmpeg 擷取畫面文字）。
  - `-u` 用 Jina AI 把網頁轉成 Markdown；另有 Parallel、Firecrawl、Serply 等網頁搜尋選項。
  - `--transcribe-file` 用 OpenAI 語音轉文字處理本機音訊／影片（超過 25MB 可用 ffmpeg 切檔）。
- **Prompt 策略**：`--strategy` 疊加 Chain-of-Thought、Chain-of-Draft、Tree-of-Thought、Self-Refine 等推理策略。
- **其他**：`-g` 指定輸出語言、context／session、Pattern 變數、`--dry-run`／`--print-prompt` 預覽送出的 prompt（不花 API 額度）、生圖、Gemini TTS、桌面通知。
- **REST API**：`fabric --serve` 提供 HTTP API（含 Swagger 文件）；加 `--serveOllama` 可偽裝成 Ollama 端點，讓只支援 Ollama 的應用把 Pattern 當模型用（如 `summarize:latest`）。
- **網頁介面**：repo 內附 Web App 作為 CLI 以外的 GUI。

## 安裝與使用方式

```bash
# 一行安裝（macOS／Linux）
curl -fsSL https://raw.githubusercontent.com/danielmiessler/fabric/main/scripts/installer/install.sh | bash
# 其他：brew install fabric-ai、yay -S fabric-ai、winget install danielmiessler.Fabric、
#       scoop install fabric-ai、go install github.com/danielmiessler/fabric/cmd/fabric@latest、Docker

fabric --setup                       # 互動式設定供應商金鑰、預設模型、Patterns
pbpaste | fabric -p summarize        # 摘要剪貼簿內容
fabric -u https://example.com -p analyze_claims
```

- Homebrew 與 AUR 安裝後指令名稱是 `fabric-ai`，README 建議加 `alias fabric='fabric-ai'`。
- 抓 YouTube 字幕需另外安裝 **yt-dlp**；抓留言與 metadata 才需要 YouTube API 金鑰。

## YouTube 影片摘要流程（整理自教學文章）

AI 郵報的中文教學把重點放在「一行指令把影片變成繁中筆記」：

```bash
fabric -y "YouTube 影片網址" --pattern extract_wisdom -g zh-TW -o 筆記.md
```

抓字幕 → 套 `extract_wisdom` → 用繁中輸出 → 存成 Markdown。文章推薦的入門 Pattern：

| Pattern | 用途 |
|---|---|
| `extract_wisdom` | 長影片、Podcast、文章：一句話摘要、觀點、洞見、金句、習慣、提到的書與工具 |
| `analyze_claims` | 新聞、公關稿、評論的事實查核：主張、正反證據、邏輯謬誤、可信度評分 |
| `summarize_paper`／`analyze_paper` | 學術論文的假設、方法、樣本限制與結論 |
| `create_micro_summary` | 把會議記錄濃縮成一句結論、幾項決策與下一步 |
| `create_quiz` | 從教材出測驗題 |
| `improve_writing`／`write_essay` | 修潤文稿 |
| `extract_poc` | 從資安報告整理 PoC 步驟與影響範圍 |
| `rate_content` | 評估內容資訊密度與原創性，決定值不值得看完 |

文章的其他建議：

- 長逐字稿用 Gemini 的免費 AI Studio 金鑰（長上下文）；機密資料用 Ollama 跑本機模型（如 Qwen、Llama），不離開電腦。
- 可以照 Pattern 的結構自己寫團隊共用模板。
- 不寫程式也行：把 `system.md` 貼進聊天工具的系統提示，再加一句「請用繁體中文回答」。

## 適用情境

- 想把「摘要 YouTube／Podcast／文章」「事實查核」「整理會議記錄」做成可重複、格式固定的流程。
- 想要一套經過整理的 prompt 範本庫，貼進自己慣用的聊天介面就能用。
- 習慣命令列，想用管線把 LLM 串進 shell 腳本、Obsidian 筆記等既有工作流。
- 想讓只支援 Ollama API 的應用改用雲端模型或套上固定 Pattern。

## 授權與成本

- **程式碼與 Patterns**：MIT，免費。
- **模型費用**：依所選供應商計費；用 Ollama、LM Studio 等本機模型則不需 API 費用。Jina 網頁擷取、Parallel 匿名搜尋有免費額度與速率限制。

## 限制與注意事項

- `-y` 只能處理**有字幕**（作者上傳或自動產生）的影片；沒字幕的要先自行轉錄（或用 `--transcribe-file` 走 OpenAI 語音轉文字）。
- Patterns 以英文撰寫，不指定 `-g` 或中文指示時，模型常會用英文回答。
- 267 個 Pattern 有不少是資安、程式等特定用途，一般使用者只會用到少數幾個。
- 教學文章的數字多已過時或未經查證：文章說「近 3 萬星」（查證時約 4.47 萬）、「200 多個 Pattern」（查證時 267 個）、「2 小時影片 20 秒內處理完」（未附依據，實際取決於模型與字幕長度）；文章舉的 Gemini 1.5 已是舊模型。`extract_wisdom` 的實際規格是 20～50 個觀點、10～20 個洞見、15～30 句金句，比文章寫的固定數字更彈性。
- 用 `--yt-dlp-args="--cookies-from-browser ..."` 處理年齡限制影片時會讀取瀏覽器 cookie，有帳號風險，也可能違反 YouTube 條款。
- 網頁擷取（`-u`）會把目標網址送到 Jina AI；雲端供應商也會收到你的輸入內容，機密資料請用本機模型。
- 很多 YouTube 教學影片是 Python 版時期錄的，安裝方式已不同，請以 README 為準。
- 文章末段夾帶與 Fabric 無關的券商推廣內容。

## 相關工具

- [last30days](last30days.md)：研究近 30 天社群討論的 agent skill，也會讀 YouTube 字幕，但重點是跨平台蒐集與排序，而不是套固定模板。
- [DSPy](DSPy.md)：用程式自動最佳化 prompt；Fabric 則是人工撰寫、可讀的 prompt 範本。
- [Promptfoo](Promptfoo.md)：可用來評測、比較自己改寫的 Pattern。

## 資料來源

- https://github.com/danielmiessler/Fabric（README、repo 資訊、releases、`data/patterns/`、`docs/YouTube-Processing.md`、`extract_wisdom/system.md`）
- https://www.aiposthub.com/fabric-open-source-ai-prompt-patterns-youtube-summary/
