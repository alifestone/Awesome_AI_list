# edge0

- **分類**：推論與訓練引擎
- **連結**：https://github.com/Edge0-AI/Edge0
- **模型**：https://huggingface.co/Edge0/Edge0-35B-A3B-preview ・ https://huggingface.co/Edge0/Edge0-8B-A1B-preview
- **論文**：https://arxiv.org/abs/2609.18063

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：開源的「SSD 串流 MoE」推論框架，附兩個專門調校過的模型（Edge0-35B-A3B、Edge0-8B-A1B）。Python 版目前只支援 Apple Silicon Mac；另有 macOS、iOS、Android、Windows 四個平台各自的原生引擎與 app。

## 概述

edge0 讓大型稀疏 MoE 模型在消費級硬體上執行：專家權重留在 SSD、需要時才串流讀入，記憶體峰值由「當下啟用的專家」決定，而不是總參數量。做法是三件事組合：**SSD 專家卸載**、**prerouter**（訓練過的小 head，提前一步預測下一層要用哪些專家，讓讀取與運算重疊，作者稱 decode 最多 +59%），以及 **Recover-LoRA**（int4 base 凍結，用 FP 教師蒸餾訓練 LoRA，補回大部分量化損失；adapter 不合併，同一份唯讀 base 可配多組 adapter）。

兩個模型分別以 Qwen3.6-35B-A3B 與 Ling 3.0（bailing hybrid）為底，checkpoint、LoRA 與 prerouter 打包在同一個目錄，`edge0 serve <tier>` 即可直接跑完整流程。

repo 於 2026-09-08 建立，查詢當下（2026-11-06）約 9.1k 顆星、約 177 commits，最後推送 2026-11-06。

## 核心功能／特色

- **SSD 專家串流**：專家權重 mmap、按需讀取，不預先載入 RAM。
- **Prerouter 路由預測**：提前一步預測專家，載入與 forward 重疊；儲存延遲越高、模型越大、K 越大，效益越明顯。
- **Recover-LoRA**：4-bit 下回補量化損失；LoRA 與 prerouter 權重都是附來源中繼資料的 `.safetensors`。
- **transformers 風格 API**：`AutoModel`／`AutoConfig`／`AutoEngine` 依模型名稱或 `config.json` 自動判斷 tier。
- **OpenAI 相容伺服器**：`/v1/chat/completions`。
- **四個平台原生引擎**（2026-09-30 開源）：macOS（Rust，CLI／daemon／桌面 app）、iOS（Swift + MLX Swift）、Android（Kotlin + 原生引擎）、Windows（C++ + Vulkan）。

## 安裝與使用方式

Python 版需求：macOS + Apple Silicon、Python 3.10+（建議 3.12）、`mlx==0.30.6`；磁碟 35B 約 23 GB、8B 約 4.2 GB。

```bash
cd python
python3.12 -m venv .venv && .venv/bin/pip install -e '.[dev,fetch]'
.venv/bin/python scripts/fetch_models.py --tier edge0-35b --target-dir models
export EDGE0_35B_MODEL=$PWD/models/edge0-35b

edge0 demo edge0-35b
edge0 serve edge0-35b          # OpenAI 相容 API，預設 127.0.0.1:8000
edge0 chat edge0-35b --prompt "Explain streaming inference in one sentence."
```

作者自測（Python 版，Mac mini M4 Pro 24 GB，3.3k token prompt）：

| Tier | Decode | Prefill（冷／熱） | MLX allocator 峰值 |
|---|---|---|---|
| edge0-35b | 14.9–17.7 tok/s | 113 / 140 tok/s | 2.9 GiB |
| edge0-8b | 23.9–25.3 tok/s | 500 / 1428 tok/s | 1.0 GiB |

其他平台（各目錄 README 自述）：iPhone 16 Pro 上 35B decode 約 4.9 tok/s、8B 約 7.2 tok/s；Android 8 GB 手機跑 8B，35B 需 12 GB 以上；Windows 8 GB 可跑 8B、16 GB 以上可跑 35B（受分頁限制）；macOS app 需 M3 以上。

品質（作者以 OpenCompass 自測，int4 + adapter + prerouter vs. fp16 base）：35B 平均 79.2 vs. 83.2（-3.9）、8B 平均 69.9 vs. 72.7（-2.8）；MMLU-Pro 上 8B 反而高於 base。

## 適用情境

- 在 16～24 GB 的 Mac 上跑 35B 等級 MoE，當本機 OpenAI 相容後端。
- 在手機（iOS／Android）或 Windows PC 上離線跑 8B／35B MoE。
- 研究 SSD 專家卸載、路由預測與量化補償（附技術報告與架構文件）。

## 授權與成本

- 程式碼 **Apache-2.0**（含 vendored 第三方程式碼，見 `NOTICE`）。
- 兩個模型在 Hugging Face 標示 **Apache-2.0**；底層模型條款另見 Qwen3.6 與 Ling 3.0。
- 免費；成本為 5～23 GB 下載與磁碟空間。

## 限制與注意事項

- 「約 2.5 GB RAM 跑 35B」指的是 `mlx.core.get_peak_memory()`（MLX allocator 峰值），**不是程序 RSS**；mmap 的專家頁面、快取、tokenizer 都另外算，長 context 的 KV 也會再增加。
- Python 框架目前只支援 Apple Silicon；CUDA 後端與跨平台統一框架都排在 2026 Q4 roadmap。
- 只能跑它自己釋出的兩個 tier（模型是 preview 版）；換別的模型要自己訓練 LoRA 與 prerouter（有「Adding a model」文件）。
- 各平台引擎目前各自獨立實作，效能數字都是作者自測；手機上 35B 偏慢，8 GB 手機跑 8B 時 decode 會掉到 1–2 tok/s。

## 相關工具

- [TurboFieldfare](TurboFieldfare.md)：同樣在 Mac 上從 SSD 串流專家，但只跑 Gemma 4 26B-A4B。
- [Janas](Janas.md)：純 C 的 SSD 串流 MoE 引擎（Linux／Windows，Vulkan／NPU）。
- [Strata](Strata.md)、[Project Maya](Project-Maya.md)：在 NVIDIA／AMD 顯卡上把專家分層放 VRAM／RAM／SSD。

## 資料來源

- https://github.com/Edge0-AI/Edge0 （README 與 `ios/`、`android/`、`windows/`、`macos/` 的 README；查詢時約 9.1k 星）
- https://huggingface.co/Edge0/Edge0-35B-A3B-preview 、https://huggingface.co/Edge0/Edge0-8B-A1B-preview
- https://arxiv.org/abs/2609.18063 （The Other Half of the Memory Wall: Serving 35B MoEs from SSD with Trained Routing Prediction）
