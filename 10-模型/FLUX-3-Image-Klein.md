# FLUX 3 Image Klein

- **分類**：模型 / 影像生成
- **連結**：https://huggingface.co/black-forest-labs/flux-3-image-klein

## 原清單說明

（原清單僅提供連結，無說明。）

## 概述

FLUX 3 Image Klein 是 Black Forest Labs（BFL）開放權重的「文生圖＋圖像編輯」模型（HF repo 建立於 2026-10-13）。同一個模型處理文生圖、單張參考圖編輯與多參考圖合成（最多 10 張參考圖，輸出一張圖），並可在 prompt 中用 bounding box 指定元素位置。此 repo 為**蒸餾版**，即 BFL API 上的 FLUX 3 Image Klein；微調、LoRA 訓練與研究請改用未蒸餾的 `flux-3-image-klein-base`。

## 模型規格

| 項目 | 內容 |
| --- | --- |
| 影像 transformer | 5.6B（HF safetensors 統計 5,548,681,984，BF16） |
| 文字編碼器 | Qwen3-VL-4B-Instruct（另計，不含在 5.6B 內；Apache-2.0） |
| 量化版本 | 同 repo 內附 FP8（`variants/fp8r/`）與 NVFP4（`variants/nvfp4/`） |
| 取樣 | Flow-map sampling |
| 步數／guidance | 蒸餾版 16 步、不用 guidance；Base 版 50 步、guidance 3.5 |

## 核心功能／特色

- 文生圖、單圖編輯、多參考圖生成整合在同一模型。
- **Bounding box 排版**：在 caption 後附上 JSON 元素清單，框座標為 0–1000 網格的 `[top, left, bottom, right]`；可依框重新上色、移動、替換或移除元素。框只引導位置與大小，不是硬 mask。
- 圖內文字渲染。
- **必須搭配 prompt upsampler**：模型吃的是完整場景描述，短 prompt 直接送入只會得到普通的結果。官方提供 `flux-3-image-klein-pup`（以 Qwen3.5-9B 微調，Apache-2.0，約 18.8 GB），也可用任何 LLM 搭配官方 `system_prompts.json`。

## 訓練方式

模型卡未說明訓練資料與流程 → **資料不足**（官方部落格 bfl.ai/blog/flux-3-image-klein，本條目未讀取）。

## 評測表現

模型卡未列出量化 benchmark → **資料不足**。

## 本地執行／使用方式

官方推論程式碼：https://github.com/black-forest-labs/flux-3-image-klein （Apache-2.0）

```bash
pip install -e .   # 在推論 repo 內
# 權重（gated，需先在 HF 同意授權並登入）
hf download black-forest-labs/flux-3-image-klein --local-dir weights/flux-3-image-klein
hf download Falconsai/nsfw_image_detection --local-dir weights/nsfw-classifier   # 安全分類器，必載
hf download black-forest-labs/flux-3-image-klein-pup --local-dir weights/pup        # prompt upsampler

python scripts/cli.py '<prompt>' --model distilled --out out.png
python scripts/cli.py '<編輯指令>' --model distilled --image out.png --out edited.png   # 可重複 --image
```

Diffusers（需原始碼版本）使用 `ModularPipeline.from_pretrained("black-forest-labs/flux-3-image-klein")`，但 pipeline 不會自動跑 prompt upsampler，需自行先用 pup 模型或其他 LLM 產生完整 caption 再傳入。

硬體（官方，B200、1024×1024、不含 upsampler 的峰值顯存）：BF16 31 GB、FP8 26 GB、NVFP4 25 GB；prompt upsampler 另需約 28 GB。

## 適用情境

- 需要精確排版（框選位置）的海報、插畫、產品圖生成。
- 多參考圖合成與局部編輯。
- 自架影像生成服務（非商用，或符合小型使用者條件的商用輸出）。

## 授權與成本

- 授權：**FLUX Kommunity License v1.0**。允許非商用；年營收（含關係企業）低於 US$500 萬的 Qualifying Users 可將**輸出**用於商業用途。其他商用需向 BFL 購買授權。此例外不等於可商用微調或散布。
- 禁止用途包括軍事、監控、生物特徵處理，以及用模型或其輸出改進同類競品模型等（見授權第 4 節）。
- 權重為 gated（需在 HF 同意條款）。文字編碼器 Qwen3-VL-4B-Instruct 與 prompt upsampler 為 Apache-2.0。
- 託管 API：BFL API 提供，價格資料不足。

## 限制與注意事項

- 不搭配 prompt upsampler 時效果明顯變差；一句簡短的編輯指令（如「改成藍色」）可能重新構圖。
- 圖內文字可能不準確或變形。
- 框不是硬 mask，元素可能超出框，小元素可能不出現；編輯可能改到指定區域以外的內容。
- 單張 GPU 至少需約 25–31 GB 顯存，加上 upsampler 更多。

## 相關模型

- FLUX 3 Image Klein Base（未蒸餾，用於微調與研究）：https://huggingface.co/black-forest-labs/flux-3-image-klein-base
- FLUX 3 Image Klein PUP（prompt upsampler）：https://huggingface.co/black-forest-labs/flux-3-image-klein-pup

## 資料來源

- https://huggingface.co/black-forest-labs/flux-3-image-klein （模型卡）
- https://huggingface.co/api/models/black-forest-labs/flux-3-image-klein （檔案清單、參數量、建立日期）
- https://huggingface.co/api/models/black-forest-labs/flux-3-image-klein-base 、https://huggingface.co/api/models/black-forest-labs/flux-3-image-klein-pup
- https://github.com/black-forest-labs/flux-3-image-klein
