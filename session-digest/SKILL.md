---
name: session-digest
description: Generalized end-of-session retrospective for any work session — debugging, feature development, research, study, writing, configuration, or ops. Distills the thread into a Session Digest (a Problems & Resolutions table pairing each problem with its root cause and the fix that worked, plus a Key Takeaways table of commands and concepts to learn next), followed by detailed atomic entries with evidence blocks — code diffs, before/after tables, command transcripts, or decision matrices. Unlike correction-log, entries are not limited to textual corrections; it also captures design decisions, discoveries, and open threads. Use whenever the user wants to wrap up, close out, or review a session, asks "what did we do / fix / decide / learn", wants a retrospective, recap, work log, or session summary, or says "digest this session" — even without naming the format.
version: 1.0
trigger: /session-digest
---

# Session Digest Skill

## Goal
Distill an entire work session — any domain, any medium — into a two-layer artifact:

1. **Digest layer** (at-a-glance): tables pairing each problem with its root cause and the fix that worked, each decision with its rationale, and the lessons worth carrying forward.
2. **Evidence layer** (detail): one atomic entry per problem, decision, or discovery, with the concrete evidence — a code diff, a before/after table, a command transcript, or an option-comparison matrix.

The deliverable is a study aid and a re-entry point for future sessions, not a plain changelog.

## Trigger
Activate when the user:
- Closes or wraps up a session ("close out", "wrap up", "we're done for today")
- Asks what was done, fixed, decided, or learned across the session
- Requests a "session digest", "retrospective", "recap", "work log", or "session summary"
- References a transcript or conversation file with intent to extract what happened and why
- Says "what should I remember from this", "document this session", or similar phrasings without naming the format

## When NOT to use
- The user wants only the errata — every before→after replacement as a chained correction log → use `correction-log` (this skill links to it for sessions that warrant both)
- Organizing complete, non-erroneous notes into a study module → use `module-organizer`
- Cleaning raw transcripts (translation, LaTeX formatting) → use `data-organizer` as preprocessor, then this skill
- A single quick fix with no session arc — a one-row digest is noise; answer inline instead

## Entry Types
Tag every detailed entry with exactly one type:

| Type | What qualifies | Evidence block |
| :--- | :--- | :--- |
| `Problem` | Something broke, misbehaved, or blocked progress, and the thread resolved (or abandoned) it | Code diff, command transcript, or before/after table |
| `Decision` | The thread weighed alternatives and committed to one | Option-comparison table with the chosen row marked |
| `Discovery` | A non-obvious fact, constraint, or behavior surfaced that changes how future work is done | Quote, table, or minimal reproducing snippet |
| `Open` | A thread that did not converge — blocked, deferred, or unanswered | Whatever partial evidence exists, plus the blocker |

Routine completed work (e.g., "renamed the folder", "bumped the version") does not get an entry — mention it in one line under **Also done** at the digest tail if worth recording at all.

## Instructions

1. **Pre-processing**: If the raw transcript needs cleanup, translation, or LaTeX formatting, apply the `data-organizer` skill first.
2. **Scan & Extract**: Read the full session. Identify every problem solved, decision made, discovery surfaced, and thread left open. A problem does not require a textual correction — a config change, an environment fix, or an "ohh, it was the firewall" realization all qualify.
3. **Categorize**: Assign each entry a type (`Problem`, `Decision`, `Discovery`, `Open`) and a domain tag (`Code`, `Math`, `Config`, `Conceptual`, `Process`, `Reference`).
4. **Order**: Chronological by resolution time. Group only when multiple entries share an identical root cause; mark the grouping with a parent heading and state the dependency.
5. **Root cause, not symptom**: In both the digest table and the entries, state why it broke, not what it looked like. Apply the 5 Whys when the thread supports it; stop at the deepest cause the thread actually established.
6. **Evidence Block** — pick per domain:
   - **Code**: fenced ` ```diff ` block. `-` for removed lines, `+` for added, no prefix for ≤3 context lines above and below. When syntax highlighting matters for the final form, follow with a language-tagged fence showing the corrected version in full.
   - **Math**: two-column Markdown table with `Before` and `After` headers; inline math `$...$` inside cells. If an equation exceeds one cell line, add a `### Detailed Math` subsection beneath with block math `$$...$$`.
   - **Config / Ops**: fenced command block showing the command(s) that worked, with a one-line comment per non-obvious flag.
   - **Decision**: comparison table — one row per option, columns `Option`, `Pros`, `Cons`, `Verdict`; bold the chosen row's option name.
   - **Prose / terminology**: two-column table, or `~~wrong~~ → correct` for fixes under ~10 words.
