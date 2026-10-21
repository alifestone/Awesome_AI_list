# 🎬 影片製作

讓 AI 做影片的工具：從「給主題就出片」的全自動系統、用程式碼寫動畫再渲染成影片的框架、呼叫影片模型生成畫面的工具，到讓 agent 剪片、看懂影片、拆解爆紅短片的 skill。

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

### [OpenDirector](OpenDirector.md)

自架的 AI 影片工作室：輸入一句構想，9 個 LangGraph agent 依序產出研究、故事、分鏡、角色、配音與配樂，再渲染成片；另有用素材庫量產短影音的批次模式。Docker 一鍵部署。LGPL-3.0。

可以做到：
- 從一句話做出有角色、分鏡、旁白的短故事影片（以靜態分鏡圖為主）。
- 用 34 種內建美術風格統一畫面，分鏡可預覽、腳本可手改。
- 批次產出知識型短影音，資料都留在自己的伺服器。

### [AutoMV](AutoMV.md)

輸入一整首歌，自動生成長篇音樂 MV 的多 agent 研究系統：先分析段落、人聲與歌詞，再由編劇、導演、驗證 agent 協作，用角色庫維持角色一致，演唱鏡頭會對嘴。附論文與評測基準。Apache-2.0。

可以做到：
- 為獨立音樂人的歌做出有故事、有對嘴鏡頭的 MV 初稿（論文估計每首約 $10–20、30 分鐘）。
- 研究音樂轉影片、長片角色一致性的做法。
- 用 12 項基準評測自己的 MV 生成系統。

### [ViMax](ViMax.md)

港大 HKUDS 的多 agent 影片創作框架：編劇、導演、製片、影片生成一條龍，輸入可以是一句點子、一份劇本或一部小說，目標是角色與場景一致的長片。有 TUI 與 Web UI，模型全走 API。MIT。

可以做到：
- 從構想做出多場景的故事短片或兒童動畫。
- 把劇本或小說章節轉成影片初稿（Script2Video、Novel2Video）。
- 上傳照片，讓自己或寵物在故事裡客串（AutoCameo）。

### [PenShot](PenShot.md)

只做「劇本 → 分鏡」這一段的 LangGraph 多 agent 系統：把任何劇本切成鏡頭片段，替每段寫好 Sora／Veo／可靈用的中英提示詞、負面提示詞與音訊提示詞，並用記憶與向量檢索維持角色一致。不直接出影片。MIT。

可以做到：
- 把短劇、小說改編劇本批次轉成可貼進影片模型的分鏡提示詞。
- 當自建影片流水線的前段，透過 SDK、REST API 或 MCP 串接。

### [Jellyfish](Jellyfish.md)

自架的 AI 短劇製作工作台：劇本拆成鏡頭，抽出角色、場景、道具、服裝集中管理以維持一致，鏡頭確認就緒後再派發圖片與影片生成，所有任務在同一個任務中心追蹤。React＋FastAPI，Docker Compose 部署。Apache-2.0。⚠️ 內建只接 OpenAI、火山引擎、阿里百鍊；介面以簡體中文為主。

可以做到：
- 把短劇劇本拆成分鏡，逐鏡確認素材與對白後批次生成圖片與影片。
- 在多集、多鏡頭之間重複使用同一組角色、場景、服裝，減少長相與風格飄移。
- 當團隊的 AI 短劇製作後台，追蹤每個生成任務的狀態與結果。

## 程式化影片（程式碼 → 影片）

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

### [Manim](Manim.md)

3Blue1Brown 用來做影片的 Python 數學動畫引擎（ManimGL，套件名 `manimgl`）：用程式碼描述公式、座標軸、圖形怎麼變化，再即時預覽或渲染成影片。另有更適合新手的社群版 Manim CE，兩版語法不相容。本身不是 AI 工具。MIT。

可以做到：
- 做數學、物理、演算法、機器學習的解說動畫，公式可以逐字變形。
- 讓 coding agent 依文字描述寫出可重跑、可修改的教學動畫。
- 參考 3Blue1Brown 公開的影片原始碼學寫法。

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

### [Awesome Opus 5.5 Videos](Awesome-Opus-5.5-Videos.md)

收集社群用 Claude Opus 5.5「寫程式」做出的動畫影片與背後的 prompt：703 個 prompt，分動態設計、解說動畫、3D 場景、遊戲與互動四類，每個都連回創作者的原始貼文；其中 418 個在 Skillry 有重製版可並排對照。MIT（影片與 prompt 版權屬原作者）。⚠️ 約 3 成 prompt 只公開了一部分，且沒有附程式碼。

