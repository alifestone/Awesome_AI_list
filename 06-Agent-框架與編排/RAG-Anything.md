# RAG-Anything

- **分類**：Agent 框架與編排 / 知識庫 / 文件問答
- **連結**：https://github.com/HKUDS/RAG-Anything
- **論文**：https://arxiv.org/abs/2510.12323

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：repo 標語為 *RAG-Anything: All-in-One RAG Framework.* 由港大 HKUDS 開發，建在同團隊的 [LightRAG](https://github.com/HKUDS/LightRAG) 之上，是 Python 函式庫，不是有圖形介面的 App。授權為 MIT。

## 概述

RAG-Anything 是多模態的 RAG（檢索增強生成）框架。一般 RAG 只處理文字，遇到 PDF 裡的圖、表格、公式就會漏掉；RAG-Anything 把這些內容也解析出來、交給視覺或語言模型理解，再一起建進知識圖譜，讓你能針對「圖文表混排」的文件提問。

repo 於 2025-06-06 建立，查詢當下（2026-10-19）約 23,795 顆星，最新版本 v1.4.2（2026-10-06 發布）。2025-10 發表技術報告（arXiv 2510.12323）。依 README，2026-06 起 LightRAG 已原生整合 RAG-Anything 來支援多模態 RAG。

## 核心功能／特色

- **端到端流程**：從文件匯入、解析，到多模態問答一條龍。
- **支援格式**：PDF、Office（DOC／DOCX／PPT／PPTX／XLS／XLSX）、圖片（JPG、PNG、BMP、TIFF、GIF、WebP）、TXT／MD；另可選用音訊（faster-whisper 本機轉錄）與影片（場景切分 + 關鍵幀 VLM 描述 + 音軌轉錄）。
- **三種解析器**：MinerU（預設，OCR 與表格擷取強，可用 GPU）、Docling（適合 Office 與 HTML）、PaddleOCR（以 OCR 為主）。
- **專門的內容分析器**：圖片交給視覺模型產生說明，表格做結構化解讀，公式以 LaTeX 處理；也能自訂新的內容類型處理器。
- **多模態知識圖譜**：把圖、表、公式也變成圖譜裡的實體，並和文字實體建立關聯，保留原文件的章節層級。
- **混合檢索**：向量相似度搜尋 + 圖譜走訪，依內容類型調整排序。
- **VLM 強化查詢**：檢索到含圖片的內容時，會把圖片本身一起送給視覺模型分析，而不只是看文字說明。
- **直接插入內容清單**：已經用別的工具解析好的內容，可以跳過解析直接匯入。

## 技術架構或運作原理

依 README，流程分五個階段：

1. **文件解析**：用 MinerU 等解析器把文件拆成文字區塊、圖片、表格、公式，保留彼此的上下文關係。
2. **內容分類與路由**：自動判斷內容類型，文字與多模態內容走不同的平行管線。
3. **多模態分析**：各類型交給專門的分析器（視覺模型、表格解讀、公式解析）。
4. **建立知識圖譜**：抽出實體、建立跨模態關聯，用 `belongs_to` 關係保留章節層級，並替關係打權重。
5. **檢索**：查詢時有 `hybrid`、`local`、`global`、`naive` 等模式（沿用 LightRAG），結合向量與圖譜結果。

## 安裝與使用方式

```bash
pip install raganything
# 需要更多格式支援時
pip install 'raganything[all]'

# 確認 MinerU 已安裝
mineru --version
```

- Office 文件需要另外安裝 LibreOffice；影片需要 ffmpeg；PaddleOCR 解析器要另裝 `paddlepaddle`。
- 需設定 LLM、視覺模型與 embedding 模型。README 範例用 OpenAI 相容 API（`.env` 裡的 `OPENAI_API_KEY`、`OPENAI_BASE_URL`），`examples/` 另有 Ollama、LM Studio、vLLM、MiniMax 的整合範例，可以全部用本機模型。

基本用法（節錄）：

```python
from raganything import RAGAnything, RAGAnythingConfig

config = RAGAnythingConfig(
    working_dir="./rag_storage",
    parser="mineru",          # mineru、docling 或 paddleocr
    enable_image_processing=True,
    enable_table_processing=True,
    enable_equation_processing=True,
)
rag = RAGAnything(config=config, llm_model_func=..., vision_model_func=..., embedding_func=...)

await rag.process_document_complete(file_path="report.pdf", output_dir="./output")
answer = await rag.aquery("第三季營收和去年比如何？", mode="hybrid")
```

## 適用情境

- 對含大量圖表、表格、公式的論文、技術文件、財報建問答系統。
- 企業內部知識庫：文件格式雜（PDF、PPT、Excel、掃描檔）時，一套流程處理。
- 研究多模態 RAG 或知識圖譜式 RAG 的實作參考。

## 授權與成本

- **授權**：MIT。
- **成本**：框架免費；用雲端模型時會產生 LLM、視覺模型與 embedding 的 API 費用（建圖時每份文件都要呼叫多次）。改用 Ollama、vLLM 等本機模型則主要是硬體成本；MinerU 解析建議有 GPU。

## 限制與注意事項

- 是給開發者用的 Python 函式庫，沒有現成的聊天介面；要圖形介面可以看 [AnythingLLM](AnythingLLM.md)。
- 解析品質依賴 MinerU 等外部解析器；repo 的 `docs/multimodal_rag_failure_modes.md` 列了 OCR、表格、檢索偏差等常見問題。
- 中文或其他 CJK 音訊轉錄，README 建議改用 `medium` 以上的 Whisper 模型並指定語言，小模型會把專有名詞轉錯。
- Markdown 裡引用的本機圖片會被送給視覺模型，只匯入可信的 Markdown。
- 公開圖片網址（`*_public_url`）目前只有 MinerU 解析器支援。

## 相關工具

- [LightRAG](https://github.com/HKUDS/LightRAG)：RAG-Anything 的底層框架（同團隊）
- [MinerU](https://github.com/opendatalab/MinerU)：預設文件解析器
- [AnythingLLM](AnythingLLM.md)：有圖形介面、不用寫程式的文件問答 App
- [ViMax](../03-影片製作/ViMax.md)：同為 HKUDS 的專案

## 資料來源

- https://github.com/HKUDS/RAG-Anything （README）
- https://api.github.com/repos/HKUDS/RAG-Anything （星數、MIT、建立時間）
- https://api.github.com/repos/HKUDS/RAG-Anything/releases/latest （v1.4.2，2026-10-06）
- https://arxiv.org/abs/2510.12323 （技術報告）
