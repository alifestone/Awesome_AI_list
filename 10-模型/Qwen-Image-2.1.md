# Qwen-Image-2.1

- **分類**：模型 / 影像生成
- **連結**：https://huggingface.co/Qwen/Qwen-Image-2.1

## 原清單說明

7B 文生圖 + 圖像編輯，支援原生透明 RGBA。⚠️ 授權改為 Qwen Research License（非商用），與先前 Apache 2.0 的版本不同。

> ⚠️ 查證結果：**屬實**。Qwen-Image-2.1 的 LICENSE 為「Qwen RESEARCH LICENSE AGREEMENT」（2026-09-20），只授權「非商業用途（研究或評估）」，商用需另向 model-business@notice.qwencloud.com 申請授權。先前開源的 Qwen-Image 系列（Qwen-Image、Qwen-Image-2512、Qwen-Image-Edit-2509、Qwen-Image-Edit-2511）在 HF 上皆標示 Apache 2.0。2026-10-09 推出的 Qwen-Image-2.1-Turbo 同樣是 Qwen Research License。
> 補充：「7B」指的是**視覺生成元件（DiT）**；完整管線另含 Qwen3-VL 8B 文字編碼器與 VAE，實際總參數量遠大於 7B。

## 概述

Qwen-Image-2.1 是阿里巴巴 Qwen 團隊開源權重的統一「文生圖＋圖像編輯」模型（HF repo 建立於 2026-09-14，GitHub 新聞列 2026-09-20 發布各推論框架 Day-0 支援）。官方強調四項改進：

- **精簡高效**：混合粒度注意力與 prefix KV cache 重用，以較低運算量取得高品質。
- **原生透明度、統一生成與編輯**：可從文字生成一般或透明（RGBA）影像、編輯透明圖層、從照片擷取主體。
- **多樣化編輯**：最多 10 張參考圖；可用圈選、塗畫標註或獨立 mask 指定局部編輯；保留人物與產品的身分一致性。
- **寫實質感與美感**：改善文字排版、人像光線與細節。

## 模型規格

| 項目 | 內容 |
| --- | --- |
| 生成元件 | Single-stream DiT，32 層，約 7B 參數（HF safetensors 統計 7,115,124,736；bf16 約 14.2 GB） |
| 注意力 | Block-causal：文字為 token 級因果 mask，影像為 chunk 級雙向 mask |
| 文字編碼器 | Qwen3-VL 8B（視覺語言模型，同時編碼文字指令與條件影像） |
| VAE | 64 通道 RGBA autoencoder，16 倍空間壓縮，原生支援透明 |
| Scheduler | Flow Matching，Euler discrete＋dynamic shifting |
| 原生解析度 | 2K（預設 2048×2048；支援 1:1、4:3、3:4、3:2、2:3、16:9、9:16 等比例） |
| 預設步數 | 40（Turbo 版 8 步） |

## 核心功能／特色

- 文生圖、單圖編輯、多參考圖合成（最多 10 張）、透明 RGBA 生成。
- Prefix KV cache：文字與條件影像在第一步計算後快取，後續去噪步驟重用，對多參考圖編輯加速明顯。
- 官方提供兩個 prompt 改寫模型（以 Qwen3.5-VL 9B 微調）：`Qwen/Qwen-Image-2.1-PE-T2I`、`Qwen/Qwen-Image-2.1-PE-I2I`，把短 prompt 擴寫為詳細描述並建議長寬比。
- 透明圖建議 prompt 格式：`This is an RGBA image with transparency. <描述>. The image has alpha channel and the background is transparent.`

## 訓練方式

訓練資料、訓練流程與規模：模型卡與 GitHub README 皆未說明 → **資料不足**（官方指向部落格 qwen.ai/blog?id=qwen-image-2.1，本條目未讀取）。

## 評測表現

模型卡與 GitHub README 未列出量化 benchmark（僅有展示圖）→ **資料不足**。

## 本地執行／使用方式

```bash
pip install "torch>=2.4.0" "transformers>=5.17" accelerate pillow
pip install git+https://github.com/huggingface/diffusers
```

