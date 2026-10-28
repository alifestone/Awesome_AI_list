# FilmCraft

- **分類**：影片製作 / 剪輯 / 處理（非線性剪輯軟體，可由 agent 驅動）
- **連結**：https://github.com/storytold/filmcraft
- **官網**：https://getartcraft.com/apps/filmcraft

## 原清單說明

（投稿時僅附連結，無原清單說明）

> **查證結果**：與 GitHub API 及 README 相符。repo 描述為 *An open-source, nonlinear video editor written by scratch in pure Rust*。README 寫的授權是 MIT 或 Apache-2.0 雙授權，GitHub 顯示的 SPDX 標示為 Apache-2.0；以 LICENSE-MIT 與 LICENSE-APACHE 為準。查詢當下（2026-10-27）約 16.4k 顆星、6.8k forks、1,815 個 open issues，最新 release 為 v0.13.0（2026-10-25）。repo 建立於 2026-09-30。

## 概述

FilmCraft 是以純 Rust 從頭寫的開源非線性影片剪輯軟體（NLE），由 ArtCraft 團隊開發。它的操作介面模仿專業剪輯軟體常見的面板與快捷鍵，包含 Source／Program 監視器、素材櫃、多軌時間軸，以及 Editing、Assembly、Color、Effects、Audio 等工作區。它支援 macOS、Windows、Linux，也能透過 WebAssembly 在瀏覽器中執行。

和其他 AI 影片工具最大的不同是：它的每個操作都是一個有 id、型別化參數與啟用狀態的「命令」。圖形介面、命令列、JSON 控制通道與 MCP server 呼叫的是同一組命令，因此 Claude 或其他 agent 可以像人一樣剪輯、修剪、調色、混音與匯出。README 表示，目前有 650 多個引擎命令。

定位上它是一套完整剪輯器，不是「給主題就出片」的生成系統，也不是剪輯 skill。

## 核心功能／特色

- **剪輯**：三點剪輯（插入、覆寫、抽離、提取）、Ripple／Roll／Slip／Slide 等修剪工具、動態修剪（trimming while playing）、多軌時間軸、巢狀序列、標記（可匯出 CSV）、無限復原與歷史面板，以及自動存檔與崩潰復原日誌。
- **時間基準**：以整數 tick 計算（每秒 254,016,000,000），README 說 23.976、29.97 drop-frame、59.94 都是精確計算而非近似。
- **調色**：基礎校正、8 種內建風格（以程式碼寫的色彩轉換，不是 LUT 檔）、RGB 曲線與色相／飽和度曲線、色輪、HSL 次要選取、暈影，以及波形與向量示波器。計算在線性光、32 位元浮點下進行。
- **特效與動態**：超過 90 種視訊特效、約 30 種轉場、位置／縮放／旋轉等變形、26 種混合模式、多種關鍵影格插值與速度圖。GPU 合成器基於 wgpu（Metal、Vulkan、DirectX 12、WebGPU），另有 CPU 路徑，兩者有互相比對的測試。
- **音訊**：ITU-R BS.1770／EBU R128 響度表、參數 EQ、動態處理、true-peak 限制器、混音台（24 軌、推子、Sends、Submix）、Read／Latch／Touch／Write 自動化，以及常數功率淡入淡出。
- **字幕與文字**：OpenType 排版、雙向文字、Type／Shape／Pen 工具；字幕軌支援 Subtitle、CEA-608、CEA-708、Teletext，可匯入匯出 SRT、WebVTT、SCC。
- **原生編解碼器**：H.264 與 HEVC（解碼）、ProRes、VP8／VP9、Opus、AV1（解碼）、DNxHD／DNxHR、AAC 等，README 表示這些是自行以 ITU-T、ISO、IETF 公開規格實作，並以 ffmpeg 作為外部比對工具測試；不內含 FFmpeg。MP3、FLAC 等目前透過 symphonia crate（MPL-2.0）處理。
- **給 agent 用**：`filmcraft-cli commands` 列出所有命令；`filmcraft-cli mcp` 啟動無介面的 MCP server；`--control <port>` 開啟 JSON-lines 控制通道；UI 每個元件都有 automation id，agent 可以點擊、拖曳、輸入與截圖。

