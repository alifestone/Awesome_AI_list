# MotionBricks

- **分類**：機器人與具身智慧 / 動作生成
- **連結**：https://nvlabs.github.io/motionbricks/

## 原清單說明

（NVIDIA，SIGGRAPH 2026）— 即時生成人物與人形機器人動作的模組化潛在生成模型：給最近 4 個姿勢和最多 4 個目標姿勢，模型自己補出中間的動作；搭配「Smart Primitives」組出走路、翻越、坐下等互動，不用重新訓練。

> **查證補充**：
>
> - 來源是 Threads 貼文（@vincent_aidev），引述官方數字：一個神經骨幹涵蓋 35 萬筆以上動作片段、約 15,000 FPS、約 2 ms 延遲。這些數字出自專案頁，屬於作者自行報告。
> - 貼文提到一位日本開發者把 MotionBricks 移植到 WebGPU、用 VRM 角色在瀏覽器裡以方向鍵即時生成動作。這個移植不是官方專案，這次沒有找到它的連結（資料不足）。
> - 專案頁說訓練資料是 35 萬筆 mocap 片段的 BONES-SEED；GitHub 上公開的 v1 checkpoint 則標示用 Bones RigPlay 1（RP1）訓練。兩者的關係，這次讀過的頁面沒有說清楚。

## 概述

MotionBricks 是 NVIDIA 在 ACM Transactions on Graphics（SIGGRAPH 2026）發表的即時動作生成框架，也是 NVIDIA GR00T Whole-Body Control 的動作生成層。同一套模型與 runtime 可以驅動人類骨架（SOMA）和 Unitree G1 人形機器人。

核心想法是把動作生成當成「補間」（inbetweening）：應用程式決定角色要到哪裡、用什麼姿勢到，模型負責生成過程。連續動作則靠一段接一段串起來。

作者：Tingwu Wang、Olivier Dionne（共同第一作者）等 16 人，來自 NVIDIA、ETH Zürich、Simon Fraser University 與 UT Austin。

## 核心功能／特色

- **一個模型涵蓋整個動作資料集**：不需要依任務切分模型或加標籤。
- **Smart locomotion**：用速度、方向與風格指令組出移動，包含走、跑、橫移、蹲行，以及 Skipping、Zombie、受傷、Combat 等六種風格。
- **Smart objects／Smart Primitives**：把「撿劍、坐下、跳過長椅」這類互動描述成擺在物件周圍的目標姿勢，模型補完過程；可零樣本用在新任務。
- **專案頁報告的效能**：約 15,000 FPS、約 2 ms 延遲。
- **UE5 示範**：專案頁有一段 2 分 40 秒未剪輯的 Unreal Engine 5 示範，宣稱所有動作都由神經網路生成，沒有 foot-lock、blending 或手工過渡。
- **官方 repo 內容**（v0.2.0，2026-10-23）：
  - SOMA 與 Unitree G1 的預訓練模型（ONNX 已附在 repo，SafeTensors checkpoint 放在 Hugging Face `nvidia/MotionBricks`）。
  - 建立在 Warp、Newton、TensorRT 上的 Python runtime。
  - 兩個示範：Inbetweener（在你擺的姿勢之間生成動作）、Scene Preview（角色在場景裡走跑、翻越、蹲、坐）。
  - 兩個編輯器：Smart Primitive Editor、Scene Editor。
  - 獨立的 ONNX 匯出工具與 guided tutorial。

## 技術架構或運作原理

1. **輸入**：每次生成以 30 Hz 運作。
   - context：角色最近 4 個姿勢。
   - target：1～4 個目標姿勢。1 個決定終點位置；更多個也決定到達時怎麼動。
2. **三個學習模組**：

   | 模組 | 角色 | 參數量（SOMA） |
   |---|---|---|
   | Root model | 預測轉場長度與根節點路徑 | 40.4M |
   | Pose model | 遮罩式 token transformer（16 層、寬 1024），沿路徑預測動作 token | 136.5M |
   | Pose VQ-VAE | 把 token 解碼成連續動作（5 個 codebook head × 16 codes） | 23.4M |

   checkpoint 合計約 2 億參數。
