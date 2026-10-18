# PlayCanvas Editor MCP

- **分類**：遊戲引擎 × Agent / 網頁遊戲引擎
- **連結**：https://github.com/playcanvas/editor-mcp-server （npm：`@playcanvas/editor-mcp-server`）

## 原清單說明

agent 在 PlayCanvas 建場景，並驗證場景真的跑得起來。

> **查證補充**：正確。README 第一句就是「讓 AI agent 自動化 PlayCanvas Editor，並檢查場景確實能執行」：Runtime 類工具可啟動 Launch 視窗、截圖、讀 log、檢查執行期狀態並模擬鍵盤／滑鼠／觸控輸入。共 130 個工具定義（約 43,000 tokens）。**這是 PlayCanvas 官方專案**：repo 位於 playcanvas 組織下，LICENSE 著作權人為 PlayCanvas Ltd.。

## 概述

PlayCanvas 是開源的 WebGL／WebGPU 網頁 3D 引擎，搭配雲端協作的 PlayCanvas Editor。Editor MCP Server 讓 Claude Code、Claude Desktop、Cursor、Codex 等 MCP 用戶端直接操作瀏覽器中打開的 PlayCanvas Editor：建實體、寫腳本、管素材、改場景設定，再啟動遊戲截圖確認效果。MCP 連線用戶端內建在 Editor 裡，不需要瀏覽器擴充功能。

截至 2026-10-18：MIT 授權、約 145 顆星、主要語言 TypeScript，最新版本 v0.7.1（2026-09-09），最近一次推送為 2026-10-16。

## 核心功能／特色

| 類別 | 涵蓋範圍 |
| --- | --- |
| Projects | 列出、讀取、建立專案，改名稱／說明／可見度，在 Editor 中開啟專案 |
| Entity | 讀取、篩選、搜尋、建立、批次安全編輯、複製、階層調整、刪除、元件生命週期 |
| Scripts | 讀寫腳本內容、解析、掛載、屬性、執行順序與移除 |
| Assets | 讀取、參照圖、建立、串流上傳與下載（最大 512 MiB）、編輯、移動、取代來源、重新匯入、材質 |
| Templates | 實例化、覆寫檢視／套用／還原、解除連結 |
| Animation | 動畫狀態圖讀寫、狀態改名、動畫事件 |
| Processing | 光照貼圖、模型 UV 展開、貼圖轉換、圖集、cubemap、字型、壓縮變體、sprite、bundle |
| Scene | 讀取、列出、載入、建立、複製、改名、刪除、場景設定 |
| Settings | 專案、私人、使用者、session、場景設定 |
| Viewport | 攝影機與視窗狀態、可見度、截圖、對焦 |
| Editor | 選取、編輯期 log、gizmo、undo／redo |
| Builds | 列出、建立、串流下載、設定主要 build、刪除 |
| Store | PlayCanvas Store 與 Sketchfab 搜尋與匯入、授權資訊、My Assets |
| Runtime | 啟動遊戲、引擎版本、截圖、log、執行期狀態檢查、鍵盤／滑鼠／觸控輸入 |
| VCS | 分支、checkpoint、還原與 hard reset、合併、衝突處理、checkpoint diff |

## 技術架構或運作原理

- MCP 用戶端以 `npx` 啟動本機 Node.js 伺服器，伺服器在 `127.0.0.1:52000` 監聽，只接受來自 `playcanvas.com` 與 localhost 頁面的連線。
- 瀏覽器中的 PlayCanvas Editor 內建 MCP 連線端，按下 MCP 按鈕 → `CONNECT` 後與本機伺服器連線，工具呼叫透過 Editor 的 API 執行。
- 一次只控制一個 Editor（當前開啟的專案）；兩個伺服器會輪流搶同一個 port，因此每個 agent 只加一次。
- 130 個工具定義約 43k tokens；Claude Code 的 MCP tool search 預設只載入工具名稱（約 1k tokens）。

## 安裝與使用方式

需求：Node.js 22.18+、PlayCanvas 帳號、Chrome（需允許「Apps on device」權限）。

```bash
# Claude Code
claude mcp add playcanvas -- npx -y @playcanvas/editor-mcp-server
# Codex
codex mcp add playcanvas -- npx -y @playcanvas/editor-mcp-server
```

Claude Desktop／Cursor／專案 `.mcp.json`：

```json
{
  "mcpServers": {
    "playcanvas": {
      "command": "npx",
      "args": ["-y", "@playcanvas/editor-mcp-server"]
    }
  }
}
```

接著在 Editor 中開啟專案 → 點 Publish 下方的 MCP 按鈕 → `CONNECT`（沒開專案時可用 `playcanvas.com/editor` 上 NEW PROJECT 旁的 MCP 按鈕）。若要改 port，伺服器加 `--port <number>`，Editor 端設定相同 port。Windows 需用 `cmd /c npx ...`。

使用範例（README）：「在目前場景加一個掛旋轉腳本的方塊，啟動後截一張執行中畫面確認它有在轉。」

## 適用情境

- 讓 agent 從零建出可在瀏覽器執行的 3D 小遊戲、產品展示或互動場景，並自己截圖驗收。
- 批次處理素材（貼圖壓縮、光照貼圖、圖集、模型匯入）。
- 從 PlayCanvas Store／Sketchfab 搜尋並匯入素材。
- 用 VCS 工具讓 agent 在分支上實驗、建立 checkpoint，失敗可回復。

## 授權與成本

- **授權**：MIT（LICENSE 著作權人為 PlayCanvas Ltd.）。
- **成本**：伺服器本身免費；需 PlayCanvas Editor 帳號，Editor 各方案的價格與私有專案限制本次未查，資料不足；另需負擔 AI 模型費用。

## 限制與注意事項

- 只能控制雲端 PlayCanvas Editor，不支援離線或自架的純引擎專案（engine-only）。
- 一次只連一個 Editor；Runtime 工具會開 Launch 視窗，需允許 Editor 彈出視窗。
- 專案無法透過工具刪除（README 明寫 Projects can't be deleted）；但 VCS 的 hard reset、實體與素材刪除仍屬破壞性操作。
- 伺服器啟動時會**停止任何佔用 52000 port 的其他程序**，若該 port 有其他用途需改 port。
- 無遙測；唯一的對外請求是 `download_build` 下載 Editor 回報的 build 封存檔。
- 工具定義很大（約 43k tokens），不支援工具延遲載入的用戶端會吃掉大量上下文。
- 版本仍在 0.x，介面可能變動。

## 相關工具

- 同資料夾：[Unity MCP](Unity-MCP.md)、[Godot AI](Godot-AI.md)、[Unreal Engine MCP](Unreal-Engine-MCP.md)（皆為桌面引擎、第三方開發；本工具是唯一官方出品、也是唯一網頁引擎）
- [Anatomy](../02-3D-建模與生成/Anatomy.md)：另一種 AI 做網頁 3D 的範例（Three.js）
- [PlayCanvas Engine](https://github.com/playcanvas/engine)

## 資料來源

- https://github.com/playcanvas/editor-mcp-server （README）
- https://api.github.com/repos/playcanvas/editor-mcp-server （repo 中繼資料：授權、星數、推送日期）
- https://raw.githubusercontent.com/playcanvas/editor-mcp-server/HEAD/LICENSE
- https://github.com/playcanvas/editor-mcp-server/releases （v0.7.1）
- https://www.npmjs.com/package/@playcanvas/editor-mcp-server
- https://www.threads.com/@davepoon128/post/DenVxBCkyaN （原清單來源貼文）