## 技術架構或運作原理

- **分層**：引擎（時間模型、資料模型、命令系統、渲染與匯出管線）與 UI（`ui-egui` crate）分開，因此 UI 可以換成其他前端而不影響剪輯邏輯。
- **命令模型**：所有操作皆經由同一套命令分派，UI、CLI、控制通道與 MCP 共用，行為一致。
- **專案格式**：`.fcproj`，有 schema 遷移機制；透過 FCP7 XML、AAF、OTIO 交換素材。
- **渲染**：預覽與匯出皆走同一條 GPU／CPU 合成路徑。

## 安裝與使用方式

```sh
# 桌面版（附示範專案）
cargo run --release -p filmcraft

# 桌面版並開啟 JSON-lines 控制通道
cargo run --release -p filmcraft -- --control 9876

# 列出所有引擎命令
cargo run --release -p filmcraft-cli -- commands

# 無介面的 MCP server
cargo run --release -p filmcraft-cli -- mcp
```

README 另提供預先編譯的版本（Downloads 段落），以及網頁版 `filmcraft-web-<version>.zip`。

可選的日文字型來自 [craft-fonts](https://github.com/storytold/craft-fonts)（OFL-1.1），不裝也能建置，只是會改用系統字型。

控制通道範例（README 所列）：

```jsonc
{"method": "engine.execute", "params": {"command": "timeline.place",
  "params": {"item": 1, "track": "V1", "seconds": 0, "sourceIn": 284298240000000, "duration": 1270080000000}}}
```

## 適用情境

- 需要真正的非線性剪輯器（多軌、調色、混音、字幕），又希望能用 agent 自動化重複性工作。
- 想研究或參與開源 NLE 的開發，例如寫新命令、特效、編解碼器或面板（參見 CONTRIBUTING.md）。
- 想在不靠 FFmpeg 的前提下，用 Rust 寫的剪輯引擎處理素材。
- 想嘗試在瀏覽器中剪片（WebAssembly 版）。

## 授權與成本

- **授權**：MIT 或 Apache-2.0 雙授權（使用者擇一）。repo 另附 NOTICE 與 ATTRIBUTION.md，內建素材各自有開放授權。
- **成本**：免費，未見付費方案。
- **社群**：Discord（https://discord.gg/artcraft）。

## 限制與注意事項

- **alpha 階段**，README 自評「功能廣度約 86%、可用於實際production約 56%」（2026-10-10 量測，見 docs/target-app-parity.md）。
- **大型素材速度**：色彩、Key 與匯出渲染目前仍在 CPU 執行；硬體解碼在 macOS、Windows，以及 Linux 上的 H.264／HEVC 可用。
- **專案匯入**：目前不能直接開啟 Premiere 的 `.prproj`，需先以 FCP7 XML、AAF 或 OTIO 轉入。
- **外掛**：不支援 VST3、Audio Units 或 OpenFX。
- **交付編碼**：軟體 H.264 是唯一的軟體交付格式；H.265 目前僅能用硬體編碼。
- **Issue 數量多**：repo 有 1,815 個 open issues，需自行評估狀態。
- 需要從原始碼編譯（Rust 工具鏈）或下載預先編譯版本。

## 相關工具

- [Remotion](Remotion.md)：另一種程式化影片工具（用 React 寫影片），定位不同
- [Palmier Pro](Palmier-Pro.md)：同樣主打 agent 與人共用時間軸的 macOS 剪輯軟體，但 v0.7.6 之後改為專有授權
- [ChatCut](ChatCut.md)：線上對話式剪輯，同樣透過 MCP 操作時間軸
- [ffmpeg-skill](ffmpeg-skill.md)：本機以 ffmpeg 為基礎的剪輯 skill，沒有時間軸介面

## 資料來源

- https://github.com/storytold/filmcraft （README、LICENSE-MIT、LICENSE-APACHE）
- https://api.github.com/repos/storytold/filmcraft （星數、授權、建立與最近推送時間）
- https://api.github.com/repos/storytold/filmcraft/releases/latest （v0.13.0）
- https://getartcraft.com/apps/filmcraft （官網，README 所附連結）
