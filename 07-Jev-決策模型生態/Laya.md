# Laya

- **分類**：Jev 決策模型生態 / 自架的 Jev 式決策模型
- **連結**：https://huggingface.co/convaiinnovations/laya

## 原清單說明

（ConvAI Innovations）— 開源非自回歸決策模型，可自架並提供 Jev 相容端點。Apache 2.0。

> 查證結果：相符。模型卡 metadata 授權為 `apache-2.0`（頁尾「Apache 2.0 · Convai Innovations」）；每個問題在單次前向傳播中作答、不生成文字（非自回歸）；`laya-serve` 提供與 TypeSafe Jev 相同請求／回應格式的 `POST /v1/systemone`。補充：Laya 是以 ModernBERT／mmBERT 編碼器為骨幹的分類式模型，並非 LLM。

## 概述

Laya 是 ConvAI Innovations 釋出的多語言決策模型。輸入一段狀態（文字、電子郵件、工單或 JSON）與有型別的問題，回傳帶校準機率的有型別答案，**從不生成文字**。模型卡表示其以「針對 proper scoring rules 的強化學習」（RLCD）訓練。Hugging Face pipeline 標籤為 Text Classification。

## 核心功能／特色

- **非自回歸、單次前向**：所有問題一次作答，模型卡引述約 33 ms 延遲。
- **三種問題型別**：`choice`、`score`、`noul`（與 Jev 相同的型別命名；`noul` 為是非題）。
- **新 schema 不需重新訓練**：每個選項在其自己的 `[MASK]` token 上評分，再在該問題的選項間做 softmax。
- **多語言**：多語言檢查點宣稱支援 100+ 語言。
- **Router**：自動偵測語言並路由到合適的檢查點。
- **整合**：選用 extras 包含 `laya[serve]`（HTTP 伺服器）、`laya[mcp]`（MCP 伺服器）、`laya[langchain]`（LangChain／LangGraph）、`laya[onnx]`、`laya[fast]`。

## 技術架構或運作原理

| 檢查點 | 骨幹 | 參數量 | 上下文 | 擅長 |
|---|---|---|---|---|
| `convaiinnovations/laya`（根目錄） | ModernBERT-large | 421M | 512 | 英文、guardrail、郵件分流 |
| `laya-multilingual`（子資料夾） | mmBERT-base（22 層，256k 詞表） | 322M | 1024（最多 8k） | 100+ 語言，約快 2.2 倍 |
| `laya-typed-decisions`（子資料夾） | ModernBERT-large | 421M | 1024 | 四種 typed-decision 工作流（0.766 準確率） |

- 英文根檢查點：ModernBERT-large 骨幹（395M）+ 從零訓練的決策 head（2 層 transformer、選項標記評分器、act/escalate head），合計 421M。
- 上下文預算：英文 512 token（`head_max_len = 192`）；多語言與 typed-decisions 1,024 token（`head_max_len = 256`）；多語言可用 `max_len=8192` 讀到 8,192 token。
- 訓練（RLCD）：策略輸出一個分布，對 logits 加高斯探索雜訊，以 proper scoring rules 作為獎勵；以帶群組平均基線的 REINFORCE 更新；多輪對話使用 TD(λ=1.0)。

### 模型卡公布的基準（Tesla T4）

延遲：

| 每次呼叫問題數 | `laya` | `laya-multilingual` |
|---|---|---|
| 1 | 39.5 ms | 32.8 ms |
| 10 | 158.6 ms | 72.3 ms |
| 50 | 771 ms | 337 ms |

準確率與比較：

- MASSIVE intent 英文 0.783（英文檢查點）；其他 13 種語言（路由後）0.451。
- XNLI 其他 14 種語言（路由後）0.731。
- 可用語言（> 3 倍隨機）：51 種中 45 種。
- typed-decisions（2,000 個決策）：微調檢查點 0.766，對照 Jev 1.13.0 公布數字 0.727。依型別：`noul` 0.857、`choice` 0.733、`score` 0.723。
- AG News 0.950 vs Jev 0.910；DAIR Emotion 0.595 vs 0.480；Banking77 0.425 vs Jev 0.870（Jev 領先）。
- 溫度縮放後 ECE 0.081 vs Jev 0.246。
- 模型卡說明 Jev 數字為第三方公布值，並非作者自行量測。

