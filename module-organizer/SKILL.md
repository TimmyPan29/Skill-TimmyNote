---
name: module-organizer
description: Reorganize and consolidate technical notes from a user-referenced file by merging identical or related concepts into comparison tables, with intuitive guides, cognitive-flow lines, rigorous derivations, and proofs/examples in dedicated sections. Trigger whenever the user asks to organize, consolidate, merge, deduplicate, restructure, or compare technical notes/modules/sections — including loose phrasings like "clean this up", "make a study sheet", "turn these into a comparison", or any reference to a notes file by name without an explicit verb.
version: 1.4
---

# /module-organizer

# Module Organizer Skill

## Goal
Reorganize and consolidate technical notes from a user-specified file. Merge related concepts into comparison tables, surface cognitive flow, and isolate proofs/examples — balancing rigor with concise intuition.

## Trigger
Activate when the user:
- Asks to organize, consolidate, merge, or restructure a module/file.
- Requests a comparison table across related concepts.
- References a notes file and wants any form of cleanup, deduplication, or study-sheet conversion.
- Uses loose phrasings ("clean these up", "polish these notes", "make sense of these") while pointing at a notes file.

## Workflow

1. **Pre-process**: If the `data-organizer` skill is available, apply it first. Otherwise, perform equivalent normalization inline — translate non-English content to English, convert math to LaTeX with `$...$` / `$$...$$`, fix obvious typos, unify nomenclature.
2. **Read & enumerate**: Read the full pre-processed file. List every concept, definition, and term.
3. **Group**: A Concept Group requires ≥ 2 contrastable items. Solitary concepts get their own section without a table.
4. **Write each Concept Group** in fixed order: Intuitive Guide → Contrast Table (if applicable) → Flow → Details → Conclusion → References.
5. **Extract proofs and worked examples** to the bottom `# Proofs & Examples` section. Cross-reference from the originating concept.
6. **Preserve embedded figures**: retain every image, identify what it depicts, place it in the most contextually relevant section. Never delete.
7. **Preserve callouts**: retain every `>[!remark]`, `>[!question]`, `>[!warning]`, `>[!example]`, `>[!note]`, `>[!tip]`, `>[!hint]`, etc. Keep the container, not just the content. Position contextually.
8. **Preserve links and citations**: append to `**References:**` at the tail of the owning section. Deduplicate identical links. A link cited only inside a specific proof goes under that proof, not its parent concept.
9. **Verify**: run the `Verification Checklist` at the end before finalizing.

## Structural Rules

### Intuitive Guide
One sentence at the top of each Concept Group. Identifies the most common confusion or the core problem the concepts address. No preamble.

### Contrast Table
- First column header: `Aspect`. Subsequent columns: one per concept.
- Each cell ≤ 25 words. Use math notation, not prose, when applicable.
- Default rows: `Definition`, `Key Property`, `Domain of Validity`, `Failure Mode`. Add rows tailored to the group.

### Flow Line
Precede every `### Details` block with `Flow: A -> B -> C -> ...`. Each node ≤ 6 tokens, maximum 6 nodes. No full sentences.

### Conclusion
End each Concept Group with a one-paragraph or one-equation strict definition — the most general form. Distinct from the Intuitive Guide.

## Content Rules

- **Eliminate filler adverbs**: drop `natively`, `dynamically`, `securely`, `inherently`, `flawlessly`, `seamlessly`, `robustly`. Zero mathematical value.
- **Verb-driven phrasing**: prefer "defines mapping rules" over "actively manages complex mapping combinations".
- **Zero preamble**: no "in this section we will discuss". State the content directly.
- **State conditions, not hedges**: replace "rather generally holds" with "holds under WSSUS" or equivalent.
- **English only** in all output.

## Formatting Standards

### Math
- Inline (including table cells): `$equation$`.
- Block: `$$ ... $$` on its own line, with one blank line before and after.
- Wrap every variable, operator, and symbol in math delimiters in prose.

### Notation
- Vectors: bold lowercase, $\mathbf{x}$.
- Matrices: bold uppercase, $\mathbf{A}$.
- Estimates: $\hat{x}$.
- Sets: calligraphic, $\mathcal{X}$.

