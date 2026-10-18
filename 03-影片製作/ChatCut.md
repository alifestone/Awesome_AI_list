# ChatCut

- **分類**：影片製作 / 剪輯 / 處理
- **連結**：https://github.com/ChatCut-Inc/agent-plugin
- **官網**：https://chatcut.io

## 原清單說明

（AI郵報〈2026 Claude Code 做影片 Skills 推薦〉）— 剪輯與字幕工具，可以安裝成 Codex 外掛，用對話操作多軌時間軸，處理口播初剪、繁體中文字幕與配樂。目前主要依逐字稿判斷內容，畫面分析仍在開發中。AI 功能以點數計費。

> **查證結果**：原文沒有附連結。查到官方的 `ChatCut-Inc/agent-plugin` repo，除了 Codex 也支援 Claude Code、Grok Bot、Cursor 與 Kimi Work。repo 沒有授權檔（GitHub 顯示無授權）。

## 概述

ChatCut 是線上影片剪輯服務，主打用對話剪片。`agent-plugin` repo 提供各家 coding agent 的外掛，透過 ChatCut 託管的 MCP endpoint 連到使用者的 ChatCut 帳號，讓 agent 直接修改 ChatCut 專案的時間軸。剪輯本身在 ChatCut 的雲端專案中進行，不是在本機算繪。

repo 於 2026-06-25 建立，查詢當下（2026-10-13）約 939 顆星，仍在頻繁更新。

## 核心功能／特色

- **對話剪輯**：匯入素材、修改時間軸、加入動態圖形、產生素材（配音、背景音樂）、轉錄音訊、上字幕、匯出影片。
- **逐字稿剪輯**：官方文件說明，在 Transcript 分頁選取文字並刪除，ChatCut 就會在單字邊界切開片段、移除那段時間，並自動補齊軌道（ripple）。
- **驗證**：外掛會檢查修改是否確實出現在編輯器中。
- **多平台外掛**：
  - `codex/`：Codex 外掛
  - `claude/`：Claude Code 外掛
  - `grok/`：Grok Bot 與 Cursor 外掛
  - `kimi/`：Kimi Work 外掛
  - `chatcut-desktop-codex-plugin/`：協助 Codex 安裝並連接 ChatCut Desktop App 的 skill 套件

## 技術架構或運作原理

各平台外掛都連到同一個託管 MCP endpoint：

```text
https://api.chatcut.io/api/external-mcp/mcp
```

第一次使用時由 agent 主程式處理授權（OAuth 登入 ChatCut 帳號）。外掛內的 skills 是同一組「剪輯技巧」skill 的各平台轉接版本。

## 安裝與使用方式

- **Codex**：在 ChatGPT／Codex 桌面 App 的外掛商店搜尋 ChatCut 並安裝，說明見 chatcut.io/chatgpt。登入指令為 `codex mcp login chatcut`。
- **Claude Code**（需 2.x 版）：從 `https://github.com/ChatCut-Inc/agent-plugin.git` 加入 marketplace 後安裝，說明見 chatcut.io/claude。登入指令為 `claude mcp login plugin:chatcut:chatcut`。
- **Grok Bot／Cursor**：從主程式的 Plugins 畫面完成授權。

需求：ChatCut 帳號，以及一個要編輯的 ChatCut 專案。

範例提示詞：`Transcribe this clip and add captions.`、`Generate a voiceover and background music.`、`Export the current project.`

## 適用情境

- 口播、訪談、教學影片的初剪：依逐字稿刪掉贅字與停頓。
- 自動上字幕，包含繁體中文字幕。
- 加配樂、配音與簡單的動態圖形。

## 授權與成本

- **授權**：agent-plugin repo 沒有授權檔；ChatCut 本身是商業服務。
- **成本**：AI郵報指出 AI 功能以點數計費。ChatCut 官網曾出現 Seedance 生成影片每秒 $0.046 起的限時優惠。完整方案價格本條目未查證，**資料不足**。

## 限制與注意事項

- 目前主要依逐字稿判斷影片內容，畫面分析仍在開發中（AI郵報），所以適合以說話為主的影片，不適合純畫面剪輯。
- 素材與專案放在 ChatCut 雲端，需要網路與帳號。
- AI郵報只有教學文章，未實測。

## 相關工具

- [Palmier Pro](Palmier-Pro.md)：同樣讓 agent 透過 MCP 操作時間軸，但是 Mac 本機軟體
- [ffmpeg-skill](ffmpeg-skill.md)：在本機用 FFmpeg 做剪輯
- [Higgsfield MCP](Higgsfield-MCP.md)

## 資料來源

- https://github.com/ChatCut-Inc/agent-plugin （README 與 docs/claude-code-install.md）
- https://chatcut.io/docs/transcript-editing （逐字稿剪輯說明）
- https://chatcut.io/blog/how-to-edit-video-with-chatgpt
- https://www.aiposthub.com/claude-code-video-skills-2026/ （AI郵報，2026-10-11）
- https://www.aiposthub.com/codex-chatcut-ai-video-editing-guide/ （AI郵報教學）
