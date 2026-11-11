# MiniMax-H3-Image

- **分類**：模型 / 影像生成
- **連結**：https://huggingface.co/MiniMaxAI/MiniMax-H3-Image （線上試用：https://huggingface.co/spaces/MiniMaxAI/minimax-h3-image ；提示詞擴寫模型：https://huggingface.co/MiniMaxAI/MiniMax-H3-Image-PE ）

## 原清單說明

MiniMax 開放權重的生圖模型：約 1,600 萬畫素（4096×4096）輸出、官方稱 10 秒生成、最多 16 張參考圖，文生圖與圖像編輯在同一個 checkpoint；授權排除歐盟、英國、韓國與美國。（來源：使用者提供的電腦王阿達報導與 Hugging Face 模型頁）

> **查證補充**：規格與授權都正確，但有幾處要注意。(1)「10 秒」是官方貼文的數字，沒有說明硬體；vLLM-Omni 官方配方在 4 張 H200 上實測 4736×3552 約 3.84 秒、2048×2048 約 0.88 秒，單卡加分層卸載則要 8.3 秒才出一張 2048×2048。(2)「最多 16 張參考圖」是模型卡與 API 的上限，vLLM-Omni 配方只寫到 9 張，Hugging Face Space 限 8 張。(3) 模型卡說文字編碼器「不在本 repo」，但截至 2026-11-11 repo 裡其實有 `text_encoder/`（66.7 GB），另外還有 diffusers 格式的 transformer 與 VAE 副本，直接 `hf download` 整個 repo 會抓約 204 GB，見「本地執行」。(4)「開源模型中最強的指令遵循」是官方說法，模型卡沒有附 benchmark 數字。

## 概述

