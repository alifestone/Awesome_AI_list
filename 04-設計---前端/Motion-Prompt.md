# Motion Prompt

- **分類**：設計 / 前端 / 網頁動畫與插圖
- **連結**：https://github.com/showheyohtaki/motion-prompt
- **官網**：https://showheyohtaki.github.io/motion-prompt/

## 原清單說明

（使用者提供）— motion prompt 的 skill 庫與名稱清單，把動態效果、camera move、UI 元件與 landing page 特效取上名字，讓 AI 能依名稱做出指定的效果。

> **查證結果**：與 README 相符。作者為 Shohei Ohtaki（大滝昇平），授權為 MIT，README 說明可商用，但使用程式碼時須保留第一行的著作權聲明。README 目前僅提供英文與日文名稱清單，中文名稱需依 `make-your-own/` 的提示詞自行翻譯。

## 概述

Motion Prompt 是一套「名稱庫」，收錄 168 種具名的視覺效果，共七組、每組 24 個：`motion`、`motion2`（動態圖形動作）、`camera`（鏡頭運動與轉場）、`ui`（UI 元件名稱）、`lp`、`lp2`（landing page 與網頁特效）、`photo`（攝影風格、光線與色調）。每個名稱附有一段動態範例、一句話說明與一則示範提示語。

它的目的是讓你向 AI 描述想要的動作時，能用精確的專有名詞，而不是「做得精緻一點」這類模糊說法。

## 核心功能／特色

- **名稱瀏覽**：可在瀏覽器的 gallery 中看每個效果的動態範例，也可在 GitHub 上閱讀 `packs/` 內的名稱清單（英文與日文）。
- **Skill 安裝**：提供 `motion-prompt` agent skill，安裝後可直接請 Claude Code 等 agent 打開 gallery，挑選效果後把編號或名稱交給 agent，由 agent 在你的專案中重建該效果。
- **編號固定**：每個效果有固定編號（例如 `#005`），方便團隊溝通時精確指定。
- **自製名稱庫**：`make-your-own/` 內附提示詞，可用來翻譯成其他語言，或為自己的領域製作類似的名稱庫。

## 技術架構或運作原理

- 每個效果是一個由時間驅動的單一函式，因此即時播放與逐格輸出的結果一致。
- 不依賴外部函式庫。
- Skill 格式與 Node.js CLI 並存，CLI 可搜尋、列出、取出程式碼，或開啟挑選介面。

## 安裝與使用方式

```bash
# 需要 Node.js 18 以上
npx skills add showheyohtaki/motion-prompt
```

- **Claude Code**：使用 `/plugin marketplace add` 與 `/plugin install` 安裝 plugin。
- **手動**：將 `skills/motion-prompt/` 資料夾複製到 agent 的 skill 目錄，例如 `~/.claude/skills/`。
- **不安裝**：直接瀏覽 gallery，挑選效果後把名稱寫進提示詞，並補上時間與強度的描述。

## 適用情境

- 前端、設計或影片剪輯工作中，需要向 AI 或同事精確描述動態效果。
- 在 landing page、UI 元件或產品展示中，快速套用一組有名稱的動作。
- 整理團隊共用的動態詞彙，減少溝通誤解。

## 授權與成本

- **授權**：MIT，© 2026 Shohei Ohtaki。允許商用，包括程式碼、影片與圖片。
- **成本**：免費。

## 限制與注意事項

- 名稱清單目前只有英文與日文，中文使用者需自行翻譯或製作。
- 收錄的是「單一動作」，不是完整影片範本；若需要整支成品影片，需另外組合。
- 專案仍相當新（建立於 2026-10-14），尚無正式 release。
- gallery 中嵌入的第三方貼文不在 MIT 授權範圍內。
- 作者的文章與 repo 的說明數量不一致（文章寫 144 項，repo 目前為 168 項），以 repo 為準。

## 相關工具

- [GSAP Skills](GSAP-Skills.md)：讓 agent 正確撰寫 GSAP 動畫，可搭配使用。
- [Hairline](Hairline.md)：細線互動插圖元件。
- [three.js](three.js.md)、[threejs-skills](threejs-skills.md)：網頁 3D 動態效果。

## 資料來源

- https://github.com/showheyohtaki/motion-prompt （README，以 raw 檔取得原文）
- https://github.com/showheyohtaki/motion-prompt （GitHub API：MIT 授權、建立時間 2026-10-14）
- https://showheyohtaki.github.io/motion-prompt/ （官方 gallery）
- https://prompt-motion.com/ （另一個收錄以 Claude Opus 5.5 製作之動態影片與提示詞的網站，與本專案無直接關係）
- https://www.aiposthub.com/motion-prompt-skill-library-names-claude-code-guide/
