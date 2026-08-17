# Week 3 — Architecture, Prompting & Productivity

**GH-300: GitHub Copilot Certification — Learning Sprint**
Duration: ~60 minutes | Format: talk + live demo + exam-style scenarios + quiz

---

## Exam coverage for this session

| Domain | Weight | Covered here |
| --- | --- | --- |
| Understand GitHub Copilot data and architecture | 10–15% | **Deep coverage** |
| Apply prompt engineering and context crafting | 10–15% | **Deep coverage** |
| Improve developer productivity with GitHub Copilot, including testing and security | 10–15% | **Deep coverage** |
| Configure privacy, content exclusions, and safeguards | 10–15% | **Exam reinforcement + troubleshooting** |
| **Total represented/reinforced by Week 3** | **40–60%** | |

> Blueprint: **skills measured as of August 7, 2026**. Week 1 owns the 25–30% features domain. Week 2 owns the separate responsible-AI domain and introduces privacy/safeguards. **Week 3 deliberately reinforces the 10–15% privacy/content-exclusion/safeguards domain because it is tightly coupled to data flow, context, secure development, and likely scenario questions.**

### Exam objective traceability — nothing in this Week 3 scope should be invisible

| Official objective | Where learners see it |
| --- | --- |
| Data usage, flow, and sharing | 1.2–1.3 |
| Input processing and prompt building | 1.2, 1.6 |
| Proxy filtering and post-processing | 1.4 |
| Code suggestion lifecycle | 1.2 + lifecycle diagram |
| LLM/Copilot limitations | 1.6, 3.9, 4.5 |
| Prompt structure, context determination, zero/few-shot | Part 2 |
| Prompt process flow + chat history | 2.4 |
| Code generation, refactoring, docs, sample data, legacy modernization | Part 3 |
| Unit/integration tests, edge cases, assertions | Part 4 |
| Security improvements + performance optimization | 3.6, 4.4 |
| Content exclusions + editor settings | Part 5 |
| Ownership/limitations of output | 5.4 |
| Public-code matching safeguards | 1.4, 5.6 |
| Troubleshoot suggestions/content exclusions | 5.5 |

**Candidate baseline:** there is no mandatory prerequisite certification. Candidates should know GitHub fundamentals, have experience with at least one programming language, and have hands-on GitHub Copilot experience. The passing scaled score is **700**.

---

## Run sheet

| Time | Segment |
| --- | --- |
| 0:00–0:03 | Opening, exam map, and objectives |
| 0:03–0:17 | Part 1 — How Copilot works: architecture, data flow, lifecycle, limitations |
| 0:17–0:27 | Part 2 — Prompt crafting, context, and chat history |
| 0:27–0:30 | **Demo 1** — context makes or breaks the suggestion |
| 0:30–0:38 | Part 3 — Developer productivity, modernization, security, performance |
| 0:38–0:46 | Part 4 — Testing with Copilot |
| 0:46–0:48 | **Demo 2** — the "passing test on buggy code" trap |
| 0:48–0:57 | Part 5 — Privacy, content exclusions, public-code safeguards, troubleshooting |
| 0:57–1:00 | Exam-style quiz + takeaways + Week 4 handoff |

> **If you must stay at 50 minutes:** move §3.3 large-repository workflow, §3.8 metrics, and Demo 3 to the appendix. Do **not** cut Part 5; it maps directly to a 10–15% exam domain.

> **Demo runbooks** — full setup, exact prompts, and failure recovery live in [`demos/`](demos/):
> [Demo 1](demos/demo-1-context-makes-the-suggestion.md) · [Demo 2](demos/demo-2-passing-test-on-buggy-code.md) · [Demo 3 (optional)](demos/demo-3-large-repo-two-phase-flow.md).
> Ready-to-run starter folders are in [`demos/sandboxes/`](demos/sandboxes/).
> **Open each sandbox as its own VS Code window** — nested inside this workspace, custom instructions do not load and the deck itself pollutes retrieval.
> Every runbook must be rehearsed once beforehand — model behaviour drifts.

---

## 0. Opening (3 min)

**Hook:** "The architecture questions sound simple until someone asks you to say exactly where your code goes, what gets retained, and what comes back."

Five things everyone should leave with:

1. Be able to draw the Copilot request/response flow on a whiteboard.
2. Be able to explain *why* a suggestion was bad in terms of missing context.
3. Distinguish **retrieval**, **prompt/context**, **policy filtering**, and **model generation**.
4. Never trust an AI-generated test or security fix without validation.
5. Know which control to use: **editor setting**, **content exclusion**, or **public-code matching policy**.

---

## Part 1 — How GitHub Copilot works and handles data (14 min)

### 1.1 The 30-second mental model

Copilot is **not merely searching for an answer to copy**. It selects relevant context, assembles a prompt, and asks a large language model to generate likely next tokens. Semantic search may help find context, but generation and retrieval are different steps.

```text
┌────────────┐   1. context     ┌──────────────┐   3. prompt    ┌──────────┐
│  Your IDE  │ ───────────────► │   Copilot    │ ─────────────► │   LLM    │
│  / Editor  │                  │ Proxy Service│                │  Model   │
│            │ ◄─────────────── │  (filters)   │ ◄───────────── │          │
└────────────┘   6. suggestion  └──────────────┘   4. completion└──────────┘
      │                                 │
      │ 2. prompt assembly              │ 5. post-response filtering
      │    (open tabs, symbols,         │    (public-code match,
      │     path, language, chat        │     safety / policy controls)
      │     variables)                  │
```

### 1.2 Step-by-step data flow

1. **Trigger** — you type, pause, or send a chat message.
2. **Context gathering and prompt assembly** — the client and Copilot service select context appropriate to the surface, such as:
   - the current file and cursor position (prefix + suffix)
   - snippets from relevant neighboring open tabs
   - file path, file name, language ID
   - symbol/type information from the language server
   - for Chat: history, attachments, explicit references, and retrieved repository context
3. **Secure transmission and pre-processing** — the request travels over HTTPS through GitHub's proxy, which applies prompt and safety controls.
4. **Inference** — the model generates candidate completions.
5. **Post-processing** — surface-appropriate safety, quality, and optional public-code controls run before delivery.
6. **Display** — ghost text, chat panel, or code block.
7. **Developer decision** — you accept, edit, reject, or give explicit feedback. These actions can produce engagement data; they do **not** mean that the model immediately learns from your code.

### 1.3 Data usage, flow, and sharing — exam wording to know

The exam objective says **usage, flow, and sharing**, not just "where does the prompt go?" Think in four data categories:

