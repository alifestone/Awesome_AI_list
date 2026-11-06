# uni-robot-agent

- **分類**：機器人與具身智慧 / LLM 控制
- **連結**：https://github.com/Open-RUA/uni-robot-agent

## 原清單說明

（Open-RUA，Tsinghua × UC Berkeley）— 開源的 robot-use agent harness：讓模型透過一致的觀察、工具與執行回報操作機器人。同一個 Qwen 模型換成這套框架後，RoboDojo 分數從 1.90 升到 31.39。

> **查證補充**：
>
> - 來源是 Threads 貼文（@aiposthub），引用共同作者 Yuxin Zuo 發布的架構與評測總覽圖。貼文沒有附連結；repo、論文與 PyPI 套件是另外找到的。
> - 「1.90 → 31.39」出自論文 Table 1：同一個 Qwen3.8-Flash-Next，在 RoboProbe harness 下是 SR 0.83／Score 1.90，在 uni-robot-agent 下是 SR 25.00／Score 31.39。中間還有 RPent（7.75）與 GAP Hybrid（21.01）兩個 harness 的數字。
> - 論文說主要結果不用深度；但 RoboProbe 那一列的觀察設定，這次讀到的部分沒有寫明（資料不足）。所以兩個數字的差距不一定全部來自 harness 本身。
> - RoboDojo Score 是 0～100 的分數，有算部分完成；SR 只算完整成功。貼文說的「進度分數」指的是 Score。
> - 和 [OpenRUA](https://github.com/terminalworld/OpenRUA)（terminalworld，arXiv 2610.02459，讓 coding agent 直接用終端機操作 ROS 2）是不同專案，論文只把它列在相關研究。

## 概述

uni-robot-agent 是 Open-RUA 團隊發表的機器人操作 agent harness，論文是〈Democratizing Robot-Use Agents: A Unified Harness with Open Models〉（arXiv 2611.01560，Jiarui Yuan、Yuxin Zuo 等 28 位作者，Tsinghua University 與 UC Berkeley，含 Pieter Abbeel）。

出發點是：現有的 robot-use agent（RUA）大多靠閉源前沿模型，研究者沒辦法繼續訓練。這個 harness 想讓開放權重模型也能有競爭力地操作機器人，並支援後續訓練。

論文報告：沒有特權輸入（例如模擬器深度或任務驗證器回饋）時，現成的 Qwen3.8-Flash-Next 在 RoboDojo 拿到 31.39，高於已發表的 GPT-6 Astra-RoboProbe 結果 28.97，也高於多個 VLA／WAM 基線；在 19 個真實世界任務上「表現有競爭力」。

## 核心功能／特色

四個設計原則：

- **Unified**：不同環境共用工具介面與回饋格式，原生 API 交給 adapter 處理。
- **Efficient**：agent 推理和工具執行重疊進行，但共用機器人資源的操作仍保持順序。
- **Realistic**：支援論文的純 RGB 設定，只用本體感知、相機校正與機器人描述，不把模擬器深度或任務驗證結果交給 agent。
- **Modular**：agent runtime、模型供應商、工具、環境與模型服務都能透過明確介面替換。

其他功能：

- **兩種動作模式**：Direct 直接用機器人工具；Hybrid 另外接上相容的動作模型，例如 Pi0.5。
- **Agent runtime**：內建 agent，也支援 Codex 與 Claude Code。模型端接任何 Responses API 相容的 endpoint。
- **Python SDK**：`Session.tools` 可以寫自己的控制策略；`RunRecord` 讀取存下的執行紀錄。
- **Dashboard**：`--monitor` 即時看相機畫面、tool call、執行時間與任務結果，也能重播存檔。

## 技術架構或運作原理

1. Agent backend（內建、Codex、Claude Code）或 Python SDK 發出 tool call。
2. Executor 排程這些呼叫：能平行的就重疊執行，共用資源的保持順序。
3. 共用的機器人工具透過獨立服務（例如可選的 SAM3）存取原生 backend。
4. 各環境的 adapter 把原生 API 轉成一致的觀察與執行回報。

論文分析不同世代、家族與大小的模型，把機器人操作能力連到四項一般能力：視覺理解、空間定位（spatial grounding）、幾何相關的寫程式能力、具身推理。作者建議未來訓練 RUA 時要同時強化這四項。

## 安裝與使用方式

需要 Linux GPU 主機與 Python 3.11 虛擬環境：

```bash
pip install uni-robot-agent        # 或 uv pip install uni-robot-agent
uni-robot-agent setup --integration robodojo

export UNI_ROBOT_AGENT_API_KEY='YOUR_API_KEY'
export UNI_ROBOT_AGENT_PROVIDER_URL='https://provider.example/v1'

uni-robot-agent run --integration robodojo --deploy local \
  --task stack_bowls --model YOUR_MODEL_ID \
  --action-profile direct --no-sam3 --output-dir ./runs --monitor

# 重播存檔
uni-robot-agent monitor --run-dir ./runs
```

- RoboDojo 預設開深度；要重現論文的純 RGB 設定，加 `--no-depth`。
- 目前版本 v0.1.1。

## 支援環境

| 類型 | 環境 | 說明 |
|---|---|---|
| 模擬 | RoboDojo | 雙臂操作，Direct 工具或 Hybrid Pi0.5 |
| 模擬 | RoboUse | 從 [LIBERO](LIBERO.md)、RoboCasa、MetaWorld、RoboSuite、ManiSkill 等挑選的任務，另有 Menagerie、Genesis 等 adapter |
| 模擬 | RoboLab | 單臂 DROID 任務，需另外準備 Isaac Sim／Isaac Lab |
| 實機 | ARX One、Franka | Coming soon |

## 適用情境

- 用開放權重模型做機器人操作 agent 研究，或拿 harness 產生資料做後續訓練。
- 公平比較不同模型：固定 harness，只換模型。
- 讓 Codex 或 Claude Code 當機器人操作 agent 的 runtime。
- 把 VLA（Pi0.5）當底層動作模型，上面加一層 LLM agent 規劃（Hybrid 模式）。

## 授權與成本

- **程式碼**：MIT。
- 上游 RoboDojo 程式碼、字型、外部素材與模型各自保留原授權。
- 套件免費；模型推論費用看你用的 endpoint。需要 GPU 跑模擬器。

## 限制與注意事項

- 實機整合還沒釋出；公開套件目前沒有支援的實體機器人連線流程。論文的 19 個真實任務（ARX AC One 雙臂 + 3 台 RealSense D405）暫時無法照著重現。
- 31.39 與 1.90 都是作者自行報告，還沒有獨立重現。
- RoboDojo 預設開深度，和論文主要結果（不用深度）的設定不同，比較分數前要確認。
- 專案很新：repo 2026-11-02 建立，這次查到約 248 顆星。
- GPT-6 Astra-RoboProbe 的 28.97 是引用已發表結果，不是同一套 harness 下的比較。

## 相關工具

- [quackd](quackd.md)（用 LLM 指揮機器人的 CLI）
- [LIBERO](LIBERO.md)（RoboUse 收錄部分任務）
- [MuJoCo](MuJoCo.md)（多數模擬環境的底層）
- [SpatialClaw](SpatialClaw.md)（同樣是「VLM + 感知工具」的 agent 路線）
- OpenRUA（terminalworld，coding agent 直接操作 ROS 2）

## 資料來源

- https://github.com/Open-RUA/uni-robot-agent
- https://arxiv.org/abs/2611.01560
- https://arxiv.org/html/2611.01560
- https://pypi.org/project/uni-robot-agent/
- https://www.threads.com/@aiposthub/post/DfUMoixAbBu/
