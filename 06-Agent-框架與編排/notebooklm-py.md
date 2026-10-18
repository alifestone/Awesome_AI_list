# notebooklm-py

- **分類**：Agent 框架與編排 / 知識庫 / 文件問答
- **連結**：https://github.com/teng-lin/notebooklm-py
- **延伸閱讀**：https://tenten.co/learning/notebooklm-py-skill/ （中文介紹；撰寫時該網站無法從本環境連線，內容未納入查證）

## 概述

notebooklm-py 是 Teng Lin 維護的**非官方** Python API、CLI 與 AI agent skill，可用程式操作 Google NotebookLM（2026 年 7 月起更名為 Gemini Notebook，同一服務、套件名稱不變）的功能，包括網頁介面沒提供的批次下載與結構化匯出。可從 Python、命令列，或 Claude Code、Codex、OpenClaw 等 agent 呼叫。

GitHub 資訊（2026-10-17 查閱）：MIT 授權，`pyproject.toml` 版本 0.8.5，最近一次提交 2026-10-15，支援 Python 3.10–3.15。

> ⚠️ README 明確警告：它使用**未公開的 Google API**，可能隨時失效、不隸屬 Google、重度使用可能被限流，適合原型、研究與個人專案。

## 核心功能／特色

- **來源管理**：批次匯入網址、PDF、YouTube、Google Drive；`source add-research` 可跑網路／Drive 研究（含 deep 模式）並自動匯入結果。
- **對話問答**：`ask` 以來源為依據回答並附引用，支援 `--json`、`--prompt-file`、`--save-as-note`。
- **內容生成**：Audio Overview（podcast）、影片（含 whiteboard 等風格與 cinematic-video）、投影片、測驗、flashcards、資訊圖表、資料表、心智圖、報告／學習指南。
- **下載與匯出**：MP3/M4A、MP4、PDF、PNG、CSV、JSON、Markdown；支援批次下載（`download <type> --all`）、測驗／flashcards 多格式匯出、心智圖 JSON、匯出至 Google Docs/Sheets。
- **Agent 整合**：根目錄附 `SKILL.md`，`notebooklm skill install` 會安裝到 `~/.claude/skills/notebooklm` 與 `~/.agents/skills/notebooklm`；另有 `AGENTS.md`（Codex 指引）與 MCP server（含遠端 connector，可接 claude.ai／ChatGPT）。
- **認證方式**：Playwright 互動登入、匯入已登入瀏覽器 cookie、或 master token（無需瀏覽器自動更新 cookie，適合伺服器／CI）；支援多帳號 profile。

## README 列舉的應用食譜

- **省 token**：把大量文件丟給 NotebookLM 做伺服器端分析，agent 只負責編排與收尾；用 Deep Research 蒸餾成可長期重用的 `SKILL.md`；用 NotebookLM 生成測驗當作 skill 的評測集。
- **Agent 記憶**：維護「Master Brain」筆記本，每次 session 結束寫入決策與修正，下次開始時查詢；或把內部文件／RFC 做成帶引用的專案知識庫。
- **來源轉產物**：RAG 式客服／on-call 問答、一份來源多格式再利用、批次匯出到 Anki 或 Obsidian。
- **無人值守**：事故 runbook 產生器、課程／學習集建構，可搭配 `auth refresh` 排程維持登入。

## 安裝與使用方式

```bash
uv tool install "notebooklm-py[browser]"   # 或 pipx install
notebooklm login                           # 首次會下載 Chromium（約 170 MB）並登入 Google
notebooklm auth check --test --json        # 驗證，預期 "status": "ok"

# 安裝 agent skill（二擇一）
notebooklm skill install
npx skills add teng-lin/notebooklm-py
```

```bash
notebooklm create "My Research" && notebooklm use <notebook_id>
notebooklm source add "./paper.pdf"
notebooklm ask "What are the key themes?"
notebooklm generate audio "make it engaging" --wait
notebooklm download audio ./podcast.m4a
```

當函式庫使用（不需 Playwright／Chromium）：`uv add notebooklm-py`。

## 適用情境

- 想讓 Claude Code 等 agent 把大量資料的閱讀與摘要外包給 NotebookLM 以節省 token。
- 批次產生並下載 podcast、簡報、測驗、心智圖等學習／內容素材。
- 為 agent 建立有引用的外部記憶或文件知識庫，不必自建向量資料庫。

## 授權與成本

- 授權：**MIT**；套件免費。
- 使用 NotebookLM 本身的額度與方案限制（`notebooklm usage` 可查看用量與重置時間），內容生成受 Google 端配額約束。

## 限制與注意事項

- 依賴未公開 API，Google 一改版就可能壞；官方 README 建議僅用於原型、研究、個人專案。
- 以 Google 帳號 cookie／master token 認證，屬帳號憑證，應妥善保管，且須自行評估是否符合 Google 服務條款。
- Windows 命令列近期調整了 asyncio event loop 行為（見 CHANGELOG Unreleased），遇沙箱環境卡住時需設定 `NOTEBOOKLM_WINDOWS_EVENT_LOOP=selector`。
- 應用情境中的成效數字多為社群自述，未見獨立評測。

## 相關工具

- Google NotebookLM／Gemini Notebook（被操作的服務）
- Claude Code、Codex、OpenClaw（可載入其 skill 的 agent）
- [Claude Code Game Studios](./Claude-Code-Game-Studios.md)、[Claude Octopus](./Claude-Octopus.md)（同為 Claude Code 生態的工作流程工具）
- [AnythingLLM](./AnythingLLM.md)（本地版文件對話／RAG 替代方案）

## 資料來源

- https://github.com/teng-lin/notebooklm-py （README、CHANGELOG、pyproject.toml、LICENSE）
