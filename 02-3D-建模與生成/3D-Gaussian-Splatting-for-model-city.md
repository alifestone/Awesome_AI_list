# 3D Gaussian Splatting for model city

- **分類**：3D 建模與生成 / 3D 重建
- **連結**：https://github.com/rakeshsuthar6322/3d_gaussian_splatting_for_model_city

## 原清單說明

以 3DGS 重建模型城市場景（依名稱判斷）。

> **查證結果**：「（依名稱判斷）」部分僅部分正確。此 repo 確實是 3D Gaussian Splatting（3DGS）重建流程，但其 README 的定位是「把實景影片轉成可匯入 NVIDIA Isaac Sim、帶物理碰撞網格的 3DGS 環境」，用於機器人模擬；README 內文完全沒有提到「model city（模型城市）」，此字眼只出現在 repo 名稱。實際重建的場景類型是任意可拍攝的實體空間，並非專為城市模型設計。

## 概述

一套端到端（end-to-end）的 Python／Shell 管線：用手機或相機繞行拍攝一段影片，自動抽影格、過濾模糊畫面、以 COLMAP 求相機位姿、用 Nerfstudio 的 Splatfacto 訓練 3DGS，輸出 PLY 與 USDZ，最後再生成不可見的碰撞網格，讓機器人在 Isaac Sim 中能與寫實的高斯點雲場景發生物理互動。

GitHub 簡介原文：「3d Gaussian Splatting pipeline for Isaac Sim .usd environment creation.」（2026-09 建立，主要語言 Python；截至 2026-10-13 約 61 顆星。）

## 核心功能／特色

- **一鍵式管線**：`setup.sh` 一次安裝環境，`run_pipeline.sh <影片>` 跑完整流程。
- **模糊偵測**：`blur_detector.py` 以 Laplacian variance 計算銳利度，低於門檻（預設 15）的影格丟棄，以提升 COLMAP 特徵匹配品質。
- **三組訓練預設**（`configs/training_presets.ini`）：Default、Aggressive（補洞）、Refined（管線預設，品質最佳）。
- **後處理**：`filter_gaussians.py`、`remove_floaters_smart.py` 移除漂浮雜點（floaters）；也可用 SuperSplat 手動裁切、對齊。
- **碰撞網格生成**：`create_collision_mesh.py` 取高斯中心點 → KNN 估法向量 → Poisson 表面重建 → 密度過濾 → 減面，產生 OBJ／PLY 碰撞網格。
- **可選稠密點雲**：使用 Depth-Anything-V2（ViT-Large 權重約 1.3 GB）做單目深度估計，補強大面積空洞的場景。

## 技術架構或運作原理

流程：**Video → FFmpeg 抽影格（預設 2 FPS）→ 模糊過濾 → COLMAP SfM（SIFT 特徵、匹配、Bundle Adjustment）→ Splatfacto 3DGS 訓練 → 匯出 PLY → `usd-convert-gsplat` 轉 USDZ → 碰撞網格 → 匯入 Isaac Sim**

- 3DGS 將場景表示為大量帶位置、共變異數（形狀／方向）、不透明度與球諧函數（視角相關顏色）的半透明 3D 橢球，以可微分光柵化渲染後與照片比對、反向傳播更新參數，並透過 Adaptive Density Control 複製／分裂／剔除高斯。
- 由於 PhysX 等物理引擎無法與高斯基元互動，才需要另外重建三角網格作為不可見碰撞體，疊在視覺用 splat 之下。
- 主要依賴：nerfstudio、Open3D、PyTorch、plyfile、scikit-learn、OpenCV；USD 轉換在獨立的 `usd_convert` conda 環境中進行。

## 安裝與使用方式

前置需求：NVIDIA GPU（≥ 8 GB VRAM）與驅動、Conda、FFmpeg、Git；README 表示不需要 sudo。

```bash
git clone https://github.com/rakeshsuthar6322/3d_gaussian_splatting_for_model_city.git
cd 3d_gaussian_splatting_for_model_city
chmod +x setup.sh && ./setup.sh          # 建立 gs_pipeline / usd_convert 環境並下載 Depth-Anything-V2（約 10 分鐘）

cp /path/to/your/scene_video.MOV data/video/
export TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=1
chmod +x run_pipeline.sh
./run_pipeline.sh data/video/scene_video.MOV   # README 估計約 30–45 分鐘（依影片長度與 GPU）
```

輸出：`outputs/splat/splat.ply`、`outputs/splat/splat.usdz`、`outputs/collision/collision_map.obj`／`.ply`。

單步訓練範例（Refined 預設）：

```bash
conda run --no-capture-output -n gs_pipeline ns-train splatfacto \
    --data data/processed --output-dir data/processed/training_output \
    --pipeline.model.densify-grad-thresh 0.0002 \
    --pipeline.model.stop-split-at 15000 \
    --pipeline.model.cull-scale-thresh 0.2 \
    --max-num-iterations 30000
```

匯入 Isaac Sim：把 `splat.usdz` 與 `collision_map.obj` 拖入同一 stage、對齊原點，將碰撞網格設為 Invisible，再加上 Physics → Collider。

## 適用情境

- 為機器人模擬快速建立寫實的實景數位分身（digital twin）環境。
- 學習 3DGS 完整實作流程（從拍攝到可互動場景）的範例專案。
- 需要「寫實外觀 + 物理碰撞」兩者兼具的 Isaac Sim 場景。

## 授權與成本

- **授權**：repo 未附 LICENSE 檔（GitHub 未偵測到授權），README 僅寫「This project is for research and educational purposes.」。未明確授權即代表預設保留所有權利，商業使用前應先向作者確認。
- **成本**：本身免費；需自備 NVIDIA GPU。依賴的 nerfstudio、COLMAP、Depth-Anything-V2 等各有自己的授權，需另外確認。

## 限制與注意事項

- 僅支援 NVIDIA GPU（≥ 8 GB VRAM）環境。
- 拍攝品質直接影響結果：動態模糊被 README 稱為攝影測量的「頭號敵人」。
- 積極加密（densification）可補洞但容易產生漂浮雜點，需搭配過濾腳本。
- 碰撞網格是由 Poisson 重建近似得到，細節與精度受參數（預設 depth 11）影響。
- 專案很新（2026-09 建立），社群驗證與維護狀況資料不足。

## 相關工具

- [Nerfstudio](https://nerf.studio/)（Splatfacto）、[COLMAP](https://colmap.github.io/)、[Open3D](http://www.open3d.org/)
- [Depth Anything V2](https://github.com/DepthAnything/Depth-Anything-V2)
- [SuperSplat](https://playcanvas.com/supersplat/editor)（高斯點雲檢視與編輯）
- [NVIDIA Isaac Sim](https://developer.nvidia.com/isaac-sim)
- 原始 3DGS 論文專案頁：https://repo-sam.inria.fr/fungraph/3d-gaussian-splatting/
- 同資料夾：World Labs（Marble，也可匯出高斯點雲）

## 資料來源

- https://github.com/rakeshsuthar6322/3d_gaussian_splatting_for_model_city （README）
- https://api.github.com/repos/rakeshsuthar6322/3d_gaussian_splatting_for_model_city （repo 中繼資料：簡介、授權、星數、建立日期）
