# AI tool list（重新分類版）

> 依「用途」重新分組，每項附一句說明。整理日期：2026-10-14。
> 標 ⚠️ 的是需要留意的地方；標「（依名稱判斷）」的是查不到詳細資料、只能從名稱推測的項目。

---

## 🤖 機器人與具身智慧

- **研究**
    - **[ARC](https://arc-robot-reasoning.github.io/)** — 機器人基礎模型的推理訓練法：自動替既有示範資料標註「以動作為依據的因果推理」，再微調 π0.5 等 VLA，不需收新示範。程式碼與模型待釋出。
    - **[SpatialClaw](https://github.com/NVlabs/SpatialClaw)**（NVIDIA，NeurIPS 2026）— 以「寫程式」當動作介面的空間推理 agent：VLM 在持久 Jupyter kernel 裡呼叫 SAM3、Depth-Anything-3 等感知工具，免訓練。
- **模擬**
    - **[MuJoCo](https://github.com/google-deepmind/mujoco)** — DeepMind 的物理模擬引擎，機器人與強化學習的標準模擬器。
- **LLM 控制**
    - **[quackd](https://github.com/rokbenko/quackd)** — 用自然語言 + LLM 指揮 Pollen Robotics 的 Microduck 雙足小機器人，內建模擬器與 MCP。⚠️ 原清單標為 LeRobot，實際針對的是 Microduck。

---

## 🧊 3D 建模與生成

> 開放權重的 3D 生成模型依用途收在這裡，不放「🧩 模型」。

- **CAD / 參數化建模**
    - **[FreeCAD MCP](https://github.com/neka-nat/freecad-mcp)** — 讓 AI 透過 MCP 操作 FreeCAD。
    - **[Rhino MCP](https://github.com/jingcheng-chen/rhinomcp)** — 讓 AI 透過 MCP 操作 Rhino。
    - **[MAC – Multi-Agent CAD](https://github.com/Pan-Chera/Multi-Agent-CAD)** — 四個 agent 分工的 text-to-CAD（build123d），直接輸出可列印的 STEP/STL，token 用量約為單一 agent 的 1/116。
    - **[USD BRep](https://github.com/NVIDIA-Omniverse/usd-brep)** — NVIDIA Omniverse 開源的 NURBS BRep 實體建模函式庫（C++／Python），可原生匯入匯出 OpenUSD；附 text-to-3D 資產生成的 agent skill。
- **Blender × Agent**
    - **[cc-blender-skill](https://github.com/RobLe3/cc-blender-skill)** — Claude Code skill 外掛，經 Blender MCP 用自然語言建模、上材質、打光、運鏡、渲染、做動畫與匯出。
    - **[MCP for Blender](https://github.com/ahujasid/mcp-for-blender)** — 社群版 Blender MCP（原 blender-mcp），讓任何 LLM 在執行中的 Blender 裡用提示詞建模與搭場景。
    - **[TheLongSilence](https://github.com/achimala/TheLongSilence)** — Claude Opus 5 做的瀏覽器太空探索遊戲；repo 裡附有 `.claude/skills/blender-hardsurface` 硬表面建模 skill（原清單收錄的應是這個）。
- **OpenUSD / Omniverse × Agent**
    - **[Kit USD Agents](https://github.com/NVIDIA-Omniverse/kit-usd-agents)** — NVIDIA 官方 Chat USD（白話編輯 Omniverse USD 場景）＋ USD／Kit／OmniUI／Isaac Sim 開發用 MCP 伺服器。
- **AI 生成 3D 資產**
    - **[Hyper3D（Rodin）](https://hyper3d.ai/)** — AI 生成 3D 模型。（已移除原連結的廣告追蹤參數）
    - **[TRELLIS.2](https://github.com/microsoft/TRELLIS.2)** — Microsoft 開源 4B 參數圖片生成 3D 模型，產出含完整 PBR 材質的 GLB（MIT；⚠️ 相依的 nvdiffrast／nvdiffrec 限非商業）。
    - **[Hunyuan3D 2.1](https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1)** — 騰訊開源圖片生成 3D 系統，形狀＋PBR 貼圖兩階段（⚠️ 社群授權，排除歐盟／英國／南韓）。
    - **[Stable Fast 3D](https://github.com/Stability-AI/stable-fast-3d)** — Stability AI 單圖約 0.5 秒重建已展 UV 的貼圖網格（⚠️ 社群授權，年營收超過 100 萬美元須企業授權）。
    - **[Meshy MCP Server](https://github.com/meshy-dev/meshy-mcp-server)** — Meshy 官方 MCP，讓 agent 生成 3D、重新網格化、重新貼圖、綁骨、做動畫與 3D 列印處理（需付費 API）。
- **AI 生成 3D 世界**
    - **[World Labs](https://www.worldlabs.ai/)** — 生成可探索 3D 世界的服務（Marble）。
    - **[HY-World 2.0](https://github.com/Tencent-Hunyuan/HY-World-2.0)** — 騰訊混元 3D 世界模型，文字／圖片生成可走動的 3D 世界，也能從照片影片重建（⚠️ 排除歐盟／英國／南韓）。
- **3D 重建與高斯點雲**
    - **[3D Gaussian Splatting for model city](https://github.com/rakeshsuthar6322/3d_gaussian_splatting_for_model_city)** — 手機繞拍影片 → COLMAP + Nerfstudio 訓練 3DGS → 輸出 PLY／USDZ，再生成碰撞網格放進 Isaac Sim 的實景數位分身管線。⚠️ 未附授權檔。
    - **[SuperSplat](https://github.com/playcanvas/supersplat)** — 瀏覽器內檢視、編輯、最佳化並發布 3D 高斯點雲的開源編輯器。

---

## 🎬 影片製作

- **Agent 影片製作系統（從主題到成片）**
    - **[OpenMontage](https://github.com/calesthio/OpenMontage)** — 開源 agentic 影片製作系統，把 Claude Code / Cursor 變成影片工作室；多條 pipeline（解說動畫、預告片、紀錄片、Podcast 剪片、多語配音…），可接本地 ComfyUI。AGPL-3.0。
    - **[MoneyPrinterTurbo](https://github.com/harry0703/MoneyPrinterTurbo/blob/main/README-en.md)** — 輸入主題，自動產生文案、素材、字幕、配音與背景音樂的短影音生成器。
    - **[video-autopilot-kit](https://github.com/Hao0321/video-autopilot-kit)** — YouTube／短影音自動化框架（繁中文件）：長片、Shorts、訪談三條產線，ffmpeg QA，問卷式填入自己頻道的設定。
    - **[AI video drama platform](https://github.com/dc-tw/ai-video-drama-platform)** — 非常早期的 AI 短劇實驗專案：故事大綱 → LLM 結構化分鏡 → ComfyUI 產圖 → FFmpeg 合成，目前只是後端骨架。⚠️ 未附授權檔。
    - **[OpenDirector](https://github.com/seme-org/open-director)** — 自架的 AI 影片工作室：一句話 → 9 個 agent 產出故事、分鏡、角色、配音與配樂並渲染；另有批次量產短影音模式。Docker 部署。LGPL-3.0。
    - **[AutoMV](https://github.com/multimodal-art-projection/AutoMV)**（M-A-P，arXiv 2512.12196）— 輸入整首歌生成長篇 MV 的多 agent 系統：音樂分析 → 編劇／導演 agent → 關鍵幀與影片生成（含對嘴）→ 驗證。依賴豆包、即夢、Gemini 等 API。Apache-2.0。
    - **[ViMax](https://github.com/HKUDS/ViMax)**（港大 HKUDS，arXiv 2606.07649）— 點子／劇本／小說 → 編劇、導演、製片 agent → 逐鏡生成長片；可把自己的照片放進故事（AutoCameo），有 TUI 與 Web UI。MIT。
    - **[PenShot](https://pypi.org/project/penshot/)**（[原始碼](https://github.com/neopen/story-shot-agent)）— 劇本分鏡 agent：把任何劇本拆成鏡頭片段，輸出給 Sora／Veo／可靈用的中英提示詞與音訊提示詞，角色跨片段一致；有 SDK、REST、MCP。不直接出影片。MIT。
- **程式化影片（程式碼 → 影片）**
    - **[Remotion](https://github.com/remotion-dev/remotion)** — 用 React 元件寫影片的老牌框架，有官方 agent skills；也是 Cinetic、OpenMontage 的渲染引擎。⚠️ 自訂授權：個人與 3 人以下公司免費，較大的公司需付費。
    - **[HyperFrames](https://github.com/heygen-com/hyperframes)**（HeyGen）— 寫 HTML/CSS/動畫，渲染成確定性 MP4，專為 AI agent 設計。Apache-2.0。
    - **[Manim](https://github.com/3b1b/manim)**（3Blue1Brown）— 用 Python 寫精準數學動畫的引擎（ManimGL，`pip install manimgl`），3Blue1Brown 影片的製作工具；另有社群版 [Manim CE](https://github.com/ManimCommunity/manim)，兩版不相容。本身不是 AI 工具。MIT。
    - **[Cinetic](https://github.com/Leonxlnx/cinetic)** — 讓 coding agent「導演」短片的 skill：先構思故事，再定品牌、配樂、渲染，最後由多個評審角色檢查。MIT。
    - **[onetake](https://github.com/feitangyuan/onetake)** — Claude Agent Skill，做「一鏡到底」的產品發表片、預告與功能演示動效。⚠️ PolyForm Noncommercial（非商用）。
    - **[PDoomVideo](https://github.com/JohnHeibel/PDoomVideo)** — Claude Opus 5.5 在 Claude Code 裡生成的音樂 MV 原始碼，可當程式化動畫參考。
- **剪輯 / 處理**
    - **[ffmpeg-skill](https://github.com/kajisho5/ffmpeg-skill)** — 給 coding agent 的本地 FFmpeg 剪輯 skill：剪接、字幕、響度、調色、平台交付檢查等 42 個工具，也可當 MCP。
    - **[ChatCut](https://github.com/ChatCut-Inc/agent-plugin)** — 線上對話式剪輯服務；agent-plugin 讓 coding agent 透過 MCP 直接改 ChatCut 雲端專案的時間軸。商業服務。
    - **[Palmier Pro](https://github.com/palmier-io/palmier-pro)** — 為 AI 打造的 macOS 剪輯軟體，內建 AI 生成並開放 MCP，agent 和人可以編輯同一條時間軸。⚠️ v0.7.6 之後改為專有授權。
- **AI 影片生成**
    - **[WanGP](https://github.com/deepbeepmeep/WanGP)** — 給低階顯卡的本機生成 App：一個網頁介面跑 Wan、LTX、Hunyuan Video、MiniMax H3 等影片模型，另含圖像、TTS 與 3D 模型，部分只要 6 GB VRAM；有 MCP server 與內建 agent Deepy。⚠️ WanGP Community License：免費、作品可商用，但不得轉售或提供付費服務。
    - **[Higgsfield MCP](https://higgsfield.ai/mcp)** — 讓 Claude 不需 API key 呼叫 30 多個圖像／影片模型，再串 Blender、After Effects，交付可繼續編輯的 AE 專案。商業服務。
    - **[Code Video Model](https://code-video-model.github.io/)** — 研究專案：文字 → 可編輯 Three.js 場景 → 代理影片 + 參考圖 → 影片模型生成，鏡位、動作、物理都能靠改程式控制。Apache-2.0。⚠️ 需 GPU 與多個外部模型／API。
- **影片理解**
    - **[claude-video（/watch）](https://github.com/bradautomates/claude-video)** — 讓 Claude「看」影片：下載、抽幀、轉錄後交給模型分析。
    - **[hook-lab](https://github.com/hongfamonvAI/hook-lab)** — Claude Code skill：拆解 TikTok／Reels／Shorts 的開場鉤子、腳本結構與爆紅原因，並給小紅書、視頻號的改寫方向。MIT。

---

## 🎨 設計 / 前端

- **網站設計提示詞**
    - **[MotionSites](https://motionsites.ai/)** — 給 Lovable、Bolt、Cursor、Claude 用的高質感（3D／動態）網站 prompt 庫，另有 MCP。
- **網頁動畫與插圖**
    - **[GSAP Skills](https://github.com/greensock/gsap-skills)**（GreenSock）— 官方給 coding agent 的 GSAP 動畫 skill 組：時間軸、ScrollTrigger、外掛與框架整合。MIT。
    - **[Hairline](https://github.com/lucasmarkes/hairline)** — 會回應滑鼠的細線等角互動插圖（React 元件），附 `hairline-create` skill 讓 agent 畫出風格一致的新圖形。MIT。
- **網頁 3D**
    - **[three.js](https://github.com/mrdoob/three.js)** — 網頁上最常用的 JavaScript 3D 函式庫，支援 WebGL／WebGPU，MIT。
    - **[threejs-skills](https://github.com/CloudAI-X/threejs-skills)** — 教 Claude Code 正確使用 three.js 的 10 個 skill，從 shader 到後製特效。⚠️ 未附 LICENSE 檔。
    - **[Anatomy](https://github.com/thebuggeddev/anatomy)** — 用 Three.js 做的互動式 3D 人體解剖瀏覽器（由 GPT 生成），偏參考作品而非工具。（原放在 3D 建模與生成）
- **簡報**
    - **[open-slide](https://github.com/open-slide/open-slide)** — 為 AI agent 打造的簡報框架：用自然語言描述，由 Claude Code 等 agent 寫 React 投影片，可匯出 HTML／PDF／PPTX。MIT。

---

## 🎵 音訊

- **[Basic Pitch](https://github.com/spotify/basic-pitch)**（Spotify）— 音訊轉 MIDI 的輕量模型。
- **[earshot](https://github.com/Leonxlnx/earshot)** — 給 coding agent 的「耳朵」：描述、比對、搜尋、檢查聲音與影片的聲畫同步，也能用程式碼做音效；本機 CPU 執行，有 CLI 與 MCP server。Cinetic 同作者。MIT。

---

## 🧠 Agent 框架與編排

- **框架**
    - **[DSPy](https://github.com/stanfordnlp/dspy)** — 用「寫程式」而非手調 prompt 來建構與最佳化 LLM 管線。
    - **[CrewAI](https://github.com/crewAIInc/crewAI)** — 多 agent 角色協作框架。（原放在 Video，已移到這裡）
    - **[Pipecat](https://github.com/pipecat-ai/pipecat)** — 即時語音／多模態對話 agent 框架。（原放在 Video，已移到這裡）
- **Coding agent**
    - **[Cline](https://github.com/cline/cline)** — VS Code 裡的自主 coding agent。
- **Coding agent 外掛與 skill 組**
    - **[Claude Octopus](https://github.com/nyldn/claude-octopus)** — Claude Code 外掛，讓 Codex、Gemini 等多個模型交叉審查、辯論，有共識閘門。
    - **[pstack](https://github.com/michael-denyer/pstack-claude)** — Cursor pstack skill 組的移植版，支援 Claude Code、Codex、Copilot、Pi：`poteto-mode` 依任務挑流程，搭配多模型審查（arena、interrogate）、PR 照顧與自我改進 skill。MIT。
    - **[agency-agents](https://github.com/msitarzewski/agency-agents)** — 各種專業角色的 agent 人設集合。
    - **[Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios)** — 把 Claude Code 變成遊戲工作室：49 個 agent、74 個 skills，涵蓋設計、架構、QA 到發行。
    - **[yao-meta-skill](https://github.com/yaojingang/yao-meta-skill)** — 建立、評測、打包與治理 agent skill 的 meta-skill（「Skill OS」），附 skill 供應鏈安全政策（[security/](https://github.com/yaojingang/yao-meta-skill/tree/main/security)）：網路、檔案寫入、子程序權限核准與發布前信任報告。MIT。（原放在資安）
- **知識庫 / 文件問答**
    - **[AnythingLLM](https://github.com/Mintplex-Labs/anything-llm)** — 一體化本地 LLM 應用：文件 RAG 對話、agent，可接各家模型。
    - **[RAG-Anything](https://github.com/HKUDS/RAG-Anything)**（HKUDS）— 建在 LightRAG 上的多模態 RAG 框架：解析 PDF／Office／圖片中的文字、圖、表格、公式，建成多模態知識圖譜做混合檢索。Python 函式庫，可接本機模型。MIT。
    - **[notebooklm-py](https://github.com/teng-lin/notebooklm-py)** — 非官方 NotebookLM Python API／CLI／agent skill：讓 Claude Code 等 agent 操作 NotebookLM 問答、生成 podcast／簡報／測驗並批次下載。
- **LLM 評測**
    - **[DeepEval](https://pypi.org/project/deepeval/)**（Confident AI）— 像 Pytest 的 LLM 評測框架：30 多種指標涵蓋 agent 軌跡、RAG、多輪對話、MCP，可放進 CI。評測為主、紅隊不是重點。Apache-2.0。（原放在資安）

---

## ⚡ Jev 決策模型生態

> Jev 是 TypeSafe 的「System One」決策模型：對封閉式問題（是非、選擇、評分）一次回傳帶機率的結構化決策，而不是生成文字。下面這組都是圍繞它的工具。

- **用 Jev 做事的工具**
    - **[fast-jev-compaction](https://github.com/tamaratran/fast-jev-compaction)** — Claude Code 外掛：用 Jev 判斷哪些工具呼叫／結果已過時並刪掉，取代摘要式壓縮，保留下來的內容維持原文。
    - **[jevgrep](https://github.com/dzhng/jevgrep)** — 「問它做什麼」就能找到相關程式碼的 CLI，給 coding agent 用。
    - **[Jev Ultrafast](https://github.com/browser-use/jev-ultrafast)**（Browser Use）— 由 Jev 選操作與目標元素的極速瀏覽器 agent。
    - **[edgextract](https://github.com/raphaelmansuy/edgextract)** — 用自訂本體（ontology）+ 封閉式是非決策，把 markdown 轉成知識圖譜，不確定的項目送人工審核。
- **自架的 Jev 式決策模型**
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
    - **[REA](https://github.com/morluto/rea)** — 「Reverse Engineer Anything」：透過 MCP／CLI 讓 agent 逆向分析原生二進位、Electron、.NET、APK、WASM、韌體等目標並附證據；原生分析可用 Hopper、Ghidra 或 IDA。
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
- **LLM 測試 / 紅隊**
    - **[Promptfoo](https://github.com/promptfoo/promptfoo)** — LLM 應用的評測、回歸測試與紅隊工具。

---

## 🧩 模型

- **本地可跑的通用 / 推理模型**
    - **[Bonsai 2](https://huggingface.co/collections/prism-ml/bonsai-2)**（PrismML）— Qwen3.8-27B 的三值（ternary）壓縮版，體積約為原本 1/9、保留約 98% 表現，可在本機跑。Apache 2.0。
    - **[Qwythos-9B](https://huggingface.co/empero-ai/Qwythos-9B-Claude-Mythos-5-1M-GGUF)**（Empero AI）— 以 Qwen3.5-9B 為底後訓練的推理模型，提供 GGUF，可用 Ollama / LM Studio 跑。
    - **[Ornith 1.5](https://huggingface.co/ornith-ai/Ornith-1.5-35B-A3B-GGUF)**（DeepReinforce）— 開放權重家族（397B／35B-A3B MoE／9B，另有手機用 9B-Mobile），提供 9B 與 35B-A3B 的 GGUF（[9B](https://huggingface.co/ornith-ai/Ornith-1.5-9B-GGUF)），256K context，MIT。基準皆官方自報。
    - **[Mellum2](https://huggingface.co/blog/JetBrains/mellum2-launch)**（JetBrains）— 12B MoE（每 token 啟用 2.5B），適合路由、RAG、子 agent 與私有部署。Apache 2.0。
- **程式碼模型**
    - **[FrogNano-4B-2609](https://huggingface.co/microsoft/FrogNano-4B-2609)**（Microsoft）— 從 Qwen3.5-4B 經 RL 訓練的小型程式代理模型，需搭配 Leaf 工具框架；官方自報 SWE-bench Verified 61.5%。
- **資安模型**
    - **[OrcaCyber Nano 1.0](https://huggingface.co/orcarouter/OrcaCyber-Nano-1.0)**（OrcaRouter）— 27B 視覺語言資安模型，逆向、漏洞分析、程式碼審查、日誌分流，GGUF 可在 16 GB 顯卡本機跑，262K context。需登入 HF 同意條件下載，Qwen 授權。⚠️ 資安評測尚未公布，通用基準為官方自報。
- **端側小模型**
    - **[Needle](https://github.com/cactus-compute/needle)**（Cactus Compute）— 給手機、穿戴裝置、機器人用的超小型工具呼叫模型，可在本機微調。
- **Embedding**
    - **[EmbeddingGemma 2](https://huggingface.co/google/embeddinggemma-2)**（Google）— 740M 多模態 embedding，文字／圖片／音訊／影片映射到同一向量空間，可端側執行。Apache 2.0。
- **影像生成**
    - **[Qwen-Image-2.1](https://huggingface.co/Qwen/Qwen-Image-2.1)** — 7B 文生圖 + 圖像編輯，支援原生透明 RGBA。⚠️ 授權改為 Qwen Research License（非商用），與先前 Apache 2.0 的版本不同。
    - **[FLUX 3 Image Klein](https://huggingface.co/black-forest-labs/flux-3-image-klein)**（Black Forest Labs）— 5.6B 文生圖 + 圖像編輯，最多 10 張參考圖，支援 bounding box 排版；需搭配 prompt upsampler。⚠️ FLUX Kommunity License：非商用，年營收低於 US$500 萬者可商用輸出。
- **影片生成**
    - **[Index-AniSora](https://github.com/bilibili/Index-anisora)**（bilibili，IJCAI'25）— 開源動漫影片生成模型：圖生影片、角色 360 度旋轉、任意幀推論、風格轉換、多模態引導。Apache 2.0。⚠️ 原清單連到 [cnb.cool 的第三方鏡像](https://cnb.cool/dfdfsd/anisora)，缺 V3，建議改用官方 repo。
- **工具 / 修正檔**
    - **[Qwen Fixed Chat Templates](https://huggingface.co/froggeric/Qwen-Fixed-Chat-Templates)** — 修正版的 Qwen chat template（依名稱判斷）。

---

## ⚙️ 推論與訓練引擎

- **[Strata](https://github.com/Niko1221/Strata)** — 在消費級顯卡上跑大型 MoE 模型的本地推論引擎，把專家權重分層放在 VRAM / RAM。MIT。
- **[Strata Easy TW](https://github.com/encoreh78951-hub/StrataEasyTW)** — Strata 的非官方繁中 Windows 安裝導覽器：左側跑官方安裝腳本、右側中文解說，可選 SC117 第三方低拒答模型。MIT。⚠️ v1.3.0-rc1 為 pre-release，完整安裝流程尚未端到端驗證。
- **[Unsloth](https://github.com/unslothai/unsloth)** — 在本機執行與訓練 LLM 的開源框架，主打快速、省顯存的微調；除 Python 函式庫外另有 Studio 網頁介面與桌面版。
- **[Janas](https://github.com/prabanta-dev/janas)** — 純 C 的本地 MoE 推論引擎：權重留在 SSD、專家串流＋快取，可跑超過 RAM 的模型（如 Qwen3-Next-80B）。GPL-3.0+。⚠️ 實驗性質，僅在單一機器測過。

---

## 📚 學習資源

- **課程 / 教材**
    - **[Learn Docker and K8s](https://github.com/ericboy0224/learn-docker-and-k8s)** — 在 Claude Code、Cursor 等 AI 編輯器裡玩的互動式 Docker／Linux／網路／Kubernetes 學習遊戲，AI 扮演導師帶你解 DevOps 情境題（英文）。
    - **[Learn Harness Engineering](https://github.com/walkinglabs/learn-harness-engineering)** — 從零到一的 Harness Engineering 課程：如何替 AI coding agent 打造可靠的工作環境（講義 + 實作專案）。
    - **[EECS 498 AASE](https://github.com/eecs498-aase/materials)** — 密西根大學 2026 秋季「應用代理式軟體工程」課程教材：投影片、可自己跑的 Aider demo，以及 Elephant-Goldfish Model 五個 Agent Skills（英文；⚠️ 未附 LICENSE 檔）。
- **學習工具**
    - **[PaperRead](https://github.com/YuriyLin/PaperRead)** — 以繁體中文閱讀學術論文的研究工作區：論文探索、待讀看板、摘要、閱讀路徑、心智圖與 PDF 對照精讀；支援雲端與本地模型。MIT。

---

## 🎮 遊戲引擎 × Agent

- **桌面遊戲引擎**
    - **[Unity MCP](https://github.com/CoplayDev/unity-mcp)** — 讓 AI 用白話文操作 Unity 編輯器：建場景、寫 C# 腳本、管素材、跑測試與輸出 build（第三方，MIT）。
    - **[Godot AI](https://github.com/hi-godot/godot-ai)** — 用 46 個 MCP 工具控制執行中的 Godot 4.7+ 編輯器：場景、GDScript、訊號、UI、材質、粒子，還能跑遊戲驗證（第三方，MIT）。
    - **[Unreal Engine MCP](https://github.com/flopperam/unreal-engine-mcp)** — 控制執行中的 Unreal 5.5+ 編輯器：管理 Actor、程序化建構世界、編輯基礎 Blueprint（第三方，已被 Aura 收購；⚠️ 未附 LICENSE 檔）。
- **網頁遊戲引擎**
    - **[PlayCanvas Editor MCP](https://github.com/playcanvas/editor-mcp-server)** — PlayCanvas 官方 MCP：agent 在瀏覽器版 Editor 建場景，再自己啟動遊戲、截圖驗證真的能跑（MIT）。

- （另見 Agent 框架的 Claude Code Game Studios：用 Claude Code 走完整遊戲開發流程）
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
- 影片製作新增 Code Video Model；推論與訓練引擎新增 Janas。
- 影片製作新增 ViMax、PenShot；模型新增「影片生成」小類（Index-AniSora）；資安的 LLM 測試區新增 DeepEval。
- Agent 框架的 Coding agent 與外掛區新增 pstack。
- 模型的影像生成區新增 FLUX 3 Image Klein。
- 依 @davepoon128 的 Threads 貼文新增 14 項 3D 工作流工具：3D 建模與生成新增 MCP for Blender、Kit USD Agents、TRELLIS.2、Hunyuan3D 2.1、Stable Fast 3D、Meshy MCP Server、HY-World 2.0、SuperSplat，並把「AI 生成 3D / 世界」拆成「AI 生成 3D 資產」與「AI 生成 3D 世界」，「3D 重建」改為「3D 重建與高斯點雲」，新增「OpenUSD / Omniverse × Agent」小類；設計 / 前端新增「網頁 3D」（three.js、threejs-skills）；新增「🎮 遊戲引擎 × Agent」分類（Unity MCP、Godot AI、Unreal Engine MCP、PlayCanvas Editor MCP）。
- 分類總檢查：Anatomy 從 3D 建模與生成移到設計 / 前端的「網頁 3D」（移除「作品範例」小類）；yao-meta-skill（改收整個專案）與 DeepEval 從資安移到 Agent 框架與編排；Agent 框架拆成「Coding agent」「Coding agent 外掛與 skill 組」「知識庫 / 文件問答」（取代「本地應用」，notebooklm-py 移入）「LLM 評測」；影片製作的「程式化動畫 / HTML → 影片」改名「程式化影片（程式碼 → 影片）」，Higgsfield MCP 與 Code Video Model 合併為「AI 影片生成」；設計 / 前端、Jev 決策模型生態、學習資源補上小類；Mellum2 移到通用 / 推理模型；機器人的「研究 / 模型」改名「研究」；更新 AI video drama platform、3DGS for model city、REA、Unsloth、Learn Docker and K8s 的說明，補上 World Labs 連結。
- 推論與訓練引擎新增 Strata Easy TW。
- 影片製作的 AI 影片生成區新增 WanGP。
- 學習資源的課程 / 教材區新增 EECS 498 AASE。
- 模型新增「資安模型」小類與 OrcaCyber Nano 1.0。
- Agent 框架與編排的知識庫 / 文件問答區新增 RAG-Anything。
- 影片製作的程式化影片區新增 Manim。
- 音訊新增 earshot。
