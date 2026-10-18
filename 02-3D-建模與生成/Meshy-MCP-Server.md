# Meshy MCP Server

- **分類**：3D 建模與生成 / AI 生成 3D 資產
- **連結**：https://github.com/meshy-dev/meshy-mcp-server （npm 套件：`@meshy-ai/meshy-mcp-server`；Meshy 官網：https://www.meshy.ai ；API 文件：https://docs.meshy.ai ）

## 原清單說明

讓 AI agent 直接做文字／圖片生成 3D、重新網格化（remesh）、重新貼圖（retexture）、綁骨（rig）與動畫。（來源：Threads @davepoon128 貼文）

> **查證補充**：正確，而且功能比貼文說的更多。README 列出 28 個工具，除上述功能外還有多圖生成 3D、文字生成動作、格式轉換、尺寸調整、UV 展開、2D 圖片生成，以及一整套 3D 列印工具（可列印性分析與修復、多色 3MF、自動拆件、切片軟體整合）。要注意的是：MCP 伺服器本身是 MIT 開源，但實際生成都在 Meshy 雲端執行，需要 **Pro 以上方案的 API 金鑰**並消耗付費點數。

## 概述

Meshy MCP Server 是 Meshy 官方的 [Model Context Protocol（MCP）](https://modelcontextprotocol.io) 伺服器，把 Meshy AI 3D 生成平台的 API 包成 agent 可呼叫的工具，讓 Claude Code、Cursor、Codex、Windsurf、VS Code 等 AI 用戶端透過自然對話建立、管理、下載 3D 模型、貼圖、圖片、綁骨角色與動畫。

截至 2026-10-18：MIT 授權、約 70 顆星、主要語言 TypeScript；repo 建立於 2026-04-03，最新版本 0.6.4（2026-10-13），更新頻繁。

## 核心功能／特色

28 個工具分類如下：

| 類別 | 工具 |
| --- | --- |
| 3D 生成 | `meshy_text_to_3d`、`meshy_text_to_3d_refine`、`meshy_image_to_3d`、`meshy_multi_image_to_3d` |
| Creative Lab | `meshy_creative_lab`（9 種產品：公仔、燈、鑰匙圈、冰箱貼、搪膠公仔、積木公仔、鍵帽、兩種紓壓玩具） |
| 後處理 | `meshy_remesh`、`meshy_retexture` |
| 綁骨與動畫 | `meshy_rig`、`meshy_animate`、`meshy_text_to_motion`、`meshy_list_animations` |
| 轉換 | `meshy_convert`（含 3MF）、`meshy_resize`（真實尺寸）、`meshy_uv_unwrap` |
| 圖片生成 | `meshy_text_to_image`、`meshy_image_to_image` |
| 任務管理 | `meshy_get_task_status`、`meshy_list_tasks`、`meshy_cancel_task`、`meshy_download_model` |
| 工作區 | `meshy_list_models` |
| 3D 列印 | `meshy_send_to_slicer`、`meshy_analyze_printability`、`meshy_repair_printability`、`meshy_process_multicolor`、`meshy_auto_split` |
| 帳戶 | `meshy_check_balance`、`meshy_list_usage` |

重點能力：

- **模型選擇**：`meshy-7.1`（`latest`）、`meshy-6`、`meshy-6-lite`（快速、便宜）；**Smart Topology**（`meshy-t2`／`meshy-t2.5`）直接生成指定面數、分件的乾淨三角網格（t2.5 最多 30,000 面）。
- **貼圖**：2K／4K／8K 貼圖；多視角圖片驅動貼圖與重新貼圖。
- **綁骨與動畫**：人形角色自動綁骨；一次套用最多 10 個預設動作，或用文字生成動作片段。
- **3D 列印**：免費的可列印性檢查（水密、孔洞、非流形邊、壁厚）、拓撲修復與加厚、9 家印表機品牌預設的多色 3MF、自動拆件加接頭；自動偵測 7 種切片軟體（OrcaSlicer、Bambu、Creality、Elegoo、Anycubic、PrusaSlicer、Cura）。
- **安全重試**（v0.6.3）：逾時或伺服器錯誤時不會重送建立請求，避免重複建立任務、重複扣點。
- **檔案管理**：自動存到 `meshy_output/`，依專案分資料夾並記錄中繼資料與歷史。
- **內建工作流程指引**：伺服器指令會引導 agent 用正確的工具順序完成各種任務。

## 技術架構或運作原理

- Node.js／TypeScript 實作的 MCP 伺服器，本身不跑模型，只把工具呼叫轉成 Meshy REST API（預設 `https://api.meshy.ai`）請求，並輪詢任務狀態、下載結果。
- 傳輸方式：預設 `stdio`；也可設 `TRANSPORT=http` 以 HTTP 提供服務（`POST /mcp`、`GET /health`），供遠端存取。
- 其他環境變數：`MESHY_API_KEY`（必填，`msy_` 開頭）、`MESHY_API_HOST`、`PORT`（預設 3000）、`CHARACTER_LIMIT`（回應長度上限，預設 25000）。
- Meshy 底層模型的架構細節，官方未公開，資料不足。

## 安裝與使用方式

需求：Node.js ≥ 18；Meshy API 金鑰（https://www.meshy.ai/developers/keys ，需 **Pro 以上方案**）。

一行安裝到本機所有偵測到的 AI 用戶端（使用 [add-mcp](https://github.com/neondatabase/add-mcp)）：

```bash
npx add-mcp @meshy-ai/meshy-mcp-server --env MESHY_API_KEY=msy_YOUR_API_KEY
```

Claude Code 手動安裝：

```bash
claude mcp add-json meshy '{"command":"npx","args":["-y","@meshy-ai/meshy-mcp-server"],"env":{"MESHY_API_KEY":"msy_YOUR_API_KEY"}}'
```

Cursor（`.cursor/mcp.json` 或 `~/.cursor/mcp.json`）：

```json
{
  "mcpServers": {
    "meshy": {
      "command": "npx",
      "args": ["-y", "@meshy-ai/meshy-mcp-server"],
      "env": { "MESHY_API_KEY": "msy_YOUR_API_KEY" }
    }
  }
}
```

- Windows 需把 `npx` 改成 `cmd /c npx ...`。
- Cursor 與 VS Code 安裝後需手動啟用伺服器；Claude Code、Codex 會自動載入。
- 也可直接請 agent 依 repo 文件幫你安裝。

## 適用情境

- 在 Claude Code、Cursor 等 agent 中一邊寫遊戲或網頁程式，一邊用對話生成並下載 3D 素材。
- 自動化的角色管線：生成 → 綁骨 → 套動畫 → 匯出。
- 3D 列印工作流程：照片生成公仔或鑰匙圈 → 檢查並修復可列印性 → 多色 3MF → 送切片軟體。
- 批次生成或重新貼圖大量道具資產。

## 授權與成本

- **MCP 伺服器授權**：MIT。
- **Meshy 服務**：付費雲端服務，API 採預付點數制，需在訂閱設定中購買 API 點數；API 金鑰需 Pro 以上方案。各方案的月費本次無法從官網取得，資料不足。
- **點數價格**（依 README 與 docs.meshy.ai/en/api/pricing）：

| 項目 | 點數 |
| --- | --- |
| `meshy-7.1`／`meshy-6` 生成 | 只有網格 20；含 2K／4K 貼圖 30；含 8K 貼圖 35 |
| `meshy-6-lite` 生成 | 只有網格 5；含 2K 貼圖 15 |
| Smart Topology（`meshy-t2`／`t2.5`，單圖） | 只有網格 5；含貼圖 15；8K 20 |
| Ultra 幾何（`geometry_resolution` 2k／4k） | +5 |
| 文字生成 3D refine（上貼圖） | 10（8K 為 15） |
| 重新貼圖 | 10（8K 為 15） |
| 重新網格化／綁骨／UV 展開 | 各 5 |
| 動畫 | 每個動作 3 |
| 文字生成動作 | 10（prime，FBX）／3（swift，BVH） |
| 轉換／調整尺寸 | 各 1 |
| 可列印性分析 | 免費 |
| 可列印性修復／多色／自動拆件 | 各 10 |
| Creative Lab | 多數產品 36；鍵帽 62；collapsible fidget 6 |

- 生成資產的商用權依 Meshy 服務條款與方案而定，本次未查證，資料不足。

## 限制與注意事項

- 需要網路與 Meshy 帳號，免費方案無法取得 API 金鑰。
- 每次呼叫都會扣點；agent 自動串連多步驟時花費可能累積很快，可在開發者平台替金鑰設定每月點數上限。
- `ai_model` 在各端點接受的值不同，`latest` 指向的模型也不同（重新貼圖的 `latest` 是 Meshy 7，不是 7.1）。
- `model_type: "lowpoly"` 將於 2026-10-30 停用，需改用 `smart-topology` + `meshy-t2`；`meshy-5` 已停用。
- 自動綁骨與動畫以人形角色為主。
- 專案更新頻繁，行為可能隨版本變動（CHANGELOG 有列出 0.6.3 的行為變更），建議固定版本。

## 相關工具

- [Meshy 官方 API 文件](https://docs.meshy.ai)、[add-mcp](https://github.com/neondatabase/add-mcp)、[Model Context Protocol](https://modelcontextprotocol.io)
- 同資料夾：TRELLIS.2、Hunyuan3D-2.1、Stable Fast 3D（可自架的開源模型）、Hyper3D（Rodin，另一個商業 3D 生成服務）、cc-blender-skill、FreeCAD MCP、Rhino MCP（其他 3D 類 agent 整合）

## 資料來源

- https://github.com/meshy-dev/meshy-mcp-server （README）
- https://api.github.com/repos/meshy-dev/meshy-mcp-server （repo 中繼資料）
- https://raw.githubusercontent.com/meshy-dev/meshy-mcp-server/main/package.json （版本）
- https://raw.githubusercontent.com/meshy-dev/meshy-mcp-server/main/CHANGELOG.md
- https://docs.meshy.ai/en/api/pricing （API 點數價格）
- https://docs.meshy.ai/en/api/authentication （API 金鑰與點數上限）
- https://www.threads.com/@davepoon128/post/DenVxBCkyaN （原始貼文）
