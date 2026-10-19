# OrcaCyber Nano 1.0

- **分類**：模型 / 資安模型
- **連結**：https://huggingface.co/orcarouter/OrcaCyber-Nano-1.0
- **原始來源**：https://www.aiposthub.com/orcacyber-nano-1-local-security-model-memory-context/

## 原清單說明

（使用者提供的 AI Post Hub 中文介紹文章連結，無附帶說明。）

> **查證結果**：文章與 Hugging Face 模型卡大致一致。文章稱「27B 視覺語言資安模型」；模型卡描述也是 27B，但 HF 頁面的 metadata 欄位顯示「2B params」，兩者矛盾，應以描述與檔案大小（13–16 GB 的混合量化）判斷為 27B 級。模型卡標示的基底 `orcarouter/OrcaCyber-Nano-1.0-AI-Defense` 未公開（查詢時 API 回應無法存取），所以無法確認再往上的底模；架構欄位為 `Qwen3_5ForConditionalGeneration`，屬 Qwen3.5 系列架構。

## 概述

OrcaCyber Nano 1.0 是 OrcaRouter 發布的開放權重資安模型，可同時輸入文字與圖片（程式碼、日誌、反組譯、diff、工具截圖），主打在本機離線執行，讓敏感的二進位檔與日誌不必上傳到雲端。官方 repo 只提供 GGUF 量化檔，原生 llama.cpp 即可載入，不需要自訂 kernel；模型卡也列出 vLLM、Ollama、LM Studio、Docker Model Runner 等執行方式。

HF repo 建立於 2026-10-16，官方在 2026-10-19（台灣時間）公告發布；查詢當下（2026-10-19）88 個 like。下載前需登入 HF 並同意分享聯絡資訊（gated）。

## 模型規格

| 項目 | 內容 |
| --- | --- |
| 發布者 | OrcaRouter |
| 參數量 | 27B（模型卡描述；HF metadata 誤顯示為 2B） |
| 架構 | Qwen3_5ForConditionalGeneration，視覺語言混合注意力：64 層（48 層線性注意力＋16 層全注意力），hidden size 5120 |
| 基底 | `orcarouter/OrcaCyber-Nano-1.0-AI-Defense`（本 repo 為其量化版；基底 repo 未公開） |
| Context 長度 | 262,144 tokens；官方 16 GB 範例只開 32K |
| 輸入／輸出 | 文字＋圖片／影片 → 文字 |
| 語言 | 英文、中文 |
| 加速 | 主檔內建 MTP head；另附 DFlash2 草稿模型做投機解碼 |

檔案：

| 檔案 | 大小 | 用途 |
| --- | ---: | --- |
| `…-Mix-13G.gguf` | 12.99 GB | 16 GB 顯卡用，搭配內建 MTP |
| `…-Mix-15.7G.gguf` | 15.70 GB | 品質最好，24 GB 以上顯卡 |
| `…-DFlash2-Q8_0.gguf` | 2.06 GB | DFlash2 投機解碼草稿模型 |
| `mmproj-…-F16.gguf` | 0.93 GB | 視覺投影，輸入圖片時才需要 |

## 核心功能／特色

模型卡列出的用途：

- 逆向工程與反編譯。
- 漏洞分析與修補建議。
- 安全程式碼審查。
- 日誌、告警、封包擷取的分流。
- 事件回應。
- 讀工具截圖（視覺輸入）。
- 保留一般程式與推理能力。

## 本地執行／使用方式

```bash
hf download orcarouter/OrcaCyber-Nano-1.0 --local-dir ./ocn-gguf

# 16 GB 顯卡：13G 主檔 + 內建 MTP 投機解碼，32K context
llama-server -m ocn-gguf/OrcaCyber-Nano-1.0-AI-Defense-Mix-13G.gguf \
  --spec-type draft-mtp -np 1 -ngl 99 -c 32768

# 24 GB 以上：15.7G 主檔 + 視覺 + DFlash2 草稿模型
llama-server -m ocn-gguf/OrcaCyber-Nano-1.0-AI-Defense-Mix-15.7G.gguf \
  --mmproj ocn-gguf/mmproj-OrcaCyber-Nano-1.0-AI-Defense-F16.gguf \
  -md ocn-gguf/OrcaCyber-Nano-1.0-AI-Defense-DFlash2-Q8_0.gguf \
  --spec-type draft-dflash --spec-draft-n-max 7 -ngl 99 -ngld 99 -c 32768
```

- 推薦取樣：`temperature=1.0, top_p=0.95, top_k=20`。
- 16 GB 範例只設一個平行 slot（`-np 1`）。實際記憶體用量還取決於 runtime 與 KV cache。
- 262K context 是模型支援的上限；32K 是官方在特定硬體上的實用起點。

## 評測表現（官方自報）

模型卡註明評測框架、設定與完整結果表「仍在整理」，以下數字尚無可重現的細節：

| 基準 | 分數 |
| --- | ---: |
| MATH-500 | 98.60% |
| GSM8K | 97.50% |
| AIME 2025 | 96.23% |
| HumanEval+ | 93.29% |
| LiveCodeBench | 92.23% |
| GPQA Diamond | 88.28% |
| MBPP+ | 84.66% |
| IFEval | 82.81% |
| SWE-bench | 78.4% |
| Terminal-Bench 2.1 | 72.5% |
| IFBench | 56.33% |
| BigCodeBench | 49.82% |

這些都是通用的數學、程式與指令遵循基準，**資安專項評測尚未公布**（文章說會之後補上）。模型卡與官網引用的 CyberGym 成績屬於另一個模型 OrcaCyber Zero，不適用於 Nano。

## 適用情境

- 不能把樣本、日誌或原始碼送上雲端的逆向、事件回應與程式碼審查。
- 單張 16–24 GB 消費級顯卡上的本地資安助手。
- 接 MCP 工具（例如 [GhidraMCP](../09-資安/GhidraMCP.md)）當本地後端模型的實驗。

## 授權與成本

- 授權：HF 標為 `other`，名稱 `qwen`（Qwen 授權），模型卡沒有附完整條款；商用前請先確認。
- 取得方式：gated，需登入 HF 並同意分享聯絡資訊。
- 成本：權重免費；硬體約需 16 GB VRAM（13G 版）或 24 GB 以上（15.7G 版＋視覺＋草稿模型）。

## 限制與注意事項

- 資安能力目前沒有公開評測數據可佐證，通用基準也都是官方自報。
- 參數量欄位、基底模型與授權條款都有資訊不完整或矛盾之處（見上方查證結果）。
- 文章提醒輸出仍要回頭對照原始證據驗證，不能直接當結論。
- 和資安類其他工具一樣，只能用在你擁有或取得授權的系統與樣本上。

## 相關

- OrcaCyber Zero（同公司另一個模型，CyberGym 成績屬於它）
- [Bonsai 2](Bonsai-2.md)：同為 Qwen 系 27B、262K context 的本地模型
- [資安](../09-資安/) 類的逆向與漏洞研究工具

## 資料來源

- https://www.aiposthub.com/orcacyber-nano-1-local-security-model-memory-context/
- https://huggingface.co/orcarouter/OrcaCyber-Nano-1.0 （模型卡與 `https://huggingface.co/api/models/orcarouter/OrcaCyber-Nano-1.0`）
- https://x.com/OrcaRouter/status/2111871993532580058 （官方發布貼文，經文章引用，未直接讀取）