| Data category | Example | Why GitHub processes it |
| --- | --- | --- |
| **Prompts / inputs** | Chat request, code around cursor, attachments | Generate a response or suggestion |
| **Suggestions / outputs** | Ghost text, chat answer, generated code | Deliver the Copilot service |
| **User engagement data** | Accepted/dismissed suggestion, usage telemetry | Operate, secure, measure, and improve the service |
| **Feedback data** | Thumbs up/down, optional comments | Troubleshooting and product improvement |

The processing path can vary by selected model, but the exam-safe model is:

```text
Developer / IDE
      │ selected prompt + context
      ▼
GitHub Copilot service / proxy
      │ safety + policy controls
      ▼
Selected model used for inference
      │ generated candidate
      ▼
GitHub Copilot post-processing
      │
      ▼
Developer validates / accepts / rejects
```

**High-value distinction:** **processing is not the same as model training.** GitHub states that Copilot Business and Enterprise customer data is not used to train AI models. For individual Free/Pro/Pro+/Max subscriptions, GitHub may use Copilot interaction data for model training, and the user can opt out in personal Copilot settings.

> **Exam scenario:** "The request is processed by a model" does **not** imply "the customer's code is added to the training set." Treat data processing, retention, and training as separate questions.

### 1.4 The filters (high-value exam material)

Applied through the **Copilot proxy service**, with exact behavior varying by surface and policy:

| Filter | What it does |
| --- | --- |
| Harmful / offensive content | Safety controls can block or suppress unsafe content |
| Prompt / request controls | Pre-processing and policy checks can reject or modify unsupported requests |
| Quality / security checks | Copilot applies post-processing appropriate to the feature and model |
| Public code matching | Policy can block matching suggestions or allow them with code references |

> Exact filters and their ordering vary by feature/model and can evolve. **For the exam, know the lifecycle and the purpose of proxy/pre- and post-processing rather than memorizing an implementation detail that may change.**

**Exam trap — Block versus Allow:**

- **Block matching suggestions:** matching public-code suggestions are discarded/suppressed.
- **Allow matching suggestions:** code referencing can identify matching public repositories and available license information so the developer can decide what to do.
- GitHub's current code-referencing documentation describes comparison using the proposed suggestion plus surrounding code of roughly **150 characters**. Treat this as implementation detail, not the concept to memorize.
- The setting can be controlled by an individual, organization, or enterprise policy, depending on the subscription.

### 1.5 Data retention — say it precisely

Retention depends on both the **plan** and the **surface**. Do not confuse **chat history**, **local/session state**, **service retention**, **engagement telemetry**, and **model training** — they are different things.

Current default behavior documented by GitHub for **Copilot Business / Enterprise**:

| Access path | Prompts and suggestions |
| --- | --- |
| **IDE Chat and IDE code completions** | **Not retained by default** |
| **Other Copilot access and use** — including github.com, mobile, and Copilot CLI | **Retained for up to 28 days by default** |

Additional exam-safe facts:

- **Business / Enterprise:** GitHub states that customer data is **not used to train AI models**.
- **Individual Free / Pro / Pro+ / Max:** GitHub may use Copilot interactions — prompts, outputs, code snippets, and context — to train/improve AI models; users can opt out in Copilot settings.
- **User engagement data** is a different category from prompts/suggestions and can have a different retention period.
- A surface may keep **conversation/session history** to provide the feature. For example, GitHub.com Copilot Chat keeps recent conversations for a limited period, and Copilot CLI maintains local session state; do not infer the service's prompt-retention policy from what the UI can display.

> **Exam trap:** "Copilot remembers the earlier turn" and "GitHub retains the prompt as service data" are not interchangeable statements.

### 1.6 The context window — the budget everything competes for

#### 1.6.1 What it actually is

The context window is the **maximum number of tokens a model can consider in one model call**. It is a per-call limit, not the repository index and not durable memory. One Chat turn or agent task can involve multiple model calls, each with newly selected or compacted context.

Two numbers people conflate:

| Term | Meaning |
| --- | --- |
| **Model context window** | The model provider's ceiling for one call. It varies by model and surface; some current models offer extended context up to one million tokens. |
| **Copilot's prompt budget** | What Copilot selects and fits into a particular call. Inline completions typically use a latency-optimized subset rather than the model's full capacity. |

Token counts are model-specific. Use estimates only to explain scale, never as guaranteed product limits.

#### 1.6.2 Everything competes for the same budget

| Slice of the window | Who puts it there |
| --- | --- |
| System prompt | GitHub / the extension — invisible to you |
| Custom instructions | `copilot-instructions.md`, `*.instructions.md`, `AGENTS.md`, personal instructions |
| Tool definitions | Agent mode — descriptions and schemas for available tools |
| Explicit references | `#file`, `#selection`, attachments, pasted text |
| Implicit context | Active file, cursor position, selection, neighbouring open tabs |
| Retrieved chunks | `@workspace` / `#codebase` semantic search results |
| Tool results | Terminal output, file reads, search results, test output |
| Conversation history | Previous turns in this session |
| Your actual question | You |
| Reserved output | Capacity for the model's answer |

> **Line to land:** every token spent on noise is a token unavailable for the answer.

**The selection funnel** — everything that happens *before* the window is even relevant:

```text
  large repository sitting on disk
        │
     ├──►  ✘  BLOCKED OR INELIGIBLE
     │        policy exclusions · unsupported/binary content · permissions
        │
        ├──►  ✘  NOT SELECTED — eligible, but nothing pointed at it
        │        closed files · unreferenced · didn't rank in retrieval
        │
        ▼
   SELECTED
   open-file snippets · explicit references · retrieved chunks
        │
        ▼
   PROMPT ASSEMBLY      rank · dedupe · truncate
        │
        ▼
    PROXY CONTROLS       safety and policy checks
        │
        ▼
 ┌──────────────────────────────────────────────┐
 │  MODEL-SPECIFIC CONTEXT WINDOW · one call   │
 │  selected input + capacity for the output   │
 └──────────────────────────────────────────────┘
        │
        ▼
      MODEL
```

Two different "no" answers matter: content can be **blocked or ineligible**, or it can be eligible but simply **not selected**. Better references can fix selection; they cannot override policy or permissions.

> Content exclusion has limitations. At the time of this deck it is not supported in IDE Edit and Agent modes, and IDE-provided type or symbol information can indirectly expose semantics from an excluded file. It also has limitations for symlinks and remote filesystems. Week 2 owns the full policy discussion.

