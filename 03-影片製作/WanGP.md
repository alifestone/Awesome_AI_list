# WanGP

- **分類**：影片製作 / AI 影片生成
- **連結**：https://github.com/deepbeepmeep/WanGP
- **官網**：https://wangp.ai/

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：repo 標語為 *A fast AI Video Generator for the GPU Poor.* 舊名 Wan2GP（安裝指令仍用 `Wan2GP` 網址），起初只跑 Wan 影片模型，現在已擴充成影片、圖像、音訊／TTS 與 3D 的整合 App。授權不是 OSI 開源授權，而是自訂的 WanGP Community License 2.0。

## 概述

WanGP 是本機執行的生成式 AI 整合 App，主打讓顯卡不夠好的使用者（「GPU Poor」）也能跑最新的開源模型：部分模型只要 6 GB VRAM，GTX 10 系列以上的 NVIDIA 卡和 AMD RDNA 2–4 都支援。以瀏覽器（Gradio）介面操作，也有命令列、Python API 與 MCP server。

repo 於 2025-02-27 建立，查詢當下（2026-10-19）約 10,651 顆星，最近一次推送為 2026-10-17。作者為 DeepBeepMeep。更新非常頻繁，README 的版本號在 2026-10 一個月內就從 v13 跳到 v18.17。

## 核心功能／特色

- **支援的模型**（依 README）：
  - 影片：Wan 2.1／2.2 與衍生模型、MiniMax H3、LTX-2／2.3／2.5、Hunyuan Video 1／1.5、LongCat、Kandinsky、LTXV、MagiHuman。
  - 圖像：Krea 2、Qwen Image（含 2.1）、Z-Image、Flux 1／2（Klein、Chroma）、FLUX 3 Klein、SenseNova、Ideogram 4、HiDream、MOSS Image。
  - 音訊／TTS：Qwen3 TTS、MiniMax H3 Voice Clone、Ace Step、Index TTS2／2.5、Chatterbox、Fish Audio Drama 3、Stable Audio 3 等。
  - 3D（v18.00 起）：Hunyuan3D 2.1、TRELLIS.2、TripoSG、TripoSplat、PartCrafter，以及從照片或影片重建 3D 場景的 WorldMirror 2.0、MapAnything 等。
- **省 VRAM**：自家的 MMGP 記憶體管理（記憶體設定檔、分配器、動態預載），README 稱 v17.17 起 15 秒 1080p 的 H3 影片從 25 GB 降到 11 GB VRAM。支援 int8、fp8、GGUF、NV FP4、Nunchaku 等量化格式，並依硬體自動下載合適的模型檔。
- **創作工具**：遮罩編輯、去背、姿態／深度／光流擷取、說話者分離；RIFE、FlashVSR 插幀與超解析；MMAudio 配樂、SeedVC 換聲；LoRA、自訂 finetune、生成佇列與作品庫。
- **Deepy 助理**：內建的低 VRAM 離線 agent，可代為排程生成與處理雜務（轉錄、切片等）。v18.17 的 Deepy Prime 可從一分鐘的 brief 規劃分鏡、維持角色一致、配上音樂或旁白，並在交付前檢查黑幀、跳切、靜音段與畫面文字錯字。
- **給外部 agent 用**：`python wgp.py --mcp` 啟動 MCP server，repo 另附 `wangp-agent` skill，教 agent 查模型能力、組設定、送出生成並取回檔案路徑。Deepy 與提示詞強化也能改接 Codex、Claude Code、OpenCode 等遠端 LLM。

## 安裝與使用方式

最簡單是用一鍵腳本，會一併安裝適合你顯卡的加速套件（Triton、Sage、Flash Attention 等）：

```bash
# Windows：雙擊 scripts\install.bat、scripts\run.bat、scripts\update.bat
# Linux／macOS：
scripts/install.sh
scripts/run.sh
```

手動安裝（RTX 20–50 系列）：

```bash
git clone https://github.com/deepbeepmeep/Wan2GP.git
cd Wan2GP
conda create -n wan2gp python=3.11.14
conda activate wan2gp
pip install torch==2.10.0 torchvision==0.25.0 torchaudio==2.10.0 --index-url https://download.pytorch.org/whl/cu130
pip install -r requirements.txt
python wgp.py
```

- GTX 10 系列要改用 Python 3.10.9 + PyTorch 2.7.1；Windows 另需依顯卡安裝對應版本的 `triton-windows`。AMD 見 `docs/AMD-INSTALLATION.md`。
- 也可用 Pinokio（README 建議用社群腳本 *wan2gp*／*wan2gp-amd*）、第三方桌面啟動器 Wan2GP Desktop，或 Debian 系統的 `./run-docker-cuda-deb.sh`。
- 第一次使用可看介面裡的 *Guides* 分頁，有推薦模型。VRAM 吃緊時，README 建議關掉瀏覽器的 GPU 加速（可多出 1–5 GB）。

## 適用情境

- 用 8–16 GB 顯卡的家用電腦在本機跑 Wan、LTX、Hunyuan Video 等開源影片模型。
- 在同一個介面裡做圖生影片、首尾幀、角色替換、配音與配樂，不用自己串 ComfyUI 節點。
- 讓 Claude Code 等 coding agent 透過 MCP 呼叫本機的影片、圖像、語音模型。

## 授權與成本

- **授權**：WanGP Community License 2.0（自訂授權，GitHub 顯示為 Other）。依授權檔的白話摘要：可免費使用（含公司內部）、可修改自用，生成的作品可以販售或授權（直接販售時需註明 WanGP）；**不可**販售 WanGP 本身、換牌、嵌入付費產品，或提供付費 API／SaaS／代管服務，除非另取得商業授權。
- 各模型、權重與第三方程式碼各自適用原授權，要另外確認（例如部分圖像模型為非商用）。
- **成本**：本機使用免費；README 強調官方不會收授權費、訂閱費或要求捐款，並提醒只認官方 repo 與 wangp.ai／wan2gp.ai，其他用 WanGP 名稱的服務都與官方無關。

## 限制與注意事項

- 需要 NVIDIA 或 AMD 顯卡；README 沒有提到 Apple Silicon 的 GPU 加速。
- 加速套件（Triton、SageAttention）的版本要和顯卡、PyTorch 對上，裝錯可能當掉；RTX 20 系列有額外限制。
- 更新節奏很快，設定與功能常改名或調整；升級 Python／PyTorch 大版本前，README 建議先把舊的 conda 環境改名備份。
- 省 VRAM 的效果與速度依硬體而異（PCIe、SSD、CPU 都有影響），README 的數字為作者自測。
- 模型檔通常很大，需要大量磁碟空間與下載時間。

## 相關工具

- [Index-AniSora](../10-模型/Index-AniSora.md)：開源動漫影片生成模型
- [FLUX 3 Image Klein](../10-模型/FLUX-3-Image-Klein.md)、[Qwen-Image-2.1](../10-模型/Qwen-Image-2.1.md)：WanGP 支援的圖像模型
- [Hunyuan3D 2.1](../02-3D-建模與生成/Hunyuan3D-2.1.md)、[TRELLIS.2](../02-3D-建模與生成/TRELLIS.2.md)：WanGP 內建的 3D 生成模型
- [OpenMontage](OpenMontage.md)：可接本地 ComfyUI 的影片製作 agent 系統

## 資料來源

- https://github.com/deepbeepmeep/WanGP （README、`LICENSE.txt`、`docs/MODELS.md`、`wangp-agent/SKILL.md`）
- https://api.github.com/repos/deepbeepmeep/WanGP （星數、建立與推送時間）
