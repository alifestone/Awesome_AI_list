# Bonsai 2

- **分類**：模型 / 本地可跑的通用 / 推理模型
- **連結**：https://huggingface.co/collections/prism-ml/bonsai-2

## 原清單說明

（PrismML）— Qwen3.8-27B 的三值（ternary）壓縮版，體積約為原本 1/9、保留約 98% 表現，可在本機跑。Apache 2.0。

> 查證結果：與官方模型卡一致。官方數字為「約 9.3 倍縮小（理想值；實際 GGUF 檔約 9.0 倍）」、「保留 98.2% FP16 表現」。補充：需使用 PrismML 自家的 llama.cpp／MLX 分支，**原生 llama.cpp 無法執行**。

## 概述

Bonsai 2（正式模型名 Ternary-Bonsai-2-27B，官方亦稱 Bonsai 2 27B）是 Prism ML 於 2026 年 9 月發布的 27B 級推理模型，由 Qwen3.8-27B 衍生，架構不變，但把語言模型權重轉為三值 {−1, 0, +1} 格式（每 128 個權重共用一個 FP16 縮放係數），讓 27B 模型縮到約 5.9–7.2 GB，可在一般筆電或單張消費級 GPU 上執行。保留思考（thinking）、工具呼叫與影像輸入能力。

HuggingFace collection 目前包含：
- `prism-ml/Ternary-Bonsai-2-27B-gguf`（llama.cpp 用，CUDA / Metal / CPU）
- `prism-ml/Ternary-Bonsai-2-27B-mlx-2bit`（Apple Silicon MLX 用）
- `prism-ml/Ternary-Bonsai-2-27B-gguf-dev`（開發用 Q2_0 版）
- Space：`webml-community/ternary-bonsai-2-webgpu-kernels`（在瀏覽器以 WebGPU 執行）

## 模型規格

| 項目 | 內容 |
| --- | --- |
| 基底模型 | Qwen/Qwen3.8-27B（混合注意力，架構不變） |
| 參數量 | 共 27.36B：語言骨幹 24.35B（64 blocks）＋ embedding/LM head 2.54B ＋ 視覺塔 0.46B |
| 架構 | 混合注意力（約 75% 線性注意力／25% 全注意力）、SwiGLU MLP、RoPE、RMSNorm |
| Context 長度 | 262K tokens（繼承自基底模型） |
| 權重格式 | Ternary g128：{−1, 0, +1} ＋ 每 128 權重一個 FP16 scale；整體 1.72 bits/weight |
| 權重基底 | 區塊 Hadamard 旋轉（block 1024）預先折入權重，執行時對 activation 套用對應轉換 |
| 低位元覆蓋 | Embedding、注意力投影、MLP 投影、LM head（僅約 26.2M 參數，即線性注意力的遞迴狀態路徑與 norm 權重，保留較高精度） |
| 視覺塔 | 另附 mmproj（Q8_0 約 0.63 GB；BF16 參考版約 0.93 GB），只有影像輸入時才需載入 |
| 部署大小 | GGUF PTQ1_0：5.95 GB（1.75 bpw）；GGUF PQ2_0：7.21 GB（2.13 bpw）；FP16 原版約 54 GB |

## 核心功能／特色

- 27B 級推理模型以約 6–7 GB 執行，官方稱「真正的」1.72 bits/weight（不靠高精度的例外層）。
- 保留思考模式、程式能力與 agentic 工具呼叫；預設推理強度為 `xhigh`，可改用 `medium`；`low` 不支援（選了會接近 `xhigh` 行為）。
- 兩種 GGUF 打包：**PTQ1_0**（緊密三值，最省記憶體）與 **PQ2_0**（每個三值放 2-bit 槽，解包較便宜）。官方說明 PQ2_0 在 H100、A100、Blackwell 上解碼較快、prompt 處理全面較快；PTQ1_0 在 Ada 世代與 L4 上解碼較快。
- 支援影像輸入（需 mmproj）。
- 另有 MLX 版本供 Apple Silicon 使用，以及可在瀏覽器以 WebGPU 執行的 Space。

## 訓練或壓縮方式

模型卡說明的是**權重表示法**：三值 g128 格式、在旋轉（Hadamard）基底中儲存、執行時對 activation 套用對應轉換。至於如何從 FP16 權重得到三值權重（例如是否經量化感知訓練、蒸餾或其他流程），模型卡與 demo README 未說明，官方指向白皮書（`bonsai-2-27b-whitepaper.pdf`），本條目未讀取白皮書內容 → **訓練流程：資料不足**。

## 評測表現（官方自報）

以下皆為 Prism ML 自行以 EvalScope + vLLM 在 H100、思考模式下測得，非第三方驗證：

| 版本 | 實際 bpw | 大小 | 14 項平均 | 相對 FP16 |
| --- | ---: | ---: | ---: | ---: |
| Qwen3.8-27B FP16 | 16.0 | 54 GB | 86.32 | 100% |
| Qwen3.8-27B UD-Q4_K_XL | 5.2 | 17.6 GB | 85.18 | 98.7% |
| Qwen3.8-27B IQ2_XXS | 2.16 | 7.27 GB | 72.59 | 84.1% |
| **Bonsai 2 27B** | **1.72** | **5.95 GB** | **84.78** | **98.2%** |

