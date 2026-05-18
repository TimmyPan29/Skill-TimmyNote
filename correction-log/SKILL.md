---
name: correction-log
description: Extracts and consolidates corrections, errata, and fixes from a conversation thread or transcript into a structured chronological errata log. Produces atomic correction entries with code-diff blocks for code changes and before/after comparison tables for math, prose, and terminology revisions, each with a pitfall note and the underlying reason. Use whenever the user asks to summarize what was wrong, what got fixed, what was corrected, or to produce an errata log/correction log/diff summary from a chat transcript or conversation — even if they only say "track the fixes" or "where did I go wrong" without naming the format.
metadata:
  version: "1.0"
---

# /correction-log

# Correction Log Skill

## Goal
Extract every correction made during a conversation thread and present them as a structured errata log. Each entry pairs the original error with its fix using a diff block (code) or comparison table (math, prose, terminology), followed by the underlying reason and a pitfall note. The deliverable is a study aid, not a plain changelog.

## Trigger
Activate when the user:
- Asks to summarize corrections, errata, or fixes from a chat
- Requests a "correction log", "errata document", "diff summary", or "fix list"
- References a conversation file with intent to extract where things were revised
- Asks what was wrong and what is right across a multi-turn exchange
- Says "track the fixes", "show where I was off", or similar phrasings without naming the format

## When NOT to use
- Organizing complete, non-erroneous notes into a study module → use `module-organizer`
- Cleaning raw transcripts (translation, LaTeX-formatting) → use `data-organizer` as preprocessor, then this skill
- Producing a full conversation summary that includes uncorrected content → out of scope; this skill captures revisions only

## Instructions

1. **Pre-processing**: If the raw transcript needs cleanup, translation, or LaTeX formatting, apply the `data-organizer` skill first.
2. **Scan & Extract**: Read the full conversation. Identify every instance where a claim, code snippet, equation, definition, or reference was revised. Include both self-corrections and user-issued corrections. A "correction" requires a *replacement* of prior content — pure additions, expansions, and clarifications do not qualify.
3. **Categorize**: Tag each correction as `Code`, `Math`, `Conceptual`, `Terminology`, or `Reference`.
4. **Order**: Chronological by default. Group only when multiple entries share an identical root cause; mark the grouping with a parent heading and indicate dependency explicitly.
5. **Atomic Entries — Per-Replacement Granularity**: One entry per textual replacement, including intermediate failed attempts that were themselves later replaced. Each entry captures exactly one before→after transition. Related entries in a debugging chain link via `Supersedes: Correction N` / `Superseded by: Correction M` fields placed in the entry header. Do not merge entries even when they share a root cause — the chain is the artifact, since it reveals the debugging trajectory and the trap each intermediate fell into.
6. **Before/After Block**:
   - **Code**: fenced ` ```diff ` block. Use `-` for removed lines, `+` for added lines, no prefix for ≤3 lines of unchanged context above and below.
   - **Math**: two-column Markdown table with `Before` and `After` headers; inline math `$...$` inside cells. If the equation exceeds one cell line, add a `### Detailed Math` subsection beneath the table with block math `$$...$$`.
   - **Prose/terminology**: two-column table, or `~~wrong~~ → correct` for fixes under ~10 words.
7. **Context Line**: One-line paraphrase of the user message that prompted the exchange. Quote verbatim only if the wording itself is the source of confusion.
8. **Pitfall Line**: One sentence naming the cognitive trap (e.g., "confused $\mathbf{H}^T$ with $\mathbf{H}^{-1}$ in non-square case", "treated NumPy broadcasting as element-wise multiply").
9. **Why Section**: Brief explanation of the underlying principle, not just restating the patch. If the conversation never stated the reason, write `Why: not stated in thread` rather than fabricating one.
10. **Status Field**:
    - `Resolved`: final, correct, no further revision in the thread.
    - `Superseded`: this entry was itself replaced by a later entry. Add `Superseded by: Correction N` in the entry header.
    - `Unresolved`: the thread did not converge; the fix was never confirmed.

    When an entry corrects a prior entry, add `Supersedes: Correction N` in the new entry's header so the chain reads in both directions.
11. **Preserve Callouts**: Keep all `>[!remark]`, `>[!question]`, `>[!note]` blocks attached to their originating entry.
12. **Preserve Links, References, Figures**: Append URLs/citations under `**References:**` at the entry tail; deduplicate identical links. Keep embedded figures at the entry they document. Never drop a link or figure silently.
13. **Verify**: Confirm the "after" version is actually correct before finalizing. If a correction itself is wrong, fix it in place and add a `>[!remark]` describing the second-order correction.
14. **Language**: English only in output, regardless of the source transcript language.

## Content Writing Rules

* **Eliminate Adverbs**: Drop filler such as `natively`, `dynamically`, `inherently`, `flawlessly`, `simply`, `clearly`, `essentially`. They consume reader attention without adding information.
* **Verb-Driven Phrasing**: Direct verbs over descriptive clauses (e.g., "swaps operand order" over "engages in a process of operand order modification").
* **Directness**: Zero preamble. State the error, the fix, the reason.
* **No Speculation**: Do not invent reasons absent from the thread. `Why: not stated in thread` is acceptable.

## Formatting Standards

### Math Expression Rules
* Inline math: `$...$`. Required inside table cells.
* Block math: `$$...$$` on independent lines with blank lines before and after. Outside tables only.
* Vectors: bold lowercase $\mathbf{x}$. Matrices: bold uppercase $\mathbf{A}$. Estimates: $\hat{x}$. Sets: $\mathcal{X}$.
* Never use `\(...\)` or `\[...\]`.

