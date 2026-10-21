# RP1

- **分類**：機器人與具身智慧 / 開源硬體平台（人形機器人）
- **連結**：https://github.com/Roboparty/RP1
- **產品頁**：https://roboparty.com/products/RP1
- **實驗室**：https://lab.roboparty.com/

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：上海萝博派对科技（RoboParty）的全開源人形機器人平台，公開了機構 CAD、PCB、線材、BOM、關節模組文件、Linux BSP、ROS 2 部署與 URDF／MJCF。但**關節模組韌體沒有公開**（ROMOMO repo 明說只放文件與測試資料），Isaac Lab 訓練 repo 目前**只支援同公司的 RPO 機器人**，還沒有 RP1 的訓練任務。`Roboparty/RP1` 本身**只是總覽頁**（只有 README、LICENSE 和圖片），實際內容分散在十多個子 repo，各有不同授權，其中幾個**沒有標授權**。產品頁標題叫「ROBOTO 01」，規格表欄位寫 RP1／RP1 Pro，指的是同一台。

## 概述

RP1 是身高 1.35 m、約 39 kg 的人形機器人，主打「沒有黑盒子」：硬體可檢查、軟體可延伸、學習方法可研究。官方架構是 輸入／感知 → 動作重定向與運動策略 → 500 Hz 即時控制（動作解碼＋串聯連桿求解）→ 自研 ROMOMO 關節模組與 RP Hand 執行，另有急停與高頻回授迴路。