#### 1.6.3 Surface differences and practical fixes

| Surface | Typical context pattern |
| --- | --- |
| Inline completion | Prefix, suffix, file metadata, language information, and selected open-file snippets; optimized for low latency using Fill-in-the-Middle |
| Chat | User prompt, attachments, instructions, history, and retrieved repository context |
| Agent mode | A sequence of model calls that adds tool schemas and results; older material may be dropped, summarized, or compacted |

Example: if `discount.ts` is attached but retrieval misses `tiers.ts`, Copilot may never see the enterprise multiplier. Attach `tiers.ts` and ask again: the user text is the same, but the **assembled prompt** is different.

The whole repository, runtime state, external systems, and private resources are not automatically available. They require retrieval, an explicit attachment, or an authorized tool. If quality drifts, start a new chat for a new task, attach controlling evidence, split broad work, and reduce noisy tool output.

> **Exam trap:** an indexed codebase is not inside the context window. The index finds candidate chunks; only selected chunks enter a model call.

### 1.7 Models, indexing, and customization

#### 1.7.1 Models

- **Model choice** affects quality, latency, context capacity, and AI-credit consumption. **Auto** suits most requests; switch deliberately for complex reasoning or extended context.
- A model's **knowledge cutoff** can cause invented or stale APIs. Supply current evidence through repository code, documentation, web search, or another enabled tool. Model and bring-your-own-model availability varies by client, plan, and policy.

**Mental model for limitations:** an LLM generates a statistically likely continuation from the prompt and context. It does not automatically query a verified database, execute your program, know production state, or prove that generated code is correct.

```text
prompt + selected context ──► probabilistic generation ──► plausible output
                                                     └──► may be wrong
```

Suggestion quality can also vary by language, framework, and task because training coverage and available context differ. **Plausible is not the same as verified.**

#### 1.7.2 Codebase indexing is not the context window

These get conflated constantly, and the exam leans on the difference. The one-line version: **indexing is how Copilot *finds* code; the context window is how much of it can *travel* with your request.**

| | Codebase index | Context window |
| --- | --- | --- |
| What it is | A searchable map of eligible repository content, split into chunks and represented for semantic matching | A hard token ceiling on one model call |
| Lifetime | Persistent and refreshed | Call-specific |
| Job | **Find and rank** candidate chunks | **Bound** the selected input and output for this call |

**Analogy for the room:** the index is a library **catalogue**; the context window is the **desk**. The catalogue can locate many books, but only selected material goes on the desk for this call.

#### 1.7.3 Where indexing is and is not used

- Repository-aware Chat on GitHub and in VS Code, plus Copilot cloud agent, can use semantic indexing. Inline completion primarily uses local editing context; grep and exact text search do not require the semantic index.
- GitHub repositories are indexed automatically when repository context is used. Non-GitHub VS Code indexing uploads workspace data to GitHub, is GitHub.com-only, and is disabled by default for Business/Enterprise until an owner enables it.
- Without an index, Copilot can still use exact search, file reads, and language tools. Retrieval failure can be silent, so attach the controlling file when you know it.

#### 1.7.4 Org-level customization

- **Copilot Spaces** collect repositories, code, issues, pull requests, notes, images, and files into durable shared context. Spaces work in GitHub Chat and can be accessed from an IDE through the GitHub MCP server.
- **Custom instructions and prompt files** persist team conventions and reusable workflows; **custom agents and MCP servers** specialize behavior and connect approved tools or external knowledge.

### 1.8 Talking points / likely exam questions

- "Which component applies the public code filter?" → the **proxy service**.
- "Does Copilot send my entire repository?" → No. It sends an assembled, size-limited prompt.
- "Does a bigger context window mean Copilot reads my whole repo?" → No. It raises the ceiling; the client still selects and truncates what goes in.
- "What does indexing actually buy me?" → *Retrieval*, not capacity. It finds the chunks; the window still limits what travels.
- "What happens when matching public code is allowed?" → Code referencing can show source links and available license information.
- "Why did Copilot suggest a function that does not exist?" → Probabilistic generation + knowledge cutoff + insufficient context. Not a bug.

### 1.9 Exam-style architecture scenarios

1. **An indexed repository contains the answer, but Chat misses the controlling file. What should you do first?**  
   **Answer:** attach/reference the file or selection explicitly. Indexing improves retrieval; it does not guarantee selection.

2. **A developer says, "Copilot processed our code, therefore GitHub trained the model on it." What is wrong?**  
   **Answer:** processing, retention, and training are separate data-handling concepts. Business/Enterprise data is not used to train AI models.

3. **A generated method does not exist in the installed SDK. Which two causes are most likely?**  
   **Answer:** insufficient/current context and model knowledge limitations. Verify against the actual types/docs.

---

## Part 2 — Prompt crafting and prompt engineering (10 min)

### 2.1 The four principles (memorize these)

| Principle | Meaning | Anti-pattern |
| --- | --- | --- |
| **Single** | One task per prompt | "Refactor this, add tests, and write the README" |
| **Specific** | State inputs, outputs, constraints, framework | "Make it better" |
| **Short** | Concise, no rambling context dump | 400-word essay prompt |
| **Surround** | Give Copilot the right surrounding context | Only the target file open |

Class mnemonic: **4S — Single, Specific, Short, Surround.** It is a memory aid, not official GitHub exam terminology.

A practical prompt shape is: **goal + relevant context + constraints + examples (when useful) + acceptance criteria**.

#### Map the 4S mnemonic to GitHub's official prompt guidance

| 4S memory aid | Official guidance learners should recognize |
| --- | --- |
| **Single** | Break complex tasks into simpler tasks |
| **Specific** | Avoid ambiguity; state the goal and relevant constraints |
| **Short** | Keep only useful evidence; iterate instead of dumping noise |
| **Surround** | Indicate relevant code, open relevant files, attach references |
| — | Give examples when format/convention matters |
| — | Experiment and iterate |
| — | Keep chat history relevant; start a new conversation for a new task |

### 2.2 Prompt patterns

- **Zero-shot** — just ask. Fine for common, well-known tasks.
- **One-shot / few-shot** — provide 1–3 examples of input → output. Best for conventions, formatting, DSLs, and internal style.
- **Plan-first / decomposition** — ask for a short plan or checklist before implementation when the task has several dependent steps.
- **Role prompting** — "Act as a security reviewer for this Express handler."
- **Iterate within a focused task** — use follow-ups while the conversation history is relevant; start a fresh chat when the task or evidence changes.

#### Few-shot example

