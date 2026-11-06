---
name: find-tool
description: 在 Awesome AI List 裡找出適合解決某個需求的工具。用法：/find-tool <你想做的事或遇到的問題>
context: fork
agent: tool-finder
argument-hint: <需求或問題>
---

使用者的需求：

$ARGUMENTS

依照 tool-finder 的工作流程，在本 repo 中找出最合適的工具並回答。