總覽 repo 建立於 2026-10-01，查詢當下（2026-10-22）約 660 顆星，最後推送 2026-10-20。同公司較早的 DIY 人形機器人 [roboto_origin](https://github.com/Roboparty/roboto_origin) 約 2,690 顆星。

## 規格（官方產品頁）

| 項目 | RP1 | RP1 Pro |
| --- | --- | --- |
| 身高／體重 | 1.35 m／約 39 kg | 1.35 m／約 41 kg |
| 主動自由度 | 24（單臂 5、單腿 6、腰 2） | 30（單臂 7、頭 2） |
| 跑步速度／爬坡 | ≤4 m/s／30° | 同左 |
| 關節峰值扭矩 | 160 N·m（100 mm 外徑模組） | 同左 |
| 電池 | 10 Ah，約 3 小時，可熱插拔，140 W USB-C 快充 | 同左 |
| 計算 | RK3588；開發計算模組選配 | RK3588 ＋ A733；開發計算模組 Orin NX 16 GB |
| 標配末端 | 假手 | 6 自由度靈巧手 |

- 可換四種頭部：運控、交互、數採（雙目 RGB）、感知（D435i 深度相機＋3D 光達）。
- 末端支援假手、RP Hand 靈巧手（6 或 22 自由度）與夾爪；Inspire Hand、Linker Hand 在產品頁標為「適配概念」，不是確定支援。
- 總覽 README 說描述 repo 支援 24／28／30／42 自由度配置（28＝固定頭、30＝2 自由度頭、42＝再加兩隻 RP Hand），但 RP1_description 目前沒有 release，檔案裡只有 24 自由度與完整版的 URDF／MJCF，查無 28、42 自由度模型。
- 官方網頁沒有標價。

## 子 repo

| Repo | 內容 | 授權 |
| --- | --- | --- |
| [rp1_hardware](https://github.com/Roboparty/rp1_hardware) | SolidWorks 原始檔、Parasolid、工程圖、PCB（Gerber、BOM）、線材、整機 BOM | CERN-OHL-W-2.0；文件 CC BY-SA 4.0 |
| [ROMOMO](https://github.com/Roboparty/ROMOMO) | 關節模組的文件、CAN-FD 手冊、上位機手冊與測試報告（PDF）；**不含韌體與原始碼** | CC-BY-4.0 |
| [rp_dexhand](https://github.com/Roboparty/rp_dexhand) | RP Hand 靈巧手文件、CAD、URDF／MJCF、C++／Python／ROS 2 SDK | LICENSES.md 明說尚未選定授權；內附 ROS 套件標為 Proprietary |
| [RP1_description](https://github.com/Roboparty/RP1_description) | URDF、MJCF、3D 資產（無 README） | 未標示 |
| [RP1_firmware](https://github.com/Roboparty/RP1_firmware) | Linux BSP、USB-CAN 橋接、底層 SDK | GPL-3.0 |
| [roboparty_deploy](https://github.com/Roboparty/roboparty_deploy) | ROS 2 部署框架：IMU、馬達、靈巧手、推論、相機驅動 | GPL-3.0 |
| [roboparty_train](https://github.com/Roboparty/roboparty_train) | Isaac Lab＋RSL-RL 訓練：行走、AMP、BeyondMimic、Parkour、MuJoCo Sim2Sim。⚠️ 任務與機器人資產都是 RPO，沒有 RP1 | README 寫 BSD-3，repo 未標 |
| [rp1_test](https://github.com/Roboparty/rp1_test) | 整機測試 | 軟體 Apache-2.0；硬體 CERN-OHL-W-2.0、文件 CC-BY-SA-4.0 |
| [Party_OS](https://github.com/Roboparty/Party_OS) | RoboParty 的人形機器人系統 | GPL-3.0 |

另有遙控器 App（roboparty_joystick）。總覽頁列出的供應鏈驗收 repo（robot_supplychain）查詢當下回傳 404，尚未公開。

## 學習與研究專案

總覽 README 的 Demo 區標「Coming soon」，列出的專案：AMP、BeyondMimic（動作模仿，如跳舞）、[MimicLite](https://github.com/Roboparty/MimicLite)（參考動作追蹤）、[UFO](https://github.com/Roboparty/UFO)（無監督 RL 的行為基礎模型）、P-BFM（加入環境感知）、I-BFM（全身接觸互動）、INTACT-JEPA（以 JEPA 學「意圖 → 動作」，免線上搜尋）。相關論文有 P-BFM（ICLR 2027）、I-BFM、PredActor、人形機器人桌球（ICRA）等。

## 安裝與使用方式

沒有單一安裝指令；依要做的事進對應子 repo。例如訓練（目前只有 RPO 機器人的任務）：

```bash
# 需 Python 3.11、Isaac Sim 5.1.0、Isaac Lab main；Ubuntu 22.04 或 Windows x64
git clone --recursive https://github.com/Roboparty/roboparty_train.git
```

硬體從 [rp1_hardware 的 v0.1.0 release](https://github.com/Roboparty/rp1_hardware/releases) 下載 SolidWorks 原始檔，打開 `RP1_SolidWorks_Source/RP1.3.4整机.SLDASM`。

## 適用情境

- 研究人形機器人的行走、動作模仿、行為基礎模型，並有完整的硬體設計可對照。
- 學習一台真實人形機器人從機構、電路、Linux BSP 到 ROS 2 部署的技術棧（關節韌體未公開）。
- 自製或改裝人形機器人：直接拿 CAD、PCB、線材與 BOM。
- 用 RP1_description 的 URDF／MJCF 在 MuJoCo 或 Isaac Lab 裡模擬（訓練環境要自己接，官方訓練 repo 尚無 RP1 任務）。

## 授權與成本

- **授權**：總覽 repo 為 GPL-3.0，但官方說明以各子 repo 為準：硬體 CERN-OHL-W-2.0、關節模組文件 CC-BY-4.0、BSP 與部署 GPL-3.0；`rp_dexhand`（官方明說尚未選定授權）、`RP1_description` 沒有授權，**預設不能任意重用**，商用前應向官方確認。
- **成本**：軟體與設計檔免費；整機價格官網未公開，自製需依 BOM 採購與 CNC 加工。

## 限制與注意事項

- 總覽 repo 不收 PR，問題與貢獻要到對應子 repo。
- RP1 專屬的子 repo（rp1_hardware、ROMOMO、rp_dexhand、RP1_firmware、rp1_test）都是 2026-09 到 10 月才建立，星數與文件還在早期；部署、訓練與描述 repo 則沿用 2025 年起的舊專案。Demo 區仍標「Coming soon」。
- `roboparty_train` 只有 RPO 的任務（`RPO-AMP`、`RPO-BeyondMimic`、`RPO-Parkour`），機器人資產與 Sim2Sim 腳本（`sim2sim_rpo.py`）也都是 RPO，查無 RP1 相關檔案。
- 關節模組韌體沒有公開；ROMOMO 只有文件，RP1_firmware 是主控的 Linux BSP。
- 社群以 QQ、微信、Bilibili 為主，部分文件只有簡體中文。

## 相關工具

- [MuJoCo](MuJoCo.md)：RP1_description 提供 MJCF，可直接模擬
- [LIBERO](LIBERO.md)：操作策略的模擬基準
- [quackd](quackd.md)：用 LLM 指揮小型機器人
- [Kit USD Agents](../02-3D-建模與生成/Kit-USD-Agents.md)：Isaac Sim 開發輔助
- [roboto_origin](https://github.com/Roboparty/roboto_origin)：同公司較早的全開源 DIY 人形機器人

## 資料來源

- https://github.com/Roboparty/RP1 （總覽 README：架構、子 repo、研究專案、論文）
- https://roboparty.com/products/RP1 （產品頁規格表）
- https://github.com/Roboparty/rp1_hardware （硬體檔案、授權）
- https://github.com/Roboparty/roboparty_train 與 https://github.com/Roboparty/robolab （訓練需求、功能；任務與資產僅 RPO）
- https://github.com/Roboparty/ROMOMO （README：只含文件與測試資料，不含韌體）
- https://github.com/Roboparty/rp_dexhand/blob/main/LICENSES.md （尚未選定授權）
- https://github.com/Roboparty/RP1_description （檔案清單：無 release，無 28／42 自由度模型）
- https://api.github.com/repos/Roboparty/ （各子 repo 的建立日期、星數、授權欄位）