```text
Convert these to our internal error format.

Input:  throw new Error("not found")
Output: throw new AppError(ErrorCode.NOT_FOUND, "not found")

Input:  throw new Error("bad input")
Output: throw new AppError(ErrorCode.VALIDATION, "bad input")

Now convert the errors in the selected file.
```

### 2.3 Context is a prompt-engineering technique

Use roughly this order:

1. **Name the goal and acceptance criteria** — say what must be true when the work is complete.
2. **Attach the controlling files or selection** — explicit context is the most reliable option when you know where the answer lives.
3. **Open related files for inline completion context** — types, interfaces, tests, and similar implementations can improve ghost text.
4. **Use meaningful names and concise intent comments** — `calculateMonthlyInterest` beats `calc`.
5. **Include an example input/output** or a sample of real data.

### 2.4 Prompt process flow + chat history — explicit exam objective

A useful way to reason about a Chat request is to picture the assembled prompt as layers:

```text
System / product instructions
          +
Applicable custom instructions
          +
Current user request
          +
Explicit references (#file, selection, attachments)
          +
Implicit IDE context (active file, open tabs, symbols)
          +
Retrieved repository context
          +
Relevant conversation history
          ↓
     ASSEMBLED PROMPT
          ↓
         LLM
          ↓
       RESPONSE
```

**Chat history helps continuity but competes for context.** Use follow-ups while the task and evidence remain relevant. When you switch to an unrelated task, start a new conversation/thread. Long histories can carry stale assumptions, irrelevant tool output, and old constraints into later turns.

> **Exam scenario:** after several unrelated questions in one long chat, answers become less relevant. The best first fix is usually **start a new focused conversation and re-supply the controlling context**, not "index more files."

### 2.5 Persistent context: custom instructions & prompt files

| Mechanism | File | Scope |
| --- | --- | --- |
| Repository custom instructions | `.github/copilot-instructions.md` | Repository-wide guidance on supported Copilot surfaces |
| Path-scoped instructions | `.github/instructions/*.instructions.md` with `applyTo:` frontmatter | Matching files only |
| Agent instructions | `AGENTS.md` | Supported agentic and coding-agent workflows |
| Reusable prompts | `.github/prompts/*.prompt.md` | Invoked on demand |
| Personal instructions | GitHub.com Copilot settings | Follows the user across repos |

Example `*.instructions.md`:

```markdown
---
applyTo: "**/*.test.ts"
---
- Use Vitest, not Jest.
- Arrange–Act–Assert with blank-line separation.
- No snapshot tests.
```

**Good custom instructions describe:** tech stack, coding style, folder conventions, preferred libraries, things to avoid.
**Avoid:** conflicting rules, volatile facts, vague slogans, and links without the essential guidance in the file. Keep instructions short enough to earn their place in every applicable request.

### 2.6 Slash commands, participants, and variables

Names and syntax vary across IDEs and releases, so teach the concepts rather than requiring learners to memorize one client's menu:

| Type | Examples | Purpose |
| --- | --- | --- |
| Commands | `/help`, `/new`, `/compact`, and task shortcuts where supported | Control a session or invoke a common workflow |
| Explicit context | Attach Context UI, files, selections, images, terminal output; references such as `#file` where supported | Pin evidence instead of relying on retrieval |
| Agents and tools | Workspace/terminal tools, custom agents, MCP servers | Search, act, or fetch context from another system |

Current surfaces to recognize: **inline and next-edit suggestions, Chat, inline chat, Copilot Edits, Plan and Agent modes, GitHub Copilot CLI, Copilot Code Review, Copilot cloud agent, Copilot Spaces, and Copilot Spark**. Week 1 owns detailed feature operation.

### 2.7 Why prompts fail

| Symptom | Cause | Fix |
| --- | --- | --- |
| Hallucinated API | Knowledge cutoff / no context | Open the library's type definitions or paste the signature |
| Ignores your conventions | No persistent instructions | Add `copilot-instructions.md` |
| Generic boilerplate | Prompt too vague | Add constraints, examples, expected output |
| Wrong framework | Ambiguous project signals | Name the framework and version explicitly |
| Truncated / partial answer | Context window overflow | Narrow the scope, split the task |

### 2.8 Exam-style prompting scenarios

1. **You need output in a strict internal DSL format. Which technique is strongest?**  
   **Answer:** provide one or more input→output examples — few-shot prompting.

2. **Copilot keeps using Jest although the repository standard is Vitest for `*.test.ts`. What is the durable fix?**  
   **Answer:** path-scoped custom instructions, rather than repeating the rule in every prompt.

3. **A prompt says "make this better" and produces generic changes. What is missing?**  
   **Answer:** specificity — define the goal, constraints, relevant context, and acceptance criteria.

---

## Demo 1 — Context makes or breaks the suggestion (3 min)

> **Full runbook:** [demos/demo-1-context-makes-the-suggestion.md](demos/demo-1-context-makes-the-suggestion.md) — sandbox files, exact prompts, recovery table, reset script.

1. **Cold start:** open a single empty file, ask for `createInvoice()`. Show generic, invented types.
2. **Warm start:** open `types/invoice.ts` and `services/orderService.ts` in adjacent tabs, retype the same prompt. Show it now uses your real types.
3. **Persistent:** add a `.github/copilot-instructions.md` with the team's stack, reload, re-ask. Show conventions applied without prompting.

**Line to land:** "Same user text, three different assembled prompts. The variable was the context."

---

## Part 3 — Developer use cases for AI (8 min)

### 3.1 Reduce toil

Boilerplate, scaffolding, DTOs, config files, regex, SQL, data transformations, `.gitignore`, and Dockerfiles. Generate **synthetic sample data and fixtures** for development and tests; never substitute real production data containing secrets or personal information.

### 3.2 Comprehension and onboarding

- `/explain` on unfamiliar code, `@workspace` questions about architecture.
- Legacy code archaeology: "What does this COBOL-era stored procedure do, in plain English?"
- Explaining error messages and stack traces.
- Using the current **GitHub Copilot CLI**: run `copilot` for an interactive session, then ask it to explain a command, inspect a project, plan work, or make an approved change. Older CLI extensions are not the current exam focus.

### 3.3 Working in a large repo — set up once, then work in two phases

This is the practical payoff of Part 1. In a big codebase you cannot load the repo into the window, and you should stop trying. Instead you build **compact, durable context artifacts** that get selected automatically, then split exploration from implementation.

#### 3.3.1 One-time setup, per repo

