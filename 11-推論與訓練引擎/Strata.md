# Strata

- **分類**：推論與訓練引擎
- **連結**：https://github.com/Niko1221/Strata

## 原清單說明

在消費級顯卡上跑大型 MoE 模型的本地推論引擎，把專家權重分層放在 VRAM / RAM。MIT。

> 查證補充：依 README，Strata 並非通用的「任意 MoE 模型」引擎，而是專為 **Qwen3.8-Flash-Next**（及其壓縮／微調變體）打造；README 未宣稱支援其他 MoE 模型。專家權重實際分為 VRAM / RAM / SSD 三層（SSD 存放查表資料）。

## 概述

Strata 是一個開源的本地推論引擎，目標是讓「通常需要伺服器才能跑」的大型 MoE 模型 Qwen3.8-Flash-Next 能在一般遊戲 PC（NVIDIA 或 AMD 顯卡）上執行，資料不離開本機。提供聊天、程式碼生成、讀圖，並可接到各種應用程式與 coding agent。README 提供英文及簡中、日、德、法、西、葡（巴西）等譯本。

## 核心功能／特色

- **一鍵安裝**：Windows 與 Linux 都有安裝腳本。
- **本地 API**（`http://127.0.0.1:8080`）：同時提供 OpenAI 相容（`/v1`）、Anthropic 相容（`/v1/messages`）與 OpenAI Responses（`/v1/responses`）端點，可直接給 Claude Code 等工具使用。
- **瀏覽器介面**：Chat、即時 Monitor（顯示模型與 GPU/CPU/RAM 狀態）、About 三個分頁。
- **思考模式**：off / low / medium / high 四段。
- **讀圖**（選用）；**MCP Server** 讓 AI 工具能安裝、啟動、停止 Strata。
- **多 GPU**（2～3 張卡）、選用的平行請求、以 API key 保護的手機／區網存取。
- **推測解碼（speculative decoding）**：README 宣稱整體輸出加速 1.6～1.8 倍，且因由模型驗證，輸出品質不變。
- **可選模型變體**：Q2_0、IQ2_XS、IQ3_XXS、IQ3_S（依序由快到慢、品質遞增）；Coder（移除一半專家、專注程式碼，可塞進 32 GB RAM）；Swift 1.5（思考時間較短的微調版）；Unsloth UD-IQ4_XS（約 94 GB 下載）與 UD-Q4_K_XL（實驗性）；OrcaRouter Uncensored IQ3_XXS（需手動設定）。

## 技術架構或運作原理

依 README 與 `docs/HOW_IT_WORKS.md`：

- 模型共有 **24,576 個小專家**，每個 token 只用其中 10 個。
- **GPU（VRAM）**：放常駐層（attention、router、shared experts、輸出頭、MTP 草稿層）以及一個「專家快取」，用最常被使用的專家填滿剩餘 VRAM，並在對話中動態調整；每多 1 GB VRAM 約可多放 700 個專家。
- **系統 RAM**：以 pinned 方式存放全部 24,576 個專家；另有低 RAM 模式，只存 GPU 沒放的專家。
- **CPU**：就地計算不在 GPU 上的專家，與 GPU 同時運算；使用 AVX-512 / AVX2 kernel 與 ggml 的 i-quant kernel。
- **SSD**：存放 28.8 GB 的 n-gram 查表，每個 token 透過作業系統快取讀取少量資料。
- **推測解碼**：MTP 層一次草擬最多 3 個 token，經 48 層一次驗證，平均每次通過 2.4～3.2 個 token；對重複上下文的文字（如程式碼修改）另有 prompt lookup，最多草擬 5 個 token（程式碼修改快 6～11%）。
- **長提示**：以最多 8,192 token 為一塊分段處理（README 稱可超過 1,000 tokens/s）；某層 attention 運算時，下一層專家同時經 PCIe 串流到 GPU；對話會被保留，後續訊息只需處理新增文字。
- 同一套引擎支援 NVIDIA（CUDA）與 AMD（HIP）；使用部分 llama.cpp / ggml 程式碼（repo 內含 `third_party/ggml`），README 並未稱其為 llama.cpp 的 fork。

## 安裝與使用方式

硬體需求（README）：

- **GPU**：NVIDIA RTX 20/30/40/50 系列，或 AMD RX 6800/6900、7900、7800/7700 XT、9060 XT、9070/9070 XT、Radeon AI PRO R9700；至少 12 GB VRAM。
- **RAM**：最少 32 GB；64 GB 可跑所有尺寸。
- **磁碟**：約 80 GB 可用空間，建議 SSD。
- **OS**：Windows 10/11 或 Linux（需新版驅動）。未提及 macOS／Apple 硬體。

