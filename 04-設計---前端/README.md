# 🎨 設計 / 前端

讓 AI 做出好看網頁與簡報的資源：設計提示詞庫、給 agent 的動畫 skill、互動插圖元件、網頁 3D 函式庫、skill 與作品範例，以及 agent 專用的簡報框架。

## 網站設計提示詞

### [MotionSites](MotionSites.md)

販售網站設計提示詞的線上庫，主打 3D、動態與 landing page 風格：複製提示詞，貼到 Lovable、Bolt、Cursor、Claude 就能生成網站。另有 MCP。商業服務。

可以做到：
- 快速做出有動態效果的 landing page、Hero 區、作品集或 SaaS 官網。
- 接案時快速做原型或提案頁。
- 學習怎麼寫高品質的網站生成提示詞。

## 網頁動畫與插圖

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

### [Motion Prompt](Motion-Prompt.md)

一組具名的動態效果清單（168 個，分七組：動態圖形、鏡頭運動、UI 元件、landing page 特效、攝影風格），每個名稱附動態範例與提示語。附 `motion-prompt` skill，agent 可依編號重建效果。MIT。

可以做到：
- 向 AI 或同事用精確名稱描述動態效果，減少「做得精緻一點」這類模糊需求。
- 在 landing page、UI 元件中快速套用有名稱的動作，並由 agent 在專案中重建。
- 為自己的領域製作類似的名稱庫（`make-your-own/` 內附提示詞）。

## 網頁 3D

### [three.js](three.js.md)

網頁上最常用的 JavaScript 3D 函式庫，內建 WebGL 與 WebGPU renderer，附大量 addon（GLTF 載入、相機控制、後製特效、WebXR）。MIT。

可以做到：
- 產品官網、landing page 的 3D 主視覺與互動展示。
- GLTF 模型檢視器、產品設定器、資料視覺化、網頁遊戲與 WebXR。
- 讓 AI agent 生成可直接在瀏覽器執行的 3D 作品。

### [threejs-skills](threejs-skills.md)

給 Claude Code 的 10 個 three.js skill，涵蓋基礎場景、幾何、材質、光照、貼圖、動畫、載入器、shader、後製特效與互動。⚠️ README 寫 MIT，但 repo 未附 LICENSE 檔。

可以做到：
- 讓 Claude Code 寫 three.js 時少犯 API 錯誤（類別名稱、匯入路徑、色彩空間）。
- 快速產出 3D 主視覺、GLTF 模型檢視器與互動式 3D 網頁。
- 自訂 shader、bloom 等後製特效，或滑鼠點選、相機控制等互動。

### [Anatomy](Anatomy.md)

用 Next.js + Three.js 做的互動式 3D 人體器官教學網站（由 GPT 生成），偏參考作品而非工具。⚠️ 未附授權檔，也不適合當醫學參考。

可以做到：
- 參考 AI 產出的 Three.js 互動 3D 網站長什麼樣子。
- 參考 3D 熱點標註、測驗互動、多語系（含 RTL）的實作方式。

## 簡報

### [open-slide](open-slide.md)

為 AI agent 打造的簡報框架：由 Claude Code 等 agent 寫內容，每張投影片是 1920 × 1080 畫布上的任意 React component。MIT。

可以做到：
- 用 agent 快速產出技術分享、產品介紹等簡報。
- 放入互動元件、動畫或程式碼展示，做一般簡報軟體做不到的投影片。
- 把簡報當程式碼管理（版本控制、PR 審查），匯出 HTML／PDF／PPTX 或直接部署成網站。

## 怎麼挑

- 要**整個網站的設計方向**：MotionSites。
- 要**網頁動畫寫得對**：GSAP Skills；要**互動插圖**：Hairline；要**用名稱指定動態效果**：Motion Prompt。
- 要**網頁 3D**：three.js；讓 Claude Code 寫 three.js 更準，加上 threejs-skills；想看 AI 做出來的 three.js 網站長什麼樣子：Anatomy。
- 要**簡報**：open-slide。
