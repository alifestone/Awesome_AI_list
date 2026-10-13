# Remotion

- **分類**：影片製作 / 程式化影片 / React → 影片
- **連結**：https://github.com/remotion-dev/remotion
- **Agent Skills**：https://github.com/remotion-dev/skills
- **官網**：https://remotion.dev

## 原清單說明

（AI郵報〈2026 Claude Code 做影片 Skills 推薦〉）— 用 React 寫影片的框架，官方提供 Agent Skills，涵蓋建立專案、字幕、渲染與互動編輯。個人、非營利組織與 3 人以下的營利公司可以免費商用。

> **查證結果**：與 README 和 LICENSE 相符。repo 的標語是 *Make videos programmatically with React*，README 開頭寫 *Video tools for the agent era*。官方 Agent Skills 放在獨立的 `remotion-dev/skills` repo。授權不是 OSI 開源授權，而是 Remotion 自訂的兩級授權（GitHub 顯示 NOASSERTION）。

## 概述

Remotion 是用 React 元件描述影片畫面、再渲染成影片的框架，2020 年推出，是「程式化影片」類工具中歷史最久、生態最完整的一個。README 現在把它定位成三種工作方式並存：用 coding agent 產生影片、在 Studio 裡拖放編輯、用程式碼接資料批次產出，三者共用同一份 React 程式碼作為唯一來源。

查詢當下（2026-10-13）主 repo 約 63.7k 顆星、5.0k forks，以 TypeScript 撰寫，npm 套件 `remotion` 最新版為 4.0.535。`remotion-dev/skills` 於 2026-01 建立，約 5.1k 顆星。

## 核心功能／特色

- **React 即影片**：每一幀都是 React 元件的渲染結果，可以接 API、資料庫或 JSON 批次產生影片。
- **官方 Agent Skills**（`remotion-dev/skills`，適用 Claude Code、Codex、Kimi Code、Cursor）：
  - `/remotion-best-practices`：總入口，包含其他所有 skill。
  - `/remotion-create`：建立新專案或 composition。
  - `/remotion-markup`：撰寫 composition、動畫、排版、字型、媒體與音訊的最佳實務。
  - `/remotion-studio`、`/remotion-render`：開啟預覽、渲染影片或靜態圖。
  - `/remotion-captions`：字幕。
  - `/remotion-maps`：地圖與路線動畫（Mapbox、MapLibre、GeoJSON、CesiumJS 3D 飛越）。
  - `/remotion-interactivity`：讓元素能在 Studio 中被選取與編輯。
  - `/remotion-saas`：以 Remotion 為核心做產品或 SaaS 的架構建議。
  - `/remotion-docs`、`/remotion-upgrade`、`/remotion-multimedia`：查文件、升級套件、用 Mediabunny 處理媒體中繼資料。
- **元件庫**：官方提供 Elements、Effects、Shapes、Transitions、Sound Effects、Captions、Fonts 等現成元件與範本。
- **多種渲染方式**：Node.js SSR、AWS Lambda、Vercel Sandbox、瀏覽器端渲染。
- **做成應用**：`@remotion/player` 可嵌入網頁播放，Editor Starter 是付費的影片編輯器起始專案。

## 技術架構或運作原理

composition 以 React 撰寫，透過 `useCurrentFrame()` 等 API 取得目前幀數並計算畫面。渲染時由打包工具建置專案，在 headless Chrome 中逐幀截圖，再交給 FFmpeg 編碼。和 [HyperFrames](HyperFrames.md) 的主要差異是撰寫模型：Remotion 用 React 並需要 build 步驟，HyperFrames 用純 HTML。

## 安裝與使用方式

```bash
# 建立新專案（建立時可選擇一併安裝 Agent Skills）
npx create-video@latest
# 或
bun create video

# 在既有專案加入官方 Agent Skills
npx skills add remotion-dev/skills
```

之後在 coding agent 中輸入例如 `/remotion-create Make a promo video for a record store`。

## 適用情境

- 用 coding agent 產出知識動畫、產品介紹、社群短片。
- 依資料批次產生大量個人化影片（年度回顧、報表影片）。
- 在自家產品內嵌影片編輯或預覽功能。
- 作為其他 skill 的渲染引擎，例如 [Cinetic](Cinetic.md) 與 [OpenMontage](OpenMontage.md)。

## 授權與成本

- **授權**：Remotion 自訂授權，原始碼公開但不是開源授權。
  - **免費授權**：個人、3 人以下的營利公司、非營利組織，以及評估階段（尚未商用）可免費使用，商用也可以。
  - **公司授權**：4 人以上的營利組織需購買，價格見 remotion.pro。
  - 不得複製或修改 Remotion 程式碼來販售或再授權自己的衍生版本。
  - LICENSE 註明 Remotion 5.0 的授權條款會「略為調整」。
- **成本**：公司授權的實際價格本條目未查證，**資料不足**，請以 remotion.pro 為準。Lambda 等雲端渲染另有雲端費用。

## 限制與注意事項

- 公司規模達 4 人以上就要付費，商用前請先確認身分。
- AI郵報實測指出：沒有特別要求時，agent 做出來的成品容易變成單純的文字卡；想要圖示或流程動畫，提示詞要直接寫明。
- 需要 Node.js 環境，渲染相當吃 CPU。

## 相關工具

- [HyperFrames](HyperFrames.md)：受 Remotion 啟發的純 HTML 版本
- [Cinetic](Cinetic.md)：以 Remotion 為預設引擎的影片導演 skill
- [OpenMontage](OpenMontage.md)：可用 Remotion 作為渲染 runtime
- [GSAP Skills](../04-設計---前端/GSAP-Skills.md)

## 資料來源

- https://github.com/remotion-dev/remotion （README）
- https://github.com/remotion-dev/remotion/blob/main/LICENSE.md （授權條款）
- https://github.com/remotion-dev/skills （Agent Skills README）
- https://api.github.com/repos/remotion-dev/remotion （星數、建立時間）
- https://registry.npmjs.org/remotion/latest （npm 最新版本號 4.0.535）
- https://www.aiposthub.com/claude-code-video-skills-2026/ （AI郵報，2026-10-11）
