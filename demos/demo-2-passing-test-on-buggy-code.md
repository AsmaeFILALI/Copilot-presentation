# Demo 2 — The passing test on buggy code

**Slot:** Week 3, after Part 4 (testing) · **Budget:** 2 minutes
**Supports:** Part 4.5 (tests come from behaviour, not intent), Part 3.9 (automation bias)

**The one line you are proving:** *green does not mean correct — it means consistent.*

---

## Pre-flight

### 1. Open the sandbox — as its own window

The files are already built for you in
[`sandboxes/demo-2-testing/`](sandboxes/demo-2-testing/README.md):

```powershell
code "C:\DevPROJECTS\Copilot presentation\demos\sandboxes\demo-2-testing"
```

> **Open it standalone.** The presentation deck contains this exact function with
> the bug called out in a comment. In the same workspace, the model finds it and
> "spots" the bug immediately — which removes the entire point of step 2.

```
demo-2-testing/
├─ pricing.py                       the buggy function
├─ _staged/pricing-with-spec.py     copied over at step 4 (hidden from search)
├─ backup_expiry.py                 subtler bug, if the model catches the first
└─ reset.ps1                        back to the buggy start state
```

### 2. Environment

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

Verify `pytest` runs and the terminal font is large enough to read from the back row.

### 3. Reset to the start state

- Delete `test_pricing.py`
- Close all editors except `pricing.py`
- New Chat session

---

## The demo

### Step 1 — Plant the bug (~20 seconds)

Show `pricing.py` on screen. Ask the room:

> "Twenty seconds. What is wrong with this function?"

Let someone call it out — `percent` is 0–100, not 0–1. Getting the audience to
find the bug *first* is what makes the next step land.

### Step 2 — Generate tests (~40 seconds)

Select the whole function. Run `/tests`.

**Do not skim the output. Read one assertion out loud, slowly:**

```python
def test_apply_discount():
    assert apply_discount(100, 20) == -1900
```

> Say: "Copilot did not write a wrong test. It wrote a *correct* test — for the
> code that is actually there."

### Step 3 — Run it (~20 seconds)

```powershell
pytest -q
```

Green. Let the silence sit for a beat.

> **Say:** "The suite passes. Coverage went up. The bug ships."

### Step 4 — The fix that matters (~40 seconds)

This is the constructive half — do not skip it, or the demo is just cynicism.

Swap in the version that states the *intent*, not just the implementation:

```powershell
Copy-Item _staged\pricing-with-spec.py pricing.py -Force
Remove-Item test_pricing.py
```

That adds a docstring giving the contract — `percent` is 0–100, `20` means 20% off,
`apply_discount(100, 20) -> 80`, never negative.

Re-run `/tests`, then `pytest -q`.

The generated test now asserts `== 80` and **fails** — surfacing the bug.

> **Close on:** "Nothing about the model changed. I gave it the *intent* instead of
> only the implementation. Tests written against behaviour confirm bugs; tests
> written against a specification catch them."

---

## If it goes wrong

| What happens | Recovery |
| --- | --- |
| **The model spots the bug unprompted** (increasingly common on stronger models) | Best possible outcome — use it. Say: "Good, this model caught it. Now watch a subtler one," and switch to the backup function below. Then continue from step 2. |
| Generated test uses `pytest.approx` or floats and passes ambiguously | Point at the *asserted value* rather than pass/fail. `-1900` is self-evidently wrong to a human reader. |
| `/tests` puts tests in an unexpected path | Irrelevant to the point. Just `pytest -q` from the root. |
| No Python available | The same demo works in any language. Keep a JS/TS variant ready if that is your house stack. |

### Backup function — subtler bug

Already in the sandbox as `backup_expiry.py`:

```python
from datetime import datetime

def is_expired(created_at: datetime, ttl_days: int) -> bool:
    """Return True when the item has outlived its TTL."""
    return (datetime.now() - created_at).days > ttl_days
```

Off-by-one: an item exactly `ttl_days` old should already be expired (`>=`).
Copilot will happily generate `assert is_expired(now - timedelta(days=30), 30) is False`
and it will pass. Nobody in the room spots this one in twenty seconds — which is
precisely the point.

---

## Reset for the next run

```powershell
.\reset.ps1
```
