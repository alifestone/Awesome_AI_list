# Jev Ultrafast

- **分類**：Jev 決策模型生態
- **連結**：https://github.com/browser-use/jev-ultrafast

## 原清單說明

（Browser Use）— 由 Jev 選操作與目標元素的極速瀏覽器 agent。

> 查證結果：與 README 相符。repo 位於 `browser-use` 組織，About 寫「Fastest and cheapest web agent」。補充：操作與目標由 Jev 決定，但當操作為 `TYPE_TEXT` 時，輸入的文字是由另一個小型文字 LLM 產生。

## 概述

Jev Ultrafast 是 Browser Use 團隊開源的網頁 agent，README 形容為「具有動態、索引化動作空間的瀏覽器 agent」。給它一個目標，它每一步會選擇一個操作（operation）與一個頁面元素作為目標；只有在選到 `TYPE_TEXT` 時才由小型 LLM 產生文字。README 的主要示範是 Google Flights 搜尋蘇黎世→倫敦航班，耗時約 **7.1 秒**（7,073 ms，從初次頁面觀察後起算）。

## 核心功能／特色

- **動態動作空間**：每次觀察都產生一張編號的元素表（按鈕、combobox、文字框等）。
- **操作集合**：`CLICK`、`TYPE_TEXT`、`SELECT`、`SCROLL_UP`、`SCROLL_DOWN`、`WAIT`、`DONE`、`BLOCKED`；只提供頁面上實際支援的操作與目標。
- **本機檢視器（inspector）**：網頁 UI 顯示編號元素、操作與目標的機率、已執行動作；「Choose next」可在執行前暫停。
- **Chrome 整合**：透過 Browser Harness 連線。
- **安全設計**：模型輸出永遠不會變成 selector、座標、shell 指令或可執行 JavaScript。

## 技術架構或運作原理

- 把元素表送給 TypeSafe 的 Jev，Jev 回傳一個操作，並對每種可能操作各回傳一個目標（`click_target`、`type_text_target`、`select_target`）——兩個決策在一次網路往返中完成（README 稱為 speculative fan-out）。
- 只執行與所選操作對應的目標；其餘目標預測屬投機性質。
- `TYPE_TEXT` 時由小型文字模型產生值，輸出必須能解析為小型 JSON 物件才會輸入。
- 預設迴圈使用結構化頁面狀態而非截圖；每次快照只需一次瀏覽器呼叫，讀取控制項、名稱、值與文字。
- 執行前重新檢查頁面新鮮度與點擊遮擋，並從觀察到的 DOM 節點解析目標。
- 在 combobox 輸入後最多等待 200 ms 讓建議出現；其他互動最多等兩個 animation frame 或 50 ms。
- 隱藏分頁透過 focus emulation 持續渲染；畫面外內容不放入模型上下文。

專案結構：`agent.py`（主迴圈與文字模型交接）、`snapshot.js`（原子 DOM 快照與新鮮度防護）、`browser.py`（瀏覽器連線、幾何、執行）、`model.py`（操作與目標 head、文字生成）、`questions.py`（模型指令）、`demo.py`（本機檢視器）。

### README 公布的數據

- 六次交替執行、相同模型與設定：新舊版本皆 3/3 通過；中位數任務時間 9.450 s → 7.092 s（降 25%）；中位數瀏覽器協定呼叫 1,092 → 101 次。
- Wikipedia 文章任務 2.798 s；本機飯店搜尋與篩選任務 1.896 s。
- README 強調這些是單一任務、單一瀏覽器設定檔的 3 次重複，不是一般可靠度基準。

## 與 Jev 的關係

- Jev 是本專案的決策核心：每一步把「選哪個操作、對哪個元素」轉為 Jev 的封閉式選擇題，並利用一次請求同時回傳多個問題答案的能力做投機性扇出。
- 需要 `TYPESAFE_API_KEY`，即直接使用 TypeSafe 託管的 Jev。
- 文字生成不由 Jev 負責（Jev 不生成自由文字），而是交給另一個文字模型。

## 安裝與使用方式

```bash
git clone https://github.com/browser-use/jev-ultrafast.git
cd jev-ultrafast
uv sync
cp .env.example .env      # 填入 TYPESAFE_API_KEY 與 TEXT_MODEL_API_KEY
uv run jev
```

開啟 http://127.0.0.1:8766，按「Start demo」再按「Run automatically」。Chrome 連不上時執行 `uv run browser-harness --doctor`。

範例設定使用 OpenRouter 的文字模型（目前為 `inception/mercury-2.5`，關閉 reasoning）；README 表示也可透過 OpenAI 相容的文字輔助設定 Gemini、GLM、DeepSeek。

函式庫用法：

```python
from jev_ultrafast import Agent

with Agent(
    "https://www.google.com/travel/flights?hl=en",
    "Find one-way flights from Zurich to London on September 20, 2026, ...",
) as agent:
    for state in agent.run():
        print(state["elapsed_ms"], state["status"])
```

```bash
uv run --env-file .env python your_script.py
uv run --env-file .env python examples/run.py --url https://en.wikipedia.org/wiki/Main_Page --goal '...'
uv run --env-file .env python examples/flights.py --keep-open   # 儲存 trace，不會真的訂票
```

開發：`uv run ruff check .`、`uv run pytest`、`node --check jev_ultrafast/static/app.js`、`node --check jev_ultrafast/snapshot.js`、`uv build`。測試離線執行；live 範例與錄影腳本會產生付費 API 呼叫。

## 適用情境

- 需要低延遲、低成本的網頁自動化（表單填寫、搜尋、篩選、導覽）。
- 研究「以決策模型取代 LLM 生成工具呼叫」的 agent 架構。
- 結構以標準 HTML／ARIA 控制項為主的網站。

## 授權與成本

- 授權：MIT。
- 成本：程式免費；執行需付費使用 TypeSafe Jev API 與文字模型 API（例如 OpenRouter）。Jev 計價依 DataCamp 報導為每百萬輸入 token 0.042 美元、輸出免費。每個任務的實際花費 README 未提供（資料不足）。Browser Use Cloud 另有「ultrafast cloud agents」候補名單。

## 限制與注意事項

- `DONE` 決策仍需獨立驗證結果是否真的完成。
- DOM 讀取器涵蓋常見 HTML 與 ARIA 控制項，未完整實作 accessible-name 規格。
- 此 MVP 不支援：shadow root、frame、canvas、檔案上傳、彈出分頁、巢狀捲動、任意鍵盤元件。
- 擁有的分頁共用既有 Chrome 設定檔（注意登入狀態與隱私）。
- 性能數據樣本極少，不能當作通用可靠度指標。

## 相關工具

- Browser Use（同組織的主力瀏覽器 agent 框架）
- Browser Harness（Chrome 連線層）
- [jevgrep](./jevgrep.md)、[fast-jev-compaction](./fast-jev-compaction.md)：其他以 Jev 為核心的 agent 工具

## 資料來源

- https://github.com/browser-use/jev-ultrafast
- https://www.datacamp.com/blog/system-one-models-jev
