# DaisyRose-27B

- **分類**：模型 / 程式碼模型
- **連結**：https://huggingface.co/RadixArk/DaisyRose-27B （FP8：https://huggingface.co/RadixArk/DaisyRose-27B-FP8 ；NVFP4：https://huggingface.co/RadixArk/DaisyRose-27B-NVFP4 ；官方部落格：https://www.radixark.com/blog/daisyrose-27b ）

## 概述

DaisyRose-27B 是 RadixArk（開源 RL 框架 Miles 的開發團隊）發表的第一個模型，2026-11-18 上傳。它以 Qwen3.8-27B 為底，**只用強化學習**（沒有 SFT、沒有蒸餾）訓練約 1,200 個長程 agent 任務，目標是讓模型在終端機、軟體工程這類要連續呼叫上百次工具、跑上一兩個小時的任務上更穩。

架構、tokenizer、chat template、讀圖能力與 256K context 都和 Qwen3.8-27B 相同，官方定位為 Qwen3.8-27B 的直接替換品：原本能跑 Qwen3.8-27B 的推論或後訓練流程不必改。權重以 Apache-2.0 釋出 BF16、FP8、NVFP4 三種精度；發布隔天社群已有 GGUF、AWQ 等量化版。

## 模型規格

| 項目 | 內容 |
| --- | --- |
| 基底模型 | Qwen/Qwen3.8-27B（`Qwen3_5ForConditionalGeneration`） |
| 架構 | Dense、多模態思考模型；64 層 decoder，Gated DeltaNet 線性注意力：全注意力 = 3:1，hidden size 5,120；27 層視覺編碼器；1 層 MTP（多 token 預測） |
| 參數量 | 共 27.8B（含 0.46B 視覺編碼器、0.42B MTP head） |
| Context 長度 | 262,144 tokens |
| 輸入／輸出 | 文字＋圖片 → 文字 |
| 官方權重 | BF16 約 52 GB、FP8 約 29 GB、NVFP4 約 23 GB（NVFP4 需 Blackwell GPU） |
| 推測解碼 draft | [RadixArk/Qwen3.8-27B-DSpark](https://huggingface.co/RadixArk/Qwen3.8-27B-DSpark) |

## 訓練方式

- **只用 RL**：從 Qwen3.8-27B 直接做強化學習；視覺編碼器與 MTP head 沿用基底、未更動。
- **任務**：和 Eigent AI 合作，從機器學習、軟體工程、科學等領域的大型任務池篩出約 1,200 個。每個任務針對基底模型會犯的錯設計，並調整到「不會太簡單也不會太難」的解題率；每次嘗試在沙箱內最多 1.5 小時、100 次以上工具呼叫、256K 以上輸出 tokens，單一 session 最長約 1M tokens。官方說每個任務都連同模型的嘗試人工檢查過，能「不真正解題就過關」的任務已修正或移除。
- **基礎設施**：用 RadixArk 開源的 RL 框架 [Miles](https://github.com/radixark/miles) 全非同步訓練：128 張 H200 以 SGLang 跑 agent rollout，16 張 H200 訓練，每步更新完把權重送回推論端。總計 144 張 H200、18 天、約 63,000 GPU 小時。沙箱建在開源的 [AgentENV](https://github.com/kvcache-ai/AgentENV) 上，九週內跑了約 94.4 萬個沙箱、尖峰同時 1,566 個；官方稱 10 月底後成功率高於 99.95%，成本比常見雲端沙箱服務低約 80%。
- **訓練效率（官方自報）**：和開源的 Megatron 系訓練器相比，MFU 37% 對 16%、144 卡端到端吞吐 16.8k 對 8.3k tokens/s（2.0×），訓練成本少 57%；在 MoE 模型上差距更大（Qwen3.6-35B-A3B 6.2×、GLM-5.3-Flash 超過 10×）。

## 評測表現（RadixArk 自報）

| 基準 | DaisyRose-27B | Qwen3.8-27B（基底） |
| --- | ---: | ---: |
| Terminal Bench 4.1（pass@1） | 12.0 | 5.6* |
| Terminal Bench 2.1 | 75.5 | 73.0 |
| DeepSWE v1.1 | 46.2 | 42.2 |
| SWE Bench Pro v2（Full, 642 題） | 94.7 | 91.3 |
| HLE（純文字、無工具） | 34.3 | 33.9 |
| IFBench | 82.4 | 79.5 |
| GPQA Diamond | 90.7 | 89.2 |

解讀注意：
- 七項都比基底高，最大的進步在 Terminal Bench 4.1（約 2 倍）；其餘多是 1–4 分，HLE 只多 0.4 分，在誤差範圍內。
- \* 基底的 Terminal Bench 4.1 沒有官方紀錄，表中 5.6 其實是 Artificial Analysis 的 **Terminal Bench 4.0** 分數；DaisyRose 自己用的是內部 mini-swe-agent harness（8 次平均、開啟摘要）。兩邊版本和 harness 不同，「從 5.6 翻倍到 12.0」不是完全同條件比較。
- 基底和其他模型的數字取自各家模型卡、排行榜或 Artificial Analysis，harness 不盡相同；DaisyRose 分數取 BF16 與 FP8 兩次跑分中較高者（官方稱兩者差距都不到 1 分）。
- 和更大的模型比，它沒有全面領先：模型卡的比較表中 MiMo V2.6 Flash（309B）在兩個 Terminal Bench 較高，Inkling 2 Small（594B）在 DeepSWE、SWE Bench Pro、HLE、GPQA 較高；IFBench 82.4 是表中最高。
- 評測設定：temperature 1.0、top_p 0.95、top_k 20、min_p 0，reasoning effort xhigh（模板預設），256K 內不設 max_tokens。

## 本地執行／使用方式

官方強烈建議用 SGLang 加 DSpark 推測解碼（`lmsysorg/sglang:latest` 映像已內含 DSpark）。各 GPU、各精度的啟動參數可用 [SGLang cookbook](https://docs.sglang.io/cookbook/autoregressive/RadixArk/DaisyRose-27B) 產生。以下是模型卡的範例：4 卡節點、BF16、每卡一個 replica。

```bash
docker run --gpus all --ipc=host --shm-size 32g -p 30000:30000 \
  -v ~/.cache/huggingface:/root/.cache/huggingface \
  lmsysorg/sglang:latest \
  python3 -m sglang.launch_server \
  --model-path RadixArk/DaisyRose-27B \
  --served-model-name DaisyRose-27B \
  --tp-size 1 --dp-size 4 \
  --context-length 262144 \
  --reasoning-parser qwen3 \
  --tool-call-parser qwen3_coder \
  --trust-remote-code \
  --mem-fraction-static 0.85 \
  --kv-cache-dtype fp8_e4m3 \
  --chunked-prefill-size 2048 \
  --mamba-full-memory-ratio 11.01 \
  --mamba-radix-cache-strategy extra_buffer_lazy \
  --mamba-ssm-dtype float32 \
  --speculative-algorithm DSPARK \
  --speculative-draft-model-path RadixArk/Qwen3.8-27B-DSpark \
  --speculative-draft-attention-backend flashinfer \
  --host 0.0.0.0 --port 30000
```

呼叫方式（OpenAI 相容 API）：

```python
from openai import OpenAI

client = OpenAI(base_url="http://localhost:30000/v1", api_key="none")
resp = client.chat.completions.create(
    model="DaisyRose-27B",
    messages=[{"role": "user", "content": "How many positive divisors does 360 have?"}],
    temperature=1.0, top_p=0.95, extra_body={"top_k": 20, "min_p": 0.0},
)
print(resp.choices[0].message.reasoning_content)  # 思考過程
print(resp.choices[0].message.content)            # 最終答案
```

- 預設先思考再回答；思考在 `reasoning_content`、答案在 `content`。
- 取樣建議：`temperature 1.0`、`top_p 0.95`、`top_k 20`、`min_p 0`。難題不要設 `max_tokens`，思考可能長達數萬 tokens。
- 多輪對話要把前幾輪的 `reasoning_content` 一起送回（chat template 預設會保留）。
- 硬體：官方稱單卡即可跑，從 H200、B200、GB300 到 RTX PRO 6000、RTX 5090、DGX Spark。
- **消費級顯卡／筆電**：官方沒有提供 GGUF，但社群已有，例如 [bartowski/RadixArk_DaisyRose-27B-GGUF](https://huggingface.co/bartowski/RadixArk_DaisyRose-27B-GGUF)（Q4_K_M 16.1 GiB、Q5_K_M 19.4 GiB、Q6_K 22.1 GiB、Q8_0 27.1 GiB，另有 0.86 GiB 的 mmproj 讀圖檔），可用 llama.cpp、LM Studio 等執行。這些是第三方量化，未經 RadixArk 評測。
- 因為和 Qwen3.8-27B 同架構、同模板，原本跑 Qwen3.8-27B 的工具通常可直接換用；本地跑 Qwen 系模板出問題時可參考 [Qwen Fixed Chat Templates](../11-推論與訓練引擎/Qwen-Fixed-Chat-Templates.md)。

## 適用情境

- 自架的 coding agent／終端機 agent 後端：長時間、多步驟、大量工具呼叫的任務。
- 已經在用 Qwen3.8-27B 的推論或後訓練流程，想直接換一個 agent 能力較強的版本。
- 研究「只用 RL、不做 SFT」的長程 agent 訓練：模型卡與部落格公開了任務規模、算力與基礎設施細節，訓練框架 Miles 與沙箱 AgentENV 也開源。

## 授權與成本

- 授權：Apache-2.0（Qwen3.8-27B 本身也是 Apache-2.0）。HF 上非 gated，不需申請即可下載。
- 成本：權重免費。官方三種精度需約 23–52 GB 顯存放權重（另加 KV cache）；社群 Q4_K_M 約 16 GiB，24 GB 級顯卡可跑（依檔案大小推估，長 context 需更多記憶體）。

## 限制與注意事項

- 所有評測都是 RadixArk 自報，且和基底、其他模型的比較混用不同來源與 harness；Terminal Bench 4.1 的基底分數其實是 4.0 版（見上方說明）。
- 模型卡沒有限制或安全性章節，也沒有說明 RL 後在一般聊天、多語言（含中文）上的表現變化。
- 視覺編碼器未經 RL 訓練，讀圖能力應與基底相同，但官方未另外評測。
- NVFP4 版只能在 Blackwell GPU 上跑；官方範例指令以資料中心多卡節點為主，單卡消費級顯卡的設定需參考 SGLang cookbook 或改用社群量化。
- 剛發布（2026-11-18），社群使用經驗與第三方獨立評測還很少。

## 相關模型

- [Bonsai 2](Bonsai-2.md)：同樣以 Qwen3.8-27B 為底，但走三值壓縮路線，體積約 6–7 GB，適合筆電。
- [FrogNano-4B-2609](FrogNano-4B-2609.md)：Microsoft 同樣只用 RL 訓練的程式代理模型，4B、定位研究成果。
- [Ornith 1.5](Ornith-1.5.md)：35B-A3B MoE 等多種尺寸的開放權重 agent／程式模型。
- Qwen/Qwen3.8-27B（基底）：https://huggingface.co/Qwen/Qwen3.8-27B

## 資料來源

- https://www.radixark.com/blog/daisyrose-27b （官方部落格：訓練規模、沙箱基礎設施、訓練效率數字）
- https://huggingface.co/RadixArk/DaisyRose-27B （模型卡 README 原始檔：規格、完整比較表與評測方法、SGLang 指令、授權）
- https://huggingface.co/api/models/RadixArk/DaisyRose-27B （建立日期、授權、gated 狀態；FP8、NVFP4 repo 同樣查詢）
- https://huggingface.co/api/models/bartowski/RadixArk_DaisyRose-27B-GGUF （社群 GGUF 檔案大小，2026-11-19 查詢）
