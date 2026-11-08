# AI Job Search

- **分類**：Agent 框架與編排 / 應用工作流
- **連結**：https://github.com/ai-job-search-dev/ai-job-search（原 `MadsLorentzen/ai-job-search`，舊網址會轉址）

## 概述

AI Job Search 是建在 Claude Code 上的求職工作流框架：fork（或複製成私人 repo）、填好個人資料，就能讓 Claude 搜尋職缺、評估適配度、替每個職缺量身改寫 CV 與求職信、準備面試並追蹤結果。作者 Mads Lorentzen 原是地球物理學家，2025 年底被裁員後做了這套工具自用，README 自述投了 69 份客製化申請、拿到 20 次初面與 1 份合約，2026 年 6 月轉任 AI 工程師。

核心流程（建檔、適配評估、起草-審稿的申請管線）不綁語言與國家；附的職缺網站搜尋 skill 則以丹麥為主（Jobindex、Jobnet、Akademikernes Jobbank、Jobdanmark），另有不限國家的 LinkedIn 與 freehire.me 搜尋，其他市場可用 `/add-portal` 自行產生。

查閱時（2026-11-09）GitHub 顯示約 70.5k stars、22.7k forks；最新 release 為 v1.7.4（2026-11-02），最後 commit 2026-11-07，repo 建立於 2026-03。

## 核心功能／特色

### 指令

| 指令 | 功能 |
| --- | --- |
| **`/setup`** | 從 `documents/` 資料夾（CV PDF、LinkedIn 匯出、學位證書、推薦信、過去的申請）、貼上的 CV 或訪談建立個人檔案；可重跑。`/setup --section search` 只重設搜尋條件 |
| **`/scrape`** | 依個人檔案搜尋多個職缺網站、去重、依適配度排序 |
| **`/apply`** | 評估適配度，起草、審稿、編譯出客製化 CV 與求職信 |
| `/rank` | 平行 agent 依五個面向批次評分 scrape 結果，產出排名短名單；deal-breaker 一票否決 |
| `/interview` | 依面試階段產出準備包（當初投的職缺、CV、求職信與前幾輪回饋），研究公司與面試官，對應 STAR 範例，可模擬面試 |
| `/outcome` | 記錄面試、offer、拒絕或無回音，封存寄出的資料；`/outcome followup` 替沉寂的申請起草追蹤信（只起草、不寄出） |
| `/gmail-sync` | 從 Gmail 找面試邀請、測驗連結、拒絕等訊號，批次提出狀態更新供你核准 |
| `/notion-sync` | 單向把求職進度發布成唯讀的 Notion 資料庫 |
| `/html-report` | 產生離線、無外部依賴的 HTML 求職儀表板 |
| `/expand` | 掃描你個人檔案中連結的 GitHub、作品集、Kaggle、Google Scholar 與課程大綱，補充能力項目 |
| `/upskill` | 比對個人檔案與追蹤中的職缺，產出技能缺口熱圖與學習計畫 |
| `/add-template` | 註冊自己的 CV／求職信範本（LaTeX、Typst 或其他可命令列編譯成 PDF 的工具） |
| `/add-portal` | 調查某個職缺網站並產生搜尋 skill，正式註冊前會先實際查詢一次測試 |
| `/reset` | 清除個人資料或文件，需輸入 `RESET` 確認 |

### `/apply` 的流程

1. 解析職缺（URL 或貼上全文），先過一道**確定性的完整性檢查**（隱藏文字、不可見字元、像指令的句子、隱藏連結）
2. 依技能、經驗、文化、地點、職涯方向評估適配度
3. 用 LaTeX 起草 CV 與求職信
4. 另開一個**全新 context 的審稿 agent**，研究公司並批評草稿
5. 依回饋修改
6. 編譯 PDF（CV 用 lualatex、求職信用 xelatex），由 Claude 看渲染結果反覆調整，直到 CV 剛好 2 頁、沒有孤立的職稱，求職信剛好 1 頁
7. **ATS 檢查**：抽出 CV 的 PDF 文字層，確認聯絡資訊是純文字、沒有亂碼字形、閱讀順序正常，再計算職缺關鍵字覆蓋率；個人檔案不支持的關鍵字列為缺口，不硬塞
8. 附驗證清單交出結果

CV 超過 2 頁時，依「與職缺的相關度、在文件中的獨特性、求職信是否引用」為每一行評分，從總分最低的刪起，而不是機械地砍最舊的經歷。README 強調所有內容都對照真實個人檔案驗證，不會捏造技能或經驗。

## 技術架構或運作原理

