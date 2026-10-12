# Qwen Fixed Chat Templates

- **分類**：模型 / 工具 / 修正檔
- **連結**：https://huggingface.co/froggeric/Qwen-Fixed-Chat-Templates

## 原清單說明

修正版的 Qwen chat template（依名稱判斷）。

> 查證結果（原說明標註「依名稱判斷」）：**已查證屬實**。這是社群作者 Frédéric Guigand（@froggeric）維護的 Jinja chat template 修正檔，**不是模型權重**；單一 `chat_template.jinja` 適用 Qwen 3.5、3.6、3.8 與 3.8 Flash-Next 全尺寸，目前版本 v22.5（2026-09-03 更新）。非 Qwen 官方出品。

## 概述

官方 Qwen chat template 在本地推論與 agent 工作流中有多種問題（渲染錯誤、KV cache 失效、浪費 token、空白 `<think>` 污染、agent 卡死等）。此 repo 提供一個可直接替換的通用 Jinja 模板，宣稱修正上述問題，並可用於 LM Studio、llama.cpp、vLLM、SGLang、MLX、oMLX、KoboldCPP 及任何支援 HF Jinja template 的引擎。

## 規格

| 項目 | 內容 |
| --- | --- |
| 類型 | Jinja chat template（非模型） |
| 適用模型 | Qwen 3.5、3.6、3.8（含 Qwen3.8-2.4T-A95B、Qwen3.8-27B）、3.8 Flash-Next |
| 版本 | v22.5（2026-09-03） |
| 檔案 | `chat_template.jinja`、`chat_template_oneline.txt`（vLLM 用單行版）、`scripts/check_applied.py`、測試腳本 |
| 參數量／架構／context | 不適用 |

## 核心功能／特色（作者自述）

針對 Qwen 3.8 官方模板：
- 預設推理強度由官方的 `xhigh` 改為 `medium`（不注入額外 token），避免把 token 預算全耗在推理而回傳空內容。
- 恢復非推理快速模式：官方 Qwen3.8-2.4T-A95B 模板在 `enable_thinking=false` 時會拋出例外（作者指出 27B 模板可接受）。
- 修正官方 3.8 在對話歷史中重複插入空白 `<think></think>` 的問題；支援 OpenAI（`reasoning_content`）、Anthropic（`thinking`）、vLLM（`reasoning`）與內文 `<think>` 標籤等多種推理欄位。
- 推理強度別名對應：`high`／`max`／`ultracode`／`extreme` → `xhigh`；`minimal` → `low`；`none`／`off` → 關閉。
- 對話內行內標籤：`<|think_low|>`、`<|think_medium|>`、`<|think_xhigh|>`、`<|think_ultracode|>`、`<|think_off|>`（具黏性，持續生效直到被替換）。

通用修正：
- 工具呼叫參數若為 JSON 字串（OpenAI／Ollama 常見）不再崩潰；預設維持 Qwen 原生 XML 格式，可用 `tool_call_format="json"` 改 Hermes JSON。
- 依時間順序保留歷史 `<think>`，宣稱達成 100% prefix KV cache 命中。
- 兩階段工具錯誤升級機制，避免 agent 反覆送出同一個失敗呼叫；以結構化規則避免把含 "error" 字樣的正常結果誤判為錯誤。
- 移除 Python 專屬 Jinja 語法，相容 C++ 的 minijinja；扁平化 AST，作者稱可修正 llama.cpp 上 80% 的吞吐下降。
- 合併連續的開頭 system／developer 訊息；支援對話中途的 system 訊息。
- 可設定 `max_tool_arg_chars`、`max_tool_response_chars` 截斷過大的工具資料。

## 驗證方式

- 附 105 項自動測試（`python3 scripts/test_v22.py`）與確定性 property fuzzer（`scripts/fuzz_template.py`，檢查 9 項結構不變量）。
- `scripts/check_applied.py` 可檢查模型資料夾或 GGUF 目前套用的模板版本。

## 評測表現

無標準 benchmark。「80% 吞吐提升」、「80%+ 提前中止率」、「100% KV cache 命中率」等數字皆為**作者自述**，未見第三方驗證。

## 使用方式

```bash
# llama.cpp / llama-server
llama-server -m your_model.gguf --jinja --chat-template-file chat_template.jinja --reasoning-format deepseek

# vLLM：把 tokenizer_config.json 中的 "chat_template" 換成 chat_template_oneline.txt 內容
vllm serve Qwen/Qwen3.8-2.4T-A95B --reasoning-parser qwen3 --tool-call-parser qwen3_xml

# SGLang（必須明確指定，否則 0.5.x 會改用 tokenizer_config.json 內嵌模板）
python3 -m sglang.launch_server --model-path Qwen/Qwen3.8-27B --chat-template chat_template.jinja
```

- LM Studio：模型設定 → Prompt Template → 貼上 `chat_template.jinja` 內容 → Save。無法傳 kwargs 的 UI 可直接修改模板頂端的 `_default_reasoning_effort`、`enable_thinking`、`_tool_format` 預設值。
- MLX／oMLX：覆蓋模型資料夾中的 `chat_template.jinja`，以 `--jinja` 啟動。
- 推理強度可經 `chat_template_kwargs` 傳入，例如 `{"reasoning_effort": "xhigh"}`。
- vLLM 的 reasoning parser 不會讀取 `<|think_off|>`，要關閉推理請在請求中傳 `"enable_thinking": false`。

## 適用情境

- 在本地引擎（llama.cpp、LM Studio、MLX、vLLM、SGLang）上跑 Qwen 3.5／3.6／3.8，並接 OpenCode、Claude Code、Cline、Cursor 等 coding agent 或工具呼叫流程時，遇到模板崩潰、推理耗盡 token、agent 卡住等問題。

## 授權與成本

- 授權：Apache-2.0（作者註明繼承自 Qwen）。
- 成本：免費。

## 限制與注意事項

- 非 Qwen 官方產物；替換模板會讓行為與官方預設不同（例如預設推理強度從 `xhigh` 變 `medium`），評測結果可能不同於官方數字。
- 設 `preserve_thinking: false` 會使 prefix KV cache 保證失效。
- XML 模式下 JSON 字串參數僅以原文作為 best-effort fallback（Jinja 無法解析 JSON），建議傳 dict。
- 模板持續快速改版（v21 → v22.5 約兩個月內多次更新），需留意版本。

## 相關模型

- Qwen 3.5／3.6／3.8 系列（Qwen3.8-27B、Qwen3.8-2.4T-A95B、Qwen3.8 Flash-Next）
- Bonsai 2（Qwen3.8-27B 衍生的三值壓縮模型）、Qwythos-9B（Qwen3.5-9B 衍生）

## 資料來源

- https://huggingface.co/froggeric/Qwen-Fixed-Chat-Templates （README 原始檔）
- https://huggingface.co/api/models/froggeric/Qwen-Fixed-Chat-Templates （授權 metadata）
