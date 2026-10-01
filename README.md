# GitHub Copilot — live demos

Two short, self-contained live demos for the GH-300 Week 3 session.

| Demo | Point it proves | Time | Runbook |
| --- | --- | --- | --- |
| 1 — Context makes the suggestion | Same prompt, three answers: the variable is the context, not the prompt | 3 min | [demo-1-context-makes-the-suggestion.md](demos/demo-1-context-makes-the-suggestion.md) |
| 2 — Passing test on buggy code | Green does not mean correct — it means consistent | 2 min | [demo-2-passing-test-on-buggy-code.md](demos/demo-2-passing-test-on-buggy-code.md) |

Each runbook has the pre-flight, the script with narration, and a "if it goes wrong" recovery table.

## Prerequisites

- VS Code with **GitHub Copilot** and **GitHub Copilot Chat**, signed in
- The `code` command on your PATH (VS Code: `Shell Command: Install 'code' command in PATH`)
- Demo 2 only: **Python 3.9+** and the VS Code **Python** extension

## Setup (once, after cloning)

Run from the repo root in PowerShell:

```powershell
# Allow the local reset / venv scripts to run in this terminal only
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Demo 2 environment
cd .\demos\sandboxes\demo-2-testing
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
pytest --version
cd ..\..\..
```

## Golden rule: open each sandbox as its own VS Code window

```powershell
code .\demos\sandboxes\demo-1-context
code .\demos\sandboxes\demo-2-testing
```

Never run a demo from this top-level folder. The runbooks contain the expected
answers, and Copilot will find them through workspace search — the demos only
work when the sandbox is the workspace root. Each sandbox also hides its
`_staged/` folder via `.vscode/settings.json` so the "answer" stays out of
Copilot's context until you reveal it.

## Before every run

In the sandbox window:

```powershell
.\reset.ps1
```

Then close all editors and start a **new** Chat session. Do a full dry run the
day before — model behaviour drifts, and the recovery tables cover the common
surprises.
