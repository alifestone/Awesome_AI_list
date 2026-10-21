# PDoomVideo

- **分類**：影片製作 / 程式化影片（程式碼 → 影片）
- **連結**：https://github.com/JohnHeibel/PDoomVideo

## 原清單說明

Claude Opus 5.5 在 Claude Code 裡生成的音樂 MV 原始碼，可當程式化動畫參考。

> **查證結果**：與 README 相符。repo 是歌曲 *I'm Upping My P(doom)* 的 MV 原始碼，作者表示 repo 中的所有內容都由模型生成，在 Claude Code 中分兩輪完成。

## 概述

PDoomVideo 是 JohnHeibel 公開的音樂 MV 專案。成片發布在 [YouTube](https://youtu.be/8j-hR4fJywU)。作者給模型的指示只有兩項：使用 Claude 吉祥物「Clawd」的角色設計，以及讓每句歌詞都有有趣的畫面與轉場。場景構想完全由模型自行決定。

查詢當下（2026-10-13）約 2k 顆星，主要語言為 JavaScript。作者另外做了一個更通用、更穩定的 Claude 動畫基底專案 ClaudeAnimationBase（README 推薦，本次未查證內容）。

## 核心功能／特色

- **兩輪生成**：
  - 第一輪：Claude Opus 5.5（Medium），放在 `legacy/`。
  - 第二輪：Claude Opus 5.5，其餘全部內容。
- **模型自己寫的製作文件**：
  - `ANIMATION_GUIDE.md`：Opus 寫給平行執行的 subagent 的風格與程式指南。
  - `STORYBOARD.md`：第一輪完成後，Opus 依指示（使用 P5 筆刷、每個場景都要有視覺亮點、每個場景都要轉場到下一個）寫出的逐鏡分鏡。
- **九個章節**：`src/ch/` 每個檔案是一個章節；`src/` 放共用的 Clawd 角色、客串角色、道具、歌詞與時間軸。
- **筆刷風格**：使用 p5.js 與 p5.brush 繪製每一幀。

## 技術架構或運作原理

- `studio.html`：繪製每一幀的頁面，使用 p5.js 與 p5.brush。
- `render.mjs`：用 headless Chrome（puppeteer-core）逐幀繪製並存成圖檔，可以中斷後續跑，最後用 ffmpeg 把畫面與歌曲編碼成 MP4。
- `package.json` 的依賴：`p5`、`p5.brush`、`puppeteer-core`。
- 歌曲檔已附在 `assets/pdoom.mp3`。

## 安裝與使用方式

```bash
npm install
node render.mjs --frames=0:156.6 --workers=4   # 把所有幀繪製到 out/frames（可續跑）
node render.mjs --encode --out=out/pdoom.mp4   # 合併畫面與歌曲輸出 MP4
```

- 需要 Node.js、Google Chrome、ffmpeg。
- 如果 Chrome 不在 Windows 的預設路徑，加上 `--chrome=<chrome 路徑>`。

## 適用情境

- 參考 LLM 如何規劃並生成長篇程式化動畫：分鏡文件、subagent 風格指南、分章節的程式碼。
- 學習以 p5.js 加 headless Chrome 逐幀渲染、再用 ffmpeg 合成影片的做法。
- 研究用 Claude Code 做音樂 MV 的完整案例。

## 授權與成本

- **授權**：repo 中**沒有 LICENSE 檔**，GitHub API 也偵測不到授權。`package.json` 中的 `"license": "ISC"` 是 npm 初始化時的預設值，不能視為正式授權。**授權資料不足**，在沒有明示授權的情況下，不應假設可以自由重用程式碼。
- 歌曲來源：README 表示據作者查到的資訊，來自 2024 年的一支 YouTube 影片；歌詞說明引用自 Osmarks。歌曲與 Clawd 角色的權利都不屬於本 repo 作者，**重用前需另外確認權利**。
- **成本**：渲染工具都是免費軟體。生成這支影片花了多少模型費用，README 沒有說明，**資料不足**。

## 限制與注意事項

- 這是單一作品的原始碼，不是通用框架。若想做自己的作品，作者建議改用 ClaudeAnimationBase。
- 依賴本機的 Chrome 路徑，預設路徑以 Windows 為準。
- 包含歌曲與 Anthropic 吉祥物角色，授權狀況不明，不適合直接拿去商用。

## 相關工具

- [HyperFrames](HyperFrames.md)：通用的 HTML → 影片框架
- [onetake](onetake.md)：以 HTML 與 headless Chrome 製作動態影片的 agent skill
- [AutoMV](AutoMV.md)：多 agent 用影片生成模型從整首歌產生 MV，與本專案的程式化路線互補
- [Awesome Opus 5.5 Videos](Awesome-Opus-5.5-Videos.md)：大量 Opus 5.5 程式化動畫的 prompt 清單（無原始碼）
- p5.js、p5.brush、Puppeteer、ffmpeg
- ClaudeAnimationBase（同一位作者的通用基底，未查證）

## 資料來源

- https://github.com/JohnHeibel/PDoomVideo （README，以 GitHub API 取得原文）
- https://api.github.com/repos/JohnHeibel/PDoomVideo （repo 中繼資料：描述、星數、授權欄位為空）
- https://api.github.com/repos/JohnHeibel/PDoomVideo/contents/ （根目錄檔案清單，確認沒有 LICENSE）
- https://raw.githubusercontent.com/JohnHeibel/PDoomVideo/main/package.json （依賴與 license 欄位）
