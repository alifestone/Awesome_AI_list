# TheLongSilence

- **分類**：3D 建模與生成 / Blender × Agent
- **連結**：https://github.com/achimala/TheLongSilence

## 原清單說明

Claude Opus 5 做的瀏覽器太空探索遊戲；repo 裡附有 `.claude/skills/blender-hardsurface` 硬表面建模 skill（原清單收錄的應是這個）。

> **查證結果**：正確。repo 簡介原文為「A space exploration game built by Claude Opus 5」；`.claude/skills/blender-hardsurface/SKILL.md` 確實存在，內容是透過 BlenderMCP socket 在 Blender 中建模、打光與渲染硬表面太空船的 skill。

## 概述

**遊戲本體**：《THE LONG SILENCE》是一款在瀏覽器分頁中執行的程序化（procedural）太空探索遊戲，使用 WebGL2，星體、行星、環系、星雲、遺骸都由種子（seed）生成，並以手寫 GLSL 著色。唯一例外是地表：材質、石頭、樹葉由影像模型與 Blender 透過 `tools/` 內的腳本製作，以圖片和一個小型 GLB 形式隨附。

**收錄重點**：`blender-hardsurface` skill，作者將建造一艘 162 公尺勘測艇過程中學到的硬表面建模、程序化貼圖、太空打光技巧，以及 Blender 5.x API 陷阱整理成 Claude skill。

截至 2026-10-13：MIT 授權（Copyright 2026 Anshu Chimala）、約 520 顆星、主要語言 JavaScript。

## 核心功能／特色

### blender-hardsurface skill

- **連線**：BlenderMCP 外掛在 `localhost:9876` 開 JSON socket；若 MCP 工具在工作階段中途才註冊，skill 教你直接對 socket 送指令（`get_scene_info`、`get_object_info`、`execute_code`、`get_viewport_screenshot`）。`reference/` 內附 `bmcp_client.py`、`build_tender.py`、`cinematic.py` 可完整重建場景。
- **建模三原則**：
  1. 以截面 Loft 出連續外殼，不堆疊基本幾何；輪廓用階梯式而非平滑漸縮。
  2. 用 `bmesh.ops.inset_region` 把面板、溝槽「刻」進外殼，而不是黏上方塊。
  3. 細節分層（主量體、面板、約船長 1/60 的 greeble），並刻意保留乾淨板面。
- **程序化貼圖（不用影像貼圖）**：Voronoi 做逐板色調差異、Pointiness 做邊緣磨損（僅 Cycles），加上朝陽面褪色與船尾煤灰。
- **太空打光**：單一硬光 SUN（約 0.9°）＋大面積弱補光＋冷色輪廓光；攝影機放在主光側；用 Voronoi 而非雜訊閾值產生星空。
- **渲染與攝影機**：從場景包圍盒推算攝影機位置；合成器用 Glare（Fog Glow、Streaks）＋Lensdist，色彩管理用 AgX。
- **陷阱清單**：攝影機在幾何內部會讓渲染時間增加約 80 倍；背景大型自發光幾何要關閉間接可見性（作者案例從 145 秒降到 4.3 秒）；Bevel 前要先套用縮放等。
- **Blender 5.x API 變更**：`Scene.node_tree` 改為 `Scene.compositing_node_group`；合成群組必須包含 `CompositorNodeRLayers`，否則會在 0.1 秒內輸出全黑透明影格；`Action.fcurves` 移除；Glare／Lensdist 設定改到 socket 上，列舉值改用顯示名稱。
- **匯出到遊戲**：GLB、Y-up、套用修改器；依材質合併物件以減少 draw call（作者案例由 78 降到約 11）；程序化節點材質不會保留。

### 遊戲本體（README 摘要）

