# Hands-On Large Language Models

- **分類**：學習資源 / 課程 / 教材
- **連結**：https://github.com/HandsOnLLM/Hands-On-Large-Language-Models
- **書本（O'Reilly）**：https://www.oreilly.com/library/view/hands-on-large-language/9781098150952/
- **教學文章**：https://www.aiposthub.com/hands-on-large-language-models-30k-stars/

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：repo 描述為 *Official code repo for the O'Reilly Book - "Hands-On Large Language Models"*。作者 Jay Alammar（《The Illustrated Transformer》作者）與 Maarten Grootendorst（BERTopic 作者），2024 年由 O'Reilly 出版（ISBN 978-1098150969），作者自稱「The Illustrated LLM Book」，全書約 400 頁、近 300 張自製圖解。repo 程式碼為 **Apache-2.0**；書本身需購買。查詢當下（2026-11-22）約 30,258 顆星、6,856 個 fork，最後一次 push 為 2026-04-24。

## 概述

這是一本偏「應用與直覺」的 LLM 入門書：用大量圖解說明 token、embedding、Transformer 內部、抽樣與 KV cache 等概念，再實際用預訓練模型做分類、分群、主題建模、語意搜尋、RAG、多模態，最後進入微調 embedding 模型與生成模型。repo 收錄全書 12 章的範例 notebook，每章一份，都有「Open in Colab」連結。

和本清單其他 LLM 教材相比：它不從零寫 Transformer（那是 [Train LLM From Scratch](Train-LLM-From-Scratch.md)），也不做可解釋性分析（那是 [50 ML Projects to Understand LLMs](ML4LLM-Book.md)），而是教「怎麼把現成模型用在真實任務上」。

## 課程／教材結構

| 章 | 主題 | 重點 |
|---|---|---|
| 1 | Introduction to Language Models | 語言模型演進、第一次載入並生成文字 |
| 2 | Tokens and Embeddings | 各種 tokenizer 比較、token／word embedding |
| 3 | Looking Inside Transformer LLMs | 輸入輸出、抽樣／解碼、KV cache 加速（以 Phi-3-mini 示範） |
| 4 | Text Classification | 用表示模型與生成模型做分類 |
| 5 | Text Clustering and Topic Modeling | 分群與 BERTopic |
| 6 | Prompt Engineering | 提示技巧、推理與輸出驗證 |
| 7 | Advanced Text Generation Techniques and Tools | LangChain 的 chains、對話記憶、ReAct agent |
| 8 | Semantic Search and RAG | 稠密檢索、重排序、RAG |
| 9 | Multimodal LLMs | 圖文模型 |
| 10 | Creating Text Embedding Models | 訓練／微調 embedding 模型 |
| 11 | Fine-tuning Representation Models for Classification | 微調 BERT、SetFit、NER |
| 12 | Fine-tuning Generation Models | QLoRA SFT（TinyLlama 1.1B）與 DPO 偏好對齊 |

另有 `bonus/` 目錄，連到作者後續的圖解長文：Mamba、量化、Stable Diffusion、MoE、推理模型、DeepSeek-R1、AI agents。

## 安裝與使用方式

官方建議用 **Google Colab**：README 說範例主要在 Colab 上開發與測試，免費 T4 GPU（16 GB VRAM）就夠。開啟章節的 Colab 連結後，到「執行階段 → 變更執行階段類型」選 T4 GPU，再執行 notebook 開頭的 `[OPTIONAL] Installing Packages` 儲存格。

本機執行（Python 3.10）：

```bash
git clone https://github.com/HandsOnLLM/Hands-On-Large-Language-Models
cd Hands-On-Large-Language-Models
conda env create -f environment.yml   # 或 pip install -r requirements.txt
```

之後依 PyTorch 官網安裝 GPU 版（多數範例需要 GPU）。Windows 用 pip 安裝時可能需要 Microsoft Visual C++ 14.0；`.setup/conda/` 有完整環境教學與常見問題。

## 適用情境

- 會基本 Python，想有系統地從概念到應用學 LLM 的開發者、資料科學家。
- 想要一份「每個概念都有圖、都有能跑的程式碼」的教材。
- 想理解 embedding、語意搜尋、RAG、微調等主題，並在 Colab 免費 GPU 上動手做。

## 授權與成本

- 程式碼 **Apache-2.0**。
- 書本需付費（Amazon、O'Reilly、Kindle 等）；沒有書也能跑 notebook，但圖解與解說主要在書中。
- Colab 免費版即可跑大部分範例。

## 限制與注意事項

- **套件版本停在 2024 年中**：`requirements.txt` 鎖定 `transformers 4.41.2`、`langchain 0.2.5`、`trl 0.9.4`、`torch 2.3.1` 等。現在的 Colab 預設環境較新，若出錯請用 notebook 內的安裝儲存格或照 requirements 鎖版本；LangChain、TRL 的 API 之後變動不少，照抄到新專案可能要改寫。
- 第 4、5、7 章有部分範例呼叫 OpenAI API、第 8 章呼叫 Cohere API，需要自己的金鑰（其餘多用 Hugging Face 開源模型，可跳過這些儲存格）；第 7 章的 agent 是 LangChain 0.2 時代的 ReAct 寫法，不涵蓋 MCP、現代 tool calling 框架。
- 教材為英文。
- 文章中的「破 3 萬星」與查證一致；但文章把 agent 歸在「第三部分：微調與 agent」，實際上 agent 在第 7 章，第 12 章只有 SFT 與 DPO（notebook 標題寫 PPO/DPO，程式碼示範 DPO）。

## 相關工具

- [50 ML Projects to Understand LLMs](ML4LLM-Book.md)：同為書本配套 notebook，改從可解釋性角度拆解模型內部。
- [Train LLM From Scratch](Train-LLM-From-Scratch.md)：從零手寫並訓練 LLM，補上本書沒有的預訓練部分。
- [AI Agents for Beginners](AI-Agents-for-Beginners.md)：本書 agent 內容較少，想深入 agent 可接這門課。

## 資料來源

- https://github.com/HandsOnLLM/Hands-On-Large-Language-Models
- https://github.com/HandsOnLLM/Hands-On-Large-Language-Models/tree/main/.setup
- https://www.oreilly.com/library/view/hands-on-large-language/9781098150952/
- https://www.aiposthub.com/hands-on-large-language-models-30k-stars/
