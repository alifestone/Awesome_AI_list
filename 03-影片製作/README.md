# 🎬 影片製作

讓 AI 做影片的工具：從「給主題就出片」的全自動系統、用程式碼寫動畫再渲染成影片的框架，到讓 agent 剪片、看懂影片、拆解爆紅短片的 skill。

## Agent 影片製作系統（從主題到成片）

### [OpenMontage](OpenMontage.md)

開源 agentic 影片製作系統，把 Claude Code、Cursor 等 coding agent 變成影片工作室：agent 負責研究、寫腳本、生素材、剪輯與合成。AGPL-3.0。

可以做到：
- 從一句描述產出解說動畫、預告片、紀錄片式蒙太奇。
- 把長篇 Podcast 或訪談切成多支社群短片，做字幕翻譯與多語配音。
- 參考爆紅影片的節奏做原創版本；可接本地 ComfyUI，不付費也能做。

### [MoneyPrinterTurbo](MoneyPrinterTurbo.md)

最熱門的開源 AI 短影音生成器之一：輸入主題，自動完成腳本、配音、素材、字幕、配樂與剪輯，每個階段都能手動調整。MIT。

可以做到：
- 大量產出知識型、資訊型短影音（TikTok、Reels、Shorts）。
- 從關鍵字快速做出含配音與字幕的草稿，再人工微調。
- 透過 API、CLI 或 WebUI 接進 n8n 等自動化流程批次生成。

### [video-autopilot-kit](video-autopilot-kit.md)

從實戰頻道抽出來的 YouTube／短影音自動化框架（繁中文件）：方法論、用程式擋下不合格剪法的「機械閘門」，以及素材處理與 QA 工具。MIT。

可以做到：
- 經營長片、Shorts、訪談三種頻道，把剪輯規範和品質檢查自動化。
- 發布前自動擋下片長、字幕、沒有來源的數據等常見錯誤。
- 透過問卷把模板填成自己頻道的設定。

### [AI video drama platform](AI-video-drama-platform.md)

非常早期的 AI 短劇實驗專案，流程是「故事大綱 → LLM 結構化分鏡 → ComfyUI 產圖 → FFmpeg 合成」。目前只是後端骨架。⚠️ 未附授權檔。

可以做到：
- 學習 LLM 結構化輸出串 ComfyUI、FFmpeg 的流水線寫法。
- 當自建 AI 分鏡／短劇產生器的起點；還不能直接產出可發布的成片。

## 程式化動畫 / HTML → 影片

### [Remotion](Remotion.md)

用 React 元件描述畫面、再渲染成影片的框架，是程式化影片類工具中歷史最久、生態最完整的。有官方 agent skills。⚠️ 自訂授權：個人與 3 人以下公司免費，較大的公司需付費。

可以做到：
- 用 coding agent 產出知識動畫、產品介紹、社群短片。
- 依資料批次產生大量個人化影片（年度回顧、報表影片）。
- 在自家產品內嵌影片編輯或預覽；也是 Cinetic、OpenMontage 等工具的渲染引擎。

### [HyperFrames](HyperFrames.md)

HeyGen 的開源框架：寫 HTML／CSS／動畫，渲染成確定性的 MP4，專為 AI agent 設計。Apache-2.0，無商用門檻。

可以做到：
- 產品發表片、功能公告、網站導覽影片。
- PR 變更說明影片（程式碼 diff 動畫、旁白、字幕）。
- 資料視覺化、chart race、地圖動畫、文件或 PDF 轉影片。
- 在 CI 中渲染可重現的動態圖像。

### [Cinetic](Cinetic.md)

讓 coding agent「導演」一支短片的 skill：先構思故事，再定品牌、配樂並渲染，最後用腳本與多個評審角色檢查成品。MIT。

可以做到：
- 產品發表的預告片、landing page 的無聲功能循環動畫。
- Reels／TikTok 直式短片、logo 片頭。

### [onetake](onetake.md)

做「一鏡到底」動態影片的 Claude Agent Skill：每個段落都從上一個畫面長出來，避免投影片感。⚠️ PolyForm Noncommercial（非商用）。

