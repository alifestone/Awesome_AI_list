# ⚙️ 推論與訓練引擎

在自己的電腦上執行與微調模型的軟體。

### [Strata](Strata.md)

開源本地推論引擎，目標是讓通常要伺服器才能跑的大型 MoE 模型 Qwen3.8-Flash-Next，在一般遊戲 PC（NVIDIA 或 AMD 顯卡）上執行。做法是把專家權重分層放在 VRAM、RAM 與 SSD。MIT。

可以做到：
- 用 12 GB 以上顯卡 + 32～64 GB RAM 在本機跑 Qwen3.8-Flash-Next，資料不上雲。
- 聊天、程式碼生成、讀圖。
- 提供本地 OpenAI／Anthropic 相容 API，當 Claude Code 等 coding agent 的後端模型。

### [Unsloth](Unsloth.md)

開源的 LLM 執行與訓練框架，主打微調更快、更省顯存。除了 Python 函式庫，也有本地 UI／桌面 App，可執行 GGUF、MLX、擴散、embedding、語音等模型。

可以做到：
- 在單張 GPU 上用 LoRA／QLoRA 微調 Llama、Qwen、Gemma、gpt-oss 等開源模型。
- 做 GRPO、DPO 等偏好或強化學習訓練。
- 微調後匯出 GGUF 給 llama.cpp、Ollama 使用。
- 不寫程式，用圖形介面走完「資料集 → 訓練 → 執行 → 匯出」。
- 用本地模型驅動 Claude Code、Codex。

### [Janas](Janas.md)

純 C 寫成的本地 MoE 推論引擎，權重留在 SSD、需要的專家再串流進記憶體，可跑比 RAM 還大的模型（如 Qwen3-Next-80B）。GPL-3.0+。實驗性質。

可以做到：
- 在 32 GB 筆電上跑 48 GB 的 80B MoE 模型。
- 提供 OpenAI 相容 API、MCP 與程式碼補全給編輯器、Claude Code。
- 用 `janas-bench` 量測自己的機器。

## 怎麼挑

- **想在家用 PC 跑大型 MoE 模型**：Strata。
- **想用 SSD 串流跑超過 RAM 的 MoE 模型（實驗性）**：Janas。
- **想微調模型，或要一個圖形介面跑本地模型**：Unsloth。
- 可以跑哪些模型，見 [模型](../10-模型/)。