分類別（FP16 → Bonsai 2）：知識與推理 85.55 → 79.86；數學 97.06 → 96.57；程式 89.07 → 89.42；指令遵循 81.25 → 82.66；工具呼叫（BFCL v3）76.74 → 74.92；視覺 71.36 → 66.19。
部分單項：AIME26 95.83、LiveCodeBench 90.07、MMLU-Redux 89.09、MMMU-Pro 75.49。

速度（官方 llama-bench，batch 1）：RTX 5090 PQ2_0 約 129.9 tok/s；RTX 4090 PTQ1_0 約 91.1 tok/s；L4 約 30 tok/s；Apple M5 Pro（Metal）約 28 tok/s；M5 Max 約 47 tok/s（M5 Max／M4 Pro 數據為舊版 pre-rotation build 量測，官方註明待重測）。

## 本地執行／使用方式

**必須使用 PrismML 的 llama.cpp 分支**（原生 llama.cpp 會拒絕 PQ2_0／PTQ1_0；載入 Q2_0 不會報錯但會輸出亂碼）。

```bash
# 建置 fork（或從 https://github.com/PrismML-Eng/llama.cpp/releases 下載預編譯版）
git clone https://github.com/PrismML-Eng/llama.cpp && cd llama.cpp
cmake -B build -DGGML_CUDA=ON && cmake --build build -j   # macOS 拿掉 -DGGML_CUDA=ON

hf download prism-ml/Ternary-Bonsai-2-27B-gguf Ternary-Bonsai-2-27B-PQ2_0.gguf --local-dir .

./build/bin/llama-cli -m Ternary-Bonsai-2-27B-PQ2_0.gguf \
    -ngl 99 -fa on -c 32768 \
    --temp 1.0 --top-p 0.95 --top-k 20 --min-p 0.05 \
    -p "Explain quantum computing in simple terms." -n 16384
```

- 推薦取樣：思考模式 `temperature=1.0, top_p=0.95, top_k=20, min_p=0.05`；非思考模式 `temperature=0.7, top_p=0.80, top_k=20, presence_penalty=1.5`。
- `-n` 要給足（例如 16384），否則思考尚未結束就被截斷。
- 一鍵安裝：官方 demo repo `PrismML-Eng/Bonsai-demo` 的 `./setup.sh` 會下載 fork 二進位檔、模型（預設 PQ2_0＋視覺投影，約 7.8 GB）與 Open WebUI；官方稱此 repo 為執行方式的「唯一準據」。
- Apple Silicon：`hf download prism-ml/Ternary-Bonsai-2-27B-mlx-2bit`，須使用套件內附的 `runtime/` 載入器（一般 MLX loader 會產生錯誤輸出而不報錯）。
- Ollama／LM Studio 內建的 llama.cpp／MLX runtime 是否可用：官方未表示支援，且說明需專用 runtime → 實務上不建議直接載入。

## 適用情境

- 筆電本機跑 27B 級 agent／推理（官方舉例：長文件分析、整個 repo 的程式工作，搭配 262K context）。
- 隱私敏感或離線環境。
- 單張消費級或入門資料中心 GPU 上提供 27B 級服務。

## 授權與成本

- 授權：Apache 2.0（模型卡標示）。
- 成本：開放權重免費下載；硬體需求約 6–8 GB 記憶體放模型（另加 KV cache；官方 demo 說明 FP16 KV cache 約 64 KiB/token，100K context 約 6.3 GiB）。

## 限制與注意事項

- 與 FP16 相比仍有落差，主要集中在知識推理（MuSR 79.63 → 70.63）與視覺（OCR Bench v2 60.99 → 56.88）。
- 依賴自家 fork；上游 llama.cpp 整合仍在進行（截至 2026-09-25，部分 PR 已合併、部分仍開啟），PQ2_0／PTQ1_0 為 fork 專屬格式。
- PTQ1_0 解包需額外運算，在 Ampere／Hopper／Blackwell 上解碼反而較慢。
- 所有評測與效能數字均為官方自報。
- 官方另有 KNOWN_ISSUES.md 列出已知問題。

## 相關模型

- Qwen/Qwen3.8-27B（基底）
- 前一代 Ternary Bonsai 27B、Bonsai 1-bit 系列（27B／8B／4B／1.7B，見 Bonsai-demo 的 Bonsai 1 指南）
- 其他低位元方案：Unsloth UD-Q4_K_XL、IQ2_XXS（模型卡中的比較對象）

## 資料來源

- https://huggingface.co/collections/prism-ml/bonsai-2 （透過 https://huggingface.co/api/collections/prism-ml/bonsai-2 讀取）
- https://huggingface.co/prism-ml/Ternary-Bonsai-2-27B-gguf （README）
- https://huggingface.co/prism-ml/Ternary-Bonsai-2-27B-mlx-2bit （README）
- https://github.com/PrismML-Eng/Bonsai-demo （README）
