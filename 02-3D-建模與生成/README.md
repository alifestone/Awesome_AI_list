# 🧊 3D 建模與生成

讓 AI 做 3D 的工具：透過 MCP 操作 CAD／Blender／Omniverse 等專業軟體、用文字直接生成工程幾何、AI 從圖片或文字生成 3D 資產與可走動的世界，以及從影片重建 3D 環境、編輯高斯點雲。

> 開放權重的 3D 生成模型（TRELLIS.2、Hunyuan3D 2.1、Stable Fast 3D、HY-World 2.0）依用途收在這裡，不放 [🧩 模型](../10-模型/)。

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

### [text-to-cad](text-to-cad.md)

給 Claude Code、Codex、Cursor、Gemini、Grok 等 agent 的 CAD 外掛與 12 個 skill：在本機用 build123d 寫程式產生模型，輸出 STEP／STL／3MF／GLB，並在對話或瀏覽器裡的 CAD Viewer 檢視。MIT；⚠️ 預設送出匿名用量統計（可關閉）。

可以做到：
- 用文字或參考圖建立、修改零件，從 step.parts 抓現成螺絲、軸承、馬達的 STEP 檔來組裝。
- 做鈑金／CNC／射出成型的 DFM 檢查與 3D 列印可列印性檢查，產出標註尺寸的工程圖 PDF 與 DXF。
- 寫 URDF／SRDF／SDF 給機器人模擬，或用 OrcaSlicer 切片、直接送到 Bambu Lab 印表機。

### [USD BRep](USD-BRep.md)

NVIDIA Omniverse 開源的 NURBS BRep 實體建模函式庫（C++／Python），可原生匯入匯出 OpenUSD。Apache-2.0。

可以做到：
- 用 Python 做布林運算、掃掠、倒角、偏移、網格化等實體建模（`pip install usd-brep`）。
- 在 OpenUSD／Omniverse 管線中保存與交換精確的 CAD 實體，而不只是網格。
- 修復與驗證其他工具輸出的 USD BRep 資產。
- 用 repo 附的 `text-to-3d-asset-generation` agent skill，讓 agent 依文字描述做出 CAD/USD 資產。

## Blender × Agent

### [MCP for Blender](MCP-for-Blender.md)

最廣為使用的社群 Blender MCP（原名 blender-mcp）：讓 Claude、Codex、Cursor 等 AI 在開著的 Blender 裡寫 Python、建模、上材質、匯入素材並截圖自我檢查。MIT；AI 生成模型可自備金鑰或訂閱 Premium。

可以做到：
- 用對話搭建場景、擺道具、打光、設定攝影機，AI 從多角度截圖檢查成果。
- 搜尋並匯入 Poly Haven、Sketchfab、Poly Pizza 素材，或用 Hunyuan3D／Tripo／Rodin 生成模型。
- 當 cc-blender-skill 等 Blender skill 包的底層 MCP 後端。

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

## OpenUSD / Omniverse × Agent

### [Kit USD Agents](Kit-USD-Agents.md)

NVIDIA Omniverse 官方的 USD agent 基礎 repo：Chat USD 讓你在 Omniverse Kit 裡用白話編輯 USD 場景，另附 4 個 MCP 伺服器，給 AI 程式助理查 USD／Kit／OmniUI／Isaac Sim 的 API 與範例。Apache-2.0（需 NVIDIA API Key）。

可以做到：
- 在 Kit 裡用對話產生並執行 USD 程式碼、搜尋素材、分析與修改場景；Stage Builder 可分步搭建整個場景。
- 讓 Claude Code、Cursor 寫 Kit 擴充套件或 Isaac Sim 腳本時查到正確 API，減少幻覺。
- 當範本開發自家的 Omniverse／USD agent。

## AI 生成 3D 資產

### [Hyper3D（Rodin）](Hyper3D（Rodin）.md)

Deemos 的 AI 3D 模型生成平台，主力產品 Rodin 可從文字或圖片生成 3D 資產。商業服務。

可以做到：
- 替遊戲、AR／VR、電商快速產出 3D 資產。
- 從概念圖做模型草稿，再匯入 DCC 工具細修；可匯出 STL 做 3D 列印。
- 透過 API 或 agent 工具批次生成。

### [TRELLIS.2](TRELLIS.2.md)

Microsoft 的 4B 參數圖片生成 3D 模型，以 O-Voxel 稀疏體素產出含完整 PBR 材質的 GLB 資產，H100 上 512³ 約 3 秒。程式碼與權重為 MIT 授權（⚠️ 相依的 nvdiffrast／nvdiffrec 限非商業使用）。

可以做到：
- 單張圖片生成帶 Base Color、Roughness、Metallic、Opacity 的 3D 資產，匯出 GLB。
- 處理開放曲面、非流形、內部封閉結構等複雜拓撲。
- 為既有 3D 形狀生成 PBR 貼圖。
- 用完整訓練程式碼在自有資料集上微調。

### [Hunyuan3D 2.1](Hunyuan3D-2.1.md)

騰訊混元的圖片生成 3D 系統，Shape（3.3B）生成幾何、Paint（2B）生成 PBR 貼圖，並開源權重與訓練程式碼。⚠️ 採騰訊混元 3D 2.1 社群授權：不適用歐盟、英國、南韓，月活躍使用者超過 100 萬須另行申請。

