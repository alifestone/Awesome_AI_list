# Rhino MCP

- **分類**：3D 建模與生成 / CAD / 參數化建模
- **連結**：https://github.com/jingcheng-chen/rhinomcp

## 原清單說明

讓 AI 透過 MCP 操作 Rhino。

> **查證補充**：正確。除了 Rhino，同一個外掛也支援讓 AI 建立與操作 **Grasshopper** 參數化定義。

## 概述

RhinoMCP 透過 Model Context Protocol 把 Rhino 3D 接到 AI agent，讓 Claude、Cursor、Codex 等助理用對話方式建立幾何、讀取文件內容、擷取視窗畫面，並替使用者建構 Grasshopper 定義。作者為 Jingcheng Chen，屬第三方整合，非 McNeel 官方產品。

截至 2026-10-13：MIT 授權、約 1.1k 顆星、主要語言 Python（另有 C# 外掛），Python 伺服器發佈於 PyPI（`rhinomcp`）。

## 核心功能／特色

**Rhino**

- 建立幾何：點、線、多段線、圓、弧、橢圓、曲線、方塊、球、圓錐、圓柱、曲面，可單一或批次建立。
- 變形與編輯：移動、旋轉、縮放、改色、改名、刪除。
- 進階建模：Loft、Extrude、Sweep、Offset、Pipe；布林聯集、差集、交集。
- 曲線操作：投影、相交、分割。
- 圖層與屬性管理；依名稱／顏色／類別（AND／OR）篩選選取。
- `capture_viewport` 擷取視窗畫面給 AI 當視覺回饋；`analyze_objects` 量測長度、面積、體積、包圍盒。
- 進階：執行任意 Rhino 指令、RhinoScript-Python、RhinoCommon C#，並內建 RhinoScript 文件查詢。
- `undo`／`redo`。

**Grasshopper**

- 搜尋已安裝的元件庫、檢視元件的輸入輸出。
- 新增、更新、刪除、自動排版元件；連接或斷開參數。
- 設定與讀取滑桿、開關、面板、值清單；執行求解並回報警告與錯誤。
- `gh_build_graph`／`gh_mutate_graph` 一次批次建構或修改整張圖。

## 技術架構或運作原理

```
AI 用戶端 ──MCP (stdio)──► rhinomcp（Python）──TCP 127.0.0.1:1999──► Rhino 外掛 ──► Rhino + Grasshopper
```

1. `server/`：Python MCP 伺服器（官方 Python SDK 2.x），提供各工具並轉送到 Rhino。
2. `plugin/`：RhinoCommon C# 外掛，在 Rhino 內跑 TCP 監聽並在主執行緒執行指令；以 `mcpstart`／`mcpstop` 啟停。
3. `contracts/`：JSON Schema 定義，讓兩端的通訊協定保持同步。

伺服器連線時會讀取外掛版本，兩端版本不同時在日誌中警告；也隨套件附上建模指引（`get_modeling_guidance("overview")` 等）。

## 安裝與使用方式

需求：**Rhino 8**（Windows 或 macOS）、[uv](https://docs.astral.sh/uv/)（提供 `uvx`）。

1. **安裝 Rhino 外掛**：Rhino → Tools → Package Manager → 搜尋 `rhinomcp` → Install，重新啟動 Rhino。
2. **連接 AI 用戶端**：

```bash
claude mcp add rhino -- uvx rhinomcp@latest                                    # Claude Code
codex mcp add rhino --env RHINO_MCP_HOST=127.0.0.1 -- uvx rhinomcp@latest      # Codex
```

或手動設定：

```json
{
  "mcpServers": {
    "rhino": {
      "command": "uvx",
      "args": ["rhinomcp@latest"],
      "env": { "RHINO_MCP_HOST": "127.0.0.1" }
    }
  }
}
```

3. **啟動橋接**：Rhino 開啟後在指令列輸入 `mcpstart`（每個 Rhino 工作階段一次）。

範例提示：「在 Grasshopper 建立點吸引子圖樣：一格狀排列的圓柱，高度隨與吸引點的距離變化，並用滑桿移動吸引點。」

README 提醒：ChatGPT 的 app／MCP 連接器目前只連遠端 MCP 伺服器，不支援 `uvx rhinomcp` 這類本機 stdio 指令，需改用 Codex 或自建遠端／通道端點。

## 適用情境

- 建築、產品設計師用自然語言快速建立或修改 Rhino 模型。
- 讓 AI 代為建構與調整 Grasshopper 參數化定義。
- 依視窗截圖做迭代修正的「看得到畫面」建模流程。
- 透過 RhinoScript-Python／C# 做批次自動化。

## 授權與成本

- **授權**：RhinoMCP 為 MIT。
- **成本**：RhinoMCP 免費；但 Rhino 8 是商業軟體，需另購授權（價格本次未查證，資料不足），另需負擔所用 AI 模型的費用。

## 限制與注意事項

- 只支援 Rhino 8（Windows／macOS）。
- 一次只能執行一個 RhinoMCP 伺服器（不要讓 Codex、Claude、Cursor 同時各啟一個）。
- **安全性**：Python 伺服器與 Rhino 外掛之間是**未驗證**的 TCP 本機連線（127.0.0.1:1999）；`run_command`、RhinoScript、C# 執行等於給模型開放的執行權限。不要在未加驗證的情況下暴露到本機以外。可用 `RHINO_MCP_ENABLE_RUN_COMMAND=0`、`RHINO_MCP_ENABLE_RHINOSCRIPT=0`、`RHINO_MCP_ENABLE_CSHARP=0` 關閉對應工具；非本機主機需 `RHINO_MCP_ALLOW_REMOTE=1` 才會連線。
- 三個元件（Python 伺服器、Rhino 外掛、AI 用戶端）各自更新；用 `uvx rhinomcp`（不加 `@latest`）會固定在第一次下載的版本。

## 相關工具

- [Rhino 3D](https://www.rhino3d.com/)、Grasshopper
- 同資料夾：FreeCAD MCP（開源 CAD 版本）、MAC – Multi-Agent CAD

## 資料來源

- https://github.com/jingcheng-chen/rhinomcp （README）
- https://api.github.com/repos/jingcheng-chen/rhinomcp （repo 中繼資料：授權、星數、推送日期）