- 本體是一個 Claude Code 專案：`CLAUDE.md` 放個人檔案與工作規則，`.claude/commands/` 是各指令，`.claude/skills/job-application-assistant/` 拆成個人檔案、行為側寫、寫作風格、評估框架、CV 範本、求職信範本、面試準備等檔案
- 職缺網站搜尋工具是 `.agents/skills/*-search/` 下的 Bun CLI，遵守同一套介面（`search`／`detail`、`--format json|table|plain`、`SKILL.md` 中的 `enabled:` 旗標、各自的測試），`/scrape` 會自動找到符合介面的 skill
- 子 agent（`posting-fetcher`、`posting-scorer`、`application-reviewer`）只有讀取、WebFetch、WebSearch 與受限的 Bash，沒有 Edit、Write
- `tools/` 下的 Python 腳本負責 PDF 版面與文字層驗證、職缺完整性檢查（`posting_guard.py`）、robots.txt 檢查、薪資查詢（自備資料）、上游更新預覽與 CI 資安檢查
- 預設 CV 範本為 moderncv（banking 風格），求職信為自製 `cover.cls`（Lato／Raleway 字型）
- 也提供 `AGENTS.md` 給 Codex、Antigravity、Gemini CLI 等使用；職缺搜尋 skill 可直接用，完整流程則有社群 fork 改寫

## 安裝與使用方式

需要：Claude Code（需付費訂閱或 API 額度，無免費方案）、Python 3.10+、[Bun](https://bun.sh)、含 `lualatex` 與 `xelatex` 的 LaTeX 發行版；`pypdf` 選用（ATS 檢查）。

```bash
# 自用建議建立私人 repo、把本 repo 設為 upstream（作法見 SETUP.md 第 8 節）
# 只有要貢獻回上游時才 fork
gh repo fork ai-job-search-dev/ai-job-search --clone
cd ai-job-search

python3 tools/install_portal_clis.py   # 以 --ignore-scripts 安裝各職缺網站 CLI

claude
# 在 Claude Code 裡：
/setup
/scrape
/apply https://jobindex.dk/job/1234567   # 抓不到時可直接貼職缺全文
```

更新建議對齊 tagged release（每週一次、通過 CI），合併前可用 `python3 tools/check_upstream_updates.py` 預覽會動到哪些個人化檔案。

## 適用情境

- 正在求職、需要大量投遞但每份都想客製化 CV 與求職信
- 想要 ATS 可解析、版面穩定的 LaTeX 履歷
- 需要面試準備、模擬面試與求職進度追蹤
- 想參考「Claude Code 專案 + 指令 + skill + 子 agent + 權限設定」組成一套非程式開發工作流的範例

## 授權與成本

- **授權**：MIT。
- **成本**：框架免費；需 Claude Pro／Max／Team 訂閱或 Anthropic API 額度（README 認為偶爾用的話 API 計費通常較便宜）。起草-審稿與 PDF 反覆編譯檢查會多花 token。

## 限制與注意事項

- **Fork 一定是公開的**：GitHub 不允許公開 repo 的私人 fork，而 `/setup` 會把姓名、聯絡方式、工作經歷、期望薪資寫進**受版本控制**的檔案。自用請建立私人 repo，不要直接 fork。
- **Prompt injection 風險**：LLM 會同時讀取不受信任的職缺內容與你的個人資料。專案以指令層規則（不照職缺內文指示做、不抓職缺內文的連結）加上權限層限制（deny 清單、子 agent 無寫入權、不附任何 hook）縮小風險，但 SECURITY.md 明說這不是沙盒，WebFetch 也不限網域；在陌生的職缺網站上，寄出前請自己看過抓到與寫出的內容。macOS／Linux 上建議開啟 Claude Code 的 Bash 沙盒。
- 內建的職缺網站搜尋以丹麥為主；`linkedin-search` 使用未登入的公開端點，自動存取違反 LinkedIn 服務條款，README 標示僅限個人使用、低頻率。
- 從其他 fork 複製來的搜尋 skill 會在你的機器上以預先核准的權限執行，不在專案資安政策涵蓋範圍內，使用前要讀完程式碼。
- LaTeX 編譯不會預先核准（避免連帶核准 `-shell-escape`），預設模式下每次編譯都會詢問。
- 本專案與 Anthropic 無關；README 聲明沒有任何相關的加密貨幣或代幣，聲稱有的都是詐騙。

## 相關工具

- [ECC](ECC.md)、[Superpowers](Superpowers.md)：同樣是 Claude Code 的大型 skill／指令組，但用途是軟體開發
- [agency-agents](agency-agents.md)：現成的專業 agent 人設集合

## 資料來源

- https://github.com/ai-job-search-dev/ai-job-search
- https://raw.githubusercontent.com/ai-job-search-dev/ai-job-search/HEAD/README.md
- https://raw.githubusercontent.com/ai-job-search-dev/ai-job-search/HEAD/SECURITY.md
- https://api.github.com/repos/ai-job-search-dev/ai-job-search
