# RP1

- **分類**：機器人與具身智慧 / 開源硬體平台（人形機器人）
- **連結**：https://github.com/Roboparty/RP1
- **產品頁**：https://roboparty.com/products/RP1
- **實驗室**：https://lab.roboparty.com/

## 原清單說明

（使用者新增，無原清單說明。）

> **查證結果**：上海萝博派对科技（RoboParty）的全開源人形機器人平台，從機構 CAD、PCB、線材、BOM、關節模組韌體，到 Linux BSP、ROS 2 部署、URDF／MJCF 與 Isaac Lab 訓練都公開。`Roboparty/RP1` 本身**只是總覽頁**（只有 README、LICENSE 和圖片），實際內容分散在十多個子 repo，各有不同授權，其中幾個**沒有標授權**。產品頁標題叫「ROBOTO 01」，規格表欄位寫 RP1／RP1 Pro，指的是同一台。

## 概述

RP1 是身高 1.35 m、約 39 kg 的人形機器人，主打「沒有黑盒子」：硬體可檢查、軟體可延伸、學習方法可研究。官方架構是 輸入／感知 → 動作重定向與運動策略 → 500 Hz 即時控制（動作解碼＋串聯連桿求解）→ 自研 ROMOMO 關節模組與 RP Hand 執行，另有急停與高頻回授迴路。

