# FreeCAD MCP

- **分類**：3D 建模與生成 / CAD / 參數化建模
- **連結**：https://github.com/neka-nat/freecad-mcp

## 原清單說明

讓 AI 透過 MCP 操作 FreeCAD。

## 概述

FreeCAD 的 MCP（Model Context Protocol）伺服器。讓 Claude Desktop 等 MCP 用戶端直接控制開源參數化 CAD 軟體 FreeCAD：建立與編輯模型、執行 Python 腳本、檢視文件，並可執行 FEM（有限元素）分析。

截至 2026-10-13：MIT 授權、約 2.8k 顆星、主要語言 Python，最近一次推送為 2026-10-07。

## 核心功能／特色

提供的 MCP 工具（`docs/tools.md`）：

| 類別 | 工具 |
| --- | --- |
| 文件 | `create_document`、`list_documents`、`reload_document` |
| 物件 | `create_object`、`edit_object`、`delete_object`、`get_objects`、`get_object` |
| 視覺回饋 | `get_view`（截取視圖，支援 Isometric／Front／Top／Right／Back／Left／Bottom／Dimetric／Trimetric） |
| 程式執行 | `execute_code`（GUI 執行緒）、`execute_code_async`（背景工作）、`get_async_status`、`execute_code_headless`（獨立 `freecadcmd` 程序） |
| 零件庫 | `get_parts_list`、`insert_part_from_library`（FreeCAD 官方零件庫） |
| 分析 | `run_fem_analysis`（呼叫 CalculiX，回傳最大 von Mises 應力、最大／最小位移、節點數） |
| 診斷 | `get_rpc_status` |

- 多數工具可附帶截圖回饋（`include_screenshot`、`view_name`），也可用 `--only-text-feedback` 全域關閉截圖以節省 token。
- README 示範：設計法蘭（flange）、玩具車、依 2D 圖面建模，以及 ADK、LangChain 整合範例。

## 技術架構或運作原理

分成兩個元件：

1. **FreeCAD 外掛（`addon/FreeCADMCP`）**：在 FreeCAD 內啟動 RPC 伺服器（預設只聽 localhost）。
2. **MCP 伺服器**：由 MCP 用戶端以 `uvx freecad-mcp` 啟動，將工具呼叫轉送給 FreeCAD 的 RPC 伺服器。

執行模式：

- `execute_code` 在 GUI 執行緒依 FIFO 依序執行，預設佇列與執行時間各 90 秒，可用 `timeout` 參數放寬（上限 1800 秒）。
- `execute_code_async` 適合長時間純幾何運算，用 `commit()` 把結果交回 GUI 執行緒寫入文件。
- `execute_code_headless` 在獨立程序中執行可能讓 OpenCascade 崩潰的操作（如螺紋、loft、大量 B-spline 布林運算），崩潰只會結束輔助程序，GUI 文件不受影響。

## 安裝與使用方式

需求：FreeCAD 與 [uv／uvx](https://docs.astral.sh/uv/guides/tools/)。

```bash
git clone https://github.com/neka-nat/freecad-mcp.git
cd freecad-mcp
# 將 addon/FreeCADMCP 複製到 FreeCAD 的 addon 目錄後重新啟動 FreeCAD
# 切換到「MCP Addon」workbench，在「FreeCAD MCP」工具列按「Start RPC Server」
```

Claude Desktop 設定（`claude_desktop_config.json`）：

```json
{
  "mcpServers": {
    "freecad": {
      "command": "uvx",
      "args": ["freecad-mcp"]
    }
  }
}
```

其他選項：

- 在 FreeCAD MCP 選單勾選「Auto-Start Server」可讓 RPC 伺服器隨 FreeCAD 啟動。
- 遠端操作：在 FreeCAD 開啟 Remote Connections 並設定 Allowed IPs，MCP 端加 `--host <IP>`；建議再設定 Auth Token（以 `FREECAD_MCP_TOKEN` 環境變數傳入），或改用 SSH 通道（`ssh -N -L 9875:localhost:9875 user@freecad-host`）。
- 指定 headless 執行檔：`freecad-mcp --freecadcmd "flatpak run --command=freecadcmd org.freecad.FreeCAD"`。

## 適用情境

- 用自然語言做機械零件、治具等參數化建模。
- 讓 AI 依 2D 圖面重建 3D 模型。
- 自動化 FEM 結構分析流程（建幾何 → 材料 → 網格 → 拘束 → 求解）。
- 作為 LangChain、Google ADK 等 agent 框架的 CAD 工具。

## 授權與成本

- **授權**：MIT。
- **成本**：本身與 FreeCAD 皆免費；需自行負擔所用 AI 模型／用戶端的費用。

## 限制與注意事項

- **安全性**：`execute_code` 以使用者權限在 FreeCAD 內執行任意 Python。RPC 伺服器預設不驗證（除非設定 token）且永不加密；開放遠端連線時務必限縮允許 IP 並設 token。伺服器會拒絕瀏覽器發出的請求。
- GUI 任務一旦開始就無法取消；逾時後結果會被丟棄，但任務仍在背景跑完。若出現 `GUI_DISPATCH_STUCK` 且狀態無法恢復，需重啟 FreeCAD。
- 腳本執行成功不代表幾何有效（文件原文：「Script success does not certify geometry validity」）。
- headless 執行發生在 MCP 伺服器所在的機器，檔案路徑需在該機器上可存取。
- 新功能（如 job status、自訂 timeout）需更新 FreeCAD 外掛版本。

## 相關工具

- [FreeCAD](https://www.freecad.org/)、[CalculiX](http://www.calculix.de/)
- 同資料夾：Rhino MCP（Rhino／Grasshopper 版本）、MAC – Multi-Agent CAD（text-to-CAD，build123d）、text-to-cad（agent CAD 外掛，build123d）

## 資料來源

- https://github.com/neka-nat/freecad-mcp （README）
- https://api.github.com/repos/neka-nat/freecad-mcp （repo 中繼資料：授權、星數、推送日期）
- https://raw.githubusercontent.com/neka-nat/freecad-mcp/HEAD/docs/tools.md
- https://raw.githubusercontent.com/neka-nat/freecad-mcp/HEAD/docs/configuration.md
- https://raw.githubusercontent.com/neka-nat/freecad-mcp/HEAD/docs/execution.md
