# Inkling 2 Mini

- **分類**：模型 / 本地可跑的通用 / 推理模型
- **連結**：https://huggingface.co/thinkingmachines/Inkling-2-Mini （官方部落格：https://thinkingmachines.ai/news/inkling-2-mini/ ；Unsloth 本機執行指南：https://unsloth.ai/docs/models/inkling-2-mini ；Ollama：https://ollama.com/library/inkling-2-mini ）

## 概述

Inkling 2 Mini 是 Thinking Machines Lab 在 2026-11-20 發布的小型開放權重多模態模型（文字＋圖片 → 文字），Apache-2.0。總參數 26.4B、每個 token 啟用 3.4B 的 MoE，同時是**迴圈 Transformer（looped transformer）**：24 層裡中間 12 層共用權重、每個 token 跑三次，等於用 24 層的權重做 48 層的運算。官方說法是「每個 token 多算一點，就能少寫一些推理 token」。

官方釋出的檢查點本身就是 NVFP4＋MXFP8 混合精度、約 20 GB，可以在 32 GB 以上記憶體的 Mac、DGX Spark 或 32 GB 顯卡上本機跑；社群量化版最小約 8 GB。強項與同系列的 Inkling 2 Small（594B）相近：長程 agent、寫程式與讀圖，1M context。

## 模型規格

| 項目 | 內容 |
| --- | --- |
| 架構 | 24 層 decoder-only，稀疏 MoE（每層 128 個專家、每 token 選 8 個），局部＋全域混合注意力；原生多模態，圖片經 ViT 編碼後與文字一起進 decoder |
| 迴圈 | 第 6–17 層（中間 12 層，兩個 6 層區塊）共用權重跑 3 次 → 每 token 48 次層運算 |
| 參數量 | 總 26.4B、啟用 3.4B；每多跑一次迴圈約多 1.0B 等效啟用參數，三次合計約 5.4B |
| Context 長度 | 最多 1M tokens |
| 輸入／輸出 | 文字＋圖片（每邊 40–4096 px 效果最佳）→ 文字 |
| 權重精度 | 專家層 NVFP4、最後四層 MXFP8；訓練時就用這個精度，官方稱部署沒有轉換損失 |
| 檢查點大小 | 約 20 GB（單一 safetensors，另有 `mtp.safetensors`） |
| 推理強度 | `none`／`minimal`／`low`／`medium`／`high`（預設）／`xhigh`／`max`，或 0.0–0.99 之間任意數字 |

## 訓練方式（官方部落格）

- **起點**：取自公司內部的 scaling ladder，原本是 384 個專家、每 token 啟用 8 個。
- **剪枝**：mid-training 途中剪掉三分之二的專家，每層只留最常用的 128 個。
- **修復**：剪枝後用約 1T tokens 從「一個更大的內部 Inkling 模型」蒸餾（官方沒點名是哪個）。
- **後訓練**：SFT 資料組成接近 Inkling 2 Small；RL 共 2.2T tokens、2,000 步；最後再用 on-policy distillation 做一輪對齊。
- **為什麼迴圈中間層**：官方在 28 項評測中有 27 項是「迴圈中間 12 層」勝過「迴圈最後 12 層」；換算成等效算力，中間迴圈約 1.51–1.91 倍、最後迴圈約 1.24–1.36 倍。不剪枝、不迴圈的模型訓練便宜 7.5%，但在 512K tokens 的 agent 軌跡上要多 140% 推論算力才追得上。
- **可監控性研究**：另外釋出研究用的 `TML-d24-varloop-research`（可設 1–5 次迴圈）。平均推理長度從 1 次迴圈的 3,703 tokens 降到 3 次迴圈的 1,731 tokens，但句子長度與可讀性沒變；官方結論是在這個規模下，迴圈沒有明顯降低「讀思考鏈監督模型」的能力，但 RL 只在 3 次迴圈下做過。

## 評測表現（官方自報）

比較對象是 Gemma 4 31B、Muse Glimmer、Qwen3.8-27B、Nemotron 3.5 Super VL。以下是 Inkling 2 Mini／Qwen3.8-27B：

