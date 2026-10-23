# Unreal Engine Skills for Claude Code

- **分類**：遊戲引擎 × Agent / 桌面遊戲引擎
- **連結**：https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
- **Claude Code 外掛市集**：https://claude.com/plugins （`claude-plugins-official` 內的 `unreal-engine-skills-for-claude-code`）

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：**Epic Games 官方**出品（GitHub 組織 EpicGames，外掛作者為 Epic 的 Thomas Mansencal），也上架在 Anthropic 官方的 Claude Code 外掛市集。這個 repo 本身**不含 MCP 伺服器**：伺服器與數百個工具來自 Unreal 5.8 內建的實驗性 `ModelContextProtocol` 與 `AllToolsets` 外掛，這個 repo 只提供 3 個 skill 和 1 個 SessionStart hook，教 Claude Code 怎麼用好那個伺服器。README 寫的「數百個工具、30 多個 toolset」是指引擎端，不是這個 repo。

## 概述

Unreal 5.8 在編輯器裡內建了實驗性的 MCP 伺服器，透過 `ToolsetRegistry` 開放 Actor、Blueprint、材質、Niagara、Control Rig、Sequencer、State Tree、UMG、Gameplay Ability System、自動化測試、Live Coding 等功能。這個 Claude Code 外掛把 Claude 接上這個伺服器，並附上操作守則：先探索工具再呼叫、大量修改前先存檔、等編譯完成再動作、會改到同一個資產的呼叫要依序執行。

截至 2026-10-23：MIT 授權、約 1.6k 顆星，repo 建立於 2026-06-08，外掛版本 3.1.1，沒有 GitHub Release，最近一次推送為 2026-09-17。

## 核心功能／特色

- **`unreal-mcp` skill**：在 Unreal 專案中要建立、修改、查詢或執行東西時觸發。即使使用者沒說「Unreal」，看到 `BP_`、`WBP_`、`M_`、`NS_` 等資產前綴、UE C++ 型別或 `.uproject` 也會觸發；碰到 Unity、Godot 則跳過。內容包含工具探索流程、安全守則、初次設定（`references/setup.md`）與 proxy 恢復（`references/operations.md`）。
- **`create-toolset` skill**：教 agent 用 C++ 或 Python 撰寫新的 toolset（可被 AI 呼叫的靜態函式），規範 API 設計原則（簡潔、CRUD 對稱、可組合、不重複）與成功／錯誤路徑的測試寫法，讓團隊自己擴充 Claude 能做的事。
- **`unreal-skill` skill**：撰寫 Unreal 引擎內的 Agent Skill（用 Python 類別或 UAsset 註冊到 MCP 伺服器的指令包），和 Claude Code 自己的 `.claude/skills/` 是兩回事。
- **SessionStart hook**：往上層目錄尋找 `.uproject` 或 `GenerateProjectFiles.*`，找到就告訴 Claude 這是 Unreal 專案（或引擎原始碼樹）、優先採用 UE 慣例（`UObject`、Slate、UHT），並提示是否還沒產生 `.mcp.json`。
- **工具搜尋（預設開啟）**：引擎端只對外提供 `list_toolsets`、`describe_toolset`、`call_tool` 三個工具，Claude 需要時才查詢並呼叫，避免數百個工具塞滿 context；可用 `bEnableToolSearch` 關閉。
- **可選 proxy**：引擎內附的 `unreal_mcp_proxy` 在編輯器關閉或重啟時維持 MCP 連線，並快取工具清單。

## 技術架構或運作原理

```text
Claude Code
  ├─ 外掛：unreal-mcp / create-toolset / unreal-skill + SessionStart hook
  └─ .mcp.json → HTTP http://127.0.0.1:8000/mcp（可經 unreal_mcp_proxy）
        → Unreal 編輯器內的 ModelContextProtocol 伺服器
        → ToolsetRegistry（AllToolsets 或個別 toolset 外掛）
```

外掛不附固定的 `.mcp.json`，要在編輯器 console 執行 `ModelContextProtocol.GenerateClientConfig ClaudeCode` 產生（也支援 `Cursor`、`VSCode`、`Gemini`、`Codex` 或 `All`）。

## 安裝與使用方式

需求：Unreal Engine 5.8（內建實驗性 MCP 外掛）、Claude Code；hook 需要 `bash`（Windows 要裝 Git Bash 或用 WSL，沒有的話只是少了 hook，工具照常可用）。

