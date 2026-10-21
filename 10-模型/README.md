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

### [Ornith 1.5](Ornith-1.5.md)

DeepReinforce 的開放權重家族：397B MoE 旗艦、35B-A3B MoE（每 token 啟用約 3B）與 9B 密集模型，另有手機用 9B-Mobile。256K context，MIT 授權，提供 GGUF，Ollama、llama.cpp 可跑。基準皆官方自報。

可以做到：
- 本機跑 9B（約 6.6 GB）或 35B-A3B（約 20 GB）的程式與 agent 任務。
- 手機端執行（9B-Mobile）。

### [Mellum2](Mellum2.md)

JetBrains 從零訓練的 MoE 模型，總參數 12B、每個 token 只啟用 2.5B，專為大型 AI 系統中高頻、延遲敏感的中間步驟設計。有 Instruct 與 Thinking 版本。Apache-2.0。

可以做到：
- 多模型系統中的路由與編排。
- RAG 前後處理、agent 子任務（規劃、驗證、準備 context），減少呼叫大模型的次數。
- IDE 內高吞吐的程式功能、私有部署。

## 程式碼模型

### [FrogNano-4B-2609](FrogNano-4B-2609.md)

Microsoft 從 Qwen3.5-4B 只用強化學習訓練的小型程式代理模型，搭配五工具的 Leaf 框架瀏覽程式碼、除錯、改檔、跑測試、產出 patch。官方自報 SWE-bench Verified 61.5%，定位為研究成果。

可以做到：
- 軟體工程與長程 coding agent 研究。
- 在沙箱中替有測試的 Python repo 產出候選 patch，再由人審查。

## 資安模型

### [OrcaCyber Nano 1.0](OrcaCyber-Nano-1.0.md)

OrcaRouter 的 27B 視覺語言資安模型（Qwen3.5 系架構），可讀程式碼、日誌、反組譯與工具截圖，主打本機離線執行。只提供 GGUF（13 GB／15.7 GB），原生 llama.cpp 可跑，262K context。HF 需登入同意條件下載，授權標為 Qwen。⚠️ 公開的評測都是通用基準且為官方自報，資安專項成績尚未公布。

可以做到：
- 在 16 GB 顯卡上本機做逆向、漏洞分析、安全程式碼審查，樣本不必上雲。
- 日誌、告警、封包擷取的分流與事件回應。
- 讀反組譯器或掃描工具的截圖並解釋。

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

## OCR／文件解析

### [Indra OCR](Indra-OCR.md)

Datalab 的輕量 OCR 模型組，只用 CPU（ONNX Runtime，不需 PyTorch 或 GPU），約 76 MB：把 PDF 和圖片轉成 Markdown、純文字或含座標框的 JSON，每行每塊都有版面標籤與閱讀順序。支援 80 多種語言，含簡繁中文、日文、韓文與直排。程式碼 Apache-2.0。⚠️ 權重為修改版 OpenRAIL-M：營收或募資超過 US$2,000 萬、或與 Datalab API 競爭的用途需付費授權。

可以做到：
- 在沒有 GPU 的機器上大量把 PDF、掃描檔轉成 Markdown 餵給 RAG（官方實測 32 核約 44 頁／秒）。
- 數位 PDF 直接讀文字層，只對圖片內文字做 OCR；加 `--math` 把公式轉成 LaTeX。
- 用本機網頁檢視器檢查每頁的行、區塊與閱讀順序，可和 Tesseract 並排比較。

## 影像生成

### [Qwen-Image-2.1](Qwen-Image-2.1.md)

阿里巴巴 Qwen 團隊的 7B 文生圖 + 圖像編輯模型，原生 2K 解析度，支援透明 RGBA。⚠️ 改用 Qwen Research License（非商用），和先前 Apache-2.0 的版本不同。

可以做到：
- 生成海報與含文字的圖像、透明貼圖與去背素材。
- 用最多 10 張參考圖做多物件合成，保留人物與產品的一致性。
- 用圈選、塗畫或 mask 做局部編輯。
- 商業用途需另取授權，或改用阿里雲託管 API。

