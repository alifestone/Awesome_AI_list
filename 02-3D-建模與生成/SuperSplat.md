# SuperSplat

- **分類**：3D 建模與生成 / 3D 重建與高斯點雲
- **連結**：https://github.com/playcanvas/supersplat （線上編輯器：https://superspl.at/editor ；使用手冊：https://developer.playcanvas.com/user-manual/supersplat/ ）

## 原清單說明

在瀏覽器中檢視、編輯、最佳化並發布 3D 高斯點雲（3D Gaussian Splats）。

> **查證補充**：正確。README 原文即為「免費開源的 3D Gaussian Splat 檢查、編輯、最佳化與發布工具，在瀏覽器中執行，不需下載安裝」。補充兩點：(1) SuperSplat 本身**不是 AI 生成或訓練工具**，不會從照片產生點雲，而是處理 3DGS 訓練管線、掃描 App 或世界模型**產出之後**的清理與發布；(2) 開源的是編輯器，發布目的地 superspl.at 是 PlayCanvas 營運的託管平台（需 PlayCanvas 帳號）。

## 概述

SuperSplat 由 WebGL／WebGPU 遊戲引擎 PlayCanvas 團隊開發，是目前最常用的網頁版 3DGS 編輯器之一。完整平台包括：Editor（清理、裁切、調色、做攝影機動畫）、Direct Upload（直接上傳已處理好的檔案）、Manage（管理已發布的點雲）、Studio（設定發布後的觀看體驗）、Convert（網頁版格式轉換），以及可自架的 Viewer。

截至 2026-10-18：MIT 授權、約 10.4k 顆星、主要語言 TypeScript，最新版 v3.5.2（2026-10-05）。

## 核心功能／特色

- **多種選取工具**：矩形、筆刷、多邊形、套索、吸管（依顏色）、填色（flood，適合清掉孤立的漂浮點）、3D 球形筆刷、球體、方塊選取；可切換「只選可見表面」與「依中心點／依投影橢圓範圍」選取。
- **清理與裁切**：刪除漂浮點（floaters）、反選後裁切、鎖定已完成區域避免誤刪；刪除為非破壞性，可復原。可依不透明度、尺度等屬性範圍選取（Splat Data 面板）。
- **變換、量測與對齊**：移動、旋轉、縮放選取部分或整個點雲，校正比例尺、對齊並合併多個掃描。
- **複製與分離**：把選取的高斯點複製或分離成新的點雲，各自設定變換與顯示。
- **時間軸動畫**：設定攝影機關鍵影格、平滑度、循環；可匯入 COLMAP `images.txt` 或 INRIA 相機姿態 JSON 直接產生關鍵影格；支援 PLY 序列播放（每個 PLY 為一格的動態點雲）。
- **格式支援**：

| 格式 | 匯入 | 匯出 | 說明 |
| --- | --- | --- | --- |
| `.ply` | ✅ | ✅ | 標準交換格式，檔案大 |
| `.compressed.ply` | ✅ | ✅ | 量化壓縮 PLY |
| `.sog` | ✅ | ✅ | 超壓縮格式（zip 內含 `meta.json` 與 `.webp`），官方建議用於執行期 |
| `.spz` | ✅ | ✅ | Niantic 壓縮格式，預設匯出 SPZ v4 |
| `.splat` | ✅ | ✅ | 舊版 antimatter15 格式 |
| `.ksplat` | ✅ | ❌ | 僅匯入 |
| `.lcc`／`.lcc2` | ✅ | ❌ | XGRIDS 多 LOD 專有格式 |
| `lod-meta.json` | ✅ | ❌ | 串流 SOG（多 LOD） |
| `.html`／`.zip` | ❌ | ✅ | 自包含的檢視器 App，可自架 |

- **一鍵發布**：發布到 superspl.at，自動壓縮成 SOG；100 萬個高斯點以上的大範圍場景會自動產生 LOD 做漸進式串流。發布後可在 Studio 加攝影機視角、註解熱點、後製效果、天空盒、碰撞幾何。
- **PWA**：可從瀏覽器網址列安裝成 App，之後在檔案總管／Finder 雙擊 `.ply`、`.sog`、`.spz` 等檔直接開啟。
- **API**：SuperSplat API 可讓掃描 App、訓練管線直接把點雲發布到 superspl.at（需 PlayCanvas access token）。

