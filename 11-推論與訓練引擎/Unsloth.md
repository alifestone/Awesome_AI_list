# Unsloth

- **分類**：推論與訓練引擎
- **連結**：https://github.com/unslothai/unsloth

## 原清單說明

快速、省顯存的 LLM 微調函式庫。

> 查證補充：目前 Unsloth 已不只是微調函式庫，README 將其描述為「在本機執行與訓練 AI 模型」的開源專案，包含程式庫（Unsloth Core）以及圖形介面（Unsloth Studio 網頁 UI、Unsloth Desktop 桌面版）。

## 概述

Unsloth 是開源的 LLM 執行與訓練框架，主打讓微調更快、更省顯存。官方文件稱其為「an open-source framework for running and training LLMs」。除了 Python 程式庫外，現在也提供本地 UI／桌面應用，可執行 GGUF、MLX、擴散模型、embedding、語音／TTS 等模型，並可把本地模型接到 Claude Code、Codex 等 agent 工具。

## 核心功能／特色

- **訓練方法**：LoRA、QLoRA、完整微調（full fine-tuning）、預訓練、強化學習（GRPO、GSPO）、DPO、FP8 訓練、消費級 GPU 上的 VLM GRPO。
- **訓練對象**：LLM、擴散模型、TTS、embedding 模型等。
- **模型執行**：LLM、GGUF、MLX、擴散、embedding、音訊、TTS 模型。
- **Agent 整合**：`unsloth start` 可把 Claude Code、Codex、OpenCode、Hermes 等 agent 接到本地模型；支援 tool calling、程式執行與 MCP。
- **搜尋與 RAG**：私有網頁搜尋、deep research、自動壓縮上下文（auto-compaction）、RAG。
- **Data Recipes**：從 PDF、CSV、DOCX 等來源建立資料集。
- **匯出**：GGUF、NVFP4、FP8 等格式。
- **API／遠端存取**：OpenAI 相容 API；區網存取或 Cloudflare HTTPS 安全連結。
- **免費 Colab notebook**：README 提供多個可免費訓練的筆記本。

官方自報加速數據（README 筆記本表格，未載明基準與硬體）：

| Notebook | 速度 | VRAM |
|---|---|---|
| Gemma 4 (E2B) | 快 1.5 倍 | 少 50% |
| Qwen3.5 (4B) | 快 1.5 倍 | 少 60% |
| gpt-oss (20B) | 快 2 倍 | 少 70% |
| gpt-oss (20B) GRPO | 快 2 倍 | 少 80% |
| Llama 3.1 (8B) Alpaca | 快 2 倍 | 少 70% |
| embeddinggemma (300M) | 快 2 倍 | 少 20% |
| Orpheus-TTS (3B) | 快 1.5 倍 | 少 50% |

其他宣稱：MoE LLM 訓練快 12 倍、省 35% VRAM；20B 模型可在 80GB GPU 上以超過 500K context 訓練；長上下文 RL 可達 7 倍長度等。

## 技術架構或運作原理

- **Unsloth Core**：Python 套件，以自行撰寫的 Triton kernel（README 提到 RoPE 與 MLP Triton kernel、padding-free packing）加速訓練並降低記憶體。
- **Unsloth Studio**：網頁 UI（`unsloth studio` 啟動），可設定密碼保護、區網存取與 API key。
- **Unsloth Desktop**：桌面應用，提供 Windows ARM64、Linux ARM64（Ubuntu 24.04+）、Linux x64 等版本。
- **推論後端**：可設 `UNSLOTH_LLAMA_CPP_BACKEND`（vulkan / cpu / cuda / rocm / auto）；`UNSLOTH_NO_TORCH=1` 可啟用不需 PyTorch 的純 GGUF 模式。
- README 未詳述 kernel 層的內部演算法細節（資料不足）。

## 安裝與使用方式

```bash
# Studio：macOS / Linux / WSL
curl -fsSL https://unsloth.ai/install.sh | sh

# Studio：Windows（PowerShell）
irm https://unsloth.ai/install.ps1 | iex

# 套件管理器
brew install --cask unsloth
winget install --id UnslothAI.Unsloth -e

# 啟動 Studio
unsloth studio
unsloth studio --secure                # 密碼保護模式
unsloth studio -H 0.0.0.0 -p 8888      # 開放區網
UNSLOTH_STUDIO_PASSWORD='your-strong-password' unsloth studio --secure
unsloth studio reset-password

# Unsloth Core（Linux / WSL）
uv venv unsloth_env --python 3.13
source unsloth_env/bin/activate
uv pip install unsloth --torch-backend=auto

# Unsloth Core（Windows：先裝 torchao）
uv pip install torchao
uv pip install unsloth --torch-backend=auto

# 把 Claude Code 接到本地模型
unsloth start claude --model unsloth/Qwen3.8-27B-GGUF:UD-Q4_K_XL
```

- 也提供 Docker 映像 `unsloth/unsloth`（AMD 用 `unsloth/unsloth-rocm`）。
- 桌面版可從 GitHub Releases 或 unsloth.ai 下載。

## 適用情境

- 在單張消費級或資料中心 GPU 上，以 LoRA/QLoRA 微調開源 LLM（Llama、Qwen、Gemma、gpt-oss 等）。
- 做 GRPO／DPO 等偏好或強化學習訓練。
- 微調後匯出 GGUF 給 llama.cpp、Ollama 等推論工具使用。
- 想要圖形介面完成「資料集 → 訓練 → 執行 → 匯出」全流程的非程式使用者。
- 以本地模型驅動 Claude Code、Codex 等 coding agent。

## 授權與成本

- **核心套件**：Apache-2.0。
- **選用元件**（如 Unsloth Studio UI）：AGPL-3.0。
- 開源版免費；README 提供免費 Colab 筆記本。
- 付費方案：官方定價頁（unsloth.ai/pricing）讀取失敗（HTTP 403），無法確認是否有付費版本、內容與價格 → **資料不足**。（網路搜尋摘要提及 Pro／Enterprise 方案，但未能由官方頁面驗證。）

## 限制與注意事項

- 加速與省顯存數字皆為官方自報，README 未說明測試硬體與比較基準。
- Studio 伺服器端工具預設開啟；對外開放時 README 提醒要小心，可加 `--disable-tools`。
- 使用 `--secure`、`--cloudflare` 或非 loopback host 時會要求設定管理員密碼。
- Windows 上若一步安裝，torchao 可能導致解析到舊版 Unsloth，需先裝 torchao。
- AMD、Intel GPU 需參考獨立指南，Docker 需用不同映像。
- 最低 VRAM、CUDA 版本等詳細需求不在 README／文件首頁，需另看「Unsloth Requirements」頁面（本條目未查證 → 資料不足）。

## 相關工具

- [Hugging Face TRL / PEFT](https://github.com/huggingface/trl)：Unsloth 常搭配使用的訓練／參數高效微調生態（本條目未逐一查證整合細節）。
- [llama.cpp](https://github.com/ggml-org/llama.cpp)：Unsloth 匯出 GGUF 後的常見推論後端，Studio 亦可設定 llama.cpp 後端。
- [Strata](https://github.com/Niko1221/Strata)：本清單收錄的本地 MoE 推論引擎，可選用 Unsloth 的 UD 量化模型。
- [QwenGyre](QwenGyre.md)：阿里巴巴針對超長任務 agent 的資料中心級 RL 訓練框架（僅論文）。

## 資料來源

- https://github.com/unslothai/unsloth
- https://unsloth.ai/docs
- https://unsloth.ai/pricing（嘗試讀取，回傳 HTTP 403）
