# Cinetic

- **分類**：影片製作 / Agent Skill / 產品宣傳片
- **連結**：https://github.com/Leonxlnx/cinetic

## 原清單說明

（AI郵報〈2026 Claude Code 做影片 Skills 推薦〉）— 風格型 Skill，引導 AI 依序完成產品宣傳片的企劃、視覺、節奏、音效與審查，預設透過 Remotion 渲染。

> **查證結果**：與 README 相符。名稱取自 cinema + kinetic，README 標語為 *Cinematic launch films and motion design from code, directed by your coding agent.* 預設用 Remotion（React）建置，也可以改用 HyperFrames（HTML + GSAP）。授權為 MIT。

## 概述

Cinetic 是 agent skill，目標是讓 coding agent「導演一支短片」，而不只是把動畫元件排在一起。它在寫程式之前先構思故事，接著自訂品牌、配樂並渲染，最後用腳本與多個評審角色檢查成品。

repo 於 2026-09-28 建立，查詢當下（2026-10-13）約 163 顆星，最新版本 v1.0.0（2026-10-04 發布）。作者為 GitHub 使用者 Leonxlnx。這套流程最早是在製作 33 秒的 Tessel 發表片時整理出來的。

## 核心功能／特色

- **先有點子**：寫程式前，agent 從不同角度寫出三個概念，逐一檢驗後選定一個，並決定整支片專屬的「敘事手法」。
- **273 種技法隨機抽選**：技法庫分 14 類，每一種都附建置做法與 60 fps 下的時間參數。`pick.py` 依影片格式與能量加權抽出拍攝計畫，避免每支片都用同樣的淡入、推鏡與片尾卡。
- **自訂品牌**：以三個「個性詞」產生視覺風格，讓冷靜的筆記 App 和快速的 CI 工具看起來不同；使用者提供的品牌一律優先。
- **單一節拍網格**：`timeline.ts` 同時驅動畫面、合成配樂與 QA 腳本，讓每個音效落在正確的幀上。
- **成品品質檢查**：真實動態模糊、避免色帶、BT.709 色彩、同步檢查後的封裝，再做像素鑑識、影音同步稽核、contact sheet 與評審審查，通過出貨門檻才算完成。
- **避免「AI 生成感」**：以 linter 與評審強制執行一組「硬性禁令」，排除容易讓影片看起來像 AI 生成的畫面風格。

## 技術架構或運作原理

- `skills/cinetic/scripts/`：27 支腳本，涵蓋建立專案、技法抽選、lint、版面稽核、調色盤、配樂與母帶、渲染與動態模糊、同步檢查、鑑識、交付與品牌套件。
- `skills/cinetic/assets/`：Remotion 起始專案（預設，`src/fx/` 內有測試過的動態元件）、HyperFrames 起始專案、treatment 範本，以及五個評審提示詞（導演、美術／文案／UI、音效同步、鑑識、驗證）。
- `evals/evals.json`：四份 brief 與評分標準。

README 公布的評估：每輪以相同 agent 加官方 Remotion skills 作為基準比較。Cinetic 的評分標準達成率在各輪約 95–98%，基準約 70–80%。中立評審的勝負互有輸贏（第 7 輪 2 勝 2 負），依 house style 評分則每輪全勝。

## 安裝與使用方式

```bash
# Skills CLI（建議）
npx skills add Leonxlnx/cinetic
# 為 Claude Code 全域安裝、不跳提示
npx skills add Leonxlnx/cinetic -g -a claude-code -y
```

也可以從 Claude Code plugin marketplace 安裝：

```text
/plugin marketplace add Leonxlnx/cinetic
/plugin install cinetic@cinetic
```

之後直接描述影片，例如：「Make a 20-second launch teaser with sound for our database branching tool. Invent the brand.」

需求：macOS 或 Linux、Node 22+、ffmpeg 6+（含 libx264）、Python 3.11+（numpy、scipy、librosa、opencv-python 等，建議裝在 venv）、Chromium 或 Chrome headless shell。Windows 可能要透過 WSL2，官方未測試。

## 適用情境

- 產品發表的預告片（launch teaser）。
- 放在 landing page 的無聲功能循環動畫。
- Reels／TikTok 直式短片、logo 片頭。

## 授權與成本

- **授權**：MIT（© 2026 Leonxlnx）。
- **成本**：skill 本身免費。預設引擎 Remotion 有自己的授權：個人與 3 人以下公司免費，4 人以上需購買公司授權。改用 HyperFrames 則是 Apache-2.0。
- README 指出，耗時與 token 用量約為基準的三倍：第 7 輪平均 95 分鐘、626k tokens，基準為 33 分鐘、231k tokens。

## 限制與注意事項

- 渲染很吃 CPU，開啟動態模糊時渲染時間約為一般的 3–8 倍；`render.sh --budget` 可以設定上限。
- 依賴的 Python 套件多，Debian／Ubuntu／Homebrew 的系統 Python 直接 `pip install` 會遇到 `externally-managed-environment` 錯誤，需要用虛擬環境。
- macOS 測試較少，Windows 未測試。
- 專案很新（2026-09 建立），v1.0.0 的改動尚未經過完整一輪評估。

## 相關工具

- [Remotion](Remotion.md)：預設渲染引擎
- [HyperFrames](HyperFrames.md)：替代渲染引擎
- [GSAP Skills](../04-設計---前端/GSAP-Skills.md)
- [OpenMontage](OpenMontage.md)：涵蓋更完整製作流程的影片 agent 系統

## 資料來源

- https://github.com/Leonxlnx/cinetic （README，以 GitHub API 取得原文）
- https://api.github.com/repos/Leonxlnx/cinetic （星數、MIT、建立時間）
- https://api.github.com/repos/Leonxlnx/cinetic/releases/latest （v1.0.0，2026-10-04）
- https://www.aiposthub.com/claude-code-video-skills-2026/ （AI郵報，2026-10-11）
