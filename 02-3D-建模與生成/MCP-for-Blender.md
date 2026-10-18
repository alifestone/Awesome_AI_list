# MCP for Blender（原 blender-mcp）

- **分類**：3D 建模與生成 / Blender × Agent
- **連結**：https://github.com/ahujasid/mcp-for-blender （舊網址 https://github.com/ahujasid/blender-mcp 會自動轉址；官網：https://www.mcp-for-blender.com/ ）

## 原清單說明

在執行中的 Blender 裡，用提示詞驅動建模與場景搭建。

> **查證補充**：正確。這個 repo 就是社群熟知的 `ahujasid/blender-mcp`：作者在 2026-09-16 宣布改名（issue #366），repo 從 `ahujasid/blender-mcp` 搬到 `ahujasid/mcp-for-blender`，PyPI 套件也從 `blender-mcp` 改為 `mcp-for-blender`。GitHub API 查 `ahujasid/blender-mcp` 會直接回傳 `ahujasid/mcp-for-blender`，星數、fork、issue 全數保留。舊的 `uvx blender-mcp` 設定仍可用（舊套件改為轉接用的相容包裝），Python 匯入路徑仍是 `blender_mcp`。作者說明改名是為了強調這是**社群外掛、非 Blender 官方產品**，避免和官方 Blender Lab MCP 混淆。

## 概述

