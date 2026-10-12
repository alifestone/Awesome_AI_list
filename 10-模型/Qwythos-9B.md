# Qwythos-9B

- **分類**：模型 / 本地可跑的通用 / 推理模型
- **連結**：https://huggingface.co/empero-ai/Qwythos-9B-Claude-Mythos-5-1M-GGUF

## 原清單說明

（Empero AI）— 以 Qwen3.5-9B 為底後訓練的推理模型，提供 GGUF，可用 Ollama / LM Studio 跑。

> 查證結果：大致一致。補充：(1) 模型卡同時稱基底為「深度去審查（deeply uncensored）的 Qwen3.5-9B」，但 metadata 只標 `Qwen/Qwen3.5-9B`，實際用的是哪個去審查版本未說明；(2) 模型刻意**去審查**；(3) 名稱中的「Claude Mythos」指訓練資料來源，**並非 Anthropic 官方模型或合作產品**；(4) 支援 1M context 與影像輸入（視覺塔未經微調）。

## 概述

Qwythos-9B（完整名稱 Qwythos-9B-Claude-Mythos-5-1M）是 Empero（empero.org）發布的 9B 推理模型，以 Qwen3.5-9B 全參數 SFT，訓練資料為超過 5 億 tokens 的「Claude Mythos 與 Claude Fable」對話軌跡，加上 Empero 內部工具 `rethink` 生成的思維鏈。每個回答都先輸出 `<think>...</think>` 推理再給答案，支援 Qwen3.5 規格的原生函式呼叫，預設以 YaRN 開啟 1,048,576 tokens context。此連結為其 GGUF 量化版 repo，原始權重在 `empero-ai/Qwythos-9B-Claude-Mythos-5-1M`（2026-06-19 建立）。

## 模型規格

| 項目 | 內容 |
| --- | --- |
| 基底模型 | Qwen/Qwen3.5-9B（模型卡稱為「deeply uncensored」的版本，來源未說明） |
| 架構 | Dense、原生多模態；混合注意力（Gated DeltaNet 線性注意力：Gated 全注意力 = 3:1），詞彙約 152k |
| 參數量 | 約 9B（依名稱；精確數字資料不足） |
| Context 長度 | 1,048,576 tokens（YaRN factor 4.0；原生 262,144） |
| 微調方式 | 全參數 SFT（文字骨幹全部訓練、視覺塔凍結） |
| GGUF 檔案 | Q4_K_M 5.24 GiB（建議預設）、Q5_K_M 6.02 GiB、Q6_K 6.85 GiB、Q8_0 8.87 GiB、BF16 16.69 GiB；另有含 MTP head 的版本；視覺投影 mmproj F16 0.86 GiB |

## 核心功能／特色

- 推理模型（`<think>` 先行）。
- 原生函式呼叫（Qwen3.5 XML 格式 `<tool_call><function=...><parameter=...>`）。
- 1M context（YaRN 已寫入 config 與 GGUF）。
- 影像輸入：搭配 mmproj，行為等同基底 Qwen3.5-9B（未微調、未評測）。
- MTP 版 GGUF 可在支援的 llama.cpp 上做 MTP draft 推測解碼（`--spec-type draft-mtp`）。
- 官方強調領域：資安、紅隊方法論、生物、藥理、臨床醫學、數學。

## 訓練方式

- 全參數 SFT，使用 TRL；assistant-only loss。
- 兩階段課程：廣泛推理語料 → 聚焦 agentic＋程式。
- 有效 batch size 16、最大序列長度 128,000、學習率 1e-5 → 5e-6 cosine、paged AdamW 8-bit、bf16。
- 資料：「Claude Mythos 與 Claude Fable traces」＋ `rethink` 生成的 CoT，超過 5 億 tokens。這些資料**如何取得、是否經授權，模型卡未說明** → 資料不足。
- 長 context 僅在約 137k tokens 做過內部 smoke test。

## 評測表現（Empero 自報）

以 lm-evaluation-harness、HF backend、`--apply_chat_template`、`--limit 100` 測得：

| 任務 | 基底 Qwen3.5-9B | Qwythos-9B | 差異 |
| --- | ---: | ---: | ---: |
| gsm8k（flexible） | 0.670 | 0.860 | +0.190 |
| gsm8k（strict） | 0.510 | 0.810 | +0.300 |
| MMLU | 0.232 | 0.575 | +0.343 |
| ARC-Challenge（acc） | 0.470 | 0.490 | +0.020 |
| GPQA Diamond（CoT, 0-shot） | 0.630 | 0.580 | −0.050 |

