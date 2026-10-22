# Janas

- **分類**：推論與訓練引擎
- **連結**：https://github.com/prabanta-dev/janas

## 原清單說明

（使用者新增，無原清單說明。）以純 C 寫成的本地 MoE 語言模型推論引擎，讓權重留在 SSD、需要的專家再串流進記憶體。

## 概述

Janas 是一組以 C 撰寫、除 C 函式庫外無其他相依的 AI 工具，第一個元件 Janas-LLM 可在一般電腦（CPU 或 GPU，Intel Core Ultra 另可用 NPU）上執行大型 MoE 語言模型。核心做法是「權重留在磁碟」：每個 token 需要的專家從 NVMe SSD 串流讀取，常用專家快取在記憶體，因此能跑比 RAM 還大的模型。作者為 Maurizio "camauri" Cammalleri。

## 核心功能／特色

- **支援模型**：Qwen3、Qwen3.5、Qwen3.6、Qwen3-Next、Qwen3-Coder-Next、Gemma 4；需轉成 `.jns`（v2）格式，轉好的模型放在 Hugging Face。
- **推測解碼（drafts）**：Qwen3.5／3.6／Next 用內建預測區塊，Gemma 4 用小型輔助模型；增益依文字而異（作者提到義大利文散文增益較低）。
- **GPU**：Vulkan 後端；`JANAS_GPU=0` 可關閉。
- **Intel NPU（2026-10-21 新增）**：Core Ultra 的 NPU 可負責讀取提示（64 token 以上的批次），回覆仍由 CPU 產生。Janas 自己產生 OpenVINO IR 圖、執行期才開啟 Level Zero 驅動（不連結，沒裝就不影響）；權重以 8 位元複製到 NPU。小型 dense 模型提示讀取快 1.5～2.6 倍（作者實測 Qwen3.5-2B 729 tok/s、Qwen3-4B 333 tok/s）；MoE 與較大的模型在作者機器上仍以 GPU 較快，引擎會自動選。`JANAS_NPU=0` 可關閉。
- **手動指定裝置**：`--prompt-on`、`--drafts-on`、`--reply-on` 分別指定讀提示、驗證 drafts、寫回覆用 `cpu`／`gpu`／`npu`（可用 `+` 合用、用逗號列出讓引擎實測挑最快）；預設 `auto` 由引擎實測決定。
- **工具**：`janas-chat`（終端聊天）、`janas-server`（OpenAI 相容 HTTP API + 網頁聊天）、`janas-mcp`（以 MCP 提供給 Claude Code、編輯器）、`janas-bench`（測機器）、`janas-get`（下載模型）與轉換／檢查工具。
- **程式碼補全**：`/v1/completions`（含 suffix）與 llama.cpp 的 `/infill`，可接 VSCodium、VS Code、llama.vscode、Continue。
- **函式庫**：可由 C、FreeBASIC／BASIC MODERN、Node.js／TypeScript 呼叫；另有航班、地震、天氣、地圖、價格、GitHub、git、Wikipedia 等服務整合。

## 技術架構或運作原理

引擎把閒置記憶體當作專家快取，以 `O_DIRECT` 讀碟；執行緒數量與是否動用 GPU／NPU 都靠實測選擇：最初幾輪嘗試不同組態、保留最快者，並偶爾重測，結果存在 `~/.cache/janas`，以適應不同硬體。作者稱引擎自選的組態與最佳組態差距在讀取 1.5%、寫入 2.6% 以內。

## 安裝與使用方式

- **Linux x86-64**（Ubuntu 22.04、Debian 12 以上）：下載解壓 release tarball，執行 `./janas-chat`，會列出模型並下載、檢查。
- **Windows** 10（1903+）／11 x86-64：解壓 zip 後在 `janas` 資料夾執行 `.\janas-chat`。
- **自行編譯**：安裝 `build-essential`（GPU 另需 `libvulkan-dev glslang-tools vulkan-tools`），執行 `./build.sh`；加 `release test` 會跑測試。
- 用 `janas-bench` 量測；`--cache <GiB>` 可限制記憶體用量；`Ctrl-C` 停止回覆、`Ctrl-D` 離開。

## 適用情境

- 在筆電或一般 PC 上跑 80B 等級的 MoE 模型（資料不上雲）。
- 為 Claude Code 或編輯器提供本地模型後端（API／MCP）。
- 研究「SSD 串流專家 + 快取」的推論做法。

## 授權與成本

- **授權**：GPL-3.0 或更新版；`janas-server` 含 GNU libmicrohttpd（LGPL 2.1+ 或 eCos）與 yyjson（MIT），`libjanas_mcp` 含 Mbed TLS（Apache-2.0 或 GPL-2.0+）。
- 模型不受 Janas 授權涵蓋，轉換後的 `.jns` 沿用原模型授權，散布前請確認。
- **成本**：免費。

## 限制與注意事項

- 作者稱其為「實驗，不是產品」，API 與命令列可能不預告更動。
- 刻意積極使用記憶體與磁碟；餘裕不足的機器可能大量 swap 或桌面無回應，作者也提到曾有 GPU 驅動重置導致桌面當掉。
- 只在一台機器上測過（Intel Core Ultra 9 185H、內顯 Arc、32 GB RAM、NVMe）；AMD CPU（尤其無 AVX-VNNI）、獨立顯卡、較慢磁碟皆未測。
- NPU 只在第一代 Core Ultra（Meteor Lake）的 Linux 上試過，需裝 Intel `linux-npu-driver` 與 Level Zero loader、使用者在 `render` 群組；Windows 版尚無 NPU 路徑。第一次讀提示要先等 NPU 準備（複製權重、編譯圖），作者實測 7～53 秒。
- 效能數字為作者自測（2026-10-21），單一機器、兩邊量法不盡相同，非獨立評測：Qwen3-Next-80B-A3B（48.4 GB，大於 RAM）不含 drafts 寫入 26.4 tok/s 對 llama.cpp 3.0；1,024 token 提示讀取 68.4 對 17.7 tok/s；含 drafts 在 bench 約 37 tok/s、實際聊天 31～35（快取暖）、冷啟動 16～20。作者稱在比較的 17 個模型／檔案上讀寫都比 llama.cpp 快，但用 NPU 讀取的列，llama.cpp 對照用的是 GPU（其 OpenVINO NPU 後端在多數模型或 768 token 以上會當掉），部分 llama.cpp 數字為 10/11 舊值。
- 資料寫入 `~/.cache/janas` 與使用者指定的輸出位置。

## 相關工具

- [Strata](Strata.md)：同樣讓大型 MoE 模型在消費級硬體執行（分層放 VRAM／RAM／SSD）
- [Unsloth](Unsloth.md)：微調與執行本地模型
- [TurboFieldfare](TurboFieldfare.md)：同樣從 SSD 串流專家，專跑 Gemma 4 26B-A4B，限 Apple Silicon Mac

## 資料來源

- https://github.com/prabanta-dev/janas （README；2026-10-23 查詢時約 460 星、76 commits）