### References
- Placement: immediately before the next `##` heading, or before the `---` preceding `# Proofs & Examples`.
- Format:

  ```
  **References:**
  - [Descriptive title](https://example.com/path)
  - Author, "Paper Title," Journal, Year.   (when no URL)
  ```

## Output Blueprint

```
# [Module Title]

## [Concept Group 1]

**Intuitive Guide**: [One sentence: the common confusion or core problem.]

| Aspect | Concept A | Concept B |
| :--- | :--- | :--- |
| Definition | ... | ... |
| Key Property | ... | ... |
| Domain of Validity | ... | ... |
| Failure Mode | ... | ... |

### Details
Flow: [Step 1] -> [Step 2] -> [Step 3]

[Verb-driven derivation. Tables for sub-classifications.]

>[!remark]
> [Preserved personal note, placed contextually.]

**Conclusion**: [Strictest technical definition.]

**References:**
- [Link title](https://...)

## [Concept Group 2]
[Same pattern.]

---

# Proofs & Examples

## Proof: [Title]   (cross-ref: Concept Group 1)
Flow: [Premise] -> [Key Lemma] -> [Conclusion]

[Full derivation.]

**References:**
- [Link title](https://...)

## Example: [Title]   (cross-ref: Concept Group 2)
Flow: [Setup] -> [Computation] -> [Result]

[Worked example.]
```

## Micro-Example

**Input fragment:**
> "MMSE estimator minimizes mean square error. LMMSE is the linear version. ML maximizes likelihood. MAP adds a prior."

**Output fragment:**
```
## Bayesian Estimators

**Intuitive Guide**: MMSE/LMMSE/ML/MAP differ in (a) what they optimize and (b) whether linearity or a prior is imposed.

| Aspect | MMSE | LMMSE | ML | MAP |
| :--- | :--- | :--- | :--- | :--- |
| Objective | $\min E[\|\hat{x} - x\|^2]$ | Same, restricted to linear $\hat{x}$ | $\max p(y \mid x)$ | $\max p(x \mid y)$ |
| Prior used | Yes | Yes (1st/2nd moments only) | No | Yes |
| Output | $E[x \mid y]$ | $\mathbf{K}_{xy}\mathbf{K}_{yy}^{-1}\mathbf{y}$ | $\arg\max_x p(y \mid x)$ | $\arg\max_x p(y \mid x)\,p(x)$ |
| Failure mode | Posterior intractable | Non-Gaussian → suboptimal | Overfits, no regularization | Sensitive to prior misspecification |

### Details
Flow: prior + likelihood -> posterior -> point estimator

**Conclusion**: An estimator is fully specified by its loss functional and the statistical structure it assumes; MMSE = $L^2$-loss with full posterior, LMMSE = $L^2$-loss restricted to affine maps, ML = no prior, MAP = mode of posterior under $L^{0/1}$-loss.
```

## Anti-Patterns

- Building a single-column "comparison" table for a solitary concept. Use Intuitive Guide → Details → Conclusion prose instead.
- Inlining proofs longer than ~5 lines inside Concept Groups. Move to `# Proofs & Examples`.
- Paraphrasing the source as prose when a table would convey the contrast in one screen.
- Dropping `>[!...]` callouts or merging them into prose. Preserve the container.
- Silent deletion of figures or links.
- Verb-padding ("we will now actively examine"). Cut.

## Verification Checklist

Before delivering, confirm:
1. Every Concept Group follows Intuitive Guide → (Table if ≥ 2 concepts) → Flow → Details → Conclusion.
2. Every proof and worked example lives under `# Proofs & Examples`, cross-referenced.
3. Every figure from the source appears exactly once, in a contextually correct location.
4. Every link/citation from the source appears under a `**References:**` block in its owning section.
5. All `>[!...]` callouts from the source are preserved with their container.
6. All math uses `$...$` / `$$...$$`; no `\(...\)` or `\[...\]`.
7. Output is in English.
8. No filler adverbs; phrasing is verb-driven.
9. Factual/logical errors in the source were corrected in place; substantive corrections noted inside a `>[!remark]`.
