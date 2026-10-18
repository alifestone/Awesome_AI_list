# onetake

- **分類**：影片製作 / 程式化影片（程式碼 → 影片）
- **連結**：https://github.com/feitangyuan/onetake

## 原清單說明

Claude Agent Skill，做「一鏡到底」的產品發表片、預告與功能演示動效。⚠️ PolyForm Noncommercial（非商用）。

> **⚠️ 查證結果**：授權確實是 **PolyForm Noncommercial 1.0.0**。README 明寫 *Commercial use is not permitted*（不允許商業用途）；GitHub API 的授權欄位顯示為 NOASSERTION，因為 GitHub 無法自動辨識這種授權。需要商用時，可購買付費的 **onetake Pro**，官網標價為一次性 US$79（2026-10-13 查詢）。

## 概述

onetake 是一個 Claude Agent Skill，也能用在 Codex 等會讀取 skills 的 agent。它專門做「一鏡到底」的動態影片：產品發表片、預告片與功能演示。核心理念是「不切到下一張投影片」：每個段落都從前一個段落的畫面中長出來，全片只有一個連續的鏡頭，而不是一堆輪流出場的場景。

這個 skill 之前叫 *ohmymotion*。查詢當下（2026-10-13）約 2.2k 顆星，官網為 onetakemotion.com。

## 核心功能／特色

- **畫面銜接（carry）**：每兩個段落的交接處，都要有一個元素留下來，並且看得到它變成下一段。例如輸入框展開成 App 視窗、卡片長成整個頁面、鏡頭穿過卡片進入下一個場景。
- **單一鏡頭**：鏡頭不剪接，會跟隨主體、甩鏡、模擬手持晃動與撞擊震動，也會在適當時候完全靜止。
- **連貫度驗收（oracle）**：
  - `probe.py` 記錄每一幀出現的元素，找出每個交接處，計算有沒有東西被帶過去（carry score）。README 範例中，被否決的版本分數為 0.00 與 0.40，通過的為 0.75 與 0.83。
  - 同一套驗收也會判掉以下問題：鏡頭長度全部一樣、沒有靜止段落、音訊爆音、快速動作沒有動態模糊、主體出畫。
- **重建真實 UI**：依照截圖用 HTML 重建產品介面，不用螢幕錄影，鏡頭推到多近都清楚。
- **動作庫**：約 38 種動作（彈簧、入場、銜接、接觸、物理模擬、鏡頭、流體背景），每一個都是時間的純函數，速度曲線經過實測。
- **真實動態模糊**：每個運動中的幀，都是在 180° 快門開啟期間多次擷取、在線性光空間平均而成。
- **音效**：依片中事件放置 Foley 與合成音效，放在同一個混響空間中，撞擊處音樂會自動讓位（ducking）。
- **確定性**：跳到任何時間點都得到同一幀。草稿為 1080p30，成片為 4K60。
- **案例**：README 的 `cases/` 附上用它做的成片與拆解文件（徽章標示 11 部，中文說明寫 10 部），**不含**影片原始碼。

## 技術架構或運作原理

製作流程：

1. 把參考影片拆成數字：靜止占多少、在哪裡剪、動作怎麼緩動。
2. 提出三個概念，選一個。
3. 寫節拍表：鏡頭長短至少相差 4 倍，每個交接處都寫明留下來的是什麼。
4. 以動作庫寫成單一 HTML 檔，加上動態模糊渲染，再依事件配上聲音。
5. 通過 oracle 驗收後，才交給人看。

主要檔案：

| 路徑 | 內容 |
|---|---|
| `SKILL.md` | 協定與硬性規則 |
| `lib/motion.js` | 動作庫 |
| `lib/ui_kit.js` | UI 重建工具 |
| `scripts/` | 渲染、驗收（verify_promo.py）、probe、參考片分析、旁白、聲音 |
| `gallery/` | 每個動作的示範 |
| `references/` | 節奏、銜接、構圖、鏡頭、聲音的方法說明 |

依相依套件判斷，渲染應是用 Playwright（Chromium）擷取 HTML 畫面，再交給 ffmpeg 編碼。README 沒有逐步說明渲染流程。

## 安裝與使用方式

```bash
# Claude Code
git clone https://github.com/feitangyuan/onetake.git ~/.claude/skills/onetake
# Codex 等會讀取 skills 的 agent
git clone https://github.com/feitangyuan/onetake.git ~/.agents/skills/onetake
```

相依套件：

- 必要：python3 搭配 `playwright`（chromium）、`numpy`、`scipy`、`Pillow`、`matplotlib`，以及 `ffmpeg`、`node`。
- 分析參考片需要 `opencv-python`。
- 旁白需要 `faster-whisper` 與 Kokoro TTS。
- 音樂預設使用免版權曲庫。

使用時直接對 agent 說，例如：「給我的 App 做個 15 秒發布影片」、「照這幾張截圖重建介面做功能演示，不要錄屏」、「我的動效影片像 PPT，幫我改」。

## 適用情境

- 產品發表片、預告片、App 功能演示，尤其是想避免「投影片感」的時候。
- 不想錄螢幕，想用截圖重建 UI 來做高畫質運鏡。
- 研究動態設計的方法論（節奏、銜接、運鏡）以及自動化品質驗收。

## 授權與成本

- **免費版**：PolyForm Noncommercial 1.0.0，個人、教育、研究等非商業用途免費，**不可商用**。
- **onetake Pro**（依官網）：
  - 一次性 US$79。
  - 內容包含：自動跟隨每個段落的鏡頭（免費版的鏡頭需手動設定關鍵幀）、每部影片與被否決版本的原始碼、5 個附節拍表的起始範本、說明每個被否決版本失敗原因的筆記，以及商用授權（可接案，不需署名）。
  - 包含 1.x 所有版本，授權不會過期。
  - 7 天內可全額退款。

## 限制與注意事項

- **免費版禁止商用**，包括客戶專案與廣告投放。
- 案例只附成片與拆解文件，不含影片原始碼（原始碼屬於 Pro 內容）。
- 依賴較多（Python 科學運算套件、Playwright、Node、ffmpeg），4K60 加上多次取樣的動態模糊，渲染成本較高。實際渲染時間 README 沒有說明，**資料不足**。
- 部分案例是在舊名 ohmymotion 時期製作的，畫面中會出現舊名稱。

## 相關工具

- [HyperFrames](HyperFrames.md)：同樣以 HTML 渲染影片的開源框架（Apache-2.0，可商用）
- [PDoomVideo](PDoomVideo.md)：以 headless Chrome 渲染的程式化動畫範例
- Playwright、Kokoro TTS、faster-whisper

## 資料來源

- https://github.com/feitangyuan/onetake （README，以 GitHub API 取得原文）
- https://api.github.com/repos/feitangyuan/onetake （repo 中繼資料：描述、星數、授權欄位 NOASSERTION、官網）
- https://onetakemotion.com （onetake Pro 內容、價格、授權與退款條款）