| Step | Why it matters |
| --- | --- |
| **Know which indexing policy applies** | GitHub repositories index automatically when repository context is used; non-GitHub VS Code workspaces require the semantic-indexing policy |
| **Keep search results high-signal** | Exclude generated output from editor search where appropriate so exact searches and agent exploration return less noise |
| **Write `.github/copilot-instructions.md` as a map** | Module boundaries and "where things live" let the agent aim its searches instead of fishing |
| **Add path-scoped `.github/instructions/*.instructions.md`** | Backend conventions stop burning tokens on frontend work |

How indexing works:

| Repo type | Index behaviour |
| --- | --- |
| Repository on GitHub | Indexed automatically in the background when a conversation uses repository context; updates are normally incremental |
| Non-GitHub repository in VS Code | Workspace data is uploaded to GitHub for semantic indexing; available on GitHub.com only and disabled by default for Business/Enterprise until an owner enables it |
| Semantic index unavailable | Copilot can still use exact text search, file reads, and language tools |

Eligibility, content exclusions, permissions, and supported file types determine what can be indexed or retrieved. Do not treat `.gitignore`, editor search exclusions, and Copilot content exclusions as interchangeable controls.

#### 3.3.2 The two-phase feature flow

```text
  ┌────────────────────┐     ┌────────────────────┐     ┌────────────────────┐
  │  CHAT 1            │     │  YOU               │     │  CHAT 2            │
  │  investigate       │ ──► │  review & correct  │ ──► │  implement         │
  │  no code changes   │     │  the spec          │     │  spec pinned       │
  └────────────────────┘     └────────────────────┘     └────────────────────┘
      writes                  the step everyone         fresh window,
      docs/specs/x.md         skips — and the           almost no
                              whole point               exploration
```

**Phase 1 — investigate, and write it down.** New chat:

```text
Investigate how order pricing works in this repo. Trace the call path from the
API handler through to persistence. List the files involved, the key types, and
anything surprising. Write your findings to docs/specs/discount-tiers.md.
Do not change any code.
```

**Then read and fix that file yourself.** This is the step people skip, and it is the whole point — it is where you add the constraint that is not in the code and the reason the weird branch exists.

**Phase 2 — implement in a brand-new chat**, pinning the artifact:

```text
#file:docs/specs/discount-tiers.md  #file:src/billing/discount.ts
Implement the enterprise tier multiplier per the spec.
```

**Why two chats, not one:** exploration can leave a long history of searches, file reads, and test output. Starting fresh gives implementation a focused history whose highest-signal content is a spec you already verified.

If you repeat the pattern, park the Phase 1 prompt in `.github/prompts/investigate.prompt.md` so it is one invocation instead of retyping.

> **Demo this live:** [demos/demo-3-large-repo-two-phase-flow.md](demos/demo-3-large-repo-two-phase-flow.md) — 5 min, with a 3-minute short cut.

#### 3.3.3 Steering individual requests

- Copilot and its agents can invoke semantic search automatically. Use a repository-context reference such as `#codebase` only where the client supports it and you intentionally want to force broad retrieval.
- Prefer pinning with `#file` over hoping retrieval ranks the right chunk. **Retrieval failure is silent** — you get a confident wrong answer, not an error.
- Use real class and function names in the prompt so the agent can match exactly.
- To inspect an upstream repository, attach or fetch it through a context source supported by your current client, subject to your permissions.
- Semantic retrieval is not exhaustive. For whole-repository counts such as "how many callers does this have?", ask Copilot to use exact search or code-reference tools and verify the result.

> **Line to land:** in a large repo, your job is not to give Copilot the most context — it is to provide the right evidence.

### 3.4 Refactoring and modernization

- Extract method, remove duplication, improve naming.
- Language/framework translation (Python → Go, Struts → Spring, class components → hooks).
- Dependency upgrades and deprecated-API replacement.
- **Constraint to state out loud:** Copilot refactors *what it can see*. Cross-repo refactors need scoping.

### 3.5 Documentation

Docstrings/JSDoc/XML comments, READMEs, ADRs, API docs, changelogs, **commit messages**, **PR descriptions and summaries**.

### 3.6 Debugging and code quality

- `/fix` on a failing selection; explain a stack trace; generate logging.
- **Copilot Code Review** — AI review comments on a PR, as a first pass before human review.
- **Copilot Autofix** with GitHub Advanced Security — suggested remediation for code-scanning alerts.
- **Performance optimization** — ask Copilot to identify likely bottlenecks and propose alternatives, then validate with a profiler, benchmark, realistic workload, and before/after measurements. A plausible optimization is not proof of improvement.

#### Security-improvement scenario — explain, remediate, then verify

```javascript
app.get("/invoice", (req, res) => {
  db.query(`SELECT * FROM invoice WHERE id=${req.query.id}`);
});
```

Useful prompt:

```text
Review this handler for security weaknesses. Explain each issue first.
Then propose the smallest safe change while preserving the API contract.
Include validation and authorization assumptions explicitly.
```

Expected review themes include parameterized queries / injection prevention, input validation, authorization, error handling, and avoiding sensitive error disclosure. **Copilot's security suggestion is a hypothesis, not a security verdict** — validate with tests, human review, and security tooling such as code scanning/CodeQL where available.

### 3.7 Copilot across the SDLC

```text
Issue ──► Copilot cloud agent ──► Agent session ──► Branch + PR
  │                                              │
  │                                              ├─► Copilot Code Review
  ├─► Chat & completions while coding            ├─► PR summary generation
  └─► /tests for coverage                        └─► Autofix on scanning alerts
```

### 3.8 Measuring impact

- **Copilot Metrics API** / usage reports: active users, engaged users, suggestions shown/accepted, acceptance rate, lines accepted, chat turns, PR summaries created.
- Acceptance rate alone is a **vanity metric**. Pair it with cycle time, PR throughput, defect rate, and developer satisfaction surveys.
- Usage/metrics reports are designed for adoption and activity analysis; do not treat aggregate metrics as a transcript of developers' prompts.

### 3.9 Limitations to name explicitly

Non-determinism, knowledge cutoff, no runtime awareness, potential for insecure or non-performant code, licence/IP considerations for suggestions, and **automation bias** — the human tendency to over-trust generated output. The developer remains accountable for everything merged.

---

## Demo 3 — Onboarding a large repo (optional, 5 min)

> **Full runbook:** [demos/demo-3-large-repo-two-phase-flow.md](demos/demo-3-large-repo-two-phase-flow.md)

**Only run this if the audience works in large repos** — and if so, swap it *in place of* Demo 1 rather than adding it, or you will overrun.