可以做到：
- 產品發表片、預告片、App 功能演示。
- 用截圖重建 UI 做高畫質運鏡，不必錄螢幕。
- 參考動態設計的節奏、銜接、運鏡方法論。

### [PDoomVideo](PDoomVideo.md)

Claude Opus 5.5 在 Claude Code 裡生成的音樂 MV 原始碼，作者只給了角色設計和「每句歌詞都要有有趣畫面」兩項指示。⚠️ 未附授權檔。

可以做到：
- 參考 LLM 如何規劃長篇程式化動畫（分鏡文件、subagent 風格指南、分章節程式碼）。
- 學習 p5.js + headless Chrome 逐幀渲染、再用 ffmpeg 合成的做法。

## 剪輯 / 處理

### [ffmpeg-skill](ffmpeg-skill.md)

給 coding agent 的本機剪輯 skill：42 支 Python 腳本呼叫 ffmpeg，流程是量測 → 盡量無損剪輯 → 檢查 → 驗證。不用雲端、不用 API key，也能當 MCP。MIT。

可以做到：
- 剪片段、刪靜音、加字幕、響度標準化、調色、轉直式畫面。
- 一支影片輸出多個平台版本，並自動檢查規格。
- 處理不想上傳雲端的內部或客戶素材。

### [ChatCut](ChatCut.md)

線上對話式剪輯服務；agent-plugin 讓 coding agent 透過 MCP 直接改你 ChatCut 雲端專案的時間軸。商業服務。

可以做到：
- 依逐字稿刪贅字與停頓，快速初剪口播、訪談、教學影片。
- 自動上字幕（含繁體中文）。
- 加配樂、配音與簡單動態圖形。

### [Palmier Pro](Palmier-Pro.md)

以 Premiere Pro 為目標、為 AI 打造的 macOS 剪輯軟體，內建 AI 生成並開放 MCP server。⚠️ v0.7.6 以前為 GPLv3，之後的版本改為專有授權。

可以做到：
- 讓 Claude Code 或 Codex 直接剪本機專案，同時保留圖形化時間軸可人工微調。
- 在同一條時間軸混用實拍素材與 AI 生成片段。

### [Higgsfield MCP](Higgsfield-MCP.md)

AI 影像／影片生成平台 Higgsfield 的 MCP server，不需 API key 就能讓 Claude 呼叫平台上 30 多個圖像與影片模型。商業服務。

可以做到：
- 讓 Claude 依 brief 規劃整套製作：Higgsfield 生素材 → Blender 建 3D → After Effects 合成。
- 交付可繼續編輯的 AE／Premiere 專案，而不只是壓平的 MP4。

## 影片理解 / 分析

### [claude-video（/watch）](claude-video（-watch）.md)

讓 Claude「看」影片的 skill：把影片網址或本機檔轉成帶時間戳的截圖與逐字稿。優先用原生字幕，沒有時可用本機 WhisperX 或雲端轉錄。MIT。

可以做到：
- 讓 agent 看教學影片、產品示範或錄影，整理成帶時間戳的摘要。
- 拆解參考影片的節奏、畫面與台詞。
- 檢查螢幕錄影裡的程式碼或 UI 變化；私人影片可全程本機處理。

### [hook-lab](hook-lab.md)

Claude Code skill：輸入 TikTok、Reels 或 Shorts 網址，拆解開場鉤子、腳本結構與爆紅原因。MIT。

可以做到：
- 研究競品或爆紅短影音的開場與結構。
- 把海外短影音的手法改寫成適合小紅書、視頻號的內容。
- 累積拆解紀錄，比較多支影片的共同模式。

## 怎麼挑

- **給主題就要成片**：OpenMontage（功能最全）、MoneyPrinterTurbo（短影音量產）、video-autopilot-kit（重視品管）。
- **產品發表片、動態設計**：HyperFrames、Remotion，或用 Cinetic、onetake 這類 skill 加上導演思維。
- **剪現有素材**：本機用 ffmpeg-skill，要時間軸介面用 Palmier Pro，雲端用 ChatCut。
- **讓 AI 看懂影片**：claude-video；專門拆短影音：hook-lab。
