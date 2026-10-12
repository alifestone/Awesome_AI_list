# MotionSites

- **分類**：設計 / 前端
- **連結**：https://motionsites.ai/

## 原清單說明

給 Lovable、Bolt、Cursor、Claude 用的高質感（3D／動態）網站 prompt 庫，另有 MCP。

> 查證結果：與原說明相符。官網標語為「Beautiful Website Prompts for Lovable, Bolt, Cursor, and Claude」，並提供 MotionSites MCP（官方 MCP 頁面列出支援 Claude、Cursor、Codex）。需注意它是**付費**提示詞庫，不是網站建置工具本身。

## 概述

MotionSites（亦寫作 Motionsites AI）是一個販售「網站設計提示詞（prompt）」的線上提示詞庫，主打 3D、動態與著陸頁（landing page）風格。使用方式是複製提示詞、貼到 Lovable、Bolt、Cursor、Claude 等 AI 建站／寫程式工具中，由該工具生成網站（官網用語：「Just copy, paste, and launch」）。

建立者為 Viktor Oddy（官網社群連結為 YouTube／X 帳號 @viktoroddy；Product Hunt 頁面亦由其介紹）。它與同一作者的 AI 設計課程網站 Design Rocket 相關聯。MotionSites 本身不提供網站託管、CMS 或部署功能。

## 核心功能／特色

- **網站提示詞庫**：MCP 頁面稱收錄 500+ 個高階網站設計提示詞（第三方整理網站 Stork 於 2026 年 7 月記錄為 364 個 prompt，數字隨時間變動）。
- **分類瀏覽**：Hero、Landing Page、SaaS、Creative、Agency、Portfolio、3D、AI、Fintech、Technology、Travel、Wellness、3D Website、Ecommerce、Carousel、Apps、Sections 等。
- **其他素材**：Animated Backgrounds（動態背景影片）、Sections（區塊）、Apps、40+ 個 Lovable 範本，以及新推出的 Restyle 功能（官網標示 New，細節資料不足）。
- **MotionSites MCP**：讓 AI 代理直接取用提示詞庫；使用者向代理描述需求，代理即從 MotionSites 拉取對應提示詞。
- **線上預覽**：首頁可瀏覽各設計的動態預覽（第三方評論指出首頁可當作免費視覺圖庫使用）。

## 技術架構或運作原理

- MotionSites 本身不是生成模型，而是**結構化提示詞**的集合。依第三方評論（rar.design、Product Hunt 介紹），提示詞是長篇的設計規格書，內容涵蓋：設計系統（色彩、圓角、字型的 CSS 變數）、版面（導覽列、Hero 區、CTA、Logo 跑馬燈）、字體排印（大小、字重、行高、漸層文字）、動態（Framer Motion 參數、hover 狀態、循環背景影片）與元件（Tailwind class、間距、透明度）。
- 公開提示詞主要以 **React + Tailwind CSS v4 + Framer Motion** 為技術棧，換用其他框架可能需要調整。
- **MCP**：以 HTTP transport 提供的遠端 MCP 伺服器（端點架設於 Supabase Functions），透過瀏覽器登入 MotionSites 帳號授權，**不需 API key**。MCP 暴露的工具名稱與功能清單：資料不足（官方頁面未列出）。

## 安裝與使用方式

**一般用法（複製提示詞）**

1. 於 motionsites.ai 瀏覽並挑選設計。
2. 複製提示詞（需登入；免費帳號可開啟 3 個提示詞）。
3. 貼到 Lovable、Bolt、Cursor、Claude（Claude Code）等工具中生成網站。
4. 依品牌替換文案、色彩、圖片與影片，必要時把畫面截圖回饋給 AI 工具迭代修改。

**MCP（Claude Code）**——官方頁面提供的指令：

```bash
claude mcp add motionsites --scope user --transport http https://xgdzyqfalbibzelpdpvr.supabase.co/functions/v1/mcp
```

接著在跳出的瀏覽器視窗登入並核准存取，即可要求代理產生設計。Cursor、Codex 的設定方式：資料不足（官方頁面僅有選項，未顯示具體設定）。

## 適用情境

- 快速製作視覺質感高、具動態效果的著陸頁、Hero 區、作品集或 SaaS 官網。
- 接案者為客戶快速做出原型或提案頁面。
- 學習「如何撰寫高品質網站生成提示詞」的參考範例。
- 搭配 Claude Code／Cursor 等代理，透過 MCP 在開發流程中直接取用設計提示詞。

## 授權與成本

**價格**（查證日 2026-10-13，官網 motionsites.ai/unlimited 所示，美元）：

| 方案 | 價格 | 計費 | 提示詞存取 |
|---|---|---|---|
| 3 Months | $129 | 每 3 個月，可隨時取消 | 合理使用：每日 3 次複製 |
| Yearly | $279 | 每年，可隨時取消 | 無限制 |
| Lifetime | $399（原價 $759，Founding Members 特價） | 一次付清 | 無限制，另含終身更新與搶先體驗 |

- 所有方案皆含：Apps、Animated Backgrounds、Sections、40+ Lovable 範本、MotionSites MCP、社群存取、「個人與客戶作品使用」、優先支援。
- 另有單次購買的提示詞包（$49），可購買數量頁面顯示不清，資料不足。
- 免費帳號可開啟 3 個提示詞；MCP 僅包含於付費方案。
- 價格變動頻繁：第三方資料曾記錄不同價位（例如 rar.design 2026-04 文章所記終身創始價 $29、Stork 2026-07 記錄年費 $149／終身 $349），購買前請以官網為準。

**使用條款（Terms of Use 摘要）**：

- 可將提示詞與原始碼用於自己的專案、修改，並可發布或販售用其做出的網站與 App（「Websites and apps you build with our prompts are yours」）。
- 不得轉售、再散布或分享提示詞文字或原始碼本身，不得在網路上重新發布提示詞庫內容，不得共用帳號、爬取或繞過付費牆。
- 訂閱自動續訂直到取消；退款條款另見 Refund Policy 頁面，具體內容資料不足（本次未能讀取該頁）。

## 限制與注意事項

- **必須另行使用 AI 建站／寫程式工具**（Lovable、Cursor、Claude 等），且這些工具本身可能另有費用；MotionSites 僅提供提示詞。
- 主要聚焦於 Hero 區與著陸頁，不涵蓋後端、內頁架構、CMS 或部署。
- 技術棧偏固定（React / Tailwind v4 / Framer Motion）。
- 生成結果仍取決於所用 AI 工具與模型，非零程式背景者仍有學習曲線。
- 動態網站在行動裝置上的效能表現：資料不足（Product Hunt 上有人提問但未見官方回覆）。
- 官網橫幅推廣同作者的 Design Rocket 課程，其宣稱（如「代理商收費 $5,000 的網站」）屬行銷用語，未經查證。
- 官方未公開提示詞的確切總數（不同頁面與第三方數字不一）。

## 相關工具

- **Lovable**、**Bolt**、**Cursor**、**Claude / Claude Code**、**Codex**：MotionSites 官方標示支援或 MCP 支援的 AI 建站／寫程式工具。
- **Design Rocket**（designrocket.io）：同作者的 AI 網站設計課程。

## 資料來源

- https://motionsites.ai/
- https://motionsites.ai/mcp
- https://motionsites.ai/unlimited
- https://motionsites.ai/terms
- https://www.producthunt.com/products/motionsites （經搜尋結果摘要）
- https://www.stork.ai/tools/motionsites-ai （經搜尋結果摘要）
- https://rar.design/posts/motionsites-ai-prompt-library