1. **Show the scale** — compare the repository with a model-specific, per-call context limit.
2. **Phase 1:** agent investigates a subsystem and writes `docs/specs/<subsystem>.md`. Narrate the tool calls scrolling past — that is the context-budget discussion in §1.6 happening live.
3. **The human step:** correct one thing in the spec that the code cannot tell you.
4. **Phase 2:** brand-new chat, pin the spec, implement. Point at how little exploration it needs.

**Line to land:** "Same repository and tooling; the run with verified, focused context knew where it was going."

---

## Part 4 — Testing with GitHub Copilot (8 min)

### 4.1 Generating unit tests

- Use `/tests` where supported, or ask directly for tests for a selected function. Inline chat is useful for one focused case.
- Copilot infers the framework from imports, config files, and neighboring test files — so **open an existing test file** before generating.
- Use **Plan mode** to outline the test strategy and **Agent mode** to create, run, and iterate on tests. Review the plan, commands, diffs, and assertions before accepting changes.
- Ask explicitly for the shape you want:

```text
Generate pytest unit tests for `parse_duration`.
Cover: valid "1h30m", zero, negative, empty string, and None.
Use parametrize. No mocking — the function is pure.
```

### 4.2 Edge cases and test data

Prompt pattern: *"List the edge cases for this function before writing any tests."* Then: *"Now write tests for cases 3, 5, and 7."*

Typical categories to prompt for: empty/null, boundary values, off-by-one, unicode, very large input, concurrency, timezone/DST, malformed input, permission failures.

### 4.3 Beyond unit tests

- **Integration tests** — Testcontainers, in-memory DBs, HTTP mocking.

Example prompt:

```text
Create an integration test for POST /orders using the repository's existing
Testcontainers PostgreSQL setup. Seed one customer, call the real HTTP route,
assert status 201 and verify the persisted order. Do not mock the repository layer.
```

The exam distinction: a **unit test** isolates a small unit (often with test doubles); an **integration test** verifies that multiple real components work together.
- **E2E** — Playwright/Cypress selectors and flows.
- **Mocks and stubs** — generating test doubles from an interface.
- **Regression tests from bug reports** — paste the issue, ask for a failing test first.
- **Test refactoring** — deduplicate setup, introduce fixtures/builders.

### 4.4 Security-oriented testing

- Ask Copilot to review for OWASP Top 10 issues in a diff.
- Generate negative tests: injection payloads, authz bypass attempts, oversized input.
- Combine with **CodeQL / code scanning** and **secret scanning** — Copilot complements, it does not replace, SAST.
- Never paste real secrets or production data into a prompt.

### 4.5 The critical caveat (this is an exam theme)

> When Copilot is grounded mainly in the implementation, it can mirror what the code **does**, including a bug, instead of what the specification says it **should do**.

If the implementation has a bug and the expected behavior is not supplied, Copilot may write a test that preserves the buggy behavior — and it can pass. Mitigations:

1. Write or review the **specification** first; test against intent, not implementation.
2. Read every generated assertion.
3. Use coverage as a signal, never as proof of correctness.
4. Consider mutation testing to validate that the tests actually detect faults.

---

## Demo 2 — The passing test on buggy code (2 min)

> **Full runbook:** [demos/demo-2-passing-test-on-buggy-code.md](demos/demo-2-passing-test-on-buggy-code.md) — includes the constructive second half and a subtler backup bug for when the model spots this one.

```python
def apply_discount(price, percent):
    return price - (price * percent)   # BUG: percent is 0-100, not 0-1
```

Ask Copilot to generate tests from the implementation without supplying the specification. It may generate something like `assert apply_discount(100, 20) == -1900` — **the test passes and the bug ships.** Model output is nondeterministic, so rehearse the backup case in the runbook.

**Line to land:** "Green does not mean correct. It means consistent."

---

## Part 5 — Privacy, content exclusions, and safeguards (9 min)

> Week 2 may introduce these controls, but this section is the **exam-ready reinforcement** for the official 10–15% privacy/content-exclusion/safeguards domain.

### 5.1 Three controls candidates commonly confuse

| Control | Primary purpose | Typical owner/scope |
| --- | --- | --- |
| **Editor / IDE Copilot settings** | Turn Copilot or suggestions on/off for the local environment or languages | Individual developer / editor configuration |
| **Content exclusion** | Prevent configured files/paths from informing supported Copilot experiences | Repository admin, organization owner, enterprise owner — Business/Enterprise |
| **Suggestions matching public code policy** | Decide whether matching public-code suggestions are blocked or allowed with references | Individual or organization/enterprise policy depending on license |

These controls solve different problems. A local language preference is not the same as governance over sensitive repository content, and neither is the same as public-code matching.

### 5.2 Editor settings — use the smallest control that solves the problem

Example VS Code setting:

```json
{
  "editor.inlineSuggest.enabled": true,
  "github.copilot.enable": {
    "*": true,
    "yaml": false,
    "plaintext": false,
    "markdown": true,
    "python": true
  }
}
```

**Scenario:** "I want Copilot generally enabled, but I do not want inline suggestions while I edit YAML on my workstation."  
**Best answer:** use the editor/language setting. Do not create an organization-wide content-exclusion rule for a personal editor preference.

### 5.3 Content exclusion — what it does, who configures it, and where it stops

For Copilot Business/Enterprise, content exclusion can be configured by repository administrators, organization owners, and enterprise owners.

Repository-level path example:

```yaml
- "/secrets/**"
- "/legacy/regulated/**"
- "*.pem"
```

For supported surfaces, excluded content means:

- inline suggestions are unavailable **in** the affected files
- affected content does not normally inform inline suggestions in other files
- affected content does not normally inform Copilot Chat responses
- affected files are not reviewed by Copilot code review

**Critical limitations to memorize conceptually:** content exclusion is **not universal across every Copilot surface**. Current GitHub documentation explicitly notes that **Copilot CLI, Copilot cloud agent, and Agent mode in IDE Chat do not support content exclusion**. GitHub also documents limitations for symlinks, remote filesystems, and semantic information indirectly supplied by the IDE (for example type/symbol information).

> **Exam trap:** a content exclusion is a governance control, but it is not a magic data-loss-prevention boundary for every agent/tool/surface. Know the documented scope and limitations.

### 5.4 Ownership and limitations of outputs

GitHub's current terms make three distinct points:

1. **GitHub does not claim ownership of your Input or Output.**
2. Output may resemble third-party code or be subject to copyright/open-source license terms.
3. The user remains responsible for reviewing, testing, validating, and determining whether the output can be used lawfully and safely.

