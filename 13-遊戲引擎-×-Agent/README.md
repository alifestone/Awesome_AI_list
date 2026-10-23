# 🎮 遊戲引擎 × Agent

讓 AI agent 直接操作遊戲引擎編輯器的 MCP 工具：在開著的 Unity、Godot、Unreal 或 PlayCanvas 編輯器裡，用自然語言建場景、寫腳本、調素材、跑遊戲並回頭檢查錯誤與畫面；以及讓 coding agent 寫遊戲程式時懂各引擎寫法的 skill 組。

## 桌面遊戲引擎

### [Unity MCP](Unity-MCP.md)

CoplayDev 開發、Aura 贊助的 Unity 編輯器 MCP 橋接器（非 Unity 官方），約 50 個工具分群組啟用。MIT。

可以做到：
- 用對話建立場景與 GameObject、改元件、材質、Prefab 與光照。
- 讓 AI 寫 C# 腳本、讀 Console 錯誤、跑測試、輸出 build。
- 啟用 `asset_gen` 群組後，用 AI 生成 3D 模型、圖片與音效並直接匯入（自備 API key）。
- 多個 MCP 用戶端同時操作同一個編輯器，或一個用戶端切換多個 Unity 實例。

### [Godot AI](Godot-AI.md)

連接執行中 Godot 4.7+ 編輯器的 MCP 外掛，出自 MCP for Unity 的同一批作者（非 Godot 官方），46 個工具、120 多種操作。MIT。

可以做到：
- 建場景、改節點、寫並熱重載 GDScript、接訊號。
- 設定 UI、主題、材質／shader、動畫、粒子、相機、TileMap。
- 跑遊戲、讀 Debugger 錯誤、模擬鍵盤／滑鼠／手把輸入來驗證行為。
- 撰寫並執行 Godot 專案的自動化測試。

### [Unreal Engine MCP](Unreal-Engine-MCP.md)

Flopperam（已被 Aura 收購）的 Unreal 5.5+ MCP（非 Epic 官方）；開源本機版 43 個工具，進階功能在不開源的託管版。⚠️ README 稱 MIT，但未附 LICENSE 檔。

可以做到：
- 一句話程序化生成城鎮、城堡、吊橋、迷宮等大型場景草稿。
- 管理 Actor、套用材質、設定物理。
- 建立 Blueprint、加變數與函式、連接節點並編譯。

### [Unreal Engine Skills for Claude Code](Unreal-Engine-Skills-for-Claude-Code.md)

Epic Games 官方的 Claude Code 外掛，接上 Unreal 5.8 內建的實驗性 MCP 伺服器（數百個工具、30 多個 toolset）。repo 本身只有 3 個 skill 和 1 個 hook，工具在引擎端，需在專案啟用 `ModelContextProtocol` 與 `AllToolsets` 外掛。已上架 Anthropic 官方外掛市集。MIT。⚠️ 引擎端仍是 Experimental；可在編輯器內執行任意 Python。

可以做到：
- 操作 Actor、Blueprint、材質、Niagara、Control Rig、Sequencer、UMG、Gameplay Ability System。
- 改完 C++ 後用 Live Coding 重新編譯、讀錯誤，再跑自動化測試。
- 依官方規範替團隊撰寫新的 toolset 與引擎內 Agent Skill，擴充 AI 能做的事。

## 網頁遊戲引擎

### [PlayCanvas Editor MCP](PlayCanvas-Editor-MCP.md)

PlayCanvas 官方的 Editor MCP 伺服器，130 個工具，連接瀏覽器中的 PlayCanvas Editor，重點是讓 agent 自己啟動遊戲驗證結果。MIT。

可以做到：
- 建實體、寫並掛載腳本、管理素材與場景設定。
- 啟動遊戲、截圖、讀 log、模擬輸入，確認場景真的能跑。
- 處理光照貼圖、貼圖壓縮、圖集，從 Store／Sketchfab 匯入素材。
- 用分支與 checkpoint 讓 agent 安全實驗。

## 遊戲開發 Skill 組

### [awesome-gamedev-agent-skills](awesome-gamedev-agent-skills.md)

74 個遊戲開發 Agent Skills 加一個 router，涵蓋 Godot、Unity、Unreal、Phaser、PixiJS、three.js、Bevy、pygame、LÖVE、Roblox 十個引擎；router 從專案檔判斷引擎、從需求判斷主題，只載入需要的 skill。名字有 awesome 但不是連結清單，也不操作編輯器。Claude Code、Cursor、Codex、Gemini CLI、Copilot 等都能用。Apache-2.0。

可以做到：
- 讓 agent 照專案的引擎版本寫出正確的 API，例如 Godot 4.7、Unity 6.3 LTS、Unreal 5.8。
- 套用平台跳躍、roguelike、RPG、塔防等 9 種類型模板，以及存檔、對話、遊戲 AI、程序生成等跨引擎主題。
- 用 `create-game-assets` 先定美術方向，再成批產出、檢查並匯入風格一致的資產。
- 照 Game Jam、快速原型、Steam／itch.io 上架流程走。

## 怎麼挑

- 看**你已經在用哪個引擎**：這幾個 MCP 工具各綁一個引擎，沒有互通。
- 要 agent **寫遊戲程式時懂引擎寫法**，而不是去操作編輯器：awesome-gamedev-agent-skills，可和任一個 MCP 工具一起用；它也涵蓋 Phaser、Bevy、pygame、LÖVE、Roblox 等這裡沒有 MCP 的引擎。
- 要**最成熟、社群最大**：Unity MCP（約 15k 星，版本迭代穩定）。
- 要**完全開源、驗證迴圈完整**：Godot AI 或 PlayCanvas Editor MCP；要**官方支援**：PlayCanvas Editor MCP 與 Unreal Engine Skills for Claude Code 是引擎廠商自己出的。
- 要**做網頁上直接能玩的 3D**：PlayCanvas Editor MCP。
- 用 **Unreal 5.8 以上又用 Claude Code**：優先選 Epic 官方的 Unreal Engine Skills for Claude Code，涵蓋材質、Niagara、Sequencer、GAS 等深度功能；工具本身在引擎裡，用 Cursor、Codex 等也能直接接引擎內建的 MCP 伺服器。
- 用 **Unreal 5.5～5.7**：Flopperam 的 Unreal Engine MCP，開源本機版適合做場景草稿與基礎 Blueprint；要深度功能得改用託管版或 Aura，並先確認授權與資料政策。
- 素材從哪來：可搭配 [3D 建模與生成](../02-3D-建模與生成/README.md) 的 Blender、AI 生成 3D 工具，再匯入引擎。
- 要**整套遊戲開發流程**（企劃、架構、QA 到發行），而不只是操作編輯器：見 Agent 框架類的 [Claude Code Game Studios](../06-Agent-框架與編排/Claude-Code-Game-Studios.md)，可和這裡的 MCP 搭配。
