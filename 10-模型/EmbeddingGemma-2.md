# EmbeddingGemma 2

- **分類**：模型 / Embedding
- **連結**：https://huggingface.co/google/embeddinggemma-2

## 原清單說明

（Google）— 740M 多模態 embedding，文字／圖片／音訊／影片映射到同一向量空間，可端側執行。Apache 2.0。

> 查證結果：與官方模型卡一致（Google DeepMind 開發，740M 總參數，四種模態共用 768 維向量空間，Apache 2.0）。

## 概述

EmbeddingGemma 2 是 Google DeepMind 的開放多模態 embedding 模型，建立在 Gemma 4 的架構與能力之上。它把文字（含程式碼）、圖片、影片、音訊以及它們的混合輸入，映射到同一個 768 維向量空間，設計目標是在手機、筆電等消費級硬體上做低延遲的搜尋、RAG、分類與分群。前一代為 EmbeddingGemma（1），僅支援文字。

## 模型規格

| 項目 | 內容 |
| --- | --- |
| 總參數 | 740M（文字模型 270M ＝ transformer 骨幹 130M ＋ embedder 140M；視覺編碼器 170M；音訊編碼器 300M） |
| 層數 | 24 |
| 模型維度／隱藏維度 | 512 / 2048 |
| 注意力 | GQA/MQA，4 heads，KV heads（local/global）2/1，local:global 5:1，sliding window 1024 |
| 啟動函數 | Gated FFN + GELU |
| Pooling | Mean pooling，投影 512→768 |
| 詞彙量 | 262,144 |
| Context 長度 | 8,192 tokens（所有模態共用） |
| 輸出維度 | 原生 768；MRL 可截斷為 512／256／128 |
| 語言 | 100+ 種語言（訓練資料含 140+ 種語言） |

## 核心功能／特色

- **原生多模態**：文字、圖片、影片、音訊在同一空間，可互相比對（例如文字查詢搜尋影片）；可交錯輸入，用 `<|image|>`、`<|video|>`、`<|audio|>` 佔位符標示位置，產出單一向量。
- **模組化載入**：視覺／音訊編碼器可不載入。純文字 270M、文字＋圖片 440M、文字＋音訊 570M、全模態 740M。
- **Matryoshka（MRL）**：可截斷到 128 維，向量儲存最多省 6 倍；官方稱到 256 維幾乎無損，128 維較適合純文字。
- **任務前綴**：以短指令前綴（如 `task: search result | query: ...`、`title: ... | text: ...`）針對搜尋、問答、事實查核、程式碼檢索、分類、分群、相似度最佳化。
- **程式碼能力**：官方稱程式碼任務比前代提升約 14%。
- 各模態 token 成本：文字 1 token/subword；圖片預設 280 tokens／張（約 29 張）；影片預設每幀 140 tokens、1 fps（約 58 幀）；音訊 25 tokens／秒（約 327 秒，需 16 kHz 單聲道）。視覺 token 預算可調整 70–1120。

## 訓練方式

- 預訓練資料：網頁文件（140+ 語言）、程式碼、圖片、影片、音訊與跨模態配對資料，截止日 2025 年 1 月。
- 資料處理：多階段 CSAM 過濾、敏感個資過濾、品質與安全過濾。
- 以 MRL 訓練、搭配任務指令前綴。
- 為預訓練 embedding 模型，**未做後訓練對齊或輸出層安全調校**。
- 訓練規模（token 數、算力）：**資料不足**。

## 評測表現（官方自報，768 維、全精度）

| 模態 | Benchmark | EmbeddingGemma 2 | EmbeddingGemma 1 |
| --- | --- | ---: | ---: |
| 文字 | MTEB（multilingual v2） | 61.36 | 61.15 |
| 文字 | MTEB（code v1） | 78.68 | 68.76 |
| 圖片 | MIEB（lite） | 64.64 | – |
| 圖片 | MMEB v2 – Image | 57.28 | – |
| 文件影像 | MMEB v2 – VisDoc | 67.84 | – |
| 影片 | MMEB v2 – Video | 50.67 | – |
| 音訊 | MSEB（Retrieval） | 69.54 | – |
| 音訊 | MAEB | 49.39 | – |

截斷後（MTEB multilingual v2）：512d 61.17、256d 60.41、128d 57.89；MMEB v2 整體在 128d 降至 45.65（多模態品質明顯下降）。
官方另稱它是「1B 以下最強的多模態 embedding 模型之一」，屬自我描述。

## 本地執行／使用方式

```bash
pip install -U sentence-transformers transformers
```

```python
import torch
from sentence_transformers import SentenceTransformer

dtype = torch.bfloat16 if torch.cuda.is_bf16_supported() else torch.float32
model = SentenceTransformer(
    "google/embeddinggemma-2",
    model_kwargs={"torch_dtype": dtype},
    # 只用文字時可省記憶體：
    # config_kwargs={"vision_config": None, "audio_config": None},
)

q = model.encode("What causes the northern lights?", prompt_name="SearchQuery")
d = model.encode("The northern lights are caused by charged particles from the sun.", prompt_name="Document")
print(model.similarity(q, d))

# MRL 截斷（記得正規化）
q128 = model.encode("...", truncate_dim=128, normalize_embeddings=True)
```

多模態交錯輸入範例：

```python
emb = model.encode({
    "text": "Waterproof running shoes. <|image|> Grip test: <|video|>",
    "image": ["shoe.jpg"],
    "video": "demo.mp4",
})
```

## 適用情境

- 端側或筆電上的語意搜尋、RAG（企業知識庫、程式碼搜尋、語音查詢搜尋音訊檔）。
- 分類（情緒、內容審核、音訊事件、圖片分類）、分群、去重、推薦、跨語言對齊。
- 事實查核的證據檢索。

## 授權與成本

- 授權：Apache 2.0（模型卡與 HF metadata 皆標示）；部署須遵守 Gemma Prohibited Use Policy（模型卡註明）。
- 成本：開放權重免費；純文字模式僅 270M 參數，可在 CPU 執行（CPU 上建議 float32）。

## 限制與注意事項

- **不可用 float16**：activation 範圍超出 fp16，會回傳 NaN 或靜默劣化的向量；請用 bfloat16 或 float32。
- MRL 截斷後必須重新 L2 正規化；查詢與文件必須使用同一維度。
- 128 維在多模態任務上品質下降明顯，須自行驗證。
- 雖支援 100+ 語言，各語言表現不一定相同；省略任務前綴會降低品質。
- 未經後訓練安全對齊，下游應用需自行加入過濾與公平性測試。

## 相關模型

- EmbeddingGemma（第一代，文字 embedding）
- Gemma 4（架構基礎）

## 資料來源

- https://huggingface.co/google/embeddinggemma-2 （README 原始檔：https://huggingface.co/google/embeddinggemma-2/raw/main/README.md）
- https://huggingface.co/api/models/google/embeddinggemma-2 （授權與參數 metadata）
