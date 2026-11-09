# colibri

- **分類**：推論與訓練引擎
- **連結**：https://github.com/JustVugg/colibri
- **網站**：https://justvugg.github.io/colibri

## 原清單說明

（使用者新增，無原清單說明。）以 C 寫成的分層 MoE 推論引擎：熱門專家放 GPU（CUDA、Vulkan），溫的放 RAM，冷的從 NVMe 串流，在自己現有的硬體上跑前沿 MoE 模型。

## 概述

colibri（colibrì，義大利文「蜂鳥」，口號「小巧引擎，龐大模型」）是 Vincenzo Fornaro 發起的開源推論引擎。出發點是 MoE 模型每個 token 只用到一小部分參數：GLM-5.2 有 744B 參數，每個 token 約用 40B，其中只有約 11 GB 的路由專家會隨 token 改變。所以模型不必整個放進高速記憶體，只要「放對地方」：稠密部分（注意力、共享專家、嵌入）常駐 RAM，路由專家留在硬碟、需要時才讀，中間有一個會學習你常用哪些專家的快取；有 GPU 時再把最熱門的專家與稠密層放上去。專案強調「配置只影響速度」，不論專家從 VRAM、RAM 或硬碟回應，路由決策與權重精度都一樣，預設也不會悄悄改變模型精度或路由。

純 C 實作，每個模型家族一個檔案，執行期不需要 BLAS 或 Python（Python 只用在安裝程式、啟動器、轉換工具與 API gateway），GPU 不是必要條件。

## 核心功能／特色

- **13 個引擎**：10 個語言模型引擎，涵蓋 GLM-5.2/5.3（也跑 Mistral-Large-4）、GLM-5.3-Flash、Inkling、Kimi K3（2.8T）、DeepSeek V4 Flash、DeepSeek V4.1 Flash、MiMo-V2.6 Flash／Pro、Qwen3.8-Flash-Next、Qwen3.6（也跑 Qwen3-Coder、Qwen3.8-27B、Flint、Muse Spark Open、LFM3-VL）與 OLMoE；1 個畫圖引擎 Qwen-Image-2.1；2 個決策模型引擎 Laya 與 GLiNER2.5-Decide（第三個決策模型 Clef 跑在 Qwen3.6 引擎上）。
- **直接讀 GGUF**：`./coli import` 接收已發布的 GGUF，不轉換、不重新量化，IQ1_S 到 Q8_0、F16、BF16、MXFP4 的區塊都照檔案原樣執行，CPU、Vulkan、CUDA 皆可。
- **一步安裝**：`START-HERE.bat`／`./start-here.sh` 會檢查 RAM、硬碟、CPU、GPU，推薦放得下的模型，在本機編譯引擎（沒有編譯器就下載預建版本），可續傳下載，最後啟動伺服器並開啟瀏覽器儀表板。`--list` 列出每個模型與本機的對照及放不下的原因。
- **GPU 後端**：Vulkan 1.2 支援任何廠商的內顯或獨顯（GPU 上的專家快取 + 把整層錄成一次提交的「稠密鏈」）；CUDA 支援 NVIDIA（每個引擎都有 GPU 路由專家層級，Windows 版另附 CUDA DLL）；Metal 支援 Apple Silicon（部分引擎）；另有 HIP 相容層。沒有 Resizable BAR 的顯卡會自動改走暫存緩衝區。
- **OpenAI／Anthropic 相容伺服器**（`coli serve`）：`/v1/chat/completions`、`/v1/completions`、`/v1/messages`，支援串流、JSON 回覆、logprobs、工具呼叫（Inkling 與 OLMoE 以外）、圖片輸入（GLM-5.3-Flash、DeepSeek V4.1 Flash、MiMo、Qwen3.8 等），可直接當 Claude Code 的後端；`/v1/images/generations` 用 Qwen-Image-2.1 出圖；`--kv-slots N` 最多同時保留 16 個對話並一起解碼。
- **System One 決策 API**（`POST /v1/systemone`）：給一段狀態與帶型別的封閉式問題（`choice`、`noul`、`score`），回傳每個選項的機率與信心值，不生成文字，所以答案不會跑出清單之外。可用任何能跑的聊天模型（讀出選項機率）或三個原生決策模型。請求與回覆格式與 TypeSafe 的 Jev API 相同，Jev 用戶端只要改 base URL 就能改連 colibri。
- **介面**：`coli chat` 終端聊天（可直接在終端畫圖、`/decide` 做決策）；`coli web` 儀表板（聊天、System One、即時顯示每個專家觸發的 Brain 頁、逐階段的 Profiling 頁）；`coli ui` 新聊天介面（推理區塊、看圖、網頁搜尋、專家地圖、監視器、已指向 colibri 的程式設計代理，七種語言）。
- **讓 AI 助手代裝**：`docs/AI_SETUP.md` 把每步寫成指令給 coding agent，下載模型或裝系統套件前會先問使用者；也有 MCP 伺服器 `coli mcp`（偵測硬體、推薦模型、安裝、啟動、停止）。

