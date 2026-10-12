# Hyper3D（Rodin）

- **分類**：3D 建模與生成 / AI 生成 3D / 世界
- **連結**：https://hyper3d.ai/

## 原清單說明

AI 生成 3D 模型。（已移除原連結的廣告追蹤參數）

## 概述

Hyper3D 是 Deemos（官網頁尾版權標示為 Deemos Corporation）推出的 AI 3D 模型生成平台，主力產品 **Rodin** 可從文字提示或圖片生成 3D 資產；同公司另有 AI 頭像生成產品 ChatAvatar。官網介面上可見「Gen-2.5」標示。

依 Deemos 的新聞稿（刊於 befores & afters，標註為 Deemos 贊助內容），Rodin Gen-2 於 2025-10-02 發表，建立在其 BANG 架構上，訓練規模 100 億參數。以上為廠商自述，未經獨立驗證。

## 核心功能／特色

官網（hyper3d.ai）列出的功能：

- **文字生成 3D、圖片生成 3D**：通常一張圖即可，多視角圖片為選用。
- **品質**：標榜乾淨拓樸（clean topology）、PBR 材質、可直接使用的 UV；可選低多邊形（low-poly）最佳化。
- **3D ControlNet**：以包圍盒（bounding box）、體素（voxel）、點雲（point cloud）控制生成形狀。
- **局部編輯**：只重新生成選取的區域。
- **生成選項**：Remix Gen、Turbo Gen，以及「Thinking Effort」等級，從 Extreme-Low（約 4 秒）到 Extreme-High（約 80 秒）。
- **匯出格式**：STL、FBX、OBJ、GLB、GLTF、USDZ。
- **外掛**：Blender、Unity、Unreal、Godot、Maya、3DS Max、Cinema 4D、NVIDIA Omniverse、ComfyUI。
- **API 平台**：可自動化文字／圖片生成 3D 並取回各種格式。

Gen-2 新聞稿另提到（廠商自述）：遞迴式部件生成（把物件拆成部件再細分）、宣稱幾何網格品質較前代提升 4 倍、烘焙法線與高解析貼圖（Beta）、「Generative Exploded Dynamics」爆炸圖展示功能。

## 技術架構或運作原理

- 官方未公開完整模型細節。依 Deemos 新聞稿：Rodin Gen-2 基於 **BANG** 架構（論文發表於 ACM Transactions on Graphics，並列 SIGGRAPH 2025 Technical Papers Fast Forward Top 10）。
- 同一新聞稿列出 Deemos 的研究成果：**CLAY** 獲 SIGGRAPH 2024 Best Paper Honorable Mention、**CAST** 獲 SIGGRAPH 2025 Best Paper；但未說明 CAST 是否用於 Rodin Gen-2。上述獎項均出自廠商新聞稿。
- 各代模型（Gen-1、Gen-2、Gen-2.5）之間的具體架構差異：資料不足。

## 安裝與使用方式

- **網頁版**：直接到 https://hyper3d.ai/ 註冊使用，上傳圖片或輸入文字即可生成，完成後下載上述格式。
- **DCC／遊戲引擎**：透過官方列出的 Blender、Unity、Unreal 等外掛使用。
- **API**：Business 方案含完整 API 存取；具體端點與呼叫方式本次未查閱官方 API 文件，資料不足。
- 另外，Blender MCP 生態（如 ahujasid/blender-mcp）提供 `generate_hyper3d_model_via_text` 工具（見同資料夾 cc-blender-skill 條目引用）。

## 適用情境

- 遊戲、AR／VR、電商產品等需要快速產出 3D 資產的場合。
- 從概念圖快速建立模型草稿，再匯入 DCC 工具細修。
- 3D 列印（可匯出 STL）。
- 透過 API 或 agent 工具做批次、自動化生成。

## 授權與成本

hyper3d.ai/pricing 於 2026-10-13 查詢時的方案：

| 方案 | 價格 | 預估產量 | 使用權 |
| --- | --- | --- | --- |
| Free | $0，依結果付費，單買點數 $1.5／credit | — | 不含「Unlimited export and any use」 |
| Creator | 月繳 $30／月；年繳 $24／月（$288） | 約 60 個模型 | Unlimited export and any use |
| Business | 月繳 $120／月；年繳 $96／月（$1,152） | 約 416 個模型 | Unlimited export and any use；含 Full API access；ChatAvatar 含商用授權 |
| Enterprise | 洽談 | 客製 | 客製部署與支援、年約、量價折扣 |
| Education | 未列價格 | Creator 等級權益 | 需驗證學生／教師身分 |

- 官網另提供 7 天免費試用，以及「不需訂閱即可用免費點數測試」。
- API 速率：前三級 120 RPM、更高級 240 RPM。
- 官網 FAQ：商業用途「依方案與授權而定」，付費方案提供較廣的匯出與使用權；用於受規範或高風險場合前應查看最新條款。完整服務條款本次未逐條查閱。

## 限制與注意事項

- 免費方案不含「無限制匯出與任意使用」，商用前請確認方案與條款。
- 模型能力、參數量與獲獎紀錄多出自廠商新聞稿，未經獨立驗證。
- 價格與方案會變動，以官網為準。
- 生成結果的拓樸、UV 是否符合特定生產需求（如動畫綁定、遊戲面數預算），需實際測試。

## 相關工具

- 同資料夾：World Labs（Marble，生成整個 3D 世界而非單一物件）、cc-blender-skill（可透過 blender-mcp 呼叫 Hyper3D）
- Deemos 的 ChatAvatar（AI 頭像生成）

## 資料來源

- https://hyper3d.ai/ （官網首頁）
- https://hyper3d.ai/pricing （方案與價格）
- https://beforesandafters.com/2025/10/02/deemos-launches-rodin-gen-2-a-groundbreaking-generative-ai-for-intuitive-3d-creation/ （Deemos 贊助的 Rodin Gen-2 發表新聞稿）
