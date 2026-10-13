# hook-lab

- **分類**：影片製作 / 短影音分析 / Claude Code Skill
- **連結**：https://github.com/hongfamonvAI/hook-lab

## 原清單說明

（AI郵報〈2026 Claude Code 做影片 Skills 推薦〉）— 拆解爆紅短影音的 Skill，分析影片如何開場、如何分段。AI郵報測試了 6 款影片拆解 Skill，hook-lab 是唯一能直接用的；其他幾款卡在 YouTube 與 TikTok 的防爬蟲機制。MIT 開源。

> **查證結果**：與 README 相符。repo 說明為「拆解短视频的 hook、脚本结构和爆款逻辑，输出适配小红书 / 视频号的改写方向」，內容以簡體中文撰寫，授權為 MIT。

## 概述

hook-lab 是 Claude Code skill：輸入 TikTok、Instagram Reels 或 YouTube Shorts 的網址，就會拆解影片的 hook（開場鉤子）、腳本結構與爆紅原因，並給出適合中文平台（小紅書、視頻號）的改寫方向。

repo 於 2026-06-11 建立，查詢當下（2026-10-13）約 100 顆星，建立後沒有再更新。

## 核心功能／特色

輸出六個部分：

1. **數據面板**：播放量、按讚、留言、轉發、互動率。
2. **Hook 拆解**：hook 類型、為什麼能讓人停下來、改寫建議。
3. **腳本結構**：依敘事邏輯分段，標註每段的作用與節奏。
4. **風格標籤**：呈現方式、內容類型、情緒基調。
5. **為什麼能爆**：2–3 個具體原因。
6. **改寫方向**：3 個可以落地的角度，附 hook 範例與適合的平台。

每次分析結果會自動附加到 `results/analyzed-videos.md`，方便比較多支影片。

## 技術架構或運作原理

以 `yt-dlp` 抓取影片資訊與內容，失敗時依序退回：

1. 帶 Chrome cookie 重新以 yt-dlp 抓取。
2. TikTok 仍失敗時，解析頁面內嵌的 JSON。
3. 以上都失敗時，讓 Claude 用 WebFetch 抓頁面。
4. 全部失敗時，請使用者手動貼上文案與數據。

## 安裝與使用方式

```bash
cp -r hook-lab ~/.claude/skills/hook-lab
pip3 install yt-dlp
```

在 Claude Code 中執行：

```text
/analyze https://www.tiktok.com/@someone/video/1234567890
/analyze https://www.instagram.com/reel/abcDEF123/
/analyze https://www.youtube.com/shorts/abcdefg
```

## 適用情境

- 研究競品或爆紅短影音的開場與結構。
- 把海外短影音的手法改寫成適合小紅書、視頻號的內容。
- 累積拆解紀錄，比較多支影片的共同模式。

## 授權與成本

- **授權**：MIT。
- **成本**：免費；Claude Code 的用量自付。

## 限制與注意事項

- 回退機制會讀取 Chrome 的 cookie（登入資料）。AI郵報提醒，使用前要確認自己能接受這個風險。
- 依賴 yt-dlp，平台改版或加強防爬蟲時可能失效。
- 改寫建議以中國大陸平台為主，輸出為簡體中文。
- 專案很小，建立後沒有後續更新。

## 相關工具

- [claude-video](claude-video（-watch）.md)：讓 Claude 觀看影片內容
- [OpenMontage](OpenMontage.md)：從研究、腳本到剪輯的完整影片製作 agent

## 資料來源

- https://github.com/hongfamonvAI/hook-lab （README）
- https://api.github.com/repos/hongfamonvAI/hook-lab （星數、MIT、建立時間）
- https://www.aiposthub.com/claude-code-video-skills-2026/ （AI郵報，2026-10-11）
- https://www.aiposthub.com/ai-video-teardown/ （AI郵報實測）