## 技術架構或運作原理

- 以 TypeScript 撰寫，建立在 PlayCanvas 引擎（WebGL／WebGPU）與 PCUI 介面庫上，所有編輯運算都在瀏覽器本機進行；只有「發布」時才上傳到 PlayCanvas 伺服器。
- 格式轉換、LOD 生成與 SOG 壓縮背後使用 PlayCanvas 的 [splat-transform](https://github.com/playcanvas/splat-transform) CLI（Convert 頁面即其網頁前端）。
- 載入含多個 LOD 的檔案時，預設選取「高斯點少於 2,000 萬」的最高細節層級，避免記憶體爆掉。

## 安裝與使用方式

- **直接使用**：開 https://superspl.at/editor ，把點雲檔拖進視窗即可，不需帳號；發布才需要免費的 PlayCanvas 帳號。
- **網址載入**：`https://superspl.at/editor?load=<SPLAT_URL>`
- **本機開發**（需 Node.js 20.19 以上）：

```bash
git clone https://github.com/playcanvas/supersplat.git
cd supersplat
npm install
npm run develop   # 開啟 http://localhost:3000
```

典型流程：拖入 `.ply` → 開啟 Selection Depth（`N`）→ 用 Flood／Lasso 等工具選漂浮點 → `Delete` → 多角度檢查 → `File > Export` 存成 SOG／SPZ，或 `File > Publish` 發布並取得分享連結。

## 適用情境

- 清理 Nerfstudio、Postshot、Luma、Polycam、Scaniverse 等工具輸出的 3DGS（去除漂浮點、背景、裁切範圍）。
- 把巨大的 PLY 壓縮成 SOG／SPZ，方便網頁或遊戲引擎使用。
- 製作攝影機飛越動畫並發布成可分享、可嵌入網頁的 3D 場景頁。
- 處理 AI 世界模型（如 HY-World 2.0、World Labs Marble）匯出的高斯點雲。
- 匯出單一 HTML 檢視器，離線展示或自架。

## 授權與成本

- **授權**：MIT（編輯器原始碼）。
- **成本**：編輯器免費；superspl.at 發布需免費 PlayCanvas 帳號。superspl.at 是否有付費方案、免費帳號的發布數量或容量上限，官方文件未明列，資料不足（v3.5.2 更新提到「上傳前檢查發布限制」，表示平台端確實有限制）。直接上傳單檔上限 10 GB。
- 發布到 superspl.at 的點雲可選擇是否開放下載，開放時需選擇 Creative Commons 授權。

## 限制與注意事項

- 只能載入 3D Gaussian Splat 格式的 PLY，一般網格或點雲 PLY 會匯入失敗。
- 不負責訓練或生成點雲，需搭配其他 3DGS 訓練工具或世界模型。
- PLY 序列（動態點雲）每格都是完整場景，非常吃記憶體。
- 從 Scene Manager 刪除整個點雲列無法復原（與刪除高斯點不同）。
- 新發布的場景預設為「不公開列出」（unlisted），要在 Manage 頁手動改成公開才會出現在搜尋。

## 相關工具

- [splat-transform](https://github.com/playcanvas/splat-transform)（PlayCanvas 的點雲轉換 CLI）、[PlayCanvas Engine](https://github.com/playcanvas/engine)
- 同資料夾：[3D Gaussian Splatting for model city](3D-Gaussian-Splatting-for-model-city.md)（從影片訓練 3DGS 的完整管線）、[HY-World 2.0](HY-World-2.0.md)（生成／重建 3DGS 世界）、[World Labs](World-Labs.md)（Marble 可匯出高斯點雲）

## 資料來源

- 原清單來源：Threads @davepoon128 貼文 https://www.threads.com/@davepoon128/post/DenVxBCkyaN
- https://github.com/playcanvas/supersplat （README）
- https://api.github.com/repos/playcanvas/supersplat （授權、星數、最新版本 v3.5.2）
- https://developer.playcanvas.com/user-manual/supersplat/ （使用手冊；以下各頁原始碼位於 github.com/playcanvas/developer-site）
  - editor/import-export（格式表）、editor/editing-splats（選取與清理）、editor/publishing（發布）、editor/timeline（時間軸）
  - upload（直接上傳與 10 GB 上限）、streaming（LOD 串流）、manage（授權選項）、api-integrations（API）
