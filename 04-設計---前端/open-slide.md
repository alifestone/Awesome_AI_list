# open-slide

- **分類**：設計 / 前端（簡報）
- **連結**：https://github.com/open-slide/open-slide
- **官網**：https://open-slide.dev

## 原清單說明

原本放在 Design，連結誤指向數位病理函式庫 OpenSlide（`openslide/openslide`）。經確認，正確的專案是 `open-slide/open-slide`。

> **查證結果**：open-slide 是「為 AI agent 打造的簡報框架」（A slide framework built for agents）。用自然語言描述簡報，由 coding agent 寫 React，框架負責畫布、縮放、換頁、熱重載與簡報模式。和數位病理的 OpenSlide 是不同專案。

## 概述

open-slide 是開源的簡報框架，本身不含 AI 模型，而是讓 Claude Code、Codex、Cursor 這類 coding agent 負責撰寫內容，框架提供執行環境。每張投影片都在固定的 1920 × 1080 畫布上渲染，頁面可以是任意 React component，沒有自訂 DSL 的限制。

專案由 Yiwei Ho（GitHub `1weiho`）建立，2026-04 開始，參與 Vercel OSS Program。查閱時 GitHub 顯示約 9.2k stars、664 forks；最新版本為 **`@open-slide/core@2.2.0`（2026-10-12）**。

## 核心功能／特色

- **Agent 原生撰寫**：支援 Claude Code、Codex、Cursor 等 coding agent
- **內建 skill**：
  - `/create-slide`：先問清楚範圍，再草擬整份簡報
  - `/slide-authoring`：agent 撰寫前閱讀的技術參考
  - `/apply-comments`：套用瀏覽器中留下的修改意見，並清除標記
- **瀏覽器內 inspector**：comment 模式下可點選或框選元素留下修改意見，意見以 `@slide-comment` 標記存進原始碼
- **素材管理**：每份簡報管理自己的圖片、影片與字型，可透過 svgl 目錄搜尋 logo
- **簡報模式**：全螢幕播放與鍵盤換頁；講者畫面顯示目前與下一張、講者備註與計時器
- **匯出**：靜態 HTML、PDF、PPTX；PPTX 在瀏覽器中產生，輸出原生文字框、形狀與圖片
- **簡報管理**：資料夾、自訂 emoji、拖放排序
- **部署**：產出靜態網站，可放到 Vercel、Cloudflare Pages、Zeabur、Netlify

## 技術架構或運作原理

- TypeScript、React、Vite（core 套件內含 Vite plugin）
- pnpm + Turbo monorepo，Biome 做 lint，Vitest 做測試
- 套件：`@open-slide/core`（runtime 與 CLI）、`@open-slide/cli`（專案腳手架）、`apps/demo`（範例 workspace）
- 產生的 workspace 已為 Claude Code 預先設定，附 `CLAUDE.md` 與 `AGENTS.md` 規範 agent 行為

流程：agent 依 skill 撰寫 React 投影片 → 開發伺服器熱重載預覽 → 在瀏覽器留 comment → agent 以 `/apply-comments` 修改 → 匯出或部署。

## 安裝與使用方式

```bash
npx @open-slide/cli init my-slide
cd my-slide
pnpm dev
```

接著在專案目錄中開啟 coding agent（例如 Claude Code），輸入 `/create-slide` 描述想要的簡報。

## 適用情境

- 用 AI agent 快速產出技術分享、產品介紹等簡報
- 需要互動元件、動畫或程式碼展示，一般簡報軟體做不到的投影片
- 把簡報當程式碼管理（版本控制、PR 審查）
- 產出可直接部署成網站的簡報

## 授權與成本

- **授權**：MIT（© Yiwei Ho）。
- **成本**：框架免費；coding agent 的訂閱或 API 費用自付。

## 限制與注意事項

- 固定 1920 × 1080 畫布，其他比例需自行調整。
- 需要 Node.js、pnpm 與 coding agent；沒有不寫程式的圖形化編輯介面。
- README 未說明 PPTX 匯出的保真度限制，複雜動畫或互動元件在 PPTX／PDF 中可能無法保留。
- README 未提及 MCP 支援。

## 相關工具

- [HyperFrames](../03-影片製作/HyperFrames.md)：同樣讓 agent 寫 HTML／React 產出內容（影片）
- [MotionSites](./MotionSites.md)：高質感網站 prompt 庫
- Slidev、reveal.js：以程式碼製作簡報的傳統框架

## 資料來源

- https://github.com/open-slide/open-slide
- https://open-slide.dev
