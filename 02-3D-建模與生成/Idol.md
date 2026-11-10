# Idol

- **分類**：3D 建模與生成 / AI 生成 3D 資產
- **連結**：https://github.com/speridlabs/idol-sdk （模型：https://huggingface.co/speridlabs/idol ；專案頁：https://speridlabs.com/research/idol ；線上試用：https://huggingface.co/spaces/speridlabs/idol ）

## 原清單說明

單張圖片 → 3D 高斯點雲（3DGS）物件，可在消費級 GPU 上執行。（來源：使用者提供的 Hugging Face 模型頁與專案頁）

> **查證補充**：正確，但有兩處數字容易混淆。(1) 參數量：專案頁寫 **0.66B**，模型頁與 repo 寫 **約 1.80B**，兩者不矛盾——0.66B 是生成部分（DiT 370.6M＋octree 解碼器 50.8M＋Gaussian 解碼器 237.3M），1.80B 是整個請求會載入的所有元件（再加上 DINOv3 840.6M、BiRefNet 220.7M、FLUX.2 VAE 84.1M）。(2) 速度：README 與模型卡寫「可在 2 秒內執行」，但同一份 README 的實測表是 262,144 個高斯、50 步取樣時，B300 為 3.4 秒、H100 為 6.7 秒、RTX 4090 為 19.1 秒，沒有說明「2 秒內」的設定，可能是減少步數或高斯數量，需自行驗證。另外 Idol 本身是 Apache-2.0，但它依賴的兩個編碼器有各自的授權，見「授權與成本」。

## 概述

