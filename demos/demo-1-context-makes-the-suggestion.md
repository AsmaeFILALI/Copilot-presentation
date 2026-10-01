# Demo 1 — Context makes or breaks the suggestion

**Slot:** Week 3, after Part 2 (prompt crafting) · **Budget:** 3 minutes
**Supports:** Part 1.5 (context window), Part 2.3 (context as prompt engineering), Part 2.4 (custom instructions)

**The one line you are proving:** *same prompt, three different answers — the variable was never the prompt, it was the context.*

---

## Pre-flight (do this before the session, not live)

### 1. Open the sandbox — as its own window

The files are already built for you in
[`sandboxes/demo-1-context/`](sandboxes/demo-1-context/README.md). Open it as a
**separate VS Code window**, never as a subfolder of the presentation workspace.
From the repo root:

```powershell
code .\demos\sandboxes\demo-1-context
```

> **This is not optional.** Repository custom instructions load from the
> *workspace root*, so step 3 silently does nothing if the sandbox is nested. And
> this runbook contains the expected answer — in the same workspace, semantic
> search finds it and the cold start is no longer cold.

What is in there:

```
demo-1-context/
├─ src/types/invoice.ts            Money, LineItem, Invoice, Result<T>
├─ src/services/orderService.ts    house conventions in action
├─ src/services/invoiceService.ts  the target — one comment, nothing else
├─ _staged/copilot-instructions.md moved into .github/ at step 3
└─ reset.ps1                       back to the cold state
```

`_staged/` is excluded via `.vscode/settings.json` so it cannot leak into the
cold-start prompt.

### 2. Verify the demo actually lands

Run all three steps once, the day before. Model behaviour drifts; you want to know
what *your* model does today, not what this document predicted.

### 3. Reset to the cold state

- Close **every** editor tab (`View → Close All Editors`)
- Confirm `.github/copilot-instructions.md` does **not** exist yet
- Open a brand-new Chat session
- Zoom the editor font to presentation size

---

## The demo

### Step 1 — Cold start (~50 seconds)

Open **only** `src/services/invoiceService.ts`. Nothing else.

In Chat, send:

```text
Add a createInvoice function to this file.
```

**Narrate while it generates:** "Copilot has the file name, the language, and one
comment. That is the entire prompt."

**What to point at in the output:**

- Invented types — usually an inline `{ id: string; amount: number }` or an
  `Invoice` interface it just made up
- `amount` as a plain `number` — no currency anywhere
- `throw new Error(...)` for failures

> Say: "None of this is wrong. It is just not *ours*. Copilot has never seen our code."

### Step 2 — Warm start (~60 seconds)

Open `src/types/invoice.ts` and `src/services/orderService.ts` in adjacent tabs.
**Start a new Chat** (do not continue the thread — you want a clean window).

Send the **identical** prompt:

```text
Add a createInvoice function to this file.
```

**What to point at:**

- It now imports and uses the real `Invoice`, `LineItem`, `Money` types
- Totals are computed in minor units
- It may mirror `calculateOrderTotal`'s shape because it saw a sibling service

> Say: "I did not tell it about our types. I opened two tabs. That is the
> *neighbouring open tabs* row from the context table in Part 1."

### Step 3 — Persistent context (~60 seconds)

Move the staged file into place:

```powershell
New-Item -ItemType Directory -Force .github
Move-Item _staged\copilot-instructions.md .github\copilot-instructions.md
```

Reload the window (`Developer: Reload Window`), open a **new Chat**, send the
same prompt a third time.

**What to point at:**

- Returns `Result<Invoice>` instead of throwing
- Error codes like `INVOICE_NO_LINES` in SCREAMING_SNAKE_CASE
- No `any`, no default export

> **Close on:** "Same prompt, three different answers. The variable was never the
> prompt — it was the context. And step three is the only one that keeps paying
> off after I walk away, because it is committed to the repo."

---

## If it goes wrong

| What happens | Recovery |
| --- | --- |
| Cold start produces surprisingly good code | Do not fight it. Say: "Interesting — it guessed well. Watch the *type names* though." The invented names will still differ from yours. That is the real tell. |
| Warm start ignores the open tabs | Explicitly pin it: `#file:src/types/invoice.ts`. Reframe as: "Open tabs are a *hint*; `#file` is an *instruction*." Still on-message. |
| Instructions appear not to apply | Confirm the file is at `.github/copilot-instructions.md` (not `.github/instructions/`) and that you reloaded. Check the Chat response's references list — VS Code shows which instruction files were used. |
| You are out of time | Cut step 2. Steps 1 → 3 still prove the point and step 3 is the actionable takeaway. |

---

## Reset for the next run

```powershell
.\reset.ps1
```

Then close all editors and start a new chat.
