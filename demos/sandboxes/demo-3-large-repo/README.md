# Demo 3 workspace — onboarding a large repo

There is no sandbox to ship here: the whole point of this demo is a repo too big
to fit in a context window. This folder exists to hold your **prep artifacts**.

Full script, short cut, and recovery table: [demo-3-large-repo-two-phase-flow.md](../../demo-3-large-repo-two-phase-flow.md)

---

## Setup, the day before

1. **Clone the repo you will demo, into its own folder outside this one.**
   Your team's repo is the better choice — recognisable file names land harder.
   Any large public repo works as a fallback.

   ```powershell
   git clone <url> C:\demos\big-repo
   code C:\demos\big-repo
   ```

2. **Confirm the semantic index.** Click the Copilot entry in the Status Bar and
   check the workspace index status. If it is still building, run
   **Build Codebase semantic index** from the Command Palette and wait.

3. **Check content exclusions.** If your org excludes paths in the repo you
   picked, Copilot is silently disabled there and the demo dies on stage. Verify
   by asking a trivial question about a file in the target subsystem.

4. **Pre-run Phase 1** and save the resulting spec into this folder as
   `backup-spec.md`. If the live run stalls past 90 seconds, copy it into the
   repo's `docs/specs/` and continue from Phase 2.

   ```powershell
   Copy-Item backup-spec.md C:\demos\big-repo\docs\specs\<subsystem>.md
   ```

5. **Rehearse that recovery once.** A planned cutover reads as confident. An
   unplanned one reads as broken.

## Reset the demo repo between runs

```powershell
cd C:\demos\big-repo
Remove-Item -Recurse -Force docs\specs -ErrorAction SilentlyContinue
git checkout .
```

## Why a separate clone, not a subfolder here

Beyond the reasons that apply to the other two demos, this one is decisive: the
demo depends on the workspace index covering **only** the large repo. Nesting it
under the presentation folder would put the deck, the runbooks, and the other two
sandboxes into the same index — so "show the scale" and every retrieval you
narrate would be measuring the wrong thing.