MiniMax-H3-Image 是 MiniMax 從影音生成模型 [MiniMax-H3](https://huggingface.co/MiniMaxAI/MiniMax-H3) 衍生出的圖像模型，2026-11-10 上傳權重並宣布開放。它的擴散 transformer（DiT）就是 H3 的架構拿掉音訊層，文字編碼器直接沿用 H3 的；同一個 checkpoint 處理文生圖與單張或多張參考圖編輯。主打兩點：一是各種長寬比都能直接輸出約 16 MP 的圖，不經放大模型；二是蒸餾到 6 步、不用 classifier-free guidance，讓這麼大的圖還能在幾秒內出來。

除了開放權重，也可用 MiniMax API（另有計價較高的 Highspeed 版）、海螺 AI 網頁版與 MiniMax Agent 桌面版。截至 2026-11-11，Hugging Face 模型頁約 511 個讚、667 次下載，HF 標記為非 gated（不需申請即可下載）。

## 模型規格

| 項目 | 內容 |
| --- | --- |
| 擴散 transformer | 33.1B 稠密單流 DiT，50 層、hidden 5376、56 頭、FFN 14336，3D 多模態 RoPE；BF16（embedding、timestep、輸出層為 FP32），約 66.3 GB |
| 文字編碼器 | MiniMax-H3 的完整 Qwen3-VL 編碼器（約 33.4B，BF16，約 66.7 GB），DiT 讀它第 50 層的 hidden states；參考圖也會經過它 |
| 圖像 VAE | CNN 編碼器＋24 層 2D ViT 解碼器，16 倍空間下採樣、24 個 latent channel，約 0.58B（FP32，2.34 GB）；DiT 以 2×2 patch 切，每個 token 對應 32×32 像素 |
| 取樣 | 6 步（6 NFE），不用 CFG；每步各有獨立輸出頭（`pdd_fused_heads.safetensors`） |
| 輸出尺寸 | 有效範圍約 4–20 MP，16 MP 最佳：1:1 4096×4096、4:3 4736×3552、3:2 5024×3360、16:9 5472×3072、21:9 6272×2688 |
| 提示詞擴寫（選用） | MiniMax-H3-Image-PE：以 Qwen3.8-27B 微調，NVFP4，17.9 GB |

## 核心功能／特色

- **文生圖＋編輯同一模型**：送參考圖就是編輯，沒有任務切換參數；參考圖依上傳順序在提示詞裡稱 `<Picture 1>`、`<Picture 2>`……
- **多參考圖合成**：官方範例把一張空房間加九件家具合成成一間客廳；也能把未上材質的 3D 算圖轉成電影劇照、把遊戲地圖轉成第一人稱視角畫面。
- **高解析度直出**：16 MP 不經 upscaler；比 2048×2048 小的尺寸會在至少 2048² 的同比例畫布上生成再縮回來（可用 `min_generation_area` 關掉）。
- **圖內文字**：官方展示中英文邏輯謎題板，連推理答案都寫在圖上（官方挑選的展示圖）。
- **固定參數**：`num_inference_steps` 只能 6、`guidance_scale` 只能 1，其他值回 HTTP 400；不支援負面提示詞；提示詞超過 4096 token 會被截斷；每次請求出一張圖。
- **需要詳細英文描述**：模型吃的是整張圖的完整英文描述。官方 API 會先用 H3-Image-Context-IR 把任何語言的短提示詞擴寫；本機可改用 MiniMax-H3-Image-PE，它會一併建議長寬比。

## 技術架構或運作原理

- 文字提示與參考圖先由 H3 的 Qwen3-VL 文字編碼器編碼，參考圖另外經 VAE 編成 latent；所有 token 組成一條序列送進單流 transformer，預測目標圖的 latent，再由 VAE 解碼。
- 後訓練包含資料、強化學習、步數壓縮（蒸餾到 6 步）、提示詞擴寫與部署最佳化（來源：電腦王阿達報導整理官方說法；模型卡未說明訓練資料與流程 → 細節**資料不足**）。
- **評測**：模型卡沒有量化 benchmark，只有展示圖 → **資料不足**。

## 本地執行／使用方式

官方建議的推論框架：SGLang、vLLM-Omni、diffusers、ComfyUI（第一天都有支援）。

**下載**——不要直接抓整個 repo（約 204 GB，含重複的 diffusers 格式權重與文字編碼器）。依需要指定資料夾，例如 SGLang／vLLM-Omni 用原生格式：

```bash
hf download MiniMaxAI/MiniMax-H3-Image \
  --exclude "transformer_diffusers/*" --exclude "vae_diffusers/*" --exclude "text_encoder/*"
hf download MiniMaxAI/MiniMax-H3 --include "text_encoder/*"   # model_index.json 從這裡載入文字編碼器
hf download MiniMaxAI/MiniMax-H3-Image-PE                     # 選用：本機提示詞擴寫
```

合計約 135 GB 磁碟（vLLM 配方估約 127 GB）。

**啟動服務**（OpenAI 相容的 `/v1/images/generations` 與 `/v1/images/edits`，回傳 PNG 的 base64）：

```bash
# SGLang，單卡
sglang serve --model-path MiniMaxAI/MiniMax-H3-Image --host 0.0.0.0 --port 30000 --warmup-mode off
# vLLM-Omni，4 卡序列平行
vllm serve MiniMaxAI/MiniMax-H3-Image --omni --host 0.0.0.0 --port 8000 \
  --num-gpus 4 --usp 4 --text-encoder-tp-size 4
```

repo 的 `examples/` 有只用 Python 標準函式庫的腳本（`t2i.py`、`edit.py`、`context_ir.py`、`api_generate.py`），可對照本機與 API 的出圖結果。注意 `context_ir.py` 呼叫的是 MiniMax 付費 API，完全離線要改用 PE 模型。

**硬體**（vLLM-Omni 配方，H200 實測峰值顯存／2048² 文生圖時間）：

| 配置 | 每卡峰值 | 時間 |
| --- | --- | --- |
| 1 卡，DiT 常駐、文字編碼器分層卸載 | 73.4 GiB | 3.2 s |
| 1 卡，DiT 與文字編碼器都分層卸載 | 14.7 GiB | 8.3 s |
| 2 卡，DiT TP 2 | 63.3 GiB | 1.5 s |
| 4 卡，DiT TP 4 | 36.2 GiB | 1.0 s |
| 4 卡，Ulysses SP 4（預設） | 81.3 GiB | 0.88 s |

全部常駐單卡估計約 135 GiB（B200／B300 適用）；80 GB 的 H100 要用分層卸載或 4 卡 TP；96 GB RTX PRO 6000 Blackwell 各種常駐配置都放得下；AMD MI325X、MI350X 已驗證。配方註明量化、模型 CPU offload 與 cache 加速**尚未驗證**，目前沒有官方量化版，消費級顯卡只能靠分層卸載（且需要大量系統記憶體）。

**線上試用**：Hugging Face Space（ZeroGPU，最多 8 張參考圖，內建 PE 擴寫）。

## 適用情境

- 需要直接輸出 4K 級大圖的海報、概念美術、環境與角色設定圖。
- 多張參考圖合成（產品、家具、人物放進同一場景）、3D 白模轉寫實圖。
- 有資料中心級 GPU、想自架高解析度生圖服務的團隊（注意授權的託管服務條款）。

## 授權與成本

- 授權：**MiniMax-H3-Image Community License Agreement**（HF 上只顯示 `license: other`）。PE 擴寫模型雖然源自 Apache-2.0 的 Qwen3.8-27B，也一併適用此授權。
- **排除地區：歐盟、英國、南韓、美國**——在這些地區不得使用、重製、散布模型或其**輸出**；在台灣等其他地區可用。
- 年化營收（含關係企業）超過 **US$100 萬**，或對第三方提供**託管服務**（API、網頁等，無營收門檻），都要事先向 MiniMax 申請書面授權。
- 商業產品介面須顯著標示「MiniMax-H3-Image」；散布時須附授權與 NOTICE 檔。
- 不得用模型或其輸出改進其他 AI 模型（含蒸餾、用合成資料訓練）；禁止軍事用途、未揭露的機器生成內容公開發布、高風險自動化決策等（見授權附件 A）。
- 準據法為香港法律。MiniMax 不主張輸出的權利，但使用者需自負輸出責任。
- **API 價格**（電腦王阿達報導，未至 MiniMax 官網核對）：輸入文字每百萬 token US$2.30、輸入圖像 US$1.50、輸出圖像 US$3.80；單張 4K 生成約 US$0.069，發表首週 16 MP 以上五折。

## 限制與注意事項

- 本機門檻極高：DiT 與文字編碼器各約 33B，至少需要一張 80 GB 級資料中心 GPU 才跑得順；單卡分層卸載雖然只要約 15 GiB 顯存，但速度慢且需要大量系統記憶體。
- 步數與 guidance 鎖死，不能用加步數換品質，也沒有負面提示詞。
- 短提示詞直接送進去效果差，需要先擴寫；完全離線要多部署一個 27B 的 PE 模型。
- 參考圖上限依部署方式而異（模型卡／API 16 張、vLLM-Omni 配方 9 張、Space 8 張）；官方建議把多個修改合成一次編輯，不要串接多次編輯。
- 沒有公開 benchmark，畫質與「最強指令遵循」都只能看官方展示與自行測試。
- 授權的地區限制連輸出都適用，美國、歐盟、英國、韓國的使用者或服務對象需特別注意。

## 相關模型

- [Qwen-Image-2.1](Qwen-Image-2.1.md)：7B，原生 2K、透明 RGBA，非商用授權，硬體需求低得多。
- [FLUX 3 Image Klein](FLUX-3-Image-Klein.md)：5.6B，bounding box 排版，單卡約 25–31 GB 顯存。
- MiniMax-H3（影音生成母模型）：https://huggingface.co/MiniMaxAI/MiniMax-H3 ；以它為基礎的專案見 [StreamRender-H3](../02-3D-建模與生成/StreamRender-H3.md)、[Code Video Model](../03-影片製作/Code-Video-Model.md)。

## 資料來源

- https://huggingface.co/MiniMaxAI/MiniMax-H3-Image （模型卡、`model_index.json`、LICENSE）
- https://huggingface.co/api/models/MiniMaxAI/MiniMax-H3-Image （檔案清單與大小、建立日期、讚數與下載數）
- https://huggingface.co/api/models/MiniMaxAI/MiniMax-H3-Image-PE （PE 參數量、基底模型）
- https://huggingface.co/spaces/MiniMaxAI/minimax-h3-image （Space 設定與 `app.py`）
- https://recipes.vllm.ai/MiniMaxAI/MiniMax-H3-Image （vLLM-Omni 部署配方、顯存與延遲實測）
- https://www.kocpc.com.tw/archives/702974 （電腦王阿達報導：發表時程、官方貼文、API 價格）