7. **Context Line**: One-line paraphrase of what prompted the entry. Quote verbatim only if the wording itself is the source of confusion.
8. **Pitfall Line** (`Problem` and `Discovery` entries): one sentence naming the cognitive trap (e.g., "assumed `np.where` short-circuits its branches", "treated each webview as sharing one JS context").
9. **Why Section**: The underlying principle, not a restatement of the patch. If the session never established the reason, write `Why: not established in session` rather than fabricating one.
10. **Status Field**:
    - `Resolved`: final, confirmed working in the session.
    - `Decided`: a `Decision` entry that was committed to (revisitable, but settled in this session).
    - `Superseded`: this entry's fix or decision was itself replaced later. Add `Superseded by: Entry N`; the replacing entry carries `Supersedes: Entry M`.
    - `Open`: did not converge; pair with a **Next step** line stating the single most concrete action to resume.
11. **Preserve Callouts, Links, Figures**: Keep `>[!remark]`/`>[!question]`/`>[!note]` blocks attached to their entry. Append URLs/citations under `**References:**` at the entry tail; deduplicate. Never drop a link or figure silently.
12. **Verify**: Confirm each "fix that worked" was actually confirmed working in the session. If the session declared victory without verification, mark `Status: Resolved (unverified)` — do not upgrade it.
13. **Handoff to correction-log**: If the session contains a debugging chain whose intermediate wrong attempts matter (the trajectory is the lesson), note `→ run /correction-log for the full per-replacement chain` under that entry instead of duplicating the chain here.
14. **Language**: English only in output, regardless of source language.

## Digest Layer

Build the digest from the detailed entries plus any one-line **Also done** items.

1. **Problems & Resolutions table**: One row per `Problem` entry, ordered by resolution. Columns: `#`, `Problem`, `Root cause`, `Fix that worked`, `Status`, `Ref`. `Ref` links to the backing entry (e.g., `Entry 3`); use `—` when none exists. Unconverged problems stay in the table with `Status: Open`.
2. **Decisions table** (only when ≥1 `Decision` entry exists): Columns: `#`, `Decision`, `Options considered`, `Chosen & why`, `Ref`.
3. **Key Takeaways table**: The study layer. Columns: `Key point / command`, `What it does`, `When to use`, `Pitfall to avoid`. Derive each row from an entry's `Pitfall` and `Why` so the lesson generalizes beyond the one incident. Literal commands go in backticks in the first cell.
4. **Open Threads list** (only when ≥1 `Open` entry exists): bullet list of `item — blocker — next step`. This is the re-entry point for the next session.
5. **Concrete-change rule**: Every takeaway is an actionable rule or command, never vague advice. Reject "be careful with multi-window state" — write "persist shared auth state via the OS keychain (`secrets_set`/`secrets_get`); each Tauri webview has an isolated JS context."
6. **Scope**: Derive everything from the session only. Do not invent problems, decisions, or lessons that never occurred. An empty session yields no digest — say so rather than padding tables.

## Content Writing Rules

* **Eliminate Adverbs**: Drop filler such as `natively`, `dynamically`, `inherently`, `flawlessly`, `simply`, `clearly`, `essentially`.
* **Verb-Driven Phrasing**: Direct verbs over descriptive clauses ("swaps operand order" over "engages in a process of operand order modification").
* **Directness**: Zero preamble. State the problem, the cause, the fix, the lesson.
* **No Speculation**: Do not invent reasons absent from the session. `Why: not established in session` is acceptable.

## Formatting Standards

### Math Expression Rules
* Inline math: `$...$`. Required inside table cells.
* Block math: `$$...$$` on independent lines with blank lines before and after. Outside tables only.
* Vectors: bold lowercase $\mathbf{x}$. Matrices: bold uppercase $\mathbf{A}$. Estimates: $\hat{x}$. Sets: $\mathcal{X}$.
* Never use `\(...\)` or `\[...\]`.

### Diff Block Rules (Code)
* Fenced ` ```diff ` block; `-` removed, `+` added, no prefix for context.
* ≤3 context lines above and below, only when needed to disambiguate.

### Reference Rules
* Placement: tail of the entry, before the `---` separator or next `##` heading.
* Format: bullet list under `**References:**`. Deduplicate identical links; a link cited in one entry stays scoped to it.

## Output Blueprint

```
# Session Digest: [Source Identifier]

## Problems & Resolutions

| # | Problem | Root cause | Fix that worked | Status | Ref |
| :-- | :--- | :--- | :--- | :--- | :--- |
| 1 | [What broke] | [Why it broke, not the symptom] | [The change that resolved it] | Resolved | Entry 1 |

## Decisions
<!-- Include only when the session contains decisions. -->

| # | Decision | Options considered | Chosen & why | Ref |
| :-- | :--- | :--- | :--- | :--- |

## Key Takeaways — Commands & Concepts to Learn

| Key point / command | What it does | When to use | Pitfall to avoid |
| :--- | :--- | :--- | :--- |
| `command or concept` | [One-line function] | [Trigger condition] | [The trap to dodge] |

## Open Threads
<!-- Include only when something did not converge. -->
- [Item] — [blocker] — **Next step:** [single concrete action]

**Also done:** [one-liners for routine completed work, if any]

---

## Entry 1: [Short Title]

**Type**: Problem | Decision | Discovery | Open
**Domain**: Code | Math | Config | Conceptual | Process | Reference
**Context**: [One-line paraphrase of what prompted this.]
**Pitfall**: [One sentence on the cognitive trap. Problem/Discovery entries only.]
**Supersedes**: Entry N (omit unless this replaces an earlier entry)
**Superseded by**: Entry M (omit unless replaced later)

### Evidence

[Diff block, command block, before/after table, or option-comparison table per domain.]

### Why
Flow: [Premise] -> [Resolution] -> [Principle]

[Concise principle explanation. No filler.]

**Status**: Resolved | Decided | Superseded | Open
**Next step**: [Open entries only — single concrete action to resume.]
**References:**
- [Link title](https://...)

---

## Entry 2: [Same pattern.]
```