解讀注意：
- `--limit 100` 表示每個任務只取 100 題，樣本小、誤差大。
- 基底 MMLU 0.232 低於四選一隨機猜測的 25%，顯示該評測設定下基底分數可能異常，「+34 分 MMLU」的頭條數字應保守看待；模型卡本身也承認 9B 模型的 MMLU 絕對分數對 harness 與 chat template 很敏感。
- GPQA Diamond 反而下降 5 分。
- 7 題工具使用測試 7/7 正確（自訂小型 harness：Python 執行器＋DuckDuckGo 搜尋），樣本極小。

## 本地執行／使用方式

```bash
# Ollama
ollama run hf.co/empero-ai/Qwythos-9B-Claude-Mythos-5-1M-GGUF:Q4_K_M

# llama.cpp
llama-cli -m Qwythos-9B-Claude-Mythos-5-1M-Q4_K_M.gguf \
  -n 8192 --temp 0.6 --top-p 0.95 --top-k 20 --repeat-penalty 1.05 -c 16384 \
  -p "你的問題"

# 影像輸入
llama-mtmd-cli -m Qwythos-9B-Claude-Mythos-5-1M-Q4_K_M.gguf \
  --mmproj mmproj-Qwythos-9B-Claude-Mythos-5-1M-F16.gguf --image ./photo.jpg \
  -p "Describe this image in detail." -c 16384

# MTP 推測解碼（需較新的 llama.cpp）
llama-server -m Qwythos-9B-Claude-Mythos-5-1M-MTP-Q4_K_M.gguf \
  --spec-type draft-mtp --spec-draft-n-max 6 -c 16384 --port 8080
```

- LM Studio／jan／KoboldCpp：把 `.gguf` 放入模型資料夾即可；LM Studio 會自動偵測同資料夾的 mmproj 並開啟附圖功能。
- 1M context：llama.cpp 用 `-c 1010000`；vLLM `--max-model-len 1010000`。官方稱單張 H100/H200 可處理 256k–512k，完整 1M 需多 GPU 或 KV cache offload。
- 推薦取樣：`temperature=0.6, top_p=0.95, top_k=20, repeat_penalty=1.05, max_new_tokens=16384`；避免 greedy 或 T ≤ 0.3（會陷入重複迴圈）。
- 只要短 context 精度、不需超過 262k 時，可用附帶的 `config.json.pre_yarn` 還原 RoPE 設定（transformers 版）。

## 適用情境

- 本機 9B 級推理與工具呼叫實驗（Q4_K_M 約 5.6 GB）。
- 需要長 context 的實驗性用途。
- 作者定位：資安、生醫等主流模型容易拒答的技術領域研究。

## 授權與成本

- 授權：模型卡標示 Apache-2.0（繼承自 Qwen3.5-9B），作者聲明「供研究與實驗，按現況提供」。
- 注意：訓練資料宣稱來自 Claude 的對話軌跡。Anthropic 商業服務條款 D.4 禁止客戶「存取服務以建立競爭產品或服務，包括訓練競爭 AI 模型」。資料取得方式未公開，是否違反相關條款無法判斷，商用前應自行評估法律風險。
- 成本：免費下載；Q4_K_M 可在 8 GB 級顯示卡或 Apple Silicon 上執行（依檔案大小推估）。

## 限制與注意事項

- **刻意去審查**，不會拒答敏感技術問題；面向終端使用者時必須自行加上應用層安全審查。
- 名稱含「Claude」但與 Anthropic 無官方關係。
- 小模型會過度自信地給出具體識別碼（CVE、hashcat mode、藥物細節），作者建議搭配檢索或工具。
- 評測樣本小（每項 100 題），且基底分數疑似異常，結論需保守看待；全部為自報。
- 視覺能力未經微調與評測；1M context 只測到約 137k。
- YaRN factor 4.0 會略降短 context 品質（作者承認）。
- 原始 transformers 權重需 flash-linear-attention 與 causal_conv1d 核心，否則線性注意力層退回緩慢的 PyTorch 實作。

## 相關模型

- Qwen/Qwen3.5-9B（基底）
- empero-ai/Qwythos-9B-Claude-Mythos-5-1M（原始 safetensors 權重）
- Unsloth 的 Qwen3.5-9B mmproj（視覺投影來源）
- Qwen Fixed Chat Templates（Qwen3.5 系列通用的模板修正檔）

## 資料來源

- https://huggingface.co/empero-ai/Qwythos-9B-Claude-Mythos-5-1M-GGUF （README 原始檔）
- https://huggingface.co/empero-ai/Qwythos-9B-Claude-Mythos-5-1M （README 原始檔）
- https://huggingface.co/api/models/empero-ai/Qwythos-9B-Claude-Mythos-5-1M （建立日期、檔案清單）
- https://www.anthropic.com/legal/commercial-terms （第 D.4 條使用限制）