可以做到：
- 單張圖片生成幾何，再自動上 PBR 材質貼圖。
- 為既有白模生成 PBR 貼圖。
- Gradio 介面（含低顯存模式）、FastAPI 伺服器、ComfyUI 與 Unity 社群整合。
- 用官方訓練程式碼微調。

### [Stable Fast 3D](Stable-Fast-3D.md)

Stability AI 以 TripoSR 為基礎的單圖快速 3D 重建模型，約 0.5 秒產出已展 UV、去光照、含材質參數的貼圖網格，約 6GB 顯存即可執行。⚠️ Stability AI Community License：年營收超過 100 萬美元須購買企業授權。

可以做到：
- 單張照片快速生成已展 UV 的貼圖 GLB 網格。
- 預測粗糙度、金屬度與法線貼圖，並去除照片光照。
- 三角形或四邊形重新網格化，可指定目標頂點數。
- ComfyUI 節點；可在 CUDA、Mac MPS（實驗性）、CPU 上執行。

### [Meshy MCP Server](Meshy-MCP-Server.md)

Meshy 官方 MCP 伺服器，提供 28 個工具，讓 Claude Code、Cursor 等 agent 直接呼叫 Meshy 雲端 3D 生成。伺服器為 MIT 授權，但需要 Pro 以上方案的 API 金鑰並消耗付費點數。

可以做到：
- 文字／圖片／多圖生成 3D，Smart Topology 生成指定面數的乾淨網格。
- 重新網格化、重新貼圖（最高 8K）、UV 展開、格式轉換。
- 人形角色自動綁骨、套動畫、文字生成動作。
- 3D 列印：可列印性檢查與修復、多色 3MF、自動拆件、送切片軟體。

## AI 生成 3D 世界

### [World Labs](World-Labs.md)

李飛飛等人創辦的「空間智慧」公司，產品 Marble 能從文字、圖片、影片或粗略 3D 配置生成可探索的 3D 世界。商業服務。

可以做到：
- 從概念圖或實景照片／影片，生成可以走動的 3D 場景。
- 匯出高斯點雲、網格或影片，給遊戲引擎、Blender、Maya 等使用。
- 產生機器人模擬用的環境（可匯出碰撞網格）。

### [HY-World 2.0](HY-World-2.0.md)

騰訊混元的 3D 世界模型：從文字或一張圖生成可走動、可匯入遊戲引擎的 3D 世界（3DGS／網格），也能從照片或影片重建 3D。⚠️ 騰訊社群授權，不適用歐盟、英國、南韓。

可以做到：
- 從一句描述或概念圖生成可自由探索的 3D 場景，匯入 Blender／Unity／UE／Isaac Sim。
- 用 WorldMirror 2.0 從多張照片或影片一次推論出點雲、深度、相機與 3DGS。
- 線上產品可用第一人稱或第三人稱角色在生成的世界裡走動（含碰撞）。

## 3D 重建與高斯點雲

### [3D Gaussian Splatting for model city](3D-Gaussian-Splatting-for-model-city.md)

一條端到端管線：拿手機繞拍一段影片，自動抽幀、去模糊、用 COLMAP 求相機位姿、用 Nerfstudio 訓練 3DGS，輸出 PLY／USDZ，再生成碰撞網格放進 Isaac Sim。⚠️ 未附授權檔。

可以做到：
- 快速替機器人模擬建立寫實的實景數位分身。
- 在 Isaac Sim 裡做出「寫實外觀 + 物理碰撞」兼具的場景。
- 當學習 3DGS 完整流程的範例專案。

### [SuperSplat](SuperSplat.md)

PlayCanvas 的網頁版 3D 高斯點雲編輯器：在瀏覽器裡檢視、清理、壓縮、做攝影機動畫，再一鍵發布到 superspl.at。本身不做 AI 生成，負責點雲產出後的處理。MIT。

可以做到：
- 清除 3DGS 的漂浮點、裁切範圍、對齊合併多個掃描。
- 在 PLY／SOG／SPZ／splat 等格式間轉換與壓縮，或匯出單一 HTML 檢視器自架。
- 發布成可分享、可嵌入的 3D 場景頁，加註解、視角與攝影機飛越動畫。

## 怎麼挑

- 要**精確、可製造的工程模型**：FreeCAD MCP、Rhino MCP、MAC，或在 OpenUSD 管線裡用 USD BRep；想讓自己的 agent 一路做到製造檢查、工程圖與送印，用 text-to-cad。
- 要**讓 AI 操作 Blender**：MCP for Blender 是底層連線，再搭 cc-blender-skill 或 TheLongSilence 的 skill 提升品質。
- 要**在 Omniverse／Isaac Sim 裡用 agent**：Kit USD Agents。
- 要**從圖片生成單一 3D 資產**：想本機跑、可商用選 TRELLIS.2（注意相依套件授權）或 Stable Fast 3D（最快、顯存需求低）；要 PBR 品質選 Hunyuan3D 2.1（注意地區限制）；不想架 GPU、要 agent 一路做到綁骨動畫，用 Meshy MCP Server 或 Hyper3D。
- 要**整個可探索場景**：World Labs（商業服務）或 HY-World 2.0（開源，需多張 GPU）。
- 要**從真實場景重建**：3DGS for model city；重建後要清理、壓縮、發布點雲：SuperSplat。
- 要**網頁上的互動 3D**：見 [🎨 設計 / 前端](../04-設計---前端/) 的網頁 3D（three.js、Anatomy）。
- 要**做遊戲**：見 [🎮 遊戲引擎 × Agent](../13-遊戲引擎-×-Agent/)。
