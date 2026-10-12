# HyperFrames

- **分類**：影片製作 / 程式化動畫 / HTML → 影片
- **連結**：https://github.com/heygen-com/hyperframes

## 原清單說明

（HeyGen）— 寫 HTML/CSS/動畫，渲染成確定性 MP4，專為 AI agent 設計。Apache-2.0。

> **查證結果**：與 README 相符。repo 由 heygen-com 組織維護，授權為 Apache-2.0。README 寫明 *same input, same frames, same output*（確定性渲染），標語是 *Write HTML. Render video. Built for agents.*

## 概述

HyperFrames 是開源框架，能把 HTML、CSS、媒體檔與「可跳轉（seekable）」的動畫渲染成確定性的 MP4 影片。它有三種用法：本機 CLI、透過 AI coding agent 的 skills，或作為託管創作流程的渲染核心。README 表示 HeyGen 已在正式環境使用，tldraw、TanStack 等團隊也有社群範例。

查詢當下（2026-10-13）約 61.6k 顆星，以 TypeScript 撰寫，npm 套件 `hyperframes` 最新版為 0.8.150。官網為 hyperframes.dev，文件在 hyperframes.heygen.com。

## 核心功能／特色

- **以 HTML 撰寫影片**：composition 就是一般 HTML 檔，用 `data-*` 屬性標記時間與軌道，例如 `data-start`、`data-duration`、`data-track-index`、`class="clip"`。不需要 React，也不需要 build 步驟，`index.html` 可以直接在瀏覽器預覽。
- **動畫以 adapter 接入**：支援 GSAP、CSS animation、Lottie、Three.js、Anime.js、WAAPI、TypeGPU，也能寫自訂的 frame adapter。
- **確定性渲染**：渲染器在 headless Chrome 中逐幀跳轉擷取畫面，再用 FFmpeg 編碼，同樣的輸入會得到同樣的影片，適合用在 CI 與回歸測試。
- **給 agent 用的 skills**：共 21 個已發布的 skill。
  - 入口是 `/hyperframes` 路由 skill。
  - 創作流程：`/product-launch-video`、`/faceless-explainer`、`/pr-to-video`、`/embedded-captions`、`/talking-head-recut`、`/motion-graphics`、`/music-to-video`、`/slideshow`、`/general-video`、`/remotion-to-hyperframes`。
  - 另有 core、animation、keyframes、audio、registry、figma 等領域 skill。
- **Catalog**：可直接安裝現成的 block 與元件，例如轉場、社群貼圖、圖表、地圖、特效。
- **frame.md**：把品牌的 design.md「轉譯成適合鏡頭的版本」，讓 agent 依設計系統產生影片。
- **其他元件**：Studio（瀏覽器編輯器）、`<hyperframes-player>` 網頁元件、WebGL shader 轉場、AWS Lambda 分散式渲染、HeyGen 託管的雲端渲染（`cloud render`）。

## 技術架構或運作原理

主要 npm 套件：

| 套件 | 用途 |
|---|---|
| `hyperframes` | CLI：init、preview、lint、check、snapshot、render、publish、doctor |
| `@hyperframes/core` | 型別、parser、linter、runtime、frame adapter |
| `@hyperframes/engine` | 以 Puppeteer + FFmpeg 擷取可跳轉頁面的引擎 |
| `@hyperframes/producer` | 完整渲染流程：擷取、編碼、混音 |
| `@hyperframes/studio` | 瀏覽器編輯器 UI |
| `@hyperframes/player` | 可嵌入網頁的播放器元件 |
| `@hyperframes/shader-transitions` | WebGL shader 轉場 |
| `@hyperframes/aws-lambda` | AWS Lambda 分散式渲染 |

README 說明 HyperFrames 受 Remotion 啟發，兩者都用 headless Chrome 加 FFmpeg。差別在撰寫模型：Remotion 以 React 元件撰寫並需要打包工具；HyperFrames 用純 HTML，不需 build。

## 安裝與使用方式

```bash
# Claude Code plugin
claude plugin marketplace add heygen-com/hyperframes
claude plugin install hyperframes@hyperframes   # 之後使用 /hyperframes:hyperframes

# 獨立安裝 skills（OpenCode 等）
npx skills add heygen-com/hyperframes
npx hyperframes skills update    # 給 agent 或非互動情境：只裝核心 skill 組

# 手動使用 CLI
npx hyperframes init my-video
cd my-video
npx hyperframes preview          # 瀏覽器即時預覽
npx hyperframes render           # 輸出 MP4

# 安裝 catalog 元件
npx hyperframes add data-chart
```

需求：Node.js 22 以上、FFmpeg。

## 適用情境

- 產品發表片、功能公告、網站導覽影片。
- PR 變更說明影片（含程式碼 diff 動畫、旁白、字幕）。
- 資料視覺化、chart race、地圖動畫。
- 社群短片（動態字幕、貼圖、配樂）、文件或 PDF 轉影片。
- 自動化內容流水線中需要可重現的動態圖像（CI 渲染）。

## 授權與成本

- **授權**：Apache-2.0。README 強調沒有按次渲染費用，也沒有商用門檻。
- **成本**：本地渲染免費。HeyGen 託管雲端渲染（`cloud render`）與 AWS Lambda 渲染的費用，README 沒有說明，**資料不足**。

## 限制與注意事項

- 動畫必須是「可跳轉」的，依賴實際時間（wall-clock）的動畫需要透過 adapter 處理，否則無法逐幀重現。
- README 標示 Studio 為「Available, evolving」，仍在演進中。
- 開發者若要 clone 完整 repo，需先安裝 Git LFS：回歸測試的基準影片約 240 MB。
- 以 skill 方式安裝時要選對範圍：
  - 互動式 picker 預設什麼都不勾。
  - 非互動執行若沒指定 `--skill`，會把 21 個 skill 全部裝上。
  - `skills add` 走 skills.sh registry，可能比 main 分支落後數小時。

## 相關工具

- Remotion（React 版的程式化影片框架，README 有比較表）
- [OpenMontage](OpenMontage.md)：把 HyperFrames 當作其中一種渲染 runtime
- [onetake](onetake.md)、[PDoomVideo](PDoomVideo.md)：同樣以 HTML 與 headless Chrome 渲染動畫
- GSAP、Lottie、Three.js

## 資料來源

- https://github.com/heygen-com/hyperframes （README，以 GitHub API 取得原文）
- https://api.github.com/repos/heygen-com/hyperframes （repo 中繼資料：星數、Apache-2.0、官網）
- https://hyperframes.heygen.com/introduction （官方文件介紹頁）
- https://registry.npmjs.org/hyperframes/latest （npm 最新版本號 0.8.150）
