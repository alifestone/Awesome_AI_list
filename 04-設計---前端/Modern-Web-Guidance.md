# Modern Web Guidance

- **分類**：設計 / 前端 / 網頁平台最佳實務
- **連結**：https://github.com/GoogleChrome/modern-web-guidance
- **官網**：https://developer.chrome.com/docs/modern-web-guidance
- **原始碼**：https://github.com/GoogleChrome/modern-web-guidance-src

## 概述

給 coding agent 的 skill，讓 agent 寫 HTML、CSS 與前端 JavaScript 時改用現代瀏覽器原生功能（`<dialog>`、Popover、Anchor Positioning、container queries、View Transitions 等），而不是訓練資料裡常見的舊寫法或肥大的 JS 套件。由 Google Chrome 團隊發起，README 寫明與 Microsoft Edge、Mozilla Firefox、MDN 團隊及社群共同維護。

做法是附一個 CLI：agent 遇到前端任務時先用 `search` 找相關指南，再用 `retrieve` 把指南（程式碼範例、陷阱、退回方案）放進 context。指南依 Baseline 相容性資料判斷哪些功能可以直接用、哪些要附退回方案。

repo 於 2026-03-23 建立，v1.0.0 於 2026-11-10 發布；查詢當下（2026-11-13）約 7.0k 顆星。

## 核心功能／特色

- **涵蓋範圍**：README 列出 250 個網頁平台功能（CSS 與版面 140、HTML 與 DOM 36、JavaScript 與 API 74），整理成 203 份以使用情境命名的指南。
- **指南分類**：使用者體驗（View Transitions、進出場動畫、捲動動畫）、CSS 版面（container queries、`subgrid`、`oklch`、`text-wrap`）、效能（預先載入、INP 診斷、`scheduler.yield`）、表單與 UI（Popover、dialog、客製 `<select>`、`:user-invalid`、autofill）、無障礙，以及瀏覽器內建 AI（Translator、Summarizer、Language Detector、Prompt API）。
- **安全採用新功能**：區分可被舊瀏覽器忽略的增強功能與需要退回方案的關鍵功能；偏好小於 50 行的自寫退回方案或按需載入的 polyfill，不引入大型套件；記錄平台限制（例如 `fetchLater()` 的 64KB 上限）。
- **實驗功能閘門**：Origin Trial 與「不穩定功能」（只有單一引擎支援、上線未滿 3 個月）的指南可以搜到，但 `retrieve` 時會擋下，需在專案的 `.mwgrc` 設 `allowOriginTrials`／`allowVolatileFeatures` 才會給。
- **`legacy-scan`**：掃描專案裡可現代化的舊寫法（只涵蓋約 20% 有明確規則的指南），agent 再逐項核對、改寫並重掃確認。
- **兩個 skill 套件**：`modern-web-guidance`（約 205 tokens）與 `chrome-extensions`（Manifest V3、背景 service worker、擴充功能 API、Chrome Web Store 上架與審查被拒的回覆）。

## 技術架構或運作原理

1. agent 依 `SKILL.md` 的描述在前端任務時啟用 skill。
2. 執行 `npx -y modern-web-guidance@latest search "<2–5 字的查詢>"`：在本機用離線、零依賴的 embedding 模型加 BM25 比對指南，不需 API key。
3. 執行 `retrieve "<guide-id>"` 取回指南全文；可一次取多份，包括 `css`、`forms`、`accessibility` 等整體規範。
4. agent 依指南寫程式並自我檢查，最後在回覆末尾加一段 `### Modern Web Guidance`，說明用了哪份指南、避開了什麼陷阱。

npm 套件自帶全部內容、沒有其他依賴。repo 內附 Claude Code、Codex、Cursor、Grok、Kimi、Gemini 等 plugin 設定。

**評測**：團隊用真實網頁應用（`daily-grind`、`devtools-times`）出題，題目不點名 API，再用 Playwright 檢查原始碼、計算後樣式、DOM 行為與無障礙狀態。README 列的 2026-11-08 結果：Claude Code（Opus 5.5）通過率 57% → 88%（+31pp），Codex CLI 54% → 82%，Antigravity CLI 58% → 94%。完整數據在 [Eval Dashboard](https://googlechrome.github.io/modern-web-guidance-src/)。

## 安裝與使用方式

```bash
# 互動式安裝精靈（--choose 可挑 skill 套件）
npx modern-web-guidance@latest install

# 不安裝直接試用
npx modern-web-guidance@latest search "animate a dialog modal backdrop"
npx modern-web-guidance@latest retrieve "animate-to-from-top-layer"
npx modern-web-guidance@latest legacy-scan .

# 更新
npx modern-web-guidance@latest update
```

其他安裝方式：

- **Claude Code**：`/plugin marketplace add GoogleChrome/modern-web-guidance`，再 `/plugin install modern-web-guidance@googlechrome`
- **Codex**：`codex plugin marketplace add GoogleChrome/modern-web-guidance`，再 `codex plugin add modern-web-guidance@googlechrome`
- **skills CLI**：`npx skills add GoogleChrome/modern-web-guidance`
- **GitHub CLI**：`gh skill install GoogleChrome/modern-web-guidance`
- 另支援 GitHub Copilot CLI、Google Antigravity、Grok Build CLI、Kimi Code。

## 適用情境

- 讓 agent 做 dialog、popover、tooltip、客製下拉選單、深色模式時用原生功能，少裝 UI 套件。
- 表單驗證、autofill、無障礙與 Core Web Vitals（LCP、INP、CLS）照現行最佳實務寫。
- 掃描舊專案找出可改成原生功能的寫法，再讓 agent 逐項現代化。
- 用 agent 開發或上架 Chrome 擴充功能（`chrome-extensions` 套件）。

## 授權與成本

- **授權**：程式碼為 Apache-2.0；`guides/` 內的指南內容為 CC-BY 4.0，部分內容改寫自 MDN 與 W3C、WHATWG、IETF 規格。
- **成本**：免費。

## 限制與注意事項

- ⚠️ **預設開啟遙測**：會回傳安裝次數、呼叫的 agent 名稱、取用的指南 ID，以及 agent 產生的搜尋字串（不含使用者原始提示）。在 shell 設定檔加 `export DISABLE_TELEMETRY=1` 可關閉。
- 每次透過 `npx …@latest` 執行，第一次與版本更新時需要連網下載；在 Claude Code、Codex 等沙箱環境要先允許網路。之後可用 `npx --offline` 離線執行。
- `SKILL.md` 的描述寫明所有 HTML、CSS、前端 JS 任務都「必須先執行」，觸發相當積極；也會要求 agent 在每次回覆末尾加一段使用說明。不想要時可在 `CLAUDE.md`／`AGENTS.md` 另外規範。
- 指南以原生 HTML／CSS／JS 撰寫，用 React、Vue 等框架時由 agent 自行轉換。
- 評測數據來自團隊自建的應用與題目，不一定代表你的專案。

## 相關工具

- [GSAP Skills](GSAP-Skills.md)：同樣是教 agent 寫前端的官方 skill，專注 GSAP 動畫
- [Playwright](../08-瀏覽器自動化/Playwright.md)：本專案評測用的瀏覽器檢查工具

## 資料來源

- https://github.com/GoogleChrome/modern-web-guidance （README 與 `skills/*/SKILL.md`，以 GitHub API 取得原文）
- https://api.github.com/repos/GoogleChrome/modern-web-guidance （星數、Apache-2.0、建立時間、v1.0.0 發布日期）
- https://api.github.com/repos/GoogleChrome/modern-web-guidance-src （原始碼 repo，Apache-2.0）
