# ⚡ Jev 決策模型生態

**Jev** 是 TypeSafe 的「System One」決策模型：對封閉式問題（是非、選擇、評分）一次回傳帶機率的結構化決策，而不是生成一段文字。因為只回答「選哪個」，它比一般 LLM 快、便宜，也比較好用機率設門檻。這個資料夾收的都是圍繞這種「決策模型」做的工具，包括使用 Jev 的應用，以及可以自架的替代品。

## 用 Jev 做事的工具

### [fast-jev-compaction](fast-jev-compaction.md)

npm 函式庫兼 Claude Code 外掛。對話需要壓縮時，不讓 LLM 寫有損的摘要，而是讓 Jev 逐一判斷每個工具呼叫和結果是否還需要，只刪掉過時的部分；使用者與助理的訊息原文保留。

可以做到：
- 在長時間的 Claude Code session 中，清掉過時的檔案讀取、測試輸出、搜尋結果。
- 壓縮後仍保留對話原文，避免摘要扭曲資訊。
- 在自建 agent 框架中用決策模型修剪上下文。

### [jevgrep](jevgrep.md)

給 coding agent 用的命令列工具（`jg`）：用自然語言問「認證在哪裡檢查」，它回傳相關檔案、閱讀線索與逐字原始碼摘錄。輸出是給 agent 的證據，不是生成的答案。

可以做到：
- 讓 agent 在陌生的大型程式庫中，找到跨多個檔案的某個行為在哪裡實作。
- 降低主模型探索程式碼時消耗的 token 與成本。
- 已知確切符號或路徑時，直接用 `rg` 就夠了。

### [Jev Ultrafast](Jev-Ultrafast.md)

Browser Use 團隊開源的瀏覽器 agent：每一步由決策模型選一個操作與一個頁面元素，只有需要輸入文字時才呼叫小型 LLM。示範在 Google Flights 搜尋航班約 7.1 秒完成。

可以做到：
- 低延遲、低成本的網頁自動化（填表、搜尋、篩選、導覽）。
- 研究「用決策模型取代 LLM 生成工具呼叫」的 agent 架構。
- 最適合以標準 HTML／ARIA 控制項為主的網站。

### [edgextract](edgextract.md)

把 Markdown 轉成知識圖譜：你寫本體（規定合法的實體與關係），程式提出候選，再由本機的小型決策模型一次回答一個是非題；不確定的送進人工審核佇列。

可以做到：
- 把內部筆記、新聞、技術文件轉成知識圖譜，匯出到 Neo4j 等資料庫。
- 「寧缺勿錯」的知識擷取，保留人工審核環節。
- 完全在本機或瀏覽器裡執行，資料不外送。

## 自架的 Jev 式決策模型

### [AnyJev](AnyJev.md)

Nokia Applied Research 的 Python 函式庫：把任何開源 LLM 變成 Jev 式決策模型，機率直接取自模型的下一個 token 分布。可免訓練使用，也有自蒸餾的 Tacit 系列模型。

可以做到：
- 完全自架 Jev 式「封閉式問題 → 機率」能力，資料不送外部 API。
- 工單分流、意圖分類、是非判斷、評分等需要用機率設門檻的場景。
- 疊在既有的 vLLM、SGLang、llama.cpp 推論環境上。

### [Laya](Laya.md)

ConvAI Innovations 開源的多語言決策模型：輸入狀態與有型別的問題，回傳帶校準機率的答案，從不生成文字。提供 Jev 相容端點。Apache-2.0。

可以做到：
- 自架、資料不出境，或不想排 Jev 的 waitlist 時使用。
- Guardrail、郵件／工單分流、意圖分類等低延遲決策。
- 讓 fast-jev-compaction、jevgrep 等 Jev 客戶端改指向自架的 `laya-serve`。

## 怎麼挑

- **Claude Code 上下文太長**：fast-jev-compaction；**agent 找不到程式碼**：jevgrep。
- **要快的瀏覽器 agent**：Jev Ultrafast；**要建知識圖譜**：edgextract。
- **不想用 Jev 的雲端服務**：用 AnyJev 把自己的模型變成決策模型，或直接自架 Laya。