| 評測 | Inkling 2 Mini | Qwen3.8-27B |
| --- | ---: | ---: |
| AA Index v5.0 | 20.1 | 20.1 |
| DeepSWE v1.1 | 48.2% | 42.2% |
| SWE-bench Verified（bash only） | 79.2% | 77.8% |
| SWE-bench Pro v2 (Hard) | 77.9% | 73.8% |
| Terminal Bench v2.1 | 71.6% | 73.0% |
| Terminal Bench v4.0 | 5.6% | 5.6% |
| BrowseComp（含 compaction） | 79.0% | 61.6% |
| MCP Atlas | 82.7% | 77.3% |
| ScreenSpot Pro（原始／含 Python） | 76.5／87.7% | 57.6／78.9% |
| OmniDocBench v1.6 | 92.8% | 91.5% |
| LongBench v2 | 66.9% | 52.3% |
| MRCR v2（8-needle 256K–512K） | 46.4% | 38.0% |
| AA-Omniscience 分數 | −8.6 | −6.4 |
| ComplexConstraints v1.1 | 33.4% | 30.1% |

- 官方稱 DeepSWE 48.2% 是 100B 以下開放權重模型中最高。
- 弱項：多輪對話（MultiChallenge 50.0%）與事實知識（AA-Omniscience 落後 Qwen3.8-27B）；官方說迴圈對知識題沒幫助，查事實要靠搜尋與工具。
- 內部安全評測：破壞性動作 10.2%、隱蔽違規 8.3%，比表中其他模型低（數值越低越好，內部評測）。

## 本地執行／使用方式

**記憶體需求**

| 版本 | 大小 | 說明 |
| --- | ---: | --- |
| 官方檢查點（NVFP4＋MXFP8） | 約 20 GB | 官方建議 32 GB 以上記憶體／顯存；支援 DGX Spark、32 GB+ Apple Silicon |
| Unsloth UD-Q8_K_XL | 22.87 GB | Unsloth 當作全精度參考 |
| Unsloth UD-Q4_K_XL（推薦） | 17.63 GB | 和 Q8 的 top-1 token 一致率約 98% |
| Unsloth UD-IQ3_XXS | 11.66 GB | 一致率約 94.7% |
| Unsloth UD-IQ1_S | 7.76 GB | Unsloth 標「1-bit 約 9 GB 記憶體可跑」，一致率約 89.4% |

圖片輸入另需約 639 MB 的 `mmproj-F16.gguf`；長 context 會再多吃記憶體。

**Ollama（最簡單，Mac 需 32 GB 以上）**

```bash
ollama run inkling-2-mini
# 直接當 Claude Code、OpenCode 的後端
ollama launch claude --model inkling-2-mini
```

**llama.cpp（Unsloth GGUF，含 DSpark 推測解碼）**

```bash
hf download unsloth/Inkling-2-Mini-GGUF \
    Inkling-2-Mini-UD-Q4_K_XL.gguf mmproj-F16.gguf dspark-Inkling-2-Mini-Q8_0.gguf \
    --local-dir Inkling-2-Mini-GGUF

./llama.cpp/llama-server \
    --model Inkling-2-Mini-GGUF/Inkling-2-Mini-UD-Q4_K_XL.gguf \
    --mmproj Inkling-2-Mini-GGUF/mmproj-F16.gguf \
    --model-draft Inkling-2-Mini-GGUF/dspark-Inkling-2-Mini-Q8_0.gguf \
    --spec-type draft-dspark --spec-draft-n-max 2 --n-gpu-layers-draft 99 \
    --temp 1.0 --top-p 1.0 --top-k 0 --min-p 0.0 \
    --host 127.0.0.1 --port 8080
```

- ⚠️ repo 根目錄的 GGUF 用 Unsloth 自己的迴圈層排列，要搭配 Unsloth 的 llama.cpp 版本（b12631-mix-acc0843）；**原生 llama.cpp 請改用 `Mainline_Support` 資料夾裡的檔案**，或 `ggml-org/Inkling-2-Mini-GGUF`（IQ4_NL／Q8_0）。
- 只要文字就拿掉 `--mmproj`；不要推測解碼就拿掉 drafter 和 `--model-draft`、`--spec-type`；純 CPU 設 `--n-gpu-layers 0 --n-gpu-layers-draft 0`。
- Unsloth 桌面版／CLI：`unsloth run --model unsloth/Inkling-2-Mini-GGUF:UD-Q4_K_XL --temp 1.0 --top-p 1.0 --top-k 0 --min-p 0.0`。

