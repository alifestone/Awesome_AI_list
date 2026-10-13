# 🧊 3D 建模與生成

讓 AI 做 3D 的工具：透過 MCP 操作 CAD／Blender 等專業軟體、用文字直接生成工程幾何、AI 生成 3D 模型與場景，以及從影片重建 3D 環境。

## CAD / 參數化建模

### [FreeCAD MCP](FreeCAD-MCP.md)

FreeCAD 的 MCP 伺服器，讓 Claude Desktop 等 MCP 用戶端直接操作開源參數化 CAD 軟體 FreeCAD。MIT。

可以做到：
- 用自然語言建立、編輯機械零件和治具等參數化模型，並截圖回饋給 AI 檢查。
- 讓 AI 依 2D 圖面重建 3D 模型。
- 自動跑 FEM 結構分析（建幾何 → 材料 → 網格 → 拘束 → 求解）。
- 當 LangChain、Google ADK 等 agent 框架的 CAD 工具。

### [Rhino MCP](Rhino-MCP.md)

把 Rhino 3D 接到 Claude、Cursor、Codex 等 AI 助理的第三方 MCP 整合（非 McNeel 官方）。MIT。

可以做到：
- 建築、產品設計師用對話快速建立或修改 Rhino 模型。
- 讓 AI 代為建構和調整 Grasshopper 參數化定義。
- 依視窗截圖反覆修正模型。

### [MAC – Multi-Agent CAD](MAC-–-Multi-Agent-CAD.md)

清華大學 IEI Lab 的 text-to-CAD 框架：四個 agent 分工，把自然語言需求轉成可編輯的 build123d 程式碼與 B-rep 模型，而不只是渲染圖。MIT。

可以做到：
- 從一句描述產出可 3D 列印的零件，匯出 STEP／STL。
- 把機構拆成多個零件分別生成，再組裝、驗證並匯出（可產生 URDF 給模擬器）。
- token 用量約為單一 agent 做法的 1/116。

### [USD BRep](USD-BRep.md)

NVIDIA Omniverse 開源的 NURBS BRep 實體建模函式庫（C++／Python），可原生匯入匯出 OpenUSD。Apache-2.0。

可以做到：
- 用 Python 做布林運算、掃掠、倒角、偏移、網格化等實體建模（`pip install usd-brep`）。
- 在 OpenUSD／Omniverse 管線中保存與交換精確的 CAD 實體，而不只是網格。
- 修復與驗證其他工具輸出的 USD BRep 資產。
- 用 repo 附的 `text-to-3d-asset-generation` agent skill，讓 agent 依文字描述做出 CAD/USD 資產。

## Blender × Agent

### [cc-blender-skill](cc-blender-skill.md)

Claude Code 的 Blender skill 組：把「做一把劍並用三點打光渲染」這類需求轉成 Blender Python，經 Blender MCP 執行。MIT。

可以做到：
- 用自然語言建模、上材質、打光、運鏡、渲染與做動畫。
- 依參考圖、三視圖、貼圖包做較精確的重建。
- 匯出 glTF／FBX 給遊戲引擎（含 Unreal 碰撞網格）。

### [TheLongSilence](TheLongSilence.md)

Claude Opus 5 做的瀏覽器太空探索遊戲。收錄重點是 repo 裡的 `blender-hardsurface` skill：作者把建一艘 162 公尺勘測艇學到的技巧整理成 Claude skill。MIT。

可以做到：
- 讓 Claude 透過 Blender MCP 做太空船、太空站等科幻硬表面模型與概念渲染。
- 查 Blender 4.x 遷移到 5.x 的 API 陷阱。
- 研究「AI 做出來的完整 WebGL 遊戲」的架構。

## AI 生成 3D / 世界

### [World Labs](World-Labs.md)

李飛飛等人創辦的「空間智慧」公司，產品 Marble 能從文字、圖片、影片或粗略 3D 配置生成可探索的 3D 世界。商業服務。

可以做到：
- 從概念圖或實景照片／影片，生成可以走動的 3D 場景。
- 匯出高斯點雲、網格或影片，給遊戲引擎、Blender、Maya 等使用。
- 產生機器人模擬用的環境（可匯出碰撞網格）。

### [Hyper3D（Rodin）](Hyper3D（Rodin）.md)

Deemos 的 AI 3D 模型生成平台，主力產品 Rodin 可從文字或圖片生成 3D 資產。商業服務。

可以做到：
- 替遊戲、AR／VR、電商快速產出 3D 資產。
- 從概念圖做模型草稿，再匯入 DCC 工具細修；可匯出 STL 做 3D 列印。
- 透過 API 或 agent 工具批次生成。

## 3D 重建

### [3D Gaussian Splatting for model city](3D-Gaussian-Splatting-for-model-city.md)

一條端到端管線：拿手機繞拍一段影片，自動抽幀、去模糊、用 COLMAP 求相機位姿、用 Nerfstudio 訓練 3DGS，輸出 PLY／USDZ，再生成碰撞網格放進 Isaac Sim。⚠️ 未附授權檔。

可以做到：
- 快速替機器人模擬建立寫實的實景數位分身。
- 在 Isaac Sim 裡做出「寫實外觀 + 物理碰撞」兼具的場景。
- 當學習 3DGS 完整流程的範例專案。

## 作品範例

### [Anatomy](Anatomy.md)

用 Next.js + Three.js 做的互動式 3D 人體器官教學網站（由 GPT 生成），偏參考作品而非工具。⚠️ 未附授權檔，也不適合當醫學參考。

可以做到：
- 參考 AI 產出的 Three.js 互動 3D 網站長什麼樣子。
- 參考 3D 熱點標註、測驗互動、多語系（含 RTL）的實作方式。

## 怎麼挑

- 要**精確、可製造的工程模型**：FreeCAD MCP、Rhino MCP、MAC，或在 OpenUSD 管線裡用 USD BRep。
- 要**視覺用的 3D 美術資產**：cc-blender-skill、TheLongSilence 的 Blender skill，或直接用 Hyper3D 生成。
- 要**整個可探索場景**：World Labs；要**從真實場景重建**：3DGS for model city。
