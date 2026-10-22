# ⚙️ 推論與訓練引擎

在自己的電腦上執行與微調模型的軟體。

### [Strata](Strata.md)

開源本地推論引擎，目標是讓通常要伺服器才能跑的大型 MoE 模型 Qwen3.8-Flash-Next，在一般遊戲 PC（NVIDIA 或 AMD 顯卡）上執行。做法是把專家權重分層放在 VRAM、RAM 與 SSD。MIT。

可以做到：
- 用 12 GB 以上顯卡 + 32～64 GB RAM 在本機跑 Qwen3.8-Flash-Next，資料不上雲。
- 聊天、程式碼生成、讀圖。
- 提供本地 OpenAI／Anthropic 相容 API，當 Claude Code 等 coding agent 的後端模型。

### [Strata Easy TW](Strata-Easy-TW.md)

Strata 的非官方繁體中文 Windows 安裝導覽器：左邊跑官方安裝腳本，右邊用中文解釋每一步，可另選 SC117 的第三方低拒答模型。MIT。⚠️ 2026-10 剛發布的 pre-release，完整安裝與推論流程尚未端到端驗證。

可以做到：
- 不熟命令列也能用圖形介面在 Windows 安裝 Strata，看中文說明回答安裝問題。
- 先用離線展示熟悉流程，不下載任何模型。
- 實驗性地改用 SC117 的 abliterated GGUF 模型。

### [Unsloth](Unsloth.md)

開源的 LLM 執行與訓練框架，主打微調更快、更省顯存。除了 Python 函式庫，也有本地 UI／桌面 App，可執行 GGUF、MLX、擴散、embedding、語音等模型。

可以做到：
- 在單張 GPU 上用 LoRA／QLoRA 微調 Llama、Qwen、Gemma、gpt-oss 等開源模型。
- 做 GRPO、DPO 等偏好或強化學習訓練。
- 微調後匯出 GGUF 給 llama.cpp、Ollama 使用。
- 不寫程式，用圖形介面走完「資料集 → 訓練 → 執行 → 匯出」。
- 用本地模型驅動 Claude Code、Codex。

### [Janas](Janas.md)

純 C 寫成的本地 MoE 推論引擎，權重留在 SSD、需要的專家再串流進記憶體，可跑比 RAM 還大的模型（如 Qwen3-Next-80B）；可搭配 Vulkan GPU 與 Intel Core Ultra 的 NPU 加速讀提示。GPL-3.0+。實驗性質。

可以做到：
- 在 32 GB 筆電上跑 48 GB 的 80B MoE 模型。
- 提供 OpenAI 相容 API、MCP 與程式碼補全給編輯器、Claude Code。
- 在 Intel Core Ultra 筆電上用 NPU 加快小模型讀長提示（Linux，實驗性）。
- 用 `janas-bench` 量測自己的機器。

### [DeepInfer](DeepInfer.md)

DeepSeek 官方開源的推論框架，就是 DeepSeek 自家大規模線上服務背後的引擎。目前只支援 DeepSeek-V4.1-Flash，硬體限 NVIDIA SM100（Blackwell）與華為昇騰 950。Apache-2.0。⚠️ 開源版只有離線推論，未含 KV cache 系統與 prefill／decode 分離部署。

可以做到：
- 在 Blackwell／昇騰 950 叢集上跑 DeepSeek-V4.1-Flash 離線推論。
- 用 MoE 專家平行（EP + EPLB）、DSpark 推測解碼加速大規模推論。
- 開啟 batch-invariant 推論與決定性取樣，讓輸出可重現。
- 用 regex、JSON schema 或 EBNF 限制輸出格式。

### [Project Maya](Project-Maya.md)

從 Strata 引擎改寫的本地推論引擎，專為 GLM-5.3-Flash（321B MoE）與 DeepSeek-V4.1-Flash-1017（748B MoE）打造：專家分層放在 VRAM／RAM／NVMe SSD，一張到 16 張 GPU 都能跑。MIT。⚠️ AMD 與 Windows 為實驗性；執行時會佔住幾乎所有空閒 RAM。

