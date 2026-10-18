# Mellum2

- **分類**：模型 / 本地可跑的通用 / 推理模型
- **連結**：https://huggingface.co/blog/JetBrains/mellum2-launch

## 原清單說明

（JetBrains）— 12B MoE（每 token 啟用 2.5B），適合路由、RAG、子 agent 與私有部署。Apache 2.0。

> 查證結果：與官方發布文一致。補充：Mellum2 定位已從第一代的「程式碼補全模型」擴展為「文字＋程式碼」通用的低延遲模型，不只是程式碼模型。

## 概述

Mellum2 是 JetBrains 於 2026-06-01 發布的開放 Mixture-of-Experts 模型，**從零開始**以自然語言與程式碼訓練，總參數 12B、每個 token 只啟用 2.5B。JetBrains 稱之為「focal model」：針對大型 AI 系統中高頻、延遲敏感的中間步驟（路由、檢索後處理、摘要、規劃、驗證、工具選擇）而設計，不打算取代最大的推理模型。官方稱與同級模型相比效能具競爭力，且推論速度快 2 倍以上（官方自述）。

## 模型規格

以 `Mellum2-12B-A2.5B-Thinking` 模型卡為準：

| 項目 | 內容 |
| --- | --- |
| 總參數／啟用參數 | 12B（HF 統計 12,149,923,072）／每 token 2.5B |
| 架構 | MoE，64 個專家、每 token 啟用 8 個；sliding-window 與全注意力混合 |
| 層數 | 28 |
| Hidden size／Intermediate size／MoE intermediate | 2304 / 7168 / 896 |
| 注意力頭（GQA） | Q 32、KV 4 |
| Context 長度 | 131,072 tokens |
| Sliding window | 1,024 |
| 詞彙量 | 98,304 |
| 模態 | 僅文字與程式碼（刻意不做多模態） |
| 精度 | bfloat16 |

模型家族（HF collection `JetBrains/mellum-2`，共 6 個 checkpoint）：
- `Mellum2-12B-A2.5B-Base-Pretrain`：長 context 擴展前的 base
- `Mellum2-12B-A2.5B-Base`：最終 base
- `Mellum2-12B-A2.5B-Instruct-SFT`／`-Thinking-SFT`：監督微調版
- `Mellum2-12B-A2.5B-Instruct`：RL 後的指令模型（低延遲、直接回答）
- `Mellum2-12B-A2.5B-Thinking`：RL 後的推理模型（先在 `<think>` 中推理）

## 核心功能／特色

- MoE 架構：大容量、低啟用量，降低即時服務成本。
- 官方列出的用途：路由與編排（prompt 分類、工具選擇）、RAG（context 壓縮、摘要、檢索後處理）、子 agent（規劃、驗證、轉換、context 準備）、私有部署（處理專有程式碼或內部資料）。
- Thinking 版支援工具呼叫（vLLM 使用 hermes parser）。

## 訓練方式

- 從零預訓練（自然語言＋程式碼），再做長 context 擴展。
- Thinking 版：由 Base 做 SFT（只在最後一個 assistant turn 計算 loss），再以可驗證獎勵強化學習（RLVR）在較難的資料組合（含長篇數學子集）上訓練。
- 預訓練 token 數、資料組成：發布文與模型卡未列，詳見技術報告（arXiv 2605.31268，本條目未讀取）→ **資料不足**。

## 評測表現（JetBrains 自報，Mellum2 Thinking）

| Benchmark | Mellum2 Thinking | Qwen3.5 4B | Qwen3.5 9B | Ministral 3 14B |
| --- | ---: | ---: | ---: | ---: |
| LiveCodeBench v6 | 69.9 | 59.4 | 68.3 | 42.7 |
| BFCL v4 | 45.6 | 42.9 | 42.7 | 35.9 |
| BFCL v3 | 69.4 | 73.9 | 68.5 | 52.2 |
| AIME（2025+2026 平均） | 58.4 | 68.3 | 73.4 | 38.3 |
| GSM-Plus | 87.0 | 89.3 | 90.7 | 86.5 |
| MMLU-Redux | 86.2 | 88.3 | 91.7 | 84.4 |
| GPQA Diamond | 57.6 | 76.8 | 81.3 | 46.0 |
| IFEval | 76.5 | 87.1 | 89.8 | 59.7 |
| HarmBench（越低越好） | 20.6 | 15.9 | 6.6 | 70.0 |

模型卡明註「All values self-reported by JetBrains」。可看出程式（LiveCodeBench）與工具呼叫（BFCL v4）是強項，知識（GPQA）、數學（AIME）、指令遵循（IFEval）則落後 Qwen3.5 4B／9B。「推論快 2 倍以上」的量測條件：發布文未說明 → 資料不足。

## 本地執行／使用方式

```sh
# vLLM（不含工具呼叫）
vllm serve JetBrains/Mellum2-12B-A2.5B-Thinking \
  --max-model-len 131072 --reasoning-parser qwen3

# vLLM（含工具呼叫）
vllm serve JetBrains/Mellum2-12B-A2.5B-Thinking \
  --max-model-len 131072 --reasoning-parser qwen3 \
  --enable-auto-tool-choice --tool-call-parser hermes
```

之後以 OpenAI 相容 API 呼叫，官方範例取樣：`temperature=0.6, top_p=0.95, top_k=20`。需要低延遲直接回答時改用 `Mellum2-12B-A2.5B-Instruct`。
GGUF／Ollama 等量化版本：官方發布文未提供 → 資料不足。

## 適用情境

- 多模型系統中的輕量路由／編排模型。
- 延遲敏感的 RAG 前後處理。
- Agent 的子任務（規劃、驗證、context 準備），減少呼叫大模型的次數。
- IDE 內高吞吐的程式功能、自架私有部署。

## 授權與成本

- 授權：Apache 2.0（發布文、模型卡、HF metadata 皆一致）。
- 成本：開放權重免費；bf16 下 12B 權重約需 24 GB 以上記憶體（依參數量推算，非官方數字），每 token 計算量相當於 2.5B。

## 限制與注意事項

- 刻意只做文字與程式碼，不支援多模態。
- 一般知識、數學與指令遵循分數不如同級 Qwen3.5（見上表）。
- BS-Bench（偵測不合理前提）僅 15.0，遠低於 Qwen3.5。
- HarmBench 有害率 20.6%，高於 Qwen3.5；面向使用者的部署需另加安全層。
- 發布文下的社群留言反映：用在 OpenCode 以自然語言要求改動專案時效果不佳（單一使用者回饋，非系統性評測）。
- 模型卡語言標示僅 `en`。

## 相關模型

- Mellum（第一代，程式碼補全模型）
- Qwen3.5 4B／9B、OLMo-3 7B、Ministral 3 14B（官方比較對象）
- FrogNano-4B（同為小型程式／代理取向）

## 資料來源

- https://huggingface.co/blog/JetBrains/mellum2-launch
- https://huggingface.co/JetBrains/Mellum2-12B-A2.5B-Thinking （README）
- https://huggingface.co/api/collections/JetBrains/mellum-2 （collection 成員與參數量）
- https://huggingface.co/api/models/JetBrains/Mellum2-12B-A2.5B-Instruct （授權 metadata）
