# Unity MCP（MCP for Unity）

- **分類**：遊戲引擎 × Agent / 桌面遊戲引擎
- **連結**：https://github.com/CoplayDev/unity-mcp （文件站：https://coplaydev.github.io/unity-mcp/ ）

## 原清單說明

用白話文驅動 Unity 編輯器：建場景、寫 C# 腳本、管理素材、跑測試、輸出 build。

> **查證補充**：正確。README 寫的是「建立場景與 GameObject、編輯 C# 腳本、管理素材、跑測試、效能分析（profile）與建置」，並稱有「50 個 MCP 工具進入點」；文件站自動產生的工具目錄（截至 2026-10-18）實際列出 49 個、分 10 個工具群組，Tool Groups 說明頁則寫 48 個，數字在 48–50 之間浮動，以實際版本為準。**非 Unity Technologies 官方**：README 的 Disclaimer 明寫「not affiliated with Unity Technologies」，由 CoplayDev 開發，目前由 Aura 贊助與維護。

## 概述

MCP for Unity 是連接 AI 助理（Claude、Codex、VS Code、本地 LLM 等）與 Unity 編輯器的 MCP 橋接器。安裝成 Unity 套件後，AI 就能直接在開著的編輯器裡操作場景、GameObject、元件、腳本、素材、Prefab、材質、shader、動畫、UI Toolkit、測試與建置。專案另有論文〈MCP-Unity: Protocol-Driven Framework for Interactive 3D Authoring〉（SIGGRAPH Asia 2025 Technical Communications）。

截至 2026-10-18：MIT 授權、約 15.1k 顆星、主要語言 C#，最新版本 v10.3.0（2026-10-04），最近一次推送為 2026-10-17。

## 核心功能／特色

工具依群組管理，預設只開 `core`，其他群組用 `manage_tools` 依需要啟用，避免一次塞太多工具定義給 LLM：

| 群組 | 工具數 | 內容 |
| --- | --- | --- |
| `core`（預設開啟） | 30 | 場景、GameObject、元件、腳本建立／編輯（`create_script`、`apply_text_edits`、`script_apply_edits`、`validate_script`）、素材、Prefab、材質、相機、物理、圖形、套件、建置（`manage_build`）、選單項目、Console 讀取、`batch_execute` |
| `animation` | 1 | Animator 控制、AnimationClip 建立 |
| `ui` | 1 | UI Toolkit（UXML、USS、UIDocument） |
| `vfx` | 3 | VFX Graph、shader、程序化貼圖 |
| `scripting_ext` | 2 | `execute_code`、ScriptableObject 管理 |
| `testing` | 2 | `run_tests`、非同步測試工作查詢 |
| `probuilder` | 1 | ProBuilder 建模（需 `com.unity.probuilder`） |
| `profiling` | 1 | Profiler、記憶體快照、Frame Debugger |
| `docs` | 2 | Unity API 反射查詢、文件查詢 |
| `asset_gen` | 6 | AI 生成 3D 模型（Tripo、Meshy、fal）、2D 圖片（fal.ai、OpenRouter）、音效（fal.ai），Sketchfab 匯入、本機模型匯入、Blender Bridge（自備 API key） |

- **多實例路由**：一個用戶端可切換驅動多個 Unity 編輯器（`set_active_instance`）。
- **Roslyn 腳本驗證**：寫入 C# 前先做語法檢查。
- **Blender Bridge**：連到已裝 BlenderMCP 外掛的 Blender（預設 `127.0.0.1:9876`），把 Blender 做好的模型帶進 Unity。
- **自訂工具**：可在專案中註冊 project-scoped 的自訂工具。
- repo 附 `unity-mcp-skill/`（Agent Skill 與工具參考）。

## 技術架構或運作原理

三段式：MCP 用戶端 → Python MCP 伺服器（`Server/`，以 `uv` 執行）→ Unity 編輯器內的 C# 套件（`MCPForUnity/`）。

- **HTTP 模式（預設）**：單一 Python 程序提供 `http://localhost:8080/mcp`，內建 WebSocket hub（`/hub/plugin`）接 Unity；多個 MCP 用戶端（如 Claude Code 與 Cursor）可同時操作同一個編輯器，各自有獨立 session 狀態；也可遠端或 Docker 部署（另有 Remote Server Auth 驗證說明）。
- **stdio 模式**：設定最簡單，Claude Desktop 預設。