## 技術架構或運作原理

每個 token 的每一層都走五步：路由、聯集、配置、重疊、學習。

- **權重的 JIT**：像 JIT 編譯器只編熱點路徑，colibri 依實測的路由熱度決定專家放 VRAM、RAM 或留在硬碟：逐層 LRU 快取，加上一組從你自己的對話學到的固定熱門專家（`.coli_usage`，每輪更新），所以越用越快。
- **不為硬碟等兩次**：一個專家的三個矩陣用一次 `pread` 讀完；載入器在常駐專家運算時同時讀缺少的專家；路由前瞻執行緒預先載入下一層（GLM-5.2 提前一層有 71.6% 可預測）。`DIRECT=1`（O_DIRECT）在快的 NVMe 上常有大幅收益。
- **多顆 SSD**：`COLI_MODEL_MIRROR` 同時從第二顆硬碟上的副本讀取，兩顆獨立控制器的 NVMe 實測解碼 +37.5%。
- **從筆電到機架**：25 GB 筆電上每個專家都從硬碟串流；大主機上所有專家常駐（`CUDA_EXPERT_GB=auto PIN_GB=all`）。`COLI_NUMA=1` 分散到多插槽記憶體控制器，另有本機叢集模式在其他機器上跑路由專家。
- **推測解碼只在划算時開**：GLM-5.2 的 int8 MTP head 每次前向可起草 2.2–2.8 token；Qwen3.8-Flash-Next 的 MTP head 預設開啟、輸出相同下提升 16–20%；DeepSeek V4 因起草成本高於節省而保持關閉。
- **忠實性**：每個引擎都在 CI 中與模型參考實作對照；Vulkan 路徑也與 CPU 輸出對照（加總順序不同，長回答可能差一個字）。GLM-5.2 的 MLA 壓縮 KV 狀態重開後保留，重開對話不必重讀提示。

## 安裝與使用方式

- **需求**：至少 8 GB RAM（16 GB 以上更好），最小模型需 22 GB 硬碟空間，需要網路；顯卡非必要。
- **Windows**：Download ZIP 解壓後按兩下 `START-HERE.bat`（缺 Python 會提議安裝）。
- **Linux**：`sudo apt install git python3 build-essential` → `git clone https://github.com/JustVugg/colibri` → `cd colibri && ./start-here.sh`。
- **macOS**：`xcode-select --install`、`brew install libomp git python`，再 clone 並執行 `./start-here.sh`（一步安裝建置 CPU 版，Metal 需從原始碼 `METAL=1` 或用 release 壓縮檔）。
- 常用選項：`--model ID` 指定模型、`--yes` 全採推薦、`--dir DIR` 把模型放到別顆硬碟（預設 `~/colibri-models`）、`--backend vulkan|cuda|cpu`、`--model-dir DIR` 用已下載的模型。
- 之後再執行同一個腳本就直接啟動；`c/coli status`、`c/coli stop`、`c/coli logs -n 50` 管理背景伺服器。
- 伺服器預設位址：瀏覽器 `http://127.0.0.1:8000/`、OpenAI base URL `http://127.0.0.1:8000/v1`、Anthropic base URL `http://127.0.0.1:8000`。
- 手動安裝：從 Releases 下載平台壓縮檔（Linux x86_64、macOS、Windows），或在 `c/` 下 `./setup.sh`、`make qwen36 VK=1`（`CUDA=1` 用 CUDA）。

