# SO-101 Bench

- **分類**：機器人與具身智慧 / 基準測試
- **連結**：https://github.com/5hadytru/so101_bench
- **官網**：https://so101-bench.github.io
- **排行榜**：https://so101-bench.github.io/leaderboard/
- **論文**：https://arxiv.org/abs/2610.36420
- **資料集**：https://huggingface.co/datasets/5hadytru/so101_bench_sim（模擬示範）・https://huggingface.co/datasets/5hadytru/so101_bench_real（實機示範）・https://huggingface.co/datasets/5hadytru/so101_bench_assets（USD 資產）

## 原清單說明

（使用者新增，無原清單說明。使用者提供的來源為 AI郵報的介紹文與 arXiv 論文。）

> **查證結果**：論文標題 *SO-101 Bench: Accessible Spatial Manipulation*，作者僅 Truman Hickok 一人（未標所屬單位），2026-10-27 投稿 arXiv（cs.CV，v1，論文 CC BY 4.0）。作者於 2026-10-28 在 X 宣布 v1。程式碼 Apache-2.0。

## 概述

SO-101 Bench 是一個以低價 SO-101 手臂（TheRobotStudio SO-ARM100 系列，介紹文估手臂本體約 120 美元）為對象的**語言條件空間操作基準**。作者先在真實桌面上架好一台 SO-101，再在 Isaac Lab 裡做出它的數位分身（real-to-sim-to-real），讓不同的機器人策略在同一個模擬環境、同樣的訓練預算下比較。

它想回答兩個問題：

1. **模擬排名能不能代表實機排名？** 五個只用模擬資料訓練的策略，在 45 個對應的佈局上分別跑模擬與實機（實機在沒見過的環境），排名完全一致（Spearman ρ = 1.00、MMRV = 0.000）。但模擬會**高估**絕對成功率。
2. **「LLM agent 寫程式 + VLA 抓取」比純 VLA 好嗎？** 九個 VLA／世界動作模型（WAM）最好約 61%，而讓 LLM 寫 Python 控制手臂、把抓取交給學到的策略的 agent 組合拿到 83.2%。作者把差距歸因於 harness 與 LLM 的選擇。

## 核心功能／特色

- **四種任務、五個計分類別**：放進容器（分 1 個物體與 4 個物體兩種）、放在旁邊、放在兩者之間、往某方向移動。
- **138 個物體、三種泛化切分**：見過的 48 個、沒見過的同類實例 43 個、沒見過的類別 47 個。
- **主評測 916 個 episode**：分數是 15 個「任務類別 × 物體切分」格子的平均成功率，附 95% bootstrap 信賴區間；另有 ROBUST（穩健性）、PLAN（規劃）、MEM（記憶）子集，和主評測重疊，不能相加。
- **測試集保持乾淨**：主評測用到的未公開類別物體、背景與機器人顏色都沒有釋出；公開的是 135 個 episode 的驗證集（`tasks/val_set.jsonl`），給開發、選 checkpoint 與公開比較用。
- **同等訓練預算**：3,629 筆模擬示範（約 18.5 小時）用來微調所有學習型策略；論文寫主要策略在 4× A100 80GB 上微調 36 小時，以 39 個保留驗證 episode 選 checkpoint。另有約 4,400 筆（約 20 小時、約 35 個物體）實機遙操作示範（HF 資料集卡片寫 4,367 個 episode），介紹文提醒要當成獨立來源看待。兩個資料集都是 LeRobot v3.0 格式、30 fps、俯視與腕部兩支相機。
- **附全部基線**：每個排行榜策略都有 policy server（`scripts/*_server.py`）、微調配方（`scripts/*_fine_tuning/`）與 Hugging Face 上的微調 checkpoint。
- **LeRobot 整合**：`lerobot-eval --env.type=so101_bench` 可對任何 LeRobot 策略跑同樣的 episode。

### 排行榜（主評測 916 episode，2026-11-08 查詢 live CSV）