## 安裝與使用方式

需求：Unity 2021.3 LTS 到 6.x、Python 3.10+（透過 [uv](https://docs.astral.sh/uv/)）、任一 MCP 用戶端（Claude Desktop／Code、Cursor、VS Code、Windsurf、Cline、Gemini CLI 等）。

1. Unity → Package Manager → Add package from git URL：
   ```
   https://github.com/CoplayDev/unity-mcp.git?path=/MCPForUnity#main
   ```
   （或 `openupm add com.coplaydev.unity-mcp`；可固定版本 tag）
2. `Window → MCP for Unity → Configure All Detected Clients`，自動寫入偵測到的用戶端設定。
3. 下提示，例如「在原點建一個 Cube 並加上 Rigidbody」。
4. 需要動畫、VFX、測試等工具時，請 AI 呼叫 `manage_tools(action="activate", group="vfx")` 啟用該群組。

## 適用情境

- 用對話快速搭出關卡原型、擺放物件、調材質與光照。
- 讓 agent 寫 C# 腳本、看 Console 錯誤、修正後再跑測試，形成迴圈。
- 自動化重複性的編輯器工作（批次改 Prefab、匯入素材、輸出 build）。
- 搭配 AI 生成 3D／圖片／音效，從零產生遊戲原型素材。

## 授權與成本

- **授權**：MIT（LICENSE 著作權人為 CoplayDev）。
- **成本**：套件本身免費；需自行負擔 AI 模型／用戶端費用。`asset_gen` 群組為自備金鑰（BYOK），會產生 Tripo、Meshy、fal.ai 等第三方服務費用。
- 同團隊另有付費產品 Aura for Unity（Unity／Unreal AI 助理），價格本次未查，資料不足。

## 限制與注意事項

- **安全性**：`execute_code`、`execute_menu_item` 等工具能在編輯器內執行任意程式或選單指令，等同給 AI 使用者權限；HTTP 模式若開放遠端，務必啟用驗證。
- **遙測**：預設收集匿名使用資料（工具使用、效能、Unity 版本、平台，不含程式碼與專案名稱），可設 `DISABLE_TELEMETRY=true` 或 `UNITY_MCP_DISABLE_TELEMETRY=true` 關閉。
- 工具數量多，非 `core` 群組預設關閉，需要時記得啟用。
- 大版本升級（v5、v6、v8、v10）有遷移說明，升級前請先看。
- 非 Unity 官方，Unity 版本更新後可能需等待相容修正。

## 相關工具

- 同資料夾：[Godot AI](Godot-AI.md)（同一批作者的 Godot 版）、[Unreal Engine MCP](Unreal-Engine-MCP.md)（同屬 Aura 旗下）、[PlayCanvas Editor MCP](PlayCanvas-Editor-MCP.md)
- [cc-blender-skill](../02-3D-建模與生成/cc-blender-skill.md)：Blender MCP 做素材，再透過 Blender Bridge 或 FBX／glTF 匯入 Unity
- [Hyper3D（Rodin）](../02-3D-建模與生成/Hyper3D（Rodin）.md)：另一種 AI 生成 3D 資產的來源

## 資料來源

- https://github.com/CoplayDev/unity-mcp （README）
- https://api.github.com/repos/CoplayDev/unity-mcp （repo 中繼資料：授權、星數、推送日期）
- https://raw.githubusercontent.com/CoplayDev/unity-mcp/main/LICENSE
- https://raw.githubusercontent.com/CoplayDev/unity-mcp/main/website/docs/reference/tools/index.md （自動產生的工具目錄）
- https://raw.githubusercontent.com/CoplayDev/unity-mcp/main/website/docs/guides/tool-groups.md
- https://raw.githubusercontent.com/CoplayDev/unity-mcp/main/website/docs/architecture/transports.md
- https://raw.githubusercontent.com/CoplayDev/unity-mcp/main/website/docs/architecture/telemetry.md
- https://www.threads.com/@davepoon128/post/DenVxBCkyaN （原清單來源貼文）
