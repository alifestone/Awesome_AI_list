# AI Engineering from Scratch

- **分類**：學習資源 / 課程 / 教材
- **連結**：https://github.com/rohitg00/ai-engineering-from-scratch
- **網站**：https://aiengineeringfromscratch.com

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：repo 標語為 *Learn AI Engineering! Learn it. Build it. Ship it for others.* 由 Rohit Ghumare 與社群維護，MIT 授權。查詢當下（2026-11-06）約 7.7 萬顆星、1.36 萬個 fork，repo 建立於 2026-03-18，最後一次 push 為 2026-11-05。README 自述 542 堂課、20 個階段（phase），ROADMAP 中 542 堂全部標為完成（✅）。

## 概述

從數學基礎一路到 agent 與上線部署的大型開源 AI 工程課程。20 個階段由下往上疊：

```
Phase 0 設定與工具 → 1 數學 → 2 ML 基礎 → 3 深度學習
  → 4 視覺／5 NLP／6 語音／9 強化學習
  → 7 Transformer → 8 生成式 AI、10 從零做 LLM
  → 11 LLM 工程、12 多模態 → 13 工具與協定（MCP 等）
  → 14 Agent 工程 → 15 自主系統、16 多 agent、17 基礎設施與上線、18 倫理與對齊
  → 19 Capstone 專案
```

程式碼有 Python、TypeScript、Rust、Julia 四種語言。README 有 30 多種語言版本，含繁體中文（`i18n/zh-TW/README.md`）；課程內文 `docs/en.md` 是英文。

## 核心功能／特色

- **每堂課固定結構**：`code/`（可執行實作）、`docs/en.md`（課文）、`outputs/`（這堂課產出的 prompt、skill、agent 或 MCP server）。流程是 Motto → Problem → Concept → **Build It**（不用框架，從原始數學寫起）→ **Use It**（同樣的東西用 PyTorch／sklearn 再做一次）→ **Ship It**（產出可重用的工具）。
- **三種學法**：網站直接讀、讓 coding agent 當家教、clone 下來跑本機程式碼。
- **AI 家教 skills**：`start-learning`（入門測驗 + 個人化學習計畫，存到 `LEARNING.md`）、`learn`（一次教一堂課：概念、數學、程式、測驗）、`course-guide`（「我要學 attention」「loss 變 NaN」→ 指到對應課程）、`check-understanding <phase>`（各階段 8 題測驗）、`find-your-level`。
- **專題路線**：只學 MCP（17 堂，約 23 小時）、只學 Agent Skills（5 堂，約 9.5 小時）、逆向工程（Phase 13 第 32–45 堂，約 32.5 小時，只分析自己寫的程式）、用 coding agent 處理真實 repo、產品判斷與交付。
- **實作專題**：例如 Retrieval Evaluation Lab，有分階段的起始碼、參考實作與本機評分腳本（`scripts/project_test.py`）。
- **電子書**：核心課程由 CI 編成六冊 EPUB／PDF，附在每個 GitHub release。
- **認證準備**：Claude 認證四個軌道（`claude-certification` skill）與 MCP Associate（MCPA，34 堂）的備考教材。README 註明不是 Anthropic、Agentic AI Foundation 或 Linux Foundation 官方教材，也不含真實考題。

## 安裝與使用方式

讓 coding agent 當家教（需要 Node.js、`npx`；跑實驗需要 `python3`）：

```bash
npx skills add rohitg00/ai-engineering-from-scratch
```

安裝時選擇宿主（Claude Code、Codex、Cursor 等）與安裝範圍，之後在 Claude Code 輸入 `/start-learning`（Codex 用 `start-learning`）。只想學 MCP 用 `/learn-mcp`，只想學 Agent Skills 用 `/learn-agent-skills`。

本機跑程式碼：

```bash
git clone https://github.com/rohitg00/ai-engineering-from-scratch.git
cd ai-engineering-from-scratch
python3 phases/00-setup-and-tooling/01-dev-environment/code/verify.py --route beginner
python3 phases/01-math-foundations/01-linear-algebra-intuition/code/vectors.py
```

第一個指令檢查環境，缺什麼會附上修正指令；第二個不需要任何相依套件。

## 適用情境

README 建議的起點與時間估計：

| 背景 | 起點 | 估計時間 |
|---|---|---|
| 程式與 AI 都是新手 | Phase 0 | 約 306 小時 |
| 會 Python、不懂 ML | Phase 1 | 約 270 小時 |
| 懂 ML、不懂深度學習 | Phase 3 | 約 200 小時 |
| 懂深度學習，想學 LLM 與 agent | Phase 10 | 約 100 小時 |
| 資深工程師，只想學 agent 工程 | Phase 14 | 約 60 小時 |

## 授權與成本

- **授權**：MIT。README 寫明可以 fork、教學、販售，署名歡迎但非必要。
- **成本**：免費。部分課程（例如 LLM 工程、agent）會用到付費 LLM API 或 GPU。

## 限制與注意事項

- **規模很大**：542 堂課，不適合從頭掃到尾；建議先做入門測驗或挑一條專題路線。
- **時間估計前後不一**：ROADMAP 開頭寫總計約 332 小時，但各階段估計加起來遠超過這個數字（光 Phase 19 Capstone 就標約 620 小時）；README 的 306 小時也不同。把它當粗略參考就好。
- **課文是英文**：只有 README 有繁中翻譯。
- **AI 家教依賴宿主**：skill 呼叫語法、安裝目錄因宿主而異，README 提醒要自行確認宿主有讀到安裝位置。
- repo 建立不到一年、星數成長極快，內容仍在快速變動。

## 相關工具

- [Train LLM From Scratch](./Train-LLM-From-Scratch.md)：只專注在從零訓練 LLM 與後訓練，範圍較窄但更深入。
- [Learn Harness Engineering](./Learn-Harness-Engineering.md)、[EECS 498 AASE](./EECS-498-AASE.md)：專注在 coding agent 的工程實務。
- [50 ML Projects to Understand LLMs](./ML4LLM-Book.md)：LLM 內部機制與可解釋性。

## 資料來源

- https://github.com/rohitg00/ai-engineering-from-scratch
- https://github.com/rohitg00/ai-engineering-from-scratch/blob/main/ROADMAP.md
- https://aiengineeringfromscratch.com
