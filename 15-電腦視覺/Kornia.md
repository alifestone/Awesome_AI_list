# Kornia

- **分類**：電腦視覺 / 視覺函式庫
- **連結**：https://github.com/kornia/kornia

## 原清單說明

建立在 PyTorch 上的可微分電腦視覺函式庫，GitHub 描述為「Geometric Computer Vision Library for Spatial AI」。

## 概述

Kornia 是一套開源的可微分電腦視覺函式庫，建立在 PyTorch 之上。它提供影像處理與幾何視覺的演算法，例如濾波、色彩轉換、相機模型、對極幾何、RANSAC、特徵偵測與匹配。這些運算都直接吃 PyTorch tensor，可以整批處理、在 GPU 上執行，而且大多可以反向傳播梯度。

- 2018-08 在 GitHub 建立，截至 2026-11-08 約 12.4k 星、1.5k fork，repo 仍持續更新。
- 最新正式版是 **v0.9.0**（2026-10-23）。前幾版為 v0.9.0rc1（2026-07-19）、v0.8.3（2026-05-19）、v0.8.2（2025-11-08）。
- README 寫明的新方向：讓 Kornia 成為 PyTorch 生態裡可微分電腦視覺與幾何的「參考實作與可執行規格」。也就是優先把慣例寫清楚、補一致性測試、公開誠實的基準，而不是繼續擴充 API（見 repo 的 `ROADMAP.md`）。
- 專案由志工開發與維護，透過 Open Collective 接受贊助。
- **定位**：官網 kornia.org 的標語是「Computer vision for robotics & spatial AI」，自稱是替空間 AI 打造整套堆疊的非營利組織，涵蓋從研究用的可微分視覺到機器人上的即時感知。本 repo 的 Python 函式庫是這套堆疊的「研究」層。其他同組織專案包括：kornia-rs（Rust 影像與 3D 核心）、kornia-slam（即時定位與建圖）、vision-rt（Jetson Orin 上的 TensorRT 推論）、sensor-rt（相機、立體與 IMU 驅動），以及 Bubbaloop（在 Jetson／Raspberry Pi 上跑的視覺 agent runtime，附 MCP server）。官網還有一個 MuJoCo 機器人模擬器 demo，把 Kornia 運算子套在模擬機器人的相機上。⚠️ 這些周邊專案本次只讀了官網介紹，沒有逐一查證。

## 核心功能／特色

- **運算子數量多**：README 說公開運算子超過 1,200 個，大多數在 torchvision 裡找不到對應。和 torchvision 重疊的主要只有縮放、裁切、翻轉、color jitter 與模糊。
- **一次呼叫、每張圖不同參數**：
  - `gaussian_blur2d` 的 `sigma` 可以是 `(B, 2)` tensor。
  - `rotate` 收 `(B,)` 角度；`warp_affine`／`warp_perspective` 收 `(B, 2, 3)`／`(B, 3, 3)` 矩陣。
  - torchvision 的 functional 運算每次呼叫只能套一組參數。
- **整批最小解算器與穩健估計**：
  - `find_fundamental(..., method="7POINT")` 吃 `(B, 7, 2)` 樣本，回傳 `(B, 3, 3, 3)` 的所有實數解。
  - 另有 8 點法、5 點本質矩陣（`find_essential`）、DLT 單應性與 PnP（`solve_pnp_dlt`）。
  - `RANSAC` 支援單應性、基礎矩陣、本質矩陣模型，在裝置上抽樣與評分；`compile=True`（PyTorch ≥ 2.14）可把整個估計編成一張圖在 GPU 上跑。
- **可微分幾何**：深度與 3D 點互轉（`depth_to_3d_v2`、`unproject_points`、`project_points`）、`warp_frame_depth`、`remap`。相機模型支援 Brown–Conrady 與 Kannala–Brandt 畸變，Lie 群有 `So3`、`Se3`。梯度可以對深度、位姿與相機參數回傳。
- **帶標註的資料增強**：`AugmentationSequential` 在 2D 中把同一次抽樣的變換一起套到影像、遮罩、框與關鍵點，而且可以反轉。另有 AutoAugment、RandAugment、TrivialAugment，以及 MixUp、CutMix、Mosaic 等。3D 增強只轉換體積資料，不處理標註也不能反轉。
- **GPU 上的局部特徵**：SIFT、HardNet、DISK、ALIKED、XFeat、DeDoDe、LoFTR、LightGlue，搭配互為最近鄰與 ratio test 匹配器。
- **預訓練模型**：YuNet 人臉偵測、SAM 分割、RT-DETR 偵測、MobileViT／ViT 分類等。
- **編譯與匯出**：README 說幾乎所有測過的運算子設定都能在 `torch.compile` 下執行且結果與 eager 一致，超過 1,000 個能匯出 ONNX。每個運算子的結果列在官方文件的 export support 頁。`kornia.onnx.ONNXSequential` 可以把 Hugging Face 上的 ONNX 運算子、模型和自己的模型串成一條再匯出。

## 技術架構或運作原理