常用指令：

```bash
# 首次安裝／之後再次啟動
START-HERE.bat            # Windows（雙擊）
./setup.sh                # Linux

# 只更新
UPDATE.bat / ./update.sh

# 跑效能測試
BENCH.bat / ./bench.sh

# 新增模型
SETUP.bat / ./setup.sh --setup

# 開放區網存取（需 API key）
START-HERE.bat --setup --host 0.0.0.0 --api-key <secret>

# 讓 Claude Code 使用 Strata
ANTHROPIC_BASE_URL=http://127.0.0.1:8080
```

- 預設模型下載約 70 GB，中斷時重新執行安裝程式即可續傳；首次載入模型可能讓電腦凍結 1～3 分鐘。
- 平行請求可在設定中加入 `"parallel": 2`。
- 依 RAM 選模型：32 GB → Coder；48 GB → IQ2_XS 或 Q2_0；64 GB → IQ2_XS（推薦）、IQ3_XXS、IQ3_S；96 GB 以上 → IQ3_S 或 UD-IQ4_XS。

作者自測數據（未經獨立驗證；輸出 tokens/s ／ 讀 32K 提示 tokens/s）：

| 平台 | Q2_0 | IQ2_XS | IQ3_XXS | IQ3_S | Coder |
|---|---|---|---|---|---|
| RTX 5070 12GB + Ryzen 5 7600 + 64GB | 94 / 2,650 | 79 / 2,090 | 62 / 1,750 | 53 / 1,620 | 55 / 2,180 |
| RX 9070 XT 16GB + Ryzen 9 3900X + 47GB | 60 / 1,160 | 52 / 1,110 | — | — | 44 / 1,420 |

## 適用情境

- 想在個人電腦（12 GB 以上顯卡 + 32～64 GB RAM）本地執行 Qwen3.8-Flash-Next，不把資料送到雲端。
- 以本地 OpenAI／Anthropic 相容 API 替 Claude Code 等 coding agent 提供後端模型。
- 研究「MoE 專家分層卸載（VRAM/RAM/SSD）」的實作參考。

## 授權與成本

- Strata 本身為 **MIT** 授權；README 註明部分元件與所有模型各有其授權。
- 軟體免費，主要成本為硬體（顯卡、大量 RAM、約 80 GB 以上磁碟）與下載流量。
- 致謝對象：Qwen 團隊（模型）、ISTA-DASLab、UkisAI、Unsloth（壓縮版本）、llama.cpp/ggml。

## 限制與注意事項

- 只針對 Qwen3.8-Flash-Next 系列；README 雖提到可「新增模型」，但未說明支援哪些其他模型（資料不足）。
- Coder 版在程式碼以外（包括中文等 CJK 文字）表現較弱。
- AMD 顯卡在 Windows 上暫不支援讀圖。
- UD-Q4_K_XL 在 64 GB PC 上只有約 7～8.5 tokens/s。
- 預設一次只處理一個請求；長對話第一則訊息約每 30,000 token 需 1 分鐘。
- 可用 RAM 不足會極慢或讓引擎當掉。
- 較舊的 NVIDIA/AMD 卡、Intel Arc、AMD Strix Halo（Linux、需自行編譯）、無 AVX2 的 CPU 皆屬實驗性、由社群測試。
- 效能數字為作者自報，不同版本（0.1.26 / 0.1.36）測得。

## 相關工具

- [llama.cpp / ggml](https://github.com/ggml-org/llama.cpp)：Strata 使用其部分程式碼。
- [Strata Easy TW](Strata-Easy-TW.md)：非官方繁中 Windows 安裝導覽器（測試版）。
- [Project Maya](Project-Maya.md)：從 Strata 引擎改寫，改跑 GLM-5.3-Flash 與 DeepSeek-V4.1-Flash-1017。
- [Unsloth](https://github.com/unslothai/unsloth)：提供 Strata 可選用的 UD 量化版本（本清單亦有收錄）。
- 其他本地推論方案（如 Ollama、LM Studio 等）可作為比較對象；本條目未逐一查證其細節。

## 資料來源

- https://github.com/Niko1221/Strata
- https://github.com/Niko1221/Strata/blob/main/docs/HOW_IT_WORKS.md
