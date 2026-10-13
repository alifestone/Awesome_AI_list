# USD BRep

- **分類**：3D 建模與生成 / CAD / 參數化建模
- **連結**：https://github.com/NVIDIA-Omniverse/usd-brep

## 概述

NVIDIA Omniverse 開源的 NURBS 邊界表示（BRep）實體建模函式庫，提供 C++ 與 Python API，並能把 BRep 資料原生匯入／匯出 [OpenUSD](https://openusd.org/)。核心是名為 SMLib 的建模核心（kernel）：實體由殼、面、邊、頂點等拓撲元素組成，綁定精確的 NURBS／B-spline／解析幾何，與多邊形網格不同，幾何是精確且與解析度無關的。

repo 附有給 AI coding agent 用的 `AGENTS.md` 與 `.agents/skills/`，其中 `text-to-3d-asset-generation` skill 讓 agent 依文字（或圖片）描述，以參數化建模產生 CAD/USD 資產。

截至 2026-10-14：Apache-2.0 授權、約 1.0k 顆星、主要語言 C++；1.0.0 版於 2026-10-08 首次公開發布，PyPI 套件為 `usd-brep`。

## 核心功能／特色

Python 套件 `usd_brep` 依子模組分組：`primitives`、`curves`、`surfaces`、`booleans`、`sweeps`、`fillets`、`offset`、`io`、`brep_ops`、`stitching`、`usd` 等。C++ 端 `SM_API` 標頭涵蓋：

| 類別 | 內容 |
| --- | --- |
| 基本形體 | 方塊、球、圓錐、圓柱、圓環、角錐、部分形體、skin、blend |
| 實體運算 | 布林運算、掃掠（sweep）、切割、投影、縫合（stitch）、偏移／薄殼 |
| 倒角 | 倒斜角（chamfer）、圓角（circular fillet）、移除圓角 |
| 曲線／曲面 | 建立、偏移、求值、節點移除；extrude／sweep／ruled／revolution／skin／offset 曲面 |
| 修剪曲面 | 以曲線修剪、投影並修剪、平面面 |
| 相交 | 曲線、曲面、面、BRep 間的相交 |
| 網格化 | BRep 轉多邊形網格（`PolyBrep`），可調弦高、角度、最大邊長、最大長寬比；網格布林運算 |
| 查詢 | 最近點、拓撲查找、包圍盒、體積、面積、長度、流形檢查 |
| 修復 | `heal_brep`；`usd.heal_file` 修復 USD 檔內的 BrepArray，保留圖層、參照、原生實例化、變換與材質 |
| 驗證 | `usd-brep[validation]` 註冊 BrepArray schema 規則，可用 `nvidia_usd_validate` 檢查 |

其他：Python GUI（`tools/scripts/smlib_gui.py`）、依 API 層分類的範例（`Examples/`），以及 19 個 agent skills（布林、圓角、網格化、修復、USD schema、OCCT 轉換、text-to-3D 等）。

## 技術架構或運作原理

分層設計（見 `AGENTS.md`）：

1. **`SMLib`**：C++ 建模核心，擁有所有幾何／拓撲類別與演算法，記憶體由內部 `SmContext` 管理。
2. **`SM_API`**：穩定的 C 風格 C++ 封裝，函式以 `SmApi*` 命名。
3. **`SM_API_USD`**：USD 匯入／匯出；BRep 以自訂的 `BrepArray` schema（omniSolid schema 外掛）和一般 USD prim 並存。
4. **`SmPyLib`**（模組 `_omni_solid`）：pybind11 綁定，對外以 `usd_brep` 套件發布。

PyPI wheel 內含所建置的 OpenUSD 執行環境（25.11），不需另裝，也不會匯入到 `pxr` 命名空間；與使用者自己的 OpenUSD 之間以檔案交換場景。

## 安裝與使用方式

用 pip 安裝（需 CPython 3.12、64 位元；Windows 或 Linux x86_64／aarch64）：

```bash
pip install usd-brep
```

```python
import usd_brep

sphere = usd_brep.primitives.create_sphere((0.0, 0.0, 0.0), 1.0)
box = usd_brep.primitives.create_box((-0.5, -0.5, -0.5), 1.0, 1.0, 1.0)
cut = usd_brep.booleans.subtract(sphere, box)

usd_brep.usd.export_brep(cut, "cut.usda")
(brep,) = usd_brep.usd.import_breps("cut.usda")

# 修復 USD 檔中的 BrepArray
usd_brep.usd.heal_file("input.usdc", "input_healed.usdc")
```

從原始碼建置（需 Git 與 Git LFS；其他相依套件由 Packman 自動下載）：

```bash
# Linux（需 build-essential）
./prebuild.sh
./repo.sh build
./repo.sh test

# macOS（僅 Apple Silicon）
./prebuild.sh -p macos-universal
./repo.sh build -p macos-universal
```

Windows 需 Visual Studio 2019／2022 的 C++ 工作負載（含 MSVC v142 工具組）與 Windows SDK，改用 `prebuild.bat`、`repo.bat build`。

## 適用情境

- 在 OpenUSD／Omniverse 管線中保存與交換精確的 CAD 實體，而非只有網格。
- 讓 AI agent 以 Python 程式做參數化建模，產生 CAD/USD 資產（repo 內的 text-to-3D skill）。
- 修復與驗證其他工具輸出的 USD BRep 資產。
- 需要開源（Apache-2.0）NURBS 建模核心的 C++／Python 專案。

## 授權與成本

- **授權**：Apache-2.0（`repo.sh`、`repo.bat`、`tools/repoman/repoman_bootstrapper.py` 為 MIT）。
- **成本**：免費。

## 限制與注意事項

- 目前不接受外部貢獻，只收 issue 與錯誤回報。
- PyPI 套件只支援 Python 3.12；不可與 PyPI 的 `usd-core` 25.11 裝在同一環境（同版本 OpenUSD 符號衝突會崩潰），`usd-core` 26.8 則在 Linux 上測試可共存。`validation` 選用套件不支援 Linux aarch64。
- `KNOWN_ISSUES.md` 列出的已知問題包括：
  - `remove_fillet` 不會移除圓角卻回報成功；`heal_brep` 修復失敗時也可能回報成功。
  - 修復圓環、球、圓柱等封閉曲面的接縫（seam）時可能修錯。
  - 圓角旁的網格可能出現法向顛倒的三角形（建議 `surface_angle_tolerance_deg` 設 15°）。
  - 以圓為邊界的面，面積／體積可能不準（預設精度下誤差約 1.4%），可調小 `relative_accuracy`。
  - 拓撲索引錯誤的 BrepArray 匯入時可能讓程式崩潰，建議先驗證。
  - 其他匯出器（如基於 OCCT 的 UsdSolid 匯出器）寫出的 UV 修剪曲線可能無法正確轉換。
- macOS 建置需要不在公開 Packman 伺服器上的 premake 套件，且預設不含 OpenUSD 相關功能。

## 相關工具

- [OpenUSD](https://openusd.org/)、[NVIDIA Omniverse](https://www.nvidia.com/omniverse/)、[Open CASCADE（OCCT）](https://dev.opencascade.org/)
- 同資料夾：FreeCAD MCP、Rhino MCP、MAC – Multi-Agent CAD（text-to-CAD，build123d）

## 資料來源

- https://github.com/NVIDIA-Omniverse/usd-brep （README）
- https://api.github.com/repos/NVIDIA-Omniverse/usd-brep （repo 中繼資料：授權、星數、建立與推送日期）
- https://raw.githubusercontent.com/NVIDIA-Omniverse/usd-brep/HEAD/AGENTS.md
- https://raw.githubusercontent.com/NVIDIA-Omniverse/usd-brep/HEAD/KNOWN_ISSUES.md
- https://raw.githubusercontent.com/NVIDIA-Omniverse/usd-brep/HEAD/CHANGELOG.md
- https://raw.githubusercontent.com/NVIDIA-Omniverse/usd-brep/HEAD/tools/pyproject/README.md （PyPI 套件說明）
- https://raw.githubusercontent.com/NVIDIA-Omniverse/usd-brep/HEAD/.agents/skills/text-to-3d-asset-generation/SKILL.md
- https://pypi.org/project/usd-brep/
- https://nvidia-omniverse.github.io/usd-brep （官方文件）
