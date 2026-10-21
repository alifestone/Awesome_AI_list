# Project Maya

- **分類**：推論與訓練引擎
- **連結**：https://github.com/mw00/project-maya

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：從 [Strata](Strata.md) 的引擎改寫而來的本地推論引擎，專為 **GLM-5.3-Flash**（321B MoE）與 **DeepSeek-V4.1-Flash-1017**（748B MoE）兩個模型打造，不是通用引擎。AMD 與 Windows 支援仍屬實驗性。

## 概述

Project Maya 讓通常要資料中心才能跑的大型 MoE 模型，在自己的 GPU（一張到 16 張，NVIDIA 或 AMD，Linux 或 Windows）上私有執行。每個模型各有一套專用引擎（DeepSeek 版為 `maya-ds4`），把對話最常用的專家放 GPU、次常用的放 RAM、其餘留在 NVMe SSD，並在對話中動態搬移；啟動時會量測 GPU、CPU、RAM、SSD 並自動調校。整包含引擎、伺服器、瀏覽器儀表板、OpenAI／Anthropic 相容 API 與量化工具。

由 Peasant Smith（@mw00）建立與主導，@needmorevram 共同維護。repo 於 2026-10-06 建立，查詢當下（2026-10-21）約 1.3k 顆星，最新版 v1.1.19（2026-10-20），更新頻繁。

## 核心功能／特色

- **專家三層分層**：VRAM／RAM／NVMe SSD，依使用頻率動態調整；RAM 越多越快。
- **Maya 自製量化**（GLM-5.3-Flash，皆保留 MTP 草稿層）：

  | 版本 | 大小 | 適用 | 相對 FP8 的零樣本準確率 |
  |---|---:|---|---|
  | Maya-S（預設） | 96.5 GB | 記憶體（RAM＋VRAM）較少 | 97.9% |
  | Maya-S24 | 94.7 GB | 24 GB 以下的顯卡 | 97.7% |
  | Maya-M | 116 GB | 較大記憶體，偏重工具呼叫與前端程式碼 | 97.9% |
  | Maya-M-Derisked | 116 GB | Maya-M 加上降低拒答的權重修改（實驗性） | 尚未量測 |
  | Maya-L | 156.3 GB | 最大記憶體 | 99.2% |

- **DeepSeek-V4.1-Flash-1017**：Maya-S 量化約 340 GB（與原模型下一個 token 相同率 92.6%），另可選 unsloth GGUF 或 LibertAIDAI 的 EXL3；附 DSpark 草稿模型（setup 實測變快才保留）與視覺塔。
- **API**：OpenAI 相容 `/v1`、Anthropic 相容 `/v1/messages`（可直接接 Claude Code）、`/v1/responses`；工具呼叫串流輸出。
- **瀏覽器介面**：聊天、即時 Monitor（模型與硬體狀態）、讀圖、思考等級（Off／Low／High／Max）。
- **平行請求**：`--parallel` 最多 8 個請求同時處理（GLM-5.3-Flash）。
- **長上下文**：KV streaming 把 attention 快取放 RAM、VRAM 只留視窗，單張 RTX 3090 可跑 1M context。
- **DFlash2 草稿模型**（選用，RTX 30／A100 以上）：每輪最多草擬 7 個 token，輸出不變。
- **自動調校**：`./maya.sh --calibrate` 約 10～15 分鐘依硬體調參。

## 安裝與使用方式

需求（README）：

- **GPU**：NVIDIA compute capability 7.0 以上（V100、RTX 20 以上）；Pascal 實驗性。AMD（實驗性）：RX 7900 XT/XTX、R9700／RX 9070、Strix Halo／Gorgon Halo 等，需 ROCm 7。
- **RAM**：32 GB 可跑，越多越快。
- **磁碟**：快速 NVMe SSD；Maya-S 約 100 GB、Maya-L 約 160 GB、DeepSeek Maya-S 約 350 GB。不可用傳統硬碟。
- **系統**：Linux x86-64（建議 AVX2）、NVIDIA 驅動、CUDA 12.x（RTX 20 以上可用 CUDA 13）、g++、Python 3.10+；Windows 10/11 實驗性；不支援 WSL2。

