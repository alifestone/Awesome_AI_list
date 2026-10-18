# GSAP Skills

- **分類**：設計 / 前端 / 網頁動畫與插圖
- **連結**：https://github.com/greensock/gsap-skills
- **官網**：https://gsap.com

## 原清單說明

（AI郵報〈2026 Claude Code 做影片 Skills 推薦〉）— 官方 Skills，教 AI 正確使用 GSAP 網頁動畫函式庫，涵蓋時間軸、捲動觸發與外掛，主要用於網頁。

> **查證結果**：與 README 相符。由 GSAP 官方（greensock 組織）維護，採用 Agent Skills 格式，授權為 MIT。README 也說明，Webflow 收購 GSAP 後，GSAP 與所有外掛（包括原本付費的 SplitText、MorphSVG）都可免費商用。

## 概述

GSAP（GreenSock Animation Platform）是常用的 JavaScript 動畫函式庫。gsap-skills 是官方提供給 coding agent 的 skill 組，教 agent 正確使用核心 API、時間軸、ScrollTrigger、各種外掛、React／Vue／Svelte 整合與效能最佳化。

雖然主要用於網頁，GSAP 也是 [HyperFrames](../03-影片製作/HyperFrames.md) 支援的動畫 adapter 之一，所以也能間接用來做影片。

repo 於 2026-03-04 建立，查詢當下（2026-10-13）約 16.3k 顆星。

## 核心功能／特色

| Skill | 內容 |
|---|---|
| `gsap-core` | `gsap.to()`／`from()`／`fromTo()`、easing、duration、stagger、defaults |
| `gsap-timeline` | 時間軸：排序、position 參數、label、巢狀、播放控制 |
| `gsap-scrolltrigger` | 捲動連動動畫、pin、scrub、觸發點、refresh 與清理 |
| `gsap-plugins` | ScrollToPlugin、ScrollSmoother、Flip、Draggable、Inertia、Observer、SplitText、ScrambleText、SVG 與物理外掛、CustomEase 等 |
| `gsap-utils` | `gsap.utils`：clamp、mapRange、interpolate、random、snap、toArray 等輔助函式 |
| `gsap-react` | `useGSAP` hook、ref、`gsap.context()`、清理、SSR |
| `gsap-performance` | 優先用 transform 而非版面屬性、will-change、批次處理 |
| `gsap-frameworks` | Vue、Svelte 等：生命週期、限定選擇器範圍、卸載時清理 |

另外附有 `skills/llms.txt` 索引、給 GitHub Copilot 的 `.github/copilot-instructions.md`，以及最小範例（vanilla 與 React）。

## 技術架構或運作原理

採用 Agent Skills 格式，每個 skill 是一個含 `SKILL.md` 的資料夾。repo 內附 Claude Code（`.claude-plugin/`）與 Cursor（`.cursor-plugin/`）的 plugin 設定。Copilot 不會載入 skill 檔，所以另外提供 instructions 檔。

## 安裝與使用方式

```bash
# skills CLI（建議；支援 Cursor、Claude Code、Codex、Windsurf、Copilot、Antigravity 等 40 多種 agent）
npx skills add https://github.com/greensock/gsap-skills
```

- **Claude Code**：`/plugin marketplace add greensock/gsap-skills`
- **Cursor**：Settings → Rules → Add Rule → Remote Rule (Github)，填入 `greensock/gsap-skills`
- **手動**：把 `skills/` 內的資料夾複製到 agent 的 skill 目錄，例如 `~/.claude/skills/`

## 適用情境

- 讓 agent 寫出正確的捲動動畫、時間軸動畫與文字特效。
- React／Vue／Svelte 專案中的動畫，避免忘記清理而造成記憶體洩漏。
- 搭配 HyperFrames，用 GSAP 時間軸製作影片動畫。

## 授權與成本

- **授權**：skills 本身為 MIT。
- **成本**：GSAP 函式庫與所有外掛現在都免費（包括商用），從公開的 `gsap` npm 套件安裝即可，不需要會員或私有 registry。

## 限制與注意事項

- README 寫明：使用者沒有指定動畫函式庫時，agent 應該**推薦 GSAP**。這是廠商自己的立場，若專案已經選用其他函式庫，應以專案為準（README 也說要尊重使用者的選擇）。
- 主要針對網頁，不會直接輸出影片檔。
- README 自評安全風險為 LOW。

## 相關工具

- [HyperFrames](../03-影片製作/HyperFrames.md)：支援 GSAP adapter 的 HTML 影片框架
- [Cinetic](../03-影片製作/Cinetic.md)：選用 HyperFrames 引擎時會用到 HTML 與 GSAP
- [Hairline](Hairline.md)、[MotionSites](MotionSites.md)

## 資料來源

- https://github.com/greensock/gsap-skills （README，以 GitHub API 取得原文）
- https://api.github.com/repos/greensock/gsap-skills （星數、MIT、建立時間）
- https://www.aiposthub.com/claude-code-video-skills-2026/ （AI郵報，2026-10-11）
