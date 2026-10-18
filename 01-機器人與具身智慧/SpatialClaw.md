# SpatialClaw

- **分類**：機器人與具身智慧 / 研究
- **連結**：https://github.com/NVlabs/SpatialClaw

## 原清單說明

（NVIDIA，NeurIPS 2026）— 以「寫程式」當動作介面的空間推理 agent：VLM 在持久 Jupyter kernel 裡呼叫 SAM3、Depth-Anything-3 等感知工具，免訓練。

> **查證補充**：
>
> - GitHub 標題與專案頁都標示「NeurIPS 2026」，但兩處都沒有明確寫出「已被接受」。
> - README 的 BibTeX 則把它列為「arXiv preprint」（2026），沒有附 arXiv 編號。
> - 作者來自 NVIDIA 與 KAIST AI，並非全部是 NVIDIA。

## 概述

SpatialClaw 是一篇 agentic 空間推理論文的官方實作。核心主張是「Code is the right action interface for spatial reasoning agents」：讓以 VLM 為核心的 agent 在持久的 Jupyter kernel 中撰寫 Python，組合各種感知模組、檢查中間結果，並在多個步驟間修正分析策略。

作者群主張：工具增強型 agent 的能力，取決於工具「能如何組合」，而不只是「有哪些工具」。這個方法不需要訓練，也不針對特定基準或模型做調整。

作者：Seokju Cho、Ryo Hachiuma、Abhishek Badki、Hang Su、Byung-Kwan Lee、Chan Hee Song、Sifei Liu、Subhashree Radhakrishnan、Seungryong Kim、Yu-Chiang Frank Wang、Min-Hung Chen。所屬機構為 NVIDIA 與 KAIST AI；Cho 的部分是在 NVIDIA 實習期間完成。

## 核心功能／特色

- **以程式碼當動作介面**：每一步寫一個 Python cell，可以自由組合工具輸出，不受固定 tool-call 格式限制。
- **預載感知工具**：
  - SAM 3：分割。
  - Depth Anything 3：深度與重建。
  - 幾何工具函式，以及 NumPy、SciPy（如 `scipy.spatial`、`KDTree`）、Matplotlib。
- **免訓練**：所有基準與骨幹模型都用同一套系統提示、工具集與超參數。
- **作者報告的成績**：
  - 在 20 個空間推理基準上平均準確率 59.9%，比先前最佳的空間 agent 高 11.2 pp。
  - 以 Gemma 4-31B 為骨幹時，20 個基準中有 19 個進步，平均比無工具基線高 6.5 pp。
  - 跨 6 個骨幹的平均增益介於 +3.1 pp（Qwen 3.5-397B-A17B）到 +7.7 pp（Qwen 3.6-27B）。
  - 單項增益最大的基準：DSI-Bench +17.6 pp、MindCube +15.3 pp、MMSI +13.4 pp。
- **動作介面消融**（Gemma 4-31B）：

  | 動作介面 | 平均分數 |
  |---|---|
  | 無工具基線 | 53.4 |
  | 單次程式碼（single-pass code） | 55.2 |
  | 結構化 tool-call | 56.7 |
  | SpatialClaw | 59.9 |

- **比較對象**（皆為 Gemma 4-31B）：

  | 方法 | 類型 | 平均分數 |
  |---|---|---|
  | VADAR | 單次 | 40.5（僅單張影像基準） |
  | pySpatial | 單次 | 47.8 |
  | SpaceTools-Toolshed | tool-call | 48.7 |

## 技術架構或運作原理

1. **五階段迴圈**：
   1. planner 擬定策略。
   2. 主 VLM 撰寫一個 cell。
   3. 用 AST 檢查 cell 的安全性。
   4. 執行 cell。
   5. 輸出（stdout、新變數、`show()` 產生的影像）回饋到下一步。

   最後 agent 以 `ReturnAnswer(...)` 提交答案。
2. **執行期元件**：
   - LangGraph 工作流程
   - 持久 Jupyter kernel
   - AST 安全檢查
   - 規劃與反思迴圈
   - FastAPI GPU 工具伺服器
   - vLLM 自動探索與負載平衡
   - SLURM 啟動管理器（可自動重啟的 chain job）
3. **支援的骨幹 VLM**：Qwen3.5／3.6 與 Gemma4 兩個家族共 6 個模型，參數量 26B～397B。範例設定檔中也出現 Gemini-3-pro。
4. **評測基準**（共 20 個）：
   - 單張影像：ERQA、Omni3D、OmniSpatial、SPBench
   - 多視角：MindCube、MMSI、SPAR-Bench
   - 一般空間：BLINK、SpatialTree、ViewSpatial
   - 影片／4D：MMSI-Video、OSI-Bench、PAI-Bench、VSI-Bench-U、VSTI-Bench、DSI-Bench
   - 一般影片：CV-Bench、PerceptComp、Video-MME、Video-MME-v2

## 安裝與使用方式

```bash
git clone --recursive https://github.com/NVlabs/SpatialClaw.git
cd SpatialClaw
bash spatial_agent/scripts/setup.sh   # 約 15–30 分鐘
cp .env.example .env                  # 填入 API key；若使用自架 vLLM 則不需 key
```

單機執行範例：

```bash
python -m spatial_agent.entrypoints.run \
  --dataset spatial_agent/config/dataset/erqa.json \
  --model spatial_agent/config/model/<模型設定檔> \
  --concurrency 4
```

- 在 SLURM 上執行前，必須先下載好模型權重。
- 安裝、實驗、監控、設定、架構與疑難排解等文件都在 `docs/`。

## 適用情境

- 圖片、多視角、影片與 4D 場景中的空間推理問答（距離、方位、視角轉換、動態關係等）。
- 研究 VLM agent 的「動作介面設計」，例如比較程式碼與結構化 tool-call。
- 想在不微調模型的情況下，替既有 VLM 加上幾何與感知工具，提升空間理解能力。

## 授權與成本

- 採 **NVIDIA Source Code License-NC**（Copyright © 2026 NVIDIA Corporation），屬非商業授權。
- 安裝時下載的第三方專案各有授權，位於 `tools/third_party/<repo>/LICENSE`。
- 成本：
  - 骨幹 VLM 為 26B～397B 參數，需要自架 vLLM（GPU）或使用 API。
  - 感知工具也需要 GPU 工具伺服器。
  - 具體的硬體需求，這次讀過的頁面沒有列出（資料不足）。

## 限制與注意事項

- 非商業授權（-NC），不能直接用於商業產品。
- 安裝流程較重：需要 submodule，setup 要 15–30 分鐘，大規模實驗需要 SLURM 叢集與預先下載的權重。
- 成績都是作者自行報告。會議接受狀態沒有明確說明，也沒有提供 arXiv 編號。
- 屬於空間推理問答研究，並非直接控制機器人的系統。用在具身任務時需要自行整合。

## 相關工具

- SAM 3（Meta，分割）
- Depth Anything 3（深度與重建）
- LangGraph、vLLM、Jupyter
- 其他空間 agent：VADAR、pySpatial、SpaceTools

## 資料來源

- https://github.com/NVlabs/SpatialClaw
- https://spatialclaw.github.io/
