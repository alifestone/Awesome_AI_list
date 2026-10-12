# quackd

- **分類**：機器人與具身智慧 / LLM 控制
- **連結**：https://github.com/rokbenko/quackd

## 原清單說明

用自然語言 + LLM 指揮 Pollen Robotics 的 Microduck 雙足小機器人，內建模擬器與 MCP。⚠️ 原清單標為 LeRobot，實際針對的是 Microduck。

> **查證結果**：「⚠️」的說法只對了一半，兩者都有支援。
>
> - quackd 確實是最早為 Pollen Robotics 的 Microduck 打造的。
> - 但它不只支援 Microduck，也支援 LeRobot SO-101 手臂、Open Duck Mini v2、ROS 2 底盤、XLeRobot、AlohaMini、ToddlerBot 等，共 7 種 adapter。
> - 依 README，**目前唯一在真實硬體上跑過的是 LeRobot SO-101 手臂**（2026-09-15 與 2026-09-23）。實體 Microduck 還無法驅動，硬體 adapter 要等機器人出貨後才能使用。
>
> 所以原清單標為 LeRobot 並非錯誤，只是不完整。

## 概述

quackd 是一個 Apache-2.0 授權的命令列工具，可以從同一個地方控制多台機器人，每台機器人都由一個 LLM 負責做決策。使用流程如下：

1. 先用名稱註冊機器人。
2. 再用三種方式之一下達目標：終端機、透過 MCP 與 Claude 對話，或撰寫 `.duck` 任務檔。

運作時，LLM 每次從機器人的 manifest 中挑選一個技能（verb）執行。quackd 本身負責把關：允許哪些技能、最多走幾步、什麼時候需要人類確認。多台機器人可以組成「flock」來分工合作。

README 自述為「LLM driven, goal directed control of one real arm and six simulated or mocked bodies」。這是獨立的社群專案，明言「not affiliated with or endorsed by」Pollen Robotics、Hugging Face 或 Open Duck Mini 專案。

## 核心功能／特色

- **多機身 adapter**：
  - Microduck：Pollen Robotics 的雙足小鴨，約 25 cm、800 g。
  - Open Duck Mini v2：可 3D 列印的雙足機器人。
  - LeRobot SO-101 手臂：支援 real、mock、MuJoCo 三種後端。
  - 任何 ROS 2 底盤：透過 rosbridge 連接。
  - XLeRobot、AlohaMini、ToddlerBot。
- **內建模擬器**：
  - `sim2d`：卡通風格的 2D 場地，內建於核心，不需另外下載。
  - `microduck:mujoco`：MuJoCo 物理模擬，使用 `alpha_walking.onnx`。
  - `lerobot:mujoco`：用真實後端的程式碼模擬 SO-101。
- **MCP 伺服器**：`quackd serve-mcp` 透過 stdio 對外提供 9 個 `robot_*` 工具，README 列出其中幾個：`robot_load_duckfile`、`robot_run_verb`、`robot_list`、`robot_recall`、`robot_remember`。README 有 Claude Code 與 Claude Desktop 的設定方式，但也坦承目前還沒有 Claude Desktop 的實際使用紀錄。
- **支援多家 LLM**：
  - 雲端：Claude、OpenAI、Gemini、Grok、Mistral、DeepSeek、Cohere、Qwen、Kimi、GLM、Meta、OpenRouter。
  - 本地：Ollama、vLLM、llama.cpp、LM Studio，或任何 OpenAI 相容的伺服器。
  - 另有 `fake`：腳本化的駕駛，不需要 API key。
- **決策 LLM（選用）**：加上 `--decision-llm`，會在 LLM 前面放一個非生成式的 stepper。它只能從既有的 verb 中挑選，絕不會直接寫入關節角度。README 列出的選項有 Jev、Laya、Kev。
- **`.duck` 任務檔**：
  - YAML frontmatter 由 quackd 強制執行，可設定 `verbs` 的 allow／confirm 清單、`budgets`（步數、分鐘數、LLM 呼叫次數）、`success`、`abort_when`、`persona` 等。
  - Markdown 本文則交給模型閱讀。
  - 格式版本從 `duck: 0` 到 `duck: 3`。
  - 隨附 15 個範本，例如 `find-and-kick`、`follow-me`、`flock-kick`、`arm-grip-check`。
- **Flock 群體模式**：
  - pilot flock：每台機器人各有一個 LLM 駕駛，彼此用 `tell` 工具協調。
  - coordinator flock（`flock-kick`）：用決定性的拍賣機制，搭配 2～4 隻模擬 Microduck，只能在模擬器中執行。
- **VLA 策略整合**：SO-101 手臂可以用 `quackd policy serve` 提供 ACT、SmolVLA、pi05 等策略，並以 `--controller vla` 把指令交給策略執行。
- **執行紀錄**：每次執行都會產生 `runs/<timestamp>-<name>/` 資料夾，內含 `transcript.jsonl`、擷取的影格、`summary.json`、`terminal.txt`，通常還有 `run.gif`。可以用 `quackd log` 重播。

