# Stable Fast 3D（SF3D）

- **分類**：3D 建模與生成 / AI 生成 3D 資產
- **連結**：https://github.com/Stability-AI/stable-fast-3d （模型：https://huggingface.co/stabilityai/stable-fast-3d ；線上試用：https://huggingface.co/spaces/stabilityai/stable-fast-3d ；專案頁：https://stable-fast-3d.github.io ）

## 原清單說明

單張照片 → 乾淨、已展 UV 的網格，速度很快。（來源：Threads @davepoon128 貼文）

> **查證補充**：正確。論文摘要寫「從單張圖片在 0.5 秒內重建高品質貼圖網格」，並明確針對網格生成訓練、內建快速 UV 展開（產生貼圖而非頂點色），還會預測材質參數與法線貼圖、去除圖片中的低頻光照（delighting）。補充兩點：0.5 秒是論文數據，實際速度依硬體而定；以及 ⚠️ 授權是 Stability AI Community License，年營收超過 100 萬美元的組織需另購企業授權。

## 概述

Stable Fast 3D 是 Stability AI 的單張圖片前饋式（feedforward）3D 網格重建模型，以 [TripoSR](https://github.com/VAST-AI-Research/TripoSR) 為基礎，加入多項新技術：明確最佳化網格品質以減少瑕疵、UV 展開的貼圖、去光照的顏色與材質參數預測，讓產出的資產可以直接放進遊戲，同時保持 TripoSR 的快速推論。論文為〈SF3D: Stable Fast 3D Mesh Reconstruction with UV-unwrapping and Illumination Disentanglement〉（arXiv 2408.00653，作者 Mark Boss 等）。

截至 2026-10-18：GitHub 授權欄顯示 NOASSERTION（實為 Stability AI Community License）、約 1.9k 顆星、主要語言 Python；repo 建立於 2024-07-17，最後推送為 2025-01-22。

## 核心功能／特色

- **快速單圖重建**：論文稱 0.5 秒；預設設定單張圖片約需 **6GB 顯存**。
- **UV 展開＋貼圖烘焙**：repo 內有 `uv_unwrapper/`、`texture_baker/` 自訂擴充（CUDA，Mac 上有 Metal kernel）。
- **材質與法線**：預測材質參數（粗糙度、金屬度）與法線貼圖。
- **去光照（delighting）**：移除輸入照片的低頻光照，方便在新光源下使用。
- **重新網格化選項**：`none`（不處理）、`triangle`（Botsch–Kobbelt 三角形重網格）、`quad`（Instant Meshes 四邊形流，匯出時拆成三角形），可指定大約的目標頂點數。
- **輸出 GLB**，可用 `--texture-resolution` 設定貼圖解析度。
- **ComfyUI 自訂節點**與範例工作流程。
- **多平台**：CUDA、Apple Silicon MPS（實驗性）、CPU、Windows（實驗性）。

## 技術架構或運作原理

- 基於 TripoSR 的大型重建模型（LRM）架構，從單張圖片前饋推論出 3D 表示，再萃取網格。
- 與 TripoSR 不同處：針對網格輸出最佳化以減少等值面萃取的瑕疵；快速 UV 展開讓貼圖取代頂點色；額外輸出材質參數與法線貼圖；加入去光照步驟。
- 訓練資料：Hugging Face 模型卡列出 `allenai/objaverse`。
- 模型參數量等細節，本次未從官方來源確認，資料不足。

## 安裝與使用方式

需求：Python ≥ 3.8；依平台安裝 PyTorch；建議 `pip install -U setuptools==69.5.1` 與 `pip install wheel`。

1. 模型在 Hugging Face 上**需申請存取（gated）**：登入 HF 並在模型頁同意授權、建立讀取權杖，再執行 `huggingface-cli login`（新版為 `hf auth login`）。
2. 安裝並執行：

```bash
git clone https://github.com/Stability-AI/stable-fast-3d.git
cd stable-fast-3d
pip install -r requirements.txt

# 單張或多張圖片 → GLB
python run.py demo_files/examples/chair1.png --output-dir output/

# 本機 Gradio 介面
pip install -r requirements-demo.txt
python gradio_app.py
```

- 強制使用 CPU：設定 `SF3D_USE_CPU=1`。Mac MPS 需 `PYTORCH_ENABLE_MPS_FALLBACK=1` 並安裝 OpenMP 執行環境；統一記憶體不足 32GB 時建議改用 CPU。
- ComfyUI：把 repo clone 到 `ComfyUI/custom_nodes` 並安裝 requirements 後重啟。

## 適用情境

- 從產品照或概念圖快速產出可放進遊戲引擎的低成本道具資產。
- 需要大量、快速生成 3D 預覽或草模的流程（例如電商 3D 預覽、原型設計）。
- 顯存有限（約 6GB）或想在 Mac／CPU 上跑的使用者。
- 在 ComfyUI 中串接圖片生成與 3D 重建。

## 授權與成本

- ⚠️ **授權：Stability AI Community License Agreement**（2024-07-05 版，非 OSI 開源授權），重點：
  - 研究與非商業用途免費。
  - **商業用途**：免授權金，但須到 https://stability.ai/community-license 註冊；若你（含關係企業）**年營收超過 100 萬美元**，授權即終止，須向 Stability AI 申請企業授權。
  - 散布時須附授權副本、在 Notice 檔保留指定聲明，並明顯標示「Powered by Stability AI」。
  - 禁止用模型或其輸出建立或改進其他基礎生成式 AI 模型。
  - 需遵守 Stability AI 的可接受使用政策（AUP）。
- **成本**：開源權重免費自行執行。Stability AI 平台 API 是否提供 SF3D 及其價格，本次未查證，資料不足。

## 限制與注意事項

- 模型權重需在 Hugging Face 申請存取並同意授權。
- 屬於較早期（2024 年）的模型，repo 自 2025-01 後未再更新；幾何細節與貼圖品質通常不如 TRELLIS.2、Hunyuan3D 2.1 等較新的大型模型（官方未提供與這些模型的直接比較，此為一般觀察）。
- 單張圖片重建，看不到的背面由模型推測，可能失真。
- Windows 與 MPS 支援為實驗性；MPS 比 CUDA 耗記憶體。
- `triangle`／`quad` 重網格化會增加 CPU 負擔。

## 相關工具

- [TripoSR](https://github.com/VAST-AI-Research/TripoSR)（SF3D 的基礎）、[ComfyUI](https://github.com/comfyanonymous/ComfyUI)、[Instant Meshes](https://github.com/wjakob/instant-meshes)
- 同資料夾：TRELLIS.2、Hunyuan3D-2.1（品質更高但需大顯存）、Meshy MCP Server、Hyper3D（Rodin）

## 資料來源

- https://github.com/Stability-AI/stable-fast-3d （README）
- https://api.github.com/repos/Stability-AI/stable-fast-3d （repo 中繼資料）
- https://raw.githubusercontent.com/Stability-AI/stable-fast-3d/main/LICENSE.md （授權全文）
- https://raw.githubusercontent.com/Stability-AI/stable-fast-3d/main/requirements.txt
- https://huggingface.co/stabilityai/stable-fast-3d （模型卡中繼資料、gated 設定）
- https://arxiv.org/abs/2408.00653 （論文摘要）
- https://www.threads.com/@davepoon128/post/DenVxBCkyaN （原始貼文）
