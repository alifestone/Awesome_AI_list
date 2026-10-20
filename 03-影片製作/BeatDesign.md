# BeatDesign

- **分類**：影片製作 / AI 影片生成
- **連結**：https://github.com/BeatAPI/BeatDesign
- **官網**：https://design.beatapi.io
- **最新版本**：v0.2.4（2026-09-23）

## 原清單說明

（使用者提供的 GitHub 連結）— Local-first AI canvas and timeline. Any MCP agent. Open-source alternative to Higgsfield.

> **查證結果**：repo 由 BeatAPI（AI 模型 API 服務商）維護，2026-08 建立，約 220 顆星、30 個 fork（2026-10-20 查詢）。程式本身開源，但內建的生成功能只接 BeatAPI 一家，需要自備 BeatAPI API key。

## 概述

BeatDesign 是在自己電腦上跑的 AI 圖片／影片創作工作台，自稱「本機版的 Higgsfield」。同一個 Project 裡有四個介面：

- **Studio**：單次生成圖片、影片，或分析影片。
- **Canvas**：無限畫布，用節點串起提示詞、參考圖、生成結果，可以分支、比較、重用。
- **Editor**：瀏覽器內的影片時間軸，剪輯後直接在瀏覽器匯出 MP4。
- **Assets**：所有匯入與生成的素材，四個介面與 MCP 共用。

它不在畫布裡內建聊天 agent，而是開放 29 個 MCP tool，讓 Claude Code、Codex、Cursor 等外部 agent 操作同一個 Project，改動會即時出現在瀏覽器裡。

## 核心功能／特色

- **Canvas**：圖片、影片、音訊、文字、生成、時間軸節點；連線、分組、複製、undo／redo；一個生成節點可保留多個版本。
- **Editor**：非破壞式 trim、split、move、ripple delete；音量、靜音、淡入淡出；可拖動的圖片疊加層；SRT 字幕（四種樣式）；選取片段用 AI 重做，結果存成 Take，可切回原版；缺素材、片段重疊、影片軌空隙診斷。
- **匯出**：用 WebCodecs + Mediabunny 在瀏覽器裡編碼 H.264／AAC MP4，不需要系統裝 FFmpeg（MCP 端的權威渲染與抽幀則要 `ffmpeg`／`ffprobe`）。
- **生成模型**（透過 BeatAPI）：GPT Image 2.5、Wan 3.0、HappyHorse 1.0／1.1、MiniMax H3 Max、Kling 2.6／3.0 Motion Control，另有 Standard／Deep 兩級影片分析。
- **MCP（29 個 tool）**：Skill、Project、Asset、Canvas、Generation、Editor 六組；支援 stdio 與 Streamable HTTP。
- **Agent 整合**：官方列出 Claude Code、Codex、Cursor、Windsurf、VS Code + Copilot、Cline／Roo Code、OpenCode、Gemini CLI、Qwen Code、Kiro、Trae、WorkBuddy 等 16 種，附設定範例。
- 介面支援英文、簡體中文、日文。

## 技術架構或運作原理

- TypeScript + React（Vite），Canvas 用 React Flow，資料存在本機 SQLite 與專案資料夾。
- 所有 UI 與 MCP 的寫入都經過同一個 **Command Kernel**（`POST /api/app/projects/:id/commands`）；用 revision／CAS 與三方合併處理並行修改，不會整份覆蓋。agent 與人可以同時改同一個 Project。
- MCP 只開放增量操作（`canvas.apply`、`editor.apply`），帶穩定 ID 與冪等鍵，不提供整份 Canvas／Timeline 取代。
- 生成走 provider adapter，預設且唯一內建的是 BeatAPI（`https://api.beatapi.io`）。fork 可以自己寫 adapter 接別家 API，但 repo 沒有附 Fal、Replicate 等其他實作。
- 本機選檔不會上傳；確認送出生成時，參考素材才上傳到 BeatAPI 或你自己的公開 R2／S3 bucket。API key 加密存在本機 SQLite。

## 安裝與使用方式

需求：Node.js 22+、pnpm 10+、macOS 或 Windows 上的新版 Chrome。

```bash
git clone https://github.com/BeatAPI/BeatDesign
cd BeatDesign
pnpm install
pnpm db:push
pnpm dev          # 只開工作台
pnpm dev:agent    # 工作台 + 本機 HTTP MCP endpoint
pnpm mcp          # 給 coding agent 的 stdio MCP server
```

開啟 http://127.0.0.1:3020。要生成或分析時，再到工作台右上角的 Provider 設定填入 BeatAPI API key。Claude Code 可直接用 repo 根目錄的 `.mcp.json`，或裝 `integrations/claude-code/` 的 plugin。

連上 MCP 後可以這樣下指令：「打開我最新的 BeatDesign 專案，把這些片段加到時間軸、放上 logo、調整字幕，然後把 Editor 開著讓我檢查。」

## 適用情境

- 想要 Higgsfield 那種「畫布生成 → 剪輯成片」流程，但希望專案與素材留在自己電腦上。
- 讓 Claude Code 等 agent 批次生成、排時間軸，人再在瀏覽器裡微調。
- 只用本機素材剪短片（匯入、排列、字幕、匯出都不需要 API key）。

## 授權與成本

- **授權**：Apache-2.0。BeatAPI／BeatDesign 商標與第三方元件另有條款。
- **成本**：工作台免費。生成與影片分析按 BeatAPI 用量計費，價格 repo 未寫明，**資料不足**，請見 BeatAPI 官網。

## 限制與注意事項

- 生成只能透過 BeatAPI；要接其他服務得自己寫 provider adapter。
- 官方只寫 macOS 與 Windows 的 Chrome，Linux 未列為支援平台。
- 目前定位是本機、單人、短片：沒有多人協作、多條時間軸、進階轉場、變速、波形或桌面版。
- 內建 Skill 目錄目前刻意回傳空清單，要等官方 Skill 通過評測後才會上架。
- 專案很新（2026-08 建立），尚在 v0.2.x。
- 文件以簡體中文為主（產品規劃文件），README 有英、簡中、日文版。

## 相關工具

- [Higgsfield MCP](Higgsfield-MCP.md)：它要對標的商業服務
- [WanGP](WanGP.md)：用自己的顯卡在本機跑開源影片模型
- [Palmier Pro](Palmier-Pro.md)、[ChatCut](ChatCut.md)：同樣可透過 MCP 讓 agent 剪輯時間軸
- [OpenMontage](OpenMontage.md)：從主題到成片的整套影片 agent

## 資料來源

- https://github.com/BeatAPI/BeatDesign （README、repo 資訊，2026-10-20 查詢）
- https://github.com/BeatAPI/BeatDesign/blob/main/docs/PRODUCT_PLAN_AND_STATUS.md （產品規劃與完成狀態，最後核對 2026-09-23）
- https://github.com/BeatAPI/BeatDesign/blob/main/docs/PROVIDERS.md （provider、模型、儲存）
- https://github.com/BeatAPI/BeatDesign/blob/main/docs/MCP.md （29 個 MCP tool）
- https://github.com/BeatAPI/BeatDesign/blob/main/CHANGELOG.md （v0.2.4，2026-09-23）
