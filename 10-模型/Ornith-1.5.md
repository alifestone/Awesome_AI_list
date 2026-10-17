# Ornith 1.5

- **分類**：模型 / 本地可跑的通用 / 推理模型
- **連結**：
  - 9B GGUF：https://huggingface.co/ornith-ai/Ornith-1.5-9B-GGUF
  - 35B-A3B GGUF：https://huggingface.co/ornith-ai/Ornith-1.5-35B-A3B-GGUF
  - 報導：https://www.techbang.com/posts/132537-ornith-1-5-release-rivals-claude-opus-iphone-17

## 原清單說明

（DeepReinforce／Ornith AI）— 2026 年 8 月發布的開放權重模型家族，MIT 授權；9B 密集版有手機用的 Mobile 量化版，35B-A3B 為 MoE（每 token 啟用約 3B），皆提供 GGUF，可用 llama.cpp、Ollama 執行。

> 查證結果：本次環境無法連到 Hugging Face 與 TechBang，以下內容來自搜尋摘要與第三方報導，模型卡原文**未直接核對**；基準分數皆為官方自報。

## 概述

Ornith-1.5 是三款尺寸的家族：397B MoE 旗艦、35B-A3B MoE、9B 密集模型（另有 9B-Mobile 量化版供手機使用）。報導稱 397B 在官方自測的 Terminal-Bench 2.1 上為 86.1，高於 Claude Opus 4.8 的 85.0。發布日期各來源說法不一（8 月 19 日或 23 日）。

## 模型規格

| 項目 | 9B | 35B-A3B |
| --- | --- | --- |
| 架構 | 密集 | MoE，總參數約 35B、每 token 啟用約 3B |
| Context | 256K（Ollama 目錄） | 256K 原生 |
| 本機版本大小 | 約 6.6 GB（Ollama `ornith-1.5:9b`） | 約 23 GB（Ollama `ornith-1.5:35b`）；Q4_K_M 約 20 GB |
| SWE-bench Verified（自報） | 70.6 | 79.0 |
| Terminal-Bench 2.1（自報） | 47.0 | 68.5 |

- 一份指南稱 35B-A3B 建立在 Qwen 3.5 MoE 架構上；1.5 的確切基底模型**資料不足**（報導只明確提到 1.0 以 Qwen 3.5／Gemma 4 為底）。

## 本地執行

```bash
# Ollama
ollama run ornith-1.5:9b
ollama run ornith-1.5:35b

# llama.cpp
llama-server -hf ornith-ai/Ornith-1.5-35B-A3B-GGUF --port 8000 -c 262144
```

## 授權與成本

- MIT。免費下載。

## 限制與注意事項

- 所有基準皆廠商自報；BenchLM 將其 18 項標為 provider-reported，並暫不排名。另有頁面顯示的分數與官方 Terminal-Bench 數字衝突，宜保守看待「媲美 Claude Opus」的說法。
- 搜尋結果中另有第三方重新封裝（如 AtomicChat）或去審查（abliterated）版本，下載時請確認 repo 屬於 `ornith-ai`。

## 相關模型

- Ornith-1.5-397B、Ornith-1.5-9B-Mobile

## 資料來源

- https://datanorth.ai/news/ornith-releases-ornith-1-5
- https://officechai.com/ai/deepreinforce-releases-open-source-orinth-1-5-family-of-models-with-solid-benchmarks-and-mit-license/
- https://gigazine.net/gsc_news/en/20260820-ornith-1-5/
- https://friendli.ai/models/ornith-ai/Ornith-1.5-35B-A3B
