# 🎵 音訊

處理聲音與音樂的 AI 工具。

### [Basic Pitch](Basic-Pitch.md)

Spotify 開源的音訊轉 MIDI 輕量模型：輸入一段音訊，輸出含滑音（pitch bend）資訊的 MIDI 檔。不限樂器，支援複音樂器與人聲，一次處理單一樂器效果最好。有 Python、TypeScript 版與網頁 Demo。Apache-2.0。

可以做到：
- 把演奏或人聲哼唱轉成 MIDI，再到 DAW 裡編輯、換音色或製譜。
- 作曲、編曲時快速擷取旋律與和聲素材。
- 當音樂資訊檢索（MIR）研究的轉譜基線。
- 部署在瀏覽器、行動端等低資源裝置上。

### [earshot](earshot.md)

給 coding agent 的「耳朵」：把聲音轉成 agent 能推理的文字與數字（聽起來像什麼、是否符合描述、長錄音裡最好的片段、真實錄音還是程式合成、整支影片的聲畫同步與評分），也能用程式碼做音效再邊聽邊改。本機 CPU 執行，有 CLI、Python API 與 MCP server。MIT。

可以做到：
- 替程式做出的影片挑選、剪輯、對齊音效，並檢查響度與聲畫同步。
- 依文字描述從一堆下載的音效檔裡挑出最合適的。
- 不用錄音，從內建 201 個程式化音效或自寫 recipe 產生 UI 音效、whoosh、logo sting。

### [VoiceStudio](VoiceStudio.md)

本機版的 ElevenLabs 替代品：聲音複製、用文字設計聲音、影片翻譯配音、聽寫、轉錄、有聲書旁白都在自己電腦上完成，不需帳號。預設引擎 OmniVoice（646 種語言），另可切換 CosyVoice、IndexTTS、WhisperX 等數十種開源引擎；有桌面 app、Docker、手機版、本機 API 與 MCP server。AGPL-3.0（模型各有授權）。

可以做到：
- 用一段參考錄音複製聲音，念旁白、有聲書。
- 把影片翻成其他語言並配上對齊時間的語音。
- 讓 agent 透過 MCP 用指定聲音說話或轉錄音檔。

> 語音 agent（語音辨識 + LLM + 語音合成的即時對話）請見 [Agent 框架與編排](../06-Agent-框架與編排/) 的 Pipecat；影片配音、配樂請見 [影片製作](../03-影片製作/)；從整首歌生成 MV 請見 [AutoMV](../03-影片製作/AutoMV.md)；用程式碼做影片請見 [Cinetic](../03-影片製作/Cinetic.md)、[Remotion](../03-影片製作/Remotion.md)，可搭配 earshot 配音效。
