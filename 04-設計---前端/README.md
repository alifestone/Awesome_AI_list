# 🎨 設計 / 前端

讓 AI 做出好看網頁與簡報的資源：設計提示詞庫、給 agent 的動畫 skill、互動插圖元件，以及 agent 專用的簡報框架。

### [MotionSites](MotionSites.md)

販售網站設計提示詞的線上庫，主打 3D、動態與 landing page 風格：複製提示詞，貼到 Lovable、Bolt、Cursor、Claude 就能生成網站。另有 MCP。商業服務。

可以做到：
- 快速做出有動態效果的 landing page、Hero 區、作品集或 SaaS 官網。
- 接案時快速做原型或提案頁。
- 學習怎麼寫高品質的網站生成提示詞。

### [GSAP Skills](GSAP-Skills.md)

GSAP 官方提供給 coding agent 的 skill 組，教 agent 正確使用核心 API、時間軸、ScrollTrigger、各種外掛與框架整合。MIT。

可以做到：
- 讓 agent 寫出正確的捲動動畫、時間軸動畫與文字特效。
- 在 React／Vue／Svelte 中寫動畫，並避免忘記清理造成記憶體洩漏。
- 搭配 HyperFrames，用 GSAP 時間軸做影片動畫。

### [Hairline](Hairline.md)

一組細線繪製、會回應滑鼠的等角視角互動圖形（卡片立起、柱子升高、視窗分層展開），可當 React 元件或用在任何 DOM 環境。附 `hairline-create` skill。MIT。

可以做到：
- 產品官網、landing page 的互動式主視覺。
- 技術產品的概念插圖（伺服器機櫃、commit 圖、呼叫堆疊）。
- 讓 agent 依十條設計規則畫出風格一致的新圖形，交付免依賴的單一 HTML 檔。

### [open-slide](open-slide.md)

為 AI agent 打造的簡報框架：由 Claude Code 等 agent 寫內容，每張投影片是 1920 × 1080 畫布上的任意 React component。MIT。

可以做到：
- 用 agent 快速產出技術分享、產品介紹等簡報。
- 放入互動元件、動畫或程式碼展示，做一般簡報軟體做不到的投影片。
- 把簡報當程式碼管理（版本控制、PR 審查），匯出 HTML／PDF／PPTX 或直接部署成網站。

## 怎麼挑

- 要**整個網站的設計方向**：MotionSites。
- 要**網頁動畫寫得對**：GSAP Skills；要**互動插圖**：Hairline。
- 要**簡報**：open-slide。
