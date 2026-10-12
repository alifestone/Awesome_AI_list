# Needle

- **分類**：模型 / 端側小模型
- **連結**：https://github.com/cactus-compute/needle

## 原清單說明

（Cactus Compute）— 給手機、穿戴裝置、機器人用的超小型工具呼叫模型，可在本機微調。

> 查證結果：與官方 README 一致。目前版本為 **Needle 3**；除工具呼叫外，也做結構化抽取與文字 embedding，並可搭配同引擎的語音轉文字模型 Whistle。授權 Apache 2.0。

## 概述

Needle 是 Cactus Compute 為手機、穿戴裝置、機器人、智慧家庭、車用與微控制器設計的基礎模型。整個模型是單一 8–29 MB 的檔案，官方說明它犧牲一般聊天能力，換取在行動裝置工具呼叫上勝過 10 倍大小的模型、在資訊抽取上追平 2–3 倍大的模型（官方自述）。三項主要工作都在裝置端完成：

- **工具呼叫**：根據 app 提供的函式挑選並填參數；兩個要求產生兩個依序的呼叫；沒有對應工具時回傳空清單而非亂猜。
- **結構化抽取**：宣告 schema，從雜亂文字取出型別化欄位（發票、訂位、通知、表單），解碼文法保證輸出可解析，也可延伸成分類。
- **文字 embedding**：同一模型可輸出句向量，供本地搜尋、比對、路由。

## 模型規格

| 項目 | 內容 |
| --- | --- |
| 架構 | Laddered Simple Attention Network：以 Monarch Hadamard MLP 取代 FFN、GQA 注意力加 causal conv taps、engram n-gram 記憶（以 gather 讀取）、multi-lane hyper-connections |
| 參數量 | 29M–121M（2 到 20 層每一種深度都可獨立部署；完整 20 層為 121M，官方稱多數參數在 engram 中，計算量約等於 50M 模型） |
| 已公布子網路 | Needle3-20L-121M、16L-98M、8L-52M、4L-29M |
| 檔案大小 | 8–29 MB（`.cact` 格式） |
| 量化 | Cactus Quants CQ2（約 2.125 bits/weight） |
| 訓練資料 | 360B tokens 的自有結構化資料集 |
| 速度（官方） | Raspberry Pi 5 上最高約 4k tokens/s 解碼、10k tokens/s prefill |
| Context 長度 | 資料不足（README 僅說明工具 schema 與 system prompt、對話共用 context） |

## 核心功能／特色

- 每次回應為單一 JSON：`function_calls`、模型的 `reasoning`、由學習式 head 產生的校準 `confidence`。
- 由使用者 schema 編譯出 byte-level 文法約束每個 token，輸出必定合法。
- 工具超過 5 個時可只保留檢索到的工具在每回合 prefix 中。
- **Whistle**：同容器、同 C++ 引擎的語音轉文字模型（16.9 MB，16 kHz 單聲道，支援英、德、法、西、義、荷、波蘭語），可一次呼叫完成「語音 → 轉寫 → 工具呼叫」。官方稱比 Whisper base 小 8.6 倍、首 token 快 6.6 倍；在部分資料集勝過 Whisper base，在 TED-LIUM、AMI、MLS 則落後。
- 每個部署平台都有預編譯引擎，另支援瀏覽器、WASI、C API、氣隙環境。

## 訓練或壓縮方式

- 以 360B tokens 自有結構化資料訓練，採「階梯式」訓練讓 2–20 層每個深度都可用。
- 出貨版權重以 CQ2 2-bit 量化，2-bit 後訓練並加入 Cactus 自有資料集。
- **微調**有兩種方式：

| | 本機 `needle finetune` | 平台 `needle platform finetune` |
| --- | --- | --- |
| 訓練內容 | 注意力投影的 LoRA adapter（base 凍結，匯出時合併） | 完整模型，2 層以上每個深度 |
| 資料 | 你的 JSONL | 你的資料＋Needle 原資料集（避免遺忘），或由工具定義自動生成 100–10,000 筆 |
| confidence | 不更新，回傳 `None` | 一併微調並校準 |
| 精度 | 4-bit | 2-bit |
| 算力 | 自己的機器（JAX，CPU／CUDA／Metal） | Cactus GPU（需 API key） |

官方稱在 DroidCall 上微調可讓每個子網路提升 18–36 分，4 層（29M）以上微調後勝過 DeepSeek V4 Flash。

## 評測表現（官方自報）

