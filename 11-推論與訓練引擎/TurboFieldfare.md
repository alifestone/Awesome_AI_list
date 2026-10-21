# TurboFieldfare

- **分類**：推論與訓練引擎
- **連結**：https://github.com/drumih/turbo-fieldfare

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：以 Swift + Metal 自寫的推論引擎，**只**跑 Gemma 4 26B-A4B IT 一個模型，**只**支援 Apple Silicon Mac（macOS 26）。不是 MLX 或 llama.cpp 的包裝。

## 概述

TurboFieldfare 讓 Gemma 4 26B-A4B（總參數 26B、每個 token 約啟用 3.88B）在 8 GB RAM 的 Mac 上執行：記憶體裡只放約 1.35 GB 的共用核心與 FP16 KV cache（合計約 2 GB），每個 token 需要的專家再從 SSD 串流讀取。整包含 Swift 函式庫、Mac app、CLI、串流安裝器與實驗性的本機 OpenAI 相容伺服器。

作者為 Andrey Mikhaylov（iOS／Metal 工程師），獨立研究專案，與 Google 無關。repo 於 2026-07-17 建立，查詢當下（2026-10-21）約 7.0k 顆星，最後推送 2026-10-15，尚無正式 release。

## 核心功能／特色

- **SSD 串流專家**：每層由 router 選出 top-8 專家，對照 16 格 LFU 快取，缺的用平行 `pread` 讀進 Metal 可見的緩衝區；讀取同時 GPU 先算共用專家分支。
- **量化**：MLX affine 4-bit（group 64），router 8-bit；模型在磁碟約 14.3 GB。
- **分塊 prefill**：每塊最多 128 token，讓同一個讀進來的專家服務多列，記憶體有上限。
- **串流安裝器**：從固定版本的 Hugging Face checkpoint 以 range request 讀取，直接重新打包成 `.gturbo` 格式，不在磁碟留第二份完整模型；可續傳，完成後驗證雜湊。
- **讀圖**（選用）：另裝約 1.1 GB 的 vision pack，需 M2 以上。
- **三種用法**：原生 Mac app（含本機對話紀錄、取樣與執行參數設定）、CLI、本機 OpenAI 相容 Chat Completions 伺服器（串流、function tools、前綴 prompt 重用）。
- **自寫 Metal kernel**：量化 GEMV、attention、MoE、normalization、RoPE、取樣等；作者記錄了 103 筆實驗結果。

## 安裝與使用方式

需求：Apple Silicon Mac（驗證目標為 8 GB M2 MacBook Air）、macOS 26 + Metal 4、Swift 6.2+（Xcode 或 Command Line Tools）、約 15 GB 空間；只支援 arm64。

```sh
git clone https://github.com/drumih/turbo-fieldfare.git
cd turbo-fieldfare
swift build -c release
.build/release/TurboFieldfareMac
# 在 app 裡選 Download Model（首次下載約 15 GB）→ Load Model → Generate

# 打包成可雙擊的 .app
Scripts/build_app.sh

# 本機 OpenAI 相容伺服器（http://127.0.0.1:8080/v1）
swift build -c release --product TurboFieldfareServer
.build/release/TurboFieldfareServer --model scratch/gemma4.gturbo
```

作者自測 decode 速度（README；依 prompt 長度、輸出長度、快取狀態與硬體而異）：

| 機器 | Decode |
|---|---:|
| 8 GB M2 MacBook Air | 5.1–6.3 tok/s |
| 24 GB M5 Pro | 31–35 tok/s |

## 適用情境

- 在 8 GB 的 MacBook 上離線跑 26B 等級的 MoE 模型。
- 以本機 OpenAI 相容 API 接 OpenCode 等工具。
- 研究 Metal 上的 SSD 專家串流、MoE kernel 與 KV cache 設計（附系統設計文件與實驗紀錄）。

## 授權與成本

- 原始碼與文件為 **Apache-2.0**。
- 模型權重不在 repo 內，由安裝器另外下載，適用 Gemma 4 原始條款（見 repo 的 `THIRD_PARTY_NOTICES.md`）。
- 免費；成本為約 15 GB 下載與磁碟空間。

## 限制與注意事項

- 只支援 Gemma 4 26B-A4B IT 一個模型；只支援 Apple Silicon、macOS 26 以上。
- 只吃文字與圖片（圖片需 M2 以上），不支援音訊與影片。
- 伺服器沒有遠端驗證與 TLS，只能留在 loopback；工具呼叫要由客戶端自行授權與執行。app 與 CLI 不執行工具。
- 同一時間只能有一個佔用模型的程序（app、CLI、伺服器或測試）。
- 速度數字主要來自作者的兩台 Mac；README 提醒模型可能重複或答錯。

## 相關工具

- [Janas](Janas.md)：同樣從 SSD 串流專家的本地 MoE 引擎，也支援 Gemma 4，但跑在 Linux／Windows（CPU 或 Vulkan）。
- [Strata](Strata.md)：在家用 PC 上把大型 MoE 專家分層放在 VRAM／RAM／SSD。
- [Project Maya](Project-Maya.md)：同樣只為特定模型打造的本地 MoE 引擎（NVIDIA／AMD GPU）。

## 資料來源

- https://github.com/drumih/turbo-fieldfare （README；查詢時約 7.0k 星、51 commits）
