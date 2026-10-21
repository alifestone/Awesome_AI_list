# Train LLM From Scratch

- **分類**：學習資源 / 課程 / 教材
- **連結**：https://github.com/FareedKhan-dev/train-llm-from-scratch
- **文件網站**：https://fareedkhan-dev.github.io/train-llm-from-scratch/

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：repo 標語為 *A straightforward method for training your LLM, from downloading data to generating text.* 作者 Fareed Khan，以純 PyTorch 從零實作 Transformer，並一路寫到 SFT、獎勵模型、PPO／DPO／GRPO 等後訓練。MIT 授權。查詢當下（2026-10-21）約 1.24 萬顆星、1,717 個 fork，最後一次 push 為 2026-10-02；最新版本為 CHANGELOG 中的 0.2.0（2026-10），沒有發布 GitHub release。

## 概述

一開始只是一篇預訓練教學，現在擴充成從原始文字到「對齊過、會推理格式」模型的完整流程：

```
原始文字 → token → Transformer → next-token loss → base model
base model → SFT → 獎勵模型 → {PPO, DPO} → GRPO → 評測與對話
```

每個演算法都用純 PyTorch 手寫，刻意不用 `trl`、`peft`、`transformers`。README 本身就是主要教材：每段程式碼前先用白話解釋做什麼、為什麼，之後多半附上預期輸出。作者把讀者分成三類：學生從頭讀到尾、開發者直接照指令跑、研究者看後訓練那一半。

repo 建立於 2025-01-12。0.2.0 版加入了「筆電 CPU 也能跑」的路線、與原始模型並列的現代架構，以及 2023 年後常見的訓練與推論技巧。

## 核心功能／特色

- **兩種模型架構，每個階段都能選**（`--arch modern`）：
  - 原始版：依《Attention is All You Need》拆成 MLP、單頭／多頭注意力、Transformer block、完整模型逐步組裝。
  - 現代版：RoPE、RMSNorm、SwiGLU、GQA／MQA、DeepSeek 的 MLA、QK-norm、滑動視窗注意力、KV cache、MoE（含平衡 loss 與共享專家）。
- **後訓練全手寫**：SFT（可加 LoRA）、Bradley-Terry 獎勵模型、含 GAE 的 PPO、DPO／ORPO／KTO／IPO／SimPO、GRPO（含 Dr. GRPO、DAPO、GSPO 選項）。
- **其他從零實作**：byte-level BPE tokenizer、Muon optimizer、cosine／WSD／linear 學習率排程、top-p／min-p 抽樣、speculative decoding、int8 權重量化。
- **沒有 GPU 也能開始**：`tiny` preset（36.9 萬參數）在筆電 CPU 上約 5 分鐘訓練完，能寫出簡單的英文小故事；另有 `student`、`small`、`13m`、`77m`、`3b` 等尺寸。
- **統一評測**：每個階段都用貪婪解碼的 GSM8K 準確率比較（從 `<answer>` 標籤取數字對答案）。
- **Streamlit 控制台**：每階段一頁（Data、Pretrain、SFT、Reward、DPO、PPO、GRPO、Evaluate、Chat），可以點按啟動訓練、看即時 loss、評測與對話。
- **文件網站**：每階段有理論、圖解與對應程式碼；另有 Foundations（斷詞、注意力、目標函數、最佳化、規模估算）、Modern LLM、筆電路線三個區塊。
- **型別與測試**：設定檔有型別檢查（打錯 key 會提示正確名稱），用 jaxtyping 標註張量形狀；約 170 個 pytest，CI 在 Linux／Windows／macOS 上跑 mypy、ruff 與端對端訓練測試。

## 課程／教材結構

README 分為 7 步，每步對應 `docs/` 的一頁：

| 步驟 | 主題 | 內容 |
|---|---|---|
| 1 | 準備資料 | The Pile 預訓練文字（HDF5）、Alpaca／Dolly／GSM8K 指令資料、HH-RLHF／UltraFeedback 偏好資料、GSM8K RL 提示；tokenizer 用 tiktoken `r50k_base` |
| 2 | 組裝模型 | MLP → 單頭注意力 → 多頭注意力 → Transformer block → 完整模型，再對照現代版 |
| 3 | 預訓練 base model | 訓練迴圈、loss 曲線、`--amp`／`--grad-checkpointing`／`--grad-accum` 省記憶體 |
| 4 | 生成文字 | 從 checkpoint 讀取模型尺寸後抽樣 |
| 5 | 後訓練 | SFT、獎勵模型、DPO／ORPO／KTO、PPO、GRPO／RLVR |
| 6 | 評測 | 各階段 GSM8K 準確率對照表 |
| 7 | 對話 | `scripts/chat.py` 與任一階段的 checkpoint 對話 |

另有 `sft_rlhf_guide.ipynb` notebook。

## 安裝與使用方式

```bash
git clone https://github.com/FareedKhan-dev/train-llm-from-scratch.git
cd train-llm-from-scratch
pip install -e .            # 或 uv sync
pip install -e ".[all]"     # 選用：資料下載、wandb、Streamlit、文件網站
```

沒有 NVIDIA GPU 的 Linux 建議先裝 CPU 版 PyTorch。筆電路線三行指令：

```bash
python scripts/prepare_tiny_data.py
python scripts/train_transformer.py --preset tiny --arch modern
python scripts/generate_text.py --model_path models/tiny.pt
```

base model 預訓練完、資料準備好之後，`bash scripts/run_posttraining.sh` 一次跑完整個後訓練鏈（預設用 torchrun，`NPROC=1` 為單 GPU）。每階段另有 `configs/smoke/` 小設定，幾秒內跑完，方便檢查。

## 適用情境

- 想親手從零寫一次 LLM、理解每個元件與訓練步驟，而不是呼叫現成函式庫的人。
- 想看 SFT、獎勵模型、PPO、DPO、GRPO 實際怎麼寫、彼此差在哪的研究者或學生。
- 手邊只有筆電、想先跑起來一個小模型的初學者。

## 授權與成本

- **MIT**，免費。
- 筆電路線只需 CPU；13M 模型用免費 Colab／Kaggle T4 即可；十億參數級需要 24 GB 以上顯卡（README 列 A100、RTX 4090／3090 可跑 2B）。
- 預訓練資料 The Pile 下載量大，需預留磁碟空間與時間。

## 限制與注意事項

- 定位是教學，訓練出的小模型能力有限：13M 模型輸出的是文法通順但語意混亂的英文。README 的 GSM8K 對照表沒有附作者的數字，要自己跑。
- 需要 OOP、神經網路與 PyTorch 基礎，README 開頭附有入門影片。
- README 的 GPU 對照表（各卡能訓練的最大模型）是作者估計值；RTX 5090 一列標明只驗證過 13M。
- TPU（PyTorch/XLA）路徑是實驗性的，作者標明未經測試。
- 教材為英文。

## 相關工具

- [50 ML Projects to Understand LLMs](ML4LLM-Book.md)：分析現成模型的內部機制；本條目則是自己從零訓練。
- [Unsloth](../11-推論與訓練引擎/Unsloth.md)：想在實務上微調現成模型時用的訓練框架。
- [QwenGyre](../11-推論與訓練引擎/QwenGyre.md)：資料中心等級的 agent RL 訓練論文，可對照本條目的小規模 GRPO 實作。

## 資料來源

- https://github.com/FareedKhan-dev/train-llm-from-scratch
- https://github.com/FareedKhan-dev/train-llm-from-scratch/blob/main/CHANGELOG.md
- https://fareedkhan-dev.github.io/train-llm-from-scratch/
