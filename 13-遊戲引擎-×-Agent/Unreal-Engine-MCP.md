# Unreal Engine MCP（Flopperam）

- **分類**：遊戲引擎 × Agent / 桌面遊戲引擎
- **連結**：https://github.com/flopperam/unreal-engine-mcp

## 原清單說明

控制執行中的 Unreal 編輯器：Actor、世界建構、Blueprint。

> **查證補充**：大致正確，但要分清楚 repo 裡其實是**兩樣東西**：
> 1. **開源本機 MCP**（`Python/` 伺服器 + `UnrealMCP/` C++ 外掛）：本次清點 `unreal_mcp_server_advanced.py` 共 43 個工具，涵蓋 Actor 管理、世界建構（城鎮、房屋、城堡、吊橋、迷宮等）、物理與材質、基礎 Blueprint 節點編輯，正是貼文描述的範圍。README 自稱是「較簡單、社群維護」的版本。
> 2. **託管版 Flop MCP**（`agent.flopperam.com/mcp`，需 API key）：50 多個工具，涵蓋 Blueprint 完整生命週期、材質、Niagara、動畫、Landscape、行為樹／GAS、Sequencer、PCG、PIE 執行期測試等。README 明說它與本 repo 的 Python 伺服器**不共用任何程式碼**，也不開源。
>
> 另外：Flopperam 已被 **Aura** 收購（README 頂部公告），repo 最近一次推送為 2026-06-26，且只是更新收購公告；**非 Epic Games 官方**。⚠️ README 寫「MIT License」，但 repo 中找不到 LICENSE 檔，GitHub 也偵測不到授權。

## 概述

Flopperam 的 Unreal Engine MCP 讓 Cursor、Claude Code、Windsurf、VS Code Copilot、Cline 等 MCP 用戶端，用自然語言控制一個正在執行的 Unreal 編輯器。開源本機版以「一句話蓋出整座城鎮／城堡」的程序化世界建構工具為特色（官方影片示範一個提示生成 4,000 多個物件的都市），並提供基礎的 Blueprint 讀寫與節點連接；更完整的功能被導向託管版與付費 agent（Flop Agent，現屬 Aura）。

截至 2026-10-18：約 1.1k 顆星、主要語言 C++，repo 建立於 2025-08-06，最近一次推送為 2026-06-26；GitHub 未偵測到授權。

## 核心功能／特色

**開源本機 MCP（43 個工具）**

| 類別 | 工具 |
| --- | --- |
| Actor 管理 | `get_actors_in_level`、`find_actors_by_name`、`delete_actor`、`set_actor_transform`、`get_actor_material_info` |
| 世界建構 | `create_town`、`construct_house`、`construct_mansion`、`create_tower`、`create_arch`、`create_staircase` |
| 大型結構 | `create_castle_fortress`、`create_suspension_bridge`、`create_aqueduct` |
| 關卡設計 | `create_maze`、`create_pyramid`、`create_wall` |
| 物理與材質 | `spawn_physics_blueprint_actor`、`set_physics_properties`、`get_available_materials`、`apply_material_to_actor`、`apply_material_to_blueprint`、`set_mesh_material_color` |
| Blueprint 系統 | `create_blueprint`、`compile_blueprint`、`add_component_to_blueprint`、`set_static_mesh_properties` |
| Blueprint 視覺腳本 | `add_node`、`add_event_node`、`connect_nodes`、`delete_node`、`set_node_property`、`create_variable`、`set_blueprint_variable_properties`、`create_function`、`add_function_input`、`add_function_output`、`delete_function`、`rename_function`（README 稱支援 23 種以上節點） |
| Blueprint 分析 | `read_blueprint_content`、`analyze_blueprint_graph`、`get_blueprint_variable_details`、`get_blueprint_function_details` |

- repo 另附 Cursor 外掛設定、`rules/`（錯誤復原與慣例）與 `skills/`（blueprint-authoring、material-vfx、scene-building 等）給 agent 參考。

**託管版 Flop MCP（50+ 工具，非開源）**：Blueprint 撰寫與檢查、場景查詢與宣告式生成、材質、Niagara／Chaos、動畫與 IK 重定向、UMG、行為樹與 GAS、Landscape／Foliage、Sequencer、MetaSound、PCG、資料資產、編輯器記錄與效能稽核、PIE 測試（30 多種斷言）、編輯器內 Python 執行、15,000 多筆 Unreal API 查詢。

## 技術架構或運作原理

