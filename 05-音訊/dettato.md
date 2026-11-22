# dettato

- **分類**：音訊 / 多樂器音訊轉 MIDI（自動採譜：音符、分軌、鼓組）
- **連結**：https://github.com/kobimusic/dettato （模型：https://huggingface.co/collections/kobimusic/dettato ；研究文章：https://kobi.music/research/dettato ；中文介紹：https://blog.derekhsu.net/2026/11/21/dettato-open-audio-to-midi-model/ ）

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：repo 描述為 *KobiMusic's multi-instrument audio-to-MIDI transcriber: notes, instrument tracks and drums from any recording.* 作者是 KobiMusic 的 Nathan Mills（個人開發者），研究文章發表於 2026-11-16。查詢當下（2026-11-22）GitHub API 顯示約 220 顆星，repo 建立於 2026-11-16，最後 push 為 2026-11-20，尚無 release。程式碼與 Hugging Face 上的模型權重皆標示 Apache-2.0。

## 概述

dettato 把一段錄音轉成 MIDI 檔：每種樂器一軌，外加一條鼓軌。和 [Basic Pitch](Basic-Pitch.md) 這類「一次處理一種樂器」的轉譜模型不同，它直接吃整首混音，自動分出樂器並加上鼓組。

它由四個小模型串成，總共 28.1M 參數：

| 階段 | 模型 | 參數 | 工作 |
|---|---|---|---|
| 1 | `kobimusic/dettato` | 15.3M | 轉譜器：抓出 88 鍵上的音符起點、結束與音高，每個鍵最多兩個聲部 |
| 2 | `kobimusic/dettato-evidence` | 4.9M | 修正器：用轉譜器的證據刪掉錯音、修正起訖、補上漏掉的音 |
| 3 | `kobimusic/dettato-grouper` | 2.9M | 分軌器：把每個音分進樂器軌並命名樂器 |
| 4 | `kobimusic/dettato-drums` | 5.0M | 鼓組：輸出 General MIDI 鼓音，分一般鼓組與管弦打擊樂兩個模型，自動選用 |

轉譜器是「音高通道（pitch lane）」網路，在諧波對數頻譜上逐鍵做局部判斷。作者表示前一版在 2026 年 4 月整個推翻，之後認為瓶頸在架構而不是資料，大型 LLM 式架構容易在合成資料上過擬合。

## 核心功能／特色

- **多樂器分軌**：一首混音直接輸出多軌 MIDI，每軌標上 General MIDI 樂器編號。
- **鼓組轉譜**：鼓組與管弦打擊樂由獨立模型處理。
- **很小**：作者測試的部分（轉譜器 + 鼓組）是 20.3M 參數，約為 MuScriptor 1.3B 的 1/65。8 GB 的 RTX 5060 上，4 分鐘的歌約 15 秒，GPU 記憶體峰值不到 4 GB。
- **自動調律偵測**：先估計錄音的 A4 基準音，明顯偏離 A440 時會先校正再轉。
- **不用版權錄音訓練**：訓練資料是合成樂器錄音、URMP 的 CC 授權獨奏，加上作者用「soundfont babies」技術混合約 20 個 soundfont 產生的音色；也沒有用任何評測集的錄音訓練。
- **可分開用**：四個階段可以各自呼叫（`dettato.transcriber`、`dettato.evidence`、`dettato.grouper`、`dettato.drums`）。

## 評測數據（作者自評）

評測用九個公開資料集：MuScriptor 論文 Table 2 的八個（Bach10、Dagstuhl ChoirSet、PHENICX-Anechoic、RWC Popular／Classical／Genre／Jazz／Royalty-Free），加上 Slakh2100 測試集。綜合分數是 onset、frame、offset 與鼓組 F1 四項的平均。

| 系統 | 參數 | 綜合 | Onset | Frame | Offset | 鼓組 |
|---|---|---|---|---|---|---|
| dettato（轉譜器 + 鼓組） | 20.3M | **59.2** | 67.2 | 77.9 | 44.8 | 47.1 |
| MuScriptor | 1.3B | 45.1 | 48.6 | 70.2 | 27.8 | 34.0 |

只看閉源模型 Mirelo A2M v1.1 Pro 有公布的三個資料集（PHENICX-Anechoic、RWC Classical、RWC Royalty-Free）：dettato 60.8、Mirelo A2M 56.1、MuScriptor 47.4、YourMT3+ 45.7。RWC Classical 單一資料集上 Mirelo 略勝（65.8 對 64.4）。

