# Demo 3 — Onboarding a large repo (the two-phase flow)

**Slot:** Week 3, optional — inside or after Part 3.3 · **Budget:** 5 minutes (3-minute short cut available)
**Supports:** Part 1.5.4 (agent mode burns the window), Part 3.3 (large-repo workflow)

**The one line you are proving:** *your job is not to give Copilot more context — it is to give it the right 10,000 tokens.*

> **Audience fit:** this is the highest-value demo for enterprise teams working in
> monorepos, and the lowest-value one for an audience of solo developers. If time
> is tight, swap it in *for* Demo 1 rather than adding it.

---

## Pre-flight — this demo fails without preparation

Agent runs are slow and non-deterministic. Everything below exists to make the
live portion predictable. Prep artifacts live in
[`sandboxes/demo-3-large-repo/`](sandboxes/demo-3-large-repo/README.md).

### 1. Pick and pre-clone the repo

Use **your own team's repo** if you can — it makes the demo real and the audience
recognises the file names. Otherwise any large public repo works.

Requirements: big enough that nobody could hold it in their head, and pushed to
GitHub so remote indexing applies.

**Clone it the day before.** Never clone live.

### 2. Confirm the semantic index is ready

Click the Copilot entry in the VS Code Status Bar and check the workspace index
status. If it is still building, run **Build Codebase semantic index** from the
Command Palette and wait.

> This screen is itself demo material — it makes the abstract "indexing" step
> from 3.3.1 concrete in two seconds.

### 3. Pre-run Phase 1 and keep the output

Run the Phase 1 prompt below the day before. Save the resulting spec as
`docs/specs/_backup-feature.md` **outside** the demo path.

If the live run stalls, drags past 90 seconds, or produces something incoherent,
copy the backup into place and continue from Phase 2. Rehearse this recovery once.

### 4. Reset to the start state

- Delete `docs/specs/` from the working tree
- Close all editors
- New Chat session, agent mode
- Terminal cleared

---

## The demo

### Step 0 — Show the scale (~20 seconds)

Open the repo. Say the number of files out loud, and roughly what that is in tokens
(≈ 12 tokens per line of code).

> "Call it a million tokens. My window is 128,000. Nothing I do today puts this
> repo in the window. So the question is never *how much* — it is *which*."

### Step 1 — Phase 1, investigate (~90 seconds)

New Chat, agent mode. Adapt the nouns to your repo:

```text
Investigate how <SUBSYSTEM> works in this repo. Trace the call path from the
entry point through to persistence. List the files involved, the key types, and
anything surprising or non-obvious. Write your findings to
docs/specs/<subsystem>.md. Do not change any code.
```

**Narrate the tool calls as they scroll past** — this is the part people remember:

> "Watch the left gutter. Semantic search. Grep. Read file. Read file. Read file.
> Every one of those results is now sitting in the context window. That burn-down
> chart from Part 1 is happening in front of you, right now."

Point out that it never opened 99% of the repo, and did not need to.

### Step 2 — The human step (~60 seconds)

Open the generated `docs/specs/<subsystem>.md`.

Read a couple of bullets aloud, then **correct something on screen**. Pick
something you genuinely know that the code does not say:

- a constraint that lives in a ticket, not the codebase
- the reason a weird branch exists
- a module that looks relevant but is dead code

> **Say:** "This is the step everyone skips, and it is the entire value of the
> workflow. The agent produced a good summary of what the code *says*. I just added
> what the code *cannot say*. That file is now worth more than any retrieval."

Optionally commit it — it becomes durable context for the whole team.

### Step 3 — Phase 2, implement in a fresh chat (~90 seconds)

**Open a brand-new Chat.** Say why, explicitly:

> "New chat. The last one is 80,000 tokens of search output I no longer need."

```text
#file:docs/specs/<subsystem>.md  #file:<the one file you will change>
<Your actual feature request, one sentence.>
```

Point at how fast it starts producing edits — no exploratory searching, because
the expensive thinking already happened and got written down.

### Step 4 — The contrast (optional, ~60 seconds)

Only if you are ahead of schedule.

Open a third chat. Same feature request, **no spec pinned**. Show that it either
starts the whole exploration over from scratch, or asks you questions the spec
already answered.

> **Close on:** "Same repo, same model, same window size. One of these runs knew
> where it was going."

---

## Short cut — 3-minute version

Skip step 1's live run entirely. Have the spec file already committed and open.

1. Show the repo scale (step 0)
2. Show the pre-made spec and say "an agent drafted this, I corrected two lines"
3. Run Phase 2 live (step 3)

You lose the tool-call narration but keep the whole argument, and it cannot
overrun.

---

## If it goes wrong

| What happens | Recovery |
| --- | --- |
| Phase 1 runs long | At 90 seconds, stop it. "I will not make you watch this — here is one I prepared." Copy in the backup spec. This is *planned*, so it reads as confident, not broken. |
| Agent edits code despite "do not change any code" | Undo, and use it: "Worth noting — instructions constrain, they do not guarantee. Review every diff." Ties straight back to Part 3.9, automation bias. |
| Index is not ready / no index | Do not panic. Say so honestly: "No semantic index here, so it is falling back to grep and text search — the answers are still decent, which is worth knowing." The workflow still works. |
| It writes the spec somewhere unexpected | Harmless. Just open wherever it landed. |
| Corporate policy blocks the repo | Have a public repo cloned as a fallback. Check this in advance — content exclusions can silently disable Copilot in some paths. |

---

## Reset for the next run

```powershell
Remove-Item -Recurse -Force docs\specs -ErrorAction SilentlyContinue
git checkout .
```

Close all editors and start a new chat.