可以做到：
- 找現成的動畫 prompt，貼給 Opus 5.5 輸出成單一 HTML 檔再錄成影片。
- 依類型或技術（Canvas、SVG、Three.js、shader…）找靈感，用 `data/videos.json` 批次篩選。
- 比較不同人怎麼寫動畫類 prompt。

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

## AI 影片生成

### [WanGP](WanGP.md)

給「顯卡不夠好」的人用的本機生成式 AI 整合 App：一個瀏覽器介面跑 Wan、LTX、Hunyuan Video、MiniMax H3 等開源影片模型，也包含圖像、TTS／音訊與 3D 模型，部分模型 6 GB VRAM 就能跑。約 1 萬顆星。⚠️ 自訂授權 WanGP Community License：可免費使用、作品可商用，但不能轉售或做成付費服務。

可以做到：
- 用家用顯卡在本機做文生影片、圖生影片、首尾幀、角色替換、影片配音與配樂。
- 用內建的 Deepy 助理從一段 brief 規劃分鏡、生成並檢查整支短片。
- 透過 MCP server 讓 Claude Code 等 agent 呼叫本機的影片、圖像與語音模型。

### [Higgsfield MCP](Higgsfield-MCP.md)

AI 影像／影片生成平台 Higgsfield 的 MCP server，不需 API key 就能讓 Claude 呼叫平台上 30 多個圖像與影片模型。商業服務。

可以做到：
- 讓 Claude 依 brief 規劃整套製作：Higgsfield 生素材 → Blender 建 3D → After Effects 合成。
- 交付可繼續編輯的 AE／Premiere 專案，而不只是壓平的 MP4。

### [BeatDesign](BeatDesign.md)

本機跑的 AI 圖片／影片工作台，自稱開源版 Higgsfield：無限畫布上生成與比較素材，再接到瀏覽器內的時間軸剪輯、加字幕並匯出 MP4。開放 29 個 MCP tool，讓 Claude Code、Codex 等 agent 操作同一個專案。生成只接 BeatAPI（需自備 key）。Apache-2.0。

可以做到：
- 在畫布上用 GPT Image、Wan、Kling、MiniMax 等模型生成、分支、比較圖片與影片。
- 把生成結果排進時間軸，剪輯、疊 logo、上 SRT 字幕，局部片段用 AI 重做。
- 讓 agent 批次生成並排好時間軸，再由人在瀏覽器裡檢查與微調。

### [Code Video Model](Code-Video-Model.md)

研究專案：文字先變成可編輯的 Three.js 場景程式，渲染成代理影片，再搭配參考圖交給影片模型生成，讓鏡位、動作、物理都能靠改程式控制。Apache-2.0。

可以做到：
- 用程式碼精準控制鏡頭與物體運動，再生成寫實影片。
- 修改場景後重跑，做同一場景的編輯版本。
- 用 CodeVideoBench 評測可控影片生成。

## 影片理解

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

- **給主題就要成片**：OpenMontage（功能最全）、MoneyPrinterTurbo（短影音量產）、video-autopilot-kit（重視品管）、OpenDirector（自架網頁工作室、有角色與分鏡）、ViMax（點子／劇本／小說都能轉，偏長片）。
- **要一個管理劇本、分鏡、素材一致性與生成任務的短劇製作後台**：Jellyfish。
- **已有劇本，只要分鏡提示詞**：PenShot；要動漫風格的鏡頭，模型可用 [Index-AniSora](../10-模型/Index-AniSora.md)。
- **有歌要做 MV**：AutoMV（AI 生成畫面與對嘴）；想用程式畫的參考 PDoomVideo。
- **想找 LLM 寫程式做動畫的範例與 prompt**：Awesome Opus 5.5 Videos（有完整原始碼的範例看 PDoomVideo）。
- **數學、科學解說動畫**：Manim（新手可先用社群版 Manim CE）。
- **產品發表片、動態設計**：HyperFrames、Remotion，或用 Cinetic、onetake 這類 skill 加上導演思維。
- **剪現有素材**：本機用 ffmpeg-skill，要時間軸介面用 Palmier Pro，雲端用 ChatCut。
- **用 AI 生成畫面**：要在自己顯卡上跑開源影片模型用 WanGP；要一次接 30 多個商用模型、交付可編輯的 AE 專案用 Higgsfield MCP；要類似 Higgsfield 的畫布＋時間軸、但專案留在本機用 BeatDesign；要精準控制鏡位與物理用 Code Video Model（需 GPU 與多個外部 API）。
- **讓 AI 看懂影片**：claude-video；專門拆短影音：hook-lab。