| 策略 | 類型 | 分數（95% CI） |
|---|---|---|
| GPT-6.1 Sol + PyRUA-Lean v9.6 + Galaxea 0.5 | LLM agent + VLA | 83.2（80.7–85.7） |
| DeepSeek V4.1 Flash (1017) + PyRUA-Lean v9.6 + Galaxea 0.5 | LLM agent + VLA | 66.8（63.8–70.0） |
| InternW0-Δ | WAM | 61.4（58.5–64.0） |
| Galaxea 0.5 | VLA | 60.8（57.8–63.6） |
| NVIDIA GR00T N1.7-3B | VLA | 45.8 |
| ImageWAM-FLUX.2-4B | WAM | 43.0 |
| Physical Intelligence π0.5 | VLA | 41.0 |
| LaWAM | WAM | 39.9 |
| Ai2 MolmoAct2（base） | VLA | 23.8 |
| Ai2 MolmoAct2-SO100_101 | VLA | 20.9 |
| FLUX 3 Action SO-101 LoRA | WAM | 8.0 |

各策略在「沒見過的類別」與 PLAN 子集上掉分最明顯，論文也把空間擺放、沒見過的物體類別與「旋轉才能放進去」的規劃列為尚待解決的挑戰。

介紹文另外引用一組 60 episode 的消融（PyRUA-Lean + Galaxea，只換 LLM）：Sol 85%、Argon 77%、DeepSeek 65%、MiMo 55%。這組和主評測用的是不同評測集，不能直接和上表比排名。

## 技術架構或運作原理

- **模擬**：Isaac Sim 5.1 + Isaac Lab，benchmark 本身是一個 Isaac Lab extension（`source/so101_bench`：環境、任務、計分、物體目錄、佈局）。
- **策略介面**：評測器透過 HTTP 呼叫策略伺服器 —— `POST /act` 送出俯視與腕部相機影像（base64 PNG）、語言指令與 6 維關節狀態，回傳一段關節位置動作（action chunk）。所以任何框架的策略只要包一層 server 就能接上。
- **LLM agent 路線**：`scripts/pyrua_eval.py` 讓 PyRUA-Lean（DAGroup-PKU 的 agent harness）以「策略」身分作答：每步收到相機影像、相機校正與關節狀態，寫 Python 下關節目標（30 Hz），抓取交給 Galaxea 0.5。LLM 思考時物理模擬會暫停，所以 agent 影片的播放速度不代表真實任務時間。評測時關掉了 Codex 的 shell、exec、網頁搜尋等工具，只留 PyRUA-Lean 的 `python` 與 `finish`。
- **Sim-to-real 檢驗**：`tasks/` 內附 sim2real（MMRV）佈局集與實機 runner。論文另有一組 GR00T N1.6 的「只用實機資料 vs 只用模擬資料」比較（15 格的 Pearson r = 0.86、Spearman ρ = 0.74；模擬 45% 對實機 61%），但它同時改了訓練來源與測試領域，不能和五策略實驗直接比。

## 安裝與使用方式

需要 Isaac Sim 5.1 與 Isaac Lab（官方測試環境：Isaac Lab 0.54、Python 3.11、一張 RTX GPU）。

```bash
git clone https://github.com/5hadytru/so101_bench && cd so101_bench
~/IsaacLab/isaaclab.sh -p -m pip install -e source/so101_bench
~/IsaacLab/isaaclab.sh -p scripts/download_assets.py      # 約 2 GB 的 USD 資產（來自 Hugging Face）
```

在公開驗證集上評測一個策略（以 Galaxea 0.5 為例）：

```bash
# 1. 啟動策略伺服器
python scripts/g05_server.py --repo /path/to/GalaxeaVLA \
    --ckpt_path /path/to/so101_bench_G0.5_full_fine_tune/checkpoints/model_state_dict.pt \
    --mode ar --replan_steps 15 --port 8000

# 2. 跑 episode（完整參數見 README，各基線的 action_horizon 等設定不同）
~/IsaacLab/isaaclab.sh -p scripts/molmoact2_eval.py --headless \
    --episodes_jsonl tasks/val_set.jsonl --episode_layouts_jsonl tasks/layouts/val_set_layouts.jsonl \
    --policy_port 8000 --action_horizon 15 --policy_cameras overhead,wrist ... 2>&1 | tee outputs/val_eval.log

# 3. 計分（15 格平均 + 95% bootstrap CI）
python scripts/score_eval.py --tasks tasks/val_set.jsonl --log outputs/val_eval.log
```

用 LeRobot 評測（LeRobot 需 Python ≥ 3.12，所以外掛會把模擬器開成獨立行程）：

