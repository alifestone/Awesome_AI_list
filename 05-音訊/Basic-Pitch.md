# Basic Pitch

- **分類**：音訊
- **連結**：https://github.com/spotify/basic-pitch

## 原清單說明

（Spotify）— 音訊轉 MIDI 的輕量模型。

> 查證結果：與原說明相符。Basic Pitch 由 Spotify 的 Audio Intelligence Lab 開發，是一個以輕量神經網路做自動音樂轉譜（Automatic Music Transcription, AMT）、把音訊轉成 MIDI 的 Python 函式庫；論文中模型參數量僅約 16,782 個。

## 概述

Basic Pitch 是 Spotify 開源的音訊轉 MIDI 工具。輸入一段音訊檔，即可輸出含**滑音（pitch bend）**資訊的 MIDI 檔。它「不限樂器」（instrument-agnostic），支援複音（polyphonic）樂器，也能處理人聲；官方 README 註明**一次處理單一樂器時效果最好**。

此函式庫與 Spotify 在 ICASSP 2022 發表的論文〈A Lightweight Instrument-Agnostic Model for Polyphonic Note Transcription and Multipitch Estimation〉（Bittner 等，arXiv:2203.09893）一同釋出。除了 Python 版（PyPI：`basic-pitch`，查證時最新版本為 0.4.0），另有 TypeScript 版本 `basic-pitch-ts`（npm 套件 `@spotify/basic-pitch`），以及官方網頁版 Demo。

## 核心功能／特色

- **音訊 → MIDI**：產生可直接匯入 DAW 編輯的 MIDI，包含 pitch bend。
- **不限樂器、支援複音**：同一個模型可處理鋼琴、吉他、合成器、管弦樂組及人聲等，不需針對樂器重新訓練。
- **同時輸出音符與多音高（multipitch）估計**：除音符事件外，也提供逐幀的音高後驗機率。
- **輕量、資源需求低**：論文中參數量約 16.8K；在 7 分 45 秒的長音檔測試中，峰值記憶體約 951 MB、耗時 24 秒，對照基線模型 MI-AMT（約 2,000 萬參數）需 3.3 GB、96 秒（2017 MacBook Pro 測得）。
- **多種推論執行環境**：內含原始 TensorFlow 模型，以及轉換後的 CoreML、TensorFlow Lite、ONNX 版本。
- **多種輸出格式**：MIDI；可選擇另存 MIDI 合成後的 WAV、原始模型輸出（NPZ）、音符事件（CSV）。
- **支援常見音訊格式**：凡其所用 librosa 版本支援者皆可，包括 `.mp3`、`.ogg`、`.wav`、`.flac`、`.m4a`。

## 技術架構或運作原理

依論文（模型稱為 NMP, Notes and Multipitch）：

1. **輸入表示**：先對音訊計算 CQT（每半音 3 個 bin、hop 約 11 ms），再做 **Harmonic Stacking**（將 CQT 依各諧波頻率位移後堆疊，取 7 個諧波與 1 個次諧波，近似 Harmonic CQT），讓小型卷積核就能捕捉諧波關係。
2. **全卷積網路**，輸出三個時頻後驗圖：
   - `Yp`：逐幀多音高（每半音 3 bin，保留顫音等細節）
   - `Yn`：音符啟動狀態（每半音 1 bin，「音樂化量化」後的結果）
   - `Yo`：音符起始（onset）
   `Yp` 經兩層卷積推得 `Yn`，`Yo` 則結合 `Yn` 與音訊卷積特徵估計。
3. **訓練**：三個輸出皆用二元交叉熵，onset 採類別加權（負類 0.05／正類 0.95）處理類別不平衡；輸入為 22,050 Hz 的 2 秒音訊，batch size 16、Adam、學習率 0.001，並做加噪、等化、殘響等資料增強。訓練資料包括 GuitarSet、MAESTRO、Slakh、iKala、MedleyDB 等公開資料集。
4. **後處理**：從 `Yo` 挑峰值作為音符起點，沿 `Yn` 向前追蹤直到機率低於門檻，產生音符事件；短於約 120 ms 的音符會被移除。
5. **推論時**：立體聲會被混成單聲道，任何取樣率皆會重取樣至 22,050 Hz。

> 注意：README 表示目前程式碼相較論文版本已有改進，研究引用時應註明所用的程式碼版本。

## 安裝與使用方式

**系統需求**：Python 3.7–3.11；支援 macOS、Windows、Ubuntu。Apple M1 硬體目前僅支援 Python 3.10（否則建議用虛擬機）。

