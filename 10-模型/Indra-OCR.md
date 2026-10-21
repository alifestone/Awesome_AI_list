# Indra OCR

- **分類**：模型 / OCR／文件解析
- **連結**：https://huggingface.co/datalab-to/indra-ocr
- **原始碼**：https://github.com/datalab-to/indra

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：Datalab（Marker、Surya、Chandra 的團隊）出的 CPU OCR 模型組，用 ONNX Runtime 執行，不需 PyTorch 或 GPU。模型卡寫「1M 參數」，指的是主要的拉丁文字辨識器（約 1.25M）；預設整組模型合計約 7.3M 參數、76 MB。程式碼 Apache-2.0，**權重為修改版 OpenRAIL-M，商用有門檻**。

## 概述

Indra OCR 把 PDF 與圖片轉成 Markdown、純文字，或含座標框的 JSON，並給每一行、每個區塊標籤與閱讀順序。設計重點是在 CPU 上快：官方在 32 核 x86 上量到約 44 頁／秒，4 核約 210 ms 一頁。數位 PDF 會先讀既有文字層，只對缺的部分做 OCR。

由 Datalab 發布；Hugging Face 模型於 2026-10-10 建立，GitHub repo 於 2026-10-13 建立。查詢當下（2026-10-21）HF 約 320 likes、3.1k 下載，GitHub 約 865 顆星，PyPI 最新版 1.1.2。

## 核心功能／特色

- **四個辨識器＋分流**：拉丁／西里爾／希臘（含拉丁手寫）、中日韓（簡繁中文、日文假名與漢字、韓文）、由右至左（阿拉伯、波斯、烏爾都、希伯來等）、印度與東南亞等其他文字；行分類器把每一行送到對應的辨識器，不確定時用主辨識器再讀一次，取信心較高者。
- **語言**：官方在 95 種語言的印刷頁上量測，83 種字元 F1 ≥ 0.90。
- **版面分析**：每行、每個區塊都有框、標籤與閱讀順序；標籤有標題、清單、表格、圖說、註腳、頁首頁尾、目錄、表單。
- **歪斜與方向**：側放、倒置、傾斜到 45 度、深底淺字都能讀；中日文直排頁會轉向後逐欄辨識。
- **數位 PDF**：任何文字都能從文字層讀取，只對圖片中的文字做 OCR（`hybrid`）。
- **數學**（選用 `--math`）：另載小模型，把數學行輸出成行內 LaTeX；較慢。
- **本機檢視器**：`indra-ocr-viewer` 在瀏覽器上疊出行、區塊與閱讀順序，可並排比較 Tesseract；檔案不離開本機。

## 安裝與使用方式

需求：Python 3.10+；在 Linux（x86_64、aarch64）與 macOS（Apple Silicon）測過。安裝 ONNX Runtime、OpenCV、pypdfium2。首次執行從 Hugging Face 下載約 76 MB 模型。

```sh
pip install indra-ocr

indra-ocr paper.pdf                 # Markdown 輸出到 stdout
indra-ocr *.pdf --out results/      # 每個檔案一份 .md，預設用全部核心
indra-ocr scan.png --format json    # 行、框、版面區塊、信心值
indra-ocr paper.pdf --math          # 數學轉 LaTeX
indra-ocr-viewer                    # http://localhost:8765
```

```python
import indra_ocr

conv = indra_ocr.load(threads=4)
for i, page in conv.convert("paper.pdf"):
    print(page.markdown)   # 表格以 HTML 輸出
    page.blocks            # [{"label", "bbox", "text"}]，依閱讀順序
```

官方 OmniParseBench 數字（2,937 頁，4 vCPU，自家跑分，非獨立評測）：

| 引擎 | 總分 | 文字 | 表格 | 版面 | 每頁中位數 |
|---|---:|---:|---:|---:|---:|
| Indra OCR（預設） | 66.7 | 46.7 | 61.1 | 92.2 | 212 ms |
| Indra OCR `--math` | 71.4 | 62.7 | 59.6 | 92.0 | 357 ms |
| PaddleOCR PP-StructureV3 | 58.4 | 55.6 | 47.8 | 71.7 | 40,958 ms |
| Tesseract 5 | – | 19.3 | – | – | 5,496 ms |

中文（136 題）：Indra OCR 64.0，PP-OCRv5 mobile 65.4，PP-StructureV3 68.4。

## 適用情境

- 在沒有 GPU 的伺服器或筆電上大量把 PDF、掃描檔轉成 Markdown，餵給 RAG 或 LLM。
- 需要版面框與閱讀順序的文件前處理（擷取標題、表格、註腳）。
- 取代 Tesseract 做多語印刷文件的 OCR，或在資料不能上雲時本機處理。

## 授權與成本

- 程式碼：**Apache-2.0**。
- 權重：**修改版 OpenRAIL-M**。研究、個人用途，以及募資或營收低於 US$2,000 萬的新創可免費使用；**不得用來與 Datalab 的 API 競爭**。超出範圍需向 Datalab 購買商用授權。
- 本身免費、只用 CPU。Datalab 另有付費雲端平台（跑精度更高的 Chandra 模型）。

## 限制與注意事項

- 主打乾淨的印刷文件。官方列出的弱項：
  - 複雜表格（合併儲存格、跨行、無格線）可能錯行錯欄。
  - 手寫：OmniParseBench 手寫題只有 25.2%。
  - 老舊、褪色、低解析度掃描：29.5%。
- 中文辨識器不含粵語用字（嘅、咗、冇）；高棉文、馬拉雅拉姆文 OCR 一般；藏文、蒙古文等只能讀數位 PDF 的文字層。
- 捷克、土耳其等重音符號多的拉丁語言，偶爾會寫成相近的符號。
- 直排報紙跨欄的文章順序可能出錯；很寬的橫幅頁、工程圖標註效果差。
- 未開 `--math` 時數學以純文字輸出。
- 所有評測數字皆為官方自測。

## 相關工具

- [RAG-Anything](../06-Agent-框架與編排/RAG-Anything.md)：多模態 RAG 框架，文件解析可用 MinerU、Docling、PaddleOCR；Indra OCR 可當其他選擇做前處理。
- [Chandra](https://github.com/datalab-to/chandra)：同團隊、精度更高的 OCR 模型，手寫、數學、複雜表格表現較好，但需要較重的硬體或付費平台。
- [PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR)、[Tesseract](https://github.com/tesseract-ocr/tesseract)：官方比較對象。

## 資料來源

- https://huggingface.co/datalab-to/indra-ocr （模型卡）
- https://github.com/datalab-to/indra
- https://pypi.org/project/indra-ocr/