```python
import torch
from diffusers import QwenImage21Pipeline

pipe = QwenImage21Pipeline.from_pretrained(
    "Qwen/Qwen-Image-2.1", torch_dtype=torch.bfloat16
).to("cuda")
# 顯存不足時改用：pipe.enable_model_cpu_offload()

image = pipe(
    prompt='A neon shop sign that reads "QWEN IMAGE 2.1", rainy night',
    width=2048, height=2048, num_inference_steps=40,
    generator=torch.Generator("cuda").manual_seed(42),
).images[0]
image.save("out.png")

# 編輯：pipe(prompt="Change the background to a sunset beach", image=input_image, ...)
# 多參考圖：image=[img1, img2, img3]
```

其他推論方式（官方 README 列出）：
- **vLLM-Omni**：`vllm serve Qwen/Qwen-Image-2.1 --omni --port 8091`，提供 `/v1/images/generations` API；支援 FP8、prefix KV cache、CUDA Graph、TP。
- **SGLang-Diffusion**、**LightX2V**：Day-0 支援。
- **ComfyUI**：Day-0 原生支援，權重見 `Comfy-Org/Qwen-Image-2.1`。
- **ModelScope／DiffSynth-Studio**：下載、線上生成、LoRA 訓練。
- 硬體：AMD Radeon（ROCm）；FlagOS 提供 8 種晶片平台的預建映像。
- 託管 API：阿里雲 Model Studio 提供 Qwen-Image-2.1 Pro 與 Turbo API。

## 適用情境

- 研究或評估用途的文生圖、海報／含文字圖像、透明貼圖與去背素材、多人／多物件合成、產品與人像一致性編輯、局部編輯。
- 商業用途需另取得授權，或改用阿里雲託管 API。

## 授權與成本

- 授權：**Qwen Research License（非商用）**。要點：僅限研究或評估；商用需另行申請；散布須附授權書與「Qwen is licensed under the Qwen RESEARCH LICENSE AGREEMENT...」聲明；用其輸出訓練並發布的模型須標示「Built with Qwen」或「Improved using Qwen」；不得以「Qwen」作為衍生作品的主要名稱；準據法為中國法律、杭州法院管轄。
- 成本：權重免費下載（限非商用）；完整管線（7B DiT＋8B 文字編碼器＋VAE）bf16 下需大量顯存，官方提供 CPU offload 選項，最低顯存需求未公布 → 資料不足。託管 API 價格：資料不足。

## 限制與注意事項

- 非商用授權是與前代最大差異，商業專案不可直接使用開源權重。
- 需安裝 diffusers 原始碼版本（`QwenImage21Pipeline`）。
- Turbo 版使用內存的 8 步排程，單獨設 `num_inference_steps` 不會覆蓋。
- 官方未公布量化評測數據。

## 相關模型

- Qwen-Image-2.1-Turbo（8 步生成／編輯，同為 Qwen Research License）
- Qwen-Image-2.1-PE-T2I／PE-I2I（prompt 改寫模型）
- 前代 Apache 2.0 版本：Qwen-Image、Qwen-Image-2512、Qwen-Image-Edit-2509、Qwen-Image-Edit-2511

## 資料來源

- https://huggingface.co/Qwen/Qwen-Image-2.1 （README 與 LICENSE 原始檔）
- https://github.com/QwenLM/Qwen-Image-2.1 （README）
- https://huggingface.co/api/models/Qwen/Qwen-Image-2.1 （檔案清單、參數量、建立日期）
- https://huggingface.co/Qwen/Qwen-Image-2.1/raw/main/text_encoder/config.json
- https://huggingface.co/api/models/Qwen/Qwen-Image-2.1-Turbo 、https://huggingface.co/api/models/Qwen/Qwen-Image 、https://huggingface.co/api/models/Qwen/Qwen-Image-2512 、https://huggingface.co/api/models/Qwen/Qwen-Image-Edit-2509 、https://huggingface.co/api/models/Qwen/Qwen-Image-Edit-2511 （授權比對）