```text
"GitHub does not claim ownership"
              ≠
"I automatically own every generated line"
              ≠
"There is no licensing, security, or quality risk"
```

**Exam answer pattern:** generated code is **developer responsibility**. Check correctness, security, licensing/provenance where relevant, and organizational policy before merging.

### 5.5 Troubleshoot suggestions and content exclusions — decision tree

```text
"Copilot is not giving the suggestion/context I expected"
                         │
                         ▼
                Is Copilot enabled?
                   ├─ No  → enable/configure the editor
                   └─ Yes
                         │
                         ▼
             Is the language/feature enabled?
                   ├─ No  → enable the required feature/language
                   └─ Yes
                         │
                         ▼
                Is content excluded?
                   ├─ Yes → check inherited policy + surface support
                   └─ No
                         │
                         ▼
              Check prompt + selected context
                         │
                         ▼
         Could public-code matching suppress output?
                         │
                         ▼
              Check auth / network / product logs
```

Two different "no" answers matter:

- **Eligible but not selected:** improve references, prompt, or retrieval.
- **Blocked/excluded by policy:** a better prompt cannot override the policy.

When content-exclusion rules were just changed, verify that the client has refreshed the policy and test the exclusion in a supported surface. Also check inherited organization/enterprise rules that a repository cannot override.

### 5.6 Public-code safeguards — scenario language

- **Block** → matching suggestion is discarded/suppressed.
- **Allow** → matching suggestion can be shown and code referencing can provide source/license information.
- The policy is separate from content exclusion and separate from editor enable/disable settings.

### 5.7 Exam-style privacy/safeguard scenarios

1. **A developer wants no Copilot completions only for YAML locally.**  
   **Answer:** editor/language setting.

2. **An organization wants a sensitive path ignored by supported Copilot Chat and inline suggestions.**  
   **Answer:** content exclusion at the appropriate repository/org/enterprise level.

3. **A file is excluded, but an Agent-mode workflow can still access it. Why?**  
   **Answer:** current content-exclusion support does not apply to Agent mode; understand surface limitations.

4. **Public-code matching is set to Allow and Copilot returns a matching snippet. What should the user expect?**  
   **Answer:** code referencing can show matching source repositories and available license information; the developer decides whether/how to use it.

5. **Who owns Copilot output?**  
   **Answer:** GitHub does not claim ownership, but that does not guarantee the user owns it free of third-party rights; the developer must review applicable rights and validate the output.

---

## Appendix A — Exam question bank (representative practice — not real exam items)

1. **Which sequence best represents a Copilot suggestion lifecycle?**  
   A. LLM → repository index → IDE  
   B. Context gathering → prompt building → proxy/policy processing → model inference → post-processing → display → developer decision  
   C. GitHub Search → copy public code → IDE  
   D. IDE → model training → suggestion  
   **Answer: B**

2. **An indexed repository contains `pricingRules.ts`, but Copilot misses its enterprise multiplier. What is the best immediate action?**  
   A. Disable the public-code filter  
   B. Attach/reference `pricingRules.ts` explicitly  
   C. Increase acceptance rate  
   D. Delete chat history only  
   **Answer: B**

3. **A developer provides two input→output examples before asking for a third transformation. Which prompting technique is this?**  
   A. Zero-shot  
   B. Few-shot  
   C. Retrieval exclusion  
   D. Post-processing  
   **Answer: B**

4. **A long Copilot Chat contains three unrelated tasks and quality is degrading. What is the best first action?**  
   A. Start a new focused chat and reattach the relevant evidence  
   B. Add every repository file  
   C. Disable safety filters  
   D. Increase model temperature  
   **Answer: A**

5. **A generated test suite passes on buggy code. What is the safest interpretation?**  
   A. The code is correct  
   B. The test may have learned implementation behavior instead of specification intent  
   C. Coverage proves correctness  
   D. Copilot silently fixed the bug  
   **Answer: B**

6. **Which test is most clearly an integration test?**  
   A. Calling one pure function with mocked dependencies  
   B. Starting the application's real HTTP route and a Testcontainers database, then asserting persisted state  
   C. Checking a regex against a string  
   D. Testing one class with every collaborator stubbed  
   **Answer: B**

7. **Copilot proposes an optimization that looks faster. What should happen next?**  
   A. Merge immediately  
   B. Benchmark/profile it with representative workloads and compare before/after results  
   C. Disable code review  
   D. Add more few-shot examples  
   **Answer: B**

8. **An organization enables Block for suggestions matching public code. What can happen to a matching suggestion?**  
   A. It is always shown with a citation  
   B. It can be suppressed/discarded  
   C. The matching repository is added to context  
   D. The developer's repository becomes public  
   **Answer: B**

9. **A team wants Vitest conventions applied only to `*.test.ts`. What is the strongest durable mechanism?**  
   A. Repeat "use Vitest" in every prompt  
   B. Path-scoped custom instructions  
   C. Content exclusion  
   D. Public-code matching  
   **Answer: B**

10. **A Business/Enterprise developer uses IDE Chat. Which statement is correct under GitHub's current default retention description?**  
    A. IDE Chat prompts and suggestions are retained indefinitely  
    B. IDE Chat prompts and suggestions are not retained by default  
    C. All engagement data is also deleted immediately  
    D. Processing means the data trains the model  
    **Answer: B**

11. **A Business/Enterprise developer uses Copilot CLI. Which statement best matches current GitHub guidance?**  
    A. Treat CLI exactly like IDE completions for retention  
    B. Other Copilot access such as CLI can retain prompts/suggestions for up to 28 days by default  
    C. CLI never keeps session state  
    D. CLI bypasses GitHub policies  
    **Answer: B**

12. **A content-exclusion rule is configured for `/secrets/**`. Which statement is safest?**  
    A. It is guaranteed across every Copilot surface and tool  
    B. It applies on supported surfaces, but current Agent/CLI/cloud-agent limitations must be considered  
    C. It deletes the files from GitHub  
    D. It is the same thing as `.gitignore`  
    **Answer: B**

13. **Which statement about Copilot output ownership is correct?**  
    A. GitHub automatically owns all output  
    B. Output is automatically public domain  
    C. GitHub does not claim ownership, but third-party rights/licensing can still apply  
    D. Public-code filtering guarantees no IP concerns  
    **Answer: C**

