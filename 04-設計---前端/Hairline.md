# Hairline

- **分類**：設計 / 前端（互動插圖）/ Agent Skill
- **連結**：https://github.com/lucasmarkes/hairline
- **官網**：https://hairline.lucasmarkes.com

## 原清單說明

（AI郵報〈2026 Claude Code 做影片 Skills 推薦〉）— 製作等角（isometric）線條插圖的 Skill，圖形會跟著滑鼠反應，輸出單一 HTML 檔。

> **查證結果**：大致相符，但 Hairline 其實包含兩部分：
> - npm 套件 `@lucasmarkes/hairline`：現成的等角線條圖形元件。GitHub 簡介仍寫「六個」，README 已增加到 33 個。
> - `hairline-create` skill：讓 agent 依規則畫新的圖形，輸出單一 HTML 檔。這是 AI郵報介紹的部分。
>
> 授權為 MIT。

## 概述

Hairline 是一組以細線繪製的等角視角圖形，會回應滑鼠指標，例如卡片在指標下立起、柱子在指標周圍升高、App 視窗分層展開。可以當 React 元件使用，也能用在任何有 DOM 的環境。

作者 Lucas Marques 另外提供 `hairline-create` skill：給 agent 一個點子，它會依照 Hairline 的十條設計規則，在同一個引擎上畫出新圖形，並交付一個沒有任何依賴、可直接從硬碟開啟的 HTML 檔。

repo 於 2026-10-01 建立，查詢當下（2026-10-13）約 1.9k 顆星，npm 最新版為 0.5.0。

## 核心功能／特色

- **33 個現成圖形**：例如 `Riffle`（卡片匣）、`Terrain`（81 根柱子）、`Exploded`（分層的 App 視窗）、`Phosphor`（點陣螢光）、`Keyboard`、`Laptop`、`Terminal`、`Branches`（commit 圖）、`Vault`、`Router` 等，每個都有自己的指標互動方式。
- **統一選項**：
  - `intensity`：反應強度，0–1。
  - `theme`：`auto`、`light` 或 `dark`。
  - `label`：無障礙名稱。
  - `onRead`：圖形說明文字改變時的回呼。
  - `play`：沒有指標時自動循環展示。
- **主題**：以六個 CSS 自訂屬性設定顏色與線寬，例如 `--hairline-plate`、`--hairline-hi`、`--hairline-stroke`。
- **無障礙與效能**：
  - 遵守 `prefers-reduced-motion`。
  - 所有圖形共用一個 `requestAnimationFrame` 迴圈，畫面外或靜止時不運算。
  - SSR 時先輸出 5:4 的空框，避免版面跳動。
- **`hairline-create` skill**：
  1. 提出 2–3 個概念。
  2. 畫出使用者選定的那一個。
  3. 依規則並在瀏覽器中檢查。
  4. 輸出 `hairline-<name>.html`，內附播放按鈕可以展示互動。

## 技術架構或運作原理

以 TypeScript 撰寫，無任何依賴，只提供 ESM。React 18 以上為選用的 peer dependency，只有 `@lucasmarkes/hairline/react` 會用到。每個圖形是一個函式，例如 `terrain(el, options)`，回傳包含 `update()` 與 `destroy()` 的物件，形式剛好符合 Svelte action。圖形依容器寬度、以 5:4 比例繪製。

## 安裝與使用方式

```bash
npm i @lucasmarkes/hairline
# 或用 shadcn（會一併加入讀取主題 token 的 wrapper）
npx shadcn@latest add https://hairline.lucasmarkes.com/r/hairline.json
```

```tsx
import { Terrain } from "@lucasmarkes/hairline/react";
export function Hero() { return <Terrain />; }
```

使用 skill 畫新圖形：

```bash
npx skills add lucasmarkes/hairline
```

```text
/hairline-create a sales funnel
```

## 適用情境

- 產品官網、landing page 的互動式主視覺。
- 技術產品的概念插圖（伺服器機櫃、commit 圖、呼叫堆疊）。
- 用 agent 快速做出風格一致的自訂互動插圖。

## 授權與成本

- **授權**：MIT（© Lucas Marques）。
- **成本**：免費。

## 限制與注意事項

- 輸出的是網頁互動元件或 HTML，不是影片檔；要放進影片需要另外錄製或用 HTML 影片框架處理。
- 圖形需要 DOM，在伺服器端只會輸出空框，函式要在 effect 或 `onMount` 中呼叫。
- `--hairline-plate` 要設成頁面背景色：圖形底板是填色而非透明，背景不是白色或 `#08090a` 時要自己設定。
- 專案很新（2026-10 建立），版本仍在 0.x。

## 相關工具

- [GSAP Skills](GSAP-Skills.md)：網頁動畫 skill
- [MotionSites](MotionSites.md)：高質感網站 prompt 庫
- [HyperFrames](../03-影片製作/HyperFrames.md)：可以把 HTML 動畫渲染成影片

## 資料來源

- https://github.com/lucasmarkes/hairline （README，以 GitHub API 取得原文）
- https://api.github.com/repos/lucasmarkes/hairline （星數、MIT、建立時間）
- https://registry.npmjs.org/@lucasmarkes/hairline/latest （npm 最新版本號 0.5.0）
- https://www.aiposthub.com/claude-code-video-skills-2026/ （AI郵報，2026-10-11）