1. 在 `.uproject` 的 `Plugins` 啟用 `ModelContextProtocol` 與 `AllToolsets`（只開前者伺服器會啟動但沒有任何工具；也可以只開需要的個別 toolset 外掛）。
2. 在編輯器 console 執行 `ModelContextProtocol.StartServer`，或在 `Saved/Config/<Platform>Editor/EditorPerProjectUserSettings.ini` 設 `bAutoStartServer=True` 讓它自動啟動。
3. 執行 `ModelContextProtocol.GenerateClientConfig ClaudeCode` 產生 `.mcp.json`。
4. 在 Claude Code 安裝外掛：

```text
/plugin install unreal-engine-skills-for-claude-code@claude-plugins-official
```

團隊可把 `"enabledPlugins": {"unreal-engine-skills-for-claude-code@claude-plugins-official": true}` 寫進專案的 `.claude/settings.json`。用 `/mcp` 確認 `unreal-mcp` 已連線，再試「列出目前關卡的所有 Actor」。

## 適用情境

- 在 Claude Code 裡直接操作 Unreal 編輯器：擺放與調整 Actor、建立並編譯 Blueprint、做材質、Niagara 特效、Sequencer 過場、UMG 介面。
- 改完 C++ 後讓 Claude 用 Live Coding 重新編譯並讀取 MSVC 錯誤，再跑自動化測試。
- 技術美術或工具程式設計師替團隊撰寫自訂 toolset 與引擎內 Agent Skill，擴充 AI 能做的事。

## 授權與成本

- **授權**：本外掛為 MIT。Unreal Engine 本身依 Epic 的 EULA 授權（含權利金條款），請另行確認。
- **成本**：外掛免費；需 Claude Code 方案或 API 費用。

## 限制與注意事項

- 引擎端 MCP 外掛在 5.8 仍標為 **Experimental**；第三方實測指出部分系統可以存取、部分還不行，整體流程仍屬早期。5.8 之前的版本沒有內建這個伺服器。
- **安全性**（README 明列）：等同讓 AI 在編輯器裡執行任意程式碼。`ProgrammaticToolset.execute_tool_script` 可在編輯器行程中執行任意 Python；伺服器只聽 localhost 並驗證 origin，但同一使用者的任何程序都能連上，不要在共用或不信任的機器上開啟，也不要對外開放 port。
- 官方建議不要搭配 `--dangerously-skip-permissions` 使用；長時間操作前先存檔並 commit，MCP 修改不一定能復原，一次呼叫就可能移動或刪除受版本控制的資產。
- 多個 agent 可以同時連同一個編輯器，但互相衝突的修改會出問題。
- 外掛只針對 Claude Code；引擎端的 MCP 伺服器本身則可接 Cursor、VS Code、Gemini、Codex。

## 相關工具

- 同資料夾：[Unreal Engine MCP](Unreal-Engine-MCP.md)（Flopperam 的第三方 Unreal MCP，支援 5.5+，以程序化建造場景為特色）、[Unity MCP](Unity-MCP.md)、[Godot AI](Godot-AI.md)、[PlayCanvas Editor MCP](PlayCanvas-Editor-MCP.md)
- [awesome-gamedev-agent-skills](awesome-gamedev-agent-skills.md)：含 6 個以 Unreal 5.8 為準的寫法 skill（Blueprint、C++、Enhanced Input、Behavior Tree、Niagara、打包），可和本外掛一起用
- [Claude Code Game Studios](../06-Agent-框架與編排/Claude-Code-Game-Studios.md)：完整遊戲開發流程模板，支援 Unreal

## 資料來源

- https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin （README、`.claude-plugin/plugin.json`、hooks、三個 SKILL.md、`references/setup.md`）
- https://api.github.com/repos/EpicGames/unreal-engine-skills-for-claude-code-plugin （repo 中繼資料：授權、星數、建立與推送日期）
- https://api.github.com/repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/commits （版本與提交紀錄）
- https://dev.epicgames.com/documentation/unreal-engine/API/Plugins/ModelContextProtocolEngine （引擎端 ModelContextProtocolEngine 模組）
- https://www.pugetsystems.com/blog/2026/07/09/unreal-engine-mcp-hands-on-testing-ai-inside-the-editor/ （5.8 實驗性 MCP 實測）
- https://forums.unrealengine.com/t/community-tutorial-connection-tutorial-claude-desktop-unreal-engine-5-8-via-mcp/2831194 （UE 5.8 內建 MCP 外掛的社群教學）
