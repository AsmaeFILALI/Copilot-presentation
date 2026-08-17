# Demo 1 sandbox — context makes or breaks the suggestion

**Open this folder as its own VS Code window.** Do not run it as a subfolder of
the presentation workspace — see [why](#why-its-own-window) below.

```powershell
code "C:\DevPROJECTS\Copilot presentation\demos\sandboxes\demo-1-context"
```

Full script, narration, and recovery table: [demo-1-context-makes-the-suggestion.md](../../demo-1-context-makes-the-suggestion.md)

---

## What is here

| Path | Role in the demo |
| --- | --- |
| `src/services/invoiceService.ts` | The target file. Starts as a single comment. |
| `src/types/invoice.ts` | Real domain types. Opened in **step 2** only. |
| `src/services/orderService.ts` | Shows house conventions. Opened in **step 2** only. |
| `_staged/copilot-instructions.md` | Moved into `.github/` in **step 3**. Hidden from search until then. |
| `reset.ps1` | Puts everything back to the cold state. |

## Run it

```powershell
# Step 1 — cold. Open ONLY src/services/invoiceService.ts.
#   Prompt: Add a createInvoice function to this file.

# Step 2 — warm. Open the two other files in tabs, NEW chat, same prompt.

# Step 3 — persistent.
New-Item -ItemType Directory -Force .github
Move-Item _staged\copilot-instructions.md .github\copilot-instructions.md
#   Reload window, NEW chat, same prompt.
```

Between runs:

```powershell
.\reset.ps1
```

## Why its own window

Three things break if this lives inside the presentation workspace:

1. **`.github/copilot-instructions.md` would not load.** Repository custom
   instructions are read from the **workspace root**. Nested at
   `demos/sandboxes/demo-1-context/.github/`, they are simply ignored — step 3
   would silently do nothing.
2. **The cold start would not be cold.** The presentation deck and the demo
   runbook contain these exact types *and* the expected answer. Semantic search
   would happily retrieve them and step 1 would look like step 2.
3. **Tab control is the whole demo.** Every unrelated file you leave open is
   another candidate for the neighbouring-tabs slice of the prompt.
