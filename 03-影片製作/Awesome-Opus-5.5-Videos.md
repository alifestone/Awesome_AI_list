# Awesome Opus 5.5 Videos

- **分類**：影片製作 / 程式化影片（程式碼 → 影片）
- **連結**：https://github.com/yihui-dev/awesome-opus5-5-videos
- **原作與重製對照頁**：https://skillry.dev/ai-videos/opus-5-5

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：repo 標語為 *A growing collection of viral videos made with Claude Opus 5.5 and the prompts behind them. Watch each original next to a live remake on Skillry.* 是一份 awesome list：收集社群用 Claude Opus 5.5 寫程式做出的動畫影片，以及創作者公開的 prompt。MIT 授權（指 repo 本身；影片與 prompt 版權屬各創作者）。查詢當下（2026-10-21）約 8,000 顆星、819 個 fork；repo 建立於 2026-09-27，最後一次 push 為 2026-10-13。

## 概述

這些影片都不是用影片生成模型做的，而是請 Opus 5.5 把動畫「寫成程式碼」（HTML、Canvas、SVG、Three.js、GSAP、shader 等），在瀏覽器播放後錄下來。清單把每支影片連回創作者在 X 上的原始貼文，並附上對方公開的 prompt，讓讀者複製後交給自己的 agent 重做。

維護方把其中一部分影片在 Skillry 網站上重做一次（live remake），可以和原作並排看。README 與連結都帶 Skillry 的 UTM 追蹤參數，實際上也是 Skillry 的推廣管道。

## 核心功能／特色

- **703 個 prompt**：每個一個 Markdown 檔（`prompts/<作者>-<編號>.md`），內含分類、重製用的技術、作者與原始貼文連結；另有機器可讀的 `data/videos.json`。
- **418 個有 Skillry 重製版**；README 挑出 100 支有重製版的影片，附預覽圖。
- **四種分類**（依 `videos.json`）：
  - 動態設計（motion）369 個
  - 3D 場景 117 個
  - 解說動畫（explainer）116 個
  - 遊戲與互動（interactive）101 個
- **技術標籤**：最常見的是 Canvas（267）、SVG（183）、Three.js（131）、shader（92）、GSAP（86），也有 CSS、音訊、可玩遊戲、粒子、像素風等。
- **prompt 範例**：有的很短，例如「仿 Apple 1984 廣告做一支 30 秒的 Opus 5.5 廣告」；有的是詳細的分鏡要求，例如「用 HTML 做 30 秒的調酒食譜解說動畫，從空杯到完成，邊倒邊顯示材料與份量」。

## 安裝與使用方式

不用安裝，直接照 README 的三步：

1. 打開一個 prompt 檔，複製 **Prompt** 區塊。
2. 貼到 Claude Opus 5.5（Claude Code、Claude app，或任何跑 Opus 5.5 的 agent）。
3. 要求輸出成單一 HTML 檔；想要影片就把網頁錄下來。

要批次瀏覽或篩選，可以直接讀 `data/videos.json`（欄位含 `category`、`tech_tags`、`prompt`、`prompt_partial`、`has_remake`）。

## 適用情境

- 想知道「只靠 LLM 寫程式」能做出什麼程度的動畫，找靈感或找可以直接改的 prompt。
- 要做產品宣傳、數據解說、3D 展示等短片，想先找類似的範例 prompt。
- 研究怎麼寫動畫類 prompt：同一類需求可以比較不同人的寫法。

## 授權與成本

- repo 為 **MIT**，但 Credits 寫明每支影片與 prompt 屬於原創作者；創作者可開 issue 要求修改或移除。
- 清單免費；重做需要能用 Claude Opus 5.5 的方案或 API 額度。

## 限制與注意事項

- **約 3 成 prompt 不完整**：703 個中有 207 個標記為 `prompt_partial`，是創作者只公開部分 prompt，或只在貼文裡描述成果。照著貼不一定能重現。
- 結果跟 Opus 5.5 綁定，換成其他模型效果可能差很多；同一個 prompt 每次跑出來也不一樣。
- 原作多數在 X 上，要看原影片需要能開 X；重製版與預覽圖放在 Skillry。
- 沒有附生成出來的程式碼，只有 prompt；要原始碼得自己重跑。
- 收錄期間集中在 2026-09-26～10-12，之後是否持續更新要看維護者。

## 相關工具

- [PDoomVideo](PDoomVideo.md)：同樣是 Opus 5.5 寫程式做的影片，但附完整原始碼與製作流程，可補本清單「只有 prompt」的不足。
- [HyperFrames](HyperFrames.md)：把 HTML 動畫確定性地渲染成 MP4，可以取代手動錄螢幕。
- [onetake](onetake.md)、[Cinetic](Cinetic.md)：讓 agent 用更有結構的流程做程式化短片的 skill。

## 資料來源

- https://github.com/yihui-dev/awesome-opus5-5-videos
- https://github.com/yihui-dev/awesome-opus5-5-videos/blob/main/data/videos.json
- https://skillry.dev/ai-videos/opus-5-5
