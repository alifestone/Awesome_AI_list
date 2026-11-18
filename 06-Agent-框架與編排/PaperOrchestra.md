# PaperOrchestra

- **分類**：Agent 框架與編排
- **連結**：https://github.com/google-research/paper-orchestra

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：Google Cloud AI Research 的多 agent 論文寫作框架（論文 arXiv:2604.05018），把研究點子與實驗紀錄轉成可投稿格式的 LaTeX 論文。README 註明「not an officially supported Google product」；論文用的 PaperWritingBench 資料集尚未隨 repo 釋出。

## 概述

PaperOrchestra 把寫論文拆給一組專門 agent：大綱、文獻回顧、各節撰寫、內容修潤（reflection）與畫圖。輸入是不限格式的寫作前素材（點子文件與實驗紀錄），輸出是套用目標會議模板、含文獻整理與圖表的 LaTeX 稿件。

作者為 Yiwen Song、Yale Song、Tomas Pfister、Jinsung Yoon。repo 於 2026-05-01 建立，查詢當下（2026-11-18）約 3.9k 顆星，無正式 release。

## 核心功能／特色

- **多 agent 流程**：Outline → Literature Review → Section Writing → Content Refinement → Plotting，端到端產生論文。
- **文獻整合**：透過 Semantic Scholar 搜尋、排序並寫進文獻回顧；可用 `--research_cutoff`（如 `2024-11`）限制文獻日期。
- **圖表生成**（選用）：plotting agent 寫程式畫圖，最多 3 輪自我批評修正；需要時用影像模型。也支援放入概念圖。
- **LaTeX 模板**：內建 `cvpr2025`、`iclr2025`，可在 `templates/` 新增自己的會議模板。
- **自動評測**：`autoraters/` 含引用 F1、文獻回顧品質、整篇論文品質（含 side-by-side 比較）與 agent 審稿等評測腳本。
- **Streamlit 介面**：`frontend/` 提供互動 demo，在背景執行生成流程。
- **論文結果**（作者自評）：在 200 篇頂會論文反推素材組成的 PaperWritingBench 上，人工 side-by-side 評比中，文獻回顧品質勝率領先自主寫作 baseline 50～68 個百分點，整體稿件品質領先 14～38 個百分點。

## 安裝與使用方式

```bash
git clone https://github.com/google-research/paper-orchestra.git && cd paper-orchestra
conda create -n paper_orchestra python=3.11
conda activate paper_orchestra
pip install -r requirements.txt

# .env：至少要有用到的模型 key
# SEMANTIC_SCHOLAR_API_KEY=...
# GEMINI_API_KEY=...（或 VERTEX_AI_PROJECT + VERTEX_AI_LOCATION）
# OPENAI_API_KEY=...（用 OpenAI 模型時）

# raw_materials 內放 idea_sparse.md 與 experimental_log.md
python paper_writing_cli.py \
  --raw_materials_dir ./my_project/raw_materials \
  --latex_template_dir templates/iclr2025 \
  --output_dir ./paper_output \
  --use_plotting true

# 互動介面
streamlit run frontend/app.py
```

預設模型：寫作、reflection、畫圖都用 `gemini-3.1-pro-preview`，影像用 `gemini-3-pro-image-preview`，可用 `--writer_model_name` 等參數更換。

## 適用情境

- 手上有研究點子與實驗紀錄，想快速產出一份投稿格式的 LaTeX 初稿再自己改。
- 自動整理相關文獻、產生文獻回顧與引用。
- 研究「AI 寫論文」的流程設計與評測方法（可用 autoraters 評估自己的系統）。

## 授權與成本

- 程式碼 **Apache-2.0**。
- 軟體免費；成本為 LLM API 費用（預設 Gemini 3.1 Pro，多 agent 加多輪修潤，一篇論文會呼叫很多次）與 Semantic Scholar API key（可免費申請）。

## 限制與注意事項

- 非 Google 官方支援產品，屬研究程式碼。
- PaperWritingBench 資料集未隨 repo 釋出，`paper_writing_cli.sh` 範例指向的 `datasets/` 需等官方另行發布，自己用時要準備素材。
- 預設綁 Gemini，換模型需自行測試；未提及本地模型支援。
- 論文勝率為作者自評，對手是其他自主寫作系統，不代表可直接投稿；生成內容與引用仍需人工逐一查核，並留意投稿會議對 AI 寫作的規定。
- `.env` 可設 SMTP 帳密讓 demo 完成時寄信給自己，不需要就別填。

## 相關工具

- [DSPy](DSPy.md)、[CrewAI](CrewAI.md)：通用的 LLM 管線／多 agent 框架，可自建類似流程。
- [AI Job Search](AI-Job-Search.md)：同樣以起草 agent＋審稿 agent 產出 LaTeX 文件的應用工作流。
- 文獻與知識庫工具見 [🗂️ RAG、知識庫與記憶](../14-RAG-知識庫與記憶/)。

## 資料來源

- https://github.com/google-research/paper-orchestra
- https://arxiv.org/abs/2604.05018
- https://yiwen-song.github.io/paper_orchestra/