### [FLUX 3 Image Klein](FLUX-3-Image-Klein.md)

Black Forest Labs 的 5.6B 文生圖 + 圖像編輯模型（另配 Qwen3-VL-4B 文字編碼器），最多 10 張參考圖，可在 prompt 裡用 bounding box 指定元素位置。蒸餾版 16 步。必須搭配 prompt upsampler。⚠️ FLUX Kommunity License：非商用，年營收低於 US$500 萬者可商用輸出。

可以做到：
- 用框選排版生成海報、插畫與含文字的圖像。
- 多參考圖合成，依框移動、替換或移除元素。
- 自架影像生成；微調或 LoRA 改用 Klein Base。

## 影片生成

### [Index-AniSora](Index-AniSora.md)

bilibili 開源的動漫影片生成模型（IJCAI'25），V2 起以 Wan 系列為基底，V3 系列支援角色 360 度旋轉、任意幀推論、風格轉換與姿態／線稿／音訊引導。Apache 2.0。⚠️ 原清單給的是 cnb.cool 上的第三方鏡像，缺 V3，建議用官方 GitHub。

可以做到：
- 從立繪或關鍵幀生成番劇、PV、VTuber 等風格的動漫鏡頭。
- 產生角色轉身影片，輔助多角度一致或 3D 建模。
- 把現有影片轉成指定的動畫風格。

### [Matrix-Game](Matrix-Game.md)

Skywork AI 的開源互動世界模型系列。3.0（以 Wan2.2-TI2V-5B 為基底）給一張圖和一段文字，就依鍵盤滑鼠動作即時生成第一人稱畫面，加了長時記憶讓場景前後一致，官方稱 720p 40 FPS。4.0 改成遊戲引擎負責玩法與物理、模型只把低多邊形畫面渲染成精緻畫面，附三個可玩場景。Apache-2.0。⚠️ 3.0 只在 A／H 系列 GPU 測過；4.0 最低支援 RTX 5070 Ti。

可以做到：
- 從一張圖生成可用動作操控、一分鐘以上仍保持一致的探索影片。
- 在消費級顯卡上試玩 AI 神經渲染的射擊與賽車遊戲，或讓 coding agent 改遊戲規則。
- 研究動作條件影片生成與世界模型（類似 Genie 的開源路線）。

## 工具 / 修正檔

### [Qwen Fixed Chat Templates](Qwen-Fixed-Chat-Templates.md)

不是模型，而是可直接替換的 Qwen 3.5／3.6／3.8 Jinja chat template，修正官方模板的渲染錯誤、KV cache 失效、空白 `<think>` 污染、agent 卡死等問題。

可以做到：
- 在 llama.cpp、LM Studio、vLLM、SGLang、MLX 等本地引擎上穩定跑 Qwen。
- 讓 Qwen 接 Claude Code、Cline、Cursor 等 agent 或工具呼叫流程時不再崩潰或卡住。

## 怎麼挑

- **筆電上跑最強的**：Bonsai 2；記憶體更少：Qwythos-9B。
- **程式碼研究**：FrogNano；**本機資安分析**：OrcaCyber Nano 1.0；**多模型系統裡的小幫手**（路由、RAG、子 agent）：Mellum2。
- **手機或嵌入式裝置**：Needle；**搜尋與 RAG**：EmbeddingGemma 2。
- **只用 CPU 把 PDF／掃描檔轉 Markdown**：Indra OCR（手寫、複雜表格、老舊掃描效果差；注意商用門檻）。
- **生圖**：Qwen-Image-2.1（注意非商用）、FLUX 3 Image Klein（需要框選排版時）；**動漫影片**：Index-AniSora；**可操控的互動世界／遊戲畫面**：Matrix-Game。
- **本地跑 Qwen 一直出問題**：先換 Qwen Fixed Chat Templates。
- 怎麼在本機跑這些模型，見 [推論與訓練引擎](../11-推論與訓練引擎/)。