MCP for Blender 透過 Model Context Protocol（MCP）把 Blender 接上 Claude、Codex、Cursor 等 AI 用戶端，讓 AI 直接在你開著的 Blender 裡寫 Python、建立與修改物件、上材質、搜尋與匯入素材，並截圖檢查自己的成果。作者為 Siddharth Ahuja（[@sidahuj](https://x.com/sidahuj)），最早於 2025-03 發布，是最早、也最廣為使用的 Blender MCP 之一。

截至 2026-10-18：MIT 授權、約 31.4k 顆星、主要語言 Python，PyPI 最新版 2.1.9，最近一次推送為 2026-10-06。

## 核心功能／特色

- **雙向溝通**：Blender 外掛在 Blender 內開 socket 伺服器，MCP 伺服器把 AI 的指令轉送過去並回傳結果。
- **9 個 MCP 工具**（README 的 Capabilities 表）：
  - `execute_blender_code`：在執行中的 Blender 跑任意 Python（建模、排版、材質、動畫、綁骨、重拓樸都靠 AI 自己寫 Python 完成）
  - `look`：從視窗、攝影機、自動取景的多角度圖、動畫影格條等角度「看」結果，可切換 solid／material／rendered／wireframe／xray 顯示，讓 AI 自我檢查
  - `get_scene_info`：精簡的場景摘要（每個物件一行，欄位可選）
  - `generate_3d`：一次呼叫就用 Tripo、Hunyuan3D 或 Hyper3D Rodin 生成並匯入模型
  - `search_assets`／`import_asset`：搜尋與匯入 [Poly Haven](https://polyhaven.com/)（HDRI、貼圖、模型，皆 CC0）、Sketchfab 模型、[Poly Pizza](https://poly.pizza/) 低多邊形模型
  - `get_addon_status`、`disable_telemetry`、`record_trajectory_feedback`
- **素材授權資訊自動寫入**：匯入 Poly Haven、Poly Pizza 素材時，會把來源、作者、授權寫成物件的 custom property；Poly Pizza 約 69% 為 CC-BY，需標示作者，可用 `licence="CC0"` 過濾。
- **Safe mode**：設 `BLENDER_MCP_SAFE_MODE=1` 後，每段腳本執行前先檢查，擋下直接讀寫檔案、執行其他程式、存取網路等風險操作；被擋的腳本會連同原因退回給 AI 重寫。
- **Codex 外掛**：在 Codex 對話中內嵌即時視窗（點物件即可附到下一則訊息）、素材縮圖挑選器、場景物件 `@` 提及。
- **一鍵安裝**：自動偵測本機的 Claude Desktop、Claude Code、Codex、Cursor、VS Code、Windsurf、OpenCode、Antigravity 並寫入設定，同時安裝並啟用 Blender 外掛。

## 技術架構或運作原理

- 兩個元件：
  1. **Blender 外掛**（`addon.py`）：在 Blender 內建立 socket 伺服器（預設 `localhost:9876`），接收並執行指令。
  2. **MCP 伺服器**（`src/blender_mcp/server.py`）：實作 MCP 協定，透過 stdio 與 AI 用戶端溝通，再以 TCP 連到 Blender 外掛。
- 通訊協定為簡單的 JSON over TCP：指令含 `type` 與選用的 `params`，回應含 `status` 與 `result` 或 `message`。
- 可用 `--port` 參數讓多個 MCP 項目各自連到不同 Blender 實例；MCP 伺服器也可放進 Docker 執行（Blender 仍在本機）。

## 安裝與使用方式

前置需求：Blender 3.0 以上、Python 3.10 以上、[uv](https://docs.astral.sh/uv/)（README 強調要用官方安裝程式，不要 `pip install uv`）。

一鍵安裝（macOS／Linux）：

```bash
curl -LsSf https://www.mcp-for-blender.com/install.sh | sh
# 已有 uv 時：
uvx mcp-for-blender setup
```

手動安裝：

```bash
# Claude Code
claude mcp add blender uvx mcp-for-blender
# Codex
codex mcp add blender -- uvx mcp-for-blender
# 安裝 Blender 外掛
uvx mcp-for-blender install-addon
```

接著在 Blender 的 **Edit → Preferences → Add-ons** 啟用 **Interface: MCP for Blender**，在 3D 視窗按 `N` 開側欄的 MCP for Blender 分頁確認伺服器已啟動，然後完全關閉並重開 AI 用戶端即可。

舊用戶升級：`uvx mcp-for-blender@latest update`（會一併更新所有已安裝的外掛副本並保留 `.bak`）。

README 範例指令：

```
Create a low poly scene in a dungeon, with a dragon guarding a pot of gold
Create a beach vibe using HDRIs, textures, and models like rocks and vegetation from Poly Haven
Make this car red and metallic
Point the camera at the scene, and make it isometric
```

## 適用情境

- 用對話快速搭建低多邊形或概念場景、擺設道具、打光、設定攝影機。
- 從參考圖重建 Blender 場景，或把現有場景轉成 Three.js 草稿。
- 結合 Poly Haven／Sketchfab／Poly Pizza 素材與 AI 生成模型，快速填滿場景。
- 作為 cc-blender-skill 等 Blender skill 包的底層 MCP 後端。

## 授權與成本

- **授權**：MIT。
- **免費部分**：外掛與 MCP 伺服器免費開源；場景編輯、Poly Haven、Sketchfab、Poly Pizza 都可免費使用。AI 生成模型需自備 Tripo／Hunyuan3D／Hyper3D 的 API 金鑰，費用直接付給供應商。
- **Premium 訂閱**（官網 premium 頁，2026-10-18 查閱）：不需自備金鑰即可生成 3D 模型（Hunyuan3D v3.1、Tripo、Hyper3D Rodin）。

| 方案 | 月費 | 標準生成數 | 高品質生成數 | 其他 |
| --- | --- | --- | --- | --- |
| Hobby | $10 | 25 | 無 | 3 台電腦 |
| Pro | $20 | 25 | 8 | 3 台電腦 |
| Studio | $60 | 60 | 30 | 3 台電腦，可同時 3 個生成 |
| Max | $100 | 100 | 50 | 3 台電腦，可同時 3 個生成 |
| Enterprise | 洽詢 | 客製 | 客製 | 更多電腦、團隊統一帳單 |

  - 每月額度不累積、失敗不計次、不退款；年繳約等於「送 2 個月」，年繳價格未列出。
- 另需負擔所用 AI 模型（Claude、GPT 等）的費用。

## 限制與注意事項

- ⚠️ **安全**：`execute_blender_code` 可在 Blender 中執行任意 Python，README 警告使用前**務必先存檔**；外掛的 socket 伺服器沒有驗證也沒有加密，能連到該埠的人都能在 Blender 裡執行 Python，請只綁在 `localhost`，遠端請改用 SSH 通道。必要時開啟 safe mode。
- ⚠️ **遙測**：預設會收集匿名使用紀錄（安裝 ID、工具名稱、成功與否、耗時、版本、作業系統等）；提示詞、程式碼、截圖、場景資料需使用者主動同意才收集。完全關閉需設 `DISABLE_TELEMETRY=true`。README 說遙測資料可能用於研究與訓練 AI 模型。
- 同一時間只能跑**一個** MCP 伺服器實例（例如不要同時在 Cursor 和 Claude Desktop 開）。
- 複雜操作可能逾時，需拆成小步驟；Poly Haven 下載在 Blender 主執行緒進行，下載大檔時介面會卡住。
- Poly Pizza 的 CDN 有 Cloudflare 防護，資料中心、VPN、雲端 IP 可能被擋。
- 這是第三方社群外掛，與 Blender 基金會無關。

## 相關工具

- [官方 Blender Lab MCP](https://www.blender.org/lab/mcp-server/)（Blender 官方的 MCP 伺服器）
- 同資料夾：[cc-blender-skill](cc-blender-skill.md)（以本專案為後端之一的 Blender skill 包）、[TheLongSilence](TheLongSilence.md)（`blender-hardsurface` skill，也透過 Blender MCP 操作）、[Hyper3D（Rodin）](Hyper3D（Rodin）.md)（`generate_3d` 可呼叫的生成服務）

## 資料來源

- 原清單來源：Threads @davepoon128 貼文 https://www.threads.com/@davepoon128/post/DenVxBCkyaN
- https://github.com/ahujasid/mcp-for-blender （README）
- https://api.github.com/repos/ahujasid/blender-mcp （確認舊名轉址至 mcp-for-blender；星數、授權、推送日期）
- https://github.com/ahujasid/mcp-for-blender/issues/366 （「blender-mcp is now mcp-for-blender」改名說明，2026-09-16）
- https://pypi.org/project/mcp-for-blender/ （最新版本 2.1.9）
- https://www.mcp-for-blender.com/premium （Premium 方案與價格）