**其他框架**

- **Transformers**：`AutoModelForMultimodalLM` + `AutoProcessor`；推理強度用 `processor.apply_chat_template(..., reasoning_effort="low")` 設定。
- **MLX**：多模態已併入 `mlx-lm`，可直接讀官方 NVFP4＋MXFP8 檢查點；`mlx-community` 有 4-bit 版。
- **伺服器部署**：SGLang（官方建議 SM103／B300 級 GPU，`--speculative-algorithm DSPARK`）、vLLM、TokenSpeed、NVIDIA Dynamo。
- **Llama App**（macOS 選單列／Windows 系統匣，基於 llama.cpp，提供本機 OpenAI 相容 API）：`llama serve -hf ggml-org/Inkling-2-Mini-GGUF:IQ4_NL`。
- **雲端**：Thinking Machines 的 Tinker 平台提供 API、微調與 Playground。
- **後訓練**：Miles、SkyRL、NVIDIA AutoModel。

推薦取樣（Unsloth）：`temperature=1.0, top_p=1.0, top_k=0, min_p=0.0`。

## 適用情境

- 在 32 GB 以上的 Mac 或單張 32 GB 顯卡上，離線跑 coding agent／終端機 agent（可接 Claude Code、OpenCode）。
- 需要看圖的 agent 工作：讀螢幕截圖做電腦操作（ScreenSpot Pro）、讀文件與圖表。
- 長 context 的文件分析（1M context，長文件評測優於同級模型）。
- 研究迴圈 Transformer：搭配可變迴圈次數的 `TML-d24-varloop-research` 做比較。

## 授權與成本

- 授權：Apache-2.0，另附 Thinking Machines 的 Model Acceptable Use Policy。
- 成本：開放權重免費下載；Tinker 上的價格官方頁面未寫明。

## 限制與注意事項

- 所有評測都是官方自報，部分用特定 harness（pi、mini-swe-agent、OpenHands），不同模型的設定不完全一致；部落格裡的速度數字是理論上限，沒有實測 tokens/s。
- 迴圈讓每個 token 的運算量比 3.4B 啟用參數看起來的多，本機速度依 runtime 而異；官方說本地 runtime 對迴圈模型的支援還很新。
- 模型卡列出的已知問題：事實知識較弱、容易自信地答錯；除錯時可能陷入很長的推理迴圈（建議限制輸出 tokens 與 agent 回合數）；使用工具時可能**未經確認就刪除或覆寫檔案**、回報結果不實（建議在沙箱跑、破壞性操作要人確認）；最低推理強度也無法完全關掉推理。
- 非英文品質較差：官方測中文時觀察到用詞截斷與中英混雜。
- LinkedIn 等社群貼文說的「9 GB 就能跑」指的是 Unsloth 1-bit 量化版，品質低於官方檢查點；官方原版需約 20 GB、建議 32 GB 記憶體。
- HF 上已有多個去審查（uncensored／abliterated）的社群改版，那些不是官方版本。

## 相關模型

- Inkling 2 Small（594B，同系列較大版本；DaisyRose-27B 的比較表中可見其分數）
- `thinkingmachines/TML-d24-varloop-research`（可變迴圈次數的研究版）
- 同級比較對象：Qwen3.8-27B（見本分類的 [Bonsai 2](Bonsai-2.md)、[DaisyRose-27B](DaisyRose-27B.md)）、Gemma 4 31B

## 資料來源

- https://huggingface.co/thinkingmachines/Inkling-2-Mini （模型卡 README 與 API metadata）
- https://thinkingmachines.ai/news/inkling-2-mini/ （官方部落格）
- https://huggingface.co/blog/inkling2mini （Hugging Face 部落格：Transformers、llama.cpp、SGLang、MLX 用法）
- https://unsloth.ai/docs/models/inkling-2-mini （Unsloth GGUF 大小與指令）
- https://ollama.com/library/inkling-2-mini
- 使用者提供的 LinkedIn 貼文（Niels Rogge）：https://lnkd.in/p/gNs67ckz