Needle 3 以出貨的 CQ2 二進位檔並開啟 confidence gate 測試；對照組在 vLLM 以 f16 執行，DeepSeek V4 Flash 透過其雲端 API：

| Benchmark（指標） | Needle3-20L-121M | Qwen3.5 0.8B | LFM2.5 1.2B | FunctionGemma 270M | DeepSeek V4 Flash（雲端） |
| --- | ---: | ---: | ---: | ---: | ---: |
| Mobile Actions（完全匹配準確率） | 86.0 | 76.0 | 82.4 | 65.1 | 88.4 |
| DroidCall（依序完全匹配） | 47.0 | 28.0 | 35.5 | 16.5 | 60.5 |
| BFCL v4（AST match） | 50.2 | 56.8 | 62.0 | 46.6 | 77.2 |
| DSTC8（欄位 F1） | 40.7 | 49.0 | 48.0 | 27.0 | 80.0 |
| SNIPS gold（欄位 F1） | 30.2 | 35.0 | 43.0 | 29.0 | 69.4 |
| SNIPS 7-way（欄位 F1） | 24.7 | 34.0 | 38.0 | 14.0 | 66.7 |

Mobile Actions 上 Apple FM（3.0B）為 57.6、Needle 2（45M）為 63.5。可見 Needle 3 在行動工具呼叫（Mobile Actions、DroidCall）上領先同級小模型，但在 BFCL v4 與抽取類（DSTC8、SNIPS）上落後 0.8B–1.2B 模型。

## 本地執行／使用方式

```sh
pip install cactus-needle
```

```python
import needle

@needle.tool
def get_weather(city: str):
    "Get the current weather for a city."
    return {"city": city, "temp_c": 27, "sky": "clear"}

agent = needle.Needle(tools=[get_weather])
print(agent.run("what's it like in Lagos right now?")["results"])

print(needle.transcribe("clip.wav")["text"])   # Whistle 語音轉文字
```

部署與微調：

```sh
needle build --platform macos-arm64
needle build --platform linux-arm64 --layers 8 --out ./pi
./macos-arm64/needle --model needle3.cact --tools tools.json --serve
./needle --model needle3.cact --model whistle.cact --tools tools.json --audio clip.wav

pip install "cactus-needle[train]"
needle finetune data.jsonl --epochs 10 --out adapter.safetensors
needle build --lora adapter.safetensors --layers 8 --out tuned.cact
```

權重與各平台引擎在 HuggingFace `Cactus-Compute/needle3`（含 `needle3.cact` 與可微調的 `needle3.safetensors`），亦可在 cactuscompute.com/needle 的瀏覽器 demo 試用。舊部署可用 `needle.Needle(tools=[...], generation=2)` 繼續跑 Needle 2。

## 適用情境

- 手機 app、穿戴裝置、智慧家庭、車用、機器人、微控制器上的離線語音／文字指令轉函式呼叫。
- 端側表單、通知、發票等結構化抽取與分類。
- 針對單一產品的工具集微調出極小子網路（最小 2 層）。

## 授權與成本

- 授權：Apache 2.0（GitHub LICENSE 檔與 HF needle3 模型卡 metadata）。
- 成本：模型與本機 LoRA 微調免費；`needle platform finetune` 使用 Cactus 平台 GPU，需 API key，計費方式 README 未列 → 資料不足（README 提及 `needle platform billing` 指令）。

## 限制與注意事項

- 刻意犧牲一般聊天能力，不適合當通用對話模型。
- 在 BFCL v4 與抽取類 benchmark 上不如 0.8B–1.2B 通用小模型；與雲端 DeepSeek V4 Flash 仍有明顯差距。
- **預設開啟遙測**：需設定環境變數 `NEEDLE_TELEMETRY=0` 與 `DO_NOT_TRACK=1` 關閉。
- 工具 schema 會佔用 context；prefix 過長時 `needle_init` 會失敗，需精簡描述或拆分工具。
- 所有評測為官方自報。
- 本機 LoRA 微調後 confidence 分數不可用（回傳 `None`）。

## 相關模型

- Needle 2（前代，45M）
- Whistle（同引擎的語音轉文字模型）
- FunctionGemma 270M、LFM2.5 系列、Qwen3.5 0.8B、Apple Foundation Model（官方比較對象）

## 資料來源

- https://github.com/cactus-compute/needle （README、LICENSE、assets/benchmarks.svg、assets/model.svg）
- https://huggingface.co/Cactus-Compute/needle3 （README 與授權 metadata）
