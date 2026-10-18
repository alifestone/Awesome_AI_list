# three.js

- **分類**：設計 / 前端（網頁 3D）/ JavaScript 函式庫
- **連結**：https://github.com/mrdoob/three.js
- **官網**：https://threejs.org

## 原清單說明

（Threads @davepoon128）— JavaScript 3D 函式庫，GitHub 約 115k 顆星。

> **查證補充**：與 README 相符，repo 簡介原文為「JavaScript 3D Library.」。星數略有落差：查詢當下（2026-10-18）為約 116.6k 顆星（36.7k fork），比貼文的 115k 再多一些。授權為 MIT。Threads 貼文原文無法直接讀取（需登入），以上依委託說明整理。

## 概述

three.js 是網頁上最常用的 3D 函式庫，由 mrdoob（Ricardo Cabello）在 2010 年發起。README 寫明目標是做出「好用、輕量、跨瀏覽器、通用」的 3D 函式庫。目前的建置版本內建 WebGL 與 WebGPU 兩種 renderer，SVG 與 CSS3D renderer 則以 addon 形式提供。

它是許多 AI 生成 3D 網頁的底層，例如本清單的 [Anatomy](../02-3D-建模與生成/Anatomy.md) 就是用 three.js 做的；[HyperFrames](../03-影片製作/HyperFrames.md) 也把 three.js 列為支援的動畫 adapter。

repo 於 2010-03-23 建立，持續活躍開發（最後 push 為 2026-10-17）。最新 release 為 r186（2026-09-24），npm 套件 `three` 目前版本為 0.186.1。

## 核心功能／特色

- **場景圖架構**：Scene、Camera、Object3D 階層，Mesh = Geometry + Material。
- **兩種主 renderer**：WebGLRenderer 與 WebGPURenderer。
- **完整材質系統**：Basic／Phong／Standard／Physical 等 PBR 材質，也能寫自訂 GLSL `ShaderMaterial`。
- **光照與陰影**：多種光源、陰影貼圖、環境貼圖。
- **動畫**：關鍵影格、骨架動畫、morph target、AnimationMixer。
- **大量 addon**（`three/addons/`）：GLTF／Draco 等模型載入器、OrbitControls 等相機控制、EffectComposer 後製特效、CSS3D／SVG renderer、WebXR 等。
- **文件與範例豐富**：官方有 Docs、Manual、數百個範例、論壇與 Discord。

## 技術架構或運作原理

three.js 包裝了底層的 WebGL／WebGPU API：開發者建立場景、相機與物件，renderer 負責把場景轉成 GPU 繪圖指令，在 `<canvas>` 上逐格繪製。核心以 ES module 發佈，額外功能放在 `examples/jsm`（以 `three/addons/` 匯入），按需載入。

版本以「r + 數字」命名（如 r186），約每月一版；API 會隨版本調整，官方 wiki 有 Migration Guide。

## 安裝與使用方式

```bash
npm install three
```

```javascript
import * as THREE from 'three';

const camera = new THREE.PerspectiveCamera(70, innerWidth / innerHeight, 0.01, 10);
camera.position.z = 1;
const scene = new THREE.Scene();
const mesh = new THREE.Mesh(new THREE.BoxGeometry(0.2, 0.2, 0.2), new THREE.MeshNormalMaterial());
scene.add(mesh);

const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(innerWidth, innerHeight);
renderer.setAnimationLoop((t) => {
  mesh.rotation.x = t / 2000;
  mesh.rotation.y = t / 1000;
  renderer.render(scene, camera);
});
document.body.appendChild(renderer.domElement);
```

也可以透過 CDN（如 jsDelivr）以 import map 直接載入。完整 clone repo 約 2 GB，README 建議用 `git clone --depth=1`。

搭配 coding agent 使用時，可以加裝 [threejs-skills](threejs-skills.md)，讓 agent 寫出 API 正確的 three.js 程式碼。

## 適用情境

- 產品官網、landing page 的 3D 主視覺與互動展示。
- 3D 模型檢視器（GLTF）、產品設定器、數位分身與資料視覺化。
- 網頁遊戲、WebXR（VR／AR）體驗。
- 讓 AI agent 生成可直接在瀏覽器執行的 3D 作品，或當作影片框架的 3D 動畫來源。

## 授權與成本

- **授權**：MIT（Copyright © 2010-2026 three.js authors）。
- **成本**：完全免費、可商用。

## 限制與注意事項

- 是「渲染函式庫」而非完整遊戲引擎：沒有內建編輯器、物理引擎與完整的資源管線，需要自行搭配其他套件。
- API 每版都可能有破壞性變更，舊教學或 AI 依舊資料寫出的程式碼可能無法直接執行（例如匯入路徑、色彩空間設定），升級前要看 Migration Guide。
- WebGPU renderer 仍較新，瀏覽器支援度與功能完整度和 WebGL 版有差異。
- 效能要自己管理：draw call 數量、記憶體釋放（`dispose()`）、行動裝置 GPU 限制等。

## 相關工具

- [threejs-skills](threejs-skills.md)：教 Claude Code 正確使用 three.js 的 10 個 skill
- [GSAP Skills](GSAP-Skills.md)：網頁動畫，可與 three.js 搭配做捲動連動 3D
- [Anatomy](../02-3D-建模與生成/Anatomy.md)：用 three.js 做的互動式 3D 人體器官網站
- [HyperFrames](../03-影片製作/HyperFrames.md)：支援 three.js adapter 的 HTML 影片框架
- [Hairline](Hairline.md)、[MotionSites](MotionSites.md)

## 資料來源

- https://github.com/mrdoob/three.js （README、LICENSE，以 raw.githubusercontent.com 取得原文）
- https://api.github.com/repos/mrdoob/three.js （星數、fork 數、MIT、建立時間，2026-10-18 查詢）
- https://api.github.com/repos/mrdoob/three.js/releases/latest （r186）
- https://registry.npmjs.org/three/latest （npm 版本 0.186.1）
- https://www.threads.com/@davepoon128/post/DenVxBCkyaN （原清單來源貼文）
