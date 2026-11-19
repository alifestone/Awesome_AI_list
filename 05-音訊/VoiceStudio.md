# VoiceStudio

- **分類**：音訊 / 本機語音工作室（語音合成、聲音複製、配音、聽寫）
- **連結**：https://github.com/debpalash/VoiceStudio （官網：https://voicestudio.sh ）

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：repo 標語為 *the open-source, fully-local ElevenLabs alternative — voice cloning, voice design, video dubbing, dictation, transcription & audiobook creation in 646 languages.* 作者是 Palash Debnath（debpalash）。專案原名 OmniVoice Studio（舊網址 `debpalash/OmniVoice-Studio` 會轉到現在的 repo，環境變數與 Docker Hub 映像仍用 `omnivoice` 名稱）。查詢當下（2026-11-20）GitHub API 顯示約 114,000 顆星，repo 建立於 2026-04-09，最後 push 為 2026-11-18，最新 release 為 v0.5.8（2026-11-12）。授權為 AGPL-3.0。

## 概述

VoiceStudio 是一套在自己電腦上跑的語音工作室，定位為 ElevenLabs 的開源、全本機替代品。打開 app 就能做聲音複製、用文字描述設計新聲音、影片翻譯配音、聽寫、轉錄、有聲書旁白，不需帳號，模型只在你同意後才下載，下載完可離線使用。

預設語音引擎是 k2-fsa 的 **OmniVoice**（官方標示支援 646 種語言），也可以在 Model Manager 裡改用其他數十種開源引擎（CosyVoice 3、IndexTTS 2.5、VoxCPM2、GPT-SoVITS、MOSS-TTS 等），只下載自己需要的模型。轉錄預設用 WhisperX。

## 核心功能／特色

- **聲音複製**：給一段乾淨的參考錄音，就能用那個聲音念任何文字。
- **聲音設計**：用文字描述（性別、年齡、音高、風格、口音）生成新聲音。
- **影片配音**：翻譯影片並配上與原片時間對齊的語音，支援多講者配音與匯出。
- **聽寫與轉錄**：浮動聽寫小工具（sherpa-onnx 即時辨識）與本機轉錄；另有人聲分離、講者分離。
- **旁白與批次**：故事、有聲書與佇列批次工作。
- **串接與自動化**：本機 API、CLI、MCP server、可重用的 recipe 與監看資料夾；生成的音訊可加 AI 浮水印。
- **多引擎**：語音合成有 OmniVoice、CosyVoice 3（含 GGUF）、IndexTTS 2.5、VoxCPM2、MOSS-TTS-v1.5、dots.tts、KittenTTS、MLX-Audio、GPT-SoVITS、sherpa-onnx 等；轉錄有 WhisperX、Faster-Whisper、MLX Whisper、Parakeet、Moonshine、FunASR，也可接 OpenAI 相容伺服器。
- **MCP server**：掛在執行中的後端 `/mcp`，提供 `generate_speech`、`clone_voice`、`design_voice`、`transcribe`、`list_voices` 等工具，可替每個 agent 綁定不同聲音；檔案讀寫限制在 `OMNIVOICE_MCP_BASE_PATH` 指定的資料夾內。
- **Agent skill**：`npx skills add debpalash/VoiceStudio`（`voicestudio` 用於音訊工作）。

## 安裝與使用方式

支援 macOS（Apple Silicon，Metal）、Windows x64（NVIDIA CUDA、AMD ROCm 實驗性、CPU）、Linux x64（CUDA、CPU；GGUF 引擎可用 Vulkan）、Docker、Android 10+ 與 iOS 17+（預覽版，裝置上離線執行）。沒有 GPU 也能用 CPU 跑，只是比較慢。

```bash
# macOS / Linux 一行安裝
curl -fsSL https://voicestudio.sh/install | sh

# Arch Linux（AUR）
yay -S voicestudio-bin

# macOS Homebrew
brew tap debpalash/tap
brew install --cask debpalash/tap/voicestudio

# 從原始碼執行（需要 bun）
git clone https://github.com/debpalash/VoiceStudio.git
cd VoiceStudio
bun run dev
```

```powershell
# Windows
irm https://voicestudio.sh/install.ps1 | iex
```

Docker（CPU，網頁介面開在 http://localhost:3900 ）：

```sh
export OMNIVOICE_API_KEY="$(openssl rand -hex 32)"
docker run -d --name omnivoice -p 127.0.0.1:3900:3900 \
  -e OMNIVOICE_API_KEY -e OMNIVOICE_DATA_DIR=/app/omnivoice_data \
  -v omnivoice-data:/app/omnivoice_data \
  ghcr.io/debpalash/voicestudio:stable
```

安裝後打開 **Voice cloning**，選一個聲音或加入參考錄音，輸入文字就能生成。預設 OmniVoice 模型約 2.3 GB，第一次生成前要先下載。

## 適用情境

- 不想把聲音上傳到雲端，在本機做旁白、有聲書、Podcast 配音。
- 把影片翻成其他語言並自動配音。
- 讓 Claude Code 等 agent 透過 MCP 用指定的聲音說話或轉錄音檔。
- 比較多種開源 TTS／ASR 引擎，不用分別架設環境。

## 授權與成本

- **授權**：app 為 AGPL-3.0，可依其條款商用。模型權重、聲音與生成內容各有自己的授權，Model Manager 會逐一顯示。
- **成本**：免費、在自己的硬體上執行，不需帳號。另有付費的 VoiceStudio Pro（閉源版本，附商業授權、最多 3 台裝置、可把工作送到其他 GPU）與尚未開放的 VoiceStudio Cloud（託管 API）。

## 限制與注意事項

- 聲音複製只能用在取得本人同意的聲音上；README 明文禁止未經授權的複製、冒充與詐騙。
- 各引擎的模型授權不同，商用前要逐一確認，不能只看 app 的 AGPL。
- Intel Mac 只能跑介面、要連到另一台電腦的後端；Windows on ARM 的後端以模擬方式跑在 CPU 上；AMD ROCm 只支援部分 RX 6000 顯卡，屬實驗性；手機版仍是預覽版。
- 0.5.3 以前是 Tauri 版，升級到現在的 Electron 版要另外安裝。
- 星數極高、更新非常頻繁（CHANGELOG 數千行），功能與預設值變動快。

## 相關工具

- [earshot](earshot.md)：給 coding agent 的聽覺與音效工具，可檢查生成語音的響度與聲畫同步
- [Pipecat](../06-Agent-框架與編排/Pipecat.md)：即時語音對話 agent 框架
- [MoneyPrinterTurbo](../03-影片製作/MoneyPrinterTurbo.md)：自動產生含配音的短影片

## 資料來源

- https://github.com/debpalash/VoiceStudio （README）
- https://api.github.com/repos/debpalash/VoiceStudio （星數、AGPL-3.0、建立時間、最後 push）
- https://github.com/debpalash/VoiceStudio/releases/latest （v0.5.8，2026-11-12）
- https://github.com/debpalash/VoiceStudio/blob/main/docs/feature-catalog.md （功能與引擎清單）
- https://github.com/debpalash/VoiceStudio/blob/main/docs/mcp.md （MCP 工具）
