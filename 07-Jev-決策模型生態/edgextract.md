# edgextract

- **分類**：Jev 決策模型生態
- **連結**：https://github.com/raphaelmansuy/edgextract

## 原清單說明

用自訂本體（ontology）+ 封閉式是非決策，把 markdown 轉成知識圖譜，不確定的項目送人工審核。

> 查證結果：與 README 相符（標語為「Closed yes/no decisions, not free-form JSON」）。補充：它預設呼叫的是**本機 Ollama** 上的小型決策模型 `tev1`（透過 Ollama 的 `POST /v1/systemone` 端點），或在瀏覽器以 WebGPU 執行；README 並未提到 TypeSafe，也不是直接呼叫 TypeSafe 託管的 Jev。

## 概述

edgextract 把 Markdown 文件轉成知識圖譜。使用者自己撰寫本體（ontology，規定合法的實體種類與關係），由程式碼提出候選名稱，再由一個小型本機決策模型**一次回答一個封閉式是非題**；不確定的項目進入人工審核佇列（review queue），而不是直接寫進圖譜。模型從不自行找出文字片段或發明型別。

由 GitHub 帳號 `raphaelmansuy` 維護；輸出格式受 EdgeQuake 啟發，但 edgextract 是獨立的函式庫。撰寫時（2026-10-13）GitHub 約 100 stars、11 forks。

## 核心功能／特色

- **自訂本體**：以 YAML 撰寫，或使用內建範例（`company_news`、`tech_docs`、`conll04` 等）。
- **EdgeQuake 形狀的 JSON 輸出**：實體名稱為 `UPPER_SNAKE`，關係附帶證據句，另有 `review`（待審）與 `rejected`（已拒絕）清單。
- **匯出**：Cypher（`edgextract export-cypher`）與互動式 HTML 圖（`edgextract graph`）。
- **瀏覽器執行**：Rust crate 可編譯成 WebAssembly，在瀏覽器分頁中執行，預設使用 WebGPU；Ollama 為另一個可選後端（`http://localhost:11434`，模型 `tev1`，需設定 `OLLAMA_ORIGINS`）。
- **兩個門檻滑桿**：決定保留／送審／丟棄；有決策快取，調整門檻不必重新詢問模型。
- **未知名稱也能處理**：清單中沒有的大寫名稱，會以封閉式問題詢問模型。

## 技術架構或運作原理

README 描述的六個步驟：

1. 將 Markdown 切成句子並記錄字元位移。
2. 從本體的名稱清單、Markdown 線索，以及（選用的）GLiNER span finder 提出候選名稱。
3. 以查表為名稱定型；未知片段先問「這是名稱嗎？」（是非題），再從種類中選一個。
4. 丟掉本體不允許的配對，非法關係根本不會被詢問。
5. 對每一種合法關係類型問一個是非題。
6. 依程式碼中的門檻，把每個項目保留、送審或丟棄。

每個候選配對都向 Ollama 的 `POST /v1/systemone` 送出封閉式是非題並取得機率，門檻就是比較這個數字。

### 評測（CoNLL04，288 句測試，精確 span 計分）

| 方法 | 名稱 F1 | 關係 F1 | 是否在 CoNLL04 上訓練 |
|---|---|---|---|
| SpERT（已發表） | 0.889 | 0.715 | 是 |
| edgextract + tev1，最終執行 | 0.690 | 0.388 | 否 |
| edgextract + tev1，首次執行 | 0.658 | 0.411 | 否 |
| Mistral Small，每句輸出 JSON | 0.643 | 0.330 | 否 |

README 坦承在基準上訓練過的模型仍大幅領先；但在零樣本比較中，封閉式決策方法保留的錯誤關係較少（關係精確率 0.41 vs 0.27；保留錯誤關係 218 vs 504），代價是部分召回率。在 12 篇技術筆記上 `tev1` 名稱分數 0.97（部分因名稱已在清單中），Mistral Small 為 0.68（另一次較早執行為 0.80）。

## 與 Jev 的關係

