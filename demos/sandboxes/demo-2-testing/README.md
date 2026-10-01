# Demo 2 sandbox — the passing test on buggy code

**Open this folder as its own VS Code window.**

```powershell
# from the repo root
code .\demos\sandboxes\demo-2-testing
```

Full script, narration, and recovery table: [demo-2-passing-test-on-buggy-code.md](../../demo-2-passing-test-on-buggy-code.md)

---

## What is here

| Path | Role in the demo |
| --- | --- |
| `pricing.py` | The buggy function. `percent` is 0–100 but the maths assumes 0–1. |
| `_staged/pricing-with-spec.py` | Same function with the docstring spec. Copied over in **step 4**. Hidden from search until then. |
| `backup_expiry.py` | Subtler off-by-one, for when the model spots the obvious bug. |
| `reset.ps1` | Deletes generated tests and restores the buggy `pricing.py`. |

## One-time setup

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
pytest --version
```

## Run it

```powershell
# Step 1 — show pricing.py, ask the room to spot the bug.

# Step 2 — select the function, run /tests.
#   Read the generated assertion out loud: apply_discount(100, 20) == -1900

# Step 3 — it passes.
pytest -q

# Step 4 — give it the intent instead of only the implementation.
Copy-Item _staged\pricing-with-spec.py pricing.py -Force
Remove-Item test_pricing.py
#   Re-run /tests, then:
pytest -q          # now RED — the bug is exposed
```

Between runs:

```powershell
.\reset.ps1
```

## Why its own window

The presentation deck contains this exact function **with the bug annotated in a
comment**, plus the expected assertion. If the deck is in the same workspace,
semantic search can surface it and the model will "spot" the bug immediately —
which kills step 2. Open the sandbox alone and it cannot.
