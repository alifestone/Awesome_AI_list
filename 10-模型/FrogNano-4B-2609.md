# FrogNano-4B-2609

- **分類**：模型 / 程式碼模型
- **連結**：https://huggingface.co/microsoft/FrogNano-4B-2609

## 原清單說明

（Microsoft）— 從 Qwen3.5-4B 經 RL 訓練的小型程式代理模型，需搭配 Leaf 工具框架；官方自報 SWE-bench Verified 61.5%。

> 查證結果：與模型卡一致（SWE-bench Verified Avg@3 61.5%，於 Leaf harness 下測得）。補充：模型卡的授權標示前後不一致，見「授權與成本」。

## 概述

FrogNano 是 Microsoft 發布的精簡型「repository 級」程式代理模型，由 Qwen/Qwen3.5-4B 衍生，**只用強化學習**在約 1,500 個合成軟體工程任務上做後訓練（任務由 TaskPilot 生成、驗證並依當前 policy 能力校準）。它透過輕量的五工具 **Leaf harness** 操作：瀏覽程式碼庫、除錯、編輯檔案、跑測試並產出候選 patch。特點是代理專屬後訓練**不使用更強模型的解題軌跡、動作、推理過程或 patch 目標**（即非行為蒸餾）。2026-09-22 發布，定位為研究成果。

## 模型規格

| 項目 | 內容 |
| --- | --- |
| 開發者 | Microsoft |
| 基底模型 | Qwen/Qwen3.5-4B |
| 架構 | Dense 32 層混合 Gated DeltaNet／gated-attention 因果語言模型（視覺元件繼承自基底但未後訓練） |
| 參數量 | 約 4.66B（BF16 權重約 9.3 GB；HF safetensors 統計 4,659,865,088） |
| Context 長度 | 評測設定約 131K tokens（含輸出空間） |
| 每回合最大輸出 | 8,192 tokens（訓練設定；GitHub 評測 preset 中 SWE-bench Pro／Terminal-Bench 為 32,000） |
| 輸入／輸出 | 僅支援文字（含程式碼、工具輸出）；輸出文字、推理、程式碼與結構化工具呼叫 |
| 訓練期間 | 2026 年 6 月–8 月 |

## 核心功能／特色

- 從自然語言 issue 出發，進行 repo 層級的問題解決、跨檔案理解、除錯、修 bug、實作功能。
- 產生 Leaf 工具呼叫；Leaf 只有五個工具：`Read`、`Write`、`Edit`、`Glob`、`Bash`。
- 依指令與測試回饋反覆修改多檔 patch。
- 模型本身不部署變更，只在隔離沙箱中產生候選 patch。

## 訓練方式

- 純 RL 後訓練：約 1,500 個 TaskPilot 合成 SWE 任務環境（每個含 repo 快照、runtime、問題描述、參考 patch、生成的評分測試與既有回歸測試），以可執行測試作為 reward，於完整多回合軌跡上訓練。
- 共五輪 TaskPilot 迭代；前四輪 context 上限 65,536、75 回合工具呼叫，第五輪提升至約 131K、150 回合。
- 合成資料：TaskPilot 用 AI 出題模型從真實 repo 生成問題、參考 patch 與隱藏測試；只保留當前 policy「有時成功、有時失敗」的任務。
- 未使用專門的安全偏好、拒答或對抗資料集。
- 文字訓練資料量標示為「1 billion 到 1 trillion tokens」區間（模型卡原文如此，無精確值）。

## 評測表現（官方自報，Avg@3，Leaf harness，150 步、約 131K context、temperature 0.6）

| Benchmark | 結果 |
| --- | ---: |
| SWE-bench Verified（驗證集） | 61.5%（基底 Qwen3.5-4B 為 39.4%；五輪 RL 依序 49.1 → 53.1 → 56.7 → 59.1 → 61.5） |
| SWE-bench Pro（held-out） | 37.6% |
| Terminal-Bench 2.0（held-out） | 31.1% |
| PatchEval-Verified（held-out） | 47.3% |
| Pass@3（技術報告附錄 C） | SWE-bench Verified 71.0%、SWE-bench Pro 47.6% |

注意：SWE-bench Verified 是訓練過程使用的**驗證集**，而非 held-out 測試集。官方明言未評測一般語言理解、數學、多語能力，不應把 Qwen3.5-4B 的分數套用到 FrogNano。

## 本地執行／使用方式

1. 以支援 Qwen3.5 架構的推論引擎提供 OpenAI 相容端點（官方 rollout 使用 SGLang；上游架構亦相容 Transformers、vLLM、SGLang、KTransformers）。SGLang 需設定 `--reasoning-parser qwen3 --tool-call-parser qwen3_coder`。
2. 安裝 Leaf harness 與評測工具（需要 Python 3.12+ 與一個 **Kubernetes 叢集**作為沙箱）：

```bash
git clone https://github.com/microsoft/FrogNano && cd FrogNano
uv venv --python 3.12 && source .venv/bin/activate
uv pip install -e .

export FROGNANO_MODEL_NAME="your-served-checkpoint"
export FROGNANO_MODEL_BASE_URL="https://your-model-endpoint.example/v1"
export OPENAI_API_KEY="your-endpoint-key"
export KUBE_CONTEXT="your-cluster-context"
export K8S_NAMESPACE="your-existing-namespace"

frognano-eval run --config frognano/configs/eval/swebench-verified.yaml
```

- 評測 preset 取樣：temperature 0.6、top_p 0.95、top_k 20、min_p 0、開啟 thinking。
- 硬體：BF16 權重約 9.3 GB，另需 KV cache；官方表示最低 GPU 與 VRAM 需求「尚待驗證」。CPU、桌面 OS、行動裝置、量化版本**皆未驗證**，目前無官方量化版。

## 適用情境

- 軟體工程研究、長程 coding agent 研究。
- 人類監督下的開發輔助：英文 issue、以 Python 為主、有可執行測試的 repo，在沙箱中產出候選 patch，再由人審查。

## 授權與成本

- **授權標示不一致**：HF 模型卡 YAML metadata 與 GitHub repo（Leaf harness）標示為 **MIT**；但模型卡內文摘要表寫「Apache License 2.0」。使用前建議以 repo 中的 LICENSE 檔或向 Microsoft 確認。
- 成本：開放權重免費；需自備 GPU 推論服務，跑官方評測還需 Kubernetes 環境。

## 限制與注意事項

- 高度依賴 Leaf harness、prompt 格式與執行環境；換 harness 表現可能下降。
- 訓練資料以 Python、英文為主；其他程式語言或自然語言未充分評測。
- 可能誤解需求、幻覺 API、過度修改、引入回歸或安全漏洞；通過測試不代表正確或安全。
- 未經完整產品級紅隊測試，**不應視為已獨立完成安全對齊**，不可給予無限制的自主生產環境權限；建議網路預設關閉、最小權限沙箱、人工審查。
- 影像／影片元件雖繼承自基底，但不支援。

## 相關模型

- Qwen/Qwen3.5-4B（基底）
- TaskPilot（任務生成框架，見技術報告）
- Mellum2（同為小型程式／代理取向模型）

## 資料來源

- https://huggingface.co/microsoft/FrogNano-4B-2609 （README 原始檔）
- https://github.com/microsoft/FrogNano （README）
- https://api.github.com/repos/microsoft/FrogNano （授權 metadata：MIT）
- https://huggingface.co/api/models/microsoft/FrogNano-4B-2609 （參數量與授權 metadata）
