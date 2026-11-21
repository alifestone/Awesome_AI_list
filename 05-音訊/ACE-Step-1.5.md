# ACE-Step 1.5

- **分類**：音訊 / 本機音樂生成模型（文字生成歌曲、翻唱、局部重繪、LoRA 微調）
- **連結**：https://github.com/ace-step/ACE-Step-1.5 （模型：https://huggingface.co/ACE-Step/Ace-Step1.5 ；專案頁：https://ace-step.github.io/ace-step-v1.5.github.io/ ；技術報告：https://arxiv.org/abs/2602.00744 ）

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：repo 標語為 *The most powerful local music generation model that outperforms almost all commercial alternatives, supporting Mac, AMD, Intel, and CUDA devices.* 由 ACE Studio 與 StepFun（階躍星辰）共同主導。查詢當下（2026-11-21）GitHub API 顯示約 15,000 顆星，repo 建立於 2025-09-04，最後 push 為 2026-11-08，最新 release 為 v0.1.8（2026-05-18）。程式碼與 Hugging Face 上的模型權重皆標示 MIT。

## 概述

ACE-Step 1.5 是開源的音樂生成基礎模型，主打在家用顯卡上做出接近商用水準的整首歌。官方數據：A100 上一首完整歌曲不到 2 秒、RTX 3090 不到 10 秒，最低不到 4 GB VRAM 就能跑；長度可從 10 秒到 10 分鐘，一次最多批次生成 8 首。

架構是「語言模型 + 擴散模型」的混合式設計：LM（以 Qwen3 0.6B／1.7B／4B 為底）當規劃者，把簡單的描述用 Chain-of-Thought 展開成完整的歌曲藍圖（後設資料、歌詞、風格描述），再交給 DiT（Diffusion Transformer）生成音訊。2026-04-02 加入 XL 系列（4B 參數 DiT），音質更好但需要更多 VRAM。

## 核心功能／特色

- **文字生成音樂**：簡單模式只要一句描述就能出整首歌；進階模式可給歌詞（支援 50+ 種語言）與風格標籤，LM 會自動改寫、擴充。
- **後設資料控制**：指定長度、BPM、調性／音階、拍號。
- **音訊編輯**：參考音訊引導風格、翻唱（cover）、局部重繪（repaint）、音軌分離、多軌疊加（類似 Suno Studio 的 Add Layer）、Vocal2BGM（替人聲自動配伴奏）。
- **音訊理解**：從音檔抽出 BPM、調性、拍號與描述；替生成的歌自動產生 LRC 歌詞時間軸；自動品質評分。
- **LoRA 微調**：Gradio 內一鍵標註與訓練，官方說 8 首歌、RTX 3090（12 GB）約 1 小時；進階訓練可用社群工具 Side-Step。
- **多種使用方式**：Gradio 網頁介面、REST API、Python API、互動式 CLI，另有獨立的 VST3 外掛（C++／GGML，可直接在 DAW 裡用）與 ComfyUI 支援。
- **模型選擇**：DiT 有 base／sft／turbo 三種（turbo 只要 8 步、品質最高；base 才支援 extract／lego／complete 等編輯任務），各有 2B 與 XL 4B 版本。

## 安裝與使用方式

需求：Python 3.11–3.12，建議 NVIDIA CUDA，也支援 Apple Silicon（MPS／MLX）、AMD ROCm、Intel XPU 與 CPU。

```bash
# 1. 安裝 uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# 2. 下載並安裝
git clone https://github.com/ACE-Step/ACE-Step-1.5.git
cd ACE-Step-1.5
uv sync

# 3. 啟動 Gradio 介面（第一次執行會自動下載模型）
uv run acestep          # http://localhost:7860

# 或啟動 REST API
uv run acestep-api      # http://localhost:8001
```

Windows 與 macOS 有預先裝好相依套件的免安裝包；各平台也有 `start_gradio_ui.*` 啟動腳本。設定（模型、連接埠、語言）建議寫在 `.env`，更新 repo 時不會被覆蓋。

依 VRAM 選模型（官方建議）：

| VRAM | DiT | LM |
|------|-----|----|
| ≤6 GB | 2B turbo | 不用 LM（INT8 量化 + CPU offload） |
| 6–8 GB | 2B turbo | 0.6B（PyTorch） |
| 8–16 GB | 2B turbo／sft | 0.6B 或 1.7B（vLLM） |
| 16–20 GB | 2B sft 或 XL turbo（需 offload） | 1.7B |
| ≥24 GB | XL sft | 4B |

介面會依顯卡自動挑選設定。

## 適用情境

- 在本機替影片、遊戲、Podcast 生成配樂或整首含人聲的歌，不想付 Suno 訂閱或把素材上傳雲端。
- 用自己的幾首作品訓練 LoRA，產生特定風格的音樂。
- 替人聲錄音自動配伴奏、翻唱既有歌曲、只重做歌曲中的某一段。
- 透過 REST API 或 Python API 接到自動化影片流程（例如短影音生成器）裡。
- 音樂人在 DAW 裡用 VST3 外掛直接生成素材。

## 授權與成本

- **授權**：程式碼與模型權重皆為 MIT，可商用。
- **成本**：本機執行免費。官方另有免費的線上版 acemusic.ai（不需 GPU）。

## 限制與注意事項

- 「品質介於 Suno v4.5 與 v5 之間」、「勝過多數商用模型」是官方自評，以自家選定的指標計算。
- XL 模型權重約 9 GB，至少 12 GB VRAM（搭配 offload 與量化），20 GB 以上才不必 offload。
- 免責聲明提醒：生成內容可能因風格相近而無意間侵權，應自行確認原創性、標示 AI 參與，改編受保護的風格或素材前先取得授權。
- README 說唯一官方網站是 GitHub Pages，並點名多個仿冒網域（ac\*\*p.com 等），不要在那些網站付款；但 README 同時也推廣 acemusic.ai，使用前請從 README 內的連結進入。
- Windows 上用 ROCm 只能用 Python 3.12。

## 相關工具

- [VoiceStudio](VoiceStudio.md)：本機語音合成與聲音複製，可和 ACE-Step 搭配做有旁白、有配樂的內容
- [earshot](earshot.md)：讓 coding agent 聽、檢查生成音樂的響度與聲畫同步
- [Basic Pitch](Basic-Pitch.md)：把生成的旋律轉成 MIDI 再編輯
- [WanGP](../03-影片製作/WanGP.md)：本機影片生成，可搭配 ACE-Step 配樂

## 資料來源

- https://github.com/ace-step/ACE-Step-1.5 （README）
- https://api.github.com/repos/ace-step/ACE-Step-1.5 （星數、MIT、建立時間、最後 push）
- https://github.com/ace-step/ACE-Step-1.5/releases/latest （v0.1.8，2026-05-18）
- https://huggingface.co/ACE-Step/Ace-Step1.5 （模型授權 MIT）
- https://arxiv.org/abs/2602.00744 （技術報告）