3. **輸出**：每次 6～16 個 token，每個 token 4 個姿勢，約 0.6～1.9 秒動作；附腳部接觸預測。轉場長度由模型自己決定。
4. **串接**：runtime 播放生成的動作、記錄播過的姿勢，再拿最後 4 個姿勢當下一次的 context。目標從哪來由應用程式決定，因此同一個模型可以變成關鍵影格補間、連續移動或物件互動。

## 安裝與使用方式

需要 NVIDIA GPU（TensorRT）。官方在 Windows 與 Linux x86-64、RTX 4090 上測試。先安裝 Git LFS 與 uv：

```bash
git clone https://github.com/NVlabs/motionbricks.git
cd motionbricks
git lfs pull
uv sync

# 示範與編輯器
uv run python -m app.inbetweener_demo
uv run python -m app.scene_preview --scene assets/scenes/soma_gym.scene.json
uv run python -m app.scene_preview --scene assets/scenes/g1_gym.scene.json
uv run python -m app.smart_primitive_editor
uv run python -m app.scene_editor
```

- 每個模型與精度第一次啟動時會建 TensorRT plan，要幾分鐘，之後快取在 `.trt-cache/`。
- 自行匯出 ONNX：`hf download nvidia/MotionBricks --local-dir checkpoints/MotionBricks`，再用 `tools/onnx` 的 `motionbricks-onnx`（預設 FP32，可加 `--precision fp16`）。

## 適用情境

- 遊戲與互動應用的角色動畫：用目標姿勢取代手工狀態機與 blend tree。
- 人形機器人（Unitree G1）的動作生成與模擬；實機控制要搭配 GR00T Whole-Body Control 等控制器。
- 動作補間、關鍵影格動畫的原型製作。
- 研究即時生成式動作模型與動作 tokenization。

## 授權與成本

- **程式碼**：Apache-2.0。
- **模型**（SOMA、G1 checkpoint 與 ONNX）：NVIDIA Open Model Agreement，允許商用與再散布修改後的模型，但須遵守協議條款。
- **範例動作檔**（Bones 衍生的 BVH 與 G1 CSV）：NVIDIA Sample Data Evaluation License，只限內部評估與測試 NVIDIA 技術。
- **文件與媒體**：CC BY 4.0。
- 成本：免費，但需要 NVIDIA GPU；TensorRT runtime 套件另受 NVIDIA TensorRT 授權約束。

## 限制與注意事項

- 15,000 FPS、2 ms 等效能數字是作者自行報告，這次沒有找到測量的硬體條件（資料不足）。
- 不含訓練流程，只能用官方預訓練模型；GR00T Whole-Body Control 裡的預覽版另有合成資料訓練流程。
- 模型卡寫明：生成的動作**沒有經過實體機器人控制的驗證**。
- 範例動作檔不能拿去商用。
- 只支援 SOMA（30 關節）與 Unitree G1 兩種骨架；其他角色要先 retarget。
- repo 目前不接受外部貢獻。

## 相關工具

- GR00T Whole-Body Control／GEAR SONIC（NVIDIA 人形機器人行為基礎模型，MotionBricks 最早以 G1 預覽版放在這裡）
- Kimodo、ARDY（NVIDIA 的離線／即時動作生成模型，可產生 MotionBricks 的目標姿勢）
- SOMA Body Model、SOMA Retargeter、BONES-SEED 資料集、ProtoMotions
- [MuJoCo](MuJoCo.md)（機器人模擬）
- [Unreal Engine MCP](../13-遊戲引擎-×-Agent/Unreal-Engine-MCP.md)（遊戲引擎整合）

## 資料來源

- https://nvlabs.github.io/motionbricks/
- https://github.com/NVlabs/motionbricks
- https://github.com/NVlabs/motionbricks/blob/main/docs/soma_model.md
- https://arxiv.org/abs/2604.24833
- https://huggingface.co/nvidia/MotionBricks
- https://www.threads.com/@vincent_aidev/post/DfJLy_sCSaO