- 設計理念與 Jev 一致：以「封閉式問題 + 機率」取代自由格式 JSON 生成，並明言「chat host 的 JSON-schema 輸出不是決策，不應被當成決策呈現」。
- 使用的端點路徑 `/v1/systemone` 與 TypeSafe Jev 的 API 路徑相同，但後端是本機 Ollama 上的 `tev1` 模型；瀏覽器預設模型為 `raphaelmansuy/tev1-0.8b-onnx-webgpu`（README 標註為 Together Tev1 ONNX）。
- README 中「Jev」只出現一次：「We do not claim anything about hosted-Jev calibration.」——即不對託管版 Jev 的校準做任何宣稱。README 未提到 TypeSafe。
- `tev1` 與 TypeSafe Jev 之間的確切關係（是否為同一模型的開放版、或第三方相容模型）：資料不足。

## 安裝與使用方式

```bash
# Rust
cargo add edgextract        # 或 cargo install edgextract
# 瀏覽器 WASM
npm i @raphael.mansuy/edgextract
# 從原始碼
git clone https://github.com/raphaelmansuy/edgextract && cd edgextract
uv sync --all-extras
ollama pull tev1            # 需要 Ollama 0.35+
```

- 瀏覽器示範首次載入 Tev1 會從 Hugging Face 下載約 1 GB 到瀏覽器快取（需 Chromium + WebGPU）。
- 沒有模型時，`make test examples` 可對替身模型離線執行。

CLI：

```bash
uv run edgextract --model tev1 report data/golden/docs/13_northwind.md \
    --ontology company_news --out graph.html
edgextract init-ontology my_domain.yaml      # 產生起始本體
edgextract validate-ontology my_domain.yaml  # 以白話列出種類與合法關係
edgextract calibrate                          # 用自己的標註資料擬合門檻
```

Python：

```python
from edgextract import extract_text, load_ontology_named, write_report
text = open("note.md").read()
ontology = load_ontology_named("company_news")
result = extract_text(text, ontology, model="tev1")
write_report("graph.html", text, result, ontology, title="My note")
```

repo 內附 9 個簡短範例腳本；瀏覽器示範提供 7 個本體範例與 YAML 編輯器。

## 適用情境

- 把內部筆記、新聞、技術文件等 Markdown 轉成知識圖譜（可匯出到 Neo4j 等支援 Cypher 的資料庫）。
- 重視「寧缺勿錯」、希望錯誤關係少、並保留人工審核環節的知識擷取流程。
- 需要完全本機或瀏覽器內執行、資料不外送的情境。
- 作為 EdgeQuake 等 GraphRAG 系統的前處理（Rust 綁定在路線圖中）。

## 授權與成本

- 授權：Apache-2.0（LICENSE 檔）。
- 成本：軟體免費；模型在本機（Ollama）或瀏覽器（WebGPU）執行，無 API 費用。效能參考：一篇 7 句筆記 `tev1` 約 7.9 秒（暖機後 4.3 秒），`gemma4` 77.8 秒，託管 Mistral 3.9 秒。

## 限制與注意事項

- 門檻未經校準：`GateConfig.fitted` 初始為 false，需以 `edgextract calibrate` 擬合。
- 不處理代名詞（無共指消解）；此版本的關係不跨句。
- 關係方向可能錯誤：CoNLL04 最終執行保留了 16 條反向關係（首次執行為 9 條）。README 的範例圖刻意保留一條錯誤關係 `Acme ACQUIRED Northwind`（原文其實是「invested in」），用來展示審核佇列。
- `weight` 是模型原始機率，不是重新縮放的分數。
- 函式庫預設模型為 `nimble`，在該示範筆記上關係分數僅 0.38。
- 若有領域內標註資料，訓練過的聯合模型效果更好。
- 路線圖：依本體擬合門檻、有限窗口內的跨句關係、可選代名詞消解、EdgeQuake 匯入的 Rust 綁定。

## 相關工具

- EdgeQuake（輸出格式的靈感來源）
- GLiNER（可選的 span finder）
- Ollama（本機決策模型後端）
- [Laya](./Laya.md)、[AnyJev](./AnyJev.md)：其他可自架的 Jev 式決策模型
- TypeSafe Jev（相同的 `/v1/systemone` 介面概念）

## 資料來源

- https://github.com/raphaelmansuy/edgextract
- https://www.datacamp.com/blog/system-one-models-jev