### Diff Block Rules (Code)
* Fenced ` ```diff ` block.
* `-` prefix: removed line. `+` prefix: added line. No prefix: unchanged context line.
* Provide ≤3 context lines above and below the change, only when context is needed to disambiguate.
* When syntax highlighting matters for the final form, follow the diff block with a second `language`-tagged fence showing the corrected version in full.

### Reference Rules
* Placement: tail of the entry, immediately before the `---` separator or next `##` heading.
* Format: bullet list under `**References:**`.
* Deduplicate identical links. A link cited only inside a single correction stays scoped to that correction.

## Output Blueprint

```
# Correction Log: [Source Identifier]

## Correction 1: [Short Title]

**Category**: Code | Math | Conceptual | Terminology | Reference
**Context**: [One-line paraphrase of the originating user message.]
**Pitfall**: [One sentence on the cognitive trap.]
**Supersedes**: Correction N (omit if this is not a follow-up)
**Superseded by**: Correction M (omit if this entry is final)

### Before → After

[Diff block for code, OR two-column table for math/prose.]

### Why
Flow: [Premise] -> [Correction] -> [Principle]

[Concise principle explanation. No filler.]

**Status**: Resolved | Superseded | Unresolved
**References:**
- [Link title](https://...)

---

## Correction 2: [Short Title]
[Same pattern.]
```

## Worked Patterns

### Code Correction Example

**Category**: Code
**Context**: User asked why MMSE estimator returned garbage at low SNR.
**Pitfall**: Dropped the noise-regularization term, collapsing MMSE to plain least squares.

### Before → After

```diff
  def mmse_estimate(H, y, sigma2):
-     return np.linalg.inv(H.T @ H) @ y
+     return np.linalg.inv(H.T @ H + sigma2 * np.eye(H.shape[1])) @ H.T @ y
```

### Why
Flow: low-SNR ill-conditioning -> $\sigma^2 \mathbf{I}$ regularizer -> stable inverse.

The MMSE estimator under Gaussian noise is $\hat{\mathbf{x}} = (\mathbf{H}^T \mathbf{H} + \sigma^2 \mathbf{I})^{-1} \mathbf{H}^T \mathbf{y}$. Omitting $\sigma^2 \mathbf{I}$ removes the noise-aware shrinkage, and the left-multiplication by $\mathbf{H}^T$ is required whenever $\mathbf{H}$ is non-square.

**Status**: Resolved

---

### Math Correction Example

**Category**: Math
**Context**: User wrote pseudo-inverse using normal equations for non-square $\mathbf{H}$.
**Pitfall**: Treated $(\mathbf{H}^T \mathbf{H})^{-1}$ as if it absorbed the $\mathbf{H}^T$ that maps $\mathbf{y}$ into the column space.

### Before → After

| Before | After |
| :--- | :--- |
| $\hat{\mathbf{x}} = (\mathbf{H}^T \mathbf{H})^{-1} \mathbf{y}$ | $\hat{\mathbf{x}} = (\mathbf{H}^T \mathbf{H})^{-1} \mathbf{H}^T \mathbf{y}$ |

### Why
Flow: minimize $\|\mathbf{y} - \mathbf{H}\mathbf{x}\|^2$ -> set gradient to zero -> $\mathbf{H}^T \mathbf{H} \hat{\mathbf{x}} = \mathbf{H}^T \mathbf{y}$.

The normal equations produce $\mathbf{H}^T \mathbf{y}$ on the right-hand side, not $\mathbf{y}$. Skipping the $\mathbf{H}^T$ leaves dimensional inconsistency when $\mathbf{H}$ is $m \times n$ with $m \ne n$.

**Status**: Resolved

---

### Terminology Correction Example

**Category**: Terminology
**Context**: User equated Doppler spread with coherence time.
**Pitfall**: Conflated reciprocal quantities; dimensional check would have caught it.

### Before → After

| Before | After |
| :--- | :--- |
| Coherence time $=$ Doppler spread | $T_c \approx 1 / f_D$ |

### Why
Flow: Doppler spread $f_D$ has units of Hz -> coherence time $T_c$ has units of seconds -> they are reciprocals, not equal.

Coherence time is the duration over which the channel response stays correlated. It scales inversely with the Doppler spread, which measures the channel's rate of change.

**Status**: Resolved

---

### Chained Entries Example (Per-Replacement Granularity)

When a debugging session contains an intermediate wrong attempt followed by the real fix, produce two entries linked via `Supersedes` / `Superseded by`. The chain reads forward and backward.

#### Correction 1: First Attempt at Equalizer Guard

**Category**: Code
**Context**: User's equalizer produced NaN; first patch attempted to mask zero entries with `np.where`.
**Pitfall**: Assumed `np.where` short-circuits its branches.
**Superseded by**: Correction 2

##### Before → After

```diff
- return Y / H
+ return np.where(H != 0, Y / H, 0)
```

##### Why
Flow: NaN observed $\Rightarrow$ guard with `np.where` $\Rightarrow$ branches still evaluated eagerly $\Rightarrow$ NaN persists.

This patch fails because Python evaluates both branches of `np.where` before the function sees the mask.

**Status**: Superseded

---

#### Correction 2: Masked `np.divide`

**Category**: Code
**Context**: First patch still produced NaN; replaced with a masked ufunc.
**Pitfall**: Mask must apply *inside* the division operation, not around it.
**Supersedes**: Correction 1

##### Before → After

```diff
- return np.where(H != 0, Y / H, 0)
+ result = np.zeros_like(Y)
+ np.divide(Y, H, out=result, where=(H != 0))
+ return result
```

##### Why
Flow: ufunc-level mask skips the division at masked positions $\Rightarrow$ no NaN ever produced $\Rightarrow$ `out=` supplies fallback.

`np.divide` with `where=` is a masked ufunc — the arithmetic is gated at the C level rather than in Python.

**Status**: Resolved