14. **Copilot invents a method not present in the installed API. What should the developer do?**  
    A. Assume the API has changed  
    B. Ground the request in the actual type definitions/current docs and verify  
    C. Increase the context window only  
    D. Enable content exclusion  
    **Answer: B**

15. **A developer says, "The repo is indexed, so the whole repo is in the model context." What is the correction?**  
    **Answer:** the index helps find/rank candidate chunks; only selected context enters a model call, subject to the prompt/context budget.

16. **A file is not excluded, but Copilot did not use it. What type of failure is this most likely?**  
    **Answer:** selection/retrieval/context failure, not a policy exclusion. Attach/reference the controlling file when known.

---

## Quiz (3 min)

Use 6–8 live; keep the rest in the question bank for self-study.

1. Which component/process area applies policy/safety filtering around model inference?  
   *A: The GitHub Copilot service/proxy and its pre-/post-processing pipeline; public-code matching is one of the documented controls.*
2. For Business/Enterprise, are **IDE Chat and IDE code-completion** prompts/suggestions retained by default?  
   *A: No.*
3. For Business/Enterprise, should you assume **Copilot CLI** has the same no-retention rule as IDE Chat/completions?  
   *A: No. GitHub currently groups CLI with other Copilot access where prompts/suggestions can be retained up to 28 days by default.*
4. Name three things that can contribute to the assembled prompt/context.  
   *A: Current file/selection, open tabs, explicit attachments/#file, custom instructions, retrieved repository chunks, conversation history, tool results.*
5. Difference between repository indexing and a model context window?  
   *A: Indexing finds/ranks candidate content; the context window limits what selected material and output fit into a model call.*
6. Difference between zero-shot and few-shot prompting?  
   *A: Few-shot supplies example input/output pairs to steer format, convention, or behavior.*
7. Why can an AI-generated test suite pass on buggy code?  
   *A: It may encode observed implementation behavior instead of the intended specification.*
8. A developer wants Copilot disabled only for YAML locally. Which control?  
   *A: Editor/language setting.*
9. A Business/Enterprise organization wants a sensitive path ignored by supported Copilot experiences. Which control?  
   *A: Content exclusion.*
10. Does content exclusion apply universally to Agent mode, Copilot CLI, and cloud agent?  
    *A: No — current GitHub documentation lists those as unsupported for content exclusion.*
11. What happens when public-code matching is **allowed**?  
    *A: Matching output can be shown with code references/source and available license information.*
12. Does GitHub claim ownership of Copilot output?  
    *A: No, but third-party rights can still apply and the developer must validate and determine permitted use.*
13. Does Copilot Business/Enterprise customer data train AI models?  
    *A: GitHub states no.*
14. Copilot proposed a performance optimization. What proves it is better?  
    *A: Profiling/benchmarking and before/after measurement on a representative workload.*
15. A file is eligible but retrieval missed it. Can changing a content-exclusion policy fix that?  
    *A: No. Improve context/references/retrieval; exclusion is a separate governance control.*

---

## Takeaways slide

1. **Copilot = context assembly + model inference + policy/safety processing + developer validation.** Draw the lifecycle.
2. **Indexing retrieves; the context window limits.** An indexed repository is not automatically in the prompt.
3. **4S:** Single, Specific, Short, Surround — then iterate and keep history relevant.
4. Persist stable conventions in custom instructions; use explicit files/selections for controlling evidence.
5. **Green tests and plausible security fixes are not proof.** Validate against specification, tests, security tooling, and measurements.
6. Keep governance controls distinct: **editor setting ≠ content exclusion ≠ public-code matching policy.**
7. **Processing ≠ retention ≠ training.** Know the plan/surface distinction.
8. GitHub does not claim ownership of output, but the developer remains responsible for correctness, security, and third-party rights.

---

## Handoff to Week 4

Week 4 covers the official practice assessment, gap review, and the exam decision. Homework before then:

- Add a `.github/copilot-instructions.md` to one repo you own and note the difference.
- Use `/tests` where supported, or a direct test-generation prompt, on one real function and record how many assertions you had to correct.
- In a test repository/organization where you have permission, inspect **Copilot content exclusion** settings and be able to explain who can configure them and which current surfaces do **not** support them.
- Complete at least **12 questions** from the exam question bank above without looking at the answers; revisit every missed concept in the official docs.

Complete these Microsoft Learn modules:

- [Introduction to prompt engineering with GitHub Copilot](https://learn.microsoft.com/training/modules/introduction-prompt-engineering-with-github-copilot/)
- [Developer use cases for AI with GitHub Copilot](https://learn.microsoft.com/training/modules/developer-use-cases-for-ai-with-github-copilot/)
- [Develop unit tests using GitHub Copilot tools](https://learn.microsoft.com/training/modules/develop-unit-tests-using-github-copilot-tools/)

---

## References

- GH-300 study guide — skills measured as of August 7, 2026: <https://learn.microsoft.com/credentials/certifications/resources/study-guides/gh-300>
- GH-300 certification and exam sandbox: <https://learn.microsoft.com/credentials/certifications/github-copilot/>
- GitHub Copilot Fundamentals [Part 1](https://learn.microsoft.com/training/paths/copilot/) and [Part 2](https://learn.microsoft.com/training/paths/gh-copilot-2/)
- GitHub Docs — Copilot: <https://docs.github.com/en/copilot>
- GitHub Docs — [code referencing](https://docs.github.com/en/copilot/concepts/completions/code-referencing), [repository indexing](https://docs.github.com/en/copilot/concepts/context/repository-indexing), and [content exclusion](https://docs.github.com/en/copilot/concepts/context/content-exclusion)
- GitHub Docs — [excluding content from Copilot](https://docs.github.com/en/copilot/how-tos/configure-content-exclusion/exclude-content-from-copilot), [Copilot in your IDE / editor settings](https://docs.github.com/en/copilot/how-tos/configure-personal-settings/configure-in-ide), and [prompt engineering](https://docs.github.com/en/copilot/concepts/prompting/prompt-engineering)
- GitHub Docs — [supported surfaces for Copilot policies](https://docs.github.com/en/copilot/reference/supported-surfaces-for-policies) and [model hosting/data handling](https://docs.github.com/en/copilot/reference/ai-models/model-hosting)
- GitHub Terms of Service — [AI Features: ownership, training, output limitations](https://docs.github.com/en/site-policy/github-terms/github-terms-of-service#j-ai-features-training-and-your-data)
- GitHub Copilot product privacy/FAQ page (retention and training by plan/surface): <https://github.com/features/copilot>
- GitHub Copilot Trust Center FAQ: <https://copilot.github.trust.page/faq>
