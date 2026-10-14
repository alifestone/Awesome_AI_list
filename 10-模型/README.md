# 🧩 模型

可以下載、自己跑的開放模型：本地推理模型、程式碼模型、端側小模型、embedding 與影像生成模型，以及修正 Qwen 模型問題的 chat template。

## 本地可跑的通用 / 推理模型

### [Bonsai 2](Bonsai-2.md)

Prism ML 把 Qwen3.8-27B 的權重壓成三值 {−1, 0, +1}，27B 模型縮到約 6–7 GB，官方稱保留約 98% 表現。保留思考、工具呼叫與讀圖能力，262K context。Apache-2.0。

可以做到：
- 在一般筆電或單張消費級 GPU 上跑 27B 級的 agent 與推理。
- 長文件分析、整個 repo 的程式工作。
- 隱私敏感或離線環境；用 llama.cpp、MLX，甚至瀏覽器 WebGPU 執行。

### [Qwythos-9B](Qwythos-9B.md)

Empero 以 Qwen3.5-9B 全參數微調的推理模型，每個回答先輸出 `<think>` 推理，支援函式呼叫，context 可開到約 100 萬 tokens。提供 GGUF，可用 Ollama、LM Studio 跑。

可以做到：
- 在本機做 9B 級推理與工具呼叫實驗（Q4_K_M 約 5.6 GB）。
- 長 context 的實驗性用途。

## 程式碼模型

### [FrogNano-4B-2609](FrogNano-4B-2609.md)

Microsoft 從 Qwen3.5-4B 只用強化學習訓練的小型程式代理模型，搭配五工具的 Leaf 框架瀏覽程式碼、除錯、改檔、跑測試、產出 patch。官方自報 SWE-bench Verified 61.5%，定位為研究成果。

可以做到：
- 軟體工程與長程 coding agent 研究。
- 在沙箱中替有測試的 Python repo 產出候選 patch，再由人審查。

### [Mellum2](Mellum2.md)

JetBrains 從零訓練的 MoE 模型，總參數 12B、每個 token 只啟用 2.5B，專為大型 AI 系統中高頻、延遲敏感的中間步驟設計。有 Instruct 與 Thinking 版本。Apache-2.0。

可以做到：
- 多模型系統中的路由與編排。
- RAG 前後處理、agent 子任務（規劃、驗證、準備 context），減少呼叫大模型的次數。
- IDE 內高吞吐的程式功能、私有部署。

## 端側小模型

### [Needle](Needle.md)

Cactus Compute 給手機、穿戴裝置、機器人、車用、微控制器用的超小型模型，整個模型只有 8–29 MB。犧牲聊天能力，專攻工具呼叫、結構化抽取與 embedding。

可以做到：
- 在裝置上把離線語音／文字指令轉成函式呼叫。
- 從發票、通知、表單抽出型別化欄位或做分類。
- 依自己的工具集在本機微調，最小可縮到 2 層。

## Embedding

### [EmbeddingGemma 2](EmbeddingGemma-2.md)

Google DeepMind 的 740M 多模態 embedding 模型，把文字、程式碼、圖片、影片、音訊映射到同一個 768 維向量空間，可在手機、筆電上執行。支援 100 多種語言。Apache-2.0。

可以做到：
- 端側或筆電上的語意搜尋與 RAG（企業知識庫、程式碼搜尋、用語音搜音訊檔）。
- 分類、分群、去重、推薦、跨語言對齊。

## 影像生成

### [Qwen-Image-2.1](Qwen-Image-2.1.md)

阿里巴巴 Qwen 團隊的 7B 文生圖 + 圖像編輯模型，原生 2K 解析度，支援透明 RGBA。⚠️ 改用 Qwen Research License（非商用），和先前 Apache-2.0 的版本不同。

可以做到：
- 生成海報與含文字的圖像、透明貼圖與去背素材。
- 用最多 10 張參考圖做多物件合成，保留人物與產品的一致性。
- 用圈選、塗畫或 mask 做局部編輯。
- 商業用途需另取授權，或改用阿里雲託管 API。

## 影片生成

### [Index-AniSora](Index-AniSora.md)

bilibili 開源的動漫影片生成模型（IJCAI'25），V2 起以 Wan 系列為基底，V3 系列支援角色 360 度旋轉、任意幀推論、風格轉換與姿態／線稿／音訊引導。Apache 2.0。⚠️ 原清單給的是 cnb.cool 上的第三方鏡像，缺 V3，建議用官方 GitHub。

可以做到：
- 從立繪或關鍵幀生成番劇、PV、VTuber 等風格的動漫鏡頭。
- 產生角色轉身影片，輔助多角度一致或 3D 建模。
- 把現有影片轉成指定的動畫風格。

## 工具 / 修正檔

### [Qwen Fixed Chat Templates](Qwen-Fixed-Chat-Templates.md)

不是模型，而是可直接替換的 Qwen 3.5／3.6／3.8 Jinja chat template，修正官方模板的渲染錯誤、KV cache 失效、空白 `<think>` 污染、agent 卡死等問題。

可以做到：
- 在 llama.cpp、LM Studio、vLLM、SGLang、MLX 等本地引擎上穩定跑 Qwen。
- 讓 Qwen 接 Claude Code、Cline、Cursor 等 agent 或工具呼叫流程時不再崩潰或卡住。

## 怎麼挑

- **筆電上跑最強的**：Bonsai 2；記憶體更少：Qwythos-9B。
- **程式碼研究**：FrogNano；**多模型系統裡的小幫手**：Mellum2。
- **手機或嵌入式裝置**：Needle；**搜尋與 RAG**：EmbeddingGemma 2。
- **生圖**：Qwen-Image-2.1（注意非商用）；**動漫影片**：Index-AniSora。
- **本地跑 Qwen 一直出問題**：先換 Qwen Fixed Chat Templates。
- 怎麼在本機跑這些模型，見 [推論與訓練引擎](../11-推論與訓練引擎/)。