可以做到：
- 用一張 24 GB 顯卡 + 32 GB 以上 RAM 在本機跑 GLM-5.3-Flash，資料不上雲。
- 提供 OpenAI／Anthropic 相容 API，當 Claude Code 等 coding agent 的後端，最多 8 個請求平行。
- 用 KV streaming 在單張 RTX 3090 上開到 1M context。
- 用 `--calibrate` 依自己的硬體自動調校。

### [TurboFieldfare](TurboFieldfare.md)

以 Swift＋Metal 自寫、只跑 Gemma 4 26B-A4B 的推論引擎：記憶體只放約 2 GB 的共用核心與 KV cache，專家每個 token 從 SSD 串流，8 GB 的 Apple Silicon Mac 也能跑。Apache-2.0。⚠️ 需 macOS 26；本機伺服器無驗證，只能留在 loopback。

可以做到：
- 在 8 GB 的 MacBook Air 上離線跑 Gemma 4 26B-A4B（作者實測約 5–6 tok/s，M5 Pro 約 31–35）。
- 用原生 Mac app 聊天，或另裝 vision pack 讀圖（M2 以上）。
- 開本機 OpenAI 相容 API（串流、function tools）接 OpenCode 等工具。

### [QwenGyre](QwenGyre.md)

阿里巴巴提出的強化學習訓練框架（論文），專門訓練單次要跑好幾小時、用掉近百萬 token 的超長任務 agent：GPU 在 rollout 與訓練之間彈性切換而不中斷執行中的 agent，並把分支軌跡整理成共享前綴的樹、去重後再訓練。⚠️ 目前只有論文，未公開程式碼；實驗規模為資料中心等級。

可以做到（依論文）：
- 訓練 Qwen 3.8 2.4T 等級模型時，比 Colocate 快最多 1.85×、比 Async 快最多 1.78×。
- 48 步內把 NL2RepoBench 通過率從 52.5% 提升到 58.5%。
- 對逾時的執行打部分分數，不浪費已完成的工作。

### [dLLM](dLLM.md)

擴散語言模型（一次並行去遮罩多個 token，而非逐字自迴歸生成）的訓練、推論與評測函式庫，建立在 `transformers` Trainer 與 `lm-evaluation-harness` 上，附 LLaDA、Dream 的範例與 MDLM、BD3LM、Edit Flows 等演算法實作。Apache-2.0。

可以做到：
- 預訓練、微調、評測 LLaDA 與 Dream，支援 LoRA、4-bit、DeepSpeed、FSDP。
- 把任意自迴歸模型或 BERT 微調成擴散模型（官方釋出 0.5B／0.6B 的 Tiny-A2D 與 BERT-Chat）。
- 用 Fast-dLLM 加速推論，或用 diffu-GRPO 做強化學習。

## 怎麼挑

- **想在家用 PC 跑大型 MoE 模型**：Strata；想要繁中圖形介面帶著裝，可試 Strata Easy TW（測試版）。
- **想用 SSD 串流跑超過 RAM 的 MoE 模型（實驗性）**：Janas。
- **想微調模型，或要一個圖形介面跑本地模型**：Unsloth。
- **想在自己的 GPU 上跑 GLM-5.3-Flash 或 DeepSeek-V4.1-Flash**：Project Maya。
- **只有一台記憶體不大的 Mac，想跑 Gemma 4 26B-A4B**：TurboFieldfare。
- **有資料中心 GPU／NPU 叢集，要自架 DeepSeek-V4.1-Flash**：DeepInfer。
- **想了解超長任務 agent 的大規模 RL 訓練怎麼做（研究參考）**：QwenGyre（只有論文）。
- **想訓練或研究擴散語言模型（LLaDA、Dream 等）**：dLLM。
- 可以跑哪些模型，見 [模型](../10-模型/)。
