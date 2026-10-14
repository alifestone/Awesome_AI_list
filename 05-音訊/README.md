# 🎵 音訊

處理聲音與音樂的 AI 工具。

### [Basic Pitch](Basic-Pitch.md)

Spotify 開源的音訊轉 MIDI 輕量模型：輸入一段音訊，輸出含滑音（pitch bend）資訊的 MIDI 檔。不限樂器，支援複音樂器與人聲，一次處理單一樂器效果最好。有 Python、TypeScript 版與網頁 Demo。Apache-2.0。

可以做到：
- 把演奏或人聲哼唱轉成 MIDI，再到 DAW 裡編輯、換音色或製譜。
- 作曲、編曲時快速擷取旋律與和聲素材。
- 當音樂資訊檢索（MIR）研究的轉譜基線。
- 部署在瀏覽器、行動端等低資源裝置上。

> 語音 agent（語音辨識 + LLM + 語音合成的即時對話）請見 [Agent 框架與編排](../06-Agent-框架與編排/) 的 Pipecat；影片配音、配樂請見 [影片製作](../03-影片製作/)；從整首歌生成 MV 請見 [AutoMV](../03-影片製作/AutoMV.md)。
