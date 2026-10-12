# MuJoCo

- **分類**：機器人與具身智慧 / 模擬
- **連結**：https://github.com/google-deepmind/mujoco

## 原清單說明

DeepMind 的物理模擬引擎，機器人與強化學習的標準模擬器。

## 概述

MuJoCo 是「Multi-Joint dynamics with Contact」的縮寫，是一套通用物理引擎，用來模擬會與環境互動的多關節結構。主要服務的領域是機器人、生物力學、圖學與動畫，以及機器學習。目前由 Google DeepMind 維護。

發展歷程：

- 最初由華盛頓大學 Movement Control Laboratory 開發，2012 年由 Emanuel Todorov、Tom Erez、Yuval Tassa 發表論文。
- 之後由 Roboti LLC 商業化販售。
- 2021 年 10 月被 DeepMind 收購。
- 2022 年 5 月以 Apache 2.0 授權開源。

截至 2026-10-13，GitHub 上最新版本是 **3.15.0**（2026-10-05 發布），前兩版為 3.14.0（2026-09-22）與 3.13.0（2026-09-08）。官方的目標是每月第一週發布新版。

## 核心功能／特色

- **廣義座標模擬**：在廣義座標下計算，因此不會出現關節違規（joint violation）。即使有接觸，逆動力學也能定義良好。
- **凸最佳化接觸模型**：軟接觸、極限、乾摩擦與等式約束，都統一用連續時間的凸最佳化來表述，而不是 LCP／NCP。
- **多種求解器與選項**：
  - 求解器可選 Newton（預設，二次收斂）、Conjugate Gradient、Projected Gauss-Seidel。
  - 摩擦錐可選金字塔形或橢圓形。
  - Jacobian 可選稠密或稀疏。
  - 積分器可選 Euler 或 Runge-Kutta。
- **豐富的模擬對象**：除了剛體，也支援粒子、布料、繩索與軟體。致動器方面支援馬達、肌肉、肌腱、曲柄滑塊等。
- **模型格式**：使用 XML 格式的 MJCF，內建模型編譯器，也能載入 URDF。
- **視覺化**：跨平台 GUI，內建 OpenGL 互動式 3D 視覺化。
- **效能**：執行期模組用 C 撰寫並針對效能調校，資料結構由編譯器預先配置。
- **GPU 後端**：
  - MJX：以 JAX 實作。
  - MuJoCo Warp：以 NVIDIA Warp 實作。
  - 兩者都沿用 `mjModel`／`mjData` 結構，可做大規模平行模擬。

## 技術架構或運作原理

- **模型與資料分離**：
  - `mjModel` 存放編譯後、不會改變的模型描述。
  - `mjData` 存放隨時間變化的狀態與中間結果。
  - 因為兩者分開，很容易同時跑多組狀態或多個模型。
- **建模流程**：MJCF 或 URDF 先解析成 `mjSpec`，再編譯成 `mjModel`。編譯後可存成 MJB 二進位檔（綁定版本），或打包成 MJZ 壓縮檔。官方建議保留 XML 或 MJZ 格式。
- **模擬流程**：`mj_step` 會執行完整的前向動力學並推進一步。可以用 pipeline flag 只跑部分階段，也可以用 callback 加入自訂力場、致動器、碰撞與控制器。
- **效能最佳化**：約束可以依「島」（constraint island）分開求解，處於靜止狀態的島可以進入休眠，節省計算。

## 安裝與使用方式

- **Python（3.10 以上）**：

  ```bash
  pip install mujoco
  ```

  Linux 的預編譯 wheel 以 `manylinux2014` 為目標。
- **預編譯二進位檔**：可從 GitHub Releases 下載，官方稱這是「推薦的使用方式」。
  - Linux：x86-64、AArch64
  - Windows：僅 x86-64
  - macOS：universal
- **從原始碼建置**：做法請見官方文件。README 提醒 `main` 分支的最新程式碼可能不穩定。
- **語言綁定**：
  - 官方提供：Python、JavaScript（WebAssembly）、C# 與 Unity 外掛。
  - 第三方：MATLAB Simulink、Swift、Java、Julia、Rust。
- **教學**：README 列出多份 Colab 筆記本，內容涵蓋基礎、模型編輯、rollout、LQR 控制、最小平方求解、MJX、可微分物理。

## 適用情境

- 機器人控制、強化學習研究與 sim-to-real 前的策略訓練。DeepMind Control Suite 的一部分就建立在 MuJoCo 上。
- 生物力學與肌肉骨骼模擬。
- 以 MJX／MuJoCo Warp 在 GPU 上做大規模平行訓練。
- 許多具身 AI 專案拿它當底層模擬器，例如本資料夾的 quackd，就用 MuJoCo 模擬 Microduck 與 SO-101 手臂。

## 授權與成本

- 原始碼採 Apache License 2.0，免費使用。
- `doc` 目錄下的文件、圖片與影片採 CC BY 4.0。
- README 註明：「not an officially supported Google product」。
- 在論文中使用時，官方要求引用 Todorov、Erez、Tassa 於 2012 年 IROS 發表的〈MuJoCo: A physics engine for model-based control〉。

## 限制與注意事項

- Windows 只提供 x86-64 的預編譯檔。
- MJB 二進位模型綁定特定版本，跨版本使用時建議保留 XML 或 MJZ。
- 從 3.5.0 起改用修改版的語意化版本規則（詳見 `VERSIONING.md`），且每月發版，升級時要留意 API 變動。
- MuJoCo Playground 與 MuJoCo Menagerie 雖然是常見的周邊專案，但這次讀過的 README 與概述頁都沒有提到，本條目不展開說明（資料不足）。

## 相關工具

- dm_control（DeepMind 的環境套件，含 PyMJCF）
- MJX、MuJoCo Warp（GPU 後端）
- mjswan（JavaScript 綁定的擴充）
- 模型轉換器：MyoConverter（OpenSim → MJCF）、gz-mujoco（SDFormat ↔ MJCF）、obj2mjcf、Onshape to Robot
- 其他模擬器：NVIDIA Isaac Sim／Isaac Lab、PyBullet、Genesis（以上僅作類別參考）

## 資料來源

- https://github.com/google-deepmind/mujoco
- https://raw.githubusercontent.com/google-deepmind/mujoco/main/README.md
- https://github.com/google-deepmind/mujoco/releases
- https://mujoco.org/
- https://mujoco.readthedocs.io/en/stable/overview.html
- https://en.wikipedia.org/wiki/MuJoCo
