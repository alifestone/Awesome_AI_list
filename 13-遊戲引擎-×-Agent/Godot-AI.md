# Godot AI

- **分類**：遊戲引擎 × Agent / 桌面遊戲引擎
- **連結**：https://github.com/hi-godot/godot-ai

## 原清單說明

46 個工具，直接控制執行中的 Godot 編輯器：場景、腳本、訊號（signal）、UI、粒子。

> **查證補充**：正確。README 與 `docs/TOOLS.md` 都寫「46 個 MCP 工具、120 多種操作（operations）」：19 個高頻動詞做成獨立工具，其餘每個領域收成一個 `<domain>_manage` 工具、用 `op="..."` 參數分派，刻意把工具數壓在部分用戶端 100 個工具上限之下。涵蓋範圍比貼文列的更廣，還包括材質／shader、動畫、相機、音訊、TileMap、GridMap、導航、CSG、測試與執行中遊戲的輸入模擬。**非 Godot 官方**：由 GitHub 組織 hi-godot 開發，MCP for Unity 的 README 稱它是「the makers of MCP for Unity」的新開源專案，與 Godot Foundation 無關聯（repo 中未見官方背書）。

## 概述

Godot AI 把 Claude Code、Claude Desktop、Codex、Hermes Agent、Cursor、VS Code 等 MCP 用戶端接到一個**正在執行的 Godot 編輯器**，讓 AI 建場景、改節點與腳本、接訊號、設定 UI、材質、動畫、粒子、相機與環境。README 展示用它約 2 小時做出 Cyberpunk HUD（無手寫程式碼與影像生成），以及用幾個提示做出含存檔系統的方塊世界遊戲。

截至 2026-10-18：MIT 授權、約 3.0k 顆星、主要語言 GDScript，repo 建立於 2026-04-12，最新版本 v4.3.0（2026-10-03），最近一次推送為 2026-10-17。

## 核心功能／特色

- **常駐核心工具**：`editor_state`、`scene_get_hierarchy`（分頁走訪場景樹）、`node_get_properties`、`session_activate`（多個編輯器時指定目標）。
- **高頻動詞**：`batch_execute`（原子化批次，第一個錯誤即回滾）、`node_create`／`node_set_property`／`node_find`、`scene_open`／`scene_save`、`script_create`／`script_attach`／`script_patch`、`project_run`、`test_run`、`logs_read`、`editor_screenshot`（3D／2D 視窗、Camera3D 電影渲染、執行中遊戲畫面）、`editor_reload_plugin`、`animation_create`。
- **領域 rollup（`*_manage`）**：scene、node、script、project、editor、session、test、animation、material（含 visual shader）、audio、particle、camera、signal、input_map、game（執行中遊戲的場景樹、UI 元素、鍵盤／滑鼠／手把輸入模擬、逐幀）、autoload、filesystem、theme、ui、resource、api、client、tilemap、tileset、gridmap、navigation、csg、custom（社群／自訂工具）。
- **驗證迴圈**：`project_run` 會等遊戲「活起來」並回報 `game_status` 與最近錯誤；GDScript 寫入後會做語法驗證、熱重載；`logs_read` 可讀出 Debugger 面板的錯誤與堆疊。
- **語言支援**：GDScript 完整支援；C# 只做文字層級（可寫 `.cs`、列符號），不負責 .NET 建置與編譯錯誤回報。
- 編輯器內有 Godot AI dock：一鍵設定用戶端、顯示連線狀態、一鍵更新。

## 技術架構或運作原理

```text
MCP 用戶端
  → godot-ai attach（stdio）
  → Python 伺服器（已驗證的 HTTP，port 8000）
  → Godot 編輯器外掛（已驗證的 WebSocket，port 9500）
```

- 兩段本機連線各自使用會輪替的 capability 憑證，不會退回未驗證存取；編輯器 WebSocket 只聽 loopback。
- agent 在容器或另一台機器時，於編輯器所在機器透過 SSH 執行橋接。
- v4 起不能直接把 `http://127.0.0.1:8000/mcp` 寫進用戶端設定，必須用 dock 產生的 `godot-ai attach` 指令。

## 安裝與使用方式

需求：Godot 4.7+（v4 系列）、[uv](https://docs.astral.sh/uv/)（提供 `uvx`）、任一 MCP 用戶端。

1. 從 [GitHub Releases](https://github.com/hi-godot/godot-ai/releases) 下載發行版，放到 `your-project/addons/godot_ai/`（`plugin.cfg` 要在該目錄內）。
2. Godot → Project → Project Settings → Plugins → 啟用 **Godot AI**，外掛會啟動 MCP 伺服器。
3. 在 Godot AI dock 對用戶端按 **Configure**（或 **Configure all**），必要時重啟用戶端。
4. 下提示，例如「顯示目前場景階層」「在 /Main 下建立名為 MainCamera 的 Camera3D」「跑場景測試」。

已安裝舊版者用 dock 的 **Update**；v3 → v4 有一鍵遷移，不要直接把新外掛解壓覆蓋舊目錄。

## 適用情境

- 獨立開發者用對話做 2D／3D 遊戲原型、HUD 與選單 UI。
- 讓 agent 寫 GDScript、跑遊戲、讀錯誤、模擬輸入驗證行為，再修正。
- 為 Godot 專案撰寫與執行自動化測試（`McpTestSuite`）。
- 批次調整場景、材質、粒子與 TileMap。

## 授權與成本

- **授權**：MIT（LICENSE 著作權人為「Godot AI contributors」）。
- **成本**：免費；需自行負擔 AI 模型／用戶端費用。

## 限制與注意事項

- 只支援 Godot 4.7+（v4）；舊版 Godot 需用舊版外掛，相容細節見 v4 遷移指南。
- C# 專案只能做文字編輯，建置錯誤需自己在編輯器或 `dotnet build` 檢查。
- **安全性**：README 坦承這些驗證機制無法防範同一使用者下已遭入侵的程序；Windows 也不保證與其他本機帳號隔離。
- **遙測**：預設收集安裝 UUID、事件、結果、時間、平台與版本（不含程式碼、場景內容、專案或檔名），可設 `GODOT_AI_DISABLE_TELEMETRY=true` 關閉。
- Linux 的 Flatpak、Steam、Fedora Atomic（Bazzite）環境有額外權限設定問題，README 有專段說明。
- 專案很新（2026-04 建立）且版本迭代快，升級時注意遷移說明。

## 相關工具

- 同資料夾：[Unity MCP](Unity-MCP.md)（同一批作者的 Unity 版）、[Unreal Engine MCP](Unreal-Engine-MCP.md)、[PlayCanvas Editor MCP](PlayCanvas-Editor-MCP.md)
- [cc-blender-skill](../02-3D-建模與生成/cc-blender-skill.md)：用 Blender MCP 做模型，匯出 glTF 給 Godot
- [Godot Engine](https://godotengine.org/)

## 資料來源

- https://github.com/hi-godot/godot-ai （README）
- https://api.github.com/repos/hi-godot/godot-ai （repo 中繼資料：授權、星數、建立與推送日期）
- https://raw.githubusercontent.com/hi-godot/godot-ai/HEAD/docs/TOOLS.md （46 個工具清單）
- https://raw.githubusercontent.com/hi-godot/godot-ai/HEAD/LICENSE
- https://github.com/hi-godot/godot-ai/releases （v4.3.0）
- https://github.com/CoplayDev/unity-mcp （提到 Godot AI 出自同一批作者）
- https://www.threads.com/@davepoon128/post/DenVxBCkyaN （原清單來源貼文）