## Worked Patterns

### Problem Entry (Code domain)

**Type**: Problem
**Domain**: Code
**Context**: Authenticating in the Settings window still required re-authenticating in the main chat window.
**Pitfall**: Stored auth state in a JS module variable, assuming all windows share one runtime — each Tauri webview has an isolated JS context.

#### Evidence

```diff
- export function isCopilotAuthenticated(): boolean {
-   return cachedGhuToken !== null;
- }
+ export async function isCopilotAuthenticated(): Promise<boolean> {
+   if (cachedGhuToken) return true;
+   const v = await invoke<string | null>("secrets_get", {
+     service: KEYRING_SERVICE,
+     account: "copilot-ghu-token",
+   });
+   return !!v;
+ }
```

#### Why
Flow: module memory is per-webview -> shared state needs a persistence layer outside JS -> OS keychain via `secrets_set`/`secrets_get`.

**Status**: Resolved

---

### Decision Entry

**Type**: Decision
**Domain**: Process
**Context**: Where to persist the shared auth token across windows.

#### Evidence

| Option | Pros | Cons | Verdict |
| :--- | :--- | :--- | :--- |
| `localStorage` | Zero setup | Per-webview origin scoping; plaintext on disk | Rejected |
| Shared JSON file | Window-agnostic | Plaintext token on disk; manual locking | Rejected |
| **OS Keychain via Rust `secrets_*`** | Encrypted at rest; window-agnostic; async API already wrapped | Requires Tauri command round-trip | **Chosen** |

#### Why
Flow: token is a secret -> plaintext-at-rest options eliminated -> keychain is the only window-agnostic encrypted store available.

**Status**: Decided

---

### Discovery Entry

**Type**: Discovery
**Domain**: Conceptual
**Context**: `gpt-5.4-mini` requests failed against the Copilot proxy while `gpt-5-mini` succeeded.
**Pitfall**: Assumed all OpenAI-named models on Copilot speak `/chat/completions`.

#### Evidence

| Model | Endpoint Copilot actually serves |
| :--- | :--- |
| `gpt-5-mini` | `/chat/completions` (standard) |
| `gpt-5.4-mini` | proprietary `/responses` stream only |

#### Why
Flow: Copilot gates newer internal models behind a proprietary stream -> standard-endpoint assumption fails per-model -> map unsupported IDs to a supported fallback before the proxy fetcher.

**Status**: Resolved

---

### Open Entry

**Type**: Open
**Domain**: Config
**Context**: Token refresh flow when the keychain entry expires mid-session.

#### Evidence

Refresh path was identified but never exercised; session ended before an expired-token scenario could be reproduced.

#### Why
Why: not established in session.

**Status**: Open
**Next step**: Force-expire the keychain entry (`secrets_delete` then restart) and trace the re-auth path in `copilotAuth.ts`.

---

### Digest Example (built from the four entries above)

#### Problems & Resolutions

| # | Problem | Root cause | Fix that worked | Status | Ref |
| :-- | :--- | :--- | :--- | :--- | :--- |
| 1 | Re-auth demanded in every window | Auth state in per-webview module memory | Persist token to OS keychain via `secrets_set`/`secrets_get` | Resolved | Entry 1 |
| 2 | `gpt-5.4-mini` requests fail on Copilot | Model served only via proprietary `/responses` stream | Map `gpt-5.4-mini` → `gpt-5-mini` before the proxy fetcher | Resolved | Entry 3 |
| 3 | Token-expiry refresh path unexercised | Session ended before reproduction | — | Open | Entry 4 |

#### Key Takeaways — Commands & Concepts to Learn

| Key point / command | What it does | When to use | Pitfall to avoid |
| :--- | :--- | :--- | :--- |
| Tauri webview memory isolation | Each window runs an independent JS context | Any multi-window Tauri app sharing state | Global state in a JS module variable — use the OS keychain or a persistent store |
| `secrets_set` / `secrets_get` | Read/write the OS keychain from any webview | Sharing secrets across windows | Forgetting the API is async — gate UI on the awaited read |
| Copilot model mapping | Newer internal models skip `/chat/completions` | Integrating unofficial Copilot endpoints | Assuming endpoint support is uniform across model IDs — test per model |
