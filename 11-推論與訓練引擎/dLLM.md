# dLLM

- **分類**：推論與訓練引擎
- **連結**：https://github.com/ZHZisZZ/dllm

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：專門給**擴散語言模型**（diffusion language model，一次並行「去遮罩」多個 token，而不是自迴歸地一個接一個生成）用的訓練、推論與評測函式庫，不是一般 LLM 的推論引擎。附技術報告 [arXiv:2602.22661](https://arxiv.org/abs/2602.22661)。

## 概述

dLLM 把擴散語言模型的訓練與評測整合成一套 Python 函式庫：訓練建立在 Hugging Face `transformers` 的 Trainer 上，評測建立在 EleutherAI 的 `lm-evaluation-harness` 上，推論則由統一的 sampler 處理。repo 為 LLaDA、Dream 等開源權重模型提供最小可用的訓練／推論／評測範例，也實作了 MDLM（遮罩擴散）、BD3LM（區塊擴散）、Edit Flows 等訓練演算法。

作者為 Zhanhui Zhou、Lingjie Chen、Hanghang Tong、Dawn Song。repo 於 2025-09-14 建立，查詢當下（2026-10-23）約 2.7k 顆星，最後一次 commit 為 2026-04-15。

## 核心功能／特色

- **支援模型**：LLaDA／LLaDA-MoE（預訓練、微調、評測）、LLaDA2.0／LLaDA2.1（推論）、Dream（預訓練、微調、評測）。
- **AR → 擴散（A2D）**：把任意自迴歸模型（Qwen、LLaMA、GPT-2 等）微調成用遮罩擴散或區塊擴散生成文字；官方釋出 Tiny-A2D 系列（0.5B／0.6B，基於 Qwen3-0.6B、Qwen2.5-Coder-0.5B），並自稱為同尺寸 SOTA。
- **BERT-Chat**：把 BERT、RoBERTa、ModernBERT 等編碼器微調成能用擴散方式對話的輕量聊天模型（已釋出 ModernBERT-base／large-chat）。
- **Edit Flows**：教學用參考實作，讓擴散模型多出插入、刪除、替換等編輯操作。
- **Fast-dLLM 加速**（2026-02）：用快取與信心門檻解碼加速 LLaDA、Dream 的推論與評測。
- **強化學習**（2026-04）：支援 diffu-GRPO，已在 LLaDA 與 Tiny-A2D 上以 GSM8K、MATH、Countdown、數獨、程式五種推理任務驗證。
- **分散式訓練**：LoRA、4-bit 量化、DeepSpeed ZeRO-1/2/3、FSDP、DDP；可本機用 `accelerate` 或丟到 Slurm 叢集跑。

## 安裝與使用方式

```bash
conda create -n dllm python=3.10 -y
conda activate dllm
conda install cuda=12.4 -c nvidia
pip install torch==2.6.0 torchvision==0.21.0 torchaudio==2.6.0 \
    --index-url https://download.pytorch.org/whl/cu124
pip install -e .

# （選用）評測環境
git submodule update --init --recursive
pip install -e "lm-evaluation-harness[ifeval,math]"
```

```bash
# 互動式聊天
python -u examples/llada/chat.py --model_name_or_path "GSAI-ML/LLaDA-8B-Instruct"

# 用 LoRA + 4-bit 在 8 張 GPU 上 SFT（ZeRO-2）
accelerate launch --config_file scripts/accelerate_configs/zero2.yaml \
    examples/llada/sft.py --num_train_epochs 4 --load_in_4bit True --lora True
```

各模型與演算法的完整範例在 `examples/` 下（`llada`、`dream`、`a2d`、`bert`、`editflow`、`fastdllm`、`rl` 等）。

## 適用情境

- 研究或教學擴散語言模型，想要一套能從訓練一路到評測的乾淨範例。
- 把手上的小型自迴歸模型或 BERT 改造成擴散模型做實驗。
- 在同一套 `lm-evaluation-harness` 流程下比較 LLaDA、Dream 等擴散模型。

## 授權與成本

- 程式碼為 **Apache-2.0**。
- 使用的模型權重（LLaDA、Dream 等）各自適用原始授權。
- 免費；訓練與評測需要 NVIDIA GPU（範例以 CUDA 12.4、多卡為主）。

## 限制與注意事項

- 只處理擴散語言模型，不能拿來跑一般的自迴歸 LLM 推論；也沒有 OpenAI 相容 API 之類的服務端。
- LLaDA2.0／2.1 目前只有推論範例，沒有訓練。
- 範例偏向多 GPU 與 Slurm 叢集；在單張消費級顯卡上能做的主要是小模型（Tiny-A2D、BERT-Chat）或 LoRA + 4-bit 微調。
- Tiny-A2D 的「SOTA」為作者自稱。
- 最後一次 commit 為 2026-04，近半年沒有新進度。

## 相關工具

- [Unsloth](Unsloth.md)：一般自迴歸 LLM 的微調與 GRPO 訓練框架。

## 資料來源

- https://github.com/ZHZisZZ/dllm （README；2026-10-23 查詢時約 2.7k 星、32 commits）
- https://arxiv.org/abs/2602.22661 （技術報告）
- https://huggingface.co/dllm-hub （釋出的模型）
