# LIBERO

- **分類**：機器人與具身智慧 / 基準測試
- **連結**：https://github.com/Lifelong-Robot-Learning/LIBERO
- **官網**：https://libero-project.github.io
- **論文**：https://arxiv.org/abs/2306.03310
- **文件**：https://lifelong-robot-learning.github.io/LIBERO/

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：repo 標語為 *Benchmarking Knowledge Transfer in Lifelong Robot Learning.* 由 UT Austin 的 Bo Liu、Yifeng Zhu、Yuke Zhu、Peter Stone 等人提出（NeurIPS 2023 Datasets and Benchmarks Track）。程式碼 MIT，示範資料集 CC BY 4.0。

## 概述

LIBERO 是一套機器人操作（manipulation）的基準測試，原本用來研究「終身學習」：機器人依序學新任務時，能不能把學過的知識轉移過去，又不忘掉舊的。它把要轉移的知識分成兩種：關於物體與空間關係的「陳述性知識」，以及關於動作與行為的「程序性知識」，並設計出分別考驗這兩種知識的任務組。

除了終身學習，LIBERO 後來也成為評測 VLA（視覺–語言–動作）模型最常用的模擬基準之一，OpenVLA、π0 等模型的論文都會回報 LIBERO 各任務組的成功率。

repo 於 2023-04-08 建立，查詢當下（2026-10-20）約 2,450 顆星、515 個 fork，最後一次 push 為 2025-03-15（新增從 Hugging Face 下載資料集）。沒有發布 GitHub release，`setup.py` 版本為 0.1.0。

## 核心功能／特色

- **程序化任務生成**：用 BDDL（行為領域定義語言）描述場景與目標，原則上能產生無限多個操作任務。
- **130 個任務、四個任務組**：
  - **LIBERO-Spatial**：物體相同、擺放位置不同，考驗空間關係的轉移。
  - **LIBERO-Object**：場景布局相同、物體不同，考驗物體知識的轉移。
  - **LIBERO-Goal**：物體與布局相同、目標不同，考驗程序性知識的轉移。
  - **LIBERO-100**：100 個混合了多種知識的任務，再拆成 **LIBERO-90**（預訓練用）與 **LIBERO-10**（測試下游終身學習，也常稱 LIBERO-Long）。
- **人類遙操作示範資料**：四個任務組都附高品質的人類示範，可直接做模仿學習。
- **基線實作**：
  - 三種視覺運動策略網路：`bc_rnn_policy`、`bc_transformer_policy`、`bc_vilt_policy`。
  - 三種終身學習演算法：ER（經驗回放）、EWC、PackNet，外加循序微調（`base`）與多任務學習（`multitask`）兩個基準。
- **五個研究主題**：論文圍繞知識轉移的類型、策略架構、演算法、預訓練的影響等問題設計實驗。
- **每個任務附語言指令**，適合語言條件化的策略與 VLA。

## 技術架構或運作原理

- 底層模擬建立在 **robosuite 1.4.0**（ARISE Initiative）之上，而 robosuite 又使用 [MuJoCo](MuJoCo.md) 物理引擎。
- 任務以 BDDL 檔定義初始狀態與目標條件；`benchmark` 模組依任務組回傳任務、語言描述與 BDDL 檔路徑。
- 環境介面為 `OffScreenRenderEnv`，動作為 7 維（機械手臂末端位姿 + 夾爪）。為了讓評測可比較，每個任務都固定一組初始狀態（`get_task_init_states`）。
- 目前只提供**稀疏獎勵**（完成任務得 +1），官方表示稀疏獎勵的強化學習很難學，因此主要聚焦在終身**模仿學習**。
- 訓練框架以 Hydra 管理設定，模仿學習部分依賴 robomimic 0.2.0。

## 安裝與使用方式

官方指定的環境（版本鎖得很舊，見「限制與注意事項」）：

```bash
conda create -n libero python=3.8.13
conda activate libero
git clone https://github.com/Lifelong-Robot-Learning/LIBERO.git
cd LIBERO
pip install -r requirements.txt
pip install torch==1.11.0+cu113 torchvision==0.12.0+cu113 torchaudio==0.11.0 --extra-index-url https://download.pytorch.org/whl/cu113
pip install -e .
```

下載示範資料集（可選 `libero_spatial`、`libero_object`、`libero_goal`、`libero_100`）：

```bash
python benchmark_scripts/download_libero_datasets.py --datasets libero_spatial --use-huggingface
```

Hugging Face 上的資料集：https://huggingface.co/datasets/yifengzhu-hf/LIBERO-datasets

訓練一個終身學習實驗：

```bash
export CUDA_VISIBLE_DEVICES=0 MUJOCO_EGL_DEVICE_ID=0
python libero/lifelong/main.py seed=0 \
    benchmark_name=LIBERO_SPATIAL \
    policy=bc_transformer_policy \
    lifelong=er
```

訓練時預設會邊訓練邊評估；GPU 不夠時可改用 `libero/lifelong/evaluate.py` 另外評估。`notebooks` 資料夾有任務取用、資料集與自訂任務的範例。

## 適用情境

- 研究終身學習、持續學習與知識轉移（避免災難性遺忘）。
- 評測 VLA 或模仿學習策略：在 LIBERO-Spatial／Object／Goal／Long 上回報成功率，和其他論文直接比較。
- 用 BDDL 自訂新的操作任務，或拿現成示範資料預訓練、微調策略。

## 授權與成本

- 程式碼：MIT License。
- 資料集：CC BY 4.0。
- 免費使用；訓練需要 NVIDIA GPU（官方範例使用 CUDA 11.3），模擬以 EGL 離屏渲染。

## 限制與注意事項

- **依賴版本很舊**：Python 3.8、PyTorch 1.11、numpy 1.22、gym 0.25、transformers 4.21，且鎖定 robosuite 1.4.0（新版 robosuite 介面不相容）。在新系統上常需另開 conda 環境，許多 VLA 專案也會自帶改過的 LIBERO 安裝方式。
- 只有稀疏獎勵，不太適合直接做強化學習。
- 維護節奏放緩：最後一次 push 為 2025-03，沒有正式 release。
- 許多 VLA 在 LIBERO 上的成功率已接近飽和（九成以上），社群另有 LIBERO-Plus、LIBERO-PRO 等擴充版本來測泛化與穩健性；這些衍生版本這次未逐一查證，本條目不展開（資料不足）。

## 相關工具

- [MuJoCo](MuJoCo.md)（底層物理引擎）、robosuite（模擬框架）、robomimic（模仿學習框架）
- 其他機器人操作基準：CALVIN、Meta-World、RLBench、SimplerEnv（以上僅作類別參考）
- 常在 LIBERO 上評測的 VLA：OpenVLA、π0／π0.5（本資料夾的 [ARC](ARC.md) 即以 π0.5 等 VLA 為對象）

## 資料來源

- https://github.com/Lifelong-Robot-Learning/LIBERO
- https://raw.githubusercontent.com/Lifelong-Robot-Learning/LIBERO/master/README.md
- https://raw.githubusercontent.com/Lifelong-Robot-Learning/LIBERO/master/requirements.txt
- https://api.github.com/repos/Lifelong-Robot-Learning/LIBERO
- https://arxiv.org/abs/2306.03310
- https://libero-project.github.io
- https://huggingface.co/datasets/yifengzhu-hf/LIBERO-datasets
