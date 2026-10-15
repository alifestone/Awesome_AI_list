# AI tool list（重新分類版）

> 依「用途」重新分組，每項附一句說明。整理日期：2026-10-14。
> 標 ⚠️ 的是需要留意的地方；標「（依名稱判斷）」的是查不到詳細資料、只能從名稱推測的項目。

---

## 🤖 機器人與具身智慧

- **研究 / 模型**
    - **[ARC](https://arc-robot-reasoning.github.io/)** — 機器人基礎模型的推理訓練法：自動替既有示範資料標註「以動作為依據的因果推理」，再微調 π0.5 等 VLA，不需收新示範。程式碼與模型待釋出。
    - **[SpatialClaw](https://github.com/NVlabs/SpatialClaw)**（NVIDIA，NeurIPS 2026）— 以「寫程式」當動作介面的空間推理 agent：VLM 在持久 Jupyter kernel 裡呼叫 SAM3、Depth-Anything-3 等感知工具，免訓練。
- **模擬**
    - **[MuJoCo](https://github.com/google-deepmind/mujoco)** — DeepMind 的物理模擬引擎，機器人與強化學習的標準模擬器。
- **LLM 控制**
    - **[quackd](https://github.com/rokbenko/quackd)** — 用自然語言 + LLM 指揮 Pollen Robotics 的 Microduck 雙足小機器人，內建模擬器與 MCP。⚠️ 原清單標為 LeRobot，實際針對的是 Microduck。

---

## 🧊 3D 建模與生成

- **CAD / 參數化建模**
    - **[FreeCAD MCP](https://github.com/neka-nat/freecad-mcp)** — 讓 AI 透過 MCP 操作 FreeCAD。
    - **[Rhino MCP](https://github.com/jingcheng-chen/rhinomcp)** — 讓 AI 透過 MCP 操作 Rhino。
    - **[MAC – Multi-Agent CAD](https://github.com/Pan-Chera/Multi-Agent-CAD)** — 四個 agent 分工的 text-to-CAD（build123d），直接輸出可列印的 STEP/STL，token 用量約為單一 agent 的 1/116。
    - **[USD BRep](https://github.com/NVIDIA-Omniverse/usd-brep)** — NVIDIA Omniverse 開源的 NURBS BRep 實體建模函式庫（C++／Python），可原生匯入匯出 OpenUSD；附 text-to-3D 資產生成的 agent skill。
- **Blender × Agent**
    - **[cc-blender-skill](https://github.com/RobLe3/cc-blender-skill)** — Claude Code skill 外掛，經 Blender MCP 用自然語言建模、上材質、打光、運鏡、渲染、做動畫與匯出。
    - **[TheLongSilence](https://github.com/achimala/TheLongSilence)** — Claude Opus 5 做的瀏覽器太空探索遊戲；repo 裡附有 `.claude/skills/blender-hardsurface` 硬表面建模 skill（原清單收錄的應是這個）。
- **AI 生成 3D / 世界**
    - **World Labs** — 生成可探索 3D 世界的服務（Marble）。
    - **[Hyper3D（Rodin）](https://hyper3d.ai/)** — AI 生成 3D 模型。（已移除原連結的廣告追蹤參數）
- **3D 重建**
    - **[3D Gaussian Splatting for model city](https://github.com/rakeshsuthar6322/3d_gaussian_splatting_for_model_city)** — 以 3DGS 重建模型城市場景（依名稱判斷）。
- **作品範例**
    - **[Anatomy](https://github.com/thebuggeddev/anatomy)** — 用 Three.js 做的互動式 3D 人體解剖瀏覽器（由 GPT 生成），偏參考作品而非工具。

---

## 🎬 影片製作

- **Agent 影片製作系統（從主題到成片）**
    - **[OpenMontage](https://github.com/calesthio/OpenMontage)** — 開源 agentic 影片製作系統，把 Claude Code / Cursor 變成影片工作室；多條 pipeline（解說動畫、預告片、紀錄片、Podcast 剪片、多語配音…），可接本地 ComfyUI。AGPL-3.0。
    - **[MoneyPrinterTurbo](https://github.com/harry0703/MoneyPrinterTurbo/blob/main/README-en.md)** — 輸入主題，自動產生文案、素材、字幕、配音與背景音樂的短影音生成器。
    - **[video-autopilot-kit](https://github.com/Hao0321/video-autopilot-kit)** — YouTube／短影音自動化框架（繁中文件）：長片、Shorts、訪談三條產線，ffmpeg QA，問卷式填入自己頻道的設定。
    - **[AI video drama platform](https://github.com/dc-tw/ai-video-drama-platform)** — AI 短劇製作平台（依名稱判斷）。
    - **[OpenDirector](https://github.com/seme-org/open-director)** — 自架的 AI 影片工作室：一句話 → 9 個 agent 產出故事、分鏡、角色、配音與配樂並渲染；另有批次量產短影音模式。Docker 部署。LGPL-3.0。
    - **[AutoMV](https://github.com/multimodal-art-projection/AutoMV)**（M-A-P，arXiv 2512.12196）— 輸入整首歌生成長篇 MV 的多 agent 系統：音樂分析 → 編劇／導演 agent → 關鍵幀與影片生成（含對嘴）→ 驗證。依賴豆包、即夢、Gemini 等 API。Apache-2.0。
    - **[ViMax](https://github.com/HKUDS/ViMax)**（港大 HKUDS，arXiv 2606.07649）— 點子／劇本／小說 → 編劇、導演、製片 agent → 逐鏡生成長片；可把自己的照片放進故事（AutoCameo），有 TUI 與 Web UI。MIT。
    - **[PenShot](https://pypi.org/project/penshot/)**（[原始碼](https://github.com/neopen/story-shot-agent)）— 劇本分鏡 agent：把任何劇本拆成鏡頭片段，輸出給 Sora／Veo／可靈用的中英提示詞與音訊提示詞，角色跨片段一致；有 SDK、REST、MCP。不直接出影片。MIT。
- **程式化動畫 / HTML → 影片**
    - **[HyperFrames](https://github.com/heygen-com/hyperframes)**（HeyGen）— 寫 HTML/CSS/動畫，渲染成確定性 MP4，專為 AI agent 設計。Apache-2.0。
    - **[onetake](https://github.com/feitangyuan/onetake)** — Claude Agent Skill，做「一鏡到底」的產品發表片、預告與功能演示動效。⚠️ PolyForm Noncommercial（非商用）。
    - **[PDoomVideo](https://github.com/JohnHeibel/PDoomVideo)** — Claude Opus 5.5 在 Claude Code 裡生成的音樂 MV 原始碼，可當程式化動畫參考。
    - **[Remotion](https://github.com/remotion-dev/remotion)** — 用 React 元件寫影片的老牌框架，有官方 agent skills；也是 Cinetic、OpenMontage 的渲染引擎。⚠️ 自訂授權：個人與 3 人以下公司免費，較大的公司需付費。
    - **[Cinetic](https://github.com/Leonxlnx/cinetic)** — 讓 coding agent「導演」短片的 skill：先構思故事，再定品牌、配樂、渲染，最後由多個評審角色檢查。MIT。
- **剪輯 / 處理**
    - **[ffmpeg-skill](https://github.com/kajisho5/ffmpeg-skill)** — 給 coding agent 的本地 FFmpeg 剪輯 skill：剪接、字幕、響度、調色、平台交付檢查等 42 個工具，也可當 MCP。
    - **[ChatCut](https://github.com/ChatCut-Inc/agent-plugin)** — 線上對話式剪輯服務；agent-plugin 讓 coding agent 透過 MCP 直接改 ChatCut 雲端專案的時間軸。商業服務。
    - **[Palmier Pro](https://github.com/palmier-io/palmier-pro)** — 為 AI 打造的 macOS 剪輯軟體，內建 AI 生成並開放 MCP，agent 和人可以編輯同一條時間軸。⚠️ v0.7.6 之後改為專有授權。
    - **[Higgsfield MCP](https://higgsfield.ai/mcp)** — 讓 Claude 不需 API key 呼叫 30 多個圖像／影片模型，再串 Blender、After Effects，交付可繼續編輯的 AE 專案。商業服務。
- **影片理解**
    - **[claude-video（/watch）](https://github.com/bradautomates/claude-video)** — 讓 Claude「看」影片：下載、抽幀、轉錄後交給模型分析。
    - **[hook-lab](https://github.com/hongfamonvAI/hook-lab)** — Claude Code skill：拆解 TikTok／Reels／Shorts 的開場鉤子、腳本結構與爆紅原因，並給小紅書、視頻號的改寫方向。MIT。

---

## 🎨 設計 / 前端

- **[MotionSites](https://motionsites.ai/)** — 給 Lovable、Bolt、Cursor、Claude 用的高質感（3D／動態）網站 prompt 庫，另有 MCP。
- **[open-slide](https://github.com/open-slide/open-slide)** — 為 AI agent 打造的簡報框架：用自然語言描述，由 Claude Code 等 agent 寫 React 投影片，可匯出 HTML／PDF／PPTX。MIT。
- **[GSAP Skills](https://github.com/greensock/gsap-skills)**（GreenSock）— 官方給 coding agent 的 GSAP 動畫 skill 組：時間軸、ScrollTrigger、外掛與框架整合。MIT。
- **[Hairline](https://github.com/lucasmarkes/hairline)** — 會回應滑鼠的細線等角互動插圖（React 元件），附 `hairline-create` skill 讓 agent 畫出風格一致的新圖形。MIT。

## 🎵 音訊

- **[Basic Pitch](https://github.com/spotify/basic-pitch)**（Spotify）— 音訊轉 MIDI 的輕量模型。

---

## 🧠 Agent 框架與編排

- **框架**
    - **[DSPy](https://github.com/stanfordnlp/dspy)** — 用「寫程式」而非手調 prompt 來建構與最佳化 LLM 管線。
    - **[CrewAI](https://github.com/crewAIInc/crewAI)** — 多 agent 角色協作框架。（原放在 Video，已移到這裡）
    - **[Pipecat](https://github.com/pipecat-ai/pipecat)** — 即時語音／多模態對話 agent 框架。（原放在 Video，已移到這裡）
- **Coding agent 與外掛**
    - **[Cline](https://github.com/cline/cline)** — VS Code 裡的自主 coding agent。
    - **[Claude Octopus](https://github.com/nyldn/claude-octopus)** — Claude Code 外掛，讓 Codex、Gemini 等多個模型交叉審查、辯論，有共識閘門。
    - **[Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios)** — 把 Claude Code 變成遊戲工作室：49 個 agent、74 個 skills，涵蓋設計、架構、QA 到發行。
    - **[agency-agents](https://github.com/msitarzewski/agency-agents)** — 各種專業角色的 agent 人設集合。
- **本地應用**
    - **[AnythingLLM](https://github.com/Mintplex-Labs/anything-llm)** — 一體化本地 LLM 應用：文件 RAG 對話、agent，可接各家模型。

---

## ⚡ Jev 決策模型生態

> Jev 是 TypeSafe 的「System One」決策模型：對封閉式問題（是非、選擇、評分）一次回傳帶機率的結構化決策，而不是生成文字。下面這組都是圍繞它的工具。

- **[fast-jev-compaction](https://github.com/tamaratran/fast-jev-compaction)** — Claude Code 外掛：用 Jev 判斷哪些工具呼叫／結果已過時並刪掉，取代摘要式壓縮，保留下來的內容維持原文。
- **[jevgrep](https://github.com/dzhng/jevgrep)** — 「問它做什麼」就能找到相關程式碼的 CLI，給 coding agent 用。
- **[Jev Ultrafast](https://github.com/browser-use/jev-ultrafast)**（Browser Use）— 由 Jev 選操作與目標元素的極速瀏覽器 agent。
- **[edgextract](https://github.com/raphaelmansuy/edgextract)** — 用自訂本體（ontology）+ 封閉式是非決策，把 markdown 轉成知識圖譜，不確定的項目送人工審核。
- **[AnyJev](https://github.com/nokia-applied-research/AnyJev)**（Nokia）— 免訓練把任何開源 LLM 變成 Jev 式決策模型，另有自蒸餾的 Tacit 系列。
- **[Laya](https://huggingface.co/convaiinnovations/laya)**（ConvAI Innovations）— 開源非自回歸決策模型，可自架並提供 Jev 相容端點。Apache 2.0。

---

## 🌐 瀏覽器自動化

- **[Playwright](https://github.com/microsoft/playwright)** — 跨瀏覽器自動化與 E2E 測試框架。
- **[Playwright MCP](https://github.com/microsoft/playwright-mcp)** — 讓 AI 透過 MCP 操作瀏覽器。
- （另見上方 Jev 區的 Jev Ultrafast）

---

## 🔐 資安

- **逆向工程**
    - **[Ghidra](https://github.com/NationalSecurityAgency/ghidra)** — NSA 開源的逆向工程框架。
    - **[GhidraMCP](https://github.com/LaurieWired/GhidraMCP)** — 讓 LLM 透過 MCP 操作 Ghidra。
    - **[REA](https://github.com/morluto/rea)** — 「Reverse Engineer Anything」：讓 agent 逆向分析 macOS 原生 app 並附證據，背後自動安裝與管理 Hopper。
- **滲透測試**
    - **[Pentest Copilot](https://github.com/bugbasesecurity/pentest-copilot)**（BugBase）— AI 滲透測試助手。
    - **[ARTEX](https://github.com/mhtsec/ARTEX)** — AI 自主滲透測試系統，百度「agent+」攻防挑戰賽冠軍專案。AGPL-3.0。
    - **[Pentest Swarm AI](https://github.com/Armur-Ai/Pentest-Swarm-AI)**（Armur AI）— 以 AI agent 蜂群對 API／網頁應用做自主滲透測試，自稱 XBOW 的開源替代。多項功能仍為 alpha／beta。AGPL-3.0。
    - **[Claude-Red](https://github.com/SnailSploit/Claude-Red)** — 攻擊性資安的 Claude Skills 集合（78 個 skill、23 類）。⚠️ 高度雙重用途，僅限授權測試。MIT。
- **程式碼漏洞研究 / 弱點掃描**
    - **[open-kritt](https://github.com/Kritt-ai/open-kritt)** — 自架的 AI 漏洞研究平台：把研究拆成小任務，交給 Codex／Claude Code 平行執行，再驗證、排序與去重。AGPL-3.0。
    - **[Nuclei](https://github.com/projectdiscovery/nuclei)**（ProjectDiscovery）— 以 YAML 模板為基礎的弱點掃描器，支援以 AI prompt 產生模板與 LLM 語意比對。MIT。（原清單誤拼為「nulcei」）
    - **[Nuclei MCP](https://github.com/addcontent/nuclei-mcp)** — 第三方 MCP server，讓 AI 呼叫 Nuclei 掃描與管理模板。⚠️ 早期專案，README 有佔位符連結。MIT。
    - **[OWASP CVE Lite CLI](https://github.com/OWASP/cve-lite-cli)** — 本機執行的 JS/TS 相依套件弱點掃描，直接給出修正指令；支援 SARIF、SBOM、離線模式。本身不是 AI 工具。MIT。
- **AI agent 安全規格 / 治理**
    - **[Foundry Security Spec](https://github.com/CiscoDevNet/foundry-security-spec)**（Cisco）— 打造 agentic 安全評估系統的開放規格：8 個核心 agent 角色、11 條憲章原則，搭配 spec-kit 產生實作。不是現成工具。CC BY 4.0。
    - **[yao-meta-skill / security](https://github.com/yaojingang/yao-meta-skill/tree/main/security)** — skill 製作工具 yao-meta-skill 的供應鏈安全政策：網路、檔案寫入、子程序權限核准與發布前信任報告。MIT。
- **LLM 測試 / 紅隊**
    - **[Promptfoo](https://github.com/promptfoo/promptfoo)** — LLM 應用的評測、回歸測試與紅隊工具。
    - **[DeepEval](https://pypi.org/project/deepeval/)**（Confident AI）— 像 Pytest 的 LLM 評測框架：30 多種指標涵蓋 agent 軌跡、RAG、多輪對話、MCP，可放進 CI。評測為主、紅隊不是重點。Apache-2.0。

---

## 🧩 模型

- **本地可跑的通用 / 推理模型**
    - **[Bonsai 2](https://huggingface.co/collections/prism-ml/bonsai-2)**（PrismML）— Qwen3.8-27B 的三值（ternary）壓縮版，體積約為原本 1/9、保留約 98% 表現，可在本機跑。Apache 2.0。
    - **[Qwythos-9B](https://huggingface.co/empero-ai/Qwythos-9B-Claude-Mythos-5-1M-GGUF)**（Empero AI）— 以 Qwen3.5-9B 為底後訓練的推理模型，提供 GGUF，可用 Ollama / LM Studio 跑。
- **程式碼模型**
    - **[FrogNano-4B-2609](https://huggingface.co/microsoft/FrogNano-4B-2609)**（Microsoft）— 從 Qwen3.5-4B 經 RL 訓練的小型程式代理模型，需搭配 Leaf 工具框架；官方自報 SWE-bench Verified 61.5%。
    - **[Mellum2](https://huggingface.co/blog/JetBrains/mellum2-launch)**（JetBrains）— 12B MoE（每 token 啟用 2.5B），適合路由、RAG、子 agent 與私有部署。Apache 2.0。
- **端側小模型**
    - **[Needle](https://github.com/cactus-compute/needle)**（Cactus Compute）— 給手機、穿戴裝置、機器人用的超小型工具呼叫模型，可在本機微調。
- **Embedding**
    - **[EmbeddingGemma 2](https://huggingface.co/google/embeddinggemma-2)**（Google）— 740M 多模態 embedding，文字／圖片／音訊／影片映射到同一向量空間，可端側執行。Apache 2.0。
- **影像生成**
    - **[Qwen-Image-2.1](https://huggingface.co/Qwen/Qwen-Image-2.1)** — 7B 文生圖 + 圖像編輯，支援原生透明 RGBA。⚠️ 授權改為 Qwen Research License（非商用），與先前 Apache 2.0 的版本不同。
- **影片生成**
    - **[Index-AniSora](https://github.com/bilibili/Index-anisora)**（bilibili，IJCAI'25）— 開源動漫影片生成模型：圖生影片、角色 360 度旋轉、任意幀推論、風格轉換、多模態引導。Apache 2.0。⚠️ 原清單連到 [cnb.cool 的第三方鏡像](https://cnb.cool/dfdfsd/anisora)，缺 V3，建議改用官方 repo。
- **工具 / 修正檔**
    - **[Qwen Fixed Chat Templates](https://huggingface.co/froggeric/Qwen-Fixed-Chat-Templates)** — 修正版的 Qwen chat template（依名稱判斷）。

---

## ⚙️ 推論與訓練引擎

- **[Strata](https://github.com/Niko1221/Strata)** — 在消費級顯卡上跑大型 MoE 模型的本地推論引擎，把專家權重分層放在 VRAM / RAM。MIT。
- **[Unsloth](https://github.com/unslothai/unsloth)** — 快速、省顯存的 LLM 微調函式庫。

---

## 📚 學習資源

- **[Learn Docker and K8s](https://github.com/ericboy0224/learn-docker-and-k8s)** — Docker 與 Kubernetes 學習教材。
- **[Learn Harness Engineering](https://github.com/walkinglabs/learn-harness-engineering)** — 從零到一的 Harness Engineering 課程：如何替 AI coding agent 打造可靠的工作環境（講義 + 實作專案）。

---

## 📝 這次整理改了什麼

- 合併重複的分類（Robotic / Robotics）與重複項目（Hyperframe 出現兩次）。
- CrewAI、Pipecat 從 Video 移到 Agent 框架。
- 把以 Jev 為核心的工具集中成一區，方便一起比較。
- 修正 quackd 的描述（Microduck，而非 LeRobot）；TheLongSilence 標明收錄的是裡面的 Blender 硬表面 skill。
- 移除 Hyper3D 連結裡的廣告追蹤參數。
- 補上 Qwen-Image-2.1、onetake 的授權提醒。
- 「待確認」區的 OpenSlide 原本連到數位病理函式庫，已更正為簡報框架 [open-slide](https://github.com/open-slide/open-slide)，移回設計 / 前端。
- 資安區新增 7 項：open-kritt、Nuclei、Nuclei MCP、Pentest Swarm AI、Claude-Red、OWASP CVE Lite CLI、Foundry Security Spec，以及 yao-meta-skill 的 security 政策。
- 影片製作新增 6 項：Remotion、Cinetic、ChatCut、Palmier Pro、Higgsfield MCP、hook-lab；設計 / 前端新增 GSAP Skills、Hairline。
- 影片製作新增 2 項：OpenDirector、AutoMV。
- 影片製作新增 ViMax、PenShot；模型新增「影片生成」小類（Index-AniSora）；資安的 LLM 測試區新增 DeepEval。