總覽 repo 建立於 2026-09-30，查詢當下（2026-10-22）約 660 顆星，最後推送 2026-10-20。同公司較早的 DIY 人形機器人 [roboto_origin](https://github.com/Roboparty/roboto_origin) 約 2,690 顆星。

## 規格（官方產品頁）

| 項目 | RP1 | RP1 Pro |
| --- | --- | --- |
| 身高／體重 | 1.35 m／約 39 kg | 1.35 m／約 41 kg |
| 主動自由度 | 24（單臂 5、單腿 6、腰 2） | 30（單臂 7、頭 2） |
| 跑步速度／爬坡 | ≤4 m/s／30° | 同左 |
| 關節峰值扭矩 | 160 N·m（100 mm 外徑模組） | 同左 |
| 電池 | 10 Ah，約 3 小時，可熱插拔，140 W USB-C 快充 | 同左 |
| 計算 | RK3588；可選配 Orin NX 16 GB | RK3588 ＋ A733 |
| 標配末端 | 假手 | 6 自由度靈巧手 |

- 可換四種頭部：運控、交互、數採（雙目 RGB）、感知（D435i 深度相機＋3D 光達）。
- 手部可接 RP Hand（6 或 22 自由度）、Inspire Hand、Linker Hand 或夾爪。
- 總覽 README 另說描述 repo 支援 24／28／30／42 自由度配置。
- 官方網頁沒有標價。

## 子 repo

| Repo | 內容 | 授權 |
| --- | --- | --- |
| [rp1_hardware](https://github.com/Roboparty/rp1_hardware) | SolidWorks 原始檔、Parasolid、工程圖、PCB（Gerber、BOM）、線材、整機 BOM | CERN-OHL-W-2.0；文件 CC BY-SA 4.0 |
| [ROMOMO](https://github.com/Roboparty/ROMOMO) | 關節模組、韌體、上位機工具 | CC-BY-4.0 |
| [rp_dexhand](https://github.com/Roboparty/rp_dexhand) | RP Hand 靈巧手文件、CAD、URDF／MJCF、C++／Python／ROS 2 SDK | 未標示 |
| [RP1_description](https://github.com/Roboparty/RP1_description) | URDF、MJCF、3D 資產、機器人配置 | 未標示 |
| [RP1_firmware](https://github.com/Roboparty/RP1_firmware) | Linux BSP、USB-CAN 橋接、底層 SDK | GPL-3.0 |
| [roboparty_deploy](https://github.com/Roboparty/roboparty_deploy) | ROS 2 部署框架：IMU、馬達、靈巧手、推論、相機驅動 | GPL-3.0 |
| [roboparty_train](https://github.com/Roboparty/roboparty_train) | Isaac Lab＋RSL-RL 訓練：行走、AMP、BeyondMimic、Parkour、MuJoCo Sim2Sim | README 寫 BSD-3，repo 未標 |
| [rp1_test](https://github.com/Roboparty/rp1_test) | 整機測試 | Apache-2.0 |
| [Party_OS](https://github.com/Roboparty/Party_OS) | RoboParty 的人形機器人系統 | GPL-3.0 |

另有供應鏈驗收（robot_supplychain）與遙控器 App（roboparty_joystick）。

## 學習與研究專案

總覽 README 的 Demo 區標「Coming soon」，列出的專案：AMP、BeyondMimic（動作模仿，如跳舞）、[MimicLite](https://github.com/Roboparty/MimicLite)（參考動作追蹤）、[UFO](https://github.com/Roboparty/UFO)（無監督 RL 的行為基礎模型）、P-BFM（加入環境感知）、I-BFM（全身接觸互動）、INTACT-JEPA（以 JEPA 學「意圖 → 動作」，免線上搜尋）。相關論文有 P-BFM（ICLR 2027）、I-BFM、PredActor、人形機器人桌球（ICRA）等。

## 安裝與使用方式

沒有單一安裝指令；依要做的事進對應子 repo。例如訓練：

```bash
# 需 Python 3.11、Isaac Sim 5.1.0、Isaac Lab main；Ubuntu 22.04 或 Windows x64
git clone --recursive https://github.com/Roboparty/roboparty_train.git
```

硬體從 [rp1_hardware 的 v0.1.0 release](https://github.com/Roboparty/rp1_hardware/releases) 下載 SolidWorks 原始檔，打開 `RP1_SolidWorks_Source/RP1.3.4整机.SLDASM`。

## 適用情境

- 研究人形機器人的行走、動作模仿、行為基礎模型，並有完整的硬體設計可對照。
- 學習一台真實人形機器人從機構、電路、關節韌體到 ROS 2 與 RL 訓練的完整技術棧。
- 自製或改裝人形機器人：直接拿 CAD、PCB、BOM 與供應鏈驗收文件。
- 用 URDF／MJCF 在 Isaac Lab 或 MuJoCo 裡模擬，再部署到實機。

## 授權與成本

- **授權**：總覽 repo 為 GPL-3.0，但官方說明以各子 repo 為準：硬體 CERN-OHL-W-2.0、關節模組 CC-BY-4.0、韌體與部署 GPL-3.0；`rp_dexhand`、`RP1_description` 等沒有授權檔，**預設不能任意重用**，商用前應向官方確認。
- **成本**：軟體與設計檔免費；整機價格官網未公開，自製需依 BOM 採購與 CNC 加工。

## 限制與注意事項

- 總覽 repo 不收 PR，問題與貢獻要到對應子 repo。
- 多數子 repo 是 2026-09 到 10 月才建立，星數與文件都還在早期；Demo 區仍標「Coming soon」。
- `roboparty_train` 的 README 寫的是「RPO」系列機器人的訓練環境，是否已含 RP1 專用任務，本條目未逐一查證，**資料不足**。
- 社群以 QQ、微信、Bilibili 為主，部分文件只有簡體中文。

## 相關工具

- [MuJoCo](MuJoCo.md)：RP1_description 提供 MJCF，可直接模擬；訓練 repo 也用它做 Sim2Sim
- [LIBERO](LIBERO.md)：操作策略的模擬基準
- [quackd](quackd.md)：用 LLM 指揮小型機器人
- [Kit USD Agents](../02-3D-建模與生成/Kit-USD-Agents.md)：Isaac Sim 開發輔助
- [roboto_origin](https://github.com/Roboparty/roboto_origin)：同公司較早的全開源 DIY 人形機器人

## 資料來源

- https://github.com/Roboparty/RP1 （總覽 README：架構、子 repo、研究專案、論文）
- https://roboparty.com/products/RP1 （產品頁規格表）
- https://github.com/Roboparty/rp1_hardware （硬體檔案、授權）
- https://github.com/Roboparty/roboparty_train （訓練需求、功能）
- https://api.github.com/repos/Roboparty/ （各子 repo 的建立日期、星數、授權欄位）