- **開源本機版**：MCP 用戶端 →（stdio）→ Python 伺服器 `unreal_mcp_server_advanced.py`（FastMCP）→（TCP socket，`127.0.0.1:55557`）→ UnrealMCP C++ 外掛 → Unreal 5.5+ 原生 API。
- **託管版**：MCP 用戶端 →（Streamable HTTP）→ `agent.flopperam.com/mcp` →（WebSocket）→ FlopAI 外掛（C++／Python 橋接）→ Unreal 編輯器與執行期。

## 安裝與使用方式

**開源本機版**（依 `LOCAL_SETUP.md`）：需求 Unreal Engine 5.5+、Python（文件寫 3.12+，`pyproject.toml` 寫 `>=3.10,<3.14`）、uv、MCP 用戶端。

```bash
git clone https://github.com/flopperam/unreal-engine-mcp.git
cd unreal-engine-mcp
# 方式 A：直接開啟 FlopperamUnrealMCP/FlopperamUnrealMCP.uproject（外掛已啟用）
# 方式 B：把 UnrealMCP/ 複製到自己專案的 Plugins/，在 Edit → Plugins 啟用後重啟
cd Python
uv run unreal_mcp_server_advanced.py
```

MCP 用戶端設定以 `uv --directory <repo>/Python run unreal_mcp_server_advanced.py` 啟動伺服器；macOS 需自行編譯外掛（見 LOCAL_SETUP.md）。

**託管版**：到 flopperam.com/account 取得 API key → 安裝 FlopAI 外掛 → 在用戶端加入 `https://agent.flopperam.com/mcp` 與 `Authorization: Bearer <API_KEY>` 標頭（Claude Code：`claude mcp add -H "Authorization: Bearer YOUR_API_KEY" --transport http flopperam-unreal https://agent.flopperam.com/mcp`）。

## 適用情境

- 用一句話快速擺出城鎮、城堡、迷宮等大型場景草稿，做關卡概念或展示影片。
- 讓 AI 建立與修改簡單的 Blueprint（變數、函式、節點連線）並編譯。
- 研究 Unreal 編輯器與 MCP 之間的 C++ socket 橋接實作。
- 需要材質、Niagara、動畫、PCG 等深度功能時，改評估託管版或 Aura。

## 授權與成本

- **授權**：⚠️ README 宣稱 MIT，但 repo 根目錄與子目錄都沒有 LICENSE 檔，GitHub API 回報無授權。嚴格來說未附授權檔時預設保留所有權利，商用或再散布前建議向維護方確認。
- **成本**：開源本機版免費（需自付 AI 模型費用）；託管版 Flop MCP 需 API key，計價方式本次未查到，資料不足；Flop Agent／Aura 為商業產品，價格資料不足。
- Unreal Engine 本身依 Epic 的 EULA 授權（含權利金條款），與本工具無關，請另行確認。

## 限制與注意事項

- 開源本機版功能明顯少於託管版，且 README 一再導流到託管版與 Aura；收購後本機版的後續維護動向不明（最後一次推送只是改公告）。
- 世界建構工具偏向「用基本形體程序化堆疊」，產出是灰盒／原型等級，不是成品美術。
- 託管版會把指令經由第三方伺服器轉送到你的編輯器，並含任意 Python 執行，使用前請評估資料與安全政策。
- 只支援 Unreal 5.5+（Flop Agent 標示支援 5.5、5.6、5.7）。
- 非 Epic 官方。

## 相關工具

- 同資料夾：[Unity MCP](Unity-MCP.md)（同屬 Aura 旗下）、[Godot AI](Godot-AI.md)、[PlayCanvas Editor MCP](PlayCanvas-Editor-MCP.md)
- [cc-blender-skill](../02-3D-建模與生成/cc-blender-skill.md)：v1.4.0 起含 Unreal 碰撞網格匯出前檢，可在 Blender 做素材再匯入 Unreal
- [World Labs](../02-3D-建模與生成/World-Labs.md)：生成可匯出網格的 3D 場景，可作為 Unreal 場景素材來源

## 資料來源

- https://github.com/flopperam/unreal-engine-mcp （README）
- https://api.github.com/repos/flopperam/unreal-engine-mcp （repo 中繼資料：無授權偵測、星數、推送日期）
- https://api.github.com/repos/flopperam/unreal-engine-mcp/git/trees/HEAD?recursive=1 （確認無 LICENSE 檔）
- https://raw.githubusercontent.com/flopperam/unreal-engine-mcp/HEAD/Python/unreal_mcp_server_advanced.py （清點 43 個工具、TCP port）
- https://raw.githubusercontent.com/flopperam/unreal-engine-mcp/HEAD/LOCAL_SETUP.md
- https://raw.githubusercontent.com/flopperam/unreal-engine-mcp/HEAD/Python/pyproject.toml
- https://www.threads.com/@davepoon128/post/DenVxBCkyaN （原清單來源貼文）
