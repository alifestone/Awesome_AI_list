# Palmier Pro

- **分類**：影片製作 / 剪輯 / 處理
- **連結**：https://github.com/palmier-io/palmier-pro
- **官網**：https://palmier.io

## 原清單說明

（AI郵報〈2026 Claude Code 做影片 Skills 推薦〉）— Mac 剪輯軟體，Claude Code 與 Codex 可以透過 MCP 讀取並修改時間軸。GPL-3.0 開源，AI 生成另以點數計費。只支援 Apple 晶片、macOS 26 以上。

> **查證結果**：大致相符，但授權有變動。README 最上方說明，**v0.7.6 以前**的版本與 `last-gpl-source` 分支的原始碼是 GPLv3；**之後的二進位版本改為專有授權**，原始碼不再公開。repo 現在只保存歷史原始碼，以及發布新版的二進位檔。

## 概述

Palmier Pro 是用 Swift 從頭打造的 macOS 剪輯軟體，標語是 *The video editor built for AI*，以 Premiere Pro 為目標，再加入 AI 工作流程。它內建 AI 生成，也開放 MCP server，讓外部 agent 與 App 內建的 agent 一起編輯同一個專案。開發公司 Palmier 是 Y Combinator S24 團隊。

repo 於 2026-04-07 建立，查詢當下（2026-10-13）約 14.6k 顆星、1.1k forks。README 有繁體中文版。

## 核心功能／特色

- **Swift 原生剪輯器**：多軌時間軸，介面參考 Premiere Pro。
- **內建生成式 AI**：在時間軸中直接用 Seedance、Kling、Nano Banana Pro 等模型生成影片與圖片。
- **MCP 整合**：可連接 Claude、Codex、Cursor，也可以使用 App 內建的 agent。
- **Claude Desktop 一鍵安裝**：App 內附 mcpb 套件，可安裝成 Claude Desktop Extension。

## 技術架構或運作原理

App 開啟時，會在本機以 HTTP 提供 MCP server：

```text
http://127.0.0.1:19789/mcp
```

agent 透過這個 endpoint 讀取並修改目前開啟的專案。App 必須在執行中，agent 才能連上。

## 安裝與使用方式

1. 從 GitHub Releases 下載 `PalmierPro.dmg` 並安裝。
2. 開啟 App，再把 MCP 加到 agent：

```bash
# Claude Code
claude mcp add --transport http palmier-pro http://127.0.0.1:19789/mcp

# Codex
codex mcp add palmier-pro --url http://127.0.0.1:19789/mcp
```

- **Cursor**：從 App 選單 `Help` → `MCP Instructions` → `Install in Cursor`，或手動寫入 `~/.cursor/mcp.json`。
- **Claude Desktop**：`Help` → `MCP Instructions` → `Install in Claude Desktop`。

## 適用情境

- 想讓 Claude Code 或 Codex 直接剪輯本機專案，同時保留圖形化時間軸，可以人工微調。
- 在同一個時間軸中混用實拍素材與 AI 生成片段。

## 授權與成本

- **授權**：
  - v0.7.6 以前的版本與 `last-gpl-source` 原始碼：GPLv3，可以使用、修改與再散布。
  - v0.7.6 之後的二進位版本：專有授權（`BINARY_LICENSE.md`）。
- **成本**：AI郵報指出 AI 生成另以點數計費。軟體本身與點數的價格本條目未查證，**資料不足**。

## 限制與注意事項

- 只支援 Apple Silicon（M 系列）且 macOS 26（Tahoe）以上，不支援 Windows、Linux 與 Intel Mac。
- 「開源」只限舊版：最新版是專有軟體，repo 也不再接受程式碼貢獻。AI郵報寫的「GPL-3.0 開源」已經不完全正確。
- MCP server 只在 App 開啟時存在。
- AI郵報只有教學文章，未實測。

## 相關工具

- [ChatCut](ChatCut.md)：雲端版的對話剪輯工具
- [Higgsfield MCP](Higgsfield-MCP.md)
- [ffmpeg-skill](ffmpeg-skill.md)

## 資料來源

- https://github.com/palmier-io/palmier-pro （README，以 GitHub API 取得原文）
- https://api.github.com/repos/palmier-io/palmier-pro （星數、建立時間）
- https://www.aiposthub.com/claude-code-video-skills-2026/ （AI郵報，2026-10-11）
- https://www.aiposthub.com/palmier-pro-ai-video-editor-tutorial/ （AI郵報教學）