```sh
git clone https://github.com/mw00/project-maya.git && cd project-maya
./setup.sh                      # Windows 改用 START-MAYA.bat
# 建置約 20～40 分鐘（另加下載），完成後開 http://127.0.0.1:8080

# 改跑 DeepSeek-V4.1-Flash-1017
./setup.sh --model DeepSeek-V4.1-Flash-1017

# 讓 Claude Code 使用 Maya
ANTHROPIC_BASE_URL=http://127.0.0.1:8080

# 依硬體調校、跑效能測試、產生問題回報
./maya.sh --calibrate
./maya.sh --bench
./maya.sh --report

# 開放區網存取（務必設 key）
./maya.sh --setup --host 0.0.0.0 --api-key <secret>
```

社群回報速度（README 摘錄，未經獨立驗證；decode tokens/s）：

| 機器 | 模型 | Decode |
|---|---|---:|
| 2× H100 80 GB | Maya-L | 122.4 |
| 4× RTX 4090 24 GB | Maya-S24 | 118 |
| RTX PRO 6000 Blackwell 96 GB | Maya-M | 81.0 |
| RTX 5090 32 GB + 96 GB DDR5 | Maya-M | 30+ |
| 1× RTX 3090 24 GB | Maya-S24 | 26.0 |
| RTX 4090 24 GB + 64 GB RAM | Maya-S24 | 16.6 |

## 適用情境

- 想在自己的工作站或多卡機器上私有執行 GLM-5.3-Flash 或 DeepSeek-V4.1-Flash 等級的大模型。
- 以本地 OpenAI／Anthropic 相容 API 替 Claude Code 等 coding agent 提供後端模型，可多 session 平行。
- 研究 MoE 專家分層卸載、KV streaming、推測解碼的實作。

## 授權與成本

- 軟體為 **MIT** 授權；基於 Strata（MIT）與 ggml／llama.cpp（MIT），另含 exllamav3、beellama.cpp 的程式碼。
- 模型：GLM-5.3-Flash 與 DeepSeek-V4.1-Flash-1017 皆為 MIT。選用的 DFlash2 草稿模型為 **CC BY-NC-ND 4.0（僅限非商業）**，只有主動選用才會下載。
- 軟體免費；主要成本為硬體（GPU、大量 RAM、數百 GB NVMe）與下載流量。

## 限制與注意事項

- 只支援 GLM-5.3-Flash 與 DeepSeek-V4.1-Flash-1017 兩個模型。
- AMD、Windows、Pascal 顯卡皆為實驗性；AMD 上 GLM-5.3-Flash 只能讀文字。
- 執行時引擎會 pin 住幾乎所有空閒 RAM（只留約 6 GB），其他程式可用記憶體很少；啟動需數分鐘。
- 空閒 RAM 不足時會改從 SSD 讀專家，速度大降。
- Maya-M-Derisked 為降低拒答的權重修改版，品質尚未量測。
- 速度數字為社群自報，不同版本與設定測得。
- 專案很新、版本更新頻繁（兩週內到 v1.1.19），行為可能常變。

## 相關工具

- [Strata](Strata.md)：Maya 引擎、伺服器與儀表板的起點。
- [DeepInfer](DeepInfer.md)：DeepSeek 官方的資料中心級推論框架，同樣跑 DeepSeek-V4.1-Flash，但需要 SM100／昇騰 950。
- [Janas](Janas.md)：另一個以 SSD 串流專家的本地 MoE 引擎。
- [llama.cpp / ggml](https://github.com/ggml-org/llama.cpp)：量化格式與部分 kernel 來源。

## 資料來源

- https://github.com/mw00/project-maya
- https://huggingface.co/peasantsmith