- **純 PyTorch 實作**：運算在輸入 tensor 所在的裝置上進行，不需要轉回 NumPy，所以可以直接放進訓練迴圈、跟著模型一起反向傳播。
- **不可微的部分**：`RANSAC` 以及 DeDoDe、XFeat 等學習式特徵的「擷取」步驟不傳梯度。
- **影像讀取**：Quick Start 用姊妹專案 `kornia-rs`（Rust 實作）讀圖與縮放；`kornia-rs>=0.2.0` 是 PyPI 套件的必要相依。
- **避免 host 同步**：在 CUDA 上，增強會把抽到的參數非阻塞地搬到 GPU，並有測試確保公開的增強沒有不必要的 host 同步。README 說從 0.9.1 起，`sigma` tensor 與 gamma、contrast、solarize 等數值檢查也在裝置上驗證。⚠️ 截至 2026-11-08 最新正式版仍是 0.9.0，0.9.1 尚未發布；MPS 上要 PyTorch ≥ 2.13 才有此效果。

## 安裝與使用方式

- **需求**（PyPI 0.9.0）：Python ≥ 3.11、PyTorch ≥ 2.5.1、NumPy ≥ 1.21、kornia-rs ≥ 0.2.0。
- **安裝**：

  ```bash
  pip install kornia
  ```

  ONNX、Stable Diffusion 溶解等功能需要額外套件，有 `onnx`、`sd`、`image` 等 extras。也可以 `pip install git+https://github.com/kornia/kornia` 裝最新版。開發環境官方建議用 pixi。
- **每張圖不同模糊程度的範例**（依 opensourceprojects.dev 文章的示範改寫）：

  ```python
  import torch
  from kornia.filters import gaussian_blur2d

  x = torch.rand(8, 3, 256, 256, device="cuda")
  sigma = torch.rand(8, 2, device="cuda") * 3 + 0.5   # 每張圖各自的 sigma
  y = gaussian_blur2d(x, (9, 9), sigma)
  ```

- **線上試用**：瀏覽器 playground（kornia.org/playground）與 Colab hello-world 筆記本。
- **其他資源**：文件 kornia.readthedocs.io、教學、獨立的 `kornia-examples` repo、部落格與 Discord。

## 適用情境

- 機器人與空間 AI：相機標定、立體視覺、位姿估計（PnP、本質矩陣）、影像對位，而且整批在 GPU 上算。
- 自監督深度或位姿學習：需要對深度、位姿、相機參數求梯度的光度損失與 warp。
- 訓練資料增強：要讓影像、遮罩、框、關鍵點一起變換，並在 GPU 上大批處理。
- 特徵匹配與 SfM 前處理：LoFTR、LightGlue、DISK 等學習式特徵的 GPU 實作。
- 參考實作：需要慣例明確、有一致性測試的幾何視覺運算，用來驗證自己的實作。

## 授權與成本

- Apache License 2.0，免費使用，可商用。
- 內建的預訓練模型權重各有原始來源與授權，本次查證未逐一確認（資料不足）。

## 限制與注意事項

- **只有整批 GPU 運算才有速度優勢**：README 引用 0.9.0 官方基準（RTX 4090、batch 32），許多濾波、warp、特徵匹配與影像指標在 eager 模式比逐張跑 CPU 的 OpenCV／scikit-image 快約 10～70 倍，`torch.compile` 後部分超過 100 倍。但：
  - 和 torchvision 在同一張 GPU 上比，重疊的運算 eager Kornia 比較慢；編譯後 hue、color jitter、高斯模糊較快，翻轉、裁切、亮度仍較慢。
  - 單張 `uint8` 影像在 CPU 上，OpenCV 較快。
  - 只做一次固定參數的模糊或縮放，README 自己說用幾行 PyTorch 或 torchvision 就夠了。
- **半精度支援不完整**：在 Python 3.11 + PyTorch 2.15.0 的 CPU 已知失敗清單中，float16 有 239 筆、bfloat16 有 251 筆測試失敗，集中在 augmentation 與 geometry 模組（例如 `solve_pnp_dlt` 不接受半精度輸入）。CI 沒有 CUDA 或 MPS 半精度測試；README 附的 CUDA 數據只是單一 revision 的本地量測，不保證之後的版本。
- **0.9.1 尚未發布**：文章提到的 0.9.1 行為（裝置上的參數驗證）目前要從 GitHub 安裝才有。
- **版本需求偏新**：要 Python 3.11 以上，部分功能要 PyTorch 2.13／2.14 以上。

## 相關工具

- [SpatialClaw](../01-機器人與具身智慧/SpatialClaw.md)：空間推理 agent，呼叫 SAM3、Depth-Anything-3 等感知工具；Kornia 可當這類流程的幾何運算層
- [MuJoCo](../01-機器人與具身智慧/MuJoCo.md)：物理模擬器；模擬出的相機影像可以接 Kornia 做處理與增強
- kornia-rs（同團隊的 Rust 影像 I/O 與處理函式庫）
- 其他視覺函式庫：OpenCV、torchvision、scikit-image（以上僅作類別參考）

## 資料來源

- https://github.com/kornia/kornia
- https://raw.githubusercontent.com/kornia/kornia/main/README.md
- https://github.com/kornia/kornia/releases
- https://pypi.org/project/kornia/
- https://kornia.readthedocs.io
- https://www.kornia.org
- https://raw.githubusercontent.com/kornia/kornia/main/ROADMAP.md
- https://www.opensourceprojects.dev/post/kornia （2026-10-28，次要來源）
