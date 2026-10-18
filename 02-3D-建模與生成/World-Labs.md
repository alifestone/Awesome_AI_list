# World Labs

- **分類**：3D 建模與生成 / AI 生成 3D 世界
- **連結**：https://www.worldlabs.ai/ （原清單無連結，已補上官網；Marble 應用程式：https://marble.worldlabs.ai ）

## 原清單說明

生成可探索 3D 世界的服務（Marble）。

> **查證補充**：正確。官網確認 Marble 是 World Labs 的第一個產品，可生成「空間一致、高擬真、持久存在」的 3D 世界，使用者可在其中移動、編輯。

## 概述

World Labs 自述為「空間智慧（spatial intelligence）」公司，開發能感知、生成、推理並與虛擬及實體世界互動的世界模型（world models）。創辦人為李飛飛（Fei-Fei Li）、Justin Johnson、Ben Mildenhall、Christoph Lassner。

旗艦產品 **Marble** 在 2025-11-12 全面開放（先前有約兩個月前的預覽版與早期 beta），可從文字、圖片、影片或粗略 3D 配置生成可探索的 3D 世界，並匯出為高斯點雲、網格或影片。API 定價頁列出的模型有 `marble-1.0`、`marble-1.1`、`marble-1.1-plus`、`marble-1.0-draft`。

## 核心功能／特色

- **多模態輸入**：文字提示、單張圖片、多張圖片（可指定方向或 Auto Layout）、影片（< 100 MB）、360° 全景圖、Chisel 建立的 3D 結構。
- **Chisel**（實驗性）：先用基本形體或匯入的 3D 素材配置場景結構，再用文字指定視覺風格，結構與風格分開控制。
- **編輯**：AI 局部修改（移除或修飾物件）與大範圍變更（替換物件、改風格、重構區域）；全景編輯、變體生成。
- **擴展與組合**：選取區域點擊擴展（expand）以補細節或修正瑕疵；Compose 模式把多個世界組合成更大的空間。
- **Record**：錄製攝影機飛越影片。
- **匯出**：
  - 高斯點雲（Gaussian splats，最高擬真度，可用開源 Spark 渲染器在瀏覽器中檢視；API 文件寫 PLY splat 匯出免費）
  - 三角網格：用於粗略物理的碰撞網格，以及高品質網格（API 的 HQ mesh 為 GLB）
  - 影片：可精確控制攝影機，並可選擇「增強」以加入細節與動態
  - 網頁分享連結、VR 相容連結
- **平台**：網頁版，桌機與手機皆可用；但進階建立流程、3D 結構建立、全景檢視等功能在手機上不提供。

## 技術架構或運作原理

- 官方只說明 Marble 由 World Labs 的多模態世界模型驅動，可重建、生成與模擬 3D 世界；模型架構、參數量等細節資料不足。
- 官方文件估計的生成時間：由文字／圖片／3D 結構生成全景約 30 秒；由多圖／影片生成全景約 2 分鐘；草稿約 20 秒；完整世界約 5 分鐘；世界擴展約 5 分鐘；全景編輯約 20 秒；高品質網格約 1 小時。

## 安裝與使用方式

- **網頁應用**：到 https://marble.worldlabs.ai 註冊使用，不需安裝。
- **API**：透過 World Labs Platform（https://platform.worldlabs.ai/ ）購買 API 點數使用。端點與驗證方式的細節本次未查閱，資料不足。
- **檢視器**：[Spark](https://sparkjs.dev/)（World Labs 官網列出的開源高斯點雲網頁渲染器）。

## 適用情境

官方部落格列出：遊戲、視覺特效（VFX）、設計、機器人、電影製作、互動世界、模擬、療癒環境等。另外也適用於：

- 從概念圖或實景照片／影片快速生成可走動的 3D 場景。
- 為遊戲引擎或 DCC 工具（Blender、Maya、3ds Max）產出場景素材。
- 機器人模擬用的環境（可匯出碰撞網格）。

## 授權與成本

**Marble 應用程式方案**（依官方說明文件 account-billing）：

| 方案 | 價格 | 世界生成數 | 主要內容 |
| --- | --- | --- | --- |
| Free | 免費 | 最多 4 個 | 文字、單張圖片、360° 全景生成 |
| Standard | $20／月（文件中的升級範例；含 20,000 點／月） | 最多 12 個 | 增加多圖／影片／3D 配置輸入、編輯、匯出、下載社群世界 |
| Pro | $35／月（文件中的升級範例） | 最多 25 個 | 增加世界擴展、影片增強、高品質貼圖網格匯出；**含生成世界的商用權** |
| Max | 官方文件未列價格 | 最多 75 個 | 針對大量生產 |
| Enterprise | 洽詢業務 | 客製 | — |

- 官方文件只在 Pro 明確寫出「含商用權」。Max 方案的價格與是否含商用權，官方文件未載明，資料不足（網路搜尋摘要中有第三方稱 Max 為 $95／月且含商用權，但未經官方證實）。
- 訂閱點數不累積到下期；加購點數（僅付費方案可買）一年後過期；降級或取消不按比例退款。
- Marble 應用程式的點數**不能**用於 API。

**API 定價**（docs.worldlabs.ai/api/pricing）：

- $1.00 = 1,250 點，最低購買 $5（6,250 點），API 點數不過期。
- `marble-1.0`／`marble-1.1`：每個世界約 1,500–1,600 點；`marble-1.1-plus`：1,500–3,100 點（依世界大小）；`marble-1.0-draft`：150–250 點。
- 若未提供全景圖，生成全景需額外點數：文字或非全景圖片 80 點、多圖或影片 100 點。
- 高品質網格匯出（GLB）每個世界 3,500 點（約 $2.80）；PLY splat 匯出免費。

## 限制與注意事項

- 商用權依方案而定，官方文件僅明確列於 Pro；商用前請查最新條款與定價頁。
- 免費方案生成數有限，且不能購買加購點數。
- 高品質網格匯出耗時約 1 小時，且在 API 上需額外付費。
- 手機版功能受限。
- 生成世界的實際尺度、幾何精度是否適合工程用途，官方未提供量化資料，資料不足。

## 相關工具

- [Spark](https://sparkjs.dev/)（高斯點雲渲染器）
- 同資料夾：Hyper3D（Rodin，生成單一 3D 物件）、3D Gaussian Splatting for model city（由實拍影片重建 3DGS 場景）

## 資料來源

- https://www.worldlabs.ai/ （官網首頁）
- https://www.worldlabs.ai/about （創辦人與使命）
- https://www.worldlabs.ai/blog/marble-world-model （Marble 正式發表文）
- https://docs.worldlabs.ai/ （Marble 產品文件）
- https://docs.worldlabs.ai/marble/support/account-billing （方案與計費規則）
- https://docs.worldlabs.ai/api/pricing （API 定價）
