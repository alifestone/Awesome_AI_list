# 🎮 遊戲引擎 × Agent

讓 AI agent 直接操作遊戲引擎編輯器的 MCP 工具：在開著的 Unity、Godot、Unreal 或 PlayCanvas 編輯器裡，用自然語言建場景、寫腳本、調素材、跑遊戲並回頭檢查錯誤與畫面。

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

## 網頁遊戲引擎

### [PlayCanvas Editor MCP](PlayCanvas-Editor-MCP.md)

PlayCanvas 官方的 Editor MCP 伺服器，130 個工具，連接瀏覽器中的 PlayCanvas Editor，重點是讓 agent 自己啟動遊戲驗證結果。MIT。

可以做到：
- 建實體、寫並掛載腳本、管理素材與場景設定。
- 啟動遊戲、截圖、讀 log、模擬輸入，確認場景真的能跑。
- 處理光照貼圖、貼圖壓縮、圖集，從 Store／Sketchfab 匯入素材。
- 用分支與 checkpoint 讓 agent 安全實驗。

## 怎麼挑

- 看**你已經在用哪個引擎**：這四個工具各綁一個引擎，沒有互通。
- 要**最成熟、社群最大**：Unity MCP（約 15k 星，版本迭代穩定）。
- 要**完全開源、驗證迴圈完整**：Godot AI 或 PlayCanvas Editor MCP；要**官方支援**：只有 PlayCanvas Editor MCP 是引擎廠商自己出的。
- 要**做網頁上直接能玩的 3D**：PlayCanvas Editor MCP。
- 用 **Unreal**：開源本機版適合做場景草稿與基礎 Blueprint；要材質、Niagara、動畫等深度功能得改用託管版或 Aura，並先確認授權與資料政策。
- 素材從哪來：可搭配 [3D 建模與生成](../02-3D-建模與生成/README.md) 的 Blender、AI 生成 3D 工具，再匯入引擎。
- 要**整套遊戲開發流程**（企劃、架構、QA 到發行），而不只是操作編輯器：見 Agent 框架類的 [Claude Code Game Studios](../06-Agent-框架與編排/Claude-Code-Game-Studios.md)，可和這裡的 MCP 搭配。