```bash
pip install -e integrations/lerobot            # 在 LeRobot 環境裡
export SO101_BENCH_ROOT=$PWD ISAACLAB_SH=~/IsaacLab/isaaclab.sh
lerobot-eval --env.type=so101_bench --policy.path=5hadytru/so101_bench_pi05 \
    --env.cameras=overhead,wrist,overhead_init,wrist_init --eval.n_episodes=1
```

上排行榜：把 checkpoint 與 policy server（或一個 endpoint）寄給作者，由作者跑 916 episode 的主評測後公布。

## 適用情境

- 手上有 SO-100／SO-101 或 LeRobot 生態的策略，想在**同一個可重現的模擬環境**和 π0.5、GR00T、Galaxea 等模型比較。
- 研究**語言條件的空間關係操作**（旁邊、之間、方向）與對沒見過物體類別的泛化。
- 研究 **LLM agent + 底層 VLA** 的分工，或比較不同 LLM 當高層規劃者的效果（可搭配 PyRUA-Lean）。
- 想用**模擬排名預測實機排名**、少跑一些實機評測。

## 授權與成本

- 程式碼：Apache-2.0；源自 Isaac Lab extension 範本的檔案保留 BSD-3-Clause；`scripts/*/patches/` 下的修補檔依各第三方 repo 的授權。
- Hugging Face 上的資料集、資產與 checkpoint 依各自卡片的條款（微調 checkpoint 繼承基礎模型的授權）。⚠️ 查詢當下（2026-11-08）三個資料集卡片都沒有標授權，用在商業用途前最好先問作者。
- 論文：CC BY 4.0。
- 軟體免費；跑模擬需要一張 RTX GPU，微調基線要大得多的算力（論文為 4× A100 80GB、36 小時）。手臂約 120 美元的估價不含電腦、GPU、相機整合與模型推論的成本。

## 限制與注意事項

- **模擬高估成功率**：排名在實機上保持，但絕對成功率要上實機才知道。而且 sim-to-real 排名一致只驗證了 5 個策略、45 個佈局。
- **單一作者、主評測只由作者跑**：測試集不公開，排行榜分數需要把 checkpoint 交給作者評測；結果只適用於所述的設定、模型與訓練預算。
- **83.2% 的 agent 用的是 GPT-6.1 Sol**，屬於閉源 API，要重現需要對應的模型存取權；不同評測集上的數字（例如 60 episode 消融）不能和主評測混著比。
- **環境綁 Isaac Sim 5.1 / Python 3.11**，和 LeRobot（Python ≥ 3.12）不相容，所以 LeRobot 整合是用獨立行程繞過去。
- repo 建立於 2026-05-13，查詢當下（2026-11-08）約 44 顆星、2 個 fork，最後 push 為 2026-11-04；沒有正式 release，屬於早期專案。
- 介紹文提到有 v0 版本，這次未查證 v0 與 v1 的差異（資料不足）。

## 相關工具

- [LIBERO](LIBERO.md)（另一個常用的操作基準，建立在 robosuite／MuJoCo，七軸手臂）
- [uni-robot-agent](uni-robot-agent.md)（同樣研究 robot-use agent harness 與 Hybrid 模式；它的 RoboLab 也用 Isaac Lab。PyRUA-Lean 是 DAGroup-PKU 的另一個專案，兩者關係未查證）
- [quackd](quackd.md)（用 LLM 指揮機器人，有提到可接 LeRobot SO-101 手臂）
- Isaac Lab／Isaac Sim（底層模擬）、LeRobot（評測整合）

## 資料來源

- https://www.aiposthub.com/so101-bench-v1-sim-real-ranking-agent-policy/
- https://arxiv.org/abs/2610.36420
- https://github.com/5hadytru/so101_bench
- https://raw.githubusercontent.com/5hadytru/so101_bench/main/README.md
- https://raw.githubusercontent.com/5hadytru/so101_bench/main/scripts/pyrua_eval.py
- https://api.github.com/repos/5hadytru/so101_bench
- https://so101-bench.github.io/leaderboard/
- https://so101-bench.github.io/data/live-leaderboard.csv
- https://arxiv.org/html/2610.36420v1
- https://huggingface.co/5hadytru
- https://huggingface.co/datasets/5hadytru/so101_bench_sim
- https://huggingface.co/datasets/5hadytru/so101_bench_real