## 適用情境

- 在沒有大顯卡的筆電或桌機上，用 SSD 串流跑數千億到兆級參數的 MoE 模型（慢但正確），資料不上雲。
- 有一張 24 GB 獨顯時跑 Qwen3.6-35B-A3B 這類模型到每秒百 token 等級，當 Claude Code 或其他 coding agent 的本地後端。
- 需要「封閉式決策 + 機率」的流程（路由、分類、審查判斷），或想把 Jev 用戶端改接本機。
- 研究 MoE 專家卸載、路由快取、多 SSD 頻寬、推測解碼的損益平衡（專案把開放研究問題列成表，歡迎提交含負面結果的測量）。

## 授權與成本

- **授權**：Apache-2.0（Copyright 2026 Vincenzo Fornaro），第三方元件見 `THIRD_PARTY_NOTICES.md`。
- 模型各自保留原授權：README 註明 GLM-5.2 權重為 MIT、Qwen-Image-2.1 僅限非商業用途、Muse Spark Open 遵循 Meta 授權、LFM3-VL 為 LFM Open License；使用或散布前請確認。
- **成本**：引擎免費；成本在硬碟空間（最小模型約 19–23 GB，GLM-5.2 約 429 GB，Kimi K3 約 1.56 TB）與硬體。

## 限制與注意事項

- 大型模型的速度由硬碟決定，可能非常慢：GLM-5.2 在 25 GB 筆電冷啟動只有 0.05–0.1 tok/s，Kimi K3 每 token 約 9.4 秒；128 GB 的 Ryzen AI Max+ 395 純 CPU 暖機後約 1.83 tok/s。適合能等的工作，不適合即時互動。
- 效能數字多為作者與社群自測（README 註明測試機器與設定，附 benchmarks 規範），非獨立評測；例如 RTX PRO 4000（24 GB）上 Qwen3.6-35B-A3B UD-Q4_K_M 解碼 CUDA 104.8／Vulkan 92.9／CPU 13.9 tok/s。
- 內顯上的 Vulkan 不一定比較快（OLMoE 在 Radeon 780M 上反而變慢），安裝程式只對部分模型在內顯開 GPU；沒有 Resizable BAR 的路徑尚未在實機上驗證。
- 部分模型需手動轉換或準備（OLMoE、Qwen3.8-27B、GLM-5.3-Flash、DeepSeek V4.1 Flash）；Inkling 用下載格式需 120 GB 以上 RAM，轉換稠密部分後才降到 25 GB。
- 決策模型（Laya、GLiNER2.5-Decide）只支援英文，不能聊天。
- 伺服器預設綁 localhost；未設 `COLI_API_KEY` 時不驗證金鑰，對外開放前要先設定。
- 在 WSL 上不要把模型放在 `/mnt/c`（慢上數倍）。
- 專案發展極快（v2.0.0 到 v2.1.0 間 387 個 PR），選項與模型清單可能常變。

## 相關工具

- [Strata](Strata.md)：同樣把 MoE 專家分層放在 VRAM／RAM／SSD，專跑 Qwen3.8-Flash-Next
- [Project Maya](Project-Maya.md)：從 Strata 改寫，專跑 GLM-5.3-Flash 與 DeepSeek-V4.1-Flash
- [Janas](Janas.md)：同樣是純 C、從 SSD 串流專家的本地 MoE 引擎
- [Laya](../07-Jev-決策模型生態/Laya.md)：colibri 原生支援的決策模型之一；System One API 與 Jev 相容（見 [Jev 決策模型生態](../07-Jev-決策模型生態/)）
- [Qwen-Image-2.1](../10-模型/Qwen-Image-2.1.md)：colibri 的畫圖引擎所跑的模型

## 資料來源

- https://github.com/JustVugg/colibri （README、README.zh-TW、CHANGELOG、NOTICE、docs/api.md；2026-11-09 查詢時約 49,200 星，最新版 v2.1.0 發布於 2026-10-31，repo 建立於 2026-07-01）
- https://justvugg.github.io/colibri
