# Betelgeuse

- **分類**：推論與訓練引擎
- **連結**：https://github.com/Betelgeuse-AI/Betelgeuse

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：llama.cpp 的 C++／CUDA fork，把大型 MoE 模型的路由專家按需從 NVMe 分頁到有上限的 VRAM 池，目標硬體是 **RTX 3060 12 GB + 16 GB RAM + 本機 NVMe**。README 自標 **experimental**：分頁路徑只針對一種 GPU（`sm_86`）與一種儲存配置驗證過，不是正式版。

## 概述

Betelgeuse（代號 Alpha-Orionis）把 dense 計算（attention、共享專家、路由頭）全部放在 GPU，路由專家則不常駐：不在 VRAM 的專家從 NVMe 讀出、快取在 pinned host 記憶體，需要時再升到 VRAM。每個被路由到的專家都以原量化精度完整計算，不剪枝、不跳過、不重新量化。

執行檔為 `bel-server`（OpenAI 相容 HTTP 伺服器）與 `bel-cli`（互動聊天）；llama C API 與 CMake target 名稱不變。repo 於 2026-10-31 建立，最新版 v0.6.0-alpha-orionis（2026-10-31），查詢當下（2026-11-18）約 170 顆星。

## 核心功能／特色

- **專家分頁**：`--moe-direct-io` 開啟按需分頁、VRAM 熱池與 in-stream CUDA doorbell；未命中的專家以 `io_uring` 依需求順序讀取，被逐出的專家可從 host victim cache（預設 8 GiB）重用。
- **Dense／專家拆檔**：小的 dense GGUF 保留 metadata、tokenizer 與所有非專家張量，專家原始量化位元組另存在 4 KiB 對齊的 `experts.bin`。缺位元組或讀取失敗會直接報錯，不會偷偷用零權重。
- **兩個認證過的模型**（README 自測）：

  | | DeepSeek-V4.1-Flash (1017) | Alpha-Orionis-XS（Qwen3.8 Flash Next） |
  |---|---|---|
  | 參數 | 748B（552B MoE + 196B Engram 表） | 約 125B（每 token 啟用 6B） |
  | 量化 | UD-Q2_K_XL 骨幹、IQ4_NL Engram | GSQ-RCO IQ2_XS |
  | 磁碟 | 約 310 GB | 約 68 GB（四檔 bundle） |
  | 推測解碼 | DSpark 草稿模型 | 無 |
  | 熱 decode | 18.92 tok/s | 22.03 tok/s（重複工作負載） |
  | 熱 prefill | 61.80 tok/s | 未另外量測 |

- **Engram 暫存**：DeepSeek 的 110.6 GB per-layer embedding 表留在 NVMe，每個 token 只用 `io_uring` 讀 48 列到小的 CUDA 張量，整張表不必放進 RAM。
- **記憶體上限**：範例以 `systemd-run -p MemoryMax=12G -p MemorySwapMax=0` 跑，DeepSeek 實測 VRAM 峰值 11.4 GB、cgroup 峰值 10.61 GiB、不用 swap。
- **同機比較**（Qwen3.8 Flash Next，使用者回報）：上游 llama.cpp 0.9 tok/s、[Strata](Strata.md) 8 tok/s、Betelgeuse 熱跑 22.03 tok/s。

## 安裝與使用方式

需求：Linux x86-64、CUDA `sm_86`（RTX 3060 12 GB）、本機 NVMe、C++17 編譯器、CMake、CUDA toolkit、liburing 開發檔（另需 llama.cpp 一般建置相依）。Btrfs 上要先對模型目錄 `chattr +C`。