- 1 單位 = 1 公里，採浮動原點（floating origin）與對數深度緩衝。
- 行星預先烘焙成 cubemap（RGB 反照率＋A 高度），最近的星球以每面 1024² 重新烘焙。
- 大氣以單次散射 raymarch 計算；GPU 自動曝光；自製後製（bloom、變形光暈、god rays、AgX、FXAA）。
- 依影格時間在 0.62×–2× 間調整渲染解析度，維持 60 fps。
- 太空船外殼由 `tools/build_hull.py` 在無頭 Blender 中 loft 後匯出 GLB。
- 地表使用 13 組由影像模型生成反照率、再以 numpy 推導高度／法線／粗糙度／AO 的 PBR 材質。

## 技術架構或運作原理

- 遊戲：純前端 JavaScript + WebGL2，使用自訂 `ShaderMaterial` 與手寫 GLSL，音訊為程序化 WebAudio；`npm run dev` 開發伺服器在 `localhost:5173`（README 未明寫所用的 3D 函式庫與打包工具名稱）。
- 驗證工具（`tools/*.mjs`）以實際有頭 Chromium（GPU 光柵化）跑互動斷言、截圖、量測 fps／draw call 與色調統計。
- skill：標準 Claude Code skill 格式（YAML front matter 的 `name`／`description`），透過 BlenderMCP 的 `execute_code` 傳送 `bpy` 程式碼。

## 安裝與使用方式

遊戲：

```bash
git clone https://github.com/achimala/TheLongSilence.git
cd TheLongSilence
npm install
npm run dev        # http://localhost:5173
npm run build      # 靜態檔輸出到 dist/
```

使用 skill（依 SKILL.md 說明）：

- 把 `.claude/skills/blender-hardsurface/` 放在 Claude Code 可讀的 skill 位置（專案內或 `~/.claude/skills/`）。
- 安裝 BlenderMCP 外掛，Blender **必須以 GUI 模式開啟**，在側欄（`N`）→ BlenderMCP → 「Connect to Claude」。外掛無法在背景模式啟動伺服器。
- 重建範例場景：`cat build_tender.py cinematic.py | python3 bmcp_client.py code`（在 `reference/` 目錄下；作者稱約 2 秒）。

## 適用情境

- 想讓 Claude 透過 Blender MCP 做科幻硬表面模型（太空船、太空站）與概念渲染。
- 從 Blender 4.x 遷移到 5.x 時查閱 API 陷阱。
- 研究「AI 做出來的完整 WebGL 遊戲」的渲染架構與驗證方法。

## 授權與成本

- **授權**：MIT。
- **成本**：免費；Blender 免費；需自行負擔 Claude 使用費用。BlenderMCP 外掛的授權另依其專案而定（本次未查證）。

## 限制與注意事項

- skill 是針對「這個遊戲的美術方向」寫的，部分內容（如匯出到本遊戲的流程、1 單位 = 1 公里）不一定適用其他專案。
- 需要 GUI 模式的 Blender；無法在無頭模式透過 BlenderMCP 使用。
- 邊緣磨損（Pointiness）只在 Cycles 有效。
- 遊戲刻意拒絕手機瀏覽（README 說明手機無法負擔其功能）。
- 遊戲需要支援 WebGL2 的瀏覽器與一定的 GPU 效能；最低需求資料不足。

## 相關工具

- [BlenderMCP（ahujasid/blender-mcp）](https://github.com/ahujasid/blender-mcp)
- 同資料夾：cc-blender-skill（另一套更完整的 Blender × Agent skill 組合）、Anatomy（另一個由 AI 打造的瀏覽器 3D 作品）

## 資料來源

- https://github.com/achimala/TheLongSilence （README）
- https://api.github.com/repos/achimala/TheLongSilence （repo 中繼資料：簡介、授權、星數）
- https://raw.githubusercontent.com/achimala/TheLongSilence/HEAD/.claude/skills/blender-hardsurface/SKILL.md
- https://raw.githubusercontent.com/achimala/TheLongSilence/HEAD/LICENSE
