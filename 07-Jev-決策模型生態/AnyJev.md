# AnyJev

- **分類**：Jev 決策模型生態 / 自架的 Jev 式決策模型
- **連結**：https://github.com/nokia-applied-research/AnyJev

## 原清單說明

（Nokia）— 免訓練把任何開源 LLM 變成 Jev 式決策模型，另有自蒸餾的 Tacit 系列。

> 查證結果：與 README 相符。專案位於 `nokia-applied-research` 組織下（Nokia Applied Research）；README 標語為「typed decisions, real probabilities, no training」，並提供自蒸餾的 Tacit 系列模型。需注意 README 明確聲明本專案「Not affiliated with TypeSafe AI or Jev」，即只是「Jev 風格」，與 TypeSafe 官方無關。

## 概述

AnyJev 是 Nokia Applied Research 釋出的 Python 函式庫（PyPI 套件名 `anyjev`），可把一般的開源因果語言模型（causal LM）變成「Jev 風格」的決策模型：輸入一段狀態（state）與一個有型別的問題，回傳每個選項的機率分布與最終決策。機率直接取自模型的下一個 token 分布，而非解析模型生成的文字。

它提供兩條路線：

- **AnyJev Training-Free（`Decider`）**：適用任何開源 causal LM，不需訓練、不需標註資料。
- **AnyJev Self-Distilled（`Tacit`）**：使用 Tacit 系列檢查點，這些模型經過自蒸餾，可在單次前向傳播中作答。

撰寫時（2026-10-13）GitHub 約 1.2k stars、146 forks。附有技術報告：AnyJev Technical Report，arXiv 2610.00831（Zhang et al., 2026）。

## 核心功能／特色

- **有型別的問題**：`choice`（預設）、`yes_no`、`score`。`score` 的選項為有序等級，預設從 1 起編號，可用 `first_level=0` 改為從 0 起。
- **真正的機率**：從下一個 token 分布讀出，非文字解析。
- **決策等級（level）**：每個 `Decision` 帶有 `level`，下游可用 `require="L0"` 拒絕較弱的決策。
- **自適應升級（adaptive escalation）**：`adaptive=True` 時，低信心決策可轉交模型自身推理（CoT），並有比例上限。
- **旋轉預算（rotation budget）**：L0 只讀取該決策所需的選項旋轉次數，以節省運算。
- **HTTP 閘道**：`python -m anyjev.serve` 提供 `/v1/decide` 與 `/v1/stats`。
- **多種後端**：transformers（`HFBackend`）、`VLLMBackend`、`SGLangBackend(url, model)`、`LlamaCppBackend(gguf)`，以及連線既有 vLLM server 的 client。

## 技術架構或運作原理

README 的決策等級表：

| 等級 | 需要 | 做法 | 不處理 |
|---|---|---|---|
| `raw` | 無 | 單一提示，對選項標籤做受限 softmax | 不修正順序偏差或標籤偏差 |
| `L0` | 無 | 對 K 種選項旋轉平均以消除位置偏差，並除去標籤先驗 | 不以標註資料做校準 |
| Tacit `one_forward` | Tacit 檢查點 | 單一提示，讀法同 `raw`，但模型已被訓練成單次作答 | 不修正順序偏差 |
| Tacit `cot` | `adaptive=True` | 先推理，再讀標籤分布 | 不超過其上限 |

自適應參數（預設值）：`adaptive=False`、`tau=0.5`（前兩名選項 log 機率差的信心門檻）、`max_cot_share=0.2`（最近 `cot_window` 筆決策中可升級的最大比例，`None` 表示不設上限）、`cot_window=1000`、`cot_max_tokens=8192`、`engine="transformers"`（另有 `"vllm"` 行程內執行、`"server"` 使用運行中的 `vllm serve`）。

### README 公布的成果

**免訓練 L0 vs. raw（Qwen3-8B，BANKING77 20 類，300 筆測試）**

| 指標 | Raw logits | L0（無標籤） |
|---|---|---|
| 選項反轉時答案翻轉率 | 0.230 | 0.073 |
| 準確率 | 0.747 | 0.803 |
| 校準誤差（ECE） | 0.240 | 0.184 |
| 在 ≤5% 錯誤率下可自動決策比例 | 7.7% | 46.3% |

**旋轉預算**：在 1% 認證不一致率下，L0 平均讀 7.2 次旋轉而非 18 次；vLLM 上每秒決策數約 2.2×、transformers 上 2.3×–2.7×，準確率不變。

**Tacit 系列準確率**

| 模型 | 基底 | JevBench 單次 | JevBench 自適應 | bev-decision 單次 | bev-decision 自適應 |
|---|---|---|---|---|---|
| Tacit-9B | Qwen3.5-9B | 0.823 | 0.887（15.2%） | 0.727 | 0.755（18.1%） |
| Tacit-8B | Qwen3-8B | 0.736 | — | 0.663 | — |
| Tacit-4B | Qwen3-4B | 0.723 | 0.758（14.3%） | 0.663 | 0.704（17.8%） |
| Tacit-2B | Qwen3.5-2B | 0.671 | — | 0.626 | — |
| Tacit-1.7B | Qwen3-1.7B | 0.619 | — | 0.598 | — |

括號內為送去推理的決策比例。Tacit-9B 升級時每筆決策約多生成 567（JevBench）／458（bev-decision）個 token；Tacit-4B 為 305／187。Tacit-8B、2B、1.7B 的自適應結果在 README 中列為進行中。README 稱 Tacit 為自蒸餾，「不使用人工標註、也不涉及其他模型」。

## 與 Jev 的關係

