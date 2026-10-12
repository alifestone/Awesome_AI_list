# DSPy

- **分類**：Agent 框架與編排 / 框架
- **連結**：https://github.com/stanfordnlp/dspy

## 原清單說明

用「寫程式」而非手調 prompt 來建構與最佳化 LLM 管線。

> 查證結果：與官方定位相符。官方口號為「Programming—not prompting—language models」，DSPy 全名為 **Declarative Self-improving Python**。

## 概述

DSPy 是源自 Stanford NLP 的 Python 框架（2022 年 12 月起公開開發），讓開發者用模組化的 Python 程式組合 AI 系統，並提供演算法自動最佳化其中的 prompt 與模型權重。無論是簡單分類器、複雜 RAG 管線或 agent 迴圈都適用。核心思想是：以結構化的「簽章（Signature）」描述任務，而不是手寫脆弱的 prompt，再以「最佳化器（Optimizer）」針對指標自動調整。

GitHub 數據（2026-10-13 透過 GitHub API 查得）：約 3.9 萬顆星，主要語言 Python，最新 Release 為 **3.4.0**（2026-09-25；官網標示此版改進 PythonInterpreter、加速 GEPA、相容 MCP v2）。官網宣稱每月下載量 750 萬以上、貢獻者 466+。

## 核心功能／特色

- **Signatures（簽章）**：以型別化的輸入／輸出欄位宣告任務（`dspy.InputField`、`dspy.OutputField`，可用 `Literal`、`Optional`、`list[...]` 等型別），也可用字串簡寫如 `"question -> answer"`。
- **Modules（模組）**：決定簽章如何執行，介面相同、策略不同：`Predict`、`ChainOfThought`、`ReAct`／`ReActV2`（工具 + 推理迴圈）、`ProgramOfThought`、`CodeAct`、`BestOfN`、`Refine`、`MultiChainComparison`、`Parallel`、`RLM`、`Flex` 等；可繼承 `dspy.Module` 以一般 Python 控制流程組合。
- **Optimizers（最佳化器）**：給定範例與評分函式，自動調整 prompt（指令與示範）或權重：`GEPA`、`MIPROv2`、`BootstrapFewShot`、`BootstrapFewShotWithRandomSearch`、`BootstrapFinetune`、`BetterTogether`、`COPRO`、`SIMBA`、`KNNFewShot`、`LabeledFewShot`、`Ensemble`、`InferRules` 等。
- **Adapters**：把簽章轉為實際 prompt 的轉換層（`ChatAdapter`、`JSONAdapter`、`XMLAdapter`、`TwoStepAdapter`）。
- **多模態**：`dspy.Image`、`Audio` 可作為簽章欄位型別。
- **工具與 MCP**：Python 函式可直接當工具傳給 ReAct；支援 MCP；內建 `PythonInterpreter`、`ColBERTv2` 檢索等。
- **評估**：`Evaluate`、`SemanticF1`、`answer_exact_match` 等。
- **工程功能**：快取、串流、非同步、儲存／載入、可觀測性與除錯。

## 技術架構或運作原理

1. 以 `dspy.LM("供應商/模型")` 設定語言模型（例：`dspy.LM("openai/gpt-5.4-nano")`）。
2. 定義 Signature 描述任務的輸入輸出。
3. 選擇 Module 執行（直接預測、思維鏈、ReAct 工具迴圈等），或組合多個模組成程式。
4. Adapter 把簽章與輸入格式化成 prompt，並解析模型輸出為 `Prediction`。
5. 提供訓練集與 metric，呼叫 optimizer 的 `compile()`，自動搜尋更好的指令、few-shot 示範，或進行微調；結果可 `save()` 成 JSON 重用。

官網範例：以 `dspy.GEPA(metric=semantic_f1, auto="medium")` 最佳化 RAG，F1 從 0.41 提升到 0.63（官網示範數據）。

相關論文：DSPy（ICLR 2024）、Demonstrate-Search-Predict（2022）、MIPROv2（2024）、BetterTogether（2024）、GEPA: Reflective Prompt Evolution（2025）、Recursive Language Models（2025）等。

## 安裝與使用方式

需求：Python ≥ 3.10。

```bash
pip install -U dspy
# 安裝 main 分支最新版
pip install git+https://github.com/stanfordnlp/dspy.git
```

```python
import dspy
dspy.configure(lm=dspy.LM("openai/gpt-5.4-nano"))

class ExtractEvent(dspy.Signature):
    """Extract event details from an email."""
    email: str = dspy.InputField()
    event_name: str = dspy.OutputField()
    date: str = dspy.OutputField()

extract = dspy.Predict(ExtractEvent)
extract(email=inbox_message)

# 加上工具成為 agent
agent = dspy.ReAct("question -> answer", tools=[search, calc])

# 依指標最佳化
optimizer = dspy.GEPA(metric=accuracy, auto="medium")
optimized = optimizer.compile(extract, trainset=labeled_emails)
optimized.save("extract_v2.json")
```

（官網範例以 `lm = dspy.LM(...)` 建立模型；`dspy.configure` 為 API 參考中列出的設定函式。）

## 適用情境

- 資訊擷取、分類、RAG、多跳問答、agent 等需要穩定品質且可持續改進的 LLM 應用。
- 有標註資料或可定義評分函式，想自動調 prompt 而非手工試錯。
- 需要更換底層模型時，希望重新編譯而非重寫 prompt。
- 研究 prompt 最佳化、LM 程式化方法的學術用途。

## 授權與成本

- 授權：**MIT**。
- 框架免費；費用來自所呼叫的 LLM API。最佳化（compile）過程會大量呼叫模型，官網範例示範以 200 筆資料最佳化約花費 $2.18（官網示範數據，實際依模型與資料而異）。

## 限制與注意事項

- 學習曲線：需要理解 Signature／Module／Optimizer 等抽象，與傳統 prompt 工程思路不同。
- 最佳化效果依賴評估指標與訓練資料品質；沒有好的 metric 難以發揮。
- 編譯過程會產生額外 API 成本與時間。
- GitHub README 內容很精簡，完整文件在 https://dspy.ai 。

## 相關工具

- [CrewAI](./CrewAI.md)（多 agent 編排框架）
- LangChain、LlamaIndex（LLM 應用框架，本次未查證）
- GEPA、MIPROv2（DSPy 內建最佳化演算法）
- ColBERTv2（DSPy 內建可用的檢索模型）

## 資料來源

- https://github.com/stanfordnlp/dspy （README）
- https://api.github.com/repos/stanfordnlp/dspy
- https://api.github.com/repos/stanfordnlp/dspy/releases/latest
- https://dspy.ai/current/