## 與 Jev 的關係

- 定位為 TypeSafe Jev 的開源、可自架替代品：採用相同的問題型別（`choice`／`score`／`noul`）與相同的 `POST /v1/systemone` 請求／回應格式，既有 Jev 客戶端只需更改 base URL 即可使用（模型卡宣稱）。
- 模型卡將 Laya 標示為「100% free」「$0 self-hosted」，並列出 TypeSafe Jev API 為封閉權重、每百萬 token 0.042 美元。
- 模型卡本身並未說明與 TypeSafe 有任何合作或隸屬關係（資料不足）。

## 安裝與使用方式

需求：Python 3.10+。

```bash
pip install laya
```

建議用 `Router`（自動偵測語言並路由）：

```python
from laya import Router
router = Router()
result = router.predict(state, questions)
```

單一模型：

```python
import laya
agent = laya.load("convaiinnovations/laya")
agent_ml = laya.load("convaiinnovations/laya", subfolder="multilingual")
```

若 `laya.load()` 卡住，請以 `USE_TF=0` 執行。

自架 Jev 相容伺服器：

```bash
pip install "laya[serve]"
LAYA_DEVICE=cuda LAYA_PRELOAD=1 laya-serve
```

伺服器綁定 `0.0.0.0:8000`；預設無驗證，設定 `LAYA_API_KEY` 後需帶 `Authorization: Bearer <key>` 標頭。格式錯誤的問題回傳 422，未知欄位會被忽略。

## 適用情境

- 想用 Jev 式決策 API，但需要自架、資料不出境，或不想受 Jev 早期存取／waitlist 限制。
- Guardrail、郵件／工單分流、意圖分類等低延遲分類型決策。
- 多語言決策需求（搭配 `laya-multilingual` 與 Router）。
- 已用 Jev 客戶端（如 fast-jev-compaction、jevgrep 的自訂端點）的專案，可嘗試改指向 `laya-serve`。

## 授權與成本

- 授權：Apache 2.0。
- 成本：模型與軟體免費，自架成本為自有硬體（模型卡基準使用 Tesla T4 GPU）。無官方託管 API 資訊。

## 限制與注意事項

- **基礎檢查點在 typed-decisions 上零樣本表現弱**：英文 0.362、多語言 0.342，低於多數類基線 0.461；0.766 的成績需要微調。
- **選項數多時效果差**：77 個選項時每個標籤在預設預算下只分到約 3–4 個 token，準確率大幅下降；建議提高 `head_max_len` 或將選項分層。
- **有序 `score` 題最弱**（SST-5：0.372）。
- **`noul` 題可能被 `false:`／`true:` 標籤主導**（英文檢查點尤甚），建議改寫為兩選項的 `choice` 題。
- **`action.act_probability` 目前沒有可用訊號**，建議改以 `confidence` 做門檻。
- **預設過度自信**：信任機率前建議依問題型別與選項數重新擬合溫度；平均 ECE 可從 0.466 降到 0.081（英文）、0.314 降到 0.106（多語言）。
- 根檢查點僅支援英文；其他語言請用 `laya-multilingual`。
- 預設 `laya-serve` 綁定所有介面且無驗證，對外部署務必設定 `LAYA_API_KEY`。

## 相關工具

- [AnyJev](./AnyJev.md)：另一種自架路線，把開源 LLM 變成 Jev 式決策模型。
- [edgextract](./edgextract.md)：同樣使用 `/v1/systemone` 介面的知識圖譜擷取工具。
- ModernBERT、mmBERT（骨幹模型）。
- TypeSafe Jev（Laya 相容的商用 System One 模型）。

## 資料來源

- https://huggingface.co/convaiinnovations/laya
- https://www.datacamp.com/blog/system-one-models-jev