## 技術架構或運作原理

- **三層迴圈**：
  - LLM 決策：約 0.2～1 Hz。
  - steering 迴圈：10 Hz。
  - 機器人自身的控制器負責實際動作。
- **Manifest**：每個 adapter 宣告機器人能做什麼。不在 manifest 裡的 verb 就等於不存在。
- **把關順序**：allowlist → 可行性判定 → 參數驗證 → confirm gate → 預算 → abort 規則 → 與 abort 競速的逾時。
- **感知**：預設用 HSV 顏色閾值，也可以選用 YOLO。另可透過 `--host` 連到 Jetson 板做偵測。
- **Flock 通訊**：有程序內 bus，也有 MQTT 函式庫，但 MQTT 只在同一台機器上的兩個節點間測試過。
- **安全機制**：heartbeat、`stop` 指令，以及手臂的 rest pose。需要 rest pose 是因為 LeRobot 斷線時會卸除扭力，手臂會直接掉下來。

## 安裝與使用方式

需求：

- Python 3.11 以上，以及 `uv`。
- Windows、macOS 或 Linux 皆可，筆電不需要 GPU。
- 若要控制真實的 LeRobot 手臂，需要 Python 3.12 以上。

```bash
# 快速試用
uvx quackd --version

# 依機身安裝 extras
uv pip install "quackd[microduck]"
uv pip install "quackd[robots]"
uv pip install "quackd[lerobot]"
uv pip install "quackd[lerobot-sim]"
uv pip install "quackd[anthropic]"

# 開發環境
git clone https://github.com/rokbenko/quackd && cd quackd && uv sync --extra dev
```

常用指令（取自 README）：

```bash
quackd doctor
quackd list-adapters
quackd list-models

# 不需 API key，在 MuJoCo 中讓 Microduck 走正方形
uvx --from "quackd[mujoco]" quackd run --goal "walk in a square" --robot microduck:mujoco --llm fake

# 註冊真實 SO-101 手臂並記錄 rest pose
quackd robot add arm-01 lerobot:real --address COM3 --llm openai:gpt-6-astra
quackd robot rest-pose arm-01

# 先以 dry-run 試跑目標
quackd run --goal "Wave to the camera with an extended arm" --robot arm-01 --max-steps 10 --dry-run

# 接到 Claude Code（MCP）
claude mcp add arm -- <path-to-venv>/quackd serve-mcp --robot arm-01
```

`--llm` 參數的格式為 `VENDOR[:MODEL]`。其他子指令還有 `validate`、`preflight`、`policy serve|check`、`list-verbs`、`discover`、`announce`、`memory`、`flock`、`record`、`log` 等。

## 適用情境

- 想用自然語言或 Claude（MCP）指揮機器人做目標導向任務的玩家與研究者。
- 在沒有硬體的情況下，先用 2D 或 MuJoCo 模擬器驗證 LLM agent 迴圈。
- 為 LeRobot SO-101 手臂接上 LLM 高層規劃，搭配 VLA 策略。
- 實驗多機器人協作（flock）。

## 授權與成本

- 程式碼採 Apache-2.0。第三方授權列在 `docs/reference/licenses.md` 與 NOTICE。
- Pollen 以 CC BY-NC-SA 授權的 mesh 沒有隨專案散布。物理模擬器會在執行時下載模型與策略，並驗證雜湊值。
- 軟體免費。使用雲端 LLM 需要支付該服務的 API 費用；`--llm fake` 與本地模型則不需要。

## 限制與注意事項

- 7 個 adapter 中有 6 個還沒在真實硬體上執行過。目前只有 SO-101 手臂跑過真機。
- 實體 Microduck 還無法驅動，要等機器人出貨。README 也說還沒有拍到真實模型在小鴨模擬器中運作的畫面。
- 預設的 2D 模擬器只測試 agent 迴圈，不測試物理。MuJoCo 模擬只涵蓋 Microduck 與手臂，且手臂模擬尚未與實機比對。
- 手臂若沒記錄 rest pose，結束時會掉下來。第二次真機測試也發現，超出校準行程的折疊姿勢無法達成。
- 任務是否成功，通常只是模型自己宣稱的。記憶功能只是一個純文字檔，沒有搜尋功能。
- flock 沒有在硬體上測試過，也從未跨機器執行。
- 本地模型的品質沒有量測過。決策 LLM、Jetson daemon、區網探索都只在有限或 stub 的環境下測試過。
- 0.x 版期間，minor 版本可能變更指令、旗標或檔案格式。
- README 明言不提供任何安全保證，機器人安全由使用者自行負責。

## 相關工具

- MuJoCo（本資料夾另有條目）
- Hugging Face LeRobot、SO-101 手臂
- Pollen Robotics microduck／microduck_rl、Open Duck Mini
- Jev／Laya／Kev 決策模型（可參考「07-Jev-決策模型生態」資料夾）
- MCP（Model Context Protocol）、Claude Code

## 資料來源

- https://github.com/rokbenko/quackd
