# DeepInfer

- **分類**：推論與訓練引擎
- **連結**：https://github.com/deepseek-ai/DeepInfer

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：DeepSeek 官方開源的推論框架，是 DeepSeek 自家大規模線上服務背後的引擎。這次開源的版本只提供**離線推論**，且需要資料中心等級硬體，不是給家用 PC 的本地推論工具。

## 概述

DeepInfer 是 DeepSeek-AI 用來支撐大規模生產服務的高效能推論框架，開源版保留了大規模部署所需的核心功能。目前只支援 DeepSeek-V4.1-Flash 一個模型，硬體限 NVIDIA SM100（Blackwell 資料中心 GPU）與華為昇騰 Ascend 950 NPU。最初主要建立在 vLLM 之上，另參考 SGLang 與 TensorRT-LLM。

repo 於 2026-10-16 建立，查詢當下（2026-10-21）約 10.7k 顆星，尚無 release。

## 核心功能／特色

- **最佳化 kernel**：整合 DeepSeek 自家的 FlashMLA、DeepGEMM、DeepEP、TileKernels、DeepSelect，以及自訂 TileLang kernel。
- **平行化**：Attention DP／平衡式 CP（context parallel）、MoE EP（expert parallel）＋ EPLB 負載平衡。
- **DSpark 與信心排程驗證**：用草稿 token 加速解碼，依信心估計排程驗證（`DEEPINFER_ENABLE_MTP_VARLEN=1`；`DEEPINFER_USE_NEXTN_DECODE` 控制最大草稿長度，預設 5）。
- **SWA bounded replay**：decoder prefill 只重播有限長度的尾段，減少計算。
- **非同步排程**：CPU 排批次與裝置執行重疊（預設開啟）。
- **Batch-invariant 推論與決定性取樣**：不同批次組合下結果一致；相同輸入與取樣參數得到相同輸出（僅 NVIDIA）。
- **結構化輸出**：以 regex、JSON schema 或 EBNF 文法限制生成。

## 安裝與使用方式

需求：Linux、GCC ≥ 13、Python 3.12、CUDA 13（NVIDIA）或 CANN 9.2（Ascend）。

```bash
# 在空的 Python 3.12 環境中；昇騰平台改用 ascend
export DEEPINFER_ACCELERATOR=nvidia
./build.sh

# 第一次執行會把 deepseek-ai/DeepSeek-V4.1-Flash-1017 下載到 Hugging Face 快取
# 已有本地權重可設 DEEPINFER_HF_MODEL_DIR=/path/to/DeepSeek-V4.1-Flash-1017
python examples/offline_inference.py
```

官方效能基準：prefill 用 4 張 SM100、decode 用 64 張 SM100 量測（各自在同一個 scale-up domain 內），可用 `examples/sweep/run_sweep.sh` 重現。

## 適用情境

- 有 Blackwell 或昇騰 950 叢集，想自架 DeepSeek-V4.1-Flash。
- 研究 DeepSeek 生產級推論的做法：MoE 專家平行、推測解碼、決定性推論等。

## 授權與成本

- **授權**：Apache-2.0。模型 DeepSeek-V4.1-Flash-1017 在 Hugging Face 標示 MIT。
- **成本**：軟體免費；硬體門檻極高（資料中心 GPU／NPU，多卡）。

## 限制與注意事項

- ⚠️ **不是完整推論服務**：官方明說這次未包含 KV cache 系統、VE／Prefill／Decode 分離部署（引擎大部分功能已實作）、跨資料平行副本的負載平衡。目前只能跑離線推論。
- 只支援 DeepSeek-V4.1-Flash 一個模型。
- 只支援 NVIDIA SM100 與 Ascend 950，消費級顯卡跑不了。
- 非常新（2026-10-16 才開源），尚無正式 release。

## 相關工具

- [Strata](Strata.md)、[Janas](Janas.md)：在消費級硬體上跑大型 MoE 模型的本地引擎，定位和 DeepInfer 正好相反
- [Unsloth](Unsloth.md)：本地執行與微調

## 資料來源

- https://github.com/deepseek-ai/DeepInfer （README）
- https://api.github.com/repos/deepseek-ai/DeepInfer （星數、建立時間、授權）
- https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash-1017 （模型授權）