Idol 是 Speridlabs（作者 Alejandro Cañada、Chema Garabito）發布的單圖生成 3D 模型：給一張物體的圖片（渲染圖、生成圖或照片），它會自動去背、置中裁切，生成最多 1,048,576 個 3D 高斯，連圖片沒拍到的背面也會補出來，輸出標準 3DGS `.ply`。專案頁的圖片輸入也包括該公司另一個文生圖模型 Iris-3B 的產出。Idol 建立在 VAST-AI 的 [TripoSplat](https://github.com/VAST-AI-Research/TripoSplat) 之上。

截至 2026-11-10：SDK repo 為 Apache-2.0、約 974 顆星、主要語言 Python，建立於 2026-10-28，最後推送為 2026-11-09，目前版本 0.1.0；Hugging Face 模型頁約 1.7k 個讚、約 2.6 萬次下載。專案很新，API 與權重都可能還會變動。

## 核心功能／特色

- **單圖 → 3DGS**：輸出 32,768 到 1,048,576 個高斯（需為 32 的倍數，預設 262,144），數量決定細節程度，輸出為標準 `.ply`，可用任何高斯點雲檢視器開啟。
- **兩種前處理模式**：`synthetic`（預設，給電腦生成圖與渲染圖）與 `real`（給真實照片）。
- **內建去背與裁切**：用 BiRefNet 去背，另外輸出模型實際看到的圖（`<name>_input.png`）與預測的輸入視角相機（`<name>_camera.json`）。
- **顯存需求低**：完整請求峰值約 7.2 GB VRAM，權重約 3.7–4.4 GB。
- **可重現**：同一個 `--seed`（預設 42）會得到同一個物件。
- **加速取樣**：在 CUDA 上預設啟用（`torch.compile` 加批次推論，官方稱約 1.7 倍），同一程序裡第一張圖要編譯所以較慢；可用 `--no_optimize` 關閉。
- **Python API**：`IdolPipeline.from_pretrained("speridlabs/idol")`；影像編碼器可改指向本機資料夾，離線載入。
- **Gradio 示範**：repo 內 `demo/` 可本機執行，Hugging Face Space 上有 93 個現成範例，也能上傳自己的圖。

## 技術架構或運作原理

- 官方技術細節不多，專案頁沒有描述架構或訓練方式；以下來自 repo README。
- **生成部分**：370M 參數的 DiT 在 Euler 取樣器下取樣（50 步、classifier-free guidance 3.0、time shift 3.0），再由 octree 解碼器與 Gaussian 解碼器還原成 3D 高斯。
- **圖片條件**：DINOv3 ViT-H+ 與 FLUX.2 VAE；去背用 BiRefNet。
- **基準（官方自評）**：與 TripoSplat、TRELLIS、LGM 比較（每個模型 1 張 H100）。Idol 在輸入視角的 SSIM、LPIPS、IoU 與新視角的 DINOv2、CLIP、銳利度距離上最佳；LGM 的 PSNR 最高（12.46 對 12.25），也最快（1.1 秒對 6.8 秒），但 README 註明它的結果明顯模糊。這些是作者自己跑的數據，未經第三方驗證。
- 訓練資料與訓練程式碼：資料不足，repo 目前只有推論 SDK 與示範。

## 安裝與使用方式

需求：Python ≥ 3.10、PyTorch ≥ 2.5；NVIDIA GPU 最順（CUDA）。

1. 先在 Hugging Face 申請並同意兩個受限模型的條款：[facebook/dinov3-vith16plus-pretrain-lvd1689m](https://huggingface.co/facebook/dinov3-vith16plus-pretrain-lvd1689m) 與 [black-forest-labs/FLUX.2-dev](https://huggingface.co/black-forest-labs/FLUX.2-dev)（只會下載它的 VAE），然後執行 `hf auth login` 或設定 `HF_TOKEN`。
2. 安裝並執行：

```bash
git clone https://github.com/speridlabs/idol-sdk.git
cd idol-sdk
pip install -e .              # 要跑示範再加 ".[demo]"

# 照片用 real，渲染圖／生成圖用 synthetic
python -m idol.sample --image photo.jpg --mode real
python -m idol.sample --image renders/ --mode synthetic --out outputs
```

```python
from idol import IdolPipeline

pipeline = IdolPipeline.from_pretrained("speridlabs/idol")
output = pipeline("photo.jpg", mode="real", seed=42, num_gaussians=1_048_576)
output.gaussian.save_ply("photo.ply")
```

- 其他常用參數：`--steps`（預設 50）、`--cfg_strength`（3.0）、`--num_gaussians`、`--dinov3_dtype fp32`（編碼器改全精度，多用 1.7 GB）、`--device cuda|mps|cpu`。
- 有裝 `flash-attn` 會自動使用，否則改用 PyTorch 的 `scaled_dot_product_attention`（結果相同、較慢），可用 `ATTN_BACKEND` 指定。
- 不想本機安裝可先用 Hugging Face Space 試。

## 適用情境

- 從產品照、概念圖或文生圖的結果，快速產出可旋轉檢視的 3D 高斯物件。
- 為 3DGS 管線（檢視、編輯、渲染）準備單一物件素材，輸出可直接進 [SuperSplat](SuperSplat.md) 清理、壓縮與發布。
- 研究單圖 3DGS 生成，與 TripoSplat、TRELLIS、LGM 做比較。
- 顯存有限（約 8 GB）、想在本機跑單圖生成 3D 的使用者。

## 授權與成本

- **Idol 本身**：SDK 與 Hugging Face 權重皆標示 Apache-2.0。
- ⚠️ **相依模型的授權**：
  - DINOv3 為 Meta 的 DINOv3 License（需手動申請核准）。
  - FLUX.2-dev 在 Hugging Face 上標示為 `flux-non-commercial-license`；Idol 只下載它的 VAE，但商用前應確認該 VAE 是否受同一授權約束。
  - README 提到影像編碼器可替換：FLUX.2 VAE 可改用任何在 `vae/` 下有相同自編碼器的 FLUX.2 repo。例如 FLUX.2-klein-4B 在 Hugging Face 上標示 Apache-2.0，且不受限（gated 為 false），可作為替代，但是否與 Idol 權重完全相容、品質是否相同，官方未說明。
  - BiRefNet 的授權本次未查證，資料不足。
- **成本**：免費自行執行；Hugging Face Space 跑在 ZeroGPU 上，可線上試用（額度與是否免費以該頁為準）。

## 限制與注意事項

- 輸出是高斯點雲，**不是網格**：沒有 UV、貼圖與 PBR 材質，不能直接放進一般遊戲引擎的網格管線；需要網格請看 TRELLIS.2、Hunyuan3D 2.1、Stable Fast 3D。
- 單圖重建，看不到的背面由模型推測，可能失真；是否適合複雜或非物件類（人像、場景）的輸入，官方未說明。
- 速度與 GPU 關係大：262,144 個高斯、50 步時，RTX 5090 約 14 秒、RTX 4090 約 19 秒、RTX 3080 約 46 秒、L4 約 55 秒；官方稱的「2 秒內」未註明設定（見查證補充）。
- Apple Silicon（MPS）可跑但很慢：M4 MacBook Air 約 18 分鐘（預設 50 步、262,144 個高斯，需 24 GB 記憶體），加速取樣只支援 CUDA。
- 需先申請兩個受限模型的存取權，才能下載編碼器。
- 專案很新（2026-10-28 建立，版本 0.1.0），基準為官方自評。

## 相關工具

- [TripoSplat](https://github.com/VAST-AI-Research/TripoSplat)（Idol 的基礎）、[TRELLIS](https://github.com/microsoft/TRELLIS)、[LGM](https://github.com/3DTopia/LGM)（官方基準中的比較對象）、[DINOv3](https://github.com/facebookresearch/dinov3)、[BiRefNet](https://github.com/ZhengPeng7/BiRefNet)
- 同資料夾：[SuperSplat](SuperSplat.md)（編輯與發布高斯點雲）、TRELLIS.2、Hunyuan3D-2.1、Stable-Fast-3D（輸出網格的單圖生成 3D）、HY-World-2.0（也輸出 3DGS，但是整個場景）

## 資料來源

- https://huggingface.co/speridlabs/idol （模型卡與中繼資料：授權、讚數、下載數、是否 gated）
- https://speridlabs.com/research/idol （專案頁：參數量、基準、作者）
- https://github.com/speridlabs/idol-sdk （README、pyproject.toml：安裝、參數、元件參數量、各 GPU 速度）
- https://api.github.com/repos/speridlabs/idol-sdk （repo 中繼資料：授權、星數、建立與推送日期）
- https://huggingface.co/black-forest-labs/FLUX.2-dev 、https://huggingface.co/facebook/dinov3-vith16plus-pretrain-lvd1689m 、https://huggingface.co/black-forest-labs/FLUX.2-klein-4B （相依模型的授權標示）
- https://paperswithcode.co/tasks/3d-generation （3D 生成任務頁；查閱時 Idol 尚未列入，僅作為任務分類參考）