```bash
# 安裝
pip install basic-pitch
# 更新
pip install --upgrade basic-pitch
# 一併安裝 TensorFlow（官方建議盡量使用 TF 版模型）
pip install basic-pitch[tf]
```

預設不安裝 TensorFlow（Python ≥ 3.11 除外）；macOS 預設裝 CoreML、Linux 裝 TensorFlow Lite、Windows 裝 ONNX。載入模型的優先順序為 TensorFlow → CoreML → TensorFlowLite → ONNX。

**命令列**

```bash
basic-pitch <output-directory> <input-audio-path>
# 一次處理多個檔案
basic-pitch <output-directory> <audio-1> <audio-2> <audio-3>
# 選用旗標
#   --sonify-midi          另存 MIDI 的 WAV 渲染
#   --save-model-outputs   另存原始模型輸出（NPZ）
#   --save-note-events     另存音符事件（CSV）
#   --model-serialization  指定非預設的模型格式（如 CoreML）
basic-pitch --help
```

**Python API**

```python
from basic_pitch.inference import predict
from basic_pitch import ICASSP_2022_MODEL_PATH

model_output, midi_data, note_events = predict("input.wav")
```

- `predict()` 可設定最小／最大頻率（Hz）過濾音符。
- 迴圈中重複推論時，先用 `Model(ICASSP_2022_MODEL_PATH)` 載入模型再傳入 `predict()`，避免重複載入。
- `predict_and_save()` 可批次處理並控制要輸出 MIDI、WAV、NPZ、CSV 哪些格式。

**其他使用管道**

- 網頁版：basicpitch.io（目前轉址至 basicpitch.spotify.com），可在瀏覽器錄音或上傳檔案，下載 MIDI。
- JavaScript／TypeScript：`yarn add @spotify/basic-pitch`（basic-pitch-ts）。

## 適用情境

- 把單一樂器演奏或人聲哼唱轉成 MIDI，再到 DAW 中編輯、換音色或製譜。
- 作曲／編曲時快速擷取旋律與和聲素材。
- 音樂資訊檢索（MIR）研究中，作為輕量、不限樂器的轉譜或多音高估計基線。
- 需要在低資源裝置、瀏覽器端或行動端部署轉譜功能的應用。

## 授權與成本

- **授權**：Apache License 2.0，Copyright 2022 Spotify AB（README 授權段落文字中另提及「GPL License」字樣，但未說明任何 GPL 適用範圍，主要授權條款為 Apache 2.0）。
- **成本**：開源免費；網頁版 Demo 標示為免費工具。
- basic-pitch-ts 同為 Apache 2.0。

## 限制與注意事項

- 官方明言**一次處理單一樂器效果最佳**；完整混音（多樂器同時演奏）的轉譜品質未保證，論文也將多樂器混音列為未來工作。
- 論文中與專用模型比較：吉他（GuitarSet 獨奏）優於 TENT，但在鋼琴（MAESTRO）上明顯不如 Onsets and Frames（Fno 70.9% vs 95.2%），人聲上 Fno 亦低於 Vocano。
- 僅分析單聲道；立體聲會被降混。
- 長音檔受限於本機磁碟／記憶體，官方建議以串流方式分段處理。
- 不同 OS 預設推論後端不同（CoreML／TFLite／ONNX 皆由 TF 轉換而來），官方建議盡量使用 TensorFlow 版本。
- Apple M1 僅支援 Python 3.10。
- 網頁版是否完全在瀏覽器本機處理、檔案大小上限與隱私政策：資料不足（頁面未說明）。

## 相關工具

- **basic-pitch-ts**（Spotify）：TypeScript／npm 版本。
- **NeuralNote**（DamRsn）：Basic Pitch README 推薦的 VST 外掛版本（VST3／AU／獨立程式）。注意：NeuralNote 2.0.0 已改用 Kyutai 與 Mirelo 的 MuScriptor transformer 模型取代 Basic Pitch，該模型權重為 CC BY-NC 4.0（僅限非商業用途）。
- 論文中提及的比較對象：Onsets and Frames（鋼琴轉譜）、Vocano（人聲轉譜）、TENT（吉他獨奏轉譜）、MI-AMT（多樂器轉譜基線）、Deep Salience（多音高估計）。

## 資料來源

- https://github.com/spotify/basic-pitch
- https://raw.githubusercontent.com/spotify/basic-pitch/main/README.md
- https://pypi.org/pypi/basic-pitch/json
- https://arxiv.org/abs/2203.09893
- https://arxiv.org/pdf/2203.09893
- https://basicpitch.spotify.com/ （basicpitch.io 轉址目標）
- https://github.com/spotify/basic-pitch-ts
- https://github.com/DamRsn/NeuralNote