- AnyJev 模仿的是 Jev 的介面概念（狀態 + 有型別問題 → 帶機率的結構化決策），讓使用者可用開源模型自建類 Jev 的決策能力。
- README 聲明**與 TypeSafe AI／Jev 無隸屬關係**，也未說明 Jev 本身的內部機制。
- Tacit 的評測使用名為「JevBench」的基準；其具體來源與內容在 README 摘要中未詳述（資料不足）。
- 與 TypeSafe 官方 Jev 的 API 相容性：README 的 HTTP 閘道路徑為 `/v1/decide`，並非 Jev 的 `/v1/systemone`，未見宣稱可直接替換 Jev 端點（資料不足以判定相容性）。

## 安裝與使用方式

```bash
pip install "anyjev[hf]"        # transformers 後端
pip install "anyjev[client]"    # 連線既有 vLLM server 的 client
pip install "anyjev[vllm]"      # 行程內 vLLM
vllm serve morriszjm/Tacit-9B --host 127.0.0.1 --port 8000
```

Tacit 模型（transformers）：

```python
from anyjev import Tacit
tacit = Tacit.from_pretrained("morriszjm/Tacit-9B")
d = tacit.decide(state="Customer: my package was due last Monday and it still has not arrived.",
                 question="What does the customer want?",
                 options=["track_order", "cancel_order", "refund", "change_address"])
d["answer"], d["probs"], d["route"]
```

自適應升級（含上限）：

```python
tacit = Tacit.from_pretrained("morriszjm/Tacit-9B", adaptive=True, tau=0.5, max_cot_share=0.2, cot_window=1000)
```

透過 vLLM server：

```python
tacit = Tacit.from_pretrained("morriszjm/Tacit-9B", engine="server",
                              base_url="http://127.0.0.1:8000", adaptive=True)
```

HTTP 閘道：

```bash
python -m anyjev.serve --model morriszjm/Tacit-9B --upstream http://127.0.0.1:8000 --adaptive --port 8100
```

免訓練 `Decider`（任意開源 LLM）：

```python
from anyjev import Decider, Question
from anyjev.backends.hf import HFBackend
d = Decider(HFBackend("Qwen/Qwen3-8B"))   # 預設 level="L0"
route = Question.choice("Which team should handle this?",
                        ["billing", "technical", "sales", "other"], name="route")
r = d.decide("My card was charged twice for one order.", [route])["route"]
r.distribution, r.level
```

旋轉預算：

```python
d = Decider(backend, adaptive_shifts=True, canonical_order=True)
d.calibrate_adaptive(route, unlabelled_tickets, target=0.01)
```

## 適用情境

- 想要 Jev 式「封閉式問題 → 機率」的決策能力，但需完全自架、不想把資料送到外部 API。
- 客服工單分流、意圖分類、是非判斷、等級評分等需要可用機率做門檻控管的場景。
- 已有 vLLM／SGLang／llama.cpp 推論基礎設施，想在其上加一層有校準概念的決策讀出。
- 研究 LLM 選項位置偏差、標籤先驗修正與自蒸餾。

## 授權與成本

- 程式碼：Apache-2.0。
- Tacit 模型：沿用基底模型（Qwen）的 Apache-2.0（Tacit-9B 模型卡亦註明 Apache-2.0、BF16、9B 參數）。
- 資料集：保留各自授權，詳見 repo 中的 THIRD_PARTY.md。
- 成本：軟體免費；實際成本為自備 GPU／推論資源。無官方託管服務資訊（資料不足）。

## 限制與注意事項

README 與 `docs/limitations.md` 列出：

1. 準確率受限於模型本身：讀出方式可消除順序與標籤先驗影響，自蒸餾可把推理移入單次前向，但都不會增加模型不具備的知識。
2. Tacit 單次前向按給定順序讀選項，不做旋轉平均；在 Tacit 上用 `Decider(level="L0")` 可做 K 次 prefill 平均，但尚未量測。
3. 升級後的決策需生成推理鏈，耗時以秒計；`cot_max_tokens` 只限制升級比例，不限制單筆耗時。
4. vLLM 上 Tacit 只從前 20 名 log 機率讀標籤，不在其中的標籤視為 0。
5. Tacit-9B 與 Tacit-2B 需要 transformers ≥ 5；Hopper GPU 上 `vllm serve` 會以 `nvcc` 編譯 kernel，需安裝 CUDA toolkit（`engine="vllm"` 會自動退回 Triton kernel）。
6. 當單一標籤在批次中占多數時，L0 的批次先驗會傷害準確率，可改用 `prior="content_free"` 或 `prior="none"`。
7. 字母讀出最多支援 26 個選項。
8. n = 300 下「5% 風險覆蓋率」估計變異大。
9. 所有公布的決策都是單獨評分，未在 agent 迴圈中評估。

另外：HTTP 閘道監聽 127.0.0.1 且本身無驗證機制；路線圖中尚有部分 Tacit 自適應結果、免標籤提前退出、agent 迴圈評估、超過 26 選項的 span 讀出等項目。

## 相關工具

- [Laya](./Laya.md)：另一個可自架的開源決策模型，提供 Jev 相容端點。
- vLLM、SGLang、llama.cpp、Hugging Face transformers（AnyJev 支援的推論後端）。
- Tacit 系列模型（Hugging Face `morriszjm` 帳號下）。
- TypeSafe Jev（AnyJev 所模仿的商用 System One 決策模型）。

## 資料來源

- https://github.com/nokia-applied-research/AnyJev
- https://github.com/nokia-applied-research/AnyJev/blob/main/docs/limitations.md
- https://huggingface.co/morriszjm/Tacit-9B
- https://www.datacamp.com/blog/system-one-models-jev
