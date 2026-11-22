# last30days

- **分類**：Agent 框架與編排 / 應用工作流（近期社群動態研究 skill）
- **連結**：https://github.com/mvanhorn/last30days-skill （skill 規格：https://github.com/mvanhorn/last30days-skill/blob/main/skills/last30days/SKILL.md ；設定說明：https://github.com/mvanhorn/last30days-skill/blob/main/CONFIGURATION.md ）

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：repo 描述為 *AI agent skill that researches any topic across Reddit, X, YouTube, HN, Polymarket, and the web - then synthesizes a grounded summary.* 作者 Matt Van Horn（mvanhorn），v3 引擎架構由 @j-sperling 設計。查詢當下（2026-11-22）GitHub API 顯示約 72,000 顆星，repo 建立於 2026-01-23，最新 release 為 v4.5.0（2026-11-21），幾乎每隔幾天就發一版。MIT 授權。

## 概述

last30days 是一個 agent skill：輸入 `/last30days <主題>`，它會同時搜尋 Reddit、X、YouTube、TikTok、Hacker News、Polymarket、GitHub 等平台**過去 30 天**的內容，依按讚、留言、觀看數與預測市場的真金白銀排序，把同一件事在不同平台的討論合併成一群，最後由 agent 寫成一份附出處的摘要。作者的說法是「Google 彙整編輯的觀點，last30days 搜尋人的觀點」。

主題可以是人、公司、產品、技術或「X vs Y」比較。跑完一次之後，同一個 session 的 agent 就掌握了這些近期資料，可以接著追問、寫 prompt、擬信或規劃。

## 核心功能／特色

- **免設定就能用的來源**：Reddit（含熱門留言）、Hacker News、Polymarket、GitHub、StockTwits；主題是公司時，另外讀美國專利申請與官方徵才頁面。
- **設定精靈解鎖更多來源**：第一次執行會引導安裝免費的 arXiv、Techmeme、Yahoo Finance CLI；X、YouTube、TikTok、Instagram、LinkedIn、Bluesky、Threads、Pinterest、小紅書、Perplexity 等要另外提供金鑰、瀏覽器登入狀態或本機服務。
- **依互動數排序**：Reddit 讚數、X 按讚、YouTube 觀看與完整字幕、Polymarket 賠率與成交量都納入評分，同一事件跨平台合併。
- **公司「秘密訊號」**（v4）：從專利申請與徵才頁面中，只挑出不像該公司平常會做、或描述尚未發表產品的項目。上市公司另附 30 天股價對比 S&P 500。
- **引文行**：最有代表性的 Reddit、X、YouTube、TikTok 留言會放在它佐證的段落下方，必要時翻譯；影片裡講的話也能引用。
- **探索模式**：問「AI agents 最近什麼在爆紅？」會掃 Reddit 分類、HN 首頁、Digg 等，回傳 5–10 個依熱度排序的話題，每個附可直接執行的後續 `/last30days` 指令。
- **長期追蹤**：`--store` 把結果存進本機 SQLite，`watchlist.py` 做排程追蹤（可推到 Slack／webhook），`briefing.py` 產生每日／每週摘要。
- **研究資料庫**：存下的報告可搜尋（`library search`，離線）、可轉成本機 HTML 索引與 Atom feed（`library feed`）。
- **結構化輸出**：`--emit=json` 輸出有版本號的 JSON，方便接進其他工作流。

## 安裝與使用方式

```bash
# Claude Code（官方推薦，透過 marketplace 自動更新）
/plugin marketplace add mvanhorn/last30days-skill
/plugin install last30days

# Codex、Cursor、Copilot、Gemini CLI 等 50 多種 Agent Skills 宿主
npx skills add mvanhorn/last30days-skill -g

# OpenClaw
clawhub install last30days-official
```

另有 Grok Build CLI、Grok Bot marketplace、claude.ai 網頁版（上傳 `last30days.skill`）與 Claude Desktop（`.mcpb` MCP 套件，僅 macOS 與 Linux）的安裝方式。

```
/last30days Peter Steinberger          # 研究某個人近 30 天在做什麼
/last30days OpenClaw vs Hermes          # 比較工具
/last30days what's exploding in AI agents?   # 探索模式
```

直接呼叫引擎（腳本或開發用）：

```bash
python3 skills/last30days/scripts/last30days.py "AI coding agents" --emit=json
python3 skills/last30days/scripts/last30days.py --preflight   # 先看會讀寫什麼，不實際執行
```

需求：Python 3.12+；YouTube 需要 `yt-dlp`。報告預設存在 `~/Documents/Last30Days/`（`LAST30DAYS_MEMORY_DIR` 或 `--save-dir` 可改）。

## 適用情境

- 開會或業務拜訪前，快速掌握對方或對方公司這個月在做什麼、社群怎麼看。
- 追 AI 等變化很快的領域，找出社群已經摸索出來、但還沒進訓練資料的做法與 prompt 技巧。
- 選工具前看真實使用者的評價與踩雷經驗。
- 找即將爆紅的話題，當內容創作或 podcast 的選題來源。
- 定期追蹤競品、公司或關鍵字，自動推送新發現。

## 授權與成本

- **授權**：MIT。
- **成本**：預設來源免費。ScrapeCreators（TikTok、Instagram、Threads、Pinterest、LinkedIn、YouTube 留言）前 10,000 次免費，之後依用量付費；Brave Search 每月 2,000 次免費；Perplexity、X API 等依各自計費。

## 限制與注意事項

- **X 預設靠瀏覽器 cookie 爬取**：預設的 X 來源（vendored Bird client）讀取你已登入瀏覽器的 cookie 來搜尋，作者自己也說爬取「有一些帳號風險」。設定精靈會先問過才讀 cookie，也可以改用官方 X API 或其他 API 金鑰。
- **以登入帳號搜尋 Reddit 可能違反 Reddit 條款**：這是另外徵詢同意的選項，設定時會明講風險。
- **資料外送**：設定了 OpenAI、xAI、OpenRouter、Gemini 等推理金鑰時，研究主題與抓到的內容片段會送到該供應商做相關性排序；不設就用本機評分模型。
- `library feed --publish` 會把 HTML 索引與報告頁面公開發布（預設公開），只在確定要分享時才用。
- 很多來源要另外設定金鑰、CLI 或瀏覽器登入；可用的來源依環境與主題而異。
- README 的案例（人物、公司、新聞）是作者挑選的展示，品質會隨主題熱度與可用來源而不同；摘要仍由 LLM 撰寫，重要結論請點回原始出處確認。
- 更新非常頻繁（幾天一版），README 描述的是主分支，安裝的版本可能不同。
- Claude Code 不會合併不同安裝方式：同時裝 marketplace 外掛與 `npx skills` 版會出現兩個 `/last30days`，一台機器只用一種安裝方式。

## 相關工具

- [notebooklm-py](../14-RAG-知識庫與記憶/notebooklm-py.md)：把資料丟進 NotebookLM 整理；last30days 負責找社群近期討論，可以把報告再交給它做成知識庫或語音摘要
- [PaperOrchestra](PaperOrchestra.md)：學術論文寫作；需要的是近期社群動態而不是論文時改用 last30days（last30days 也能透過 arXiv 來源找新論文）