## 安裝與使用方式

需求：Python 3.10+、PyTorch 2.2+，建議 CUDA GPU。m4a／aac 與部分 mp3 需要系統上有 `ffmpeg`。

```bash
pip install git+https://github.com/kobimusic/dettato

# 單檔 → out/song.mid + out/song.json（軌道、音符數、調律估計）
dettato song.mp3 -o out/

# 多檔、整個資料夾（遞迴搜尋，保留資料夾結構）；強制 CPU 加 --device cpu
dettato song.mp3 other.wav folder/ -o out/
```

```python
import dettato

result = dettato.transcribe("song.mp3")
result.save_midi("song.mid")
for track in result.tracks:
    print(track.name, track.program, track.is_drum, len(track.notes))

# 大量檔案：只載入一次模型
from dettato import Dettato
model = Dettato.from_pretrained("cuda")
for path in paths:
    model.transcribe(path).save_midi(path + ".mid")
```

第一次執行會從 Hugging Face 下載權重；離線使用時把四個模型 repo 放在同一資料夾，並設定 `DETTATO_WEIGHTS` 指向它。

## 適用情境

- 把整首歌轉成多軌 MIDI，丟進 DAW 換音色、重新編曲或取樣旋律與和聲。
- 抓出鼓組節奏型，做成 MIDI 鼓軌。
- 鋼琴獨奏、古典、爵士錄音的採譜初稿。
- 批次處理大量音檔，替音樂資訊檢索（MIR）研究或資料集建置產生 MIDI。
- 搭配音樂生成模型，把生成的歌轉回 MIDI 再編輯。

## 授權與成本

- **授權**：程式碼與模型權重皆為 Apache-2.0，可商用。但 README 提醒：分軌器與鼓組模型的部分訓練資料集帶有非商用條款，各模型卡列有資料集與授權，商用前請自行確認。
- **成本**：本機執行免費。

## 限制與注意事項

- 評測數字都是作者自評；表中只評了轉譜器與鼓組，**四個模型串在一起的完整流程還沒評過**，分軌器只在作者自己的分軌基準上測過。
- 中文介紹文與作者研究頁把 60.8 當成整體分數，但那其實只是 Mirelo 有公布的三個資料集；九個資料集的整體分數是 59.2。
- **分軌是最弱的一環**：作者說真實爵士錄音中約四分之一的薩克斯風或主奏吉他音符會被分進鋼琴軌；合成器為主的音樂、管樂團的樂器命名也只是大概。中文介紹轉述的 Hacker News 回報也提到純鋼琴被拆成鋼琴、吉他、鼓三軌，目前無法鎖定只輸出某種樂器。
- 人聲與多樂器齊奏容易混淆（社群回報）。
- 輸出是**演奏 MIDI**：保留錄音原本的時間，沒有量化到拍子上，不是可以直接演奏的樂譜。要樂譜作者推薦 Songscription 或 Klangio。
- 音高只涵蓋鋼琴 88 鍵，同一個鍵同時最多兩個音；只預測十二平均律（可調 A4 基準音）。
- 取樣率低於 40 kHz 的音檔不會轉鼓組。
- CPU 可以跑但很慢（筆電 CPU 上 15 秒的片段含載入花了 87 秒）。
- 專案很新（2026-11-16 建立），尚無 release，介面可能變動。

## 相關工具

- [Basic Pitch](Basic-Pitch.md)：Spotify 的輕量音訊轉 MIDI，適合單一樂器；要整首混音分軌與鼓組時改用 dettato
- [ACE-Step 1.5](ACE-Step-1.5.md)：本機音樂生成，生成的歌可用 dettato 轉成多軌 MIDI 再編輯
- [earshot](earshot.md)：讓 coding agent 聽、檢查音訊

## 資料來源

- https://github.com/kobimusic/dettato （README：架構、評測表、安裝、限制、授權）
- https://api.github.com/repos/kobimusic/dettato （星數、Apache-2.0、建立時間、最後 push）
- https://huggingface.co/collections/kobimusic/dettato （四個模型與評測資料集；模型授權 Apache-2.0）
- https://kobi.music/research/dettato （作者研究文章，2026-11-16；開發過程、與 Mirelo 的比較）
- https://blog.derekhsu.net/2026/11/21/dettato-open-audio-to-midi-model/ （中文介紹與 Hacker News 社群實測整理）
