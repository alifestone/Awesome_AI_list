# 3D Model Anything

- **分類**：3D 建模與生成 / 3D 重建與高斯點雲
- **連結**：https://github.com/wesbos/3d-model-anything
- **線上展示**：https://wesbos.github.io/3d-model-anything/

## 原清單說明

用 iPhone 掃描房間，再讓 AI coding agent 依掃描的幾何與照片，重建成可編輯的 Three.js 場景。（來源：使用者提供的 GitHub repo）

> **查證補充**：正確。README 明講這是**反覆迭代的重建流程**，不是一鍵把掃描轉成完美模型的轉換器；目前只針對房間與室內空間。

## 概述

Wes Bos 的開源專案，分三塊：

1. **3D Model Anything iPhone app**（Swift）：用 LiDAR 掃描房間，同一個 ARSession 同時記錄 RoomPlan 牆門窗與家具框、LiDAR 網格、帶相機位姿與內參的照片、深度幀，可跨多天分次掃整棟房子，匯出成 zip 分享。
2. **scan-to-threejs agent skill**（`.agents/skills/scan-to-threejs/`）：指引 agent 把掃描當「量測證據」、照片當「視覺證據」，先建出可編輯幾何，再用同機位渲染跟原照片並排比對、修正最大差異，反覆迭代。
3. **Three.js 檢視器**與 Wes 辦公室的完整重建示範：可用娃娃屋、第一人稱行走、俯視、線框、knolling（零件攤平）等視角瀏覽。

截至 2026-11-20：約 3,100 顆星，建立於 2026-10-21，最後推送 2026-10-27。另有[介紹影片](https://www.youtube.com/watch?v=JGQCcCzuS88)。

## 核心功能／特色

- **iPhone 擷取**（需 LiDAR 的 iPhone／iPad、iOS 17+）：
  - RoomPlan（無頭模式）的牆、門、窗、開口與家具外框。
  - LiDAR 網格，掃描時依照片覆蓋率即時上色（紅＝還需要拍、綠＝已覆蓋），存成 `mesh/room-N.ply`。
  - 自動在最能增加覆蓋的位置抓清晰照片，也可手動拍特寫；每張照片附精確位姿與內參。
  - 256×192 深度＋信心值＋640×480 彩色幀，最多每秒 5 幀。
  - 房間庫、掃描歷史版本、從已存房間接續掃描、垃圾桶；每完成一間就寫檔，當機最多只丟正在掃的那間。
- **scan-to-threejs skill**：
  - 支援 app 匯出（`house.json`、含 `manifest.json` 的 bundle）、原始 RoomPlan JSON、GLB/glTF 掃描；各有轉換／量測腳本（`house_to_rooms.py`、`bundle_to_room.py`、`measure_scan.mjs`）。
  - 先定地板、牆面、開口、天花板高低差與家具尺寸，再加細節；不確定的尺寸要記錄下來，不准亂編。
  - `cmp.sh`、`cmp_photo.sh` 用與原照片相同的相機位姿截圖並拼接對照；工具只負責產生對照圖，**相似度要 agent 自己看、自己判斷**。
  - 交付時實作 `RoomModule` 並註冊到 `demos/index.ts`，說明哪些細節是量到的、建模的或估計的。

## 安裝與使用方式

檢視器（Node.js 22.12+）：

```sh
git clone https://github.com/wesbos/3d-model-anything.git && cd 3d-model-anything
npm ci
npm run dev        # http://localhost:5188；遊玩頁 /play.html?room=office-v4&mode=fpv
```

自己的房間：

1. 用 Xcode 建置 `apps/house-capture`（`xcodegen generate` 後選自己的簽章團隊），裝到有 LiDAR 的 iPhone。**目前沒有上架 App Store**。
2. 掃描後用分享選單匯出房間 zip，解壓到 `data/captures-in/<room>/`（已在 `.gitignore`）。
3. 在支援本機 skill 的 agent（如 Claude Code、Codex）裡開這個 repo，要求：

   > Use scan-to-threejs to rebuild the room in data/captures-in/my-room. Inspect the measurements and photos, create an editable scene, and compare rendered views with the original photographs.

輔助腳本需要 Python 3；照片比對需要 Pillow，選用的深度重建需要 NumPy、Open3D、Pillow；截圖腳本使用 `agent-browser` CLI。skill 資料夾可複製到其他專案，但擷取流程仍需要這個 repo 的檢視器。

## 適用情境

- 把自己的房間、辦公室做成可在網頁上走動、可編輯的 Three.js 場景。
- 研究「掃描當量測、照片當參考、agent 反覆比對修正」的重建方法，套用到其他 agent 建模工作。
- 需要帶位姿照片、深度、LiDAR 網格的室內資料集來源（app 匯出格式有完整文件）。

## 授權與成本

- 程式碼與 skill：MIT。
- 示範辦公室的量測資料、圖片與貼圖另有 [ASSETS-LICENSE](https://github.com/wesbos/3d-model-anything/blob/main/ASSETS-LICENSE.md)：只能隨 repo 研究與展示，不可單獨轉售或再散布；部分材質來自 Poly Haven、ambientCG，沿用其原授權。
- 本身免費；agent 的模型費用另計。

## 限制與注意事項

- ⚠️ 不是一鍵轉換：成果品質取決於 agent 反覆建模與人的檢查，示範辦公室是多輪迭代（`office-v2` → `office-v4`）的結果。
- ⚠️ 掃描需要有 LiDAR 的 iPhone／iPad，且要自己用 Xcode 建置安裝；沒有 LiDAR 的裝置只能匯入檢視。
- 目前只針對房間與室內；多次分開掃描的房間需要先對齊才能組成整棟房子。
- 公開示範不含原始掃描與照片，所以示範辦公室的 Scan、Overlay 模式是關閉的。
- 掃描與照片可能含個資，作者提醒發布前自行檢查。

## 相關工具

- 同資料夾：[3D Gaussian Splatting for model city](3D-Gaussian-Splatting-for-model-city.md)（手機影片 → 3DGS 寫實重建，不是可編輯幾何）、[SuperSplat](SuperSplat.md)
- 網頁 3D：[three.js](../04-設計---前端/three.js.md)、[threejs-skills](../04-設計---前端/threejs-skills.md)

## 資料來源

- https://github.com/wesbos/3d-model-anything （README、`.agents/skills/scan-to-threejs/SKILL.md`、`apps/house-capture/README.md`、`ASSETS-LICENSE.md`、`docs/release-status.md`）
- https://api.github.com/repos/wesbos/3d-model-anything （星數、建立與推送日期）
