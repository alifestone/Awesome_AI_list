# threejs-skills

- **分類**：設計 / 前端（網頁 3D）/ Agent Skill
- **連結**：https://github.com/CloudAI-X/threejs-skills

## 原清單說明

（Threads @davepoon128）— 給 Claude Code 的 10 個 three.js skill，從 shader 到後製特效都有。

> **查證補充**：數量正確，repo 的 `skills/` 內確實有 10 個 skill 資料夾，各含一個 `SKILL.md`，涵蓋 shader 與 post-processing。查詢當下（2026-10-18）約 3.6k 顆星、406 fork。需注意兩點：⚠️ README 寫「MIT License」，但 repo **沒有 LICENSE 檔**，GitHub 也未偵測到授權；README 的安裝指令指向另一個 repo `pinkforest/threejs-playground`，該 repo 目前無法存取（404）。Threads 貼文原文無法直接讀取（需登入），以上依委託說明整理。

## 概述

一組 three.js 的 Agent Skills，目的是補足 Claude Code 對 three.js API 細節、最佳做法與常見寫法的知識，讓 agent 寫出建構子簽名正確、匯入路徑正確、可以直接執行的 3D 程式碼。

README 自述內容已對照官方文件（r160 以後）審核過類別名稱、方法簽名與 `three/addons/` 匯入路徑。

repo 於 2026-01-19 建立，同日完成主要 commit，最後 push 為 2026-07-09，之後未見更新。

## 核心功能／特色

| Skill | 內容 |
|---|---|
| `threejs-fundamentals` | 場景設定、相機、renderer、Object3D 階層、座標系統 |
| `threejs-geometry` | 內建形狀、BufferGeometry、自訂幾何、instancing |
| `threejs-materials` | PBR 材質、Basic／Phong／Standard 材質、shader 材質 |
| `threejs-lighting` | 光源類型、陰影、環境光照、light helper |
| `threejs-textures` | 貼圖類型、UV mapping、環境貼圖、render target |
| `threejs-animation` | 關鍵影格、骨架動畫、morph target、動畫混合 |
| `threejs-loaders` | GLTF／GLB 載入、貼圖載入、非同步寫法、快取 |
| `threejs-shaders` | GLSL 基礎、ShaderMaterial、uniform、自訂特效 |
| `threejs-postprocessing` | EffectComposer、bloom、景深、畫面特效、自訂 pass |
| `threejs-interaction` | Raycasting、相機控制、滑鼠／觸控輸入、物件選取 |

每個 `SKILL.md` 約 11–16 KB，格式統一：Quick Start（最小範例）→ Core Concepts → Common Patterns → Performance Tips → See Also。

## 技術架構或運作原理

採用 Agent Skills 格式：每個 skill 是一個資料夾，`SKILL.md` 開頭的 frontmatter 有 `name` 與 `description`（寫明何時啟用）。Claude Code 依請求內容自動載入相符的 skill，例如要求「載入 GLTF 模型並播放動畫」會載入 `threejs-loaders` 與 `threejs-animation`。

純文件，不含可執行程式碼，也沒有 plugin 或 marketplace 設定。

## 安裝與使用方式

README 的安裝指令指向 `pinkforest/threejs-playground`，該 repo 目前無法存取。實際可行的做法是直接從本 repo 複製：

```bash
git clone https://github.com/CloudAI-X/threejs-skills.git
# 全域安裝
cp -r threejs-skills/skills/* ~/.claude/skills/
# 或只裝在專案內
mkdir -p .claude/skills && cp -r threejs-skills/skills/* .claude/skills/
```

注意 README 說 skill 放在 `.claude/skills`，但 repo 實際路徑是 `skills/`，複製時要自己對應。裝好後直接下指令即可，例如：

> 「做一個有旋轉立方體的 Three.js 場景」、「做一個有 fresnel 效果的自訂 shader 材質」

## 適用情境

- 讓 Claude Code 寫 three.js 時少犯 API 錯誤（類別名稱、匯入路徑、色彩空間設定）。
- 快速產出 3D 主視覺、GLTF 模型檢視器、互動式 3D 網頁。
- 自訂 shader、bloom 等後製特效，或滑鼠點選、相機控制等互動。

## 授權與成本

- **授權**：⚠️ README 宣稱 MIT，但 repo 未附 LICENSE 檔，GitHub 未偵測到授權。只有 README 的一句話，法律效力不明確；要納入商業專案或重新散布，建議先向作者確認。
- **成本**：免費。

## 限制與注意事項

- README 的安裝指令指向不存在的 repo，`.claude/skills` 路徑也和實際的 `skills/` 不符，文件與 repo 內容不一致。
- 內容以 WebGL 為主，依 r160 左右的 API 撰寫；目前 three.js 已到 r186，WebGPU renderer、TSL（Three Shading Language）等新功能涵蓋程度「資料不足」，且部分匯入寫法混用 `three/addons/` 與 `three/examples/jsm/`。
- 2026-07 之後未再更新，可能跟不上 three.js 每月的版本變動。
- 非 three.js 官方出品，正確性由社群自行維護。

## 相關工具

- [three.js](three.js.md)：這組 skill 所教的 3D 函式庫
- [GSAP Skills](GSAP-Skills.md)：同樣是教 agent 寫網頁動畫的 skill 組（官方出品）
- [Hairline](Hairline.md)：附 skill 的互動插圖元件
- [Anatomy](../02-3D-建模與生成/Anatomy.md)：AI 生成的 three.js 3D 網站範例
- [cc-blender-skill](../02-3D-建模與生成/cc-blender-skill.md)：讓 Claude Code 操作 Blender 的 skill

## 資料來源

- https://github.com/CloudAI-X/threejs-skills （README 與各 `SKILL.md`，以 raw.githubusercontent.com 取得原文）
- https://api.github.com/repos/CloudAI-X/threejs-skills （星數、fork 數、無授權、建立時間，2026-10-18 查詢）
- https://api.github.com/repos/CloudAI-X/threejs-skills/git/trees/HEAD?recursive=1 （確認 10 個 skill、無 LICENSE 檔）
- https://api.github.com/repos/pinkforest/threejs-playground （回傳 404）
- https://www.threads.com/@davepoon128/post/DenVxBCkyaN （原清單來源貼文）
