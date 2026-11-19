# AnyMachine

- **分類**：3D 建模與生成 / Blender × Agent
- **連結**：https://github.com/apekshik/anymachine

## 原清單說明

讓 agent 在 Blender 裡做出「真的會動」的機械：鉸鏈、腿、軟質物件都能綁好，每個控制都是 0–1 的參數。（來源：使用者提供的 GitHub repo）

> **查證補充**：正確。repo 自稱 **Status: experiments**，目前是六組實驗的腳本、筆記與檢查報告，不是可直接呼叫的服務或 API（README：「there is no endpoint yet」）。

## 概述

AnyMachine 是 apekshik 的實驗 repo，示範讓 coding agent（作者使用 Claude Fable 5.2 + Claude Code）用 Blender Python 腳本建出可動、可綁骨、可匯出遊戲用 GLB 的機械與道具，人只負責挑設計與逐階段核可。它屬於同作者的一組工具：[AnyScene](https://github.com/apekshik/anyscene)（從一段描述做出整個寫實場景）、[AnyKit](https://github.com/apekshik/anykit)（風格一致的道具組）、AnyMachine（會動的機械）、[AnyShot](https://github.com/apekshik/anyshot)（替 3D 場景運鏡出片）。

代表作 **Stilt**：一台 30 公尺高的四足步行機，160 個零件、每個關節都有可運作的液壓缸、104 根骨頭、三段動畫（走路、伸手、轉頭），全部由一支 Python 腳本 `build_stilt.py` 從零生成。

截至 2026-11-20：MIT、約 640 顆星，建立於 2026-11-04，最後推送 2026-11-17。

## 核心功能／特色

三種做法，對應不同物件：

- **從生成網格做日常物件的可動綁定**：
  1. 用 Meshy、Tripo 生成擺出關節姿勢的物件。
  2. 把網格當「外皮」：從上面量出關節軸，再在這些軸上用乾淨幾何重建可動部件（同軸鉸鏈筒、並排關節板），避免互相穿透。
  3. 每個關節一個 0–1 自訂屬性（含 driver 與限制），烘成線性 glTF action，任何引擎用 `seek(t = value)` 就能擺姿勢。
  4. 自動檢查：掃過每個參數找三角形重疊、夾住超出範圍的值、量腳步滑移，再重新匯入 GLB 比對。
- **從參考圖做生成器給不了的機械**（PIPELINE.md 第一部分）：一張概念圖 → 三視圖／轉台圖 → 單一視角 → 每個機構一張特寫板 → 先寫零件清單（尺度、軸、每個零件掛哪根骨）→ 建模腳本 → 把模型照參考圖角度渲染並排比對 → 動畫與穿模檢查 → 匯出 GLB/FBX 並重新匯入驗證。
- **從參考板做複雜靜態物件**（PIPELINE.md 第二部分）：先生成六面圖與特寫板，再在 Blender Python 裡一個真實零件一個零件地建，與參考並排渲染、二次補細節、在 GPU 算圖農場烘貼圖、匯出遊戲用資產。這類物件不使用圖生 3D 網格。

## 實驗結果（作者自述）

| 實驗 | 關節 | 結果 |
|---|---|---|
| hardsurface | 無（靜態道具：救生艇站、直升機、12 件鑽油平台設備、19 種燈具、3 把步槍） | 可當遊戲道具；部分地方比參考板簡單、平；直升機約 31,477 個三角形、三組貼圖，尚未在遊戲裡測試 |
| stilt | 4 腿 × 3 關節、雙臂、手、5 節頸；14 支液壓缸 | 可用，三段動畫都沒有穿模；手、肘、腳比參考板樸素 |
| laptop | 一個螢幕上蓋鉸鏈 0–135° | 全範圍 0 重疊，最小間隙 0.32 mm |
| quadruped | 4 腿 × 3 關節；小跑、待機、坐、站 | 0 重疊、腳滑移 0.014 mm；腿是素板 |
| spider | 8 腿 × 3 關節 | 0 重疊；生成器只給 6 條腿，8 條是依需求補的；身體外皮粗糙 |
| backpacks | 捲、扣、填充、掀蓋、拉鍊、背帶 | 部分成功：捲口包全過，背包與日用包在控制互相影響處失敗 |

背包實驗的結論：鉸鏈、滑軌、輪子足以處理硬表面物件，但軟質物件需要自己的關節類型（`flap`、`zip_path`、`fill`、`strap`、`roll`、`clip`、`jiggle`）與控制間的相依描述，筆記裡有草案。

## 安裝與使用方式

需要 Blender（Stilt 與 hardsurface 用 5.2，其他實驗用 5.0）。

```bash
git clone https://github.com/apekshik/anymachine.git && cd anymachine

# Stilt：只需腳本，從零重建 stilt.blend 與 stilt.glb（含貼圖烘焙約 80 秒，加 --no-bake 跳過）
blender --background --python stilt/build_stilt.py
blender --background stilt/stilt.blend --python stilt/render_stilt.py -- 3q cu check
blender --background --python stilt/verify_glb.py

# 硬表面物件：每個物件一支腳本，--nobake 幾秒內建好幾何
cd hardsurface/rig2_blender/kit
blender -b --factory-startup --python aircraft/helicopter/build.py -- --nobake
```

- 其他實驗資料夾各有 `run_all.sh`（背包為 `run_bag.sh`），從 `gen/` 裡的快取生成結果無頭重建。
- 重新生成參考圖需要 fal 的 `FAL_KEY`（`stilt/edit.ps1`、`video.ps1`，讀 `jobs_*.json` 提示詞檔）；作者用 GPT Image 2.6，README 說任何能吃參考圖的圖像模型都行。
- 想讓自己的 agent 做下一台機器：把 `PIPELINE.md` 給它當流程說明（文件明寫是給「要做下一台機器的 agent」看的）。

## 適用情境

- 讓 Claude Code 等 agent 在 Blender 裡做會動、可綁骨、能匯出 GLB 的機械或道具，而不只是靜態模型。
- 把 Meshy／Tripo 生成的網格變成關節正確、沒有穿模的可動資產（筆電、四足、蜘蛛）。
- 參考「概念圖 → 參考板 → 零件清單 → 腳本 → 並排比對」這套流程，提升 agent 建模的準確度。
- 遊戲裡需要用一個 0–1 參數驅動的開合、走路、伸縮動作。

## 授權與成本

- MIT。
- 生成參考圖、圖生 3D（Meshy、Tripo）與 GPU 烘焙需要各服務的付費額度；只跑現成的 Stilt 腳本則只需 Blender。

## 限制與注意事項

- ⚠️ 明確標示為**實驗**，沒有套件、API 或服務，是一組可參考的腳本與方法。
- 生成檔、`.blend`、GLB 與渲染畫格多數不在 repo 裡（Stilt 的 `stilt.glb` 例外），repo 保留示範 GIF、靜態圖與 `check.json` 報告。
- 成品在部分地方比參考圖簡單；軟質物件（背包）尚未完全解決。
- 流程中每一階段都需要人核可，不是一鍵全自動。

## 相關工具

- 同作者：[AnyScene](https://github.com/apekshik/anyscene)、[AnyKit](https://github.com/apekshik/anykit)、[AnyShot](https://github.com/apekshik/anyshot)
- 同資料夾：[MCP for Blender](MCP-for-Blender.md)（讓 agent 操作開著的 Blender）、[cc-blender-skill](cc-blender-skill.md)、[TheLongSilence](TheLongSilence.md)（硬表面建模 skill）、[Meshy MCP Server](Meshy-MCP-Server.md)（生成網格與自動綁骨）

## 資料來源

- https://github.com/apekshik/anymachine （README、PIPELINE.md）
- https://api.github.com/repos/apekshik/anymachine （授權、星數、建立與推送日期）
- https://api.github.com/repos/apekshik/anyscene 、anykit、anyshot（同系列 repo 說明）
