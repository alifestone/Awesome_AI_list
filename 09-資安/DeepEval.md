# DeepEval

- **分類**：資安 / LLM 測試 / 紅隊（評測為主）
- **連結**：https://pypi.org/project/deepeval/
- **原始碼**：https://github.com/confident-ai/deepeval
- **文件**：https://deepeval.com

## 原清單說明

（使用者提供連結，無附註說明）

> **查證結果**：PyPI 套件 `deepeval`，自稱「The LLM Evaluation Framework」，由 Confident AI 開發（作者 Jeffrey Ip）。Apache-2.0。查詢當下最新版本 4.2.8（2026-10-02 發布）。

## 概述

DeepEval 是開源的 LLM 評測框架，用法像 Pytest，但專門替 LLM 應用寫單元測試。它內建大量評測指標（G-Eval、答案相關性、幻覺、任務完成度等），以「LLM 當評審」或在本機執行的 NLP 模型打分，可以評估整個應用、完整的 agent 軌跡，或單一步驟（LLM 呼叫、工具使用、檢索、子 agent 交接）。

repo 於 2023-08-10 建立，查詢當下（2026-10-14）約 18,800 顆星，持續活躍（最後推送 2026-10-12）。

## 核心功能／特色

- **現成指標**（每個都附分數理由）：
  - **通用**：G-Eval（自訂準則的 LLM 評審）、JevEval（用 Jev 決策模型打出校準過的機率分數）、DAG。
  - **Agent**：任務完成度、工具正確性、參數正確性、步驟效率、計畫遵循等。
  - **RAG**：答案相關性、忠實度、上下文精確率／召回率／相關性，以及 RAGAS。
  - **多輪對話**：知識保留、對話完整度、逐輪相關性與忠實度、角色遵循。
  - **MCP**：MCP 任務完成度、MCP 使用效率。
  - **多模態**：文生圖、圖像編輯、圖文一致性等。
  - **其他**：幻覺、摘要、偏見、毒性、JSON 格式正確性、prompt 遵循。
- **自訂指標**，自動接入整個生態。
- **合成資料集**：產生單輪與多輪的測試資料。
- **追蹤（tracing）**：用 `@observe` 裝飾器或框架整合記錄每一步，做軌跡式評測。
- **CI/CD**：`deepeval test run` 可放進任何 CI。
- **自動最佳化 prompt**：依評測結果調整。
- **標準基準**：不到 10 行程式碼跑 MMLU、HellaSwag、DROP、BIG-Bench Hard、TruthfulQA、HumanEval、GSM8K。
- **框架整合**：LangChain、LangGraph、LlamaIndex、CrewAI、Pydantic AI、OpenAI／OpenAI Agents、Anthropic、Mastra、AI SDK（TypeScript）等。
- **給 coding agent 的 skill**：讓 Claude Code 等 agent 幫你產資料集、寫評測、跑測試並修失敗項目。

## 安裝與使用方式

```bash
pip install -U deepeval   # Python 3.9+
export OPENAI_API_KEY="..."   # 預設評審模型；也可換成自己的模型
```

```python
# test_chatbot.py
from deepeval import assert_test
from deepeval.metrics import GEval
from deepeval.test_case import LLMTestCase, SingleTurnParams

def test_case():
    correctness = GEval(
        name="Correctness",
        criteria="Determine if the 'actual output' is correct based on the 'expected output'.",
        evaluation_params=[SingleTurnParams.ACTUAL_OUTPUT, SingleTurnParams.EXPECTED_OUTPUT],
        threshold=0.5,
    )
    test_case = LLMTestCase(
        input="What if these shoes don't fit?",
        actual_output="You have 30 days to get a full refund at no extra cost.",
        expected_output="We offer a 30-day full refund at no extra costs.",
    )
    assert_test(test_case, [correctness])
```

```bash
deepeval test run test_chatbot.py
```

`deepeval login` 可把結果上傳到 Confident AI 平台產生可分享的報告（選用）。

## 適用情境

- 替 RAG、chatbot、agent 寫自動化品質測試，改 prompt 或換模型前後做回歸比較。
- 評估 agent 的工具使用與整條決策軌跡，而不只看最終答案。
- 評估 MCP agent 是否用對工具。
- 在 CI 中設門檻，品質掉下來就擋住合併。

## 授權與成本

- **授權**：Apache-2.0。
- **成本**：框架免費；以 LLM 當評審的指標會消耗所選模型的 API 費用（預設 OpenAI）。Confident AI 雲端平台是商業服務，非必要。

## 限制與注意事項

- 多數指標靠 LLM 評審，分數會受評審模型影響，有一定隨機性與成本。
- 紅隊（對抗攻擊）不是 DeepEval 本身的重點；README 把紅隊列在 Confident AI 平台功能中，若要做資安紅隊，Promptfoo 的覆蓋面較完整。放在資安分類是為了和 Promptfoo 並列比較。
- README 大力推薦登入 Confident AI；登入後測試案例會自動上傳，處理敏感資料前請先看其資料隱私說明。

## 相關工具

- [Promptfoo](Promptfoo.md)：YAML 設定的 LLM 評測與紅隊工具，紅隊功能更完整
- [Jev 決策模型生態](../07-Jev-決策模型生態/)：DeepEval 的 JevEval 指標使用 Jev
- [DSPy](../06-Agent-框架與編排/DSPy.md)、[CrewAI](../06-Agent-框架與編排/CrewAI.md)：可被 DeepEval 評測的 LLM 框架

## 資料來源

- https://pypi.org/project/deepeval/ （套件摘要、版本、Python 需求、授權）
- https://github.com/confident-ai/deepeval （README：指標、整合、快速開始）
- https://api.github.com/repos/confident-ai/deepeval （repo 中繼資料：建立日期、星數、最後推送）