```bash
cmake -S . -B build \
    -DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=86 \
    -DLLAMA_BUILD_TOOLS=ON
cmake --build build --config Release --target llama-server llama-cli -j6
# 產出 build/bin/bel-server、build/bin/bel-cli

# 下載 Qwen3.8 Flash Next bundle（約 68 GB）
hf download Betelgeuse-AI/Alpha-Orionis-XS \
    Qwen3.8-Flash-Next-Dense.gguf experts.bin \
    Qwen3.8-Flash-Next-PLE.gguf profile-qwen4exp.bin \
    --local-dir /path/to/Alpha-Orionis-XS
export BUNDLE=/path/to/Alpha-Orionis-XS

export MOE_HOT_K=0 MOE_PREKICK=0 MOE_SEED_BUDGET_MS=0
systemd-run --user --scope --quiet -p MemoryMax=12G -p MemorySwapMax=0 \
    build/bin/bel-server \
    -m "$BUNDLE/Qwen3.8-Flash-Next-Dense.gguf" \
    --moe-direct-io --moe-pack-dir "$BUNDLE" \
    --moe-profile "$BUNDLE/profile-qwen4exp.bin" --moe-slots 5000 \
    -ngl 99 -np 1 -c 512 -ub 64 -t 6 \
    --cache-warmup 0 --host 127.0.0.1 --port 8080
```

DeepSeek-V4.1-Flash 另加 `-md` 指定 DSpark 草稿模型與 `--spec-type draft-dspark`，參數見 README。`--auto-warm` 可在開服前先生成並重播一次以預熱快取（實測多約 42 秒啟動）。

## 適用情境

- 手上只有 RTX 3060 12 GB 等級顯卡與 16 GB RAM，想在本機跑 DeepSeek-V4.1-Flash 或 Qwen3.8 Flash Next。
- 研究 MoE 專家分頁、VRAM 熱池、`io_uring` 串流與 Engram 表暫存的實作。
- 比較同硬體下 llama.cpp、Strata 與分頁 fork 的速度差異。

## 授權與成本

- 引擎為 **MIT**（llama.cpp／ggml fork，保留上游聲明）。
- 模型權重**不在** MIT 範圍內：Alpha-Orionis-XS 來源量化 repo 標 Apache-2.0，但上游 Qwen Community License 1.0 對商業 MaaS 與 AI 工作助理有限制；DeepSeek-V4.1-Flash 與 DSpark 依各自上游條款。
- 軟體免費；成本為硬體與數十到數百 GB 的 NVMe 空間及下載流量。

## 限制與注意事項

- **實驗性**：分頁路徑只認證 `sm_86` + Linux + 本機 NVMe；其他 GPU、純 CPU、非 Linux 與其他後端都未認證。
- 每個程序只能一個分頁 context，須 `-np 1`，不能平行服務多個請求；已記錄的設定只有 `-c 512` 這種很小的 context，更大的 context 或 batch 需自行驗證。
- 速度數字是熱跑（快取已填滿）結果；冷啟動要付 SSD 串流成本（DeepSeek 冷跑約 5.6 tok/s），不代表 prefill、冷啟動或跨工作負載速度。16.80 與 22.03 tok/s 來自不同次執行，不是配對基準。
- DSpark 推測解碼只對 DeepSeek 設定認證；Qwen bundle 無 MTP／推測加速，歷史 MTP 測試結果偏離標準答案。
- 拆過的 dense GGUF 需要本 fork 的 pager，不能在上游 llama.cpp 載入；上游執行檔與容器映像不含分頁功能。
- 專案很新（建立不到三週、只有一個 release）。

## 相關工具

- [Strata](Strata.md)：同樣讓遊戲 PC 跑 Qwen3.8-Flash-Next 的分層 MoE 引擎；Betelgeuse README 列出同機 Strata 8 tok/s 作比較。
- [Project Maya](Project-Maya.md)：也跑 DeepSeek-V4.1-Flash-1017，但目標是 24 GB 以上顯卡與多 GPU。
- [colibri](colibri.md)、[Janas](Janas.md)：其他以 NVMe 串流專家的本地 MoE 引擎。
- [llama.cpp](https://github.com/ggml-org/llama.cpp)：上游專案。

## 資料來源

- https://github.com/Betelgeuse-AI/Betelgeuse
- https://huggingface.co/Betelgeuse-AI/Alpha-Orionis-XS
